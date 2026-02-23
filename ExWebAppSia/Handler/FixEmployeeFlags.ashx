<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.FixEmployeeFlags" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class FixEmployeeFlags : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var applicantService = new ApplicantService();
                var employeeService = new EmployeeService();
                var users = MongoDBHelper.GetUsersCollection();
                var employees = MongoDBHelper.GetEmployeesCollection();
                
                var allEmployees = await employeeService.GetAllEmployeesAsync();
                int updatedCount = 0;
                var details = new List<string>();

                foreach (var emp in allEmployees)
                {
                    if (string.IsNullOrEmpty(emp.ApplicantId)) continue;

                    var applicant = await applicantService.GetApplicantByIdAsync(emp.ApplicantId);
                    if (applicant == null) continue;

                    // Check if we need to update
                    bool needsUpdate = (emp.HasSSS != applicant.HasSSS) || 
                                     (emp.HasPhilHealth != applicant.HasPhilHealth) || 
                                     (emp.HasPagIbig != applicant.HasPagIbig);

                    if (needsUpdate)
                    {
                        // 1. Update Employee record
                        var empFilter = Builders<Employee>.Filter.Eq(e => e.Id, emp.Id);
                        var empUpdate = Builders<Employee>.Update
                            .Set(e => e.HasSSS, applicant.HasSSS)
                            .Set(e => e.HasPhilHealth, applicant.HasPhilHealth)
                            .Set(e => e.HasPagIbig, applicant.HasPagIbig);
                        
                        await employees.UpdateOneAsync(empFilter, empUpdate);

                        // 2. Update User record (for login/portal view)
                        var userFilter = Builders<User>.Filter.Eq(u => u.EmployeeId, emp.EmployeeId);
                        var userUpdate = Builders<User>.Update
                            .Set(u => u.HasSSS, applicant.HasSSS)
                            .Set(u => u.HasPhilHealth, applicant.HasPhilHealth)
                            .Set(u => u.HasPagIbig, applicant.HasPagIbig);
                        
                        await users.UpdateOneAsync(userFilter, userUpdate);

                        updatedCount++;
                        details.Add($"Updated {emp.FullName} ({emp.EmployeeId}): SSS={applicant.HasSSS}, PH={applicant.HasPhilHealth}, PI={applicant.HasPagIbig}");
                    }
                }

                var response = new
                {
                    success = true,
                    message = $"Data synchronization complete. {updatedCount} employees updated.",
                    updated_count = updatedCount,
                    details = details
                };

                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(response));
            }
            catch (Exception ex)
            {
                context.Response.Write(new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(new { 
                    success = false, 
                    message = "Error: " + ex.Message 
                }));
            }
        }
    }
}
