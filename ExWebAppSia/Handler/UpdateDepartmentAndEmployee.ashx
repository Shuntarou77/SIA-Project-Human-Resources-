<%@ WebHandler Language="C#" Class="ExWebAppSia.Handler.UpdateDepartmentAndEmployee" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.Handler
{
    public class UpdateDepartmentAndEmployee : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var employees = MongoDBHelper.GetEmployeesCollection();
                var users = MongoDBHelper.GetUsersCollection();
                
                // 1. Update all employees in "Legal" to "Inventory"
                var legalFilter = Builders<Employee>.Filter.Eq(e => e.Department, "Legal");
                var deptUpdate = Builders<Employee>.Update.Set(e => e.Department, "Inventory");
                var deptResult = await employees.UpdateManyAsync(legalFilter, deptUpdate);
                
                // Also update the Users collection if department is stored there (checking)
                var userDeptFilter = Builders<User>.Filter.Eq("Department", "Legal"); // Assuming field name
                var userDeptUpdate = Builders<User>.Update.Set("Department", "Inventory");
                await users.UpdateManyAsync(userDeptFilter, userDeptUpdate);

                // 2. Find one employee in the new "Inventory" department to update to the specific details
                var inventoryEmployees = await employees.Find(Builders<Employee>.Filter.Eq(e => e.Department, "Inventory")).ToListAsync();
                
                string employeeUpdatedString = "None";
                if (inventoryEmployees.Count > 0)
                {
                    // Pick the first one or a specific one if needed. 
                    // Let's pick one that might have been "Adams, Amanda" as seen in the screenshot.
                    var targetEmp = inventoryEmployees.FirstOrDefault(e => e.LastName == "Adams") ?? inventoryEmployees[0];
                    
                    var oldEmail = targetEmp.Email;
                    var oldId = targetEmp.Id;
                    var oldEmpId = targetEmp.EmployeeId;

                    // Update Employee details
                    var empUpdate = Builders<Employee>.Update
                        .Set(e => e.FirstName, "Onesimus")
                        .Set(e => e.LastName, "Delacruz")
                        .Set(e => e.Email, "delacruzonesimuspalles@gmail.com")
                        .Set(e => e.Role, "Inventory Manager");
                    
                    await employees.UpdateOneAsync(Builders<Employee>.Filter.Eq(e => e.Id, oldId), empUpdate);

                    // Update User details for login
                    var userUpdate = Builders<User>.Update
                        .Set(u => u.Username, "delacruzonesimuspalles@gmail.com")
                        .Set(u => u.Email, "delacruzonesimuspalles@gmail.com");
                    
                    await users.UpdateOneAsync(Builders<User>.Filter.Eq(u => u.EmployeeId, oldEmpId), userUpdate);
                    
                    employeeUpdatedString = $"Updated {targetEmp.FullName} to Onesimus Delacruz (delacruzonesimuspalles@gmail.com)";
                }

                var response = new
                {
                    success = true,
                    message = "Department migration and employee update complete.",
                    department_updated_count = deptResult.ModifiedCount,
                    employee_updated = employeeUpdatedString
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
