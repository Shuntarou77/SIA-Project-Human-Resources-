using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    [BsonIgnoreExtraElements]
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

        [BsonElement("street")]
        public string Street { get; set; }

        [BsonElement("city")]
        public string City { get; set; }

        [BsonElement("state")]
        public string State { get; set; }

        [BsonElement("country")]
        public string Country { get; set; }

        [BsonElement("age")]
        public int? Age { get; set; }

        [BsonElement("birthDate")]
        public DateTime? BirthDate { get; set; }

        [BsonElement("gender")]
        public string Gender { get; set; }

        [BsonElement("department")]
        public string Department { get; set; } // The position/department they were hired for

        [BsonElement("role")]
        public string Role { get; set; } // Job Title / Position

        [BsonElement("position")]
        public string Position { get; set; } // Specific role within department

        [BsonElement("hiredDate")]
        public DateTime HiredDate { get; set; } = DateTime.UtcNow;

        [BsonElement("applicantId")]
        public string ApplicantId { get; set; } // Reference to original applicant record

        [BsonElement("contractType")]
        public string ContractType { get; set; } // "Regular" or "Probationary"

        [BsonElement("hasSSS")]
        public bool HasSSS { get; set; }

        [BsonElement("hasPhilHealth")]
        public bool HasPhilHealth { get; set; }

        [BsonElement("hasPagIbig")]
        public bool HasPagIbig { get; set; }

        [BsonElement("baseSalary")]
        public decimal BaseSalary { get; set; }

        [BsonElement("sssNumber")]
        public string SSSNumber { get; set; }

        [BsonElement("philHealthNumber")]
        public string PhilHealthNumber { get; set; }

        [BsonElement("pagIbigNumber")]
        public string PagIbigNumber { get; set; }

        [BsonElement("resumePath")]
        public string ResumePath { get; set; }

        [BsonElement("resumeFileName")]
        public string ResumeFileName { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // Auto-calculate employment status based on HiredDate (6 months rule)
        [BsonIgnore]
        public string EmploymentStatus 
        {
            get 
            {
                if (HiredDate == DateTime.MinValue) return "Probationary";
                var sixMonthsAgo = DateTime.UtcNow.AddMonths(-6);
                return HiredDate <= sixMonthsAgo ? "Regular" : "Probationary";
            }
        }

        // Helper property for full name
        [BsonIgnore]
        public string FullName => $"{LastName}, {FirstName}" + (!string.IsNullOrEmpty(MiddleName) ? $" {MiddleName}" : "");
    }
}

