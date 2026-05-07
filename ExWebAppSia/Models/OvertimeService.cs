using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class OvertimeService
    {
        private readonly IMongoCollection<OvertimeRequest> _overtime;

        public OvertimeService()
        {
            _overtime = MongoDBHelper.GetOvertimeRequestsCollection();
        }

        // Employee submits an overtime request
        public async Task<bool> RequestOvertimeAsync(string attendanceId, string employeeId, string employeeName, string department, string reason, DateTime otDate, string startTime, string endTime, decimal requestedHours)
        {
            try
            {
                // Prevent duplicate pending requests for the same attendance record
                var existing = await _overtime
                    .Find(o => o.AttendanceId == attendanceId && o.Status == "Pending" && o.IsActive)
                    .FirstOrDefaultAsync();

                if (existing != null)
                    return false; // Already has a pending request for this shift

                var request = new OvertimeRequest
                {
                    AttendanceId = attendanceId,
                    EmployeeId = employeeId,
                    EmployeeName = employeeName,
                    Department = department,
                    Date = otDate.Date,
                    Reason = reason,
                    StartTime = startTime,
                    EndTime = endTime,
                    RequestedHours = requestedHours,
                    Status = "Pending",
                    RequestedAt = DateTime.UtcNow,
                    IsActive = true
                };

                await _overtime.InsertOneAsync(request);

                // Notification for Admin/HR
                try
                {
                    var notifService = new NotificationService();
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = "ADMIN",
                        Title = "New Overtime Request",
                        Message = $"{employeeName} has submitted an overtime request.",
                        Type = "NewRequest",
                        Link = "~/webpage/Approvals.aspx",
                        RelatedId = request.Id
                    });
                }
                catch { }

                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating overtime request: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SubmitRequestAsync(OvertimeRequest request)
        {
            try
            {
                await _overtime.InsertOneAsync(request);
                return true;
            }
            catch
            {
                return false;
            }
        }

        // Admin approves an overtime request and sets the day type/rate
        public async Task<bool> ApproveAsync(string overtimeRequestId, string overtimeType = "Regular", decimal? customHourlyRate = null)
        {
            try
            {
                var request = await _overtime.Find(o => o.Id == overtimeRequestId).FirstOrDefaultAsync();
                if (request == null) return false;

                decimal otHourlyRate = 0;
                
                if (customHourlyRate.HasValue)
                {
                    otHourlyRate = customHourlyRate.Value;
                }
                else
                {
                    // Calculate based on DOLE guidelines
                    var employeeService = new EmployeeService();
                    var employee = await employeeService.GetByEmployeeIdAsync(request.EmployeeId);
                    if (employee != null && employee.BaseSalary > 0)
                    {
                        decimal dailyRate = (employee.BaseSalary * 12) / 313m;
                        otHourlyRate = CalculateOvertimeHourlyRate(dailyRate, overtimeType, IsNightShiftTime(DateTime.UtcNow.AddHours(8)));
                    }
                }

                var updateBuilder = Builders<OvertimeRequest>.Update
                    .Set(o => o.Status, "Approved")
                    .Set(o => o.ApprovedAt, DateTime.UtcNow)
                    .Set(o => o.OvertimeType, overtimeType)
                    .Set(o => o.OvertimeHourlyRate, otHourlyRate);

                var result = await _overtime.UpdateOneAsync(o => o.Id == overtimeRequestId, updateBuilder);
                
                if (result.ModifiedCount > 0)
                {
                    // Notification for Employee
                    try
                    {
                        var updatedRequest = await GetByIdAsync(overtimeRequestId);
                        if (updatedRequest != null)
                        {
                            var notifService = new NotificationService();
                            await notifService.CreateNotificationAsync(new Notification
                            {
                                RecipientId = updatedRequest.EmployeeId,
                                Title = "Overtime Request Approved",
                                Message = "Your overtime request has been approved.",
                                Type = "RequestUpdate",
                                Link = "~/webpage(EmployeeViewpoint)/Dashboard.aspx",
                                RelatedId = overtimeRequestId
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
                System.Diagnostics.Debug.WriteLine($"Error approving overtime request: {ex.Message}");
                return false;
            }
        }

        // Admin rejects an overtime request
        public async Task<bool> RejectAsync(string overtimeRequestId)
        {
            try
            {
                var update = Builders<OvertimeRequest>.Update
                    .Set(o => o.Status, "Rejected");

                var result = await _overtime.UpdateOneAsync(o => o.Id == overtimeRequestId, update);
                
                if (result.ModifiedCount > 0)
                {
                    // Notification for Employee
                    try
                    {
                        var updatedRequest = await GetByIdAsync(overtimeRequestId);
                        if (updatedRequest != null)
                        {
                            var notifService = new NotificationService();
                            await notifService.CreateNotificationAsync(new Notification
                            {
                                RecipientId = updatedRequest.EmployeeId,
                                Title = "Overtime Request Rejected",
                                Message = "Your overtime request has been rejected.",
                                Type = "RequestUpdate",
                                Link = "~/webpage(EmployeeViewpoint)/Dashboard.aspx",
                                RelatedId = overtimeRequestId
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
                System.Diagnostics.Debug.WriteLine($"Error rejecting overtime request: {ex.Message}");
                return false;
            }
        }

        // Get all pending overtime requests
        public async Task<List<OvertimeRequest>> GetPendingRequestsAsync()
        {
            try
            {
                return await _overtime
                    .Find(o => o.Status == "Pending" && o.IsActive)
                    .SortByDescending(o => o.RequestedAt)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting pending overtime requests: {ex.Message}");
                return new List<OvertimeRequest>();
            }
        }

        public async Task<List<OvertimeRequest>> GetRequestsByEmployeeIdAsync(string employeeId, bool onlyActive = true)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return new List<OvertimeRequest>();
                employeeId = employeeId.Trim();

                var filter = onlyActive
                    ? Builders<OvertimeRequest>.Filter.Where(o => o.EmployeeId == employeeId && o.IsActive)
                    : Builders<OvertimeRequest>.Filter.Where(o => o.EmployeeId == employeeId);

                return await _overtime
                    .Find(filter)
                    .SortByDescending(o => o.RequestedAt)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting overtime requests by employee ID: {ex.Message}");
                return new List<OvertimeRequest>();
            }
        }

        public async Task<List<OvertimeRequest>> GetRecentRequestsByEmployeeIdAsync(string employeeId, int limit = 100, bool onlyActive = true)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return new List<OvertimeRequest>();
                employeeId = employeeId.Trim();
                if (limit <= 0) limit = 100;

                var filter = onlyActive
                    ? Builders<OvertimeRequest>.Filter.Where(o => o.EmployeeId == employeeId && o.IsActive)
                    : Builders<OvertimeRequest>.Filter.Where(o => o.EmployeeId == employeeId);

                // Avoid DB-side sort (can be slow without indexes).
                return await _overtime
                    .Find(filter)
                    .Limit(limit)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting recent overtime requests by employee ID: {ex.Message}");
                return new List<OvertimeRequest>();
            }
        }

        // Get the OT request for a specific attendance record (for employee dashboard)
        public async Task<OvertimeRequest> GetByAttendanceIdAsync(string attendanceId)
        {
            try
            {
                return await _overtime
                    .Find(o => o.AttendanceId == attendanceId && o.IsActive)
                    .SortByDescending(o => o.RequestedAt)
                    .FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting overtime request by attendance ID: {ex.Message}");
                return null;
            }
        }

        // Get a single overtime request by its ID (used for self-approval checks)
        public async Task<OvertimeRequest> GetByIdAsync(string requestId)
        {
            try
            {
                return await _overtime
                    .Find(o => o.Id == requestId)
                    .FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting overtime request by ID: {ex.Message}");
                return null;
            }
        }

        // Record actual overtime worked after employee times out and calculate pay
        public async Task<bool> SetOvertimeWorkedAsync(string attendanceId, string overtimeWorked, decimal dailyRate, string overtimeType = "Regular")
        {
            try
            {
                // Parse overtime hours from string "HH:mm:ss"
                double hours = 0;
                if (TimeSpan.TryParse(overtimeWorked, out TimeSpan ts))
                {
                    hours = ts.TotalHours;
                }

                // Check if it's night shift (10 PM - 6 AM)
                // In a real scenario, we'd check the actual time intervals, 
                // but for now we follow the logic if the OT period overlaps with night hours.
                // For simplicity, we can add a boolean or check current time if called at timeout.
                bool isNightShift = IsNightShiftTime(DateTime.UtcNow.AddHours(8)); // Check local PHIL time

                decimal hourlyRate = dailyRate / 8;
                decimal otHourlyRate = CalculateOvertimeHourlyRate(dailyRate, overtimeType, isNightShift);
                decimal calculatedPay = (decimal)hours * otHourlyRate;

                var update = Builders<OvertimeRequest>.Update
                    .Set(o => o.OvertimeWorked, overtimeWorked)
                    .Set(o => o.HourlyRate, hourlyRate)
                    .Set(o => o.OvertimeHourlyRate, otHourlyRate)
                    .Set(o => o.OvertimeType, overtimeType)
                    .Set(o => o.IsNightShift, isNightShift)
                    .Set(o => o.CalculatedOvertimePay, calculatedPay);

                var result = await _overtime.UpdateOneAsync(
                    o => o.AttendanceId == attendanceId && o.Status == "Approved",
                    update);

                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error setting overtime worked and calculating pay: {ex.Message}");
                return false;
            }
        }

        public decimal CalculateOvertimePay(decimal dailyRate, double hoursWorked, string type, bool isNightShift)
        {
            decimal otHourlyRate = CalculateOvertimeHourlyRate(dailyRate, type, isNightShift);
            return (decimal)hoursWorked * otHourlyRate;
        }

        public decimal CalculateOvertimeHourlyRate(decimal dailyRate, string type, bool isNightShift)
        {
            decimal hourlyRate = dailyRate / 8m;
            decimal multiplier = GetMultiplier(type);
            decimal otHourlyRate = hourlyRate * multiplier;

            if (isNightShift)
            {
                otHourlyRate *= 1.10m;
            }

            return Math.Round(otHourlyRate, 2);
        }

        public decimal GetMultiplier(string type)
        {
            switch (type?.ToLower())
            {
                case "regular":
                    return 1.25m;
                case "restday":
                case "specialholiday":
                    return 1.69m;
                case "regularholiday":
                    return 2.60m;
                default:
                    return 1.25m;
            }
        }

        public async Task<List<OvertimeRequest>> GetAllAsync()
        {
            try
            {
                return await _overtime.Find(o => o.IsActive).ToListAsync();
            }
            catch { return new List<OvertimeRequest>(); }
        }

        public async Task<List<OvertimeRequest>> GetByDateAsync(DateTime date)
        {
            try
            {
                var target = date.Date;
                return await _overtime.Find(o => o.Date == target && o.IsActive).ToListAsync();
            }
            catch { return new List<OvertimeRequest>(); }
        }

        private bool IsNightShiftTime(DateTime time)
        {
            // Night shift is 10 PM to 6 AM
            int hour = time.Hour;
            return (hour >= 22 || hour < 6);
        }
    }
}
