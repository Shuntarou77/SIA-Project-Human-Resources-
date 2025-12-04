using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// Payslip Model - Digital payslip record (Function 6.4)
    /// </summary>
    public class Payslip
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

 [BsonElement("payRunId")]
    public string PayRunId { get; set; }

        [BsonElement("payPeriodStart")]
        public DateTime PayPeriodStart { get; set; }

  [BsonElement("payPeriodEnd")]
        public DateTime PayPeriodEnd { get; set; }

        [BsonElement("payDate")]
     public DateTime PayDate { get; set; }

        [BsonElement("pdfFilePath")]
        public string PdfFilePath { get; set; } // Path to generated PDF

        [BsonElement("htmlContent")]
    public string HtmlContent { get; set; } // HTML version for web display

        [BsonElement("generatedAt")]
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("emailedAt")]
        public DateTime? EmailedAt { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // Payslip Data (snapshot from PayrollItem)
   [BsonElement("employeeName")]
        public string EmployeeName { get; set; }

        [BsonElement("department")]
        public string Department { get; set; }

  [BsonElement("grossSalary")]
        public decimal GrossSalary { get; set; }

        [BsonElement("totalDeductions")]
public decimal TotalDeductions { get; set; }

        [BsonElement("netSalary")]
        public decimal NetSalary { get; set; }

        // Computed
      [BsonIgnore]
        public string PayPeriodDisplay => $"{PayPeriodStart:MMM dd} - {PayPeriodEnd:MMM dd, yyyy}";
    }
}
