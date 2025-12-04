using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class EmployeeConcern
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; }

        [BsonElement("concernType")]
        public string ConcernType { get; set; } // Workplace Issue, Harassment, Safety, Payroll, Benefits, Equipment, Suggestion, Other

        [BsonElement("subject")]
        public string Subject { get; set; }

        [BsonElement("description")]
        public string Description { get; set; }

        [BsonElement("priorityLevel")]
        public string PriorityLevel { get; set; } // Low, Medium, High, Urgent

        [BsonElement("status")]
        public string Status { get; set; } // Pending, In Progress, Resolved, Closed

        [BsonElement("submittedDate")]
        public DateTime SubmittedDate { get; set; } = DateTime.UtcNow;

        [BsonElement("supportingDocuments")]
        public string[] SupportingDocuments { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;
    }
}

