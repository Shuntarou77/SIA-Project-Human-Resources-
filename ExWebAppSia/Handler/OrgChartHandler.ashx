<%@ WebHandler Language="C#" Class="OrgChartHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Threading.Tasks;
using Newtonsoft.Json;

public class OrgChartHandler : IHttpAsyncHandler, IHttpHandler
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
            var employeeService = new EmployeeService();
            var data = await employeeService.GetOrgChartDataAsync();
            
            if (data == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { error = "No data found or error generating hierarchy." }));
                return;
            }
            
            context.Response.Write(JsonConvert.SerializeObject(data));
        }
        catch (Exception ex)
        {
            context.Response.Write(JsonConvert.SerializeObject(new { error = ex.Message }));
        }
    }

    public bool IsReusable => false;
}
