using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class EmployeeService
    {
        private readonly IMongoCollection<Employee> _employees;

        public EmployeeService()
        {
            _employees = MongoDBHelper.GetEmployeesCollection();
        }

        // Create a new employee
        public async Task<bool> CreateEmployeeAsync(Employee employee)
        {
            try
            {
                // Generate employee ID if not provided
                if (string.IsNullOrEmpty(employee.EmployeeId))
                {
                    employee.EmployeeId = await GenerateEmployeeIdAsync();
                }

                employee.HiredDate = DateTime.UtcNow;
                employee.IsActive = true;

                await _employees.InsertOneAsync(employee);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating employee: {ex.Message}");
                return false;
            }
        }

        // Create a new employee and return the created employee
        public async Task<Employee> CreateEmployeeAndReturnAsync(Employee employee)
        {
            try
            {
                // Generate employee ID if not provided
                if (string.IsNullOrEmpty(employee.EmployeeId))
                {
                    employee.EmployeeId = await GenerateEmployeeIdAsync();
                }

                employee.HiredDate = DateTime.UtcNow;
                employee.IsActive = true;

                await _employees.InsertOneAsync(employee);
                return employee;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating employee: {ex.Message}");
                return null;
            }
        }

        // Get employee by email
        public async Task<Employee> GetEmployeeByEmailAsync(string email)
        {
            try
            {
                return await _employees.Find(e => e.IsActive && e.Email == email).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by email: {ex.Message}");
                return null;
            }
        }

        // Get employee by applicant ID
        public async Task<Employee> GetEmployeeByApplicantIdAsync(string applicantId)
        {
            try
            {
                return await _employees.Find(e => e.IsActive && e.ApplicantId == applicantId).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by applicant ID: {ex.Message}");
                return null;
            }
        }

        // Get all active employees
        public async Task<List<Employee>> GetAllEmployeesAsync()
        {
            try
            {
                return await _employees.Find(e => e.IsActive)
                    .SortBy(e => e.EmployeeId)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all employees: {ex.Message}");
                return new List<Employee>();
            }
        }

        // Get employees by department
        public async Task<List<Employee>> GetEmployeesByDepartmentAsync(string department)
        {
            try
            {
                return await _employees.Find(e => e.IsActive && e.Department == department)
                    .SortBy(e => e.EmployeeId)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employees by department: {ex.Message}");
                return new List<Employee>();
            }
        }

        // Get department counts
        public async Task<Dictionary<string, int>> GetDepartmentCountsAsync()
        {
            try
            {
                var employees = await GetAllEmployeesAsync();
                return employees
                    .GroupBy(e => e.Department)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting department counts: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        // Generate employee ID (format: YY-XXXX)
        private async Task<string> GenerateEmployeeIdAsync()
        {
            try
            {
                var year = DateTime.Now.ToString("yy");
                
                // Get the last employee ID for this year
                var lastEmployee = await _employees
                    .Find(e => e.EmployeeId.StartsWith(year + "-"))
                    .SortByDescending(e => e.EmployeeId)
                    .FirstOrDefaultAsync();

                int nextNumber = 2211; // Starting number
                
                if (lastEmployee != null && !string.IsNullOrEmpty(lastEmployee.EmployeeId))
                {
                    var parts = lastEmployee.EmployeeId.Split('-');
                    if (parts.Length == 2 && int.TryParse(parts[1], out int lastNumber))
                    {
                        nextNumber = lastNumber + 1;
                    }
                }

                return $"{year}-{nextNumber}";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating employee ID: {ex.Message}");
                return $"{DateTime.Now:yy}-2211";
            }
        }

        // Get employee by ID
        public async Task<Employee> GetEmployeeByIdAsync(string id)
        {
            try
            {
                return await _employees.Find(e => e.Id == id).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by ID: {ex.Message}");
                return null;
            }
        }

        // Update employee
        public async Task<bool> UpdateEmployeeAsync(string id, Employee employee)
        {
            try
            {
                var filter = Builders<Employee>.Filter.Eq(e => e.Id, id);
                var result = await _employees.ReplaceOneAsync(filter, employee);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating employee: {ex.Message}");
                return false;
            }
        }

        // Delete (deactivate) employee
        public async Task<bool> DeleteEmployeeAsync(string id)
        {
            try
            {
                var filter = Builders<Employee>.Filter.Eq(e => e.Id, id);
                var update = Builders<Employee>.Update.Set(e => e.IsActive, false);
                var result = await _employees.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting employee: {ex.Message}");
                return false;
            }
        }
    }
}

