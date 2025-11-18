    using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Interview
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("applicantId")]
        public string ApplicantId { get; set; }

        [BsonElement("applicantName")]
        public string ApplicantName { get; set; }

        [BsonElement("interviewDate")]
        public DateTime InterviewDate { get; set; }

        [BsonElement("interviewTime")]
        public string InterviewTime { get; set; }

        [BsonElement("interviewLocation")]
        public string InterviewLocation { get; set; }

        [BsonElement("interviewerName")]
        public string InterviewerName { get; set; }

        [BsonElement("interviewNotes")]
        public string InterviewNotes { get; set; }

        [BsonElement("scheduledBy")]
        public string ScheduledBy { get; set; }

        [BsonElement("scheduledDate")]
        public DateTime ScheduledDate { get; set; } = DateTime.UtcNow;

        [BsonElement("status")]
        public string Status { get; set; } // "Scheduled", "Completed", "Cancelled", "No Show"

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;
    }
}

