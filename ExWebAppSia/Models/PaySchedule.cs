using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PaySchedule Model - Company-wide pay period configuration (6.1.3)
    /// </summary>
    public class PaySchedule
    {
        [BsonId]
 [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; }

        // Pay Schedule Type
        [BsonElement("scheduleType")]
   public string ScheduleType { get; set; } // "Semi-Monthly", "Monthly", "Weekly", "Bi-Weekly"

        [BsonElement("payFrequency")]
        public int PayFrequency { get; set; } // How many times per month (2 for semi-monthly, 1 for monthly)

        // Cut-off Dates (for Semi-Monthly)
        [BsonElement("firstCutoffDay")]
   public int? FirstCutoffDay { get; set; } // e.g., 15 (for 1st-15th period)

        [BsonElement("secondCutoffDay")]
  public int? SecondCutoffDay { get; set; } // e.g., 30/31 (for 16th-end period)

        // Pay Dates (when salaries are released)
        [BsonElement("firstPayDay")]
        public int? FirstPayDay { get; set; } // e.g., 20th (5 days after 1st cutoff)

        [BsonElement("secondPayDay")]
      public int? SecondPayDay { get; set; } // e.g., 5th of next month

      // Monthly Schedule (if monthly)
        [BsonElement("monthlyCutoffDay")]
        public int? MonthlyCutoffDay { get; set; } // e.g., Last day of month

        [BsonElement("monthlyPayDay")]
        public int? MonthlyPayDay { get; set; } // e.g., 5th of next month

        // Working Days Configuration
        [BsonElement("totalWorkingDaysPerMonth")]
        public int TotalWorkingDaysPerMonth { get; set; } = 22; // Default: 22 working days

     [BsonElement("workingHoursPerDay")]
        public int WorkingHoursPerDay { get; set; } = 8; // Default: 8 hours

        // Metadata
        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
      public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("createdBy")]
        public string CreatedBy { get; set; }

// Computed Properties
        [BsonIgnore]
        public string DisplaySchedule
   {
       get
       {
if (ScheduleType == "Semi-Monthly")
  return $"Semi-Monthly: 1st-{FirstCutoffDay}th (pay on {FirstPayDay}th) & {FirstCutoffDay + 1}th-End (pay on {SecondPayDay}th)";
                else if (ScheduleType == "Monthly")
 return $"Monthly: Pay on {MonthlyPayDay}th of next month";
       else
               return ScheduleType;
            }
        }
    }
}
