using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MongoDB.Driver;
using MongoDB.Bson;

namespace ExWebAppSia.Models
{
    public class NotificationService
    {
        private readonly IMongoCollection<Notification> _notifications;

        public NotificationService()
        {
            var database = MongoDBHelper.GetDatabase();
            _notifications = database.GetCollection<Notification>("Notifications");
        }

        public async Task<List<Notification>> GetUserNotificationsAsync(string employeeId, string role)
        {
            try
            {
                var filterBuilder = Builders<Notification>.Filter;
                FilterDefinition<Notification> filter;

                if (role == "Super Admin" || role == "Admin" || role == "HR")
                {
                    // Admins see their own, "ADMIN" designated notifications, and "ALL"
                    filter = filterBuilder.Or(
                        filterBuilder.Eq(n => n.RecipientId, employeeId),
                        filterBuilder.Eq(n => n.RecipientId, "ADMIN"),
                        filterBuilder.Eq(n => n.RecipientId, "ALL")
                    );
                }
                else if (role == "President")
                {
                     // President sees "ALL" and "ADMIN" (since they monitor everything)
                     filter = filterBuilder.Or(
                        filterBuilder.Eq(n => n.RecipientId, employeeId),
                        filterBuilder.Eq(n => n.RecipientId, "ADMIN"),
                        filterBuilder.Eq(n => n.RecipientId, "ALL")
                    );
                }
                else
                {
                    // Regular employees see their own and "ALL"
                    filter = filterBuilder.Or(
                        filterBuilder.Eq(n => n.RecipientId, employeeId),
                        filterBuilder.Eq(n => n.RecipientId, "ALL")
                    );
                }

                return await _notifications.Find(filter)
                    .SortByDescending(n => n.Timestamp)
                    .Limit(20)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error fetching notifications: {ex.Message}");
                return new List<Notification>();
            }
        }

        public async Task<long> GetUnreadCountAsync(string employeeId, string role)
        {
            try
            {
                var filterBuilder = Builders<Notification>.Filter;
                FilterDefinition<Notification> filter;

                var unreadFilter = filterBuilder.Eq(n => n.IsRead, false);

                if (role == "Super Admin" || role == "Admin" || role == "HR" || role == "President")
                {
                    filter = filterBuilder.And(
                        unreadFilter,
                        filterBuilder.Or(
                            filterBuilder.Eq(n => n.RecipientId, employeeId),
                            filterBuilder.Eq(n => n.RecipientId, "ADMIN"),
                            filterBuilder.Eq(n => n.RecipientId, "ALL")
                        )
                    );
                }
                else
                {
                    filter = filterBuilder.And(
                        unreadFilter,
                        filterBuilder.Or(
                            filterBuilder.Eq(n => n.RecipientId, employeeId),
                            filterBuilder.Eq(n => n.RecipientId, "ALL")
                        )
                    );
                }

                return await _notifications.CountDocumentsAsync(filter);
            }
            catch
            {
                return 0;
            }
        }

        public async Task CreateNotificationAsync(Notification notification)
        {
            try
            {
                notification.Timestamp = DateTime.UtcNow;
                notification.IsRead = false;
                await _notifications.InsertOneAsync(notification);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating notification: {ex.Message}");
            }
        }

        public async Task MarkAsReadAsync(string notificationId)
        {
            try
            {
                var filter = Builders<Notification>.Filter.Eq(n => n.Id, notificationId);
                var update = Builders<Notification>.Update.Set(n => n.IsRead, true);
                await _notifications.UpdateOneAsync(filter, update);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error marking notification as read: {ex.Message}");
            }
        }

        public async Task MarkAllAsReadAsync(string employeeId, string role)
        {
            try
            {
                var filterBuilder = Builders<Notification>.Filter;
                FilterDefinition<Notification> filter;

                if (role == "Super Admin" || role == "Admin" || role == "HR" || role == "President")
                {
                    filter = filterBuilder.Or(
                        filterBuilder.Eq(n => n.RecipientId, employeeId),
                        filterBuilder.Eq(n => n.RecipientId, "ADMIN"),
                        filterBuilder.Eq(n => n.RecipientId, "ALL")
                    );
                }
                else
                {
                    filter = filterBuilder.Or(
                        filterBuilder.Eq(n => n.RecipientId, employeeId),
                        filterBuilder.Eq(n => n.RecipientId, "ALL")
                    );
                }

                var update = Builders<Notification>.Update.Set(n => n.IsRead, true);
                await _notifications.UpdateManyAsync(filter, update);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error marking all as read: {ex.Message}");
            }
        }
    }
}
