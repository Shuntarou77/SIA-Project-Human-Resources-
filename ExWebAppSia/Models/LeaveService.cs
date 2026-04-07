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
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating leave: {ex.Message}");
                return false;
            }
        }

        // Get leave by ID
        public async Task<Leave> GetLeaveByIdAsync(string id)
        {
            try
            {
                return await _leaves.Find(l => l.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
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
                return await _leaves.Find(l => l.IsActive && l.EmployeeId == employeeId)
                    .SortByDescending(l => l.SubmittedDate)
                    .ToListAsync().ConfigureAwait(false);
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
                    .ToListAsync().ConfigureAwait(false);
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
                var startDate = date.Date;
                var endDate = startDate.AddDays(1);

                return await _leaves.Find(l => l.IsActive &&
                       l.StartDate <= date && l.EndDate >= date)
                    .ToListAsync().ConfigureAwait(false);
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
        public async Task<List<Leave>> GetLeavesByEmployeeAndDateRangeAsync(
     string employeeId, DateTime startDate, DateTime endDate)
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

   return await _leaves.Find(filter)
  .SortBy(l => l.StartDate)
    .ToListAsync().ConfigureAwait(false);
         }
     catch (Exception ex)
     {
     System.Diagnostics.Debug.WriteLine($"Error getting leaves by employee and date range: {ex.Message}");
         return new List<Leave>();
            }
        }
    }
}

