using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;

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

        [BsonElement("hasImage")]
        public bool HasImage { get; set; } = false;

        [BsonElement("imagePath")]
        public string ImagePath { get; set; }

        [BsonElement("hasVideo")]
        public bool HasVideo { get; set; } = false;

        [BsonElement("videoPath")]
        public string VideoPath { get; set; }

        [BsonElement("mediaUrls")]
        public List<string> MediaUrls { get; set; } = new List<string>();
    }
}