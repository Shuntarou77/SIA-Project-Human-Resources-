using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace ExWebAppSia.Models
{
    public class UndertimeService
    {
        private readonly IMongoCollection<UndertimeRecord> _undertime;
        private readonly IMongoCollection<UndertimeRequest> _requests;

        public UndertimeService()
        {
            _undertime = MongoDBHelper.GetUndertimeCollection();
            _requests = MongoDBHelper.GetUndertimeRequestsCollection();
        }

        public async Task<bool> RequestUndertimeAsync(string attendanceId, string employeeId, string employeeName, string department, string reason)
        {
            try
            {
                var request = new UndertimeRequest
                {
                    AttendanceId = attendanceId,
                    EmployeeId = employeeId,
                    EmployeeName = employeeName,
                    Department = department,
                    Reason = reason,
                    Date = DateTime.UtcNow.AddHours(8).Date, // PH Local Date (UTC+8)
                    RequestedAt = DateTime.UtcNow,
                    Status = "Pending",
                    IsActive = true
                };

                await _requests.InsertOneAsync(request);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error requesting undertime: {ex.Message}");
                return false;
            }
        }

        public async Task<UndertimeRequest> GetActiveRequestAsync(string employeeId)
        {
            try
            {
                if (string.IsNullOrEmpty(employeeId)) return null;
                employeeId = employeeId.Trim();

                // FOR DEBUGGING: Look for ANY record/request for this employee without date filters
                // 1. Check formal Records
                var record = await _undertime.Find(u => u.EmployeeId == employeeId && u.IsActive)
                    .SortByDescending(u => u.RecordedAt)
                    .FirstOrDefaultAsync();

                if (record != null)
                {
                    return new UndertimeRequest
                    {
                        EmployeeId = record.EmployeeId,
                        EmployeeName = record.EmployeeName,
                        Status = "Approved",
                        Reason = record.Reason,
                        Date = record.Date,
                        AttendanceId = record.AttendanceId
                    };
                }

                // 2. Check Requests
                return await _requests.Find(r => r.EmployeeId == employeeId && r.IsActive)
                    .SortByDescending(r => r.RequestedAt)
                    .FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting active undertime request: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> RecordUndertimeAsync(UndertimeRecord record)
        {
            try
            {
                var existing = await _undertime.Find(u => u.AttendanceId == record.AttendanceId).FirstOrDefaultAsync();
                if (existing != null)
                {
                    await _undertime.ReplaceOneAsync(u => u.Id == existing.Id, record);
                }
                else
                {
                    await _undertime.InsertOneAsync(record);
                }
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error recording undertime: {ex.Message}");
                return false;
            }
        }

        public async Task<List<UndertimeRecord>> GetUndertimeRecordsByDateAsync(DateTime date)
        {
            try
            {
                var targetDate = date.Date;
                var nextDate = targetDate.AddDays(1);
                return await _undertime.Find(u => u.Date >= targetDate && u.Date < nextDate && u.IsActive).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting undertime records: {ex.Message}");
                return new List<UndertimeRecord>();
            }
        }

        public async Task<List<UndertimeRecord>> GetUndertimeRecordsByEmployeeAsync(string employeeId)
        {
            try
            {
                return await _undertime.Find(u => u.EmployeeId == employeeId && u.IsActive).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee undertime records: {ex.Message}");
                return new List<UndertimeRecord>();
            }
        }

        public async Task<List<UndertimeRequest>> GetAllPendingRequestsAsync()
        {
            try
            {
                return await _requests.Find(r => r.Status == "Pending" && r.IsActive).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all pending undertime requests: {ex.Message}");
                return new List<UndertimeRequest>();
            }
        }

        public async Task<bool> ApproveRequestAsync(string requestId)
        {
            try
            {
                var request = await _requests.Find(r => r.Id == requestId).FirstOrDefaultAsync();
                if (request == null) return false;

                var update = Builders<UndertimeRequest>.Update.Set(r => r.Status, "Approved");
                await _requests.UpdateOneAsync(r => r.Id == requestId, update);

                string cleanEmployeeId = request.EmployeeId?.Trim() ?? "";

                var now = DateTime.UtcNow.AddHours(8);
                var shiftEnd = new DateTime(now.Year, now.Month, now.Day, 17, 0, 0);
                double hours = (shiftEnd - now).TotalHours;
                if (hours < 0) hours = 0;

                var employeeCollection = MongoDBHelper.GetEmployeesCollection();
                var employee = await employeeCollection.Find(e => e.EmployeeId == cleanEmployeeId).FirstOrDefaultAsync();
                decimal hourlyRate = 0;
                if (employee != null && employee.BaseSalary > 0)
                {
                    hourlyRate = (employee.BaseSalary * 12) / 313m / 8m;
                }

                var record = new UndertimeRecord
                {
                    AttendanceId = request.AttendanceId,
                    EmployeeId = cleanEmployeeId,
                    EmployeeName = request.EmployeeName,
                    Date = request.Date,
                    HoursUndertime = Math.Round(hours, 2),
                    HourlyRate = Math.Round(hourlyRate, 2),
                    DeductionAmount = Math.Round((decimal)hours * hourlyRate, 2),
                    Reason = request.Reason,
                    RecordedAt = DateTime.UtcNow,
                    IsActive = true
                };

                await RecordUndertimeAsync(record);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error approving undertime request: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> RejectRequestAsync(string requestId)
        {
            try
            {
                var update = Builders<UndertimeRequest>.Update.Set(r => r.Status, "Rejected");
                var result = await _requests.UpdateOneAsync(r => r.Id == requestId, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error rejecting undertime request: {ex.Message}");
                return false;
            }
        }
    }
}
