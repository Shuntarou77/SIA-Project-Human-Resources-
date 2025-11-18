using MongoDB.Driver;
using System;
using System.Configuration;

namespace ExWebAppSia.Models
{
    public class MongoDBHelper
    {
        private static IMongoDatabase _database;
        private static readonly string ConnectionString = "mongodb://localhost:27017";
        private static readonly string DatabaseName = "HRSystem";

        public static IMongoDatabase GetDatabase()
        {
            if (_database == null)
            {
                // Configure MongoDB client with connection timeout settings to prevent hanging
                var settings = MongoClientSettings.FromConnectionString(ConnectionString);
                settings.ConnectTimeout = TimeSpan.FromSeconds(5); // 5 second connection timeout
                settings.ServerSelectionTimeout = TimeSpan.FromSeconds(5); // 5 second server selection timeout
                settings.SocketTimeout = TimeSpan.FromSeconds(10); // 10 second socket timeout
                
                var client = new MongoClient(settings);
                _database = client.GetDatabase(DatabaseName);
            }
            return _database;
        }

        public static IMongoCollection<User> GetUsersCollection()
        {
            return GetDatabase().GetCollection<User>("users");
        }

        public static IMongoCollection<Announcement> GetAnnouncementsCollection()
        {
            return GetDatabase().GetCollection<Announcement>("announcements");
        }

        public static IMongoCollection<Applicant> GetApplicantsCollection()
        {
            return GetDatabase().GetCollection<Applicant>("applicants");
        }

        public static IMongoCollection<Interview> GetInterviewsCollection()
        {
            return GetDatabase().GetCollection<Interview>("interviews");
        }

        public static IMongoCollection<Employee> GetEmployeesCollection()
        {
            return GetDatabase().GetCollection<Employee>("employees");
        }

        public static IMongoCollection<Leave> GetLeavesCollection()
        {
            return GetDatabase().GetCollection<Leave>("leaves");
        }

        public static IMongoCollection<EmployeeConcern> GetEmployeeConcernsCollection()
        {
            return GetDatabase().GetCollection<EmployeeConcern>("employeeConcerns");
        }

        public static IMongoCollection<Attendance> GetAttendanceCollection()
        {
            return GetDatabase().GetCollection<Attendance>("attendance");
        }

        public static IMongoCollection<Manager> GetManagersCollection()
        {
            return GetDatabase().GetCollection<Manager>("managers");
        }
    }
}