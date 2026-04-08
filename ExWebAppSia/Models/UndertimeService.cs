using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class UndertimeService
    {
        private readonly IMongoCollection<UndertimeRecord> _undertime;

        public UndertimeService()
        {
            _undertime = MongoDBHelper.GetUndertimeCollection();
        }

        public async Task<bool> RecordUndertimeAsync(UndertimeRecord record)
        {
            try
            {
                // Check if already recorded for this attendance
                var existing = await _undertime.Find(u => u.AttendanceId == record.AttendanceId).FirstOrDefaultAsync();
                if (existing != null)
                {
                    await _undertime.ReplaceOneAsync(u => u.Id == existing.Id, record);
                }
                else
                {
                    await _undertime.InsertOneAsync(record);
                }
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error recording undertime: {ex.Message}");
                return false;
            }
        }

        public async Task<List<UndertimeRecord>> GetUndertimeRecordsByDateAsync(DateTime date)
        {
            try
            {
                var targetDate = date.Date;
                var nextDate = targetDate.AddDays(1);
                
                // Allow some flexibility or match the UTC midnight stored in DB
                return await _undertime.Find(u => 
                    u.Date >= targetDate.AddDays(-1) && 
                    u.Date <= nextDate && 
                    u.IsActive)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting undertime records: {ex.Message}");
                return new List<UndertimeRecord>();
            }
        }

        public async Task<List<UndertimeRecord>> GetUndertimeRecordsByEmployeeAsync(string employeeId)
        {
            try
            {
                return await _undertime.Find(u => u.EmployeeId == employeeId && u.IsActive).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting employee undertime records: {ex.Message}");
                return new List<UndertimeRecord>();
            }
        }
    }
}
