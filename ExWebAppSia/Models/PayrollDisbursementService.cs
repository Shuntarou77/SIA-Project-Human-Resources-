using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayrollDisbursementService - Handles payroll approval and disbursement (Function 6.3)
    /// </summary>
    public class PayrollDisbursementService
    {
        private readonly PayRunService _payRunService;
        private readonly EmployeeService _employeeService;

  public PayrollDisbursementService()
        {
            _payRunService = new PayRunService();
    _employeeService = new EmployeeService();
    }

        // ========== FUNCTION 6.3.1: PAYROLL REVIEW & ADJUSTMENT ==========

        /// <summary>
        /// Adjust payroll item manually (bonuses, one-time deductions, etc.)
     /// </summary>
        public async Task<bool> AdjustPayrollItemAsync(
            string payRunId,
         string employeeId,
    decimal? newGrossSalary = null,
    decimal? newDeductions = null,
            decimal? bonusAmount = null,
         decimal? oneTimeDeduction = null,
            string remarks = null)
        {
      try
     {
     var payRun = await _payRunService.GetByIdAsync(payRunId);
                if (payRun == null || !payRun.CanEdit) return false;

                var item = payRun.Items.FirstOrDefault(i => i.EmployeeId == employeeId);
      if (item == null) return false;

 // Track original values
           var originalGross = item.GrossSalary;
 var originalDeductions = item.TotalDeductions;

     // Apply adjustments
                if (newGrossSalary.HasValue)
  {
           item.GrossSalary = newGrossSalary.Value;
    }

          if (bonusAmount.HasValue && bonusAmount.Value > 0)
     {
         item.Bonuses += bonusAmount.Value;
       item.GrossSalary += bonusAmount.Value;
    }

         if (newDeductions.HasValue)
       {
        item.TotalDeductions = newDeductions.Value;
    }

   if (oneTimeDeduction.HasValue && oneTimeDeduction.Value > 0)
     {
        item.OtherDeductions += oneTimeDeduction.Value;
           item.TotalDeductions += oneTimeDeduction.Value;
    }

         // Recalculate net salary
      item.NetSalary = item.GrossSalary - item.TotalDeductions;

     // Track adjustment
      item.IsManuallyAdjusted = true;
      var adjustmentLog = $"[{DateTime.UtcNow:yyyy-MM-dd HH:mm}] ";
       adjustmentLog += $"Gross: {originalGross:C} ? {item.GrossSalary:C}, ";
         adjustmentLog += $"Deductions: {originalDeductions:C} ? {item.TotalDeductions:C}";
       if (!string.IsNullOrEmpty(remarks))
      {
              adjustmentLog += $" | {remarks}";
        }
          
            item.AdjustmentHistory = string.IsNullOrEmpty(item.AdjustmentHistory) 
    ? adjustmentLog 
     : item.AdjustmentHistory + "\n" + adjustmentLog;

     item.Remarks = remarks;

         // Save changes
     payRun.RecalculateTotals();
      return await _payRunService.UpdateAsync(payRunId, payRun);
            }
            catch (Exception ex)
            {
     System.Diagnostics.Debug.WriteLine($"Error adjusting payroll item: {ex.Message}");
   return false;
      }
        }

        /// <summary>
        /// Bulk adjust payroll (e.g., company-wide bonus)
      /// </summary>
   public async Task<bool> BulkAdjustPayrollAsync(
  string payRunId,
            decimal? bonusPercentage = null,
         decimal? flatBonus = null,
            string department = null,
         string remarks = null)
        {
            try
            {
         var payRun = await _payRunService.GetByIdAsync(payRunId);
       if (payRun == null || !payRun.CanEdit) return false;

         var itemsToAdjust = payRun.Items.AsEnumerable();
   
          // Filter by department if specified
    if (!string.IsNullOrEmpty(department))
           {
      itemsToAdjust = itemsToAdjust.Where(i => i.Department == department);
           }

       foreach (var item in itemsToAdjust)
            {
           decimal bonus = 0;
    
              if (bonusPercentage.HasValue)
         {
        bonus = item.BasicSalary * (bonusPercentage.Value / 100);
       }
            else if (flatBonus.HasValue)
        {
      bonus = flatBonus.Value;
             }

   if (bonus > 0)
            {
       item.Bonuses += bonus;
          item.GrossSalary += bonus;
                item.NetSalary = item.GrossSalary - item.TotalDeductions;
     item.IsManuallyAdjusted = true;
      item.Remarks = remarks ?? "Bulk bonus adjustment";
         }
          }

 payRun.RecalculateTotals();
   return await _payRunService.UpdateAsync(payRunId, payRun);
            }
     catch (Exception ex)
            {
          System.Diagnostics.Debug.WriteLine($"Error bulk adjusting payroll: {ex.Message}");
     return false;
          }
        }

// ========== FUNCTION 6.3.2: APPROVAL WORKFLOW ==========

    /// <summary>
        /// Submit payroll for review
        /// </summary>
  public async Task<bool> SubmitForReviewAsync(string payRunId, string submittedBy)
        {
        try
    {
            var payRun = await _payRunService.GetByIdAsync(payRunId);
           if (payRun == null) return false;

             payRun.Status = "Reviewed";
          payRun.ReviewedBy = submittedBy;
     payRun.ReviewedAt = DateTime.UtcNow;
     payRun.UpdatedAt = DateTime.UtcNow;

    return await _payRunService.UpdateAsync(payRunId, payRun);
            }
     catch (Exception ex)
    {
       System.Diagnostics.Debug.WriteLine($"Error submitting for review: {ex.Message}");
       return false;
    }
        }

        /// <summary>
        /// Approve payroll (Function 6.3.2)
 /// </summary>
  public async Task<bool> ApprovePayrollAsync(
     string payRunId, 
            string approvedBy, 
       string comments = null)
      {
         try
            {
                return await _payRunService.ApproveAsync(payRunId, approvedBy, comments);
     }
            catch (Exception ex)
 {
                System.Diagnostics.Debug.WriteLine($"Error approving payroll: {ex.Message}");
                return false;
            }
        }

        /// <summary>
  /// Reject payroll (send back to draft)
    /// </summary>
        public async Task<bool> RejectPayrollAsync(
 string payRunId, 
        string rejectedBy, 
            string reason)
        {
     try
 {
          var payRun = await _payRunService.GetByIdAsync(payRunId);
                if (payRun == null) return false;

            payRun.Status = "Draft";
              payRun.ApprovalComments = $"Rejected by {rejectedBy}: {reason}";
payRun.UpdatedAt = DateTime.UtcNow;

     return await _payRunService.UpdateAsync(payRunId, payRun);
            }
   catch (Exception ex)
            {
      System.Diagnostics.Debug.WriteLine($"Error rejecting payroll: {ex.Message}");
  return false;
     }
        }

        // ========== FUNCTION 6.3.3: STATUS UPDATE ==========

        /// <summary>
     /// Update employee payment status after disbursement
 /// </summary>
   public async Task<bool> UpdateEmployeePaymentStatusAsync(string payRunId)
    {
       try
     {
    var payRun = await _payRunService.GetByIdAsync(payRunId);
    if (payRun == null || payRun.Status != "Approved") return false;

          // Update each employee's payment status
         int successCount = 0;
     foreach (var item in payRun.Items)
                {
var updated = await _employeeService.UpdatePaymentStatusAsync(
          item.EmployeeId, 
               "Paid", 
        payRun.PayDate,
   payRunId
            );
         
          if (updated)
            {
   successCount++;
    }
        }

                System.Diagnostics.Debug.WriteLine($"Payment status updated for {successCount}/{payRun.TotalEmployees} employees");
     
        return successCount > 0;
     }
 catch (Exception ex)
 {
        System.Diagnostics.Debug.WriteLine($"Error updating payment status: {ex.Message}");
        return false;
       }
 }

  // ========== FUNCTION 6.3.4: BANK TRANSFER FILE GENERATION ==========

        /// <summary>
        /// Generate CSV bank transfer file
     /// </summary>
        public async Task<BankTransferFile> GenerateBankTransferFileAsync(
    string payRunId, 
     string format = "CSV")
  {
     try
     {
     var payRun = await _payRunService.GetByIdAsync(payRunId);
     if (payRun == null || payRun.Status != "Approved")
        {
throw new Exception("PayRun must be approved before generating bank file");
           }

    var records = new List<BankTransferRecord>();

  // Generate records for each employee
       foreach (var item in payRun.Items)
     {
    var employee = await _employeeService.GetUserByEmployeeIdAsync(item.EmployeeId);
        
     if (employee == null) continue;

                // Check if employee has bank account
           if (string.IsNullOrEmpty(employee.BankAccountNumber))
                    {
         System.Diagnostics.Debug.WriteLine($"Warning: Employee {item.EmployeeId} has no bank account configured");
continue;
       }
      
    records.Add(new BankTransferRecord
      {
          EmployeeId = item.EmployeeId,
     EmployeeName = item.EmployeeName,
 BankAccountNumber = employee.BankAccountNumber,
     BankName = employee.BankName ?? "N/A",
           Amount = item.NetSalary,
   Currency = "PHP",
     Reference = $"{payRun.PayRunNumber}-{item.EmployeeId}"
       });
    }

        if (records.Count == 0)
            {
   throw new Exception("No employees with valid bank accounts found in this pay run");
      }

 // Generate file content based on format
         string fileContent;
      if (format.ToUpper() == "CSV")
     {
   fileContent = GenerateCSV(records, payRun);
         }
       else if (format.ToUpper() == "BSF")
    {
fileContent = GenerateBSF(records, payRun);
 }
   else if (format.ToUpper() == "TXT")
      {
             fileContent = GenerateTXT(records, payRun);
   }
  else
    {
    fileContent = GenerateCSV(records, payRun);
     }

     return new BankTransferFile
       {
 FileName = $"PayRun_{payRun.PayRunNumber}_{DateTime.Now:yyyyMMdd}.{format.ToLower()}",
 GeneratedDate = DateTime.UtcNow,
   TotalRecords = records.Count,
   TotalAmount = records.Sum(r => r.Amount),
   FileContent = fileContent,
       Format = format
      };
   }
       catch (Exception ex)
       {
    System.Diagnostics.Debug.WriteLine($"Error generating bank transfer file: {ex.Message}");
          throw;
   }
      }

      /// <summary>
        /// Generate CSV format
        /// </summary>
        private string GenerateCSV(List<BankTransferRecord> records, PayRun payRun)
        {
       var sb = new StringBuilder();
            
            // Header
      sb.AppendLine("Employee ID,Employee Name,Bank Account,Bank Name,Amount,Currency,Reference");
            
        // Data rows
   foreach (var record in records)
            {
   sb.AppendLine($"{record.EmployeeId},{record.EmployeeName},{record.BankAccountNumber}," +
         $"{record.BankName},{record.Amount:F2},{record.Currency},{record.Reference}");
         }
            
    // Footer
  sb.AppendLine($"TOTAL,,,,,{records.Sum(r => r.Amount):F2},");
      sb.AppendLine($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
   sb.AppendLine($"Pay Period: {payRun.PayPeriodDisplay}");
            
            return sb.ToString();
        }

        /// <summary>
        /// Generate BSF (Bank Standard Format) - Common in Philippines
        /// </summary>
        private string GenerateBSF(List<BankTransferRecord> records, PayRun payRun)
        {
        var sb = new StringBuilder();
            
      // Header record
    sb.AppendLine($"H|{DateTime.Now:yyyyMMdd}|{records.Count}|{records.Sum(r => r.Amount):F2}|{payRun.PayRunNumber}");

          // Detail records
            foreach (var record in records)
            {
 sb.AppendLine($"D|{record.EmployeeId}|{record.EmployeeName}|" +
             $"{record.BankAccountNumber}|{record.Amount:F2}|{record.Reference}");
  }
       
   // Trailer record
 sb.AppendLine($"T|{records.Count}|{records.Sum(r => r.Amount):F2}");
          
       return sb.ToString();
 }

    /// <summary>
    /// Generate TXT format (Fixed width)
        /// </summary>
        private string GenerateTXT(List<BankTransferRecord> records, PayRun payRun)
        {
      var sb = new StringBuilder();
      
      sb.AppendLine("BANK TRANSFER FILE");
            sb.AppendLine($"Pay Run: {payRun.PayRunNumber}");
            sb.AppendLine($"Period: {payRun.PayPeriodDisplay}");
 sb.AppendLine($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine(new string('=', 80));
     sb.AppendLine();
            
     // Column headers
            sb.AppendLine($"{"Emp ID",-12} {"Employee Name",-30} {"Account",-20} {"Amount",15}");
 sb.AppendLine(new string('-', 80));
            
            // Data rows
            foreach (var record in records)
            {
     sb.AppendLine($"{record.EmployeeId,-12} {record.EmployeeName,-30} " +
         $"{record.BankAccountNumber,-20} {record.Amount,15:N2}");
          }
      
      // Footer
        sb.AppendLine(new string('-', 80));
            sb.AppendLine($"{"TOTAL",-64} {records.Sum(r => r.Amount),15:N2}");
          sb.AppendLine();
     sb.AppendLine($"Total Employees: {records.Count}");
     
        return sb.ToString();
      }

        /// <summary>
      /// Send payroll to finance system (Function 6.3.3)
        /// </summary>
     public async Task<bool> SendToFinanceAsync(string payRunId)
{
            try
         {
                var success = await _payRunService.MarkSentToFinanceAsync(payRunId);
 
       if (success)
       {
     // Update employee payment status
       await UpdateEmployeePaymentStatusAsync(payRunId);
           
  System.Diagnostics.Debug.WriteLine($"PayRun {payRunId} sent to finance successfully");
       }
     
                return success;
  }
     catch (Exception ex)
            {
    System.Diagnostics.Debug.WriteLine($"Error sending to finance: {ex.Message}");
                return false;
            }
        }

      // ========== HELPER METHODS ==========

        /// <summary>
        /// Get payroll summary for review
        /// </summary>
     public async Task<Dictionary<string, object>> GetPayrollSummaryAsync(string payRunId)
        {
            try
   {
       var payRun = await _payRunService.GetByIdAsync(payRunId);
                if (payRun == null) return null;

     var summary = new Dictionary<string, object>
{
           ["PayRunNumber"] = payRun.PayRunNumber,
         ["PayPeriod"] = payRun.PayPeriodDisplay,
       ["TotalEmployees"] = payRun.TotalEmployees,
        ["TotalGross"] = payRun.TotalGrossSalary,
       ["TotalDeductions"] = payRun.TotalDeductions,
          ["TotalNet"] = payRun.TotalNetSalary,
    ["Status"] = payRun.Status,
 ["CanEdit"] = payRun.CanEdit,
         ["CanApprove"] = payRun.CanApprove,
        ["CanSendToFinance"] = payRun.CanSendToFinance,
       ["CreatedBy"] = payRun.CreatedBy,
       ["CreatedAt"] = payRun.CreatedAt,
       ["ApprovedBy"] = payRun.ApprovedBy,
    ["ApprovedAt"] = payRun.ApprovedAt,
           ["DepartmentBreakdown"] = payRun.Items
              .GroupBy(i => i.Department)
             .ToDictionary(g => g.Key, g => new
         {
      Count = g.Count(),
TotalGross = g.Sum(i => i.GrossSalary),
 TotalNet = g.Sum(i => i.NetSalary)
       })
      };

 return summary;
      }
      catch (Exception ex)
            {
       System.Diagnostics.Debug.WriteLine($"Error getting payroll summary: {ex.Message}");
return null;
            }
        }
    }
}
