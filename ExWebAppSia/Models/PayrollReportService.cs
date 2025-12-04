using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayrollReportService - Generate payroll reports and audit trails (Function 6.6)
    /// </summary>
    public class PayrollReportService
    {
    private readonly PayRunService _payRunService;
 private readonly PayrollConfigurationService _configService;
        private readonly EmployeeService _employeeService;
      private readonly FinanceIntegrationService _financeService;

        public PayrollReportService()
        {
         _payRunService = new PayRunService();
 _configService = new PayrollConfigurationService();
   _employeeService = new EmployeeService();
            _financeService = new FinanceIntegrationService();
        }

      // ========== FUNCTION 6.6: PAYROLL REPORTS ==========

        /// <summary>
        /// Generate Monthly Payroll Summary Report
        /// </summary>
      public async Task<MonthlyPayrollSummary> GenerateMonthlyPayrollSummaryAsync(int year, int month)
    {
        try
    {
       var startDate = new DateTime(year, month, 1);
           var endDate = startDate.AddMonths(1).AddDays(-1);

              // Get all pay runs for the month
         var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);
    var approvedRuns = payRuns.Where(p => p.Status == "Approved").ToList();

      if (!approvedRuns.Any())
  {
         return new MonthlyPayrollSummary
          {
             Year = year,
      Month = month,
             MonthName = startDate.ToString("MMMM"),
      TotalPayRuns = 0,
   Message = "No approved payroll for this month"
    };
      }

     // Calculate totals
      var summary = new MonthlyPayrollSummary
             {
     Year = year,
           Month = month,
     MonthName = startDate.ToString("MMMM"),
              TotalPayRuns = approvedRuns.Count,
   TotalEmployees = approvedRuns.Sum(p => p.TotalEmployees),
           TotalGrossSalary = approvedRuns.Sum(p => p.TotalGrossSalary),
          TotalDeductions = approvedRuns.Sum(p => p.TotalDeductions),
     TotalNetSalary = approvedRuns.Sum(p => p.TotalNetSalary),
          TotalOvertimePay = approvedRuns.Sum(p => p.TotalOvertimePay),
         TotalStatutoryDeductions = approvedRuns.Sum(p => p.TotalStatutoryDeductions),
        TotalLoanDeductions = approvedRuns.Sum(p => p.TotalLoanDeductions)
    };

     // Calculate breakdown by deduction type
     var allItems = approvedRuns.SelectMany(p => p.Items).ToList();
    summary.TotalSSSDeductions = allItems.Sum(i => i.SSSDeduction);
        summary.TotalPhilHealthDeductions = allItems.Sum(i => i.PhilHealthDeduction);
             summary.TotalPagIbigDeductions = allItems.Sum(i => i.PagIbigDeduction);
        summary.TotalTaxDeductions = allItems.Sum(i => i.WithholdingTax);

   // Department breakdown
           summary.DepartmentBreakdown = allItems
  .GroupBy(i => i.Department)
      .Select(g => new DepartmentSalarySummary
        {
      Department = g.Key,
       EmployeeCount = g.Count(),
      TotalGross = g.Sum(i => i.GrossSalary),
        TotalDeductions = g.Sum(i => i.TotalDeductions),
          TotalNet = g.Sum(i => i.NetSalary),
             AverageSalary = g.Average(i => i.GrossSalary)
         })
 .OrderByDescending(d => d.TotalGross)
       .ToList();

         // Pay run details
       summary.PayRunDetails = approvedRuns
      .Select(p => new PayRunSummaryLine
       {
  PayRunNumber = p.PayRunNumber,
             PayPeriod = p.PayPeriodDisplay,
     PayDate = p.PayDate,
        EmployeeCount = p.TotalEmployees,
         GrossSalary = p.TotalGrossSalary,
        NetSalary = p.TotalNetSalary
    })
        .ToList();

      summary.GeneratedDate = DateTime.UtcNow;

return summary;
            }
            catch (Exception ex)
   {
                System.Diagnostics.Debug.WriteLine($"Error generating monthly summary: {ex.Message}");
      throw;
}
        }

        /// <summary>
   /// Generate Department-wise Salary Cost Report
    /// </summary>
        public async Task<List<DepartmentCostReport>> GenerateDepartmentCostReportAsync(DateTime startDate, DateTime endDate)
        {
 try
            {
    var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);
    var approvedRuns = payRuns.Where(p => p.Status == "Approved").ToList();

             if (!approvedRuns.Any())
          {
           return new List<DepartmentCostReport>();
      }

      var allItems = approvedRuns.SelectMany(p => p.Items).ToList();

                var report = allItems
     .GroupBy(i => i.Department)
      .Select(g => new DepartmentCostReport
     {
       Department = g.Key,
           PeriodStart = startDate,
     PeriodEnd = endDate,
 TotalEmployees = g.Select(i => i.EmployeeId).Distinct().Count(),
      TotalBasicSalary = g.Sum(i => i.ProratedBasicSalary),
       TotalAllowances = g.Sum(i => i.Allowances),
     TotalOvertimePay = g.Sum(i => i.OvertimePay),
         TotalBonuses = g.Sum(i => i.Bonuses),
    TotalGrossSalary = g.Sum(i => i.GrossSalary),
     TotalDeductions = g.Sum(i => i.TotalDeductions),
          TotalNetSalary = g.Sum(i => i.NetSalary),
   AverageSalaryPerEmployee = g.Average(i => i.GrossSalary),
      HighestSalary = g.Max(i => i.GrossSalary),
      LowestSalary = g.Min(i => i.GrossSalary),
       GeneratedDate = DateTime.UtcNow
              })
       .OrderByDescending(r => r.TotalGrossSalary)
          .ToList();

      return report;
         }
            catch (Exception ex)
         {
    System.Diagnostics.Debug.WriteLine($"Error generating department cost report: {ex.Message}");
     throw;
            }
        }

        /// <summary>
        /// Generate Statutory Deduction Report (SSS, PhilHealth, Pag-IBIG)
        /// </summary>
        public async Task<StatutoryDeductionReport> GenerateStatutoryDeductionReportAsync(int year, int month)
        {
            try
            {
     var startDate = new DateTime(year, month, 1);
       var endDate = startDate.AddMonths(1).AddDays(-1);

        var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);
     var approvedRuns = payRuns.Where(p => p.Status == "Approved").ToList();

      if (!approvedRuns.Any())
                {
           return new StatutoryDeductionReport
            {
    Year = year,
             Month = month,
         MonthName = startDate.ToString("MMMM"),
        Message = "No approved payroll for this month"
      };
    }

           var allItems = approvedRuns.SelectMany(p => p.Items).ToList();

      var report = new StatutoryDeductionReport
           {
        Year = year,
       Month = month,
    MonthName = startDate.ToString("MMMM"),
      TotalEmployees = allItems.Select(i => i.EmployeeId).Distinct().Count(),

         // SSS Summary
        TotalSSSContributions = allItems.Sum(i => i.SSSDeduction),
      TotalSSSLoanDeductions = allItems.Sum(i => i.SSSLoan),
         TotalSSSRemittance = allItems.Sum(i => i.SSSDeduction + i.SSSLoan),

    // PhilHealth Summary
        TotalPhilHealthContributions = allItems.Sum(i => i.PhilHealthDeduction),

              // Pag-IBIG Summary
    TotalPagIbigContributions = allItems.Sum(i => i.PagIbigDeduction),
           TotalPagIbigLoanDeductions = allItems.Sum(i => i.PagIbigLoan),
      TotalPagIbigRemittance = allItems.Sum(i => i.PagIbigDeduction + i.PagIbigLoan),

        // Total Statutory
        TotalStatutoryDeductions = allItems.Sum(i => i.TotalStatutoryDeductions),

  GeneratedDate = DateTime.UtcNow
     };

     // Employee-level details
                report.EmployeeDetails = allItems
  .GroupBy(i => i.EmployeeId)
              .Select(g => new EmployeeStatutoryDetail
      {
       EmployeeId = g.Key,
   EmployeeName = g.First().EmployeeName,
        Department = g.First().Department,
      SSSContribution = g.Sum(i => i.SSSDeduction),
         PhilHealthContribution = g.Sum(i => i.PhilHealthDeduction),
           PagIbigContribution = g.Sum(i => i.PagIbigDeduction),
                  SSSLoan = g.Sum(i => i.SSSLoan),
PagIbigLoan = g.Sum(i => i.PagIbigLoan),
               TotalStatutory = g.Sum(i => i.TotalStatutoryDeductions)
    })
           .OrderBy(e => e.EmployeeName)
     .ToList();

   return report;
  }
     catch (Exception ex)
            {
    System.Diagnostics.Debug.WriteLine($"Error generating statutory deduction report: {ex.Message}");
 throw;
   }
  }

     /// <summary>
 /// Generate Year-End Tax Report (BIR Compliance)
