using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class ActivityLogService
    {
        private readonly IMongoCollection<ActivityLog> _activityLogs;

        public ActivityLogService()
        {
            _activityLogs = MongoDBHelper.GetDatabase().GetCollection<ActivityLog>("ActivityLogs");
        }

        public async Task<bool> LogActionAsync(string hrUsername, string hrName, string action, string module, string targetInfo)
        {
            try
            {
                var log = new ActivityLog
                {
                    HRUsername = hrUsername ?? "Unknown",
                    HRName = hrName ?? "HR Admin",
                    Action = action,
                    Module = module,
                    TargetInfo = targetInfo,
                    Timestamp = DateTime.UtcNow
                };

                await _activityLogs.InsertOneAsync(log);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error logging activity: {ex.Message}");
                return false;
            }
        }

        public async Task<List<ActivityLog>> GetAllLogsAsync()
        {
            try
            {
                return await _activityLogs.Find(_ => true)
                                          .SortByDescending(l => l.Timestamp)
                                          .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving activity logs: {ex.Message}");
                return new List<ActivityLog>();
            }
        }
    }
}
