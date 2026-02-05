using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// Service for managing Pay Schedule Configuration (Function 6.1.3)
    /// Handles company-wide payroll schedule settings
    /// </summary>
    public class PayScheduleService
    {
      private readonly IMongoCollection<PaySchedule> _collection;

     public PayScheduleService()
        {
            var database = MongoDBHelper.GetDatabase();
            _collection = database.GetCollection<PaySchedule>("PaySchedules");
    }

  // ========== CREATE ==========

    /// <summary>
        /// Create new pay schedule configuration (6.1.3)
      /// </summary>
        public async Task<PaySchedule> CreateAsync(PaySchedule schedule)
        {
            // Deactivate existing active schedules first
await DeactivateAllAsync();

   schedule.CreatedAt = DateTime.UtcNow;
  schedule.UpdatedAt = DateTime.UtcNow;
   schedule.IsActive = true;

     await _collection.InsertOneAsync(schedule);
       return schedule;
     }

        // ========== READ ==========

        /// <summary>
/// Get the current active pay schedule
        /// </summary>
        public async Task<PaySchedule> GetActiveScheduleAsync()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[PayScheduleService] GetActiveScheduleAsync START");
                System.Diagnostics.Debug.WriteLine("[PayScheduleService] Building filter for IsActive=true");
                
                var filter = Builders<PaySchedule>.Filter.Eq(s => s.IsActive, true);
                
                System.Diagnostics.Debug.WriteLine("[PayScheduleService] Executing Find query...");
                var result = await _collection.Find(filter).FirstOrDefaultAsync().ConfigureAwait(false);
                
                System.Diagnostics.Debug.WriteLine($"[PayScheduleService] Query returned: {(result == null ? "NULL" : "PaySchedule found")}");
                
                if (result != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[PayScheduleService] Schedule Type: {result.ScheduleType}, IsActive: {result.IsActive}");
                }
                
                return result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PayScheduleService] ERROR: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[PayScheduleService] Stack: {ex.StackTrace}");
                throw;
            }
        }

     /// <summary>
        /// Get schedule by ID
        /// </summary>
        public async Task<PaySchedule> GetByIdAsync(string id)
        {
       var filter = Builders<PaySchedule>.Filter.Eq(s => s.Id, id);
         return await _collection.Find(filter).FirstOrDefaultAsync();
        }

        /// <summary>
        /// Get all pay schedules (including inactive)
        /// </summary>
      public async Task<List<PaySchedule>> GetAllAsync()
        {
   return await _collection.Find(_ => true)
             .SortByDescending(s => s.CreatedAt)
           .ToListAsync();
        }

        /// <summary>
        /// Check if pay schedule exists
        /// </summary>
        public async Task<bool> ExistsAsync()
        {
            var filter = Builders<PaySchedule>.Filter.Eq(s => s.IsActive, true);
            var count = await _collection.CountDocumentsAsync(filter);
   return count > 0;
     }

  // ========== UPDATE ==========

        /// <summary>
    /// Update pay schedule configuration
        /// </summary>
        public async Task<bool> UpdateAsync(string id, PaySchedule schedule)
{
     schedule.UpdatedAt = DateTime.UtcNow;

         var filter = Builders<PaySchedule>.Filter.Eq(s => s.Id, id);
     var update = Builders<PaySchedule>.Update
.Set(s => s.ScheduleType, schedule.ScheduleType)
      .Set(s => s.PayFrequency, schedule.PayFrequency)
 .Set(s => s.FirstCutoffDay, schedule.FirstCutoffDay)
           .Set(s => s.SecondCutoffDay, schedule.SecondCutoffDay)
    .Set(s => s.FirstPayDay, schedule.FirstPayDay)
        .Set(s => s.SecondPayDay, schedule.SecondPayDay)
.Set(s => s.MonthlyCutoffDay, schedule.MonthlyCutoffDay)
          .Set(s => s.MonthlyPayDay, schedule.MonthlyPayDay)
              .Set(s => s.TotalWorkingDaysPerMonth, schedule.TotalWorkingDaysPerMonth)
                .Set(s => s.WorkingHoursPerDay, schedule.WorkingHoursPerDay)
     .Set(s => s.UpdatedAt, schedule.UpdatedAt);

       var result = await _collection.UpdateOneAsync(filter, update);
 return result.ModifiedCount > 0;
        }

        // ========== DELETE ==========

        /// <summary>
        /// Deactivate all pay schedules
        /// </summary>
        public async Task<bool> DeactivateAllAsync()
        {
  var filter = Builders<PaySchedule>.Filter.Eq(s => s.IsActive, true);
        var update = Builders<PaySchedule>.Update
  .Set(s => s.IsActive, false)
      .Set(s => s.UpdatedAt, DateTime.UtcNow);

   var result = await _collection.UpdateManyAsync(filter, update);
            return result.ModifiedCount > 0;
        }

        /// <summary>
        /// Activate a specific schedule
     /// </summary>
    public async Task<bool> ActivateAsync(string id)
        {
            // Deactivate all first
       await DeactivateAllAsync();

            // Activate the selected one
      var filter = Builders<PaySchedule>.Filter.Eq(s => s.Id, id);
          var update = Builders<PaySchedule>.Update
     .Set(s => s.IsActive, true)
              .Set(s => s.UpdatedAt, DateTime.UtcNow);

          var result = await _collection.UpdateOneAsync(filter, update);
            return result.ModifiedCount > 0;
        }

      /// <summary>
        /// Hard delete schedule
        /// </summary>
        public async Task<bool> DeleteAsync(string id)
     {
            var filter = Builders<PaySchedule>.Filter.Eq(s => s.Id, id);
            var result = await _collection.DeleteOneAsync(filter);
          return result.DeletedCount > 0;
    }

  // ========== HELPER METHODS ==========

        /// <summary>
        /// Calculate pay period dates for current month
 /// </summary>
   public async Task<(DateTime startDate, DateTime endDate, DateTime payDate)> GetCurrentPayPeriodAsync()
        {
            var schedule = await GetActiveScheduleAsync();
    if (schedule == null)
         throw new Exception("No active pay schedule configured");

        var today = DateTime.Today;
    var year = today.Year;
          var month = today.Month;

            DateTime startDate, endDate, payDate;

  if (schedule.ScheduleType == "Semi-Monthly")
    {
      int firstCutoff = schedule.FirstCutoffDay ?? 15;
    int secondCutoff = schedule.SecondCutoffDay ?? DateTime.DaysInMonth(year, month);
                int firstPay = schedule.FirstPayDay ?? 20;
     int secondPay = schedule.SecondPayDay ?? 5;

     if (today.Day <= firstCutoff)
    {
   // First period (1st to 15th)
              startDate = new DateTime(year, month, 1);
  endDate = new DateTime(year, month, firstCutoff);
       payDate = new DateTime(year, month, firstPay);
      }
         else
       {
  // Second period (16th to end)
  startDate = new DateTime(year, month, firstCutoff + 1);
                    endDate = new DateTime(year, month, DateTime.DaysInMonth(year, month));
       
  // Pay date is in next month
     var nextMonth = month == 12 ? 1 : month + 1;
   var nextYear = month == 12 ? year + 1 : year;
     payDate = new DateTime(nextYear, nextMonth, secondPay);
       }
            }
        else // Monthly
     {
              int cutoffDay = schedule.MonthlyCutoffDay ?? DateTime.DaysInMonth(year, month);
          int payDay = schedule.MonthlyPayDay ?? 5;

        startDate = new DateTime(year, month, 1);
   endDate = new DateTime(year, month, cutoffDay);

// Pay date is in next month
     var nextMonth = month == 12 ? 1 : month + 1;
      var nextYear = month == 12 ? year + 1 : year;
         payDate = new DateTime(nextYear, nextMonth, payDay);
   }

          return (startDate, endDate, payDate);
   }

        /// <summary>
