using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class EmployeeService
    {
        private readonly IMongoCollection<User> _users;
        private readonly IMongoCollection<Employee> _employees; // optional separate collection

        public EmployeeService()
        {
            _users = MongoDBHelper.GetUsersCollection();
            try { _employees = MongoDBHelper.GetEmployeesCollection(); } catch { _employees = null; }
        }

        // Create a new employee (creates a User with Role="Employee")
        public async Task<bool> CreateEmployeeAsync(Employee employee)
        {
            try
            {
                string empId = string.IsNullOrEmpty(employee.EmployeeId) ? await GenerateEmployeeIdAsync() : employee.EmployeeId;

                // 1. CREATE EMPLOYEE RECORD IN EMPLOYEES COLLECTION
                var employeeRecord = new Employee
                {
                    EmployeeId = empId,
                    FirstName = employee.FirstName,
                    MiddleName = employee.MiddleName,
                    LastName = employee.LastName,
                    Email = employee.Email,
                    ContactNo = employee.ContactNo,
                    Address = employee.Address,
                    Age = employee.Age,
                    BirthDate = employee.BirthDate,
                    Gender = employee.Gender,
                    Department = employee.Department,
                    Role = employee.Role,
                    HiredDate = employee.HiredDate,
                    ApplicantId = employee.ApplicantId,
                    ContractType = employee.ContractType ?? "Regular",
                    IsActive = true
                };

                if (_employees != null)
                {
                    await _employees.InsertOneAsync(employeeRecord);
                }

                // 2. CREATE USER LOGIN ACCOUNT (CREDENTIALS ONLY)
                var user = new User
                {
                    Username = employee.Email,
                    Password = GenerateDefaultPassword(),
                    Role = "Employee",
                    Email = employee.Email,
                    EmployeeId = empId,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };
                await _users.InsertOneAsync(user);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating employee: {ex.Message}");
                return false;
            }
        }

        // Create a new employee and return the created employee (backwards compatibility)
        public async Task<Employee> CreateEmployeeAndReturnAsync(Employee employee)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine("?? CreateEmployeeAndReturnAsync - START");
                System.Diagnostics.Debug.WriteLine("========================================");

                // Generate EmployeeId if not provided
                string empId = string.IsNullOrEmpty(employee.EmployeeId) ? await GenerateEmployeeIdAsync() : employee.EmployeeId;
                
                System.Diagnostics.Debug.WriteLine($"Step 1: Generated EmployeeId: {empId}");
                
                // 1. CREATE EMPLOYEE RECORD IN EMPLOYEES COLLECTION (ALL EMPLOYEE DATA)
                var employeeRecord = new Employee
                {
                    EmployeeId = empId,
                    FirstName = employee.FirstName,
                    MiddleName = employee.MiddleName,
                    LastName = employee.LastName,
                    Email = employee.Email,
                    ContactNo = employee.ContactNo,
                    Address = employee.Address,
                    Age = employee.Age,
                    BirthDate = employee.BirthDate,
                    Gender = employee.Gender,
                    Department = employee.Department,
                    Role = employee.Role,
                    HiredDate = employee.HiredDate,
                    ApplicantId = employee.ApplicantId,
                    ContractType = employee.ContractType ?? "Regular",
                    IsActive = true
                };

                System.Diagnostics.Debug.WriteLine($"Step 2: Employee record prepared:");
                System.Diagnostics.Debug.WriteLine($"  - EmployeeId: {employeeRecord.EmployeeId}");
                System.Diagnostics.Debug.WriteLine($"  - Name: {employeeRecord.FullName}");
                System.Diagnostics.Debug.WriteLine($"  - Department: {employeeRecord.Department}");
                System.Diagnostics.Debug.WriteLine($"  - Role: {employeeRecord.Role}");
                System.Diagnostics.Debug.WriteLine($"  - Email: {employeeRecord.Email}");

                // Insert into Employees collection (PRIMARY SOURCE for employee data)
                if (_employees != null)
                {
                    System.Diagnostics.Debug.WriteLine("Step 3: Inserting into Employees collection...");
                    
                    try
                    {
                        // Use WriteConcern.Acknowledged to ensure write is confirmed
                        var options = new InsertOneOptions 
                        { 
                            BypassDocumentValidation = false 
                        };
                        
                        await _employees.InsertOneAsync(employeeRecord, options).ConfigureAwait(false);
                        
                        System.Diagnostics.Debug.WriteLine($"? InsertOneAsync completed");
                        System.Diagnostics.Debug.WriteLine($"? MongoDB-generated Id: {employeeRecord.Id ?? "NULL"}");
                        
                        // Verify the Id was generated
                        if (string.IsNullOrEmpty(employeeRecord.Id))
                        {
                            System.Diagnostics.Debug.WriteLine("?? WARNING: Id is null after insert, waiting 500ms and retrying verification...");
                            await Task.Delay(500);
                            
                            // Try to find the record we just inserted
                            var verification = await _employees
                                .Find(e => e.EmployeeId == empId && e.Email == employee.Email)
                                .FirstOrDefaultAsync()
                                .ConfigureAwait(false);
                            
                            if (verification != null)
                            {
                                System.Diagnostics.Debug.WriteLine($"? Verification successful - Found record with Id: {verification.Id}");
                                employeeRecord = verification; // Use the verified record with Id
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine("? ERROR: Could not verify record after insert!");
                                throw new Exception("Employee record was not saved to database - verification failed");
                            }
                        }
                        
                        // Final verification: Check that record exists in database
                        System.Diagnostics.Debug.WriteLine($"Step 4: Final verification - querying by Id: {employeeRecord.Id}");
                        var finalCheck = await _employees
                            .Find(e => e.Id == employeeRecord.Id)
                            .FirstOrDefaultAsync()
                            .ConfigureAwait(false);
                        
                        if (finalCheck == null)
                        {
                            System.Diagnostics.Debug.WriteLine("? ERROR: Final verification failed - record not found!");
                            throw new Exception("Employee record verification failed after insert");
                        }
                        
                        System.Diagnostics.Debug.WriteLine($"? Final verification successful:");
                        System.Diagnostics.Debug.WriteLine($"  - MongoDB _id: {finalCheck.Id}");
                        System.Diagnostics.Debug.WriteLine($"  - EmployeeId: {finalCheck.EmployeeId}");
                        System.Diagnostics.Debug.WriteLine($"  - Name: {finalCheck.FullName}");
                        System.Diagnostics.Debug.WriteLine($"? Employee record created in Employees collection: {employeeRecord.EmployeeId}");
                    }
                    catch (MongoDB.Driver.MongoWriteException mongoEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"? MongoDB Write Exception: {mongoEx.Message}");
                        System.Diagnostics.Debug.WriteLine($"? Write Error Code: {mongoEx.WriteError?.Code}");
                        System.Diagnostics.Debug.WriteLine($"? Write Error Details: {mongoEx.WriteError?.Details}");
                        throw new Exception($"MongoDB write error: {mongoEx.WriteError?.Message ?? mongoEx.Message}", mongoEx);
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("? ERROR: Employees collection is NULL!");
                    throw new Exception("Employees collection is required but not available");
                }

                // 2. CREATE USER LOGIN ACCOUNT IN USERS COLLECTION (CREDENTIALS ONLY - NO EMPLOYEE DATA)
                System.Diagnostics.Debug.WriteLine("Step 5: Creating user login account in Users collection...");
                
                var user = new User
                {
                    Username = employee.Email,
                    Password = GenerateDefaultPassword(),
                    Role = "Employee",
                    Email = employee.Email,
                    EmployeeId = empId,  // Link to employee record
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                    // NO EMPLOYEE FIELDS - Users table is for authentication only
                };

                await _users.InsertOneAsync(user).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"? User login account created (credentials only): {user.Email}");

                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine("? CreateEmployeeAndReturnAsync - SUCCESS");
                System.Diagnostics.Debug.WriteLine($"? Returning Employee with Id: {employeeRecord.Id}");
                System.Diagnostics.Debug.WriteLine("========================================");

                // Return the employee record (with MongoDB-generated Id)
                return employeeRecord;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine($"? CreateEmployeeAndReturnAsync - FATAL ERROR");
                System.Diagnostics.Debug.WriteLine($"? Error Type: {ex.GetType().FullName}");
                System.Diagnostics.Debug.WriteLine($"? Error Message: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"? Stack trace: {ex.StackTrace}");
                
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"? Inner Exception: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"? Inner Stack: {ex.InnerException.StackTrace}");
                }
                
                System.Diagnostics.Debug.WriteLine("========================================");
                return null;
            }
        }

        // Get all active employees (Employees collection ONLY - no Users fallback)
        public async Task<List<Employee>> GetAllEmployeesAsync()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine("?? GetAllEmployeesAsync - START");
                System.Diagnostics.Debug.WriteLine("========================================");

                // Check if Employees collection is available
                if (_employees == null)
                {
                    System.Diagnostics.Debug.WriteLine("? ERROR: _employees collection is NULL!");
                    System.Diagnostics.Debug.WriteLine("========================================");
                    return new List<Employee>();
                }

                System.Diagnostics.Debug.WriteLine($"? Employees collection available: {_employees.CollectionNamespace.CollectionName}");
                System.Diagnostics.Debug.WriteLine("Step 1: Querying Employees collection...");
                
                // Count total documents first
                var totalCount = await _employees.CountDocumentsAsync(FilterDefinition<Employee>.Empty).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"  Total documents in Employees collection: {totalCount}");
                
                // Count active documents
                var activeCount = await _employees.CountDocumentsAsync(e => e.IsActive).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"  Active documents in Employees collection: {activeCount}");
                
                // Fetch active employees
                var employees = await _employees.Find(e => e.IsActive)
                    .SortBy(e => e.EmployeeId)
                    .ToListAsync()
                    .ConfigureAwait(false);
                
                System.Diagnostics.Debug.WriteLine($"? Retrieved {employees.Count} active employees from Employees collection");
                
                if (employees.Count > 0)
                {
                    System.Diagnostics.Debug.WriteLine($"?? First {Math.Min(5, employees.Count)} employees:");
                    foreach (var emp in employees.Take(5))
                    {
                        System.Diagnostics.Debug.WriteLine($"  - Id: {emp.Id}, EmployeeId: {emp.EmployeeId}, Name: {emp.FullName}, Dept: {emp.Department}, Active: {emp.IsActive}");
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("?? WARNING: No active employees found in Employees collection");
                    System.Diagnostics.Debug.WriteLine("  ACTION REQUIRED: Hire employees through Recruitment module!");
                }
                
                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine($"? GetAllEmployeesAsync - END (returning {employees.Count} employees)");
                System.Diagnostics.Debug.WriteLine("========================================");
                
                return employees;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("========================================");
                System.Diagnostics.Debug.WriteLine($"? GetAllEmployeesAsync - ERROR");
                System.Diagnostics.Debug.WriteLine($"? Error Type: {ex.GetType().FullName}");
                System.Diagnostics.Debug.WriteLine($"? Error Message: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"? Stack trace: {ex.StackTrace}");
                
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"? Inner Exception: {ex.InnerException.Message}");
                }
                
                System.Diagnostics.Debug.WriteLine("========================================");
                return new List<Employee>();
            }
        }

        // Get employee by email (Employees collection ONLY)
        public async Task<Employee> GetEmployeeByEmailAsync(string email)
        {
            try
            {
                // Check Employees collection only
                if (_employees != null)
                {
                    var employee = await _employees.Find(e => e.IsActive && e.Email == email).FirstOrDefaultAsync();
                    if (employee != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"? Employee found in Employees collection: {email}");
                        return employee;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"?? Employee not found: {email}");
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by email: {ex.Message}");
                return null;
            }
        }

        // Get employee by applicant ID (Employees collection ONLY)
        public async Task<Employee> GetEmployeeByApplicantIdAsync(string applicantId)
        {
            try
            {
                // Check Employees collection only
                if (_employees != null)
                {
                    var employee = await _employees.Find(e => e.IsActive && e.ApplicantId == applicantId).FirstOrDefaultAsync();
                    if (employee != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"? Employee found in Employees collection by applicantId: {applicantId}");
                        return employee;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"?? Employee not found by applicantId: {applicantId}");
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by applicant ID: {ex.Message}");
                return null;
            }
        }

        // Get employees by department (Employees collection ONLY)
        public async Task<List<Employee>> GetEmployeesByDepartmentAsync(string department)
        {
            try
            {
                // Query Employees collection only
                if (_employees != null)
                {
                    var employees = await _employees.Find(e => e.IsActive && e.Department == department)
                        .SortBy(e => e.EmployeeId)
                        .ToListAsync();
                    
                    System.Diagnostics.Debug.WriteLine($"? Found {employees.Count} employees in department: {department}");
                    return employees;
                }

                System.Diagnostics.Debug.WriteLine($"?? Employees collection not available");
                return new List<Employee>();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employees by department: {ex.Message}");
                return new List<Employee>();
            }
        }

        public async Task<Dictionary<string, int>> GetDepartmentCountsAsync()
        {
            try
            {
                var employees = await GetAllEmployeesAsync();
                return employees
                    .Where(e => !string.IsNullOrEmpty(e.Department))
                    .GroupBy(e => e.Department)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting department counts: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        private async Task<string> GenerateEmployeeIdAsync()
        {
            try
            {
                var year = DateTime.Now.ToString("yy");
                var lastUser = await _users
                    .Find(u => u.Role == "Employee" && u.EmployeeId != null && u.EmployeeId.StartsWith(year + "-"))
                    .SortByDescending(u => u.EmployeeId)
                    .FirstOrDefaultAsync();
                int nextNumber = 2211;
                if (lastUser != null && !string.IsNullOrEmpty(lastUser.EmployeeId))
                {
                    var parts = lastUser.EmployeeId.Split('-');
                    if (parts.Length == 2 && int.TryParse(parts[1], out int lastNumber))
                        nextNumber = lastNumber + 1;
                }
                return $"{year}-{nextNumber}";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating employee ID: {ex.Message}");
                return $"{DateTime.Now:yy}-2211";
            }
        }

        // Get employee by Id (Mongo _id string) - Employees collection ONLY
        public async Task<Employee> GetEmployeeByIdAsync(string id)
        {
            try
            {
                // Check Employees collection only
                if (_employees != null)
                {
                    var employee = await _employees.Find(e => e.Id == id && e.IsActive).FirstOrDefaultAsync();
                    if (employee != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"? Employee found in Employees collection by Id: {id}");
                        return employee;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"?? Employee not found by Id: {id}");
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by ID: {ex.Message}");
                return null;
            }
        }

        // Get employee by EmployeeId string (e.g., "23-2211") - Employees collection ONLY
        public async Task<Employee> GetByEmployeeIdAsync(string employeeId)
        {
            try
            {
                // Check Employees collection only
                if (_employees != null)
                {
                    var employee = await _employees.Find(e => e.EmployeeId == employeeId && e.IsActive).FirstOrDefaultAsync();
                    if (employee != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"✓ Employee found in Employees collection by EmployeeId: {employeeId}");
                        return employee;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"⚠ Employee not found by EmployeeId: {employeeId}");
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee by EmployeeId: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UpdateEmployeeAsync(string id, Employee employee)
        {
            try
            {
                // PRIMARY: Update Employees collection
                if (_employees != null)
                {
                    var existingEmployee = await _employees.Find(e => e.Id == id).FirstOrDefaultAsync();
                    if (existingEmployee != null)
                    {
                        existingEmployee.FirstName = employee.FirstName;
                        existingEmployee.MiddleName = employee.MiddleName;
                        existingEmployee.LastName = employee.LastName;
                        existingEmployee.Email = employee.Email;
                        existingEmployee.ContactNo = employee.ContactNo;
                        existingEmployee.Address = employee.Address;
                        existingEmployee.Age = employee.Age;
                        existingEmployee.BirthDate = employee.BirthDate;
                        existingEmployee.Gender = employee.Gender;
                        existingEmployee.Department = employee.Department;
                        existingEmployee.Role = employee.Role;
                        existingEmployee.ContractType = employee.ContractType;

                        var filter = Builders<Employee>.Filter.Eq(e => e.Id, id);
                        var result = await _employees.ReplaceOneAsync(filter, existingEmployee);
                        
                        // Also update email in Users collection if it changed (for login)
                        if (result.ModifiedCount > 0)
                        {
                            var userFilter = Builders<User>.Filter.Eq(u => u.EmployeeId, existingEmployee.EmployeeId);
                            var userUpdate = Builders<User>.Update
                                .Set(u => u.Email, employee.Email)
                                .Set(u => u.Username, employee.Email);
                            await _users.UpdateOneAsync(userFilter, userUpdate);
                            System.Diagnostics.Debug.WriteLine($"? Employee updated in Employees collection: {id}");
                        }
                        
                        return result.ModifiedCount > 0;
                    }
                }

                // FALLBACK: Update Users collection (legacy)
                var existingUser = await _users.Find(u => u.Id == id).FirstOrDefaultAsync();
                if (existingUser == null) return false;

                existingUser.FirstName = employee.FirstName;
                existingUser.MiddleName = employee.MiddleName;
                existingUser.LastName = employee.LastName;
                existingUser.Email = employee.Email;
                existingUser.ContactNo = employee.ContactNo;
                existingUser.Address = employee.Address;
                existingUser.Age = employee.Age;
                existingUser.BirthDate = employee.BirthDate;
                existingUser.Gender = employee.Gender;
                existingUser.Department = employee.Department;
                existingUser.Position = employee.Role;
                existingUser.ContractType = employee.ContractType;

                var userFilter2 = Builders<User>.Filter.Eq(u => u.Id, id);
                var result2 = await _users.ReplaceOneAsync(userFilter2, existingUser);
                System.Diagnostics.Debug.WriteLine($"? Employee updated in Users collection (legacy): {id}");
                return result2.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating employee: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteEmployeeAsync(string id)
        {
            try
            {
                bool success = false;

                // Delete from Employees collection
                if (_employees != null)
                {
                    var empFilter = Builders<Employee>.Filter.Eq(e => e.Id, id);
                    var empUpdate = Builders<Employee>.Update.Set(e => e.IsActive, false);
                    var empResult = await _employees.UpdateOneAsync(empFilter, empUpdate);
                    if (empResult.ModifiedCount > 0)
                    {
                        success = true;
                        System.Diagnostics.Debug.WriteLine($"? Employee deactivated in Employees collection: {id}");
                    }
                }

                // Also deactivate in Users collection
                var userFilter = Builders<User>.Filter.Eq(u => u.Id, id);
                var userUpdate = Builders<User>.Update.Set(u => u.IsActive, false);
                var userResult = await _users.UpdateOneAsync(userFilter, userUpdate);
                if (userResult.ModifiedCount > 0)
                {
                    success = true;
                    System.Diagnostics.Debug.WriteLine($"? User account deactivated: {id}");
                }

                return success;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting employee: {ex.Message}");
                return false;
            }
        }

        private string GenerateDefaultPassword() => $"EMP-{new Random().Next(100000, 999999)}";

        // ========== PAYMENT & BANKING METHODS (Still use Users collection for payment status) ==========
        
        // Keep original parameter names for backwards compatibility
        public async Task<bool> UpdatePaymentStatusAsync(string employeeId, string status, DateTime? payDate, string payRunId = null)
        {
            try
            {
                var filter = Builders<User>.Filter.And(
                    Builders<User>.Filter.Eq(u => u.EmployeeId, employeeId),
                    Builders<User>.Filter.Eq(u => u.Role, "Employee")
                );
                var update = Builders<User>.Update
                    .Set(u => u.PaymentStatus, status)
                    .Set(u => u.LastPaymentDate, payDate);
                if (!string.IsNullOrEmpty(payRunId)) update = update.Set(u => u.LastPayRunId, payRunId);
                var result = await _users.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating payment status: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateBankAccountAsync(string employeeId, string accountNumber, string bankName, string accountType = "Savings")
        {
            try
            {
                var filter = Builders<User>.Filter.And(
                    Builders<User>.Filter.Eq(u => u.EmployeeId, employeeId),
                    Builders<User>.Filter.Eq(u => u.Role, "Employee")
                );
                var update = Builders<User>.Update
                    .Set(u => u.BankAccountNumber, accountNumber)
                    .Set(u => u.BankName, bankName)
                    .Set(u => u.BankAccountType, accountType);
                var result = await _users.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating bank account: {ex.Message}");
                return false;
            }
        }

        public async Task<User> GetUserByEmployeeIdAsync(string employeeId)
        {
            try { return await _users.Find(u => u.EmployeeId == employeeId && u.Role == "Employee").FirstOrDefaultAsync(); }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"Error getting user by employee ID: {ex.Message}"); return null; }
        }
    }
}

