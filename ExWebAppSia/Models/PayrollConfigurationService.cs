using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// Service for managing Payroll Configuration (Function 6.1.1 & 6.1.2)
    /// Handles CRUD operations for employee salary setup and deductions
    /// </summary>
    public class PayrollConfigurationService
    {
        private readonly IMongoCollection<PayrollConfiguration> _collection;

        public PayrollConfigurationService()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Constructor START");
                
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Getting database...");
                var database = MongoDBHelper.GetDatabase();
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Database obtained");
                
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Getting collection...");
                _collection = database.GetCollection<PayrollConfiguration>("PayrollConfigurations");
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Collection obtained");
                
                System.Diagnostics.Debug.WriteLine("[PayrollConfigurationService] Constructor COMPLETE");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PayrollConfigurationService] Constructor ERROR: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[PayrollConfigurationService] Stack: {ex.StackTrace}");
                throw;
            }
        }

        // ========== CREATE ==========

        /// <summary>
        /// Create new payroll configuration for an employee (6.1.1)
        /// </summary>
        public async Task<PayrollConfiguration> CreateAsync(PayrollConfiguration config)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[CreateAsync] START");
                System.Diagnostics.Debug.WriteLine($"[CreateAsync] Creating for employee: {config.EmployeeName} ({config.EmployeeId})");
                
                // 1. Set metadata
                config.CreatedAt = DateTime.UtcNow;
                config.UpdatedAt = DateTime.UtcNow;
                config.IsActive = true;
                System.Diagnostics.Debug.WriteLine("[CreateAsync] Metadata set");

                // 2. Create cancellation token with 10-second timeout
                using (var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(10)))
                {
                    System.Diagnostics.Debug.WriteLine("[CreateAsync] Starting MongoDB insert (10s timeout)...");
                    
                    try
                    {
                        await _collection.InsertOneAsync(config, null, cts.Token).ConfigureAwait(false);
                        System.Diagnostics.Debug.WriteLine($"[CreateAsync] SUCCESS - Inserted with ID: {config.Id}");
                    }
                    catch (OperationCanceledException)
                    {
                        System.Diagnostics.Debug.WriteLine("[CreateAsync] TIMEOUT: MongoDB insert took >10 seconds");
                        throw new TimeoutException("MongoDB insert operation timed out after 10 seconds. Check MongoDB Atlas connection and IP whitelist.");
                    }
                    catch (Exception ex) when (ex.GetType().FullName.Contains("MongoWriteException"))
                    {
                        System.Diagnostics.Debug.WriteLine($"[CreateAsync] WRITE ERROR: {ex.Message}");
                        throw new Exception($"MongoDB write failed: {ex.Message}");
                    }
                    catch (Exception ex) when (ex.GetType().FullName.Contains("Mongo"))
                    {
                        System.Diagnostics.Debug.WriteLine($"[CreateAsync] MONGODB ERROR: {ex.Message}");
                        throw new Exception($"MongoDB operation failed: {ex.Message}");
                    }
                }
                
                System.Diagnostics.Debug.WriteLine("[CreateAsync] COMPLETE");
                return config;
            }
            catch (TimeoutException tex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateAsync] TIMEOUT EXCEPTION: {tex.Message}");
                throw; // Re-throw to be caught by web method
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateAsync] ERROR: {ex.GetType().Name} - {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[CreateAsync] Stack: {ex.StackTrace}");
                throw;
            }
        }

     /// <summary>
    /// Bulk create configurations for multiple employees
        /// </summary>
        public async Task<bool> CreateBulkAsync(List<PayrollConfiguration> configs)
  {
            try
 {
      foreach (var config in configs)
   {
     config.CreatedAt = DateTime.UtcNow;
               config.UpdatedAt = DateTime.UtcNow;
            config.IsActive = true;
  }

  await _collection.InsertManyAsync(configs);
     return true;
      }
            catch
            {
       return false;
            }
        }

        // ========== READ ==========

        /// <summary>
 /// Get payroll configuration by Employee ID (MongoDB ObjectId from Users._id)
        /// </summary>
     public async Task<PayrollConfiguration> GetByEmployeeIdAsync(string employeeId)
        {
            var filter = Builders<PayrollConfiguration>.Filter.And(
      Builders<PayrollConfiguration>.Filter.Eq(c => c.EmployeeId, employeeId),
 Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true)
          );

            return await _collection.Find(filter)
    .SortByDescending(c => c.EffectiveDate)
         .FirstOrDefaultAsync();
        }

  /// <summary>
        /// Get all active payroll configurations
        /// </summary>
        public async Task<List<PayrollConfiguration>> GetAllActiveAsync()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[GetAllActiveAsync] START");
                
                System.Diagnostics.Debug.WriteLine("[GetAllActiveAsync] Building filter...");
                var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true);
                
                System.Diagnostics.Debug.WriteLine("[GetAllActiveAsync] Executing Find query with timeout...");
                
                // Use FindAsync with proper options
                var findOptions = new FindOptions<PayrollConfiguration, PayrollConfiguration>
                {
                    MaxTime = TimeSpan.FromSeconds(5), // 5-second server timeout
                    Sort = Builders<PayrollConfiguration>.Sort.Ascending(c => c.EmployeeName)
                };
                
                var cursor = await _collection.FindAsync(filter, findOptions).ConfigureAwait(false);
                
                System.Diagnostics.Debug.WriteLine("[GetAllActiveAsync] Cursor obtained, reading results...");
                
                var result = await cursor.ToListAsync().ConfigureAwait(false);
                
                System.Diagnostics.Debug.WriteLine($"[GetAllActiveAsync] Query returned {result?.Count ?? 0} documents");
                
                return result ?? new List<PayrollConfiguration>();
            }
            catch (TimeoutException ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetAllActiveAsync] TIMEOUT: {ex.Message}");
                return new List<PayrollConfiguration>();
            }
            catch (Exception ex) when (ex.GetType().Name.Contains("Mongo"))
            {
                System.Diagnostics.Debug.WriteLine($"[GetAllActiveAsync] MongoDB error: {ex.Message}");
                // Collection might not exist yet - return empty list
                return new List<PayrollConfiguration>();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetAllActiveAsync] ERROR: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Get configurations by department
        /// </summary>
        public async Task<List<PayrollConfiguration>> GetByDepartmentAsync(string department)
    {
            var filter = Builders<PayrollConfiguration>.Filter.And(
    Builders<PayrollConfiguration>.Filter.Eq(c => c.Department, department),
    Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true)
 );

            return await _collection.Find(filter)
              .SortBy(c => c.EmployeeName)
           .ToListAsync();
        }

        /// <summary>
     /// Get configuration by ID
    /// </summary>
        public async Task<PayrollConfiguration> GetByIdAsync(string id)
        {
         var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.Id, id);
     return await _collection.Find(filter).FirstOrDefaultAsync();
    }

        /// <summary>
        /// Check if employee has payroll configuration
   /// </summary>
        public async Task<bool> ExistsAsync(string employeeId)
        {
       var filter = Builders<PayrollConfiguration>.Filter.And(
          Builders<PayrollConfiguration>.Filter.Eq(c => c.EmployeeId, employeeId),
             Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true)
      );

         var count = await _collection.CountDocumentsAsync(filter);
        return count > 0;
        }

      // ========== UPDATE ==========

  /// <summary>
     /// Update payroll configuration (6.1.1 & 6.1.2)
        /// </summary>
        public async Task<bool> UpdateAsync(string id, PayrollConfiguration config)
   {
            config.UpdatedAt = DateTime.UtcNow;

            var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.Id, id);
          var update = Builders<PayrollConfiguration>.Update
      // Salary Components
           .Set(c => c.BasicSalary, config.BasicSalary)
  .Set(c => c.HousingAllowance, config.HousingAllowance)
            .Set(c => c.TransportAllowance, config.TransportAllowance)
   .Set(c => c.MealAllowance, config.MealAllowance)
    .Set(c => c.OtherAllowances, config.OtherAllowances)
     // Overtime Rates
      .Set(c => c.RegularOvertimeRate, config.RegularOvertimeRate)
             .Set(c => c.HolidayOvertimeRate, config.HolidayOvertimeRate)
    .Set(c => c.NightDifferentialRate, config.NightDifferentialRate)
         // Statutory Deductions
      .Set(c => c.SSSContribution, config.SSSContribution)
 .Set(c => c.PhilHealthContribution, config.PhilHealthContribution)
    .Set(c => c.PagIbigContribution, config.PagIbigContribution)
         .Set(c => c.WithholdingTax, config.WithholdingTax)
    // Loan Deductions
       .Set(c => c.SSSLoan, config.SSSLoan)
         .Set(c => c.PagIbigLoan, config.PagIbigLoan)
    .Set(c => c.CompanyLoan, config.CompanyLoan)
         .Set(c => c.OtherDeductions, config.OtherDeductions)
        // Penalty Rates
           .Set(c => c.AbsencePenaltyRate, config.AbsencePenaltyRate)
 .Set(c => c.LatePenaltyRate, config.LatePenaltyRate)
    // Metadata
      .Set(c => c.EffectiveDate, config.EffectiveDate)
                .Set(c => c.UpdatedAt, config.UpdatedAt);

     var result = await _collection.UpdateOneAsync(filter, update);
            return result.ModifiedCount > 0;
        }

        /// <summary>
