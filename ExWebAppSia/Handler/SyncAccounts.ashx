<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.SyncAccounts" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class SyncAccounts : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var userService = new UserService();
                var employeeService = new EmployeeService();
                var users = MongoDBHelper.GetUsersCollection();
                var employees = MongoDBHelper.GetEmployeesCollection();
                
                // Get all employees from the primary Employees collection
                var allEmployees = await employees.Find(_ => true).ToListAsync();
                int updatedCount = 0;
                var details = new List<string>();

                foreach (var emp in allEmployees)
                {
                    // Find User by email (Username)
                    var user = await userService.GetUserByUsernameAsync(emp.Email);
                    if (user != null)
                    {
                        bool needsUpdate = false;
                        var updateList = new List<UpdateDefinition<User>>();

                        // 1. Check ID mismatch
                        if (user.EmployeeId != emp.EmployeeId)
                        {
                            updateList.Add(Builders<User>.Update.Set(u => u.EmployeeId, emp.EmployeeId));
                            needsUpdate = true;
                            details.Add($"Syncing ID for {emp.Email}: {user.EmployeeId} -> {emp.EmployeeId}");
                        }

                        // 2. Check Name mismatch (optional but good for consistency)
                        if (user.FirstName != emp.FirstName || user.LastName != emp.LastName)
                        {
                            updateList.Add(Builders<User>.Update.Set(u => u.FirstName, emp.FirstName));
                            updateList.Add(Builders<User>.Update.Set(u => u.LastName, emp.LastName));
                            needsUpdate = true;
                        }

                        // 3. Ensure password is set to the correct EmployeeId (the default)
                        // This fixes the login issue if the hash was made from a different ID
                        if (!PasswordHelper.VerifyPasswordComplete(emp.EmployeeId, user.Password))
                        {
                            string newHash = PasswordHelper.HashPasswordComplete(emp.EmployeeId);
                            updateList.Add(Builders<User>.Update.Set(u => u.Password, newHash));
                            needsUpdate = true;
                            details.Add($"Resetting password for {emp.Email} to its current ID: {emp.EmployeeId}");
                        }

                        if (needsUpdate)
                        {
                            var combinedUpdate = Builders<User>.Update.Combine(updateList);
                            await users.UpdateOneAsync(u => u.Id == user.Id, combinedUpdate);
                            updatedCount++;
                        }
                    }
                    else
                    {
                        // User record missing - recreate it
                        await userService.EnsureEmployeeAccountAsync(
                            emp.Email, emp.EmployeeId, emp.FirstName, emp.LastName, 
                            emp.MiddleName, emp.Department, emp.Role, 
                            emp.HasSSS, emp.HasPhilHealth, emp.HasPagIbig);
                        
                        updatedCount++;
                        details.Add($"Created missing User record for {emp.Email} (ID: {emp.EmployeeId})");
                    }
                }

                var response = new
                {
                    success = true,
                    message = $"Account synchronization complete. {updatedCount} records updated.",
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
