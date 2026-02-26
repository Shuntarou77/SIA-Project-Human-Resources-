<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.SeedAttendanceForOnesimus" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class SeedAttendanceForOnesimus : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var attendanceCollection = MongoDBHelper.GetAttendanceCollection();
                var employeeId = "26-2251";
                var employeeName = "Delacruz, Onesimus";
                var department = "Inventory";

                // Date range: Jan 26, 2026 to Feb 26, 2026 (local time)
                DateTime startDate = new DateTime(2026, 1, 26);
                DateTime endDate = new DateTime(2026, 2, 26);
                
                int createdCount = 0;
                int skippedCount = 0;
                var details = new List<string>();

                var inventoryEmployees = await MongoDBHelper.GetEmployeesCollection().Find(e => e.Department == "Inventory").ToListAsync();
                var inventoryDetails = inventoryEmployees.Select(e => new { e.FullName, e.EmployeeId }).ToList();

                for (DateTime date = startDate; date <= endDate; date = date.AddDays(1))
                {
                    // Skip Sundays (Saturdays are working days)
                    if (date.DayOfWeek == DayOfWeek.Sunday)
                    {
                        skippedCount++;
                        continue;
                    }

                    // Create UTC Date explicitly
                    var utcDate = new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, DateTimeKind.Utc);
                    var existing = await attendanceCollection.Find(a => a.EmployeeId == employeeId && a.Date == utcDate && a.IsActive).FirstOrDefaultAsync();
                    
                    if (existing != null)
                    {
                        skippedCount++;
                        continue;
                    }

                    // TimeIn 8:00 AM PH (UTC+8) = 0:00 AM UTC
                    // TimeOut 5:00 PM PH (UTC+8) = 9:00 AM UTC
                    var timeIn = new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, DateTimeKind.Utc);
                    var timeOut = new DateTime(date.Year, date.Month, date.Day, 9, 0, 0, DateTimeKind.Utc);

                    var attendance = new Attendance
                    {
                        EmployeeId = employeeId,
                        EmployeeName = employeeName,
                        Department = department,
                        Date = utcDate,
                        TimeIn = timeIn,
                        TimeOut = timeOut,
                        LateTime = null,
                        CreatedAt = DateTime.UtcNow,
                        IsActive = true
                    };

                    await attendanceCollection.InsertOneAsync(attendance);
                    createdCount++;
                    details.Add($"Created attendance for {date:yyyy-MM-dd}");
                }

                var response = new
                {
                    success = true,
                    message = $"Attendance seeding complete for {employeeName}.",
                    created_count = createdCount,
                    skipped_count = skippedCount,
                    inventory_employees = inventoryDetails,
                    details = details
                };

                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(response));
            }
            catch (Exception ex)
            {
                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(new { 
                    success = false, 
                    message = "Error: " + ex.Message,
                    stack_trace = ex.StackTrace
                }));
            }
        }
    }
}
