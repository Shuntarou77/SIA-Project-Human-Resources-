using System;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;

namespace ExWebAppSia
{
    /// <summary>
    /// Global Application Event Handler
    /// This runs ONCE when the application starts, BEFORE any page loads
    /// </summary>
    public class Global : System.Web.HttpApplication
    {
        /// <summary>
        /// Application_Start - Runs ONCE when the application first starts
        /// ?? FIX: Pre-warm MongoDB connection to prevent cold-start delays
        /// </summary>
        protected void Application_Start(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("?? APPLICATION STARTING...");
            System.Diagnostics.Debug.WriteLine($"? Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            System.Diagnostics.Debug.WriteLine("========================================");

            // ?? PRE-WARM MONGODB CONNECTION (prevents 5-15 second cold start delay)
            Task.Run(async () =>
            {
                try
                {
                    System.Diagnostics.Debug.WriteLine("[Startup] ?? Pre-warming MongoDB connection...");
                    var startTime = DateTime.Now;

                    // Test MongoDB connection by getting the database
                    var database = MongoDBHelper.GetDatabase();
                    System.Diagnostics.Debug.WriteLine($"[Startup] ? MongoDB connection established");

                    // Pre-warm critical collections (triggers collection metadata load)
                    System.Diagnostics.Debug.WriteLine("[Startup] ?? Pre-loading collection metadata...");
                    
                    // Trigger Users collection (most frequently accessed)
                    var users = database.GetCollection<User>("Users");
                    await users.CountDocumentsAsync(MongoDB.Driver.Builders<User>.Filter.Empty);
                    System.Diagnostics.Debug.WriteLine("[Startup] ? Users collection warmed");

                    // Trigger Employees collection
                    var employees = database.GetCollection<Employee>("Employees");
                    await employees.CountDocumentsAsync(MongoDB.Driver.Builders<Employee>.Filter.Empty);
                    
                    // DATA FIX: Correct HiredDate for Steven Andrei Baliong (was incorrectly 2028)
                    var baliongFilter = MongoDB.Driver.Builders<Employee>.Filter.Eq(emp => emp.Email, "steven.andrei.baliong@gmail.com");
                    var baliongUpdate = MongoDB.Driver.Builders<Employee>.Update.Set(emp => emp.HiredDate, new DateTime(2026, 1, 21, 0, 0, 0, DateTimeKind.Utc));
                    await employees.UpdateOneAsync(baliongFilter, baliongUpdate);
                    System.Diagnostics.Debug.WriteLine("[Startup] ? Corrected HiredDate for Steven Andrei Baliong to Jan 21, 2026");

                    System.Diagnostics.Debug.WriteLine("[Startup] ? Employees collection warmed");

                    // Trigger PayrollConfigurations collection
                    var payrollConfigs = database.GetCollection<PayrollConfiguration>("PayrollConfigurations");
                    await payrollConfigs.CountDocumentsAsync(MongoDB.Driver.Builders<PayrollConfiguration>.Filter.Empty);
                    System.Diagnostics.Debug.WriteLine("[Startup] ? PayrollConfigurations collection warmed");

                    // Trigger PaySchedules collection (used on Payroll page load)
                    var paySchedules = database.GetCollection<PaySchedule>("PaySchedules");
                    await paySchedules.CountDocumentsAsync(MongoDB.Driver.Builders<PaySchedule>.Filter.Empty);
                    System.Diagnostics.Debug.WriteLine("[Startup] ? PaySchedules collection warmed");

                    var elapsed = (DateTime.Now - startTime).TotalSeconds;
                    System.Diagnostics.Debug.WriteLine($"[Startup] ?? MongoDB pre-warm complete in {elapsed:F2} seconds");
                    System.Diagnostics.Debug.WriteLine($"[Startup] ?? First page load will now be INSTANT!");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Startup] ? ERROR pre-warming MongoDB: {ex.Message}");
                    System.Diagnostics.Debug.WriteLine($"[Startup] Stack: {ex.StackTrace}");
                    // Don't crash the application - just log the error
                    // Pages will still work, just with a slow first load
                }
            }).Wait(TimeSpan.FromSeconds(30)); // Wait max 30 seconds for warmup

            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("? APPLICATION STARTED SUCCESSFULLY");
            System.Diagnostics.Debug.WriteLine("========================================");
        }

        /// <summary>
        /// Application_End - Runs when the application shuts down
        /// </summary>
        protected void Application_End(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("?? APPLICATION SHUTTING DOWN...");
            System.Diagnostics.Debug.WriteLine($"? Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            System.Diagnostics.Debug.WriteLine("========================================");
        }

        /// <summary>
        /// Application_Error - Runs when an unhandled exception occurs
        /// </summary>
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception exception = Server.GetLastError();
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("? UNHANDLED APPLICATION ERROR");
            System.Diagnostics.Debug.WriteLine($"? Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            System.Diagnostics.Debug.WriteLine($"Error: {exception?.Message}");
            System.Diagnostics.Debug.WriteLine($"Stack: {exception?.StackTrace}");
            System.Diagnostics.Debug.WriteLine("========================================");
        }

        /// <summary>
        /// Session_Start - Runs when a new user session begins
        /// </summary>
        protected void Session_Start(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"[Session] ?? New session started: {Session.SessionID}");
        }

        /// <summary>
        /// Session_End - Runs when a user session ends (timeout or logout)
        /// </summary>
        protected void Session_End(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"[Session] ?? Session ended: {Session.SessionID}");
        }
    }
}
