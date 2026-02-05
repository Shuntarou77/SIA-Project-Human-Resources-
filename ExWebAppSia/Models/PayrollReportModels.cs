using System;
using System.Collections.Generic;

namespace ExWebAppSia.Models
{
    // ========== MONTHLY PAYROLL SUMMARY ==========

    /// <summary>
    /// Monthly Payroll Summary Report
    /// </summary>
    public class MonthlyPayrollSummary
    {
    public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; }
        public int TotalPayRuns { get; set; }
        public int TotalEmployees { get; set; }
        public decimal TotalGrossSalary { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal TotalNetSalary { get; set; }
        public decimal TotalOvertimePay { get; set; }
  public decimal TotalStatutoryDeductions { get; set; }
        public decimal TotalLoanDeductions { get; set; }
        
        // Breakdown by deduction type
        public decimal TotalSSSDeductions { get; set; }
        public decimal TotalPhilHealthDeductions { get; set; }
  public decimal TotalPagIbigDeductions { get; set; }
        public decimal TotalTaxDeductions { get; set; }
     
        // Department breakdown
        public List<DepartmentSalarySummary> DepartmentBreakdown { get; set; } = new List<DepartmentSalarySummary>();
        
   // Pay run details
        public List<PayRunSummaryLine> PayRunDetails { get; set; } = new List<PayRunSummaryLine>();
   
        public DateTime GeneratedDate { get; set; }
 public string Message { get; set; }
    }

    public class DepartmentSalarySummary
    {
  public string Department { get; set; }
        public int EmployeeCount { get; set; }
        public decimal TotalGross { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal TotalNet { get; set; }
        public decimal AverageSalary { get; set; }
    }

    public class PayRunSummaryLine
    {
        public string PayRunNumber { get; set; }
        public string PayPeriod { get; set; }
        public DateTime PayDate { get; set; }
        public int EmployeeCount { get; set; }
        public decimal GrossSalary { get; set; }
        public decimal NetSalary { get; set; }
    }

    // ========== DEPARTMENT COST REPORT ==========

    /// <summary>
    /// Department-wise Salary Cost Report
    /// </summary>
    public class DepartmentCostReport
    {
    public string Department { get; set; }
    public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
    public int TotalEmployees { get; set; }
     public decimal TotalBasicSalary { get; set; }
   public decimal TotalAllowances { get; set; }
  public decimal TotalOvertimePay { get; set; }
        public decimal TotalBonuses { get; set; }
        public decimal TotalGrossSalary { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal TotalNetSalary { get; set; }
        public decimal AverageSalaryPerEmployee { get; set; }
        public decimal HighestSalary { get; set; }
        public decimal LowestSalary { get; set; }
        public DateTime GeneratedDate { get; set; }
        
   public string PeriodDisplay => $"{PeriodStart:MMM dd} - {PeriodEnd:MMM dd, yyyy}";
    }

    // ========== STATUTORY DEDUCTION REPORT ==========

    /// <summary>
    /// Statutory Deduction Report (SSS, PhilHealth, Pag-IBIG)
  /// </summary>
    public class StatutoryDeductionReport
    {
     public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; }
        public int TotalEmployees { get; set; }
  
        // SSS
     public decimal TotalSSSContributions { get; set; }
  public decimal TotalSSSLoanDeductions { get; set; }
        public decimal TotalSSSRemittance { get; set; }
        
     // PhilHealth
        public decimal TotalPhilHealthContributions { get; set; }
        
      // Pag-IBIG
   public decimal TotalPagIbigContributions { get; set; }
        public decimal TotalPagIbigLoanDeductions { get; set; }
        public decimal TotalPagIbigRemittance { get; set; }
 
        // Total
     public decimal TotalStatutoryDeductions { get; set; }
    
    // Employee-level details
     public List<EmployeeStatutoryDetail> EmployeeDetails { get; set; } = new List<EmployeeStatutoryDetail>();
     
        public DateTime GeneratedDate { get; set; }
        public string Message { get; set; }
    }

    public class EmployeeStatutoryDetail
    {
        public string EmployeeId { get; set; }
  public string EmployeeName { get; set; }
        public string Department { get; set; }
        public decimal SSSContribution { get; set; }
  public decimal PhilHealthContribution { get; set; }
        public decimal PagIbigContribution { get; set; }
        public decimal SSSLoan { get; set; }
        public decimal PagIbigLoan { get; set; }
        public decimal TotalStatutory { get; set; }
  }

    // ========== YEAR-END TAX REPORT ==========

  /// <summary>
    /// Year-End Tax Report (BIR Compliance)
    /// </summary>
    public class YearEndTaxReport
    {
        public int Year { get; set; }
     public int TotalEmployees { get; set; }
        public decimal TotalGrossCompensation { get; set; }
        public decimal TotalTaxWithheld { get; set; }
public decimal TotalNetCompensation { get; set; }
     
   // Employee annual summaries (for BIR Form 2316)
     public List<EmployeeAnnualTaxSummary> EmployeeAnnualSummary { get; set; } = new List<EmployeeAnnualTaxSummary>();
      
      // Monthly breakdown
        public List<MonthlyTaxSummary> MonthlyBreakdown { get; set; } = new List<MonthlyTaxSummary>();
    
        public DateTime GeneratedDate { get; set; }
        public string Message { get; set; }
    }

