using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class OvertimeRequest
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("attendanceId")]
        public string AttendanceId { get; set; } // Reference to the Attendance record

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

        [BsonElement("employeeName")]
        public string EmployeeName { get; set; }

        [BsonElement("department")]
        public string Department { get; set; }

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("reason")]
        public string Reason { get; set; }

        [BsonElement("status")]
        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected

        [BsonElement("overtimeWorked")]
        public string OvertimeWorked { get; set; } // e.g., "02:30:00" — filled after timeout

        [BsonElement("hourlyRate")]
        public decimal HourlyRate { get; set; } // Calculated as Daily Rate / 8

        [BsonElement("overtimeType")]
        public string OvertimeType { get; set; } // Regular, RestDay, RegularHoliday

        [BsonElement("isNightShift")]
        public bool IsNightShift { get; set; } // True if OT is between 10 PM and 6 AM

        [BsonElement("calculatedOvertimePay")]
        public decimal CalculatedOvertimePay { get; set; } // Final calculated amount

        [BsonElement("overtimeHourlyRate")]
        public decimal OvertimeHourlyRate { get; set; } // Specific OT rate per hour (e.g., HourlyRate * 1.25)

        [BsonElement("approvedAt")]
        public DateTime? ApprovedAt { get; set; }

        [BsonElement("requestedAt")]
        public DateTime RequestedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("requestedHours")]
        public decimal RequestedHours { get; set; } // Number of OT hours requested by the employee

        [BsonElement("baseSalary")]
        public decimal BaseSalary { get; set; } // Employee's base salary at the time of the request
    }
}
