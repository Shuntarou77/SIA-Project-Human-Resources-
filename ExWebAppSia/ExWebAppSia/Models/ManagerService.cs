using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class ManagerService
    {
        private readonly IMongoCollection<Manager> _managers;

        public ManagerService()
        {
            _managers = MongoDBHelper.GetManagersCollection();
        }

        // Create a new manager
        public async Task<bool> CreateManagerAsync(Manager manager)
        {
            try
            {
                // Generate manager ID if not provided
                if (string.IsNullOrEmpty(manager.ManagerId))
                {
                    manager.ManagerId = await GenerateManagerIdAsync();
                }

                manager.HiredDate = DateTime.UtcNow;
                manager.IsActive = true;

                await _managers.InsertOneAsync(manager);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating manager: {ex.Message}");
                return false;
            }
        }

        // Create a new manager and return the created manager
        public async Task<Manager> CreateManagerAndReturnAsync(Manager manager)
        {
            try
            {
                // Generate manager ID if not provided
                if (string.IsNullOrEmpty(manager.ManagerId))
                {
                    manager.ManagerId = await GenerateManagerIdAsync();
                }

                manager.HiredDate = DateTime.UtcNow;
                manager.IsActive = true;

                await _managers.InsertOneAsync(manager);
                return manager;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating manager: {ex.Message}");
                return null;
            }
        }

        // Get manager by email
        public async Task<Manager> GetManagerByEmailAsync(string email)
        {
            try
            {
                return await _managers.Find(m => m.IsActive && m.Email == email).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting manager by email: {ex.Message}");
                return null;
            }
        }

        // Get manager by applicant ID
        public async Task<Manager> GetManagerByApplicantIdAsync(string applicantId)
        {
            try
            {
                return await _managers.Find(m => m.IsActive && m.ApplicantId == applicantId).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting manager by applicant ID: {ex.Message}");
                return null;
            }
        }

        // Get all active managers
        public async Task<List<Manager>> GetAllManagersAsync()
        {
            try
            {
                return await _managers.Find(m => m.IsActive)
                    .SortBy(m => m.ManagerId)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all managers: {ex.Message}");
                return new List<Manager>();
            }
        }

        // Get managers by department
        public async Task<List<Manager>> GetManagersByDepartmentAsync(string department)
        {
            try
            {
                return await _managers.Find(m => m.IsActive && m.Department == department)
                    .SortBy(m => m.ManagerId)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting managers by department: {ex.Message}");
                return new List<Manager>();
            }
        }

        // Get department counts
        public async Task<Dictionary<string, int>> GetDepartmentCountsAsync()
        {
            try
            {
                var managers = await GetAllManagersAsync();
                return managers
                    .GroupBy(m => m.Department)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting department counts: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        // Generate manager ID (format: MN-XXXX)
        private async Task<string> GenerateManagerIdAsync()
        {
            try
            {
                // Get the last manager ID
                var lastManager = await _managers
                    .Find(m => m.ManagerId.StartsWith("MN-"))
                    .SortByDescending(m => m.ManagerId)
                    .FirstOrDefaultAsync();

                int nextNumber = 2211; // Starting number
                
                if (lastManager != null && !string.IsNullOrEmpty(lastManager.ManagerId))
                {
                    var parts = lastManager.ManagerId.Split('-');
                    if (parts.Length == 2 && int.TryParse(parts[1], out int lastNumber))
                    {
                        nextNumber = lastNumber + 1;
                    }
                }

                return $"MN-{nextNumber}";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating manager ID: {ex.Message}");
                return "MN-2211";
            }
        }

        // Get manager by ID
        public async Task<Manager> GetManagerByIdAsync(string id)
        {
            try
            {
                return await _managers.Find(m => m.Id == id).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting manager by ID: {ex.Message}");
                return null;
            }
        }

        // Update manager
        public async Task<bool> UpdateManagerAsync(string id, Manager manager)
        {
            try
            {
                var filter = Builders<Manager>.Filter.Eq(m => m.Id, id);
                var result = await _managers.ReplaceOneAsync(filter, manager);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating manager: {ex.Message}");
                return false;
            }
        }

        // Delete (deactivate) manager
        public async Task<bool> DeleteManagerAsync(string id)
        {
            try
            {
                var filter = Builders<Manager>.Filter.Eq(m => m.Id, id);
                var update = Builders<Manager>.Update.Set(m => m.IsActive, false);
                var result = await _managers.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting manager: {ex.Message}");
                return false;
            }
        }
    }
}

