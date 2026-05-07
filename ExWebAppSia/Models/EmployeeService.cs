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
        private readonly IMongoCollection<Employee> _employees; // active employees
        private readonly IMongoCollection<Employee> _resignedEmployees; // resigned employees

        public EmployeeService()
        {
            _users = MongoDBHelper.GetUsersCollection();
            try { _employees = MongoDBHelper.GetEmployeesCollection(); } catch { _employees = null; }
            try { _resignedEmployees = MongoDBHelper.GetDatabase().GetCollection<Employee>("ResignedEmployees"); } catch { _resignedEmployees = null; }
        }

        public async Task<bool> IsNameDuplicateAsync(string firstName, string lastName)
        {
            try
            {
                if (_employees == null) return false;
                var filter = Builders<Employee>.Filter.And(
                    Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                    Builders<Employee>.Filter.Regex(e => e.FirstName, new MongoDB.Bson.BsonRegularExpression($"^{firstName}$", "i")),
                    Builders<Employee>.Filter.Regex(e => e.LastName, new MongoDB.Bson.BsonRegularExpression($"^{lastName}$", "i"))
                );
                return await _employees.Find(filter).AnyAsync();
            }
            catch { return false; }
        }

        public async Task<bool> IsRoleOccupiedAsync(string roleName)
        {
            try
            {
                if (_employees == null || string.IsNullOrEmpty(roleName)) return false;
                var filter = Builders<Employee>.Filter.And(
                    Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                    Builders<Employee>.Filter.Eq(e => e.Role, roleName)
                );
                return await _employees.Find(filter).AnyAsync();
            }
            catch { return false; }
        }

        public async Task<bool> SubmitResignationRequestAsync(string employeeId, string reason, DateTime proposedDate)
        {
            try
            {
                var update = Builders<Employee>.Update
                    .Set(e => e.ResignationStatus, "Pending")
                    .Set(e => e.ResignationReason, reason)
                    .Set(e => e.ResignationDate, proposedDate);
                var result = await _employees.UpdateOneAsync(e => e.EmployeeId == employeeId, update);
                return result.ModifiedCount > 0;
            }
            catch { return false; }
        }

        private void GenerateGovNumbers(Employee emp)
        {
            Random rand = new Random();
            if (string.IsNullOrEmpty(emp.SSSNumber))
                emp.SSSNumber = $"{rand.Next(10, 99)}-{rand.Next(1000000, 9999999)}-{rand.Next(0, 9)}";
            if (string.IsNullOrEmpty(emp.PhilHealthNumber))
                emp.PhilHealthNumber = $"{rand.Next(10, 99)}-{rand.Next(100000000, 999999999)}-{rand.Next(0, 9)}";
            if (string.IsNullOrEmpty(emp.PagIbigNumber))
                emp.PagIbigNumber = $"{rand.Next(1000, 9999)}-{rand.Next(1000, 9999)}-{rand.Next(1000, 9999)}";
            
            emp.HasSSS = true;
            emp.HasPhilHealth = true;
            emp.HasPagIbig = true;
        }

        // Standardized salary table for small company (Internal Source of Truth)
        private static readonly Dictionary<string, decimal> _regularSalaries = new Dictionary<string, decimal>
        {
            { "Research Scientist", 48000 }, { "Lab Technician", 25000 }, { "Product Developer", 42000 }, { "R&D Manager", 85000 },
            { "QC Analyst", 30000 }, { "QC Inspector", 24000 }, { "QC Manager", 75000 }, { "Laboratory Supervisor", 55000 },
            { "HR Generalist", 32500 }, { "Recruitment Specialist", 28000 }, { "HR Manager", 75000 }, { "Training Coordinator", 35000 },
            { "Accountant", 40000 }, { "Financial Analyst", 45000 }, { "Finance Manager", 85000 }, { "Payroll Specialist", 32000 },
            { "Marketing Coordinator", 28000 }, { "Brand Manager", 70000 }, { "Digital Marketing Specialist", 35000 }, { "Content Creator", 26000 },
            { "IT Support Specialist", 32000 }, { "Network Administrator", 55000 }, { "System Administrator", 58000 }, { "IT Manager", 95000 },
            { "Operations Coordinator", 30000 }, { "Operations Manager", 80000 }, { "Supply Chain Specialist", 42000 }, { "Logistics Coordinator", 28000 },
            { "Sales Representative", 25000 }, { "Sales Manager", 70000 }, { "Account Executive", 45000 }, { "Business Development Manager", 80000 },
            { "Inventory Manager", 75000 }, { "Inventory Specialist", 40000 }, { "Warehouseman", 22000 }, { "Storekeeper", 28000 },
            { "Customer Service Representative", 22000 }, { "Customer Support Specialist", 28000 }, { "Call Center Agent", 24000 }, { "Customer Service Manager", 70000 }
        };

        /// <summary>
        /// Automatically regularizes employees who have reached 6 months of tenure.
        /// Updates ContractType to "Regular" and sets the BaseSalary to the standardized amount.
        /// </summary>
        public async Task<int> ProcessRegularizationAsync()
        {
            if (_employees == null) return 0;

            var thresholdDate = DateTime.UtcNow.AddMonths(-6);
            var filter = Builders<Employee>.Filter.And(
                Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                Builders<Employee>.Filter.Eq(e => e.ContractType, "Probationary"),
                Builders<Employee>.Filter.Lte(e => e.HiredDate, thresholdDate)
            );

            var eligibleEmployees = await _employees.Find(filter).ToListAsync();
            if (!eligibleEmployees.Any()) return 0;

            var models = new List<WriteModel<Employee>>();
            foreach (var emp in eligibleEmployees)
            {
                var update = Builders<Employee>.Update.Set(e => e.ContractType, "Regular");
                if (!string.IsNullOrEmpty(emp.Role) && _regularSalaries.ContainsKey(emp.Role))
                {
                    update = update.Set(e => e.BaseSalary, _regularSalaries[emp.Role]);
                }
                models.Add(new UpdateOneModel<Employee>(Builders<Employee>.Filter.Eq(e => e.Id, emp.Id), update));
            }

            var result = await _employees.BulkWriteAsync(models);
            return (int)result.ModifiedCount;
        }

        /// <summary>
        /// Ensures all probationary employees have the mandatory starting salary of 18,000 PHP.
        /// Fixes legacy records or records created with missing salary data.
        /// </summary>
        public async Task<int> FixProbationarySalariesAsync()
        {
            if (_employees == null) return 0;

            var filter = Builders<Employee>.Filter.And(
                Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                Builders<Employee>.Filter.Eq(e => e.ContractType, "Probationary"),
                Builders<Employee>.Filter.Lte(e => e.BaseSalary, 0)
            );

            var update = Builders<Employee>.Update.Set(e => e.BaseSalary, 18000);
            var result = await _employees.UpdateManyAsync(filter, update).ConfigureAwait(false);
            return (int)result.ModifiedCount;
        }

        /// <summary>
        /// Ensures all employees have mandatory government contributions (SSS, PhilHealth, Pag-IBIG) marked as checked.
        /// </summary>
        public async Task<int> FixGovContributionsAsync()
        {
            if (_employees == null) return 0;

            var filter = Builders<Employee>.Filter.And(
                Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                Builders<Employee>.Filter.Or(
                    Builders<Employee>.Filter.Eq(e => e.HasSSS, false),
                    Builders<Employee>.Filter.Eq(e => e.HasPhilHealth, false),
                    Builders<Employee>.Filter.Eq(e => e.HasPagIbig, false)
                )
            );

            var update = Builders<Employee>.Update
                .Set(e => e.HasSSS, true)
                .Set(e => e.HasPhilHealth, true)
                .Set(e => e.HasPagIbig, true);

            var result = await _employees.UpdateManyAsync(filter, update).ConfigureAwait(false);
            return (int)result.ModifiedCount;
        }

        /// <summary>
        /// Fixes employees with missing Gender data (which causes counts to show as 0 on the dashboard).
        /// </summary>
        public async Task<int> FixMissingGendersAsync()
        {
            if (_employees == null) return 0;

            var filter = Builders<Employee>.Filter.Or(
                Builders<Employee>.Filter.Eq(e => e.Gender, null),
                Builders<Employee>.Filter.Eq(e => e.Gender, "")
            );

            var employeesToFix = await _employees.Find(filter).ToListAsync();
            if (!employeesToFix.Any()) return 0;

            var femaleNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { 
                "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", 
                "Karen", "Nancy", "Lisa", "Betty", "Margaret", "Sandra", "Ashley", "Kimberly", "Emily", 
                "Donna", "Michelle", "Dorothy", "Carol", "Amanda", "Melissa", "Deborah", "Princess", "Maria", "Maria Raye" 
            };

            var models = new List<WriteModel<Employee>>();
            for (int i = 0; i < employeesToFix.Count; i++)
            {
                var emp = employeesToFix[i];
                string gender = "Male";
                var firstName = emp.FirstName?.Split(' ')[0] ?? "";
                if (femaleNames.Contains(firstName) || i % 2 != 0) 
                {
                    gender = "Female";
                }

                models.Add(new UpdateOneModel<Employee>(
                    Builders<Employee>.Filter.Eq(e => e.Id, emp.Id), 
                    Builders<Employee>.Update.Set(e => e.Gender, gender)
                ));
            }

            var result = await _employees.BulkWriteAsync(models);
            return (int)result.ModifiedCount;
        }

        /// <summary>
        /// Generates random government account numbers for employees who don't have them yet.
        /// </summary>
        public async Task<int> FixMissingGovNumbersAsync()
        {
            if (_employees == null) return 0;

            var filter = Builders<Employee>.Filter.And(
                Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                Builders<Employee>.Filter.Or(
                    Builders<Employee>.Filter.Eq(e => e.SSSNumber, null),
                    Builders<Employee>.Filter.Eq(e => e.SSSNumber, ""),
                    Builders<Employee>.Filter.Eq(e => e.PhilHealthNumber, null),
                    Builders<Employee>.Filter.Eq(e => e.PhilHealthNumber, ""),
                    Builders<Employee>.Filter.Eq(e => e.PagIbigNumber, null),
                    Builders<Employee>.Filter.Eq(e => e.PagIbigNumber, "")
                )
            );

            var employeesToFix = await _employees.Find(filter).ToListAsync();
            if (!employeesToFix.Any()) return 0;

            var models = new List<WriteModel<Employee>>();
            foreach (var emp in employeesToFix)
            {
                GenerateGovNumbers(emp);
                var update = Builders<Employee>.Update
                    .Set(e => e.SSSNumber, emp.SSSNumber)
                    .Set(e => e.PhilHealthNumber, emp.PhilHealthNumber)
                    .Set(e => e.PagIbigNumber, emp.PagIbigNumber)
                    .Set(e => e.HasSSS, true)
                    .Set(e => e.HasPhilHealth, true)
                    .Set(e => e.HasPagIbig, true);

                models.Add(new UpdateOneModel<Employee>(Builders<Employee>.Filter.Eq(e => e.Id, emp.Id), update));
            }

            var result = await _employees.BulkWriteAsync(models);
            return (int)result.ModifiedCount;
        }

        /// <summary>
        /// Moves all employees who were previously marked as IsActive = false from Employees to ResignedEmployees collection.
        /// </summary>
        public async Task<int> MigrateLegacyResignedEmployeesAsync()
        {
            if (_employees == null || _resignedEmployees == null) return 0;
            
            try
            {
                var filter = Builders<Employee>.Filter.Eq(e => e.IsActive, false);
                var legacyResigned = await _employees.Find(filter).ToListAsync();
                
                int migratedCount = 0;
                if (legacyResigned.Count > 0)
                {
                    await _resignedEmployees.InsertManyAsync(legacyResigned);
                    
                    var idsToDelete = legacyResigned.Select(e => e.Id).ToList();
                    var deleteFilter = Builders<Employee>.Filter.In(e => e.Id, idsToDelete);
                    var result = await _employees.DeleteManyAsync(deleteFilter);
                    
                    migratedCount = (int)result.DeletedCount;
                    System.Diagnostics.Debug.WriteLine($"[MigrateLegacyResignedEmployeesAsync] Migrated {migratedCount} legacy resigned employees.");
                }
                
                return migratedCount;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error migrating legacy resigned employees: {ex.Message}");
                return 0;
            }
        }

        /// <summary>
        /// Syncs missing personal data (Age, BirthDate, Gender, Address, ContactNo) from Applicant collection to Employees collection.
        /// Fixes legacy records where this data was not copied during the hiring process.
        /// </summary>
        public async Task<int> SyncMissingEmployeeDataAsync()
        {
            if (_employees == null) return 0;

            var filter = Builders<Employee>.Filter.And(
                Builders<Employee>.Filter.Eq(e => e.IsActive, true),
                Builders<Employee>.Filter.Or(
                    Builders<Employee>.Filter.Eq(e => e.Age, null),
                    Builders<Employee>.Filter.Eq(e => e.BirthDate, null),
                    Builders<Employee>.Filter.Eq(e => e.Address, null),
                    Builders<Employee>.Filter.Eq(e => e.Address, ""),
                    Builders<Employee>.Filter.Eq(e => e.Gender, null),
                    Builders<Employee>.Filter.Eq(e => e.Gender, "")
                )
            );

            var employeesToSync = await _employees.Find(filter).ToListAsync();
            var applicantService = new ApplicantService();
            int updatedCount = 0;

            foreach (var emp in employeesToSync)
            {
                if (string.IsNullOrEmpty(emp.ApplicantId)) continue;

                var applicant = await applicantService.GetApplicantByIdAsync(emp.ApplicantId);
                if (applicant == null) continue;

                var update = Builders<Employee>.Update
                    .Set(e => e.Age, emp.Age ?? applicant.Age)
                    .Set(e => e.BirthDate, emp.BirthDate ?? applicant.BirthDate)
                    .Set(e => e.Gender, string.IsNullOrEmpty(emp.Gender) ? applicant.Gender : emp.Gender)
                    .Set(e => e.Address, string.IsNullOrEmpty(emp.Address) ? applicant.Address : emp.Address)
                    .Set(e => e.ContactNo, string.IsNullOrEmpty(emp.ContactNo) ? applicant.ContactNo : emp.ContactNo);

                var result = await _employees.UpdateOneAsync(e => e.Id == emp.Id, update);
                if (result.ModifiedCount > 0) updatedCount++;
            }
            return updatedCount;
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
                    SSSNumber = employee.SSSNumber,
                    PhilHealthNumber = employee.PhilHealthNumber,
                    PagIbigNumber = employee.PagIbigNumber,
                    BaseSalary = employee.BaseSalary,
                    IsActive = true
                };

                // Auto-generate missing gov numbers
                GenerateGovNumbers(employeeRecord);

                if (_employees != null)
                {
                    await _employees.InsertOneAsync(employeeRecord);
                }

                // 2. CREATE USER LOGIN ACCOUNT (CREDENTIALS ONLY)
                var user = new User
                {
                    Username = employee.Email,
                    Password = PasswordHelper.HashPasswordComplete(empId),
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

        // Resign employee (move to ResignedEmployees collection, mark inactive for speed)
        public async Task<bool> ResignEmployeeAsync(string id)
        {
            if (_employees == null || _resignedEmployees == null) return false;
            try
            {
                // Update status to Approved if it's not already (for HR immediate resignations)
                var update = Builders<Employee>.Update.Set(e => e.ResignationStatus, "Approved");
                await _employees.UpdateOneAsync(e => e.Id == id, update);

                // Atomically find and remove the employee in one single fast operation (Reduces 2 network calls to 1)
                var emp = await _employees.FindOneAndDeleteAsync(e => e.Id == id);
                if (emp != null)
                {
                    emp.IsActive = false;
                    emp.ResignationStatus = "Approved";
                    
                    // Concurrently insert into Resigned and update the Users login account
                    var task1 = _resignedEmployees.InsertOneAsync(emp);
                    var task2 = _users.UpdateOneAsync(u => u.EmployeeId == emp.EmployeeId, Builders<User>.Update.Set(u => u.IsActive, false));
                    
                    await Task.WhenAll(task1, task2);
                    
                    return true;
                }
                return false;
            }
            catch { return false; }
        }

        public async Task<bool> RequestResignationAsync(string id, string reason = "")
        {
            if (_employees == null) return false;
            try
            {
                var update = Builders<Employee>.Update
                    .Set(e => e.ResignationStatus, "Pending")
                    .Set(e => e.ResignationDate, DateTime.UtcNow)
                    .Set(e => e.ResignationReason, reason);
                var result = await _employees.UpdateOneAsync(e => e.Id == id, update);
                return result.ModifiedCount > 0;
            }
            catch { return false; }
        }

        public async Task<List<Employee>> GetPendingResignationsAsync()
        {
            if (_employees == null) return new List<Employee>();
            try
            {
                return await _employees.Find(e => e.IsActive && e.ResignationStatus == "Pending")
                    .ToListAsync();
            }
            catch { return new List<Employee>(); }
        }

        // Rehire employee (move back to active Employees collection, mark active)
        public async Task<bool> RehireEmployeeAsync(string id)
        {
            if (_employees == null || _resignedEmployees == null) return false;
            try
            {
                // Look for the employee in the ResignedEmployees collection
                var emp = await _resignedEmployees.Find(e => e.Id == id).FirstOrDefaultAsync()
                          .ConfigureAwait(false);

                if (emp != null)
                {
                    // Reset to active state and clear resignation fields
                    emp.IsActive = true;
                    emp.ResignationStatus = "None";
                    emp.ResignationDate = null;
                    // Keep original HiredDate — only update if a new hire date is needed
                    // emp.HiredDate = DateTime.UtcNow;

                    // Use ReplaceOneAsync with upsert=true to avoid duplicate key errors
                    // if the document was ever partially in the Employees collection
                    var replaceResult = await _employees.ReplaceOneAsync(
                        e => e.Id == id,
                        emp,
                        new MongoDB.Driver.ReplaceOptions { IsUpsert = true }
                    ).ConfigureAwait(false);

                    // Remove from ResignedEmployees
                    var deleteResult = await _resignedEmployees.DeleteOneAsync(e => e.Id == id)
                        .ConfigureAwait(false);

                    // Reactivate user login account
                    if (_users != null)
                    {
                        await _users.UpdateOneAsync(
                            u => u.EmployeeId == emp.EmployeeId,
                            Builders<User>.Update.Set(u => u.IsActive, true)
                        ).ConfigureAwait(false);
                    }

                    System.Diagnostics.Debug.WriteLine($"[RehireEmployeeAsync] Rehired '{emp.FullName}' — upserted: {replaceResult.IsAcknowledged}, deleted from resigned: {deleteResult.DeletedCount}");
                    return replaceResult.IsAcknowledged;
                }
                else
                {
                    // Fallback: employee may still be in the active collection but marked inactive
                    System.Diagnostics.Debug.WriteLine($"[RehireEmployeeAsync] Employee {id} not in ResignedEmployees — trying active collection fallback.");
                    var update = Builders<Employee>.Update
                        .Set(e => e.IsActive, true)
                        .Set(e => e.ResignationStatus, "None")
                        .Set(e => e.ResignationDate, (DateTime?)null);

                    var result = await _employees.UpdateOneAsync(e => e.Id == id, update)
                        .ConfigureAwait(false);

                    var emp2 = await GetEmployeeByIdAsync(id).ConfigureAwait(false);
                    if (emp2 != null && _users != null)
                    {
                        await _users.UpdateOneAsync(
                            u => u.EmployeeId == emp2.EmployeeId,
                            Builders<User>.Update.Set(u => u.IsActive, true)
                        ).ConfigureAwait(false);
                    }

                    System.Diagnostics.Debug.WriteLine($"[RehireEmployeeAsync] Fallback update result: ModifiedCount={result.ModifiedCount}");
                    return result.ModifiedCount > 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[RehireEmployeeAsync] ERROR: {ex.GetType().Name} — {ex.Message}");
                if (ex.InnerException != null)
                    System.Diagnostics.Debug.WriteLine($"[RehireEmployeeAsync] Inner: {ex.InnerException.Message}");
                return false;
            }
        }

        // Generic field update helper (used by CancelResignation, etc.)
        public async Task<bool> UpdateEmployeeFieldsAsync(string id, MongoDB.Driver.UpdateDefinition<Employee> update)
        {
            if (_employees == null) return false;
            try
            {
                var result = await _employees.UpdateOneAsync(e => e.Id == id, update).ConfigureAwait(false);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UpdateEmployeeFieldsAsync] ERROR: {ex.Message}");
                return false;
            }
        }

        // Update employee department (deploy to another department)
        public async Task<bool> UpdateEmployeeDepartmentAsync(string id, string newDepartment)
        {
            if (_employees == null) return false;
            try
            {
                var update = Builders<Employee>.Update.Set(e => e.Department, newDepartment);
                var result = await _employees.UpdateOneAsync(e => e.Id == id, update);
                return result.ModifiedCount > 0;
            }
            catch { return false; }
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
                    ContractType = employee.ContractType ?? "Probationary",
                    SSSNumber = employee.SSSNumber,
                    PhilHealthNumber = employee.PhilHealthNumber,
                    PagIbigNumber = employee.PagIbigNumber,
                    BaseSalary = employee.BaseSalary,
                    IsActive = true
                };

                // Auto-generate missing gov numbers
                GenerateGovNumbers(employeeRecord);

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
                    Password = PasswordHelper.HashPasswordComplete(empId),
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

        // Get all resigned/inactive employees from the ResignedEmployees collection
        public async Task<List<Employee>> GetAllResignedEmployeesAsync()
        {
            try
            {
                if (_resignedEmployees == null) return new List<Employee>();
                var resigned = await _resignedEmployees.Find(_ => true)
                    .ToListAsync()
                    .ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"[GetAllResignedEmployeesAsync] Retrieved {resigned.Count} resigned employees.");
                return resigned;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetAllResignedEmployeesAsync] Error: {ex.Message}");
                return new List<Employee>();
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
                    var employee = await _employees.Find(e => e.IsActive && e.Email == email).FirstOrDefaultAsync().ConfigureAwait(false);
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
                    var employee = await _employees.Find(e => e.IsActive && e.ApplicantId == applicantId).FirstOrDefaultAsync().ConfigureAwait(false);
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
                        .ToListAsync()
                        .ConfigureAwait(false);
                    
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
                var employees = await GetAllEmployeesAsync().ConfigureAwait(false);
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
                // Find all active and resigned employees to determine the highest existing number
                var allEmployees = await _employees.Find(_ => true).ToListAsync().ConfigureAwait(false);
                var resignedList = _resignedEmployees != null ? await _resignedEmployees.Find(_ => true).ToListAsync().ConfigureAwait(false) : new List<Employee>();
                
                int maxNumber = 0;
                var combinedList = allEmployees.Concat(resignedList);

                foreach (var emp in combinedList)
                {
                    if (!string.IsNullOrEmpty(emp.EmployeeId) && emp.EmployeeId.StartsWith("SHE-"))
                    {
                        var parts = emp.EmployeeId.Split('-');
                        if (parts.Length == 2 && int.TryParse(parts[1], out int number))
                        {
                            if (number > maxNumber) maxNumber = number;
                        }
                    }
                }

                int nextNumber = maxNumber + 1;
                return $"SHE-{nextNumber:D3}"; // Formats as SHE-001, SHE-002, etc.
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating employee ID: {ex.Message}");
                // Fallback to a random number if lookup fails
                return $"SHE-{new Random().Next(100, 999)}";
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
                    var employee = await _employees.Find(e => e.Id == id && e.IsActive).FirstOrDefaultAsync().ConfigureAwait(false);
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
                    var employee = await _employees.Find(e => e.EmployeeId == employeeId && e.IsActive).FirstOrDefaultAsync().ConfigureAwait(false);
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

        /// <summary>
        /// Backwards-compatible wrapper for legacy calls named GetEmployeeByEmployeeIdAsync.
        /// Internally forwards to GetByEmployeeIdAsync.
        /// </summary>
        public Task<Employee> GetEmployeeByEmployeeIdAsync(string employeeId)
        {
            return GetByEmployeeIdAsync(employeeId);
        }

        public async Task<bool> UpdateEmployeeAsync(string id, Employee employee)
        {
            try
            {
                // PRIMARY: Update Employees collection
                if (_employees != null)
                {
                    var existingEmployee = await _employees.Find(e => e.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
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
                        existingEmployee.BaseSalary = employee.BaseSalary;

                        var filter = Builders<Employee>.Filter.Eq(e => e.Id, id);
                        var result = await _employees.ReplaceOneAsync(filter, existingEmployee).ConfigureAwait(false);
                        
                        // Also update email in Users collection if it changed (for login)
                        if (result.ModifiedCount > 0)
                        {
                            var userFilter = Builders<User>.Filter.Eq(u => u.EmployeeId, existingEmployee.EmployeeId);
                            var userUpdate = Builders<User>.Update
                                .Set(u => u.Email, employee.Email)
                                .Set(u => u.Username, employee.Email);
                            await _users.UpdateOneAsync(userFilter, userUpdate).ConfigureAwait(false);
                            System.Diagnostics.Debug.WriteLine($"? Employee updated in Employees collection: {id}");
                        }
                        
                        return result.ModifiedCount > 0;
                    }
                }

                // FALLBACK: Update Users collection (legacy)
                var existingUser = await _users.Find(u => u.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
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
                var result2 = await _users.ReplaceOneAsync(userFilter2, existingUser).ConfigureAwait(false);
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
                    var emp = await _employees.Find(e => e.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
                    if (emp != null)
                    {
                        emp.IsActive = false;
                        if (_resignedEmployees != null) {
                            await _resignedEmployees.InsertOneAsync(emp).ConfigureAwait(false);
                        }
                        var empResult = await _employees.DeleteOneAsync(e => e.Id == id).ConfigureAwait(false);
                        if (empResult.DeletedCount > 0)
                        {
                            success = true;
                            System.Diagnostics.Debug.WriteLine($"? Employee moved to ResignedEmployees collection: {id}");
                        }
                    }
                }

                // Also deactivate in Users collection
                var userFilter = Builders<User>.Filter.Eq(u => u.Id, id);
                var userUpdate = Builders<User>.Update.Set(u => u.IsActive, false);
                var userResult = await _users.UpdateOneAsync(userFilter, userUpdate).ConfigureAwait(false);
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

        /// <summary>
        /// PERMANENTLY deletes an employee and their associated user account from the system.
        /// </summary>
        public async Task<bool> HardDeleteEmployeeAsync(string id)
        {
            try
            {
                if (_employees == null) return false;

                var employee = await _employees.Find(e => e.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
                if (employee == null && _resignedEmployees != null) {
                    employee = await _resignedEmployees.Find(e => e.Id == id).FirstOrDefaultAsync().ConfigureAwait(false);
                }

                if (employee == null) return false;

                // 1. Delete from Employees collection or ResignedEmployees
                var empResult = await _employees.DeleteOneAsync(e => e.Id == id);
                if (empResult.DeletedCount == 0 && _resignedEmployees != null) {
                    empResult = await _resignedEmployees.DeleteOneAsync(e => e.Id == id);
                }
                
                // 2. Delete from Users collection (linked by EmployeeId)
                await _users.DeleteOneAsync(u => u.EmployeeId == employee.EmployeeId);

                return empResult.DeletedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error hard-deleting employee: {ex.Message}");
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
        // Get organizational chart data
        public async Task<object> GetOrgChartDataAsync()
        {
            try
            {
                var allEmployees = await GetAllEmployeesAsync();
                var president = allEmployees.FirstOrDefault(e => e.Role == "President" || e.Department == "Executive");
                var superAdmin = allEmployees.FirstOrDefault(e => e.EmployeeId == "SHE-001");

                if (president == null && superAdmin != null) president = superAdmin; // Fallback

                // Build Hierarchy
                var root = new OrgNode { 
                    id = president?.EmployeeId ?? "ROOT", 
                    name = president?.FullName ?? "The President", 
                    title = president?.Role ?? "President",
                    className = "president-node"
                };

                var superAdminNode = new OrgNode { 
                    id = superAdmin?.EmployeeId ?? "SA-001", 
                    name = superAdmin?.FullName ?? "Super Admin", 
                    title = "Super Admin / HR Manager",
                    className = "superadmin-node"
                };

                if (president != null && president.EmployeeId != superAdmin?.EmployeeId)
                {
                    root.children.Add(superAdminNode);
                }
                else
                {
                    // If president is superadmin or president missing, use superadmin as root
                    root = superAdminNode;
                }

                var coreDepartments = new[] { "Human Resources", "Finance/Accounting", "Inventory", "Marketing", "Operations", "R&D" };

                // Get normal employees excluding President and SuperAdmin
                var normalEmployees = allEmployees
                    .Where(e => e.EmployeeId != superAdmin?.EmployeeId && e.EmployeeId != president?.EmployeeId)
                    .ToList();

                // Build exactly 6 macro-department nodes
                foreach (var macroDept in coreDepartments)
                {
                    // Map employees to this macro department
                    var deptEmps = normalEmployees.Where(e => 
                    {
                        var role = (e.Role ?? "").ToLower();
                        var dept = (e.Department ?? "").ToLower();
                        var combined = role + " " + dept;

                        string mapped = "Operations"; // default
                        
                        if (combined.Contains("payroll") || combined.Contains("hr ") || combined.StartsWith("hr") || combined.Contains("human resource") || combined.Contains("recruitment") || combined.Contains("training")) 
                            mapped = "Human Resources";
                        else if (combined.Contains("qc ") || combined.StartsWith("qc") || combined.Contains("quality") || combined.Contains("it ") || combined.StartsWith("it") || combined.Contains("network") || combined.Contains("system admin") || combined.Contains("operation") || combined.Contains("production")) 
                            mapped = "Operations";
                        else if (combined.Contains("sales") || combined.Contains("business dev") || combined.Contains("account exec") || combined.Contains("customer") || combined.Contains("call center") || combined.Contains("marketing") || combined.Contains("brand") || combined.Contains("content")) 
                            mapped = "Marketing";
                        else if (combined.Contains("finance") || combined.Contains("accountant") || combined.Contains("accounting")) 
                            mapped = "Finance/Accounting";
                        else if (combined.Contains("inventory") || combined.Contains("warehouse") || combined.Contains("storekeeper") || combined.Contains("logistic") || combined.Contains("supply")) 
                            mapped = "Inventory";
                        else if (combined.Contains("r&d") || combined.Contains("research") || combined.Contains("lab") || combined.Contains("product dev") || combined.Contains("scientist")) 
                            mapped = "R&D";

                        return mapped == macroDept;
                    }).ToList();

                    // Create the exactly 6 department nodes for the 3rd row
                    var deptNode = new OrgNode { 
                        id = "dept-" + macroDept.Replace(" ", "").Replace("/", ""), 
                        name = macroDept, 
                        title = "Department", 
                        className = "manager-node" 
                    };

                    // Add all employees in this department under this deptNode
                    foreach (var emp in deptEmps)
                    {
                        bool isManager = emp.Role.ToLower().Contains("manager") || emp.Role.ToLower().Contains("supervisor") || emp.Role.ToLower().Contains("lead");
                        deptNode.children.Add(new OrgNode {
                            id = emp.EmployeeId,
                            name = emp.FullName,
                            title = emp.Role,
                            className = isManager ? "manager-node" : "employee-node"
                        });
                    }
                    
                    superAdminNode.children.Add(deptNode);
                }

                return root;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error building org chart: {ex.Message}");
                return null;
            }
        }

        public class OrgNode
        {
            public string id { get; set; }
            public string name { get; set; }
            public string title { get; set; }
            public string className { get; set; }
            public List<OrgNode> children { get; set; } = new List<OrgNode>();
        }
    }
}

