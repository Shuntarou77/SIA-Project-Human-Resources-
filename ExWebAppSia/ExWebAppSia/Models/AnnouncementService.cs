using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class AnnouncementService
    {
        private readonly IMongoCollection<Announcement> _ann;

        public AnnouncementService()
        {
            _ann = MongoDBHelper.GetAnnouncementsCollection();
        }

        public async Task<Announcement> CreateAsync(string content, string postedBy, string department)
        {
            var doc = new Announcement
            {
                Content = content,
                PostedBy = postedBy,
                Department = department,
                PostedDate = DateTime.UtcNow,
                IsActive = true
            };
            await _ann.InsertOneAsync(doc);
            return doc;
        }

        public async Task<List<Announcement>> GetAllAsync(int limit = 100)
        {
            var filter = Builders<Announcement>.Filter.Eq(x => x.IsActive, true);
            return await _ann.Find(filter)
                             .SortByDescending(x => x.PostedDate)
                             .Limit(limit)
                             .ToListAsync();
        }

        public async Task<List<Announcement>> GetRecentAsync(int count = 3)
        {
            var filter = Builders<Announcement>.Filter.Eq(x => x.IsActive, true);
            return await _ann.Find(filter)
                             .SortByDescending(x => x.PostedDate)
                             .Limit(count)
                             .ToListAsync();
        }
    }
}