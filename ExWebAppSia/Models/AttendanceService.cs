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
                var today = DateTime.UtcNow.Date;
                var now = DateTime.UtcNow;

                System.Diagnostics.Debug.WriteLine($"TimeInAsync called - EmployeeId: {employeeId}, EmployeeName: {employeeName}, Department: {department}");
                System.Diagnostics.Debug.WriteLine($"UTC Date: {today:yyyy-MM-dd}, UTC Now: {now:yyyy-MM-dd HH:mm:ss}");

                // Check if attendance record already exists for today
                var existingAttendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                if (existingAttendance != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Existing record found - ID: {existingAttendance.Id}, TimeIn: {existingAttendance.TimeIn}, TimeOut: {existingAttendance.TimeOut}");
                    if (!existingAttendance.TimeIn.HasValue)
                    {
                        // Calculate Late Time
                        var localTime = now.AddHours(8);
                        var shiftStart = new DateTime(localTime.Year, localTime.Month, localTime.Day, 8, 0, 0);
                        if (localTime > shiftStart)
                        {
                            var diff = localTime - shiftStart;
                            existingAttendance.LateTime = $"{(int)diff.TotalHours:D2}:{(int)diff.Minutes:D2}";
                        }

                        existingAttendance.TimeIn = now;
                        existingAttendance.EmployeeName = employeeName;
                        existingAttendance.Department = department;
                        var updateResult = await _attendance.ReplaceOneAsync(
                            a => a.Id == existingAttendance.Id,
                            existingAttendance);
                        System.Diagnostics.Debug.WriteLine($"Updated existing record - Matched: {updateResult.MatchedCount}, Modified: {updateResult.ModifiedCount}");
                        return true;
                    }
                    else if (existingAttendance.TimeOut.HasValue)
                    {
                        // Employee has already timed out, create a new record for a new shift
                        System.Diagnostics.Debug.WriteLine("Employee has timed out, creating new record for new shift");
                        var newAttendance = new Attendance
                        {
                            EmployeeId = employeeId,
                            EmployeeName = employeeName,
                            Department = department,
                            Date = today,
                            TimeIn = now,
                            TimeOut = null,
                            CreatedAt = now,
                            IsActive = true
                        };
                        await _attendance.InsertOneAsync(newAttendance);
                        System.Diagnostics.Debug.WriteLine($"New shift record created - ID: {newAttendance.Id}");
                        return true;
                    }
                    else
                    {
                        // Already timed in today but not timed out yet
                        System.Diagnostics.Debug.WriteLine("Already timed in today (not timed out yet)");
                        return false;
                    }
                }
                else
                {
                    // Calculate Late Time (Standard shift starts at 8:00 AM Local/UTC+8)
                    string lateTimeStr = null;
                    var localTime = now.AddHours(8); // Convert UTC to PH Time (UTC+8)
                    var shiftStart = new DateTime(localTime.Year, localTime.Month, localTime.Day, 8, 0, 0);
                    
                    if (localTime > shiftStart)
                    {
                        var diff = localTime - shiftStart;
                        lateTimeStr = $"{(int)diff.TotalHours:D2}:{(int)diff.Minutes:D2}";
                    }

                    // Create new attendance record
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

                    System.Diagnostics.Debug.WriteLine($"Attempting to insert attendance record...");
                    await _attendance.InsertOneAsync(attendance);
                    System.Diagnostics.Debug.WriteLine($"InsertOneAsync completed - ID: {attendance.Id}");
                    
                    if (string.IsNullOrEmpty(attendance.Id))
                    {
                        System.Diagnostics.Debug.WriteLine($"ERROR - Insert completed but ID is null or empty!");
                        return false;
                    }
                                        return true;
                }
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
                var today = DateTime.UtcNow.Date;
                var now = DateTime.UtcNow;

                // Find today's attendance record
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                if (attendance != null && attendance.TimeIn != null && attendance.TimeOut == null)
                {
                    attendance.TimeOut = now;
                    await _attendance.ReplaceOneAsync(
                        a => a.Id == attendance.Id,
                        attendance);
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
                var today = DateTime.UtcNow.Date;
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
                var today = DateTime.UtcNow.Date;
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
                var today = DateTime.UtcNow.Date;
                // Get the most recent attendance record for today (in case of multiple shifts)
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .FirstOrDefaultAsync();

                return attendance;
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
                    attendance.Date = DateTime.UtcNow.Date;
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
    }
}

