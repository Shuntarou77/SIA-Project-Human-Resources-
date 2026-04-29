<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.GenerateAttendanceDataAll" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class GenerateAttendanceDataAll : HttpTaskAsyncHandler
    {
        private static Random _random = new Random();

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var attendanceCollection = MongoDBHelper.GetAttendanceCollection();
                var employeesCollection = MongoDBHelper.GetEmployeesCollection();
                
                var employees = await employeesCollection.Find(e => e.IsActive).ToListAsync();
                
                // Date range: January 1 of this year until now
                DateTime startDate = new DateTime(DateTime.Today.Year, 1, 1);
                DateTime endDate = DateTime.Today;
                
                int totalCreated = 0;
                int totalSkipped = 0;
                var summary = new List<string>();

                foreach (var emp in employees)
                {
                    // Assign a behavior profile to this employee
                    // 0: Perfect, 1: Latecomer, 2: Absentee, 3: Mixed
                    int profile = _random.Next(0, 4);
                    int absencesCount = 0;
                    int targetAbsences = profile == 2 ? _random.Next(1, 4) : (profile == 3 ? _random.Next(1, 4) : 0);
                    
                    int empCreated = 0;
                    int empLate = 0;

                    // Pre-calculate which working days will be absent
                    var workingDays = new List<DateTime>();
                    for (DateTime d = startDate; d <= endDate; d = d.AddDays(1))
                    {
                        if (d.DayOfWeek != DayOfWeek.Sunday) workingDays.Add(d);
                    }
                    
                    var absentDates = new HashSet<DateTime>();
                    if (targetAbsences > 0)
                    {
                        var shuffledDays = workingDays.OrderBy(x => _random.Next()).Take(targetAbsences).ToList();
                        foreach (var d in shuffledDays) absentDates.Add(d.Date);
                        absencesCount = absentDates.Count;
                    }

                    for (DateTime date = startDate; date <= endDate; date = date.AddDays(1))
                    {
                        // Skip Sundays
                        if (date.DayOfWeek == DayOfWeek.Sunday)
                        {
                            continue;
                        }

                        // Check if attendance already exists for this employee on this date
                        var utcDate = new DateTime(date.Year, date.Month, date.Day, 0, 0, 0, DateTimeKind.Utc);

                        // Determine if absent today
                        if (absentDates.Contains(date.Date))
                        {
                            // CRITICAL: To ensure an 'Absent' shows up even if there was previous data, 
                            // we remove any existing record for this employee on this date.
                            await attendanceCollection.DeleteManyAsync(a => a.EmployeeId == emp.EmployeeId && a.Date == utcDate);
                            continue;
                        }

                        var existing = await attendanceCollection.Find(a => a.EmployeeId == emp.EmployeeId && a.Date == utcDate && a.IsActive).FirstOrDefaultAsync();
                        
                        if (existing != null)
                        {
                            totalSkipped++;
                            continue;
                        }

                        // Determine Time In
                        DateTime timeIn;
                        string lateTimeStr = null;
                        
                        bool isLate = false;
                        if (profile == 1) // Latecomer
                        {
                            isLate = _random.Next(0, 100) < 40; // 40% chance
                        }
                        else if (profile == 3) // Mixed
                        {
                            isLate = _random.Next(0, 100) < 20; // 20% chance
                        }

                        if (isLate)
                        {
                            // Late: between 8:16 AM and 9:30 AM
                            int offsetMinutes = _random.Next(16, 91);
                            timeIn = new DateTime(date.Year, date.Month, date.Day, 8, 0, 0, DateTimeKind.Utc).AddMinutes(offsetMinutes).AddHours(-8); // Subtract 8 to store as UTC
                            
                            // Calculate late time string (HH:mm:ss)
                            var lateDiff = TimeSpan.FromMinutes(offsetMinutes);
                            lateTimeStr = $"{(int)lateDiff.TotalHours:D2}:{lateDiff.Minutes:D2}:{lateDiff.Seconds:D2}";
                            empLate++;
                        }
                        else
                        {
                            // On time: between 7:30 AM and 8:15 AM
                            int offsetMinutes = _random.Next(-30, 16);
                            timeIn = new DateTime(date.Year, date.Month, date.Day, 8, 0, 0, DateTimeKind.Utc).AddMinutes(offsetMinutes).AddHours(-8);
                        }

                        // Time Out: between 5:00 PM and 6:30 PM
                        int outOffsetMinutes = _random.Next(0, 91);
                        DateTime timeOut = new DateTime(date.Year, date.Month, date.Day, 17, 0, 0, DateTimeKind.Utc).AddMinutes(outOffsetMinutes).AddHours(-8);

                        var attendance = new Attendance
                        {
                            EmployeeId = emp.EmployeeId,
                            EmployeeName = emp.FullName,
                            Department = emp.Department,
                            Date = utcDate,
                            TimeIn = timeIn,
                            TimeOut = timeOut,
                            LateTime = lateTimeStr,
                            CreatedAt = DateTime.UtcNow,
                            IsActive = true
                        };

                        await attendanceCollection.InsertOneAsync(attendance);
                        totalCreated++;
                        empCreated++;
                    }
                    
                    string profileName = profile == 0 ? "Perfect" : (profile == 1 ? "Latecomer" : (profile == 2 ? "Absentee" : "Mixed"));
                    summary.Add($"{emp.FullName} ({emp.EmployeeId}): {empCreated} records, {empLate} lates, {absencesCount} absences. Profile: {profileName}");
                }

                var response = new
                {
                    success = true,
                    message = $"Attendance generation complete for {employees.Count} employees.",
                    total_created = totalCreated,
                    total_skipped = totalSkipped,
                    summary = summary
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
