using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    public class User
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // ========== AUTHENTICATION FIELDS ==========
        [BsonElement("username")]
        public string Username { get; set; }

        [BsonElement("password")]
        public string Password { get; set; } // Hashed password

        [BsonElement("role")]
        public string Role { get; set; } // "Admin", "Employee", "HR"

        [BsonElement("email")]
        public string Email { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        // ========== EMPLOYEE FIELDS (Previously in Employee table) ==========
        [BsonElement("employeeId")]
        public string EmployeeId { get; set; } // e.g., "25-2211"

        [BsonElement("firstName")]
        public string FirstName { get; set; }

        [BsonElement("middleName")]
        public string MiddleName { get; set; }

        [BsonElement("lastName")]
        public string LastName { get; set; }

        [BsonElement("contactNo")]
        public string ContactNo { get; set; }

        [BsonElement("address")]
        public string Address { get; set; }

        [BsonElement("age")]
        public int? Age { get; set; }

        [BsonElement("birthdate")] // Changed from "birthDate" to "birthdate" to match MongoDB field
        public DateTime? BirthDate { get; set; }

        [BsonElement("gender")]
        public string Gender { get; set; } // "Male", "Female"

        [BsonElement("department")]
        public string Department { get; set; } // Department they work in

        [BsonElement("position")]
        public string Position { get; set; } // Job role/title (formerly "role" in Employee)

        [BsonElement("hiredDate")]
        public DateTime? HiredDate { get; set; }

        [BsonElement("applicantId")]
        public string ApplicantId { get; set; } // Reference to original applicant record

        [BsonElement("contractType")]
        public string ContractType { get; set; } // "Regular" or "Contractual"

        // ========== PAYROLL & BANKING FIELDS (Function 6.3.3 & 6.3.4) ==========
        [BsonElement("bankAccountNumber")]
        public string BankAccountNumber { get; set; } // Employee's bank account

        [BsonElement("bankName")]
        public string BankName { get; set; } // Bank name (e.g., "BPI", "BDO", "Metrobank")

        [BsonElement("bankAccountType")]
        public string BankAccountType { get; set; } // "Savings", "Checking"

        [BsonElement("paymentStatus")]
        public string PaymentStatus { get; set; } // "Unpaid", "Paid", "Pending"

        [BsonElement("lastPaymentDate")]
        public DateTime? LastPaymentDate { get; set; } // Last time salary was paid

        [BsonElement("lastPayRunId")]
        public string LastPayRunId { get; set; } // Reference to last PayRun

        // ========== HELPER PROPERTIES ==========
        [BsonIgnore]
        public string FullName
        {
            get
            {
                if (string.IsNullOrEmpty(FirstName) && string.IsNullOrEmpty(LastName))
                    return Username; // Fallback to username for admin accounts

                return $"{LastName}, {FirstName}" + (!string.IsNullOrEmpty(MiddleName) ? $" {MiddleName}" : "");
            }
        }

        [BsonIgnore]
        public bool IsEmployee => Role == "Employee";

        [BsonIgnore]
        public bool IsAdmin => Role == "Admin" || Role == "HR";

        [BsonIgnore]
        public bool HasBankAccount => !string.IsNullOrEmpty(BankAccountNumber);

        [BsonIgnore]
        public bool IsPaid => PaymentStatus == "Paid";
    }
}