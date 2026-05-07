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

        public async Task<bool> RequestUndertimeAsync(string attendanceId, string employeeId, string employeeName, string department, string reason, string utType = "Regular", string departureTime = null)
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
                    IsActive = true,
                    UTType = utType,
                    RequestedDepartureTime = departureTime
                };

                await _requests.InsertOneAsync(request);

                // Notification for Admin/HR
                try
                {
                    var notifService = new NotificationService();
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = "ADMIN",
                        Title = (utType == "Emergency" ? "🚨 EMERGENCY " : "New ") + "Undertime Request",
                        Message = $"{employeeName} has submitted a {(utType == "Emergency" ? "HIGH PRIORITY emergency " : "")}undertime request.",
                        Type = utType == "Emergency" ? "EmergencyAlert" : "NewRequest",
                        Link = "~/webpage/Approvals.aspx",
                        RelatedId = request.Id,
                        Priority = utType == "Emergency" ? "High" : "Normal"
                    });
                }
                catch { }

                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error requesting undertime: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> RecordEmergencyUndertimeAsync(string attendanceId, string employeeId, string employeeName, string department)
        {
            try
            {
                var now = DateTime.UtcNow.AddHours(8);
                var shiftEnd = new DateTime(now.Year, now.Month, now.Day, 17, 0, 0);
                double hours = (shiftEnd - now).TotalHours;
                if (hours < 0) hours = 0;

                string cleanEmployeeId = employeeId?.Trim() ?? "";
                var employeeCollection = MongoDBHelper.GetEmployeesCollection();
                var employee = await employeeCollection.Find(e => e.EmployeeId == cleanEmployeeId).FirstOrDefaultAsync();
                
                decimal hourlyRate = 0;
                if (employee != null && employee.BaseSalary > 0)
                {
                    hourlyRate = (employee.BaseSalary * 12) / 313m / 8m;
                }

                var record = new UndertimeRecord
                {
                    AttendanceId = attendanceId,
                    EmployeeId = cleanEmployeeId,
                    EmployeeName = employeeName,
                    Date = now.Date,
                    HoursUndertime = Math.Round(hours, 2),
                    HourlyRate = Math.Round(hourlyRate, 2),
                    DeductionAmount = Math.Round((decimal)hours * hourlyRate, 2),
                    Reason = "EMERGENCY UNDERTIME",
                    RecordedAt = DateTime.UtcNow,
                    IsActive = true,
                    UTType = "Emergency"
                };

                await RecordUndertimeAsync(record);

                // High Priority Alert to HR Staff (ADMIN)
                try
                {
                    var notifService = new NotificationService();
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = "ADMIN",
                        Title = "🚨 EMERGENCY UNDERTIME ALERT",
                        Message = $"URGENT: {employeeName} has triggered an Emergency Undertime and timed out. This has been recorded automatically.",
                        Type = "EmergencyAlert",
                        Link = "~/webpage(SuperAdminViewpoint)/Attendance.aspx",
                        RelatedId = record.Id,
                        Priority = "High"
                    });
                }
                catch { }

                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error recording emergency undertime: {ex.Message}");
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

        // Get a single undertime request by its ID (used for self-approval checks)
        public async Task<UndertimeRequest> GetRequestByIdAsync(string requestId)
        {
            try
            {
                return await _requests
                    .Find(r => r.Id == requestId)
                    .FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting undertime request by ID: {ex.Message}");
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

                // Notification for Employee
                try
                {
                    var notifService = new NotificationService();
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = request.EmployeeId,
                        Title = "Undertime Request Approved",
                        Message = "Your undertime request has been approved.",
                        Type = "RequestUpdate",
                        Link = "~/webpage(EmployeeViewpoint)/Dashboard.aspx",
                        RelatedId = requestId
                    });
                }
                catch { }

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
                
                if (result.ModifiedCount > 0)
                {
                    // Notification for Employee
                    try
                    {
                        var request = await GetRequestByIdAsync(requestId);
                        if (request != null)
                        {
                            var notifService = new NotificationService();
                            await notifService.CreateNotificationAsync(new Notification
                            {
                                RecipientId = request.EmployeeId,
                                Title = "Undertime Request Rejected",
                                Message = "Your undertime request has been rejected.",
                                Type = "RequestUpdate",
                                Link = "~/webpage(EmployeeViewpoint)/Dashboard.aspx",
                                RelatedId = requestId
                            });
                        }
                    }
                    catch { }
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error rejecting undertime request: {ex.Message}");
                return false;
            }
        }
        public async Task<List<UndertimeRequest>> GetAllRequestsAsync()
        {
            try
            {
                return await _requests.Find(r => r.IsActive).ToListAsync();
            }
            catch { return new List<UndertimeRequest>(); }
        }

        public async Task<List<UndertimeRequest>> GetRequestsByEmployeeIdAsync(string employeeId, bool onlyActive = true)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return new List<UndertimeRequest>();
                employeeId = employeeId.Trim();
                return await _requests
                    .Find(r => r.EmployeeId == employeeId && (!onlyActive || r.IsActive))
                    .SortByDescending(r => r.RequestedAt)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting undertime requests by employee ID: {ex.Message}");
                return new List<UndertimeRequest>();
            }
        }

        public async Task<List<UndertimeRequest>> GetRecentRequestsByEmployeeIdAsync(string employeeId, int limit = 100, bool onlyActive = true)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return new List<UndertimeRequest>();
                employeeId = employeeId.Trim();
                if (limit <= 0) limit = 100;

                // Avoid DB-side sort (can be slow without indexes).
                return await _requests
                    .Find(r => r.EmployeeId == employeeId && (!onlyActive || r.IsActive))
                    .Limit(limit)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting recent undertime requests by employee ID: {ex.Message}");
                return new List<UndertimeRequest>();
            }
        }

        public async Task<List<UndertimeRequest>> GetRequestsByDateAsync(DateTime date)
        {
            try
            {
                var target = date.Date;
                return await _requests.Find(r => r.Date == target && r.IsActive).ToListAsync();
            }
            catch { return new List<UndertimeRequest>(); }
        }
    }
}
