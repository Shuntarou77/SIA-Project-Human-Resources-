using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Announcement
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("content")]
        public string Content { get; set; }

        [BsonElement("postedBy")]
        public string PostedBy { get; set; }

        [BsonElement("department")]
        public string Department { get; set; }

        [BsonElement("postedDate")]
        public DateTime PostedDate { get; set; } = DateTime.UtcNow;

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("isPinned")]
        public bool IsPinned { get; set; } = false;
    }
}