using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// JournalEntry Model - Accounting journal entry for finance integration (Function 6.5.1)
    /// </summary>
    public class JournalEntry
    {
        [BsonId]
   [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        // ========== JOURNAL ENTRY HEADER ==========

    [BsonElement("entryNumber")]
   public string EntryNumber { get; set; } // e.g., "JE-2025-01-001"

        [BsonElement("entryDate")]
        public DateTime EntryDate { get; set; } // Date of entry

        [BsonElement("postingDate")]
        public DateTime PostingDate { get; set; } // When it should be posted to GL

        [BsonElement("description")]
  public string Description { get; set; } // e.g., "Payroll for Jan 1-15, 2025"

        [BsonElement("reference")]
        public string Reference { get; set; } // Reference to source document (PayRunId)

   [BsonElement("sourceType")]
      public string SourceType { get; set; } // "Payroll", "Manual", "Adjustment"

        // ========== JOURNAL ENTRY LINES ==========

    [BsonElement("lines")]
        public List<JournalEntryLine> Lines { get; set; } = new List<JournalEntryLine>();

        // ========== TOTALS ==========

        [BsonElement("totalDebit")]
        public decimal TotalDebit { get; set; }

        [BsonElement("totalCredit")]
        public decimal TotalCredit { get; set; }

        // ========== STATUS & SYNC ==========

 [BsonElement("status")]
        public string Status { get; set; } // "Draft", "Posted", "Synced", "Failed"

        [BsonElement("isBalanced")]
        public bool IsBalanced { get; set; } // Debit = Credit?

        [BsonElement("isSynced")]
      public bool IsSynced { get; set; } = false;

  [BsonElement("syncedAt")]
  public DateTime? SyncedAt { get; set; }

        [BsonElement("syncMethod")]
        public string SyncMethod { get; set; } // "CSV", "API", "Manual"

        [BsonElement("syncError")]
public string SyncError { get; set; } // Error message if sync failed

  // ========== METADATA ==========

        [BsonElement("createdAt")]
      public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("createdBy")]
  public string CreatedBy { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

    // ========== COMPUTED PROPERTIES ==========

   /// <summary>
        /// Check if debits equal credits
    /// </summary>
      [BsonIgnore]
        public bool IsValid => Math.Abs(TotalDebit - TotalCredit) < 0.01m;

        /// <summary>
        /// Display-friendly status color
        /// </summary>
        [BsonIgnore]
        public string StatusColor
    {
get
        {
                if (Status == "Draft") return "#9CA3AF";
       if (Status == "Posted") return "#3B82F6";
           if (Status == "Synced") return "#10B981";
    if (Status == "Failed") return "#EF4444";
   return "#6B7280";
       }
        }

  /// <summary>
     /// Recalculate totals from lines
        /// </summary>
        public void RecalculateTotals()
        {
 TotalDebit = Lines?.Sum(l => l.Debit) ?? 0;
       TotalCredit = Lines?.Sum(l => l.Credit) ?? 0;
          IsBalanced = IsValid;
            UpdatedAt = DateTime.UtcNow;
        }
    }

    /// <summary>
    /// JournalEntryLine - Individual line item in journal entry
    /// </summary>
    public class JournalEntryLine
    {
     [BsonElement("lineNumber")]
        public int LineNumber { get; set; } // 1, 2, 3...

        [BsonElement("accountCode")]
        public string AccountCode { get; set; } // GL account code (e.g., "5100", "2110")

      [BsonElement("accountName")]
        public string AccountName { get; set; } // GL account name (e.g., "Salary Expense", "SSS Payable")

    [BsonElement("description")]
    public string Description { get; set; } // Line description

        [BsonElement("debit")]
        public decimal Debit { get; set; } // Debit amount

   [BsonElement("credit")]
        public decimal Credit { get; set; } // Credit amount

        [BsonElement("department")]
   public string Department { get; set; } // Department/Cost center

        [BsonElement("employeeId")]
     public string EmployeeId { get; set; } // Employee reference (if applicable)

        /// <summary>
        /// Display amount with Dr/Cr indicator
        /// </summary>
        [BsonIgnore]
public string AmountDisplay => Debit > 0 ? $"?{Debit:N2} Dr" : $"?{Credit:N2} Cr";
    }
}
