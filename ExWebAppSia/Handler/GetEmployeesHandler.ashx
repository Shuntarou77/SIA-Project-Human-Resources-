<%@ WebHandler Language="C#" Class="GetEmployeesHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class GetEmployeesHandler : IHttpAsyncHandler, IHttpHandler
{
    public IAsyncResult BeginProcessRequest(HttpContext context, AsyncCallback cb, object extraData)
    {
        var task = ProcessRequestAsync(context);
        return ((Task)task).ContinueWith(t => cb?.Invoke(t));
    }

    public void EndProcessRequest(IAsyncResult result)
    {
        ((Task)result).Wait();
    }

    public void ProcessRequest(HttpContext context)
    {
        ProcessRequestAsync(context).Wait();
    }

    private async Task ProcessRequestAsync(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("GetEmployees called for payroll generation");
            System.Diagnostics.Debug.WriteLine("========================================");
            
            var employeeService = new EmployeeService();
            var employees = await employeeService.GetAllEmployeesAsync();
            
            if (employees == null || !employees.Any())
            {
                System.Diagnostics.Debug.WriteLine("No employees found in database");
                context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "No employees found"
                }));
                return;
            }
            
            System.Diagnostics.Debug.WriteLine($"Retrieved {employees.Count} employees from database");
            
            // Map to simplified DTO for client
            var employeeDTOs = employees.Select(e => new
            {
                id = e.Id,
                employeeId = e.EmployeeId,
                name = $"{e.LastName}, {e.FirstName} {e.MiddleName}",
                department = e.Department,
                position = e.Role,
                employeeType = e.ContractType,
                isActive = e.IsActive
            }).ToList();
            
            System.Diagnostics.Debug.WriteLine($"Mapped {employeeDTOs.Count} active employees");
            if (employeeDTOs.Any())
            {
                System.Diagnostics.Debug.WriteLine($"   Sample: {employeeDTOs.FirstOrDefault()?.employeeId} - {employeeDTOs.FirstOrDefault()?.name}");
            }
            
            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
            {
                success = true,
                employees = employeeDTOs,
                count = employeeDTOs.Count
            }));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error in GetEmployeesHandler: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"   Stack trace: {ex.StackTrace}");
            
            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
            {
                success = false,
                message = $"Error loading employees: {ex.Message}"
            }));
        }
    }

    public bool IsReusable => false;
}