/// Update only salary components (6.1.1)
    /// </summary>
 public async Task<bool> UpdateSalaryAsync(string employeeId, decimal basicSalary,
          decimal housingAllowance, decimal transportAllowance, decimal mealAllowance)
  {
    var filter = Builders<PayrollConfiguration>.Filter.And(
                Builders<PayrollConfiguration>.Filter.Eq(c => c.EmployeeId, employeeId),
                Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true)
            );

          var update = Builders<PayrollConfiguration>.Update
         .Set(c => c.BasicSalary, basicSalary)
  .Set(c => c.HousingAllowance, housingAllowance)
         .Set(c => c.TransportAllowance, transportAllowance)
    .Set(c => c.MealAllowance, mealAllowance)
 .Set(c => c.UpdatedAt, DateTime.UtcNow);

            var result = await _collection.UpdateOneAsync(filter, update);
       return result.ModifiedCount > 0;
      }

        /// <summary>
        /// Update only deductions (6.1.2)
        /// </summary>
  public async Task<bool> UpdateDeductionsAsync(string employeeId,
            decimal sss, decimal philHealth, decimal pagIbig, decimal tax,
            decimal sssLoan, decimal pagIbigLoan, decimal companyLoan)
  {
   var filter = Builders<PayrollConfiguration>.Filter.And(
 Builders<PayrollConfiguration>.Filter.Eq(c => c.EmployeeId, employeeId),
      Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true)
     );

