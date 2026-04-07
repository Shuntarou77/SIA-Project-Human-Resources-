using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class UndertimeRecord
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("attendanceId")]
        public string AttendanceId { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

        [BsonElement("employeeName")]
        public string EmployeeName { get; set; }

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("hoursUndertime")]
        public double HoursUndertime { get; set; } // e.g., 2.5 hours

        [BsonElement("hourlyRate")]
        public decimal HourlyRate { get; set; }

        [BsonElement("deductionAmount")]
        public decimal DeductionAmount { get; set; } // HourlyRate * HoursUndertime

        [BsonElement("reason")]
        public string Reason { get; set; }

        [BsonElement("recordedAt")]
        public DateTime RecordedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;
    }
}
