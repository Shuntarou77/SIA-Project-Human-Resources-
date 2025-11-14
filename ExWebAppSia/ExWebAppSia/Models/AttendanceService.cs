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
            _attendance = MongoDBHelper.GetAttendanceCollection();
        }

        // Record time in for an employee
        public async Task<bool> TimeInAsync(string employeeId, string employeeName, string department)
        {
            try
            {
                var today = DateTime.UtcNow.Date;
                var now = DateTime.UtcNow;

                // Check if attendance record already exists for today
                var existingAttendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                if (existingAttendance != null)
                {
                    // Update existing record if time in hasn't been set
                    if (existingAttendance.TimeIn == null)
                    {
                        existingAttendance.TimeIn = now;
                        existingAttendance.EmployeeName = employeeName;
                        existingAttendance.Department = department;
                        await _attendance.ReplaceOneAsync(
                            a => a.Id == existingAttendance.Id,
                            existingAttendance);
                        return true;
                    }
                    else
                    {
                        // Already timed in today
                        return false;
                    }
                }
                else
                {
                    // Create new attendance record
                    var attendance = new Attendance
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

                    await _attendance.InsertOneAsync(attendance);
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error recording time in: {ex.Message}");
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
                var attendanceList = await _attendance
                    .Find(a => a.Date == dateOnly && a.IsActive)
                    .SortByDescending(a => a.TimeIn)
                    .ToListAsync();

                return attendanceList;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting attendance by date: {ex.Message}");
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
                var attendance = await _attendance
                    .Find(a => a.EmployeeId == employeeId && 
                               a.Date == today && 
                               a.IsActive)
                    .FirstOrDefaultAsync();

                return attendance;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting today's attendance: {ex.Message}");
                return null;
            }
        }
    }
}

