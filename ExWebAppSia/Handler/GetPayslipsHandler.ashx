<%@ WebHandler Language="C#" Class="GetPayslipsHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Diagnostics;
using Newtonsoft.Json;

public class GetPayslipsHandler : IHttpAsyncHandler, IHttpHandler
{
    private static PayslipService _payslipService;

    private static PayslipService PayslipServiceInstance
    {
        get
        {
            if (_payslipService == null)
            {
                Debug.WriteLine("[GetPayslipsHandler] Initializing PayslipService...");
                _payslipService = new PayslipService();
                Debug.WriteLine("[GetPayslipsHandler] PayslipService initialized");
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
            System.Diagnostics.Debug.WriteLine("[GetPayslipsHandler] START");
            System.Diagnostics.Debug.WriteLine("========================================");

            var payslips = await PayslipServiceInstance.GetAllPayslipsAsync();

            System.Diagnostics.Debug.WriteLine($"[GetPayslipsHandler] Found {payslips?.Count ?? 0} payslips");

            var payslipList = (payslips ?? new List<Payslip>()).Select(ps => new
            {
                id = ps.Id,
                employeeId = ps.EmployeeId,
                employeeName = ps.EmployeeName,
                department = ps.Department,
                payRunId = ps.PayRunId,
                payPeriodStart = ps.PayPeriodStart.ToString("MMM dd, yyyy"),
                payPeriodEnd = ps.PayPeriodEnd.ToString("MMM dd, yyyy"),
                period = $"{ps.PayPeriodStart:MMM dd} - {ps.PayPeriodEnd:MMM dd, yyyy}",
                payDate = ps.PayDate.ToString("MMM dd, yyyy"),
                grossSalary = ps.GrossSalary,
                totalDeductions = ps.TotalDeductions,
                netSalary = ps.NetSalary,
                generatedAt = ps.GeneratedAt.ToString("MMM dd, yyyy"),
                emailedAt = ps.EmailedAt?.ToString("MMM dd, yyyy") ?? "Not emailed",
                htmlContent = ps.HtmlContent
            }).ToList();

            System.Diagnostics.Debug.WriteLine($"[GetPayslipsHandler] Returning {payslipList.Count} items");

            var response = new
            {
                success = true,
                data = payslipList,
                count = payslipList.Count
            };

            context.Response.Write(JsonConvert.SerializeObject(response));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[GetPayslipsHandler] ERROR: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"[GetPayslipsHandler] Stack: {ex.StackTrace}");

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

