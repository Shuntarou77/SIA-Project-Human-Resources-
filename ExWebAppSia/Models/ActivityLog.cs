using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    [BsonIgnoreExtraElements]
    public class ActivityLog
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("hrUsername")]
        public string HRUsername { get; set; }

        [BsonElement("hrName")]
        public string HRName { get; set; }

        [BsonElement("action")]
        public string Action { get; set; }

        [BsonElement("module")]
        public string Module { get; set; } // e.g., "Recruitment", "Employee", "Payroll", "Announcement"

        [BsonElement("targetInfo")]
        public string TargetInfo { get; set; } // e.g., applicant name, employee ID, announcement title

        [BsonElement("timestamp")]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }
}
