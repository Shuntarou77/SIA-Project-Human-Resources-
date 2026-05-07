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

        [BsonElement("civilStatus")]
        public string CivilStatus { get; set; }

        [BsonElement("educationLevel")]
        public string EducationLevel { get; set; }

        [BsonElement("school")]
        public string School { get; set; }

        [BsonElement("degree")]
        public string Degree { get; set; }

        [BsonElement("guardianName")]
        public string GuardianName { get; set; }

        [BsonElement("guardianRelationship")]
        public string GuardianRelationship { get; set; }

        [BsonElement("guardianContactNo")]
        public string GuardianContactNo { get; set; }

        [BsonElement("guardianEmail")]
        public string GuardianEmail { get; set; }

        [BsonElement("guardianHomeAddress")]
        public string GuardianHomeAddress { get; set; }

        [BsonElement("previousCompanyName")]
        public string PreviousCompanyName { get; set; }

        [BsonElement("previousPosition")]
        public string PreviousPosition { get; set; }

        [BsonElement("yearsOfExperience")]
        public int YearsOfExperience { get; set; }

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

        [BsonElement("resignationStatus")]
        public string ResignationStatus { get; set; } = "None"; // None, Pending, Approved

        [BsonElement("resignationDate")]
        public DateTime? ResignationDate { get; set; }

        [BsonElement("resignationLastDay")]
        public DateTime? ResignationLastDay { get; set; }

        [BsonElement("resignationNoticeDays")]
        public int ResignationNoticeDays { get; set; }

        [BsonElement("resignationShortfallDays")]
        public int ResignationShortfallDays { get; set; }

        [BsonElement("resignationReasonCode")]
        public string ResignationReasonCode { get; set; }

        [BsonElement("resignationLetterPath")]
        public string ResignationLetterPath { get; set; }

        [BsonElement("resignationReason")]
        public string ResignationReason { get; set; }

        [BsonElement("availabilityStatus")]
        public string AvailabilityStatus { get; set; } = "Available"; // "Available", "Unavailable"

        [BsonIgnore]
        public bool IsUnavailable => AvailabilityStatus == "Unavailable";

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
        public string FullName => $"{LastName}, {FirstName}{(string.IsNullOrEmpty(MiddleName) ? "" : " " + MiddleName)}";

        [BsonIgnore]
        public int? CalculatedAge
        {
            get
            {
                if (!BirthDate.HasValue) return Age;
                var today = DateTime.Today;
                var age = today.Year - BirthDate.Value.Year;
                if (BirthDate.Value.Date > today.AddYears(-age)) age--;
                return age;
            }
        }
    }
}