/// Get pay period for a specific date
        /// </summary>
      public async Task<(DateTime startDate, DateTime endDate)> GetPayPeriodForDateAsync(DateTime date)
  {
            var schedule = await GetActiveScheduleAsync();
            if (schedule == null)
    throw new Exception("No active pay schedule configured");

          var year = date.Year;
            var month = date.Month;

      DateTime startDate, endDate;

            if (schedule.ScheduleType == "Semi-Monthly")
   {
      int firstCutoff = schedule.FirstCutoffDay ?? 15;

    if (date.Day <= firstCutoff)
                {
     startDate = new DateTime(year, month, 1);
endDate = new DateTime(year, month, firstCutoff);
 }
   else
     {
         startDate = new DateTime(year, month, firstCutoff + 1);
    endDate = new DateTime(year, month, DateTime.DaysInMonth(year, month));
   }
          }
            else // Monthly
            {
    startDate = new DateTime(year, month, 1);
        endDate = new DateTime(year, month, DateTime.DaysInMonth(year, month));
            }

         return (startDate, endDate);
     }

        /// <summary>
        /// Calculate number of working days in a period
        /// </summary>
        public int CalculateWorkingDays(DateTime startDate, DateTime endDate)
        {
       int workingDays = 0;
      for (var date = startDate; date <= endDate; date = date.AddDays(1))
   {
     // Exclude Saturdays and Sundays
       if (date.DayOfWeek != DayOfWeek.Saturday && date.DayOfWeek != DayOfWeek.Sunday)
         {
          workingDays++;
 }
       }
            return workingDays;
    }
    }
}
