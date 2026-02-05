using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayRun - A complete payroll run for a specific pay period (Function 6.2.5)
    /// Contains all employees' payroll calculations
    /// </summary>
    public class PayRun
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // ========== PAY PERIOD DETAILS ==========
        
    [BsonElement("payPeriodStart")]
      public DateTime PayPeriodStart { get; set; } // e.g., Jan 1, 2025

        [BsonElement("payPeriodEnd")]
   public DateTime PayPeriodEnd { get; set; } // e.g., Jan 15, 2025
   

   [BsonElement("payDate")]
   public DateTime PayDate { get; set; } // When employees get paid

        [BsonElement("payPeriodType")]
   public string PayPeriodType { get; set; } // "Semi-Monthly", "Monthly"

        [BsonElement("cutoffDate")]
        public DateTime CutoffDate { get; set; } // Last date included in calculations

        // ========== PAY RUN DETAILS ==========
        
   [BsonElement("payRunNumber")]
        public string PayRunNumber { get; set; } // e.g., "PR-2025-01-001"

        [BsonElement("description")]
      public string Description { get; set; } // e.g., "Semi-Monthly Jan 1-15, 2025"

        [BsonElement("totalEmployees")]
        public int TotalEmployees { get; set; } // Number of employees included

        // ========== PAYROLL ITEMS ==========
 
        [BsonElement("items")]
  public List<PayrollItem> Items { get; set; } = new List<PayrollItem>();

        // ========== TOTALS ==========
        
        [BsonElement("totalGrossSalary")]
    public decimal TotalGrossSalary { get; set; }

        [BsonElement("totalDeductions")]
        public decimal TotalDeductions { get; set; }

     [BsonElement("totalNetSalary")]
        public decimal TotalNetSalary { get; set; }

        [BsonElement("totalOvertimePay")]
        public decimal TotalOvertimePay { get; set; }

        [BsonElement("totalStatutoryDeductions")]
        public decimal TotalStatutoryDeductions { get; set; }

   [BsonElement("totalLoanDeductions")]
        public decimal TotalLoanDeductions { get; set; }

        // ========== STATUS & WORKFLOW ==========
      
        [BsonElement("status")]
  public string Status { get; set; } // "Draft", "Calculated", "Reviewed", "Approved", "Sent"

        [BsonElement("isFinalized")]
   public bool IsFinalized { get; set; } = false;

 [BsonElement("isSentToFinance")]
   public bool IsSentToFinance { get; set; } = false;

        [BsonElement("isPayslipsGenerated")]
        public bool IsPayslipsGenerated { get; set; } = false;

        [BsonElement("payslipsGeneratedAt")]
        public DateTime? PayslipsGeneratedAt { get; set; }

        [BsonElement("payslipsGeneratedBy")]
        public string PayslipsGeneratedBy { get; set; }

// ========== APPROVAL WORKFLOW (Function 6.3.2) ==========
        
        [BsonElement("reviewedBy")]
    public string ReviewedBy { get; set; }

        [BsonElement("reviewedAt")]
        public DateTime? ReviewedAt { get; set; }

   [BsonElement("approvedBy")]
        public string ApprovedBy { get; set; }

        [BsonElement("approvedAt")]
        public DateTime? ApprovedAt { get; set; }

        [BsonElement("approvalComments")]
        public string ApprovalComments { get; set; }

        // ========== PAYMENT TRACKING ==========
        
        [BsonElement("isPaid")]
        public bool IsPaid { get; set; } = false;
        
        [BsonElement("paidBy")]
        public string PaidBy { get; set; }
        
        [BsonElement("paidAt")]
        public DateTime? PaidAt { get; set; }

     // ========== METADATA ==========
   
   [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

      [BsonElement("createdBy")]
  public string CreatedBy { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // ========== COMPUTED PROPERTIES ==========

        /// <summary>
  /// Display-friendly pay period
        /// </summary>
        [BsonIgnore]
        public string PayPeriodDisplay => 
         $"{PayPeriodStart:MMM dd} - {PayPeriodEnd:MMM dd, yyyy}";

  /// <summary>
        /// Total statutory deductions from all employees
      /// </summary>
        [BsonIgnore]
        public decimal CalculatedStatutoryDeductions => 
       Items?.Sum(i => i.TotalStatutoryDeductions) ?? 0;

        /// <summary>
        /// Total loan deductions from all employees
      /// </summary>
    [BsonIgnore]
        public decimal CalculatedLoanDeductions => 
      Items?.Sum(i => i.TotalLoanDeductions) ?? 0;

        /// <summary>
        /// Total penalty deductions from all employees
  /// </summary>
        [BsonIgnore]
        public decimal TotalPenaltyDeductions => 
     Items?.Sum(i => i.TotalPenaltyDeductions) ?? 0;

        /// <summary>
     /// Status badge color
        /// </summary>
        [BsonIgnore]
        public string StatusColor
        {
   get
            {
          if (Status == "Draft") return "#9CA3AF";
      if (Status == "Calculated") return "#3B82F6";
                if (Status == "Reviewed") return "#F59E0B";
    if (Status == "Approved") return "#10B981";
       if (Status == "Sent") return "#8B5CF6";
                return "#6B7280";
            }
  }

        /// <summary>
     /// Check if pay run can be edited
        /// </summary>
  [BsonIgnore]
      public bool CanEdit => Status == "Draft" || Status == "Calculated";

        /// <summary>
        /// Check if pay run can be approved
        /// </summary>
    [BsonIgnore]
        public bool CanApprove => Status == "Reviewed" && !IsFinalized;

        /// <summary>
        /// Check if pay run can be sent to finance
        /// </summary>
        [BsonIgnore]
        public bool CanSendToFinance => Status == "Approved" && !IsSentToFinance;

        // ========== HELPER METHODS ==========

   /// <summary>
   /// Recalculate totals from items
        /// </summary>
  public void RecalculateTotals()
        {
     if (Items == null || Items.Count == 0)
            {
     TotalGrossSalary = 0;
       TotalDeductions = 0;
       TotalNetSalary = 0;
 TotalOvertimePay = 0;
        TotalStatutoryDeductions = 0;
                TotalLoanDeductions = 0;
           return;
         }

            TotalGrossSalary = Items.Sum(i => i.GrossSalary);
 TotalDeductions = Items.Sum(i => i.TotalDeductions);
            TotalNetSalary = Items.Sum(i => i.NetSalary);
     TotalOvertimePay = Items.Sum(i => i.OvertimePay);
            TotalStatutoryDeductions = CalculatedStatutoryDeductions;
         TotalLoanDeductions = CalculatedLoanDeductions;
  TotalEmployees = Items.Count;
            UpdatedAt = DateTime.UtcNow;
   }
    }
}
