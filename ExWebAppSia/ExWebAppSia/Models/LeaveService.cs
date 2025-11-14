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

                await _leaves.InsertOneAsync(leave);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating leave: {ex.Message}");
                return false;
            }
        }

        // Get leaves by employee ID
        public async Task<List<Leave>> GetLeavesByEmployeeIdAsync(string employeeId)
        {
            try
            {
                return await _leaves.Find(l => l.IsActive && l.EmployeeId == employeeId)
                    .SortByDescending(l => l.SubmittedDate)
                    .ToListAsync();
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
                return await _leaves.Find(l => l.IsActive)
                    .SortByDescending(l => l.SubmittedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all leaves: {ex.Message}");
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
                var result = await _leaves.UpdateOneAsync(filter, update);
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
                var result = await _leaves.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting leave: {ex.Message}");
                return false;
            }
        }
    }
}

