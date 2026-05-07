using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    [BsonIgnoreExtraElements]
    public class Notification
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("recipientId")]
        public string RecipientId { get; set; } // Specific EmployeeId, "ADMIN" for all HR/Admins, or "ALL" for everyone

        [BsonElement("title")]
        public string Title { get; set; }

        [BsonElement("message")]
        public string Message { get; set; }

        [BsonElement("type")]
        public string Type { get; set; } // "RequestUpdate", "NewRequest", "Announcement"

        [BsonElement("link")]
        public string Link { get; set; } // Optional link to the relevant page

        [BsonElement("timestamp")]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        [BsonElement("isRead")]
        public bool IsRead { get; set; } = false;

        [BsonElement("relatedId")]
        public string RelatedId { get; set; } // ID of the Leave/OT/UT record

        [BsonElement("priority")]
        public string Priority { get; set; } = "Normal"; // "Normal", "High"
    }
}
