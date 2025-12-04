using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayrollConfiguration Model - Stores salary setup for each employee
    /// This is the master data for payroll calculations
    /// </summary>
    public class PayrollConfiguration
    {
[BsonId]
  [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; }

        // Employee Reference - MUST match User._id (MongoDB ObjectId), NOT User.EmployeeId
        [BsonElement("employeeId")]
        public string EmployeeId { get; set; } // MongoDB ObjectId as string (e.g., "692451360c27cb8da7b77bee")

        [BsonElement("employeeName")]
        public string EmployeeName { get; set; } // For display purposes

        [BsonElement("employeeNumber")]
        public string EmployeeNumber { get; set; } // Display ID like "23-2211" for UI

        [BsonElement("department")]
 public string Department { get; set; }

        // ========== SALARY COMPONENTS (6.1.1) ==========
        
        [BsonElement("basicSalary")]
    public decimal BasicSalary { get; set; } // Monthly basic salary

        // Allowances
     [BsonElement("housingAllowance")]
        public decimal HousingAllowance { get; set; }

  [BsonElement("transportAllowance")]
        public decimal TransportAllowance { get; set; }

        [BsonElement("mealAllowance")]
        public decimal MealAllowance { get; set; }

  [BsonElement("otherAllowances")]
  public decimal OtherAllowances { get; set; }

     // Overtime Rates (per hour)
        [BsonElement("regularOvertimeRate")]
        public decimal RegularOvertimeRate { get; set; } // Normal day overtime

    [BsonElement("holidayOvertimeRate")]
        public decimal HolidayOvertimeRate { get; set; } // Holiday overtime

   [BsonElement("nightDifferentialRate")]
        public decimal NightDifferentialRate { get; set; } // Night shift premium

        // ========== DEDUCTIONS SETUP (6.1.2) ==========
        
        // Government Mandatory Deductions
        [BsonElement("sssContribution")]
        public decimal SSSContribution { get; set; }

     [BsonElement("philHealthContribution")]
     public decimal PhilHealthContribution { get; set; }

[BsonElement("pagIbigContribution")]
        public decimal PagIbigContribution { get; set; }

  [BsonElement("withholdingTax")]
        public decimal WithholdingTax { get; set; }

        // Loan Deductions
 [BsonElement("sssLoan")]
  public decimal SSSLoan { get; set; }

        [BsonElement("pagIbigLoan")]
        public decimal PagIbigLoan { get; set; }

    [BsonElement("companyLoan")]
        public decimal CompanyLoan { get; set; }

        [BsonElement("otherDeductions")]
    public decimal OtherDeductions { get; set; }

        // Variable Deductions (calculated from attendance)
        [BsonElement("absencePenaltyRate")]
    public decimal AbsencePenaltyRate { get; set; } // Per day

        [BsonElement("latePenaltyRate")]
 public decimal LatePenaltyRate { get; set; } // Per hour/minute

      // ========== METADATA ==========
        
      [BsonElement("effectiveDate")]
        public DateTime EffectiveDate { get; set; } // When this config becomes active

  [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

     [BsonElement("createdBy")]
        public string CreatedBy { get; set; } // Admin/HR who created this

        [BsonElement("isActive")]
 public bool IsActive { get; set; } = true;

 // ========== COMPUTED PROPERTIES ==========

    /// <summary>
  /// Total Monthly Allowances
   /// </summary>
      [BsonIgnore]
        public decimal TotalAllowances => 
        HousingAllowance + TransportAllowance + MealAllowance + OtherAllowances;

        /// <summary>
    /// Total Monthly Statutory Deductions
 /// </summary>
        [BsonIgnore]
        public decimal TotalStatutoryDeductions => 
  SSSContribution + PhilHealthContribution + PagIbigContribution + WithholdingTax;

 /// <summary>
   /// Total Monthly Loan Deductions
        /// </summary>
  [BsonIgnore]
 public decimal TotalLoanDeductions => 
   SSSLoan + PagIbigLoan + CompanyLoan;

     /// <summary>
        /// Gross Monthly Salary (Basic + Allowances)
    /// </summary>
        [BsonIgnore]
        public decimal GrossMonthlySalary => BasicSalary + TotalAllowances;

        /// <summary>
     /// Calculate and update computed totals (for compatibility)
        /// </summary>
        public void CalculateTotals()
        {
    // Totals are now calculated via computed properties
        // This method exists for backward compatibility
         // No action needed as properties auto-calculate
      }
    }
}
