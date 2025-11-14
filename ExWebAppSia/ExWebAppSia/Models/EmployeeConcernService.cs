using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class EmployeeConcernService
    {
        private readonly IMongoCollection<EmployeeConcern> _concerns;

        public EmployeeConcernService()
        {
            _concerns = MongoDBHelper.GetEmployeeConcernsCollection();
        }

        // Create a new employee concern
        public async Task<bool> CreateConcernAsync(EmployeeConcern concern)
        {
            try
            {
                concern.SubmittedDate = DateTime.UtcNow;
                concern.Status = "Pending";
                concern.IsActive = true;

                await _concerns.InsertOneAsync(concern);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating concern: {ex.Message}");
                return false;
            }
        }

        // Get concerns by employee ID
        public async Task<List<EmployeeConcern>> GetConcernsByEmployeeIdAsync(string employeeId)
        {
            try
            {
                return await _concerns.Find(c => c.IsActive && c.EmployeeId == employeeId)
                    .SortByDescending(c => c.SubmittedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting concerns by employee ID: {ex.Message}");
                return new List<EmployeeConcern>();
            }
        }

        // Get all concerns
        public async Task<List<EmployeeConcern>> GetAllConcernsAsync()
        {
            try
            {
                return await _concerns.Find(c => c.IsActive)
                    .SortByDescending(c => c.SubmittedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all concerns: {ex.Message}");
                return new List<EmployeeConcern>();
            }
        }

        // Update concern status
        public async Task<bool> UpdateConcernStatusAsync(string concernId, string status)
        {
            try
            {
                var filter = Builders<EmployeeConcern>.Filter.Eq(c => c.Id, concernId);
                var update = Builders<EmployeeConcern>.Update.Set(c => c.Status, status);
                var result = await _concerns.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating concern status: {ex.Message}");
                return false;
            }
        }

        // Delete (deactivate) concern
        public async Task<bool> DeleteConcernAsync(string concernId)
        {
            try
            {
                var filter = Builders<EmployeeConcern>.Filter.Eq(c => c.Id, concernId);
                var update = Builders<EmployeeConcern>.Update.Set(c => c.IsActive, false);
                var result = await _concerns.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting concern: {ex.Message}");
                return false;
            }
        }
    }
}

