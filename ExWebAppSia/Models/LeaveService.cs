using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class LeaveService
    {
        private readonly IMongoCollection<Leave> _leaves;

        public LeaveService()
        {
            _leaves = MongoDBHelper.GetLeavesCollection();
        }

        // Create a new leave request
        public async Task<bool> CreateLeaveAsync(Leave leave)
        {
            try
            {
                leave.SubmittedDate = DateTime.UtcNow;
                leave.Status = "Pending";
                leave.IsActive = true;

                await _leaves.InsertOneAsync(leave).ConfigureAwait(false);

                // Notification for Admin/HR
                try
                {
                    var notifService = new NotificationService();
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = "ADMIN",
                        Title = "New Leave Request",
                        Message = $"{leave.EmployeeName} has submitted a {leave.LeaveType} leave request.",
                        Type = "NewRequest",
                        Link = "~/webpage(SuperAdminViewpoint)/Approvals.aspx",
                        RelatedId = leave.Id
                    });
                }
                catch { }

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public async Task<bool> SubmitLeaveRequestAsync(Leave leave)
        {
            return await CreateLeaveAsync(leave);
        }

        // Get leave by ID
        public async Task<Leave> GetLeaveByIdAsync(string id)
        {
            try
            {
                var filter = Builders<Leave>.Filter.Eq(l => l.Id, id);
                var cursor = await _leaves.FindAsync(filter).ConfigureAwait(false);
                return await cursor.FirstOrDefaultAsync().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting leave by ID: {ex.Message}");
                return null;
            }
        }

        // Get leaves by employee ID
        public async Task<List<Leave>> GetLeavesByEmployeeIdAsync(string employeeId)
        {
            try
            {
                var filter = Builders<Leave>.Filter.And(
                    Builders<Leave>.Filter.Eq(l => l.IsActive, true),
                    Builders<Leave>.Filter.Eq(l => l.EmployeeId, employeeId)
                );
                
                var options = new FindOptions<Leave>
                {
                    Sort = Builders<Leave>.Sort.Descending(l => l.SubmittedDate)
                };

                var cursor = await _leaves.FindAsync(filter, options).ConfigureAwait(false);
                return await cursor.ToListAsync().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting leaves by employee ID: {ex.Message}");
                return new List<Leave>();
            }
        }

        // Get all leaves
        public async Task<List<Leave>> GetAllLeavesAsync()
        {
            try
            {
                var filter = Builders<Leave>.Filter.Eq(l => l.IsActive, true);
                var options = new FindOptions<Leave>
                {
                    Sort = Builders<Leave>.Sort.Descending(l => l.SubmittedDate)
                };

                var cursor = await _leaves.FindAsync(filter, options).ConfigureAwait(false);
                return await cursor.ToListAsync().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all leaves: {ex.Message}");
                return new List<Leave>();
            }
        }

        // Get leaves by date
        public async Task<List<Leave>> GetLeavesByDateAsync(DateTime date)
        {
            try
            {
                var filter = Builders<Leave>.Filter.And(
                    Builders<Leave>.Filter.Eq(l => l.IsActive, true),
                    Builders<Leave>.Filter.Lte(l => l.StartDate, date),
                    Builders<Leave>.Filter.Gte(l => l.EndDate, date)
                );

                var cursor = await _leaves.FindAsync(filter).ConfigureAwait(false);
                return await cursor.ToListAsync().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting leaves by date: {ex.Message}");
                return new List<Leave>();
            }
        }

        // Update leave status
        public async Task<bool> UpdateLeaveStatusAsync(string leaveId, string status)
        {
            try
            {
                var filter = Builders<Leave>.Filter.Eq(l => l.Id, leaveId);
                var update = Builders<Leave>.Update.Set(l => l.Status, status);
                var result = await _leaves.UpdateOneAsync(filter, update).ConfigureAwait(false);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating leave status: {ex.Message}");
                return false;
            }
        }

        // Delete (deactivate) leave
        public async Task<bool> DeleteLeaveAsync(string leaveId)
        {
            try
            {
                var filter = Builders<Leave>.Filter.Eq(l => l.Id, leaveId);
                var update = Builders<Leave>.Update.Set(l => l.IsActive, false);
                var result = await _leaves.UpdateOneAsync(filter, update).ConfigureAwait(false);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting leave: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Get leaves by employee and date range (for payroll processing)
        /// </summary>
        public async Task<List<Leave>> GetLeavesByEmployeeAndDateRangeAsync(string employeeId, DateTime startDate, DateTime endDate)
        {
            try
            {
                var filterBuilder = Builders<Leave>.Filter;

                // Find leaves that overlap with the date range
                var filter = filterBuilder.And(
                    filterBuilder.Eq(l => l.EmployeeId, employeeId),
                    filterBuilder.Eq(l => l.IsActive, true),
                    filterBuilder.Or(
                        // Leave starts within the range
                        filterBuilder.And(
                            filterBuilder.Gte(l => l.StartDate, startDate),
                            filterBuilder.Lte(l => l.StartDate, endDate)
                        ),
                        // Leave ends within the range
                        filterBuilder.And(
                            filterBuilder.Gte(l => l.EndDate, startDate),
                            filterBuilder.Lte(l => l.EndDate, endDate)
                        ),
                        // Leave spans the entire range
                        filterBuilder.And(
                            filterBuilder.Lte(l => l.StartDate, startDate),
                            filterBuilder.Gte(l => l.EndDate, endDate)
                        )
                    )
                );

                var options = new FindOptions<Leave>
                {
                    Sort = Builders<Leave>.Sort.Ascending(l => l.StartDate)
                };

                var cursor = await _leaves.FindAsync(filter, options).ConfigureAwait(false);
                return await cursor.ToListAsync().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting leaves by employee and date range: {ex.Message}");
                return new List<Leave>();
            }
        }
    }
}
