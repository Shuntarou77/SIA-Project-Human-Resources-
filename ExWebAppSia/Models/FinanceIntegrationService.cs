using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// FinanceIntegrationService - Handles payroll to finance system integration (Function 6.5)
    /// </summary>
  public class FinanceIntegrationService
    {
        private readonly IMongoCollection<JournalEntry> _collection;
        private readonly PayRunService _payRunService;

        public FinanceIntegrationService()
{
       var database = MongoDBHelper.GetDatabase();
         _collection = database.GetCollection<JournalEntry>("JournalEntries");
      _payRunService = new PayRunService();
 }

        // ========== FUNCTION 6.5.1: JOURNAL ENTRY GENERATION ==========

        /// <summary>
        /// Generate journal entry from approved payroll
        /// </summary>
        public async Task<JournalEntry> GenerateJournalEntryAsync(string payRunId)
        {
     try
   {
           var payRun = await _payRunService.GetByIdAsync(payRunId);
             if (payRun == null || payRun.Status != "Approved")
     {
   throw new Exception("PayRun must be approved before generating journal entry");
     }

       // Create journal entry header
  var journalEntry = new JournalEntry
             {
    EntryNumber = await GenerateEntryNumberAsync(),
    EntryDate = DateTime.UtcNow,
     PostingDate = payRun.PayDate,
Description = $"Payroll - {payRun.PayPeriodDisplay}",
        Reference = payRunId,
           SourceType = "Payroll",
  Status = "Draft",
            CreatedAt = DateTime.UtcNow,
        CreatedBy = "System"
                };

    // Generate journal entry lines
            int lineNumber = 1;

            // 1. DEBIT: Salary Expense (Total Gross Salary)
      journalEntry.Lines.Add(new JournalEntryLine
  {
   LineNumber = lineNumber++,
                 AccountCode = "5100",
            AccountName = "Salary Expense",
        Description = $"Gross salary for {payRun.PayPeriodDisplay}",
  Debit = payRun.TotalGrossSalary,
        Credit = 0,
           Department = "All"
  });

      // 2. CREDIT: SSS Payable (Total SSS Deductions)
    if (payRun.Items.Sum(i => i.SSSDeduction) > 0)
       {
       journalEntry.Lines.Add(new JournalEntryLine
      {
        LineNumber = lineNumber++,
       AccountCode = "2110",
      AccountName = "SSS Payable",
    Description = "SSS contributions",
          Debit = 0,
          Credit = payRun.Items.Sum(i => i.SSSDeduction)
         });
          }

           // 3. CREDIT: PhilHealth Payable
          if (payRun.Items.Sum(i => i.PhilHealthDeduction) > 0)
         {
  journalEntry.Lines.Add(new JournalEntryLine
      {
 LineNumber = lineNumber++,
  AccountCode = "2120",
          AccountName = "PhilHealth Payable",
            Description = "PhilHealth contributions",
   Debit = 0,
     Credit = payRun.Items.Sum(i => i.PhilHealthDeduction)
    });
       }

    // 4. CREDIT: Pag-IBIG Payable
     if (payRun.Items.Sum(i => i.PagIbigDeduction) > 0)
  {
           journalEntry.Lines.Add(new JournalEntryLine
 {
                  LineNumber = lineNumber++,
       AccountCode = "2130",
      AccountName = "Pag-IBIG Payable",
 Description = "Pag-IBIG contributions",
  Debit = 0,
           Credit = payRun.Items.Sum(i => i.PagIbigDeduction)
      });
      }

      // 5. CREDIT: Tax Payable (Withholding Tax)
          if (payRun.Items.Sum(i => i.WithholdingTax) > 0)
       {
   journalEntry.Lines.Add(new JournalEntryLine
          {
               LineNumber = lineNumber++,
            AccountCode = "2140",
    AccountName = "Withholding Tax Payable",
        Description = "Income tax withheld",
   Debit = 0,
         Credit = payRun.Items.Sum(i => i.WithholdingTax)
      });
         }

    // 6. CREDIT: Loans Payable (SSS Loan)
     if (payRun.Items.Sum(i => i.SSSLoan) > 0)
       {
    journalEntry.Lines.Add(new JournalEntryLine
               {
  LineNumber = lineNumber++,
       AccountCode = "2150",
      AccountName = "SSS Loan Payable",
      Description = "SSS loan deductions",
              Debit = 0,
     Credit = payRun.Items.Sum(i => i.SSSLoan)
 });
           }

        // 7. CREDIT: Pag-IBIG Loan Payable
                if (payRun.Items.Sum(i => i.PagIbigLoan) > 0)
         {
           journalEntry.Lines.Add(new JournalEntryLine
           {
               LineNumber = lineNumber++,
      AccountCode = "2160",
  AccountName = "Pag-IBIG Loan Payable",
        Description = "Pag-IBIG loan deductions",
   Debit = 0,
        Credit = payRun.Items.Sum(i => i.PagIbigLoan)
      });
        }

            // 8. CREDIT: Company Loan Payable
     if (payRun.Items.Sum(i => i.CompanyLoan) > 0)
            {
    journalEntry.Lines.Add(new JournalEntryLine
 {
        LineNumber = lineNumber++,
   AccountCode = "2170",
   AccountName = "Company Loan Payable",
    Description = "Company loan deductions",
              Debit = 0,
          Credit = payRun.Items.Sum(i => i.CompanyLoan)
           });
       }

      // 9. CREDIT: Other Deductions
         if (payRun.Items.Sum(i => i.OtherDeductions) > 0)
            {
           journalEntry.Lines.Add(new JournalEntryLine
{
             LineNumber = lineNumber++,
     AccountCode = "2180",
        AccountName = "Other Payables",
        Description = "Other deductions",
  Debit = 0,
     Credit = payRun.Items.Sum(i => i.OtherDeductions)
        });
        }

          // 10. CREDIT: Cash/Bank Account (Total Net Salary to be paid)
          journalEntry.Lines.Add(new JournalEntryLine
         {
        LineNumber = lineNumber++,
            AccountCode = "1010",
           AccountName = "Cash in Bank - Payroll Account",
Description = $"Net salary payment for {payRun.PayPeriodDisplay}",
             Debit = 0,
        Credit = payRun.TotalNetSalary
     });

            // Recalculate totals
    journalEntry.RecalculateTotals();

         // Save to database
           await _collection.InsertOneAsync(journalEntry);

   return journalEntry;
  }
    catch (Exception ex)
    {
         System.Diagnostics.Debug.WriteLine($"Error generating journal entry: {ex.Message}");
       throw;
            }
        }

      /// <summary>
     /// Generate detailed journal entry by department
 /// </summary>
        public async Task<JournalEntry> GenerateDetailedJournalEntryAsync(string payRunId)
        {
          try
         {
        var payRun = await _payRunService.GetByIdAsync(payRunId);
if (payRun == null || payRun.Status != "Approved")
      {
  throw new Exception("PayRun must be approved before generating journal entry");
   }

        var journalEntry = new JournalEntry
        {
  EntryNumber = await GenerateEntryNumberAsync(),
            EntryDate = DateTime.UtcNow,
         PostingDate = payRun.PayDate,
         Description = $"Payroll (Detailed) - {payRun.PayPeriodDisplay}",
           Reference = payRunId,
     SourceType = "Payroll",
       Status = "Draft",
    CreatedAt = DateTime.UtcNow,
   CreatedBy = "System"
    };

                int lineNumber = 1;

     // Group by department for detailed entries
         var departmentGroups = payRun.Items.GroupBy(i => i.Department);

        foreach (var dept in departmentGroups)
        {
         // DEBIT: Salary Expense by Department
            journalEntry.Lines.Add(new JournalEntryLine
     {
      LineNumber = lineNumber++,
     AccountCode = $"5100-{dept.Key}",
       AccountName = $"Salary Expense - {dept.Key}",
           Description = $"Gross salary for {dept.Key}",
               Debit = dept.Sum(i => i.GrossSalary),
      Credit = 0,
     Department = dept.Key
           });
      }

          // CREDIT: Consolidated deductions (same as summary method)
      if (payRun.Items.Sum(i => i.SSSDeduction) > 0)
    {
  journalEntry.Lines.Add(new JournalEntryLine
     {
     LineNumber = lineNumber++,
      AccountCode = "2110",
    AccountName = "SSS Payable",
 Description = "SSS contributions",
      Debit = 0,
               Credit = payRun.Items.Sum(i => i.SSSDeduction)
     });
        }

      if (payRun.Items.Sum(i => i.PhilHealthDeduction) > 0)
      {
  journalEntry.Lines.Add(new JournalEntryLine
            {
  LineNumber = lineNumber++,
            AccountCode = "2120",
              AccountName = "PhilHealth Payable",
       Description = "PhilHealth contributions",
          Debit = 0,
    Credit = payRun.Items.Sum(i => i.PhilHealthDeduction)
         });
         }

 if (payRun.Items.Sum(i => i.PagIbigDeduction) > 0)
      {
          journalEntry.Lines.Add(new JournalEntryLine
           {
  LineNumber = lineNumber++,
    AccountCode = "2130",
  AccountName = "Pag-IBIG Payable",
             Description = "Pag-IBIG contributions",
          Debit = 0,
       Credit = payRun.Items.Sum(i => i.PagIbigDeduction)
         });
       }

        if (payRun.Items.Sum(i => i.WithholdingTax) > 0)
    {
      journalEntry.Lines.Add(new JournalEntryLine
        {
     LineNumber = lineNumber++,
            AccountCode = "2140",
                 AccountName = "Withholding Tax Payable",
         Description = "Income tax withheld",
 Debit = 0,
             Credit = payRun.Items.Sum(i => i.WithholdingTax)
  });
          }

       if (payRun.Items.Sum(i => i.SSSLoan) > 0)
   {
  journalEntry.Lines.Add(new JournalEntryLine
        {
         LineNumber = lineNumber++,
          AccountCode = "2150",
      AccountName = "SSS Loan Payable",
  Description = "SSS loan deductions",
       Debit = 0,
       Credit = payRun.Items.Sum(i => i.SSSLoan)
  });
      }

          if (payRun.Items.Sum(i => i.PagIbigLoan) > 0)
             {
        journalEntry.Lines.Add(new JournalEntryLine
    {
              LineNumber = lineNumber++,
  AccountCode = "2160",
         AccountName = "Pag-IBIG Loan Payable",
          Description = "Pag-IBIG loan deductions",
   Debit = 0,
     Credit = payRun.Items.Sum(i => i.PagIbigLoan)
         });
        }

          if (payRun.Items.Sum(i => i.CompanyLoan) > 0)
                {
          journalEntry.Lines.Add(new JournalEntryLine
      {
         LineNumber = lineNumber++,
      AccountCode = "2170",
       AccountName = "Company Loan Payable",
     Description = "Company loan deductions",
         Debit = 0,
     Credit = payRun.Items.Sum(i => i.CompanyLoan)
      });
    }

       // CREDIT: Cash in Bank
      journalEntry.Lines.Add(new JournalEntryLine
     {
    LineNumber = lineNumber++,
         AccountCode = "1010",
          AccountName = "Cash in Bank - Payroll Account",
    Description = $"Net salary payment for {payRun.PayPeriodDisplay}",
      Debit = 0,
    Credit = payRun.TotalNetSalary
});

      journalEntry.RecalculateTotals();
 await _collection.InsertOneAsync(journalEntry);

      return journalEntry;
            }
            catch (Exception ex)
            {
     System.Diagnostics.Debug.WriteLine($"Error generating detailed journal entry: {ex.Message}");
      throw;
     }
      }

    // ========== FUNCTION 6.5.2: DATA EXPORT/API SYNC ==========

        /// <summary>
  /// Export journal entry to CSV format
     /// </summary>
        public string ExportJournalEntryToCSV(JournalEntry journalEntry)
        {
            var sb = new StringBuilder();

  // Header
     sb.AppendLine("Entry Number,Entry Date,Posting Date,Description");
       sb.AppendLine($"{journalEntry.EntryNumber},{journalEntry.EntryDate:yyyy-MM-dd},{journalEntry.PostingDate:yyyy-MM-dd},{journalEntry.Description}");
      sb.AppendLine();

  // Column headers
            sb.AppendLine("Line,Account Code,Account Name,Description,Debit,Credit,Department");

          // Lines
  foreach (var line in journalEntry.Lines.OrderBy(l => l.LineNumber))
            {
   sb.AppendLine($"{line.LineNumber},{line.AccountCode},{line.AccountName}," +
       $"\"{line.Description}\",{line.Debit:F2},{line.Credit:F2},{line.Department}");
            }

          // Totals
            sb.AppendLine();
            sb.AppendLine($"TOTALS,,,{journalEntry.TotalDebit:F2},{journalEntry.TotalCredit:F2}");
       sb.AppendLine($"BALANCED,,,{(journalEntry.IsBalanced ? "YES" : "NO")}");

    return sb.ToString();
        }

        /// <summary>
        /// Export journal entry to Excel-compatible format
   /// </summary>
        public string ExportJournalEntryToExcel(JournalEntry journalEntry)
   {
       // Same as CSV but with tab-separated values
      var csv = ExportJournalEntryToCSV(journalEntry);
        return csv.Replace(",", "\t");
        }

        /// <summary>
        /// Export journal entry to QuickBooks IIF format
        /// </summary>
        public string ExportToQuickBooksIIF(JournalEntry journalEntry)
        {
       var sb = new StringBuilder();

       // IIF Header
       sb.AppendLine("!TRNS\tTRNSID\tTRNSTYPE\tDATE\tACCNT\tNAME\tCLASS\tAMOUNT\tDOCNUM\tMEMO");
            sb.AppendLine("!SPL\tSPLID\tTRNSTYPE\tDATE\tACCNT\tNAME\tCLASS\tAMOUNT\tDOCNUM\tMEMO");
            sb.AppendLine("!ENDTRNS");

         // Transaction header
            sb.AppendLine($"TRNS\t\tGENERAL JOURNAL\t{journalEntry.PostingDate:MM/dd/yyyy}\t" +
          $"{journalEntry.Lines[0].AccountName}\t\t\t{journalEntry.Lines[0].Debit - journalEntry.Lines[0].Credit:F2}\t" +
             $"{journalEntry.EntryNumber}\t{journalEntry.Description}");

  // Split lines
            foreach (var line in journalEntry.Lines.Skip(1))
      {
    var amount = line.Debit > 0 ? line.Debit : -line.Credit;
                sb.AppendLine($"SPL\t\tGENERAL JOURNAL\t{journalEntry.PostingDate:MM/dd/yyyy}\t" +
                $"{line.AccountName}\t\t{line.Department}\t{amount:F2}\t" +
      $"{journalEntry.EntryNumber}\t{line.Description}");
            }

            sb.AppendLine("ENDTRNS");

          return sb.ToString();
     }

        /// <summary>
        /// Mark journal entry as synced
        /// </summary>
        public async Task<bool> MarkAsSyncedAsync(string journalEntryId, string syncMethod)
        {
    try
{
    var filter = Builders<JournalEntry>.Filter.Eq(j => j.Id, journalEntryId);
  var update = Builders<JournalEntry>.Update
            .Set(j => j.IsSynced, true)
  .Set(j => j.SyncedAt, DateTime.UtcNow)
         .Set(j => j.SyncMethod, syncMethod)
     .Set(j => j.Status, "Synced")
         .Set(j => j.UpdatedAt, DateTime.UtcNow);

  var result = await _collection.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
 {
                System.Diagnostics.Debug.WriteLine($"Error marking as synced: {ex.Message}");
         return false;
            }
        }

        /// <summary>
        /// Mark journal entry sync as failed
        /// </summary>
    public async Task<bool> MarkSyncFailedAsync(string journalEntryId, string errorMessage)
     {
   try
            {
 var filter = Builders<JournalEntry>.Filter.Eq(j => j.Id, journalEntryId);
    var update = Builders<JournalEntry>.Update
       .Set(j => j.Status, "Failed")
        .Set(j => j.SyncError, errorMessage)
            .Set(j => j.UpdatedAt, DateTime.UtcNow);

                var result = await _collection.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
  catch (Exception ex)
       {
      System.Diagnostics.Debug.WriteLine($"Error marking sync failed: {ex.Message}");
     return false;
  }
        }

        // ========== FUNCTION 6.5.3: SYNC STATUS TRACKING ==========

      /// <summary>
        /// Get all journal entries
        /// </summary>
        public async Task<List<JournalEntry>> GetAllJournalEntriesAsync()
  {
      return await _collection.Find(j => j.IsActive)
   .SortByDescending(j => j.EntryDate)
     .ToListAsync();
        }

        /// <summary>
        /// Get journal entry by ID
        /// </summary>
        public async Task<JournalEntry> GetJournalEntryByIdAsync(string id)
        {
    return await _collection.Find(j => j.Id == id).FirstOrDefaultAsync();
        }

   /// <summary>
        /// Get journal entries by status
        /// </summary>
        public async Task<List<JournalEntry>> GetByStatusAsync(string status)
   {
     return await _collection.Find(j => j.Status == status)
  .SortByDescending(j => j.EntryDate)
.ToListAsync();
   }

        /// <summary>
        /// Get unsynced journal entries
        /// </summary>
        public async Task<List<JournalEntry>> GetUnsyncedEntriesAsync()
        {
     return await _collection.Find(j => !j.IsSynced && j.Status != "Failed")
      .SortBy(j => j.EntryDate)
                .ToListAsync();
        }

     /// <summary>
   /// Get sync history/log
        /// </summary>
        public async Task<Dictionary<string, object>> GetSyncStatusAsync()
        {
  var allEntries = await GetAllJournalEntriesAsync();

 return new Dictionary<string, object>
            {
             ["TotalEntries"] = allEntries.Count,
     ["SyncedEntries"] = allEntries.Count(j => j.IsSynced),
    ["PendingEntries"] = allEntries.Count(j => !j.IsSynced && j.Status != "Failed"),
       ["FailedEntries"] = allEntries.Count(j => j.Status == "Failed"),
         ["LastSyncDate"] = allEntries.Where(j => j.SyncedAt.HasValue)
           .OrderByDescending(j => j.SyncedAt)
      .FirstOrDefault()?.SyncedAt,
      ["RecentFailures"] = allEntries.Where(j => j.Status == "Failed")
 .OrderByDescending(j => j.UpdatedAt)
        .Take(5)
   .Select(j => new
              {
                j.EntryNumber,
   j.Description,
      j.SyncError,
   j.UpdatedAt
   })
             .ToList()
            };
   }

     /// <summary>
        /// Retry failed sync
        /// </summary>
        public async Task<bool> RetryFailedSyncAsync(string journalEntryId)
        {
            try
 {
      var filter = Builders<JournalEntry>.Filter.Eq(j => j.Id, journalEntryId);
      var update = Builders<JournalEntry>.Update
    .Set(j => j.Status, "Draft")
        .Set(j => j.SyncError, null)
    .Set(j => j.UpdatedAt, DateTime.UtcNow);

            var result = await _collection.UpdateOneAsync(filter, update);
        return result.ModifiedCount > 0;
         }
            catch (Exception ex)
            {
     System.Diagnostics.Debug.WriteLine($"Error retrying failed sync: {ex.Message}");
                return false;
     }
        }

        // ========== HELPER METHODS ==========

        /// <summary>
        /// Generate unique journal entry number
        /// </summary>
        private async Task<string> GenerateEntryNumberAsync()
        {
            var year = DateTime.Now.Year;
   var month = DateTime.Now.Month;

            // Get last entry number for this month
            var lastEntry = await _collection
     .Find(j => j.EntryNumber.StartsWith($"JE-{year}-{month:D2}"))
   .SortByDescending(j => j.EntryNumber)
      .FirstOrDefaultAsync();

       int nextNumber = 1;
  if (lastEntry != null && !string.IsNullOrEmpty(lastEntry.EntryNumber))
            {
 var parts = lastEntry.EntryNumber.Split('-');
             if (parts.Length == 4 && int.TryParse(parts[3], out int lastNumber))
                {
                    nextNumber = lastNumber + 1;
            }
    }

       return $"JE-{year}-{month:D2}-{nextNumber:D3}";
        }

        /// <summary>
        /// Post journal entry (mark as posted)
        /// </summary>
        public async Task<bool> PostJournalEntryAsync(string journalEntryId)
        {
      try
          {
        var journalEntry = await GetJournalEntryByIdAsync(journalEntryId);
           if (journalEntry == null || !journalEntry.IsBalanced)
          {
           throw new Exception("Journal entry must be balanced before posting");
   }

       var filter = Builders<JournalEntry>.Filter.Eq(j => j.Id, journalEntryId);
      var update = Builders<JournalEntry>.Update
           .Set(j => j.Status, "Posted")
          .Set(j => j.UpdatedAt, DateTime.UtcNow);

var result = await _collection.UpdateOneAsync(filter, update);
          return result.ModifiedCount > 0;
}
          catch (Exception ex)
      {
              System.Diagnostics.Debug.WriteLine($"Error posting journal entry: {ex.Message}");
    return false;
    }
        }

     /// <summary>
   /// Delete journal entry
        /// </summary>
        public async Task<bool> DeleteJournalEntryAsync(string journalEntryId)
        {
   try
     {
        var filter = Builders<JournalEntry>.Filter.Eq(j => j.Id, journalEntryId);
    var update = Builders<JournalEntry>.Update
           .Set(j => j.IsActive, false)
        .Set(j => j.UpdatedAt, DateTime.UtcNow);

   var result = await _collection.UpdateOneAsync(filter, update);
        return result.ModifiedCount > 0;
 }
       catch (Exception ex)
            {
         System.Diagnostics.Debug.WriteLine($"Error deleting journal entry: {ex.Message}");
      return false;
    }
     }
    }
}