/// </summary>
        public async Task<YearEndTaxReport> GenerateYearEndTaxReportAsync(int year)
     {
         try
            {
     var startDate = new DateTime(year, 1, 1);
     var endDate = new DateTime(year, 12, 31);

     var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);
     var approvedRuns = payRuns.Where(p => p.Status == "Approved").ToList();

                if (!approvedRuns.Any())
       {
    return new YearEndTaxReport
                    {
Year = year,
            Message = "No approved payroll for this year"
    };
       }

                var allItems = approvedRuns.SelectMany(p => p.Items).ToList();

         var report = new YearEndTaxReport
 {
       Year = year,
      TotalEmployees = allItems.Select(i => i.EmployeeId).Distinct().Count(),
       TotalGrossCompensation = allItems.Sum(i => i.GrossSalary),
TotalTaxWithheld = allItems.Sum(i => i.WithholdingTax),
               TotalNetCompensation = allItems.Sum(i => i.NetSalary),
    GeneratedDate = DateTime.UtcNow
       };

// Employee annual summary (for BIR Form 2316)
             report.EmployeeAnnualSummary = allItems
        .GroupBy(i => i.EmployeeId)
        .Select(g => new EmployeeAnnualTaxSummary
        {
 EmployeeId = g.Key,
      EmployeeName = g.First().EmployeeName,
   Department = g.First().Department,
   Position = g.First().Position,
   
        // Annual totals
               TotalGrossCompensation = g.Sum(i => i.GrossSalary),
  TotalBasicSalary = g.Sum(i => i.ProratedBasicSalary),
        TotalAllowances = g.Sum(i => i.Allowances),
       TotalBonuses = g.Sum(i => i.Bonuses),
           TotalOvertimePay = g.Sum(i => i.OvertimePay),
   
       // Deductions
     TotalSSSContributions = g.Sum(i => i.SSSDeduction),
                    TotalPhilHealthContributions = g.Sum(i => i.PhilHealthDeduction),
     TotalPagIbigContributions = g.Sum(i => i.PagIbigDeduction),
      TotalTaxWithheld = g.Sum(i => i.WithholdingTax),
     
            // Net
            TotalNetCompensation = g.Sum(i => i.NetSalary),
              
  // Taxable income (for reference)
       TaxableIncome = g.Sum(i => i.GrossSalary - i.TotalStatutoryDeductions)
      })
  .OrderBy(e => e.EmployeeName)
           .ToList();

         // Monthly breakdown
    report.MonthlyBreakdown = Enumerable.Range(1, 12)
  .Select(month =>
     {
         var monthStart = new DateTime(year, month, 1);
 var monthEnd = monthStart.AddMonths(1).AddDays(-1);
             var monthRuns = approvedRuns.Where(p => 
         p.PayPeriodStart >= monthStart && p.PayPeriodEnd <= monthEnd).ToList();
       var monthItems = monthRuns.SelectMany(p => p.Items).ToList();

              return new MonthlyTaxSummary
          {
   Month = month,
             MonthName = monthStart.ToString("MMMM"),
      TotalGross = monthItems.Sum(i => i.GrossSalary),
        TotalTaxWithheld = monthItems.Sum(i => i.WithholdingTax),
            EmployeeCount = monthItems.Select(i => i.EmployeeId).Distinct().Count()
  };
 })
          .ToList();

     return report;
            }
    catch (Exception ex)
            {
     System.Diagnostics.Debug.WriteLine($"Error generating year-end tax report: {ex.Message}");
   throw;
     }
        }

        /// <summary>
        /// Generate Payroll Audit Trail Report
      /// </summary>
      public async Task<PayrollAuditReport> GenerateAuditTrailReportAsync(DateTime startDate, DateTime endDate)
        {
    try
 {
    var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);

     var report = new PayrollAuditReport
          {
                PeriodStart = startDate,
       PeriodEnd = endDate,
        TotalPayRuns = payRuns.Count,
          GeneratedDate = DateTime.UtcNow
         };

             // Audit trail entries
       report.AuditEntries = payRuns
     .SelectMany(p => new List<PayrollAuditEntry>
   {
        new PayrollAuditEntry
    {
    PayRunNumber = p.PayRunNumber,
            Action = "Created",
          PerformedBy = p.CreatedBy,
        Timestamp = p.CreatedAt,
             Status = p.Status,
    EmployeeCount = p.TotalEmployees,
    Amount = p.TotalNetSalary
             },
        p.ReviewedAt.HasValue ? new PayrollAuditEntry
     {
              PayRunNumber = p.PayRunNumber,
        Action = "Reviewed",
      PerformedBy = p.ReviewedBy,
          Timestamp = p.ReviewedAt.Value,
         Status = "Reviewed",
         EmployeeCount = p.TotalEmployees,
       Amount = p.TotalNetSalary
           } : null,
            p.ApprovedAt.HasValue ? new PayrollAuditEntry
                 {
         PayRunNumber = p.PayRunNumber,
   Action = "Approved",
        PerformedBy = p.ApprovedBy,
             Timestamp = p.ApprovedAt.Value,
              Status = "Approved",
      EmployeeCount = p.TotalEmployees,
       Amount = p.TotalNetSalary,
         Comments = p.ApprovalComments
      } : null
       })
              .Where(e => e != null)
   .OrderByDescending(e => e.Timestamp)
             .ToList();

        // Summary by action
       report.ActionSummary = report.AuditEntries
       .GroupBy(e => e.Action)
          .ToDictionary(
               g => g.Key,
        g => g.Count()
      );

         // Summary by user
                report.UserActivitySummary = report.AuditEntries
          .Where(e => !string.IsNullOrEmpty(e.PerformedBy))
             .GroupBy(e => e.PerformedBy)
         .Select(g => new UserActivitySummary
  {
        Username = g.Key,
    TotalActions = g.Count(),
            LastActivity = g.Max(e => e.Timestamp),
  ActionBreakdown = g.GroupBy(e => e.Action)
             .ToDictionary(ag => ag.Key, ag => ag.Count())
       })
         .ToList();

   return report;
     }
  catch (Exception ex)
            {
            System.Diagnostics.Debug.WriteLine($"Error generating audit trail report: {ex.Message}");
            throw;
       }
        }

    /// <summary>
        /// Generate Employee Payroll History Report
        /// </summary>
  public async Task<EmployeePayrollHistory> GenerateEmployeePayrollHistoryAsync(
     string employeeId, DateTime startDate, DateTime endDate)
        {
         try
 {
     var payRuns = await _payRunService.GetByDateRangeAsync(startDate, endDate);
      var approvedRuns = payRuns.Where(p => p.Status == "Approved").ToList();

          var employeeItems = approvedRuns
            .SelectMany(p => p.Items)
        .Where(i => i.EmployeeId == employeeId)
         .OrderBy(i => approvedRuns.First(p => p.Items.Contains(i)).PayPeriodStart)
.ToList();

        if (!employeeItems.Any())
             {
        return new EmployeePayrollHistory
   {
        EmployeeId = employeeId,
   Message = "No payroll records found for this employee"
  };
       }

 var firstItem = employeeItems.First();
      
       var history = new EmployeePayrollHistory
   {
        EmployeeId = employeeId,
             EmployeeName = firstItem.EmployeeName,
      Department = firstItem.Department,
       Position = firstItem.Position,
  PeriodStart = startDate,
     PeriodEnd = endDate,
        TotalPayPeriods = employeeItems.Count,
       
 // Totals
   TotalGrossEarned = employeeItems.Sum(i => i.GrossSalary),
            TotalDeductions = employeeItems.Sum(i => i.TotalDeductions),
   TotalNetReceived = employeeItems.Sum(i => i.NetSalary),
     TotalOvertimePay = employeeItems.Sum(i => i.OvertimePay),
        TotalBonuses = employeeItems.Sum(i => i.Bonuses),
    
            // Averages
           AverageGrossPay = employeeItems.Average(i => i.GrossSalary),
 AverageNetPay = employeeItems.Average(i => i.NetSalary),
         
       GeneratedDate = DateTime.UtcNow
      };

    // Pay period details
            history.PayPeriodDetails = employeeItems
         .Select(i =>
             {
       var payRun = approvedRuns.First(p => p.Items.Contains(i));
 return new PayPeriodDetail
          {
     PayRunNumber = payRun.PayRunNumber,
        PayPeriod = payRun.PayPeriodDisplay,
      PayDate = payRun.PayDate,
    GrossSalary = i.GrossSalary,
           TotalDeductions = i.TotalDeductions,
          NetSalary = i.NetSalary,
        DaysPresent = i.DaysPresent,
   DaysAbsent = i.DaysAbsent,
    OvertimeHours = i.RegularOvertimeHours,
 Status = i.Status
   };
    })
           .ToList();

       return history;
   }
   catch (Exception ex)
      {
        System.Diagnostics.Debug.WriteLine($"Error generating employee history: {ex.Message}");
                throw;
      }
        }

        /// <summary>
      /// Generate Comparative Payroll Report (Year-over-Year)
      /// </summary>
      public async Task<ComparativePayrollReport> GenerateComparativeReportAsync(int year1, int year2)
  {
   try
     {
 var year1Start = new DateTime(year1, 1, 1);
    var year1End = new DateTime(year1, 12, 31);
            var year2Start = new DateTime(year2, 1, 1);
    var year2End = new DateTime(year2, 12, 31);

           var year1Runs = await _payRunService.GetByDateRangeAsync(year1Start, year1End);
         var year2Runs = await _payRunService.GetByDateRangeAsync(year2Start, year2End);

   var year1Approved = year1Runs.Where(p => p.Status == "Approved").ToList();
    var year2Approved = year2Runs.Where(p => p.Status == "Approved").ToList();

         var report = new ComparativePayrollReport
                {
          Year1 = year1,
           Year2 = year2,
            
 // Year 1 totals
         Year1TotalGross = year1Approved.Sum(p => p.TotalGrossSalary),
     Year1TotalNet = year1Approved.Sum(p => p.TotalNetSalary),
     Year1AverageEmployees = (int)year1Approved.Average(p => p.TotalEmployees),
   
     // Year 2 totals
          Year2TotalGross = year2Approved.Sum(p => p.TotalGrossSalary),
  Year2TotalNet = year2Approved.Sum(p => p.TotalNetSalary),
   Year2AverageEmployees = (int)year2Approved.Average(p => p.TotalEmployees),
           
                    GeneratedDate = DateTime.UtcNow
         };

          // Calculate variances
      report.GrossVariance = report.Year2TotalGross - report.Year1TotalGross;
    report.GrossVariancePercent = report.Year1TotalGross > 0 
          ? (report.GrossVariance / report.Year1TotalGross) * 100 
              : 0;

     report.NetVariance = report.Year2TotalNet - report.Year1TotalNet;
       report.NetVariancePercent = report.Year1TotalNet > 0 
    ? (report.NetVariance / report.Year1TotalNet) * 100 
     : 0;

           report.EmployeeVariance = report.Year2AverageEmployees - report.Year1AverageEmployees;

      // Monthly comparison
   report.MonthlyComparison = Enumerable.Range(1, 12)
       .Select(month =>
        {
   var y1MonthStart = new DateTime(year1, month, 1);
     var y1MonthEnd = y1MonthStart.AddMonths(1).AddDays(-1);
      var y2MonthStart = new DateTime(year2, month, 1);
            var y2MonthEnd = y2MonthStart.AddMonths(1).AddDays(-1);

    var y1MonthRuns = year1Approved.Where(p => 
    p.PayPeriodStart >= y1MonthStart && p.PayPeriodEnd <= y1MonthEnd).ToList();
 var y2MonthRuns = year2Approved.Where(p => 
       p.PayPeriodStart >= y2MonthStart && p.PayPeriodEnd <= y2MonthEnd).ToList();

    var y1Total = y1MonthRuns.Sum(p => p.TotalNetSalary);
       var y2Total = y2MonthRuns.Sum(p => p.TotalNetSalary);

    return new MonthlyComparison
       {
   Month = month,
    MonthName = y1MonthStart.ToString("MMMM"),
   Year1Total = y1Total,
              Year2Total = y2Total,
                Variance = y2Total - y1Total,
   VariancePercent = y1Total > 0 ? ((y2Total - y1Total) / y1Total) * 100 : 0
           };
                    })
            .ToList();

  return report;
            }
       catch (Exception ex)
            {
  System.Diagnostics.Debug.WriteLine($"Error generating comparative report: {ex.Message}");
         throw;
 }
        }

        // ========== EXPORT METHODS ==========

 /// <summary>
        /// Export report to CSV format
        /// </summary>
        public string ExportMonthlyPayrollToCSV(MonthlyPayrollSummary summary)
        {
     var sb = new StringBuilder();
            
        // Header
     sb.AppendLine($"Monthly Payroll Summary Report");
            sb.AppendLine($"Month: {summary.MonthName} {summary.Year}");
            sb.AppendLine($"Generated: {summary.GeneratedDate:yyyy-MM-dd HH:mm:ss}");
  sb.AppendLine();
      
            // Summary section
        sb.AppendLine("SUMMARY");
     sb.AppendLine($"Total Pay Runs,{summary.TotalPayRuns}");
            sb.AppendLine($"Total Employees,{summary.TotalEmployees}");
            sb.AppendLine($"Total Gross Salary,{summary.TotalGrossSalary:N2}");
            sb.AppendLine($"Total Deductions,{summary.TotalDeductions:N2}");
   sb.AppendLine($"Total Net Salary,{summary.TotalNetSalary:N2}");
            sb.AppendLine();
   
            // Department breakdown
        sb.AppendLine("DEPARTMENT BREAKDOWN");
        sb.AppendLine("Department,Employees,Total Gross,Total Deductions,Total Net,Average Salary");
            foreach (var dept in summary.DepartmentBreakdown)
    {
         sb.AppendLine($"{dept.Department},{dept.EmployeeCount},{dept.TotalGross:N2}," +
   $"{dept.TotalDeductions:N2},{dept.TotalNet:N2},{dept.AverageSalary:N2}");
            }
  
            return sb.ToString();
        }

        /// <summary>
    /// Export statutory deduction report to CSV
        /// </summary>
        public string ExportStatutoryDeductionToCSV(StatutoryDeductionReport report)
        {
    var sb = new StringBuilder();
            
            // Header
            sb.AppendLine($"Statutory Deduction Report");
     sb.AppendLine($"Month: {report.MonthName} {report.Year}");
         sb.AppendLine($"Generated: {report.GeneratedDate:yyyy-MM-dd HH:mm:ss}");
         sb.AppendLine();
     
            // Summary
        sb.AppendLine("SUMMARY");
     sb.AppendLine($"Total Employees,{report.TotalEmployees}");
    sb.AppendLine($"Total SSS Contributions,{report.TotalSSSContributions:N2}");
         sb.AppendLine($"Total PhilHealth Contributions,{report.TotalPhilHealthContributions:N2}");
        sb.AppendLine($"Total Pag-IBIG Contributions,{report.TotalPagIbigContributions:N2}");
            sb.AppendLine($"Total SSS Loan Deductions,{report.TotalSSSLoanDeductions:N2}");
            sb.AppendLine($"Total Pag-IBIG Loan Deductions,{report.TotalPagIbigLoanDeductions:N2}");
        sb.AppendLine();
          
   // Employee details
            sb.AppendLine("EMPLOYEE DETAILS");
          sb.AppendLine("Employee ID,Employee Name,Department,SSS,PhilHealth,Pag-IBIG,SSS Loan,Pag-IBIG Loan,Total");
        foreach (var emp in report.EmployeeDetails)
            {
      sb.AppendLine($"{emp.EmployeeId},{emp.EmployeeName},{emp.Department}," +
 $"{emp.SSSContribution:N2},{emp.PhilHealthContribution:N2},{emp.PagIbigContribution:N2}," +
          $"{emp.SSSLoan:N2},{emp.PagIbigLoan:N2},{emp.TotalStatutory:N2}");
            }
 
        return sb.ToString();
      }
    }
}
