<%@ WebHandler Language="C#" Class="GetPayslipContentHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Threading.Tasks;
using System.Diagnostics;
using Newtonsoft.Json;

public class GetPayslipContentHandler : IHttpAsyncHandler, IHttpHandler
{
    private static PayslipService _payslipService;

    private static PayslipService PayslipServiceInstance
    {
        get
        {
            if (_payslipService == null)
            {
                Debug.WriteLine("[GetPayslipContentHandler] Initializing PayslipService...");
                _payslipService = new PayslipService();
                Debug.WriteLine("[GetPayslipContentHandler] PayslipService initialized");
            }
            return _payslipService;
        }
    }

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
        context.Response.Charset = "utf-8";

        try
        {
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("[GetPayslipContentHandler] START");
            System.Diagnostics.Debug.WriteLine("========================================");

            string payslipId = context.Request.QueryString["id"];

            if (string.IsNullOrEmpty(payslipId))
            {
                context.Response.StatusCode = 400;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Payslip ID is required." }));
                return;
            }

            var payslip = await PayslipServiceInstance.GetPayslipByIdAsync(payslipId);

            if (payslip == null)
            {
                context.Response.StatusCode = 404;
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = $"Payslip with ID {payslipId} not found." }));
                return;
            }

            var response = new
            {
                success = true,
                htmlContent = payslip.HtmlContent ?? ""
            };

            System.Diagnostics.Debug.WriteLine($"[GetPayslipContentHandler] Returning payslip content for ID: {payslipId}");

            context.Response.Write(JsonConvert.SerializeObject(response));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[GetPayslipContentHandler] ERROR: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"[GetPayslipContentHandler] Stack: {ex.StackTrace}");

            var errorResponse = new
            {
                success = false,
                message = ex.Message
            };

            context.Response.StatusCode = 500;
            context.Response.Write(JsonConvert.SerializeObject(errorResponse));
        }
    }

    public bool IsReusable => false;
}

