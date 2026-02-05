using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    /// <summary>
  /// Admin User Model - Main admin authentication table
    /// </summary>
    public class AdminUser
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("admin_user")]
        public string AdminUsername { get; set; }

  [BsonElement("password_hash")]
        public string PasswordHash { get; set; }

   [BsonElement("first_name")]
        public string FirstName { get; set; }

        [BsonElement("middle_name")]
        public string MiddleName { get; set; }

  [BsonElement("last_name")]
        public string LastName { get; set; }

        [BsonElement("user_type")]
        public string UserType { get; set; } // "SuperAdmin", "Admin", "HR"

        [BsonElement("is_active")]
        public bool IsActive { get; set; } = true;

   [BsonElement("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updated_at")]
      public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonIgnore]
      public string FullName => $"{FirstName} {MiddleName} {LastName}".Trim();
    }

    /// <summary>
    /// Admin Session Model - Tracks active admin sessions
    /// </summary>
    public class AdminSession
    {
   [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("admin_user_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string AdminUserId { get; set; }

      [BsonElement("ip_address")]
        public string IpAddress { get; set; }

        [BsonElement("user_agent")]
        public string UserAgent { get; set; }

     [BsonElement("expires_at")]
        public DateTime ExpiresAt { get; set; }

        [BsonElement("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
  }

 /// <summary>
    /// Admin Address Model
    /// </summary>
    public class AdminAddress
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

  [BsonElement("admin_user_id")]
        [BsonRepresentation(BsonType.ObjectId)]
  public string AdminUserId { get; set; }

        [BsonElement("street_address")]
    public string StreetAddress { get; set; }

        [BsonElement("city")]
      public string City { get; set; }

        [BsonElement("state")]
        public string State { get; set; }

        [BsonElement("country")]
        public string Country { get; set; }

        [BsonElement("postal_code")]
        public string PostalCode { get; set; }

        [BsonElement("is_default")]
        public bool IsDefault { get; set; } = true;

        [BsonElement("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Admin Phone Model
    /// </summary>
    public class AdminPhone
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
   public string Id { get; set; }

[BsonElement("admin_user_id")]
        [BsonRepresentation(BsonType.ObjectId)]
    public string AdminUserId { get; set; }

        [BsonElement("phone_number")]
    public string PhoneNumber { get; set; }

        [BsonElement("country_code")]
 public string CountryCode { get; set; } = "+63"; // Philippines

      [BsonElement("is_primary")]
        public bool IsPrimary { get; set; } = true;

    [BsonElement("created_at")]
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Admin Email Model
    /// </summary>
    public class AdminEmail
    {
        [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; }

      [BsonElement("admin_user_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string AdminUserId { get; set; }

        [BsonElement("email")]
   public string Email { get; set; }

     [BsonElement("is_verified")]
    public bool IsVerified { get; set; } = false;

     [BsonElement("verification_token")]
  public string VerificationToken { get; set; }

 [BsonElement("verified_at")]
        public DateTime? VerifiedAt { get; set; }

        [BsonElement("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Admin Permission Model - Defines what actions can be performed
    /// </summary>
    public class AdminPermission
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

   [BsonElement("permission_key")]
        public string PermissionKey { get; set; } // e.g., "payroll.view", "employee.edit"

   [BsonElement("module")]
    public string Module { get; set; } // "Payroll", "Employee", "Recruitment", etc.

 [BsonElement("description")]
        public string Description { get; set; }

        [BsonElement("created_at")]
     public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Admin Role Permission Model - Links roles to permissions
    /// </summary>
    public class AdminRolePermission
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

   [BsonElement("role")]
        public string Role { get; set; } // "SuperAdmin", "Admin", "HR"

      [BsonElement("admin_permission_id")]
        [BsonRepresentation(BsonType.ObjectId)]
        public string AdminPermissionId { get; set; }

        [BsonElement("can_view")]
        public bool CanView { get; set; } = false;

        [BsonElement("can_create")]
   public bool CanCreate { get; set; } = false;

        [BsonElement("can_edit")]
        public bool CanEdit { get; set; } = false;

  [BsonElement("can_delete")]
     public bool CanDelete { get; set; } = false;

    [BsonElement("created_at")]
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
