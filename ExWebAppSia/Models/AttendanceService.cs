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
        /// Calculates the remaining absence allowance for an employee for the current year.
        /// Only counts FINALIZED past days (up to yesterday) to avoid penalizing employees for
        /// the current unfinished day. Present days for today are included if timed in.
        /// </summary>
        public async Task<int> GetRemainingAbsencesAsync(string employeeId, DateTime hiredDate)
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8); // PH Time
                var today = now.Date;
                var yesterday = today.AddDays(-1);
                var currentYear = now.Year;
                var hiredDateLocal = hiredDate.ToLocalTime().Date;
                var yearStart = new DateTime(currentYear, 1, 1);
                var statsStart = hiredDateLocal > yearStart ? hiredDateLocal : yearStart;
                
                // Don't count absences before the system tracking started (March 19, 2026)
                if (statsStart < TRACKING_START_DATE) statsStart = TRACKING_START_DATE;

                // 1. Get yearly attendance (FINALIZED present days — up to yesterday only)
                //    We exclude today because it's incomplete. If they timed in today but haven't
                //    timed out, counting today as both present AND as a working day would be
                //    inconsistent — so we only finalize yesterday and before.
                var yearlyRecords = await _attendance
                    .Find(a => a.EmployeeId == employeeId && a.IsActive && a.TimeIn != null && a.Date.Year == currentYear)
                    .ToListAsync();

                // Only count distinct present days that are BEFORE today (finalized)
                var yearlyPresent = yearlyRecords
                    .Select(r => r.Date.Date)
                    .Distinct()
                    .Count(d => d < today);

                // 2. Get approved leaves
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employeeId);
                var approvedLeaves = leaves.Where(l => l.Status == "Approved" && l.StartDate.Year == currentYear).ToList();

                // 3. Calculate FINALIZED past working days (Mon–Sat), up to YESTERDAY only
                //    We never include today to avoid treating the current day as missed before it ends.
                int pastYearWeekdays = 0;
                if (statsStart <= yesterday)
                {
                    pastYearWeekdays = Enumerable.Range(0, (yesterday - statsStart).Days + 1)
                        .Select(i => statsStart.AddDays(i))
                        .Count(d => d.DayOfWeek != DayOfWeek.Sunday); // Include Saturdays as working days
                }

                // 4. Calculate leave days (finalized — before today)
                int yearlyLeaveDays = 0;
                foreach (var leave in approvedLeaves)
                {
                    var lStart = leave.StartDate.ToLocalTime().Date;
                    var lEnd = leave.EndDate.ToLocalTime().Date;

                    for (var d = lStart; d <= lEnd; d = d.AddDays(1))
                    {
                        if (d.Year == currentYear && d >= statsStart && d < today && d.DayOfWeek != DayOfWeek.Sunday)
                        {
                            yearlyLeaveDays++;
                        }
                    }
                }

                var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent - yearlyLeaveDays);
                return Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating remaining absences: {ex.Message}");
                return TOTAL_ALLOWED_ABSENCES_PER_YEAR;
            }
        }
    }
}
