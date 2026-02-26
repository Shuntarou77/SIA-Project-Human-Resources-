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
                return await _roleSalaries.Find(r => r.IsActive).ToListAsync();
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
                return await _roleSalaries.Find(r => r.RoleName == roleName && r.IsActive).FirstOrDefaultAsync();
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
            var count = await _roleSalaries.CountDocumentsAsync(new BsonDocument());
            if (count <= 6) // If only the old small set exists or it's empty
            {
                // Clear existing if it's the old 6-role set to avoid duplicates/confusion
                if (count > 0)
                {
                    await _roleSalaries.DeleteManyAsync(new BsonDocument());
                }

                var initialSalaries = new List<RoleSalary>
                {
                    // Research & Development
                    new RoleSalary { RoleName = "Research Scientist", Department = "Research & Development", BaseSalary = 48000 },
                    new RoleSalary { RoleName = "Lab Technician", Department = "Research & Development", BaseSalary = 25000 },
                    new RoleSalary { RoleName = "Product Developer", Department = "Research & Development", BaseSalary = 42000 },
                    new RoleSalary { RoleName = "R&D Manager", Department = "Research & Development", BaseSalary = 85000 },
                    
                    // Quality Control
                    new RoleSalary { RoleName = "QC Analyst", Department = "Quality Control", BaseSalary = 30000 },
                    new RoleSalary { RoleName = "QC Inspector", Department = "Quality Control", BaseSalary = 24000 },
                    new RoleSalary { RoleName = "QC Manager", Department = "Quality Control", BaseSalary = 75000 },
                    new RoleSalary { RoleName = "Laboratory Supervisor", Department = "Quality Control", BaseSalary = 55000 },
                    
                    // Human Resources
                    new RoleSalary { RoleName = "HR Generalist", Department = "Human Resources", BaseSalary = 32500 },
                    new RoleSalary { RoleName = "Recruitment Specialist", Department = "Human Resources", BaseSalary = 28000 },
                    new RoleSalary { RoleName = "HR Manager", Department = "Human Resources", BaseSalary = 75000 },
                    new RoleSalary { RoleName = "Training Coordinator", Department = "Human Resources", BaseSalary = 35000 },
                    
                    // Finance
                    new RoleSalary { RoleName = "Accountant", Department = "Finance", BaseSalary = 40000 },
                    new RoleSalary { RoleName = "Financial Analyst", Department = "Finance", BaseSalary = 45000 },
                    new RoleSalary { RoleName = "Finance Manager", Department = "Finance", BaseSalary = 85000 },
                    new RoleSalary { RoleName = "Payroll Specialist", Department = "Finance", BaseSalary = 32000 },
                    
                    // Marketing
                    new RoleSalary { RoleName = "Marketing Coordinator", Department = "Marketing", BaseSalary = 28000 },
                    new RoleSalary { RoleName = "Brand Manager", Department = "Marketing", BaseSalary = 70000 },
                    new RoleSalary { RoleName = "Digital Marketing Specialist", Department = "Marketing", BaseSalary = 35000 },
                    new RoleSalary { RoleName = "Content Creator", Department = "Marketing", BaseSalary = 26000 },
                    
                    // IT Support
                    new RoleSalary { RoleName = "IT Support Specialist", Department = "IT Support", BaseSalary = 32000 },
                    new RoleSalary { RoleName = "Network Administrator", Department = "IT Support", BaseSalary = 55000 },
                    new RoleSalary { RoleName = "System Administrator", Department = "IT Support", BaseSalary = 58000 },
                    new RoleSalary { RoleName = "IT Manager", Department = "IT Support", BaseSalary = 95000 },
                    
                    // Operations
                    new RoleSalary { RoleName = "Operations Coordinator", Department = "Operations", BaseSalary = 30000 },
                    new RoleSalary { RoleName = "Operations Manager", Department = "Operations", BaseSalary = 80000 },
                    new RoleSalary { RoleName = "Supply Chain Specialist", Department = "Operations", BaseSalary = 42000 },
                    new RoleSalary { RoleName = "Logistics Coordinator", Department = "Operations", BaseSalary = 28000 },
                    
                    // Sales
                    new RoleSalary { RoleName = "Sales Representative", Department = "Sales", BaseSalary = 25000 },
                    new RoleSalary { RoleName = "Sales Manager", Department = "Sales", BaseSalary = 70000 },
                    new RoleSalary { RoleName = "Account Executive", Department = "Sales", BaseSalary = 45000 },
                    new RoleSalary { RoleName = "Business Development Manager", Department = "Sales", BaseSalary = 80000 },
                    
                    // Inventory
                    new RoleSalary { RoleName = "Inventory Manager", Department = "Inventory", BaseSalary = 75000 },
                    new RoleSalary { RoleName = "Inventory Specialist", Department = "Inventory", BaseSalary = 40000 },
                    new RoleSalary { RoleName = "Warehouseman", Department = "Inventory", BaseSalary = 22000 },
                    new RoleSalary { RoleName = "Storekeeper", Department = "Inventory", BaseSalary = 28000 },
                    
                    // Customer Service
                    new RoleSalary { RoleName = "Customer Service Representative", Department = "Customer Service", BaseSalary = 22000 },
                    new RoleSalary { RoleName = "Customer Support Specialist", Department = "Customer Service", BaseSalary = 28000 },
                    new RoleSalary { RoleName = "Call Center Agent", Department = "Customer Service", BaseSalary = 24000 },
                    new RoleSalary { RoleName = "Customer Service Manager", Department = "Customer Service", BaseSalary = 70000 }
                };
                await _roleSalaries.InsertManyAsync(initialSalaries);
            }
        }
    }
}
