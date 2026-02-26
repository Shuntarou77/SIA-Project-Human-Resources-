<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.CheckAttendance" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class CheckAttendance : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var attendanceCollection = MongoDBHelper.GetAttendanceCollection();
                var employeeId = "26-2251";
                
                var records = await attendanceCollection.Find(a => a.EmployeeId == employeeId && a.IsActive).ToListAsync();
                
                var response = new
                {
                    success = true,
                    count = records.Count,
                    records = records.Select(r => new {
                        Date = r.Date.ToString("yyyy-MM-dd"),
                        TimeIn = r.TimeIn?.ToString("yyyy-MM-dd HH:mm:ss"),
                        TimeOut = r.TimeOut?.ToString("yyyy-MM-dd HH:mm:ss"),
                        EmployeeName = r.EmployeeName,
                        Department = r.Department
                    })
                };

                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(response));
            }
            catch (Exception ex)
            {
                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(new { 
                    success = false, 
                    message = ex.Message 
                }));
            }
        }
    }
}
