using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
  /// <summary>
    /// PayrollItem - Individual employee's payroll calculation for a pay period
    /// Part of Function 6.2: Payroll Processing Engine
    /// </summary>
    public class PayrollItem
    {
        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

        [BsonElement("employeeName")]
        public string EmployeeName { get; set; }

        [BsonElement("department")]
        public string Department { get; set; }

     [BsonElement("position")]
        public string Position { get; set; }

   // ========== ATTENDANCE DATA (6.2.1) ==========
     
    [BsonElement("totalWorkingDays")]
        public int TotalWorkingDays { get; set; } // Expected working days in period

        [BsonElement("daysPresent")]
    public int DaysPresent { get; set; } // Days employee attended

        [BsonElement("daysAbsent")]
        public int DaysAbsent { get; set; } // Days absent

  [BsonElement("daysLate")]
        public int DaysLate { get; set; } // Days with late attendance

        [BsonElement("lateMinutes")]
        public int LateMinutes { get; set; } // Total late minutes

        [BsonElement("unpaidLeaveDays")]
        public int UnpaidLeaveDays { get; set; } // Days on unpaid leave

// ========== OVERTIME DATA (6.2.1) ==========
   
[BsonElement("regularOvertimeHours")]
        public decimal RegularOvertimeHours { get; set; } // Regular day OT

        [BsonElement("holidayOvertimeHours")]
        public decimal HolidayOvertimeHours { get; set; } // Holiday OT

        [BsonElement("nightDifferentialHours")]
        public decimal NightDifferentialHours { get; set; } // Night shift hours

        // ========== SALARY COMPONENTS (6.2.2) ==========
        
  [BsonElement("basicSalary")]
        public decimal BasicSalary { get; set; } // Monthly basic salary

        [BsonElement("proratedBasicSalary")]
        public decimal ProratedBasicSalary { get; set; } // Adjusted for attendance

        [BsonElement("allowances")]
        public decimal Allowances { get; set; } // Total allowances

        [BsonElement("overtimePay")]
        public decimal OvertimePay { get; set; } // Total OT pay

        [BsonElement("holidayPay")]
        public decimal HolidayPay { get; set; } // Holiday premium

        [BsonElement("nightDifferentialPay")]
        public decimal NightDifferentialPay { get; set; } // Night shift premium

[BsonElement("bonuses")]
        public decimal Bonuses { get; set; } // Performance bonuses

    [BsonElement("otherEarnings")]
        public decimal OtherEarnings { get; set; } // Other earnings

      [BsonElement("grossSalary")]
        public decimal GrossSalary { get; set; } // Total gross (6.2.2)

        // ========== DEDUCTIONS (6.2.3) ==========
        
        // Statutory Deductions
        [BsonElement("sssDeduction")]
        public decimal SSSDeduction { get; set; }

        [BsonElement("philHealthDeduction")]
        public decimal PhilHealthDeduction { get; set; }

        [BsonElement("pagIbigDeduction")]
        public decimal PagIbigDeduction { get; set; }

  [BsonElement("withholdingTax")]
        public decimal WithholdingTax { get; set; }

        // Loan Deductions
        [BsonElement("sssLoan")]
        public decimal SSSLoan { get; set; }

      [BsonElement("pagIbigLoan")]
        public decimal PagIbigLoan { get; set; }

    [BsonElement("companyLoan")]
        public decimal CompanyLoan { get; set; }

        // Penalty Deductions
   [BsonElement("absencePenalty")]
  public decimal AbsencePenalty { get; set; }

        [BsonElement("latePenalty")]
        public decimal LatePenalty { get; set; }

  [BsonElement("unpaidLeaveDeduction")]
    public decimal UnpaidLeaveDeduction { get; set; }

    [BsonElement("otherDeductions")]
        public decimal OtherDeductions { get; set; }

     [BsonElement("totalDeductions")]
      public decimal TotalDeductions { get; set; } // Total deductions (6.2.3)

        // ========== NET SALARY (6.2.4) ==========
        
  [BsonElement("netSalary")]
   public decimal NetSalary { get; set; } // Gross - Deductions

        // ========== METADATA ==========
        
        [BsonElement("remarks")]
        public string Remarks { get; set; } // HR notes

   [BsonElement("status")]
        public string Status { get; set; } // "Calculated", "Adjusted", "Approved"

        [BsonElement("isManuallyAdjusted")]
        public bool IsManuallyAdjusted { get; set; } // Flag for manual changes

        [BsonElement("adjustmentHistory")]
        public string AdjustmentHistory { get; set; } // Track manual changes

        // ========== COMPUTED PROPERTIES ==========

        /// <summary>
        /// Attendance percentage
     /// </summary>
        [BsonIgnore]
        public decimal AttendancePercentage
      {
  get
 {
          if (TotalWorkingDays == 0) return 0;
            return Math.Round((decimal)DaysPresent / TotalWorkingDays * 100, 2);
          }
        }

        /// <summary>
    /// Total earnings (Gross Salary components)
        /// </summary>
        [BsonIgnore]
        public decimal TotalEarnings => 
  ProratedBasicSalary + Allowances + OvertimePay + HolidayPay + 
            NightDifferentialPay + Bonuses + OtherEarnings;

        /// <summary>
        /// Total statutory deductions
        /// </summary>
   [BsonIgnore]
        public decimal TotalStatutoryDeductions => 
  SSSDeduction + PhilHealthDeduction + PagIbigDeduction + WithholdingTax;

        /// <summary>
        /// Total loan deductions
        /// </summary>
        [BsonIgnore]
  public decimal TotalLoanDeductions => 
            SSSLoan + PagIbigLoan + CompanyLoan;

   /// <summary>
        /// Total penalty deductions
        /// </summary>
        [BsonIgnore]
        public decimal TotalPenaltyDeductions => 
            AbsencePenalty + LatePenalty + UnpaidLeaveDeduction;
    }
}
