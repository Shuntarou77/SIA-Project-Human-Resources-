<%@ WebHandler Language="C#" Class="OrgChartHandler" %>

using System;
using System.Web;
using System.Threading.Tasks;
using Newtonsoft.Json;
using ExWebAppSia.Models;

public class OrgChartHandler : HttpTaskAsyncHandler
{
    public override async Task ProcessRequestAsync(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache, no-store");
        
        try
        {
            var employeeService = new EmployeeService();
            var data = await employeeService.GetOrgChartDataAsync().ConfigureAwait(false);
            
            if (data == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { error = "No data found or error generating hierarchy." }));
                return;
            }
            
            context.Response.Write(JsonConvert.SerializeObject(data));
        }
        catch (Exception ex)
        {
            // Log the error for server-side debugging if needed
            System.Diagnostics.Debug.WriteLine($"[OrgChartHandler] Error: {ex.Message}");
            
            context.Response.StatusCode = 500;
            context.Response.Write(JsonConvert.SerializeObject(new { error = "Internal Server Error: " + ex.Message }));
        }
    }
}

