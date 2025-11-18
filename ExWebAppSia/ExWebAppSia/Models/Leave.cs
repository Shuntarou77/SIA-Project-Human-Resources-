using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Leave
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

        [BsonElement("leaveType")]
        public string LeaveType { get; set; } // Sick, Vacation, Personal, Emergency, Maternity, Paternity

        [BsonElement("startDate")]
        public DateTime StartDate { get; set; }

        [BsonElement("endDate")]
        public DateTime EndDate { get; set; }

        [BsonElement("reason")]
        public string Reason { get; set; }

        [BsonElement("status")]
        public string Status { get; set; } // Pending, Approved, Rejected

        [BsonElement("submittedDate")]
        public DateTime SubmittedDate { get; set; } = DateTime.UtcNow;

        [BsonElement("attachmentPath")]
        public string AttachmentPath { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;
    }
}

