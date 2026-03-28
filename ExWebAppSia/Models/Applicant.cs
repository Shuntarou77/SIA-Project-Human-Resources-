using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    [BsonIgnoreExtraElements]
    public class Applicant
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // Additional fields from job_applicant collection
        [BsonElement("appointmentStatus")]
        public string AppointmentStatus { get; set; }

        [BsonElement("appointmentToken")]
        public string AppointmentToken { get; set; }

        [BsonElement("appointmentConfirmedDate")]
        public DateTime? AppointmentConfirmedDate { get; set; }

        [BsonElement("rescheduleReason")]
        public string RescheduleReason { get; set; }

        [BsonElement("rescheduleRequestDate")]
        public DateTime? RescheduleRequestDate { get; set; }

        [BsonElement("declineDate")]
        public DateTime? DeclineDate { get; set; }

        [BsonElement("latitude")]
        public double? Latitude { get; set; }

        [BsonElement("longitude")]
        public double? Longitude { get; set; }

        [BsonElement("draftSavedDate")]
        public DateTime? DraftSavedDate { get; set; }

        [BsonElement("referenceNumber")]
        public string ReferenceNumber { get; set; }

        [BsonElement("isDraft")]
        public bool IsDraft { get; set; }

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

        [BsonElement("street")]
        public string Street { get; set; }

        [BsonElement("city")]
        public string City { get; set; }

        [BsonElement("state")]
        public string State { get; set; }

        [BsonElement("country")]
        public string Country { get; set; }

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

        [BsonElement("approvedDate")]
        public DateTime? ApprovedDate { get; set; }

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

        [BsonElement("declineReason")]
        public string DeclineReason { get; set; }

        [BsonElement("isRequirementsComplete")]
        public bool IsRequirementsComplete { get; set; }

        [BsonElement("hasSSS")]
        public bool HasSSS { get; set; }

        [BsonElement("hasPhilHealth")]
        public bool HasPhilHealth { get; set; }

        [BsonElement("hasPagIbig")]
        public bool HasPagIbig { get; set; }

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

        [BsonElement("resumeBase64")]
        public string ResumeBase64 { get; set; }

        [BsonElement("resumeFileType")]
        public string ResumeFileType { get; set; }

        [BsonElement("startingSalary")]
        public decimal StartingSalary { get; set; } = 18000;

        [BsonElement("recruitmentType")]
        public string RecruitmentType { get; set; } = "New Applicant"; // "New Applicant" or "Regularization"

        [BsonElement("linkedEmployeeId")]
        public string LinkedEmployeeId { get; set; } // Reference to Employee ID for regularization

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // Helper property for full name
        [BsonIgnore]
        public string FullName => $"{LastName}, {FirstName}" + (!string.IsNullOrEmpty(MiddleName) ? $" {MiddleName}" : "");
    }
}