    public class EmployeeAnnualTaxSummary
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
     public string Department { get; set; }
        public string Position { get; set; }
        
        // Annual earnings
    public decimal TotalGrossCompensation { get; set; }
        public decimal TotalBasicSalary { get; set; }
 public decimal TotalAllowances { get; set; }
     public decimal TotalBonuses { get; set; }
        public decimal TotalOvertimePay { get; set; }
 
        // Deductions
        public decimal TotalSSSContributions { get; set; }
        public decimal TotalPhilHealthContributions { get; set; }
        public decimal TotalPagIbigContributions { get; set; }
     public decimal TotalTaxWithheld { get; set; }
        
    // Net
     public decimal TotalNetCompensation { get; set; }
        
        // Taxable income
        public decimal TaxableIncome { get; set; }
    }

    public class MonthlyTaxSummary
    {
        public int Month { get; set; }
    public string MonthName { get; set; }
        public decimal TotalGross { get; set; }
        public decimal TotalTaxWithheld { get; set; }
        public int EmployeeCount { get; set; }
    }

    // ========== PAYROLL AUDIT REPORT ==========

    /// <summary>
    /// Payroll Audit Trail Report
    /// </summary>
    public class PayrollAuditReport
    {
    public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public int TotalPayRuns { get; set; }
        
        // Audit entries
    public List<PayrollAuditEntry> AuditEntries { get; set; } = new List<PayrollAuditEntry>();
        
 // Summary statistics
        public Dictionary<string, int> ActionSummary { get; set; } = new Dictionary<string, int>();
   public List<UserActivitySummary> UserActivitySummary { get; set; } = new List<UserActivitySummary>();
        
        public DateTime GeneratedDate { get; set; }
        
        public string PeriodDisplay => $"{PeriodStart:MMM dd} - {PeriodEnd:MMM dd, yyyy}";
    }

    public class PayrollAuditEntry
    {
        public string PayRunNumber { get; set; }
        public string Action { get; set; } // "Created", "Reviewed", "Approved", "Rejected"
    public string PerformedBy { get; set; }
public DateTime Timestamp { get; set; }
        public string Status { get; set; }
        public int EmployeeCount { get; set; }
        public decimal Amount { get; set; }
     public string Comments { get; set; }
    }

    public class UserActivitySummary
    {
        public string Username { get; set; }
        public int TotalActions { get; set; }
        public DateTime LastActivity { get; set; }
        public Dictionary<string, int> ActionBreakdown { get; set; } = new Dictionary<string, int>();
    }

    // ========== EMPLOYEE PAYROLL HISTORY ==========

    /// <summary>
    /// Employee Payroll History Report
 /// </summary>
    public class EmployeePayrollHistory
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string Department { get; set; }
    public string Position { get; set; }
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public int TotalPayPeriods { get; set; }
        
   // Totals
    public decimal TotalGrossEarned { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal TotalNetReceived { get; set; }
        public decimal TotalOvertimePay { get; set; }
  public decimal TotalBonuses { get; set; }
     
   // Averages
        public decimal AverageGrossPay { get; set; }
        public decimal AverageNetPay { get; set; }
 
        // Pay period details
        public List<PayPeriodDetail> PayPeriodDetails { get; set; } = new List<PayPeriodDetail>();
     
        public DateTime GeneratedDate { get; set; }
        public string Message { get; set; }
      
        public string PeriodDisplay => $"{PeriodStart:MMM dd} - {PeriodEnd:MMM dd, yyyy}";
    }

    public class PayPeriodDetail
    {
        public string PayRunNumber { get; set; }
        public string PayPeriod { get; set; }
        public DateTime PayDate { get; set; }
        public decimal GrossSalary { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal NetSalary { get; set; }
        public int DaysPresent { get; set; }
        public int DaysAbsent { get; set; }
      public decimal OvertimeHours { get; set; }
        public string Status { get; set; }
    }

    // ========== COMPARATIVE PAYROLL REPORT ==========

    /// <summary>
    /// Comparative Payroll Report (Year-over-Year)
    /// </summary>
    public class ComparativePayrollReport
    {
public int Year1 { get; set; }
        public int Year2 { get; set; }
      
     // Year 1 totals
        public decimal Year1TotalGross { get; set; }
    public decimal Year1TotalNet { get; set; }
        public int Year1AverageEmployees { get; set; }
        
    // Year 2 totals
        public decimal Year2TotalGross { get; set; }
        public decimal Year2TotalNet { get; set; }
   public int Year2AverageEmployees { get; set; }
   
        // Variances
        public decimal GrossVariance { get; set; }
        public decimal GrossVariancePercent { get; set; }
   public decimal NetVariance { get; set; }
        public decimal NetVariancePercent { get; set; }
        public int EmployeeVariance { get; set; }
        
        // Monthly comparison
        public List<MonthlyComparison> MonthlyComparison { get; set; } = new List<MonthlyComparison>();
        
 public DateTime GeneratedDate { get; set; }
    }

    public class MonthlyComparison
    {
        public int Month { get; set; }
        public string MonthName { get; set; }
public decimal Year1Total { get; set; }
        public decimal Year2Total { get; set; }
        public decimal Variance { get; set; }
      public decimal VariancePercent { get; set; }
    }
}