var update = Builders<PayrollConfiguration>.Update
                .Set(c => c.SSSContribution, sss)
       .Set(c => c.PhilHealthContribution, philHealth)
        .Set(c => c.PagIbigContribution, pagIbig)
     .Set(c => c.WithholdingTax, tax)
    .Set(c => c.SSSLoan, sssLoan)
   .Set(c => c.PagIbigLoan, pagIbigLoan)
    .Set(c => c.CompanyLoan, companyLoan)
     .Set(c => c.UpdatedAt, DateTime.UtcNow);

       var result = await _collection.UpdateOneAsync(filter, update);
            return result.ModifiedCount > 0;
        }

        // ========== DELETE ==========

        /// <summary>
        /// Soft delete (deactivate) configuration
        /// </summary>
        public async Task<bool> DeactivateAsync(string id)
  {
  var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.Id, id);
            var update = Builders<PayrollConfiguration>.Update
    .Set(c => c.IsActive, false)
                .Set(c => c.UpdatedAt, DateTime.UtcNow);

            var result = await _collection.UpdateOneAsync(filter, update);
return result.ModifiedCount > 0;
        }

  /// <summary>
        /// Hard delete (permanent removal)
        /// </summary>
      public async Task<bool> DeleteAsync(string id)
        {
   var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.Id, id);
    var result = await _collection.DeleteOneAsync(filter);
            return result.DeletedCount > 0;
        }

        // ========== STATISTICS ==========

        /// <summary>
        /// Get total configured employees count
        /// </summary>
        public async Task<long> GetTotalConfiguredEmployeesAsync()
    {
            var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true);
   return await _collection.CountDocumentsAsync(filter);
        }

        /// <summary>
        /// Get average basic salary by department
  /// </summary>
        public async Task<Dictionary<string, decimal>> GetAverageSalaryByDepartmentAsync()
        {
      var configs = await GetAllActiveAsync();
            return configs
         .GroupBy(c => c.Department)
      .ToDictionary(
          g => g.Key,
         g => g.Average(c => c.BasicSalary)
     );
 }

   /// <summary>
      /// Get employees without payroll configuration
        /// FIXED: Now compares against User._id (MongoDB ObjectId) instead of User.EmployeeId
     /// </summary>
        public async Task<List<string>> GetEmployeesWithoutConfigAsync()
        {
 // Get all employees
   var employeeService = new EmployeeService();
            var allEmployees = await employeeService.GetAllEmployeesAsync();

   // Get configured employee IDs (these are MongoDB ObjectIds)
   var configs = await GetAllActiveAsync();
            var configuredIds = configs.Select(c => c.EmployeeId).ToList();

      // Return employees without config - compare against User.Id (MongoDB ObjectId), NOT User.EmployeeId
     return allEmployees
     .Where(e => !configuredIds.Contains(e.Id)) // FIXED: Changed from e.EmployeeId to e.Id
    .Select(e => e.Id) // FIXED: Return User.Id (MongoDB ObjectId)
  .ToList();
        }

        /// <summary>
        /// Get employees WITH payroll configuration (employee IDs)
   /// Returns list of MongoDB ObjectIds for employees that have configurations
        /// </summary>
     public async Task<List<string>> GetEmployeesWithConfigAsync()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[GetEmployeesWithConfigAsync] START");
                
                var findOptions = new FindOptions<PayrollConfiguration, PayrollConfiguration>
                {
                    MaxTime = TimeSpan.FromSeconds(5)
                };
                
                var filter = Builders<PayrollConfiguration>.Filter.Eq(c => c.IsActive, true);
                
                var cursor = await _collection.FindAsync(filter, findOptions).ConfigureAwait(false);
                
                var configs = await cursor.ToListAsync().ConfigureAwait(false);
                
                System.Diagnostics.Debug.WriteLine($"[GetEmployeesWithConfigAsync] Found {configs?.Count ?? 0} configs");
                
                var employeeIds = configs?.Select(c => c.EmployeeId).Distinct().ToList() ?? new List<string>();
                
                System.Diagnostics.Debug.WriteLine($"[GetEmployeesWithConfigAsync] Returning {employeeIds.Count} unique employee IDs");
                
                return employeeIds;
            }
            catch (TimeoutException ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetEmployeesWithConfigAsync] TIMEOUT: {ex.Message}");
                return new List<string>();
            }
            catch (Exception ex) when (ex.GetType().Name.Contains("Mongo"))
            {
                System.Diagnostics.Debug.WriteLine($"[GetEmployeesWithConfigAsync] MongoDB error: {ex.Message}");
                return new List<string>();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetEmployeesWithConfigAsync] ERROR: {ex.Message}");
                throw;
            }
        }
    }
}
