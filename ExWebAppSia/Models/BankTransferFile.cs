using System;
using System.Collections.Generic;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// BankTransferFile - Generates bank transfer files for payroll disbursement (Function 6.3.4)
    /// </summary>
    public class BankTransferFile
    {
        public string FileName { get; set; }
        public DateTime GeneratedDate { get; set; }
        public int TotalRecords { get; set; }
        public decimal TotalAmount { get; set; }
    public string FileContent { get; set; }
        public string Format { get; set; } // "CSV", "BSF", "TXT"
    }

    /// <summary>
    /// Bank Transfer Record - Single employee's bank transfer details
    /// </summary>
    public class BankTransferRecord
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
   public string BankAccountNumber { get; set; }
        public string BankName { get; set; }
      public decimal Amount { get; set; }
 public string Currency { get; set; } = "PHP";
    public string Reference { get; set; }
    }
}
