using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class Applicant
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // Personal Info
        [BsonElement("firstName")]
        public string FirstName { get; set; }

        [BsonElement("middleName")]
        public string MiddleName { get; set; }

        [BsonElement("lastName")]
        public string LastName { get; set; }

        [BsonElement("age")]
        public int? Age { get; set; }

        [BsonElement("birthDate")]
        public DateTime? BirthDate { get; set; }

        [BsonElement("gender")]
        public string Gender { get; set; }

        [BsonElement("email")]
        public string Email { get; set; }

        [BsonElement("contactNo")]
        public string ContactNo { get; set; }

        [BsonElement("address")]
        public string Address { get; set; }

        [BsonElement("education")]
        public string Education { get; set; }

        // Previous Company Info
        [BsonElement("hasPreviousCompany")]
        public bool HasPreviousCompany { get; set; }

        [BsonElement("previousCompanyName")]
        public string PreviousCompanyName { get; set; }

        [BsonElement("jobIndustry")]
        public string JobIndustry { get; set; }

        [BsonElement("years")]
        public int? Years { get; set; }

        [BsonElement("months")]
        public int? Months { get; set; }

        [BsonElement("previousPosition")]
        public string PreviousPosition { get; set; }

        // Guardian Info
        [BsonElement("guardianName")]
        public string GuardianName { get; set; }

        [BsonElement("guardianContactNo")]
        public string GuardianContactNo { get; set; }

        [BsonElement("guardianEmail")]
        public string GuardianEmail { get; set; }

        [BsonElement("guardianHomeAddress")]
        public string GuardianHomeAddress { get; set; }

                // Application Info
                [BsonElement("appliedPosition")]
                public string AppliedPosition { get; set; } // Department

                [BsonElement("role")]
                public string Role { get; set; } // Job Title/Position

                [BsonElement("howDidYouHearUs")]
                public string HowDidYouHearUs { get; set; }

        [BsonElement("referralName")]
        public string ReferralName { get; set; }

        [BsonElement("contractType")]
        public string ContractType { get; set; } // "Regular" or "Contractual"

        [BsonElement("hiringType")]
        public string HiringType { get; set; } // "Employee" or "Manager"

        [BsonElement("status")]
        public string Status { get; set; } // "New", "In-Progress", "Scheduled", "Rejected", "Hired"

        [BsonElement("appliedDate")]
        public DateTime AppliedDate { get; set; } = DateTime.UtcNow;

        [BsonElement("notes")]
        public string Notes { get; set; }

        // Interview Information
        [BsonElement("interviewDate")]
        public DateTime? InterviewDate { get; set; }

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
        public DateTime? ScheduledDate { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // Helper property for full name
        [BsonIgnore]
        public string FullName => $"{LastName}, {FirstName}" + (!string.IsNullOrEmpty(MiddleName) ? $" {MiddleName}" : "");
    }
}
