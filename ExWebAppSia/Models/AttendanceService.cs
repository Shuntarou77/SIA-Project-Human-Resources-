using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class AttendanceService
    {
        private readonly IMongoCollection<Attendance> _attendance;
        public const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;
        public static readonly DateTime TRACKING_START_DATE = new DateTime(2026, 1, 1);

        /// <summary>
        /// Calculates the number of working days (Monday to Saturday) between two dates inclusive.
        /// </summary>
        public static int GetWorkingDaysCount(DateTime startDate, DateTime endDate)
        {
            if (startDate > endDate) return 0;
            
            int count = 0;
            for (var d = startDate.Date; d <= endDate.Date; d = d.AddDays(1))
            {
                if (d.DayOfWeek != DayOfWeek.Sunday)
                {
                    count++;
                }
            }
            return count;
        }

        public static int GetTotalWorkingDaysInYear(int year)
        {
            return GetWorkingDaysCount(new DateTime(year, 1, 1), new DateTime(year, 12, 31));
        }

        public AttendanceService()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== AttendanceService Constructor Called ===");
                _attendance = MongoDBHelper.GetAttendanceCollection();
                System.Diagnostics.Debug.WriteLine($"AttendanceService initialized - Collection name: {_attendance.CollectionNamespace.CollectionName}, Database: {_attendance.Database.DatabaseNamespace.DatabaseName}");
                System.Diagnostics.Trace.WriteLine($"TRACE: AttendanceService initialized successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR initializing AttendanceService: {ex.Message}\n{ex.StackTrace}");
                System.Diagnostics.Trace.WriteLine($"TRACE ERROR: {ex.Message}");
                throw;
            }
        }

        // Record time in for an employee
        public async Task<bool> TimeInAsync(string employeeId, string employeeName, string department)
        {
            try
            {
                var today = DateTime.UtcNow.AddHours(8).Date; // PH Local Date
                var now = DateTime.UtcNow;

                System.Diagnostics.Debug.WriteLine($"TimeInAsync called - EmployeeId: {employeeId}, EmployeeName: {employeeName}, Department: {department}");

                // 1. Check for ANY active shift (no TimeOut) regardless of date
                var activeShift = await _attendance
                    .Find(a => a.EmployeeId == employeeId && a.TimeOut == null && a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                if (activeShift != null)
                {
                    // If the active shift is from a previous day, auto-close it
                    if (activeShift.Date < today)
                    {
                        System.Diagnostics.Debug.WriteLine($"Closing stale shift from {activeShift.Date:yyyy-MM-dd} before new TimeIn");
                        activeShift.TimeOut = activeShift.TimeIn.Value.AddHours(8); // Default to 8 hour shift if forgotten
                        await _attendance.ReplaceOneAsync(a => a.Id == activeShift.Id, activeShift);
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Already have an active shift for today");
                        return false;
                    }
                }

                // 2. Check if a RECORD exists for today (maybe already timed out)
                var existingRecord = await _attendance
                    .Find(a => a.EmployeeId == employeeId && a.Date == today && a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                if (existingRecord != null && existingRecord.TimeOut.HasValue)
                {
                    System.Diagnostics.Debug.WriteLine("Employee already timed out today, creating second shift");
                }
                else if (existingRecord != null && !existingRecord.TimeIn.HasValue)
                {
                    var localNow = now.AddHours(8);
                    existingRecord.TimeIn = now;
                    existingRecord.EmployeeName = employeeName;
                    existingRecord.Department = department;
                    
                    var shiftStart = new DateTime(localNow.Year, localNow.Month, localNow.Day, 8, 0, 0);
                    if (localNow > shiftStart.AddMinutes(15))
                    {
                        var diff = localNow - shiftStart;
                        existingRecord.LateTime = $"{(int)diff.TotalHours:D2}:{(int)diff.Minutes:D2}:{(int)diff.Seconds:D2}";
                    }
                    
                    await _attendance.ReplaceOneAsync(a => a.Id == existingRecord.Id, existingRecord);
                    return true;
                }

                // 3. Create new attendance record
                string lateTimeStr = null;
                var localTime = now.AddHours(8);
                var standardStart = new DateTime(localTime.Year, localTime.Month, localTime.Day, 8, 0, 0);
                
                if (localTime > standardStart.AddMinutes(15))
                {
                    var diff = localTime - standardStart;
                    lateTimeStr = $"{(int)diff.TotalHours:D2}:{(int)diff.Minutes:D2}:{(int)diff.Seconds:D2}";
                }

                var attendance = new Attendance
                {
                    EmployeeId = employeeId,
                    EmployeeName = employeeName,
                    Department = department,
                    Date = today,
                    TimeIn = now,
                    TimeOut = null,
                    LateTime = lateTimeStr,
                    CreatedAt = now,
                    IsActive = true
                };

                await _attendance.InsertOneAsync(attendance);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in TimeInAsync: {ex.Message}");
                return false;
            }
        }

        // Record time out for an employee
        public async Task<bool> TimeOutAsync(string employeeId)
        {
            try
            {
                var today = DateTime.UtcNow.AddHours(8).Date;
                var now = DateTime.UtcNow;

                // Find the active shift. Prefer today's shift if multiple exist
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.TimeOut == null && 
                               a.IsActive)
                    .SortByDescending(a => a.Date)
                    .ThenByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                if (attendance != null && attendance.TimeIn != null && attendance.TimeOut == null)
                {
                    attendance.TimeOut = now;
                    await _attendance.ReplaceOneAsync(a => a.Id == attendance.Id, attendance);

                    // Calculate and record overtime worked in the OvertimeRequests collection
                    var otService = new OvertimeService();
                    var otRequest = await otService.GetByAttendanceIdAsync(attendance.Id);
                    if (otRequest != null && otRequest.Status == "Approved")
                    {
                        var localTimeOut = now.AddHours(8); // Convert to PH time
                        var shiftEnd = new DateTime(localTimeOut.Year, localTimeOut.Month, localTimeOut.Day, 17, 0, 0); // 5 PM
                        
                        if (localTimeOut > shiftEnd)
                        {
                            var ot = localTimeOut - shiftEnd;
                            string otWorked = $"{(int)ot.TotalHours:D2}:{ot.Minutes:D2}:{ot.Seconds:D2}";
                            
                            var employeeService = new EmployeeService();
                            var employee = await employeeService.GetEmployeeByEmployeeIdAsync(employeeId);
                            
                            // Fetch daily rate from employee base salary (simplified: monthly / 22)
                            decimal dailyRate = 0;
                            if (employee != null)
                            {
                                dailyRate = employee.BaseSalary / 22m; 
                            }
                            
                            // Determine type (simplified: weeked = RestDay)
                            string otType = (localTimeOut.DayOfWeek == DayOfWeek.Saturday || localTimeOut.DayOfWeek == DayOfWeek.Sunday) 
                                ? "RestDay" : "Regular";

                            await otService.SetOvertimeWorkedAsync(attendance.Id, otWorked, dailyRate, otType);
                        }
                    }

                    // NEW: Undertime Detection (If worked hours < 8)
                    var timeDiff = (now - attendance.TimeIn.Value).TotalHours;
                    // Deduct 1 hour for lunch if they worked more than 5 hours (standard assumption)
                    double actualWorkedHours = timeDiff > 5 ? timeDiff - 1 : timeDiff;

                    if (actualWorkedHours < 8)
                    {
                        var utService = new UndertimeService();
                        // ONLY record if there is an APPROVED request for today
                        var utRequest = await utService.GetActiveRequestAsync(employeeId);
                        
                        if (utRequest != null && utRequest.Status == "Approved")
                        {
                            var empService = new EmployeeService();
                            var employee = await empService.GetByEmployeeIdAsync(employeeId);
                            
                            if (employee != null && employee.BaseSalary > 0)
                            {
                                double undertimeHours = 8 - actualWorkedHours;
                                decimal dailyRate = (employee.BaseSalary * 12) / 313m;
                                decimal hourlyRate = dailyRate / 8m;
                                decimal deduction = (decimal)undertimeHours * hourlyRate;

                                var utRecord = new UndertimeRecord
                                {
                                    AttendanceId = attendance.Id,
                                    EmployeeId = employeeId,
                                    EmployeeName = employee.FullName,
                                    Date = DateTime.UtcNow.AddHours(8).Date,
                                    HoursUndertime = undertimeHours,
                                    HourlyRate = hourlyRate,
                                    DeductionAmount = deduction,
                                    Reason = !string.IsNullOrEmpty(utRequest.Reason) ? utRequest.Reason : "Timed out early (Approved)",
                                    RecordedAt = DateTime.UtcNow
                                };
                                await utService.RecordUndertimeAsync(utRecord);
                            }
                        }
                    }

                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error recording time out: {ex.Message}");
                return false;
            }
        }

        // Get attendance records for a specific date
        public async Task<List<Attendance>> GetAttendanceByDateAsync(DateTime date)
        {
            try
            {
                var dateOnly = date.Date;
                System.Diagnostics.Debug.WriteLine($"GetAttendanceByDateAsync - Querying for date: {dateOnly:yyyy-MM-dd}");
                
                var attendanceList = await _attendance
                    .Find(a => a.Date == dateOnly && a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .ToListAsync();

                System.Diagnostics.Debug.WriteLine($"GetAttendanceByDateAsync - Found {attendanceList.Count} records for date {dateOnly:yyyy-MM-dd}");
                foreach (var record in attendanceList)
                {
                    System.Diagnostics.Debug.WriteLine($"  Record - EmployeeId: {record.EmployeeId}, Date: {record.Date:yyyy-MM-dd}, TimeIn: {record.TimeIn?.ToString("yyyy-MM-dd HH:mm:ss") ?? "null"}");
                }

                return attendanceList;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting attendance by date: {ex.Message}\n{ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                }
                return new List<Attendance>();
            }
        }

        // Get all active attendance records (for debugging)
        public async Task<List<Attendance>> GetAllActiveAttendanceAsync()
        {
            try
            {
                var allRecords = await _attendance
                    .Find(a => a.IsActive)
                    .SortByDescending(a => a.Date)
                    .ThenByDescending(a => a.TimeIn)
                    .ToListAsync();
                
                System.Diagnostics.Debug.WriteLine($"GetAllActiveAttendanceAsync - Found {allRecords.Count} total active records");
                return allRecords;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all attendance: {ex.Message}\n{ex.StackTrace}");
                return new List<Attendance>();
            }
        }

        // Get attendance records for all employees within a date range
        public async Task<List<Attendance>> GetAllAttendanceAsync(DateTime startDate, DateTime endDate)
        {
            try
            {
                var filterBuilder = Builders<Attendance>.Filter;
                var filter = filterBuilder.Gte(a => a.Date, startDate.Date) &
                            filterBuilder.Lte(a => a.Date, endDate.Date) &
                            filterBuilder.Eq(a => a.IsActive, true);

                return await _attendance
                    .Find(filter)
                    .SortByDescending(a => a.Date)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all attendance records: {ex.Message}");
                return new List<Attendance>();
            }
        }

        // Get attendance records for a local date (handles timezone conversion)
        public async Task<List<Attendance>> GetAttendanceByLocalDateAsync(DateTime localDate)
        {
            try
            {
                // Get the start and end of the local day in UTC
                var localStart = new DateTime(localDate.Year, localDate.Month, localDate.Day, 0, 0, 0, DateTimeKind.Local);
                var localEnd = localStart.AddDays(1);
                var utcStart = localStart.ToUniversalTime().Date;
                var utcEnd = localEnd.ToUniversalTime().Date;

                System.Diagnostics.Debug.WriteLine($"Querying attendance: Local {localDate:yyyy-MM-dd} = UTC range {utcStart:yyyy-MM-dd} to {utcEnd:yyyy-MM-dd}");

                // Query for records where Date falls within the UTC date range
                var filterBuilder = Builders<Attendance>.Filter;
                var filter = filterBuilder.Eq(a => a.IsActive, true) &
                           (filterBuilder.Eq(a => a.Date, utcStart) | filterBuilder.Eq(a => a.Date, utcEnd));

                var attendanceList = await _attendance
                    .Find(filter)
                    .SortByDescending(a => a.TimeIn)
                    .ToListAsync();

                // Filter to only include records where TimeIn falls within the local day
                var filteredList = attendanceList.Where(a =>
                {
                    if (a.TimeIn == null) return false;
                    var localTimeIn = a.TimeIn.Value.ToLocalTime();
                    return localTimeIn.Date == localDate.Date;
                }).ToList();

                System.Diagnostics.Debug.WriteLine($"Found {filteredList.Count} attendance records for local date {localDate:yyyy-MM-dd}");
                return filteredList;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting attendance by local date: {ex.Message}\n{ex.StackTrace}");
                return new List<Attendance>();
            }
        }

        // Get attendance records for an employee
        public async Task<List<Attendance>> GetEmployeeAttendanceAsync(string employeeId, DateTime? startDate = null, DateTime? endDate = null)
        {
            try
            {
                var filterBuilder = Builders<Attendance>.Filter;
                var filter = filterBuilder.Eq(a => a.EmployeeId, employeeId) & 
                            filterBuilder.Eq(a => a.IsActive, true);

                if (startDate.HasValue)
                {
                    filter = filter & filterBuilder.Gte(a => a.Date, startDate.Value.Date);
                }

                if (endDate.HasValue)
                {
                    filter = filter & filterBuilder.Lte(a => a.Date, endDate.Value.Date);
                }

                var attendanceList = await _attendance
                    .Find(filter)
                    .SortByDescending(a => a.Date)
                    .ToListAsync();

                return attendanceList;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee attendance: {ex.Message}");
                return new List<Attendance>();
            }
        }

        /// <summary>
        /// Get attendance records for an employee within a date range (for payroll processing)
        /// </summary>
        public async Task<List<Attendance>> GetAttendanceByEmployeeAndDateRangeAsync(
            string employeeId, DateTime startDate, DateTime endDate)
        {
            return await GetEmployeeAttendanceAsync(employeeId, startDate, endDate);
        }
                
        // Get attendance records for a department within a date range
        public async Task<List<Attendance>> GetDepartmentAttendanceAsync(string department, DateTime startDate, DateTime endDate)
        {
            try
            {
                var filterBuilder = Builders<Attendance>.Filter;
                var filter = filterBuilder.Eq(a => a.Department, department) &
                            filterBuilder.Gte(a => a.Date, startDate.Date) &
                            filterBuilder.Lte(a => a.Date, endDate.Date) &
                            filterBuilder.Eq(a => a.IsActive, true);

                var attendanceList = await _attendance
                    .Find(filter)
                    .SortByDescending(a => a.Date)
                    .ToListAsync();

                return attendanceList;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting department attendance: {ex.Message}");
                return new List<Attendance>();
            }
        }

        // Check if employee has timed in today
        public async Task<bool> HasTimedInTodayAsync(string employeeId)
        {
            try
            {
                var today = DateTime.UtcNow.AddHours(8).Date;
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.TimeIn != null && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                return attendance != null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error checking time in status: {ex.Message}");
                return false;
            }
        }

        // Check if employee has timed out today
        public async Task<bool> HasTimedOutTodayAsync(string employeeId)
        {
            try
            {
                var today = DateTime.UtcNow.AddHours(8).Date;
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.TimeOut != null && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                return attendance != null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error checking time out status: {ex.Message}");
                return false;
            }
        }

        // Get today's attendance status for an employee
        public async Task<Attendance> GetTodayAttendanceAsync(string employeeId)
        {
            try
            {
                var today = DateTime.UtcNow.AddHours(8).Date;
                var now = DateTime.UtcNow;

                // 1. Look for a record SPECIFICALLY for today's local date
                var todayAttendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                if (todayAttendance != null)
                {
                    // If it's still open, check for auto-timeout (16h)
                    if (todayAttendance.TimeIn.HasValue && !todayAttendance.TimeOut.HasValue)
                    {
                        var hoursWorked = (now - todayAttendance.TimeIn.Value).TotalHours;
                        if (hoursWorked >= 16)
                        {
                            todayAttendance.TimeOut = todayAttendance.TimeIn.Value.AddHours(16);
                            await _attendance.ReplaceOneAsync(a => a.Id == todayAttendance.Id, todayAttendance);
                            System.Diagnostics.Debug.WriteLine($"Auto-timed out TODAY'S shift for {employeeId}");
                        }
                    }
                    return todayAttendance;
                }

                // 2. If no record for today, check for an ACTIVE shift from a previous day
                var staleShift = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.TimeOut == null && 
                               a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                if (staleShift != null)
                {
                    // Check if it should be auto-timed out
                    var hoursWorked = (now - staleShift.TimeIn.Value).TotalHours;
                    if (hoursWorked >= 16 || staleShift.Date < today)
                    {
                        // Shift is too old or from previous day
                        staleShift.TimeOut = staleShift.TimeIn.Value.AddHours(8); // Default closure
                        await _attendance.ReplaceOneAsync(a => a.Id == staleShift.Id, staleShift);
                        System.Diagnostics.Debug.WriteLine($"Auto-closed stale shift from {staleShift.Date:yyyy-MM-dd} for {employeeId}");
                        return null; // Return null so UI shows "Not timed in yet" for today
                    }
                    return staleShift;
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting today's attendance: {ex.Message}");
                return null;
            }
        }

        // Create attendance record directly (for testing/admin purposes)
        public async Task<bool> CreateAttendanceAsync(Attendance attendance)
        {
            try
            {
                if (attendance.Date == DateTime.MinValue)
                {
                    attendance.Date = DateTime.UtcNow.AddHours(8).Date;
                }
                if (attendance.CreatedAt == DateTime.MinValue)
                {
                    attendance.CreatedAt = DateTime.UtcNow;
                }
                attendance.IsActive = true;

                await _attendance.InsertOneAsync(attendance);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating attendance: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Centralized method to calculate comprehensive attendance statistics for an employee.
        /// Consistently used across President, Admin, and Employee dashboards.
        /// </summary>
        /// <summary>
        /// Centralized method to calculate MONTHLY attendance statistics for an employee.
        /// Useful for dashboards that prefer a month-to-month view.
        /// </summary>
        public async Task<AttendanceStats> GetMonthlyAttendanceStatsAsync(string employeeId, DateTime hiredDate)
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8); // PH Local Time
                var todayLocal = now.Date;
                var currentMonthStart = new DateTime(now.Year, now.Month, 1);
                
                // Determine effective start date for THIS MONTH
                var hiredDateLocal = hiredDate == DateTime.MinValue ? TRACKING_START_DATE : hiredDate.ToLocalTime().Date;
                var effectiveStart = currentMonthStart > hiredDateLocal ? currentMonthStart : hiredDateLocal;
                
                // Ensure we don't go before system tracking start
                if (effectiveStart < TRACKING_START_DATE) effectiveStart = TRACKING_START_DATE;

                // CRITICAL: MongoDB queries should use DateTimeKind.Utc to avoid driver-side conversions
                DateTime queryStart = DateTime.SpecifyKind(effectiveStart, DateTimeKind.Utc);
                DateTime queryEnd = DateTime.SpecifyKind(todayLocal, DateTimeKind.Utc);

                // 1. Fetch records for the CURRENT MONTH
                var monthlyRecords = await _attendance
                    .Find(a => a.EmployeeId == employeeId && a.IsActive && a.Date >= queryStart && a.Date <= queryEnd)
                    .ToListAsync();

                // 2. Count PRESENT days
                var presentDates = monthlyRecords
                    .Where(r => r.TimeIn.HasValue)
                    .Select(r => r.Date.Date)
                    .Distinct()
                    .ToList();
                int presentCount = presentDates.Count;

                // 3. Count LATE days
                int lateCount = monthlyRecords
                    .Where(r => r.TimeIn.HasValue)
                    .GroupBy(r => r.Date.Date)
                    .Count(g => {
                        var firstIn = g.OrderBy(r => r.TimeIn).First();
                        var localIn = firstIn.TimeIn.Value.ToLocalTime();
                        // 8:15 AM is the limit
                        return localIn.Hour >= 9 || (localIn.Hour == 8 && localIn.Minute > 15);
                    });

                // 4. Calculate WORKING DAYS for the month so far
                int workingDaysSoFar = 0;
                if (effectiveStart <= todayLocal)
                {
                    workingDaysSoFar = Enumerable.Range(0, (todayLocal - effectiveStart).Days + 1)
                        .Select(i => effectiveStart.AddDays(i))
                        .Count(d => d.DayOfWeek != DayOfWeek.Sunday);
                }

                // 5. Fetch approved LEAVES for the month
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employeeId);
                var monthlyLeaves = leaves?.Where(l => l.Status == "Approved" && 
                    ((l.StartDate.Month == now.Month && l.StartDate.Year == now.Year) || 
                     (l.EndDate.Month == now.Month && l.EndDate.Year == now.Year))).ToList() ?? new List<Leave>();

                int leaveDaysCount = 0;
                var uniqueLeaveDates = new HashSet<DateTime>();
                foreach (var leave in monthlyLeaves)
                {
                    var lStart = leave.StartDate.ToLocalTime().Date;
                    var lEnd = leave.EndDate.ToLocalTime().Date;
                    for (var d = lStart; d <= lEnd; d = d.AddDays(1))
                    {
                        if (d.Month == now.Month && d.Year == now.Year && d >= effectiveStart && d <= todayLocal && d.DayOfWeek != DayOfWeek.Sunday)
                        {
                            uniqueLeaveDates.Add(d);
                        }
                    }
                }
                leaveDaysCount = uniqueLeaveDates.Count(ld => !presentDates.Contains(ld));

                // 6. Calculate ABSENT days
                int absentCount = Math.Max(0, workingDaysSoFar - presentCount - leaveDaysCount);

                // 7. Absence Allowance (Yearly pool)
                // We always fetch the yearly allowance remaining, but keep other stats monthly
                var yearlyStats = await GetYearlyAttendanceStatsAsync(employeeId, hiredDate);

                return new AttendanceStats
                {
                    PresentCount = presentCount,
                    AbsentCount = absentCount,
                    LateCount = lateCount,
                    WorkingDaysToDate = workingDaysSoFar, // Now strictly monthly
                    RemainingAbsences = yearlyStats.RemainingAbsences,
                    AttendanceRate = workingDaysSoFar > 0 ? (presentCount * 100.0 / workingDaysSoFar) : 0
                };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating monthly stats: {ex.Message}");
                return new AttendanceStats { RemainingAbsences = TOTAL_ALLOWED_ABSENCES_PER_YEAR };
            }
        }

        public async Task<AttendanceStats> GetYearlyAttendanceStatsAsync(string employeeId, DateTime hiredDate)
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8); // PH Local Time
                var todayLocal = now.Date;
                var currentYear = now.Year;
                var yearStart = new DateTime(currentYear, 1, 1);
                
                // Determine effective start date for stats
                var hiredDateLocal = hiredDate == DateTime.MinValue ? TRACKING_START_DATE : hiredDate.ToLocalTime().Date;
                var effectiveStart = hiredDateLocal > yearStart ? hiredDateLocal : yearStart;
                
                // Ensure we don't go before system tracking start
                if (effectiveStart < TRACKING_START_DATE) effectiveStart = TRACKING_START_DATE;

                // CRITICAL: MongoDB queries should use DateTimeKind.Utc to avoid driver-side conversions
                DateTime queryStart = DateTime.SpecifyKind(effectiveStart, DateTimeKind.Utc);
                DateTime queryEnd = DateTime.SpecifyKind(todayLocal, DateTimeKind.Utc);

                // 1. Fetch ALL yearly records for this employee
                var yearlyRecords = await _attendance
                    .Find(a => a.EmployeeId == employeeId && a.IsActive && a.Date >= queryStart && a.Date <= queryEnd)
                    .ToListAsync();

                // 2. Count PRESENT days (distinct dates where TimeIn exists, including today)
                var presentDates = yearlyRecords
                    .Where(r => r.TimeIn.HasValue)
                    .Select(r => r.Date.Date)
                    .Distinct()
                    .ToList();
                int presentCount = presentDates.Count;

                // 3. Count LATE days (include today if timed in)
                int lateCount = yearlyRecords
                    .Where(r => r.TimeIn.HasValue)
                    .GroupBy(r => r.Date.Date)
                    .Count(g => {
                        var firstIn = g.OrderBy(r => r.TimeIn).First();
                        var localIn = firstIn.TimeIn.Value.ToLocalTime();
                        // PH Standard: 8:00 AM start, 15 min grace period
                        return localIn.Hour >= 9 || (localIn.Hour == 8 && localIn.Minute > 15);
                    });

                // 4. Fetch approved LEAVES
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employeeId);
                var approvedLeaves = leaves?.Where(l => l.Status == "Approved" && l.StartDate.Year == currentYear).ToList() ?? new List<Leave>();

                // 5. Calculate WORKING DAYS passed (Mon-Sat, from effectiveStart to todayLocal)
                int workingDaysPassed = 0;
                if (effectiveStart <= todayLocal)
                {
                    workingDaysPassed = Enumerable.Range(0, (todayLocal - effectiveStart).Days + 1)
                        .Select(i => effectiveStart.AddDays(i))
                        .Count(d => d.DayOfWeek != DayOfWeek.Sunday);
                }

                // 6. Calculate LEAVE days that overlap with working days (up to todayLocal)
                int leaveDaysCount = 0;
                var uniqueLeaveDates = new HashSet<DateTime>();
                foreach (var leave in approvedLeaves)
                {
                    var lStart = leave.StartDate.ToLocalTime().Date;
                    var lEnd = leave.EndDate.ToLocalTime().Date;
                    for (var d = lStart; d <= lEnd; d = d.AddDays(1))
                    {
                        if (d.Year == currentYear && d >= effectiveStart && d <= todayLocal && d.DayOfWeek != DayOfWeek.Sunday)
                        {
                            uniqueLeaveDates.Add(d);
                        }
                    }
                }
                // Only count leaves on days where the employee was NOT present
                leaveDaysCount = uniqueLeaveDates.Count(ld => !presentDates.Contains(ld));

                // 7. Calculate ABSENT days
                // Absent = Total Work Days - Present Days - Leave Days
                int absentCount = Math.Max(0, workingDaysPassed - presentCount - leaveDaysCount);
                int remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - absentCount);

                return new AttendanceStats
                {
                    PresentCount = presentCount,
                    AbsentCount = absentCount,
                    LateCount = lateCount,
                    WorkingDaysToDate = workingDaysPassed,
                    RemainingAbsences = remainingAbsences,
                    AttendanceRate = workingDaysPassed > 0 ? (presentCount * 100.0 / workingDaysPassed) : 0
                };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating yearly stats: {ex.Message}");
                return new AttendanceStats { RemainingAbsences = TOTAL_ALLOWED_ABSENCES_PER_YEAR };
            }
        }

        public async Task<int> GetRemainingAbsencesAsync(string employeeId, DateTime hiredDate)
        {
            var stats = await GetYearlyAttendanceStatsAsync(employeeId, hiredDate);
            return stats.RemainingAbsences;
        }

        /// <summary>
        /// Calculates MONTHLY aggregate attendance for the whole team.
        /// </summary>
        public async Task<TeamAttendanceStats> GetMonthlyTeamStatsAsync()
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8);
                var currentMonthStart = new DateTime(now.Year, now.Month, 1);
                var todayLocal = now.Date;

                DateTime queryStart = DateTime.SpecifyKind(currentMonthStart, DateTimeKind.Utc);
                DateTime queryEnd = DateTime.SpecifyKind(todayLocal, DateTimeKind.Utc);

                // 1. Get all active employees
                var employees = await MongoDBHelper.GetEmployeesCollection()
                    .Find(e => e.IsActive)
                    .ToListAsync();
                int totalEmployees = employees.Count;

                // 2. Get all attendance records for the month
                var monthlyRecords = await _attendance
                    .Find(a => a.IsActive && a.Date >= queryStart && a.Date <= queryEnd)
                    .ToListAsync();

                // 3. Count total presents, lates
                int totalPresents = monthlyRecords.Count(r => r.TimeIn.HasValue);
                int totalLates = monthlyRecords.Count(r => r.TimeIn.HasValue && 
                    (r.TimeIn.Value.ToLocalTime().Hour > 8 || 
                     (r.TimeIn.Value.ToLocalTime().Hour == 8 && r.TimeIn.Value.ToLocalTime().Minute > 15)));

                // 4. Get all approved leaves for the month
                var leaves = await MongoDBHelper.GetLeavesCollection()
                    .Find(l => l.Status == "Approved" && 
                        ((l.StartDate.Month == now.Month && l.StartDate.Year == now.Year) || 
                         (l.EndDate.Month == now.Month && l.EndDate.Year == now.Year)))
                    .ToListAsync();

                int totalLeaveDays = 0;
                var workingDaysInMonth = Enumerable.Range(0, (todayLocal - currentMonthStart).Days + 1)
                    .Select(i => currentMonthStart.AddDays(i))
                    .Where(d => d.DayOfWeek != DayOfWeek.Sunday)
                    .ToList();

                foreach (var leave in leaves)
                {
                    var lStart = leave.StartDate.ToLocalTime().Date;
                    var lEnd = leave.EndDate.ToLocalTime().Date;
                    foreach (var wd in workingDaysInMonth)
                    {
                        if (wd >= lStart && wd <= lEnd)
                        {
                            // Only count if they didn't time in that day
                            if (!monthlyRecords.Any(r => r.EmployeeId == leave.EmployeeId && r.Date.Date == wd.Date && r.TimeIn.HasValue))
                            {
                                totalLeaveDays++;
                            }
                        }
                    }
                }

                // 5. Calculate total expected working days across all employees
                int workingDaysSoFar = workingDaysInMonth.Count;
                int totalPossibleWorkingDays = totalEmployees * workingDaysSoFar;

                // 6. Calculate total absents
                int totalAbsents = Math.Max(0, totalPossibleWorkingDays - totalPresents - totalLeaveDays);

                return new TeamAttendanceStats
                {
                    PresentCount = totalPresents,
                    AbsentCount = totalAbsents,
                    OnLeaveCount = totalLeaveDays,
                    LateCount = totalLates
                };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating team monthly stats: {ex.Message}");
                return new TeamAttendanceStats();
            }
        }
        public async Task<int> DetectConsecutiveUnexcusedAbsencesAsync(string employeeId)
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8).Date;
                int consecutiveAbsences = 0;
                
                // Check back up to 15 days to find a sequence of 5-7 days
                for (int i = 0; i < 15; i++)
                {
                    var checkDate = now.AddDays(-i);
                    
                    // Skip Sundays (not business days in this system)
                    if (checkDate.DayOfWeek == DayOfWeek.Sunday) continue;
                    
                    // 1. Check Attendance
                    var attendance = await _attendance.Find(a => a.EmployeeId == employeeId && a.Date == checkDate && a.IsActive).FirstOrDefaultAsync();
                    if (attendance != null && attendance.TimeIn.HasValue)
                    {
                        // They showed up, sequence broken
                        break;
                    }
                    
                    // 2. Check Approved Leave
                    var leaveService = new LeaveService();
                    var isOnLeave = await leaveService.IsEmployeeOnLeaveOnDateAsync(employeeId, checkDate);
                    if (isOnLeave)
                    {
                        // They have a valid reason, sequence broken
                        break;
                    }
                    
                    // If no attendance and no leave, it's an unexcused absence
                    consecutiveAbsences++;
                    
                    // We only care about 5-7 days for now
                    if (consecutiveAbsences >= 7) break;
                }
                
                return consecutiveAbsences;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error detecting consecutive absences: {ex.Message}");
                return 0;
            }
        }

        public async Task<List<ContractualHiringNeed>> GetContractualHiringNeedsAsync()
        {
            var needs = new List<ContractualHiringNeed>();
            try
            {
                var empService = new EmployeeService();
                var leaveService = new LeaveService();
                
                var employees = await empService.GetAllEmployeesAsync();
                
                foreach (var emp in employees.Where(e => e.IsActive))
                {
                    // Condition 1: 5 to 7 consecutive business days of unexcused absence
                    int unexcusedDays = await DetectConsecutiveUnexcusedAbsencesAsync(emp.EmployeeId);
                    if (unexcusedDays >= 5)
                    {
                        needs.Add(new ContractualHiringNeed
                        {
                            Id = emp.Id,
                            EmployeeId = emp.EmployeeId,
                            EmployeeName = emp.FullName,
                            Position = emp.Position,
                            Department = emp.Department,
                            Reason = $"Unexcused Absence ({unexcusedDays} consecutive days)",
                            Type = "Contractual",
                            Priority = "High"
                        });
                    }
                    
                    // Condition 2: Permanent employee's leave spans at least 30 to 105 days
                    var leaves = await leaveService.GetLeavesByEmployeeIdAsync(emp.EmployeeId);
                    var longTermLeave = leaves?.FirstOrDefault(l => l.Status == "Approved" && 
                        (l.EndDate - l.StartDate).TotalDays >= 30 && 
                        (l.EndDate - l.StartDate).TotalDays <= 105);
                        
                    if (longTermLeave != null)
                    {
                        needs.Add(new ContractualHiringNeed
                        {
                            Id = emp.Id,
                            EmployeeId = emp.EmployeeId,
                            EmployeeName = emp.FullName,
                            Position = emp.Position,
                            Department = emp.Department,
                            Reason = $"Long-term Leave ({(int)(longTermLeave.EndDate - longTermLeave.StartDate).TotalDays} days)",
                            Type = "Fixed-term",
                            Priority = "Medium"
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting contractual hiring needs: {ex.Message}");
            }
            return needs;
        }
    }

    public class TeamAttendanceStats
    {
        public int PresentCount { get; set; }
        public int AbsentCount { get; set; }
        public int OnLeaveCount { get; set; }
        public int LateCount { get; set; }
    }

    public class AttendanceStats
    {
        public int PresentCount { get; set; }
        public int AbsentCount { get; set; }
        public int LateCount { get; set; }
        public int WorkingDaysToDate { get; set; }
        public int RemainingAbsences { get; set; }
        public double AttendanceRate { get; set; }
    }

    public class ContractualHiringNeed
    {
        public string Id { get; set; } // MongoDB ID
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string Position { get; set; }
        public string Department { get; set; }
        public string Reason { get; set; }
        public string Type { get; set; } // Contractual or Fixed-term
        public string Priority { get; set; }
    }
}
