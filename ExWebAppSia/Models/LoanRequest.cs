using System;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace ExWebAppSia.Models
{
    public class LoanRequest
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string LoanType { get; set; } // e.g., Salary Loan, Calamity Loan
        public string Agency { get; set; }   // e.g., SSS, Pag-IBIG, GSIS
        
        [BsonDateTimeOptions(Kind = DateTimeKind.Local)]
        public DateTime RequestDate { get; set; } = DateTime.Now;

        public string Status { get; set; } = "PENDING"; // PENDING, APPROVED, DECLINED

        [BsonDateTimeOptions(Kind = DateTimeKind.Local)]
        public DateTime LastUpdated { get; set; } = DateTime.Now;

        public string Remarks { get; set; }
    }
}
