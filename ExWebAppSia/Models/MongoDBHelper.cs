using MongoDB.Driver;
using System;
using System.Linq;

namespace ExWebAppSia.Models
{
    public static class MongoDBHelper
    {
        // Read connection string from Web.config
        private static string ConnectionString => 
            System.Configuration.ConfigurationManager.ConnectionStrings["MongoDBConnection"]?.ConnectionString 
            ?? "mongodb://localhost:27017";
        
        // Read database name from Web.config
        private static string DatabaseName => 
            System.Configuration.ConfigurationManager.AppSettings["MongoDBDatabase"] 
            ?? "HumanResourcesDB";

        private static IMongoDatabase _database;
        private static readonly object _lock = new object();

        /// <summary>
        /// Get the MongoDB database instance (Singleton pattern)
        /// </summary>
        public static IMongoDatabase GetDatabase()
        {
            if (_database == null)
            {
                lock (_lock)
                {
                    if (_database == null)
                    {
                        try
                        {
                            System.Diagnostics.Debug.WriteLine($"[MongoDBHelper] Connecting to MongoDB at {ConnectionString}...");
                            
                            // Configure MongoDB client with timeout settings
                            var settings = MongoClientSettings.FromConnectionString(ConnectionString);
                            settings.ServerSelectionTimeout = TimeSpan.FromSeconds(10);
                            settings.ConnectTimeout = TimeSpan.FromSeconds(10);
                            settings.SocketTimeout = TimeSpan.FromSeconds(30);
                            settings.MaxConnectionPoolSize = 100;
                            
                            var client = new MongoClient(settings);
                            _database = client.GetDatabase(DatabaseName);
                            
                            System.Diagnostics.Debug.WriteLine($"[MongoDBHelper] Connected successfully to database: {DatabaseName}");
                            
                            // Test connection
                            _database.ListCollectionNames().FirstOrDefault();
                            System.Diagnostics.Debug.WriteLine($"[MongoDBHelper] Connection test successful");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"[MongoDBHelper] ERROR connecting to MongoDB: {ex.Message}");
                            throw new Exception($"Failed to connect to MongoDB at {ConnectionString}. Ensure MongoDB is running.", ex);
                        }
                    }
                }
            }
            return _database;
        }

        public static IMongoCollection<T> GetCollection<T>(string collectionName)
        {
            try
            {
                var collection = GetDatabase().GetCollection<T>(collectionName);
                System.Diagnostics.Debug.WriteLine("[MongoDBHelper] Accessed collection: " + collectionName);
                return collection;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[MongoDBHelper] Collection error: " + ex.Message);
                throw;
            }
        }

        public static IMongoCollection<User> GetUsersCollection()
        {
            return GetCollection<User>("Users");
        }

        public static IMongoCollection<Employee> GetEmployeesCollection()
        {
            return GetCollection<Employee>("Employees");
        }

        public static IMongoCollection<Manager> GetManagersCollection()
        {
            return GetCollection<Manager>("Managers");
        }

        public static IMongoCollection<Announcement> GetAnnouncementsCollection()
        {
            return GetCollection<Announcement>("Announcements");
        }

        public static IMongoCollection<Applicant> GetApplicantsCollection()
        {
            return GetCollection<Applicant>("job_applicant");
        }

        public static IMongoCollection<Interview> GetInterviewsCollection()
        {
            return GetCollection<Interview>("Interviews");
        }

        public static IMongoCollection<Leave> GetLeavesCollection()
        {
            return GetCollection<Leave>("Leaves");
        }

        public static IMongoCollection<Attendance> GetAttendanceCollection()
        {
            return GetCollection<Attendance>("Attendance");
        }

        public static IMongoCollection<OvertimeRequest> GetOvertimeRequestsCollection()
        {
            return GetCollection<OvertimeRequest>("OvertimeRequests");
        }

        public static IMongoCollection<RoleSalary> GetRoleSalariesCollection()
        {
            return GetCollection<RoleSalary>("RoleSalaries");
        }

        public static IMongoCollection<EmployeeConcern> GetEmployeeConcernsCollection()
        {
            return GetCollection<EmployeeConcern>("EmployeeConcerns");
        }

        public static IMongoCollection<UndertimeRecord> GetUndertimeCollection()
        {
            return GetCollection<UndertimeRecord>("UndertimeRecords");
        }

        public static IMongoCollection<PayrollSnapshot> GetPayrollSnapshotsCollection()
        {
            try
            {
                // We use sia_payroll_db for snapshots specifically
                var client = new MongoClient(System.Configuration.ConfigurationManager.ConnectionStrings["MongoDBConnection"]?.ConnectionString ?? "mongodb://localhost:27017");
                var db = client.GetDatabase("sia_payroll_db");
                return db.GetCollection<PayrollSnapshot>("PayrollSnapshots");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[MongoDBHelper] Snapshots collection error: " + ex.Message);
                throw;
            }
        }

        public static bool TestConnection()
        {
            try
            {
                GetDatabase().ListCollectionNames().FirstOrDefault();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
