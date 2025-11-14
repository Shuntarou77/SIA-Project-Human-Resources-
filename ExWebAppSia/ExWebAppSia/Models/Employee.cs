using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Employee
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employeeId")]
        public string EmployeeId { get; set; } // e.g., "23-2211"

        [BsonElement("firstName")]
        public string FirstName { get; set; }

        [BsonElement("middleName")]
        public string MiddleName { get; set; }

        [BsonElement("lastName")]
        public string LastName { get; set; }

        [BsonElement("email")]
        public string Email { get; set; }

        [BsonElement("contactNo")]
        public string ContactNo { get; set; }

        [BsonElement("address")]
        public string Address { get; set; }

        [BsonElement("department")]
        public string Department { get; set; } // The position/department they were hired for

        [BsonElement("role")]
        public string Role { get; set; } // Job role/title

        [BsonElement("hiredDate")]
        public DateTime HiredDate { get; set; } = DateTime.UtcNow;

        [BsonElement("applicantId")]
        public string ApplicantId { get; set; } // Reference to original applicant record

        [BsonElement("contractType")]
        public string ContractType { get; set; } // "Regular" or "Contractual"

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // Helper property for full name
        [BsonIgnore]
        public string FullName => $"{LastName}, {FirstName}" + (!string.IsNullOrEmpty(MiddleName) ? $" {MiddleName}" : "");
    }
}

