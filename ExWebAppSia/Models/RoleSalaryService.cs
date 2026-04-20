using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class RoleSalaryService
    {
        private readonly IMongoCollection<RoleSalary> _roleSalaries;

        public RoleSalaryService()
        {
            _roleSalaries = MongoDBHelper.GetRoleSalariesCollection();
        }

        // Create or Update Role Salary
        public async Task<bool> SaveRoleSalaryAsync(RoleSalary roleSalary)
        {
            try
            {
                roleSalary.UpdatedAt = DateTime.UtcNow;
                if (string.IsNullOrEmpty(roleSalary.Id))
                {
                    roleSalary.CreatedAt = DateTime.UtcNow;
                    await _roleSalaries.InsertOneAsync(roleSalary);
                }
                else
                {
                    var filter = Builders<RoleSalary>.Filter.Eq(r => r.Id, roleSalary.Id);
                    await _roleSalaries.ReplaceOneAsync(filter, roleSalary);
                }
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving role salary: {ex.Message}");
                return false;
            }
        }

        // Get all role salaries
        public async Task<List<RoleSalary>> GetAllRoleSalariesAsync()
        {
            try
            {
                return await _roleSalaries.Find(_ => true).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting role salaries: {ex.Message}");
                return new List<RoleSalary>();
            }
        }

        // Get salary by role name
        public async Task<RoleSalary> GetSalaryByRoleAsync(string roleName)
        {
            try
            {
                return await _roleSalaries.Find(r => r.RoleName == roleName).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting salary for role {roleName}: {ex.Message}");
                return null;
            }
        }

        // Seed initial data if needed
        public async Task SeedRoleSalariesAsync()
        {
            var hasLegacyDept = await _roleSalaries.Find(r => r.Department == "IT Support" || r.Department == "Quality Control").AnyAsync();
            var hasNewRole = await _roleSalaries.Find(r => r.RoleName == "Fulfillment & Logistics Coordinator").AnyAsync();
            var hasInactive = await _roleSalaries.Find(r => !r.IsActive).AnyAsync();
            var count = await _roleSalaries.CountDocumentsAsync(new BsonDocument());
            
            // Re-seed if count is low, legacy depts found, new role missing, OR any role is inactive
            if (count <= 6 || hasLegacyDept || !hasNewRole || hasInactive) 
            {
                // Clear existing if it's the old 6-role set to avoid duplicates/confusion
                if (count > 0)
                {
                    await _roleSalaries.DeleteManyAsync(new BsonDocument());
                }

                var initialSalaries = new List<RoleSalary>
                {
                    // Human Resources
                    new RoleSalary { RoleName = "HR Manager", Department = "Human Resources", BaseSalary = 31000, IsActive = true },
                    new RoleSalary { RoleName = "HR Generalist", Department = "Human Resources", BaseSalary = 21000, IsActive = true },
                    new RoleSalary { RoleName = "Recruitment Specialist", Department = "Human Resources", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Payroll Manager", Department = "Human Resources", BaseSalary = 31000, IsActive = true },
                    new RoleSalary { RoleName = "Payroll Specialist", Department = "Human Resources", BaseSalary = 20000, IsActive = true },

                    // Operations (includes QC and IT Support)
                    new RoleSalary { RoleName = "Operations Manager", Department = "Operations", BaseSalary = 40000, IsActive = true },
                    new RoleSalary { RoleName = "Order Processing Specialist", Department = "Operations", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Supply Chain Coordinator", Department = "Operations", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Quality Control Manager", Department = "Operations", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "IT Systems Administrator", Department = "Operations", BaseSalary = 29000, IsActive = true },
                    new RoleSalary { RoleName = "E-Commerce Tech Support Specialist", Department = "Operations", BaseSalary = 21000, IsActive = true },
                    new RoleSalary { RoleName = "Fulfillment & Logistics Coordinator", Department = "Operations", BaseSalary = 28000, IsActive = true },
                    new RoleSalary { RoleName = "Product Quality Inspector", Department = "Operations", BaseSalary = 24000, IsActive = true },

                    // Marketing (includes Sales and Customer Service)
                    new RoleSalary { RoleName = "Digital Marketing Manager", Department = "Marketing", BaseSalary = 34000, IsActive = true },
                    new RoleSalary { RoleName = "Social Media & Content Specialist", Department = "Marketing", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Sales Manager", Department = "Marketing", BaseSalary = 34000, IsActive = true },
                    new RoleSalary { RoleName = "Online Sales Specialist", Department = "Marketing", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Beauty Brand Partnership Associate", Department = "Marketing", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Customer Service Team Lead", Department = "Marketing", BaseSalary = 25000, IsActive = true },
                    new RoleSalary { RoleName = "Customer Support Representative", Department = "Marketing", BaseSalary = 19000, IsActive = true },

                    // Finance/Accounting
                    new RoleSalary { RoleName = "Finance Manager", Department = "Finance/Accounting", BaseSalary = 38000, IsActive = true },
                    new RoleSalary { RoleName = "Senior Accountant", Department = "Finance/Accounting", BaseSalary = 29000, IsActive = true },
                    new RoleSalary { RoleName = "Accounts Payable Specialist", Department = "Finance/Accounting", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Accounts Receivable Specialist", Department = "Finance/Accounting", BaseSalary = 20000, IsActive = true },
                    
                    // Inventory
                    new RoleSalary { RoleName = "Inventory Manager", Department = "Inventory", BaseSalary = 29000, IsActive = true },
                    new RoleSalary { RoleName = "Inventory Control Specialist", Department = "Inventory", BaseSalary = 20000, IsActive = true },
                    new RoleSalary { RoleName = "Warehouse & Stock Associate", Department = "Inventory", BaseSalary = 19000, IsActive = true },
                    
                    // R&D
                    new RoleSalary { RoleName = "R&D Manager", Department = "R&D", BaseSalary = 38000, IsActive = true },
                    new RoleSalary { RoleName = "Cosmetic Formulation Specialist", Department = "R&D", BaseSalary = 25000, IsActive = true },
                    new RoleSalary { RoleName = "Product Development & Testing Associate", Department = "R&D", BaseSalary = 20000, IsActive = true }
                };
                await _roleSalaries.InsertManyAsync(initialSalaries);
            }
        }
    }
}
