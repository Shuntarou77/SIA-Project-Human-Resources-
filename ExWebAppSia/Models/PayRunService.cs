using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayRunService - Manages PayRun CRUD operations in MongoDB
    /// </summary>
    public class PayRunService
    {
        private readonly IMongoCollection<PayRun> _collection;

    public PayRunService()
        {
    var database = MongoDBHelper.GetDatabase();
 _collection = database.GetCollection<PayRun>("PayRuns");
      }

   // ========== CREATE ==========

    /// <summary>
    /// Save a new pay run to database
        /// </summary>
      public async Task<PayRun> CreateAsync(PayRun payRun)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[PayRunService] CreateAsync START");
                System.Diagnostics.Debug.WriteLine($"[PayRunService] PayRunNumber: {payRun.PayRunNumber}, Employees: {payRun.TotalEmployees}");
                
                payRun.CreatedAt = DateTime.UtcNow;
       payRun.UpdatedAt = DateTime.UtcNow;
     payRun.IsActive = true;

                System.Diagnostics.Debug.WriteLine("[PayRunService] Metadata set, inserting to MongoDB...");

                // ?? FIX: Add 30-second timeout to prevent infinite hang
                using (var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(30)))
                {
                    try
                    {
                        await _collection.InsertOneAsync(payRun, null, cts.Token).ConfigureAwait(false);
                        System.Diagnostics.Debug.WriteLine($"[PayRunService] SUCCESS - Inserted PayRun: {payRun.Id}");
                    }
                    catch (OperationCanceledException)
                    {
                        System.Diagnostics.Debug.WriteLine("[PayRunService] TIMEOUT: Insert took >30 seconds");
                        throw new TimeoutException("Database insert timed out after 30 seconds. MongoDB may be slow or unreachable.");
                    }
                    catch (Exception ex) when (ex.GetType().FullName.Contains("Mongo"))
                    {
                        System.Diagnostics.Debug.WriteLine($"[PayRunService] MongoDB ERROR: {ex.Message}");
                        throw new Exception($"MongoDB operation failed: {ex.Message}");
                    }
                }
                
                System.Diagnostics.Debug.WriteLine("[PayRunService] CreateAsync COMPLETE");
            return payRun;
            }
            catch (TimeoutException tex)
            {
                System.Diagnostics.Debug.WriteLine($"[PayRunService] TIMEOUT EXCEPTION: {tex.Message}");
                throw;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PayRunService] ERROR: {ex.GetType().Name} - {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[PayRunService] Stack: {ex.StackTrace}");
                throw;
            }
      }

      // ========== READ ==========

        /// <summary>
  /// Get pay run by ID
        /// </summary>
 public async Task<PayRun> GetByIdAsync(string id)
     {
      var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
  return await _collection.Find(filter).FirstOrDefaultAsync();
     }

   /// <summary>
      /// Get all pay runs (latest first)
        /// </summary>
 public async Task<List<PayRun>> GetAllAsync()
        {
     return await _collection.Find(_ => true)
    .SortByDescending(p => p.CreatedAt)
                .ToListAsync();
  }

        /// <summary>
        /// Get pay runs by status
  /// </summary>
 public async Task<List<PayRun>> GetByStatusAsync(string status)
        {
       var filter = Builders<PayRun>.Filter.Eq(p => p.Status, status);
            return await _collection.Find(filter)
         .SortByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

      /// <summary>
     /// Get pay runs for a specific date range
        /// </summary>
        public async Task<List<PayRun>> GetByDateRangeAsync(DateTime startDate, DateTime endDate)
        {
      var filter = Builders<PayRun>.Filter.And(
              Builders<PayRun>.Filter.Gte(p => p.PayPeriodStart, startDate),
    Builders<PayRun>.Filter.Lte(p => p.PayPeriodEnd, endDate)
 );

      return await _collection.Find(filter)
       .SortByDescending(p => p.PayPeriodStart)
      .ToListAsync();
        }

      /// <summary>
        /// Get latest pay run
        /// </summary>
        public async Task<PayRun> GetLatestAsync()
        {
            return await _collection.Find(_ => true)
                .SortByDescending(p => p.CreatedAt)
                .FirstOrDefaultAsync();
        }

        /// <summary>
        /// Get latest approved pay run for a specific employee
        /// </summary>
        public async Task<PayRun> GetLatestPayRunForEmployeeAsync(string employeeId)
        {
            var filter = Builders<PayRun>.Filter.And(
                Builders<PayRun>.Filter.Eq(p => p.Status, "Approved"),
                Builders<PayRun>.Filter.ElemMatch(p => p.Items, i => i.EmployeeId == employeeId)
            );

            return await _collection.Find(filter)
                .SortByDescending(p => p.CreatedAt)
                .FirstOrDefaultAsync();
        }

        /// <summary>
        /// Check if pay run exists for period
        /// </summary>
        public async Task<bool> ExistsForPeriodAsync(DateTime startDate, DateTime endDate)
      {
      var filter = Builders<PayRun>.Filter.And(
                Builders<PayRun>.Filter.Eq(p => p.PayPeriodStart, startDate),
             Builders<PayRun>.Filter.Eq(p => p.PayPeriodEnd, endDate)
            );

  var count = await _collection.CountDocumentsAsync(filter);
            return count > 0;
        }

        // ========== UPDATE ==========

    /// <summary>
        /// Update entire pay run
        /// </summary>
        public async Task<bool> UpdateAsync(string id, PayRun payRun)
        {
          payRun.UpdatedAt = DateTime.UtcNow;

      var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
          var result = await _collection.ReplaceOneAsync(filter, payRun);
        return result.ModifiedCount > 0;
        }

        /// <summary>
        /// Update pay run status
   /// </summary>
 public async Task<bool> UpdateStatusAsync(string id, string status)
        {
    var update = Builders<PayRun>.Update
     .Set(p => p.Status, status)
      .Set(p => p.UpdatedAt, DateTime.UtcNow);

   var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
    var result = await _collection.UpdateOneAsync(filter, update);
            return result.ModifiedCount > 0;
        }

        /// <summary>
        /// Approve pay run (Function 6.3.2) and send payslips to employees
        /// </summary>
        public async Task<bool> ApproveAsync(string id, string approvedBy, string comments = null)
        {
            try
            {
                // First, update the pay run status
                var update = Builders<PayRun>.Update
                    .Set(p => p.Status, "Approved")
                    .Set(p => p.ApprovedBy, approvedBy)
                    .Set(p => p.ApprovedAt, DateTime.UtcNow)
                    .Set(p => p.ApprovalComments, comments)
                    .Set(p => p.IsFinalized, true)
                    .Set(p => p.UpdatedAt, DateTime.UtcNow);

                var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
                var result = await _collection.UpdateOneAsync(filter, update);

                if (result.ModifiedCount > 0)
                {
                    // Get the approved pay run
                    var payRun = await GetByIdAsync(id);
                    
                    if (payRun != null && payRun.Items != null)
                    {
                        // Send payslips to all employees in background to prevent timeout
                        _ = Task.Run(async () => await SendPayslipsToEmployeesAsync(payRun));
                    }
                }

                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in ApproveAsync: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Send payslip PDFs to all employees in the approved pay run
        /// </summary>
        private async Task SendPayslipsToEmployeesAsync(PayRun payRun)
        {
            try
            {
                var emailService = new EmailService();
                var pdfService = new PayslipPdfService();
                var employeeService = new EmployeeService();

                System.Diagnostics.Debug.WriteLine($"[PayRunService] Sending payslips for {payRun.Items.Count} employees");

                foreach (var payrollItem in payRun.Items)
                {
                    try
                    {
                        // Get employee details (email)
                        // payrollItem.EmployeeId is the MongoDB _id, so we use GetEmployeeByIdAsync
                        var employee = await employeeService.GetEmployeeByIdAsync(payrollItem.EmployeeId);

                        if (employee == null)
                        {
                            System.Diagnostics.Debug.WriteLine($"⚠ Employee not found by ID: {payrollItem.EmployeeId}");
                            // Try fallback: maybe it IS an employee number?
                            employee = await employeeService.GetByEmployeeIdAsync(payrollItem.EmployeeId);
                        }

                        if (employee == null)
                        {
                            System.Diagnostics.Debug.WriteLine($"⚠ Employee lookup failed for: {payrollItem.EmployeeId}");
                            continue;
                        }

                        // Generate PDF
                        var htmlContent = pdfService.GenerateEnhancedPayslipHtml(payRun, payrollItem);
                        var pdfBytes = pdfService.GeneratePdfFromHtml(htmlContent);

                        // Create filename
                        var fileName = $"SheEssentials_Payslip_{payrollItem.EmployeeId}_{payRun.PayPeriodStart:yyyyMMdd}-{payRun.PayPeriodEnd:yyyyMMdd}.pdf";

                        // Send email
                        var emailSent = await emailService.SendPayslipEmailAsync(
                            employee.Email,
                            payrollItem.EmployeeName,
                            payRun.PayPeriodDisplay,
                            pdfBytes,
                            fileName
                        );

                        if (emailSent)
                        {
                            System.Diagnostics.Debug.WriteLine($"[PayRunService] ✓ Payslip sent to {payrollItem.EmployeeName} ({employee.Email})");
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"[PayRunService] ✗ Failed to send payslip to {payrollItem.EmployeeName}");
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"[PayRunService] Error sending payslip to {payrollItem.EmployeeName}: {ex.Message}");
                        // Continue with next employee even if one fails
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[PayRunService] Finished sending payslips");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PayRunService] Error in SendPayslipsToEmployeesAsync: {ex.Message}");
                // Don't throw - we don't want email failures to prevent approval
            }
        }

        /// <summary>
        /// Mark as sent to finance (Function 6.3.3)
        /// </summary>
public async Task<bool> MarkSentToFinanceAsync(string id)
        {
      var update = Builders<PayRun>.Update
         .Set(p => p.IsSentToFinance, true)
    .Set(p => p.Status, "Calculated")
 .Set(p => p.UpdatedAt, DateTime.UtcNow);

            var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
       var result = await _collection.UpdateOneAsync(filter, update);
            return result.ModifiedCount > 0;
        }
        
        /// <summary>
        /// Mark a pay run as paid
        /// </summary>
        public async Task<bool> MarkAsPaidAsync(string payRunId, string paidBy)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"[MarkAsPaidAsync] Marking pay run {payRunId} as paid by {paidBy}");
                
                var filter = Builders<PayRun>.Filter.Eq(p => p.Id, payRunId);
                var update = Builders<PayRun>.Update
                    .Set(p => p.IsPaid, true)
                    .Set(p => p.PaidBy, paidBy)
                    .Set(p => p.PaidAt, DateTime.UtcNow)
                    .Set(p => p.Status, "Paid")
                    .Set(p => p.UpdatedAt, DateTime.UtcNow);

                var result = await _collection.UpdateOneAsync(filter, update);
                
                System.Diagnostics.Debug.WriteLine($"[MarkAsPaidAsync] Modified count: {result.ModifiedCount}");
                
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[MarkAsPaidAsync] Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[MarkAsPaidAsync] Stack: {ex.StackTrace}");
                return false;
            }
        }
        /// <summary>
    /// Update individual payroll item
     /// </summary>
        public async Task<bool> UpdatePayrollItemAsync(string payRunId, string employeeId, PayrollItem updatedItem)
        {
       var payRun = await GetByIdAsync(payRunId);
   if (payRun == null) return false;

    var index = payRun.Items.FindIndex(i => i.EmployeeId == employeeId);
            if (index < 0) return false;

            payRun.Items[index] = updatedItem;
  payRun.RecalculateTotals();

            return await UpdateAsync(payRunId, payRun);
   }

      // ========== DELETE ==========

        /// <summary>
        /// Soft delete (deactivate)
      /// </summary>
   public async Task<bool> DeactivateAsync(string id)
        {
     var update = Builders<PayRun>.Update
        .Set(p => p.IsActive, false)
          .Set(p => p.UpdatedAt, DateTime.UtcNow);

            var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
            var result = await _collection.UpdateOneAsync(filter, update);
  return result.ModifiedCount > 0;
        }

      /// <summary>
        /// Hard delete (permanent removal)
        /// </summary>
 public async Task<bool> DeleteAsync(string id)
  {
   var filter = Builders<PayRun>.Filter.Eq(p => p.Id, id);
       var result = await _collection.DeleteOneAsync(filter);
   return result.DeletedCount > 0;
        }

    // ========== STATISTICS ==========

    /// <summary>
     /// Get total pay runs count
        /// </summary>
        public async Task<long> GetTotalCountAsync()
        {
  return await _collection.CountDocumentsAsync(_ => true);
        }

  /// <summary>
        /// Get total net salary paid (all approved pay runs)
        /// </summary>
   public async Task<decimal> GetTotalNetSalaryPaidAsync()
        {
    var approvedRuns = await GetByStatusAsync("Approved");
   return approvedRuns.Sum(p => p.TotalNetSalary);
      }

  /// <summary>
        /// Get total net salary for a year
        /// </summary>
        public async Task<decimal> GetYearlyTotalAsync(int year)
        {
            var startDate = new DateTime(year, 1, 1);
         var endDate = new DateTime(year, 12, 31);

         var payRuns = await GetByDateRangeAsync(startDate, endDate);
            return payRuns.Where(p => p.Status == "Approved").Sum(p => p.TotalNetSalary);
        }

        /// <summary>
 /// Get monthly summary
  /// </summary>
        public async Task<Dictionary<string, decimal>> GetMonthlySummaryAsync(int year)
        {
        var startDate = new DateTime(year, 1, 1);
       var endDate = new DateTime(year, 12, 31);

    var payRuns = await GetByDateRangeAsync(startDate, endDate);

  return payRuns
                .Where(p => p.Status == "Approved")
      .GroupBy(p => p.PayPeriodStart.ToString("yyyy-MM"))
       .ToDictionary(
        g => g.Key,
   g => g.Sum(p => p.TotalNetSalary)
 );
}
    }
}
