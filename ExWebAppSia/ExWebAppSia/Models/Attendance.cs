using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Attendance
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; } // e.g., "23-2211"

        [BsonElement("employeeName")]
        public string EmployeeName { get; set; } // e.g., "Padilla, Dan Jerciey"

        [BsonElement("department")]
        public string Department { get; set; } // e.g., "Research & Development"

        [BsonElement("date")]
        public DateTime Date { get; set; } // The date of attendance (without time)

        [BsonElement("timeIn")]
        public DateTime? TimeIn { get; set; } // Time in timestamp

        [BsonElement("timeOut")]
        public DateTime? TimeOut { get; set; } // Time out timestamp

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;
    }
}

