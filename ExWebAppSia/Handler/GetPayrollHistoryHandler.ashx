<%@ WebHandler Language="C#" Class="GetPayrollHistoryHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Diagnostics;

public class GetPayrollHistoryHandler : IHttpAsyncHandler, IHttpHandler
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
        context.Response.Charset = "utf-8";

        try
        {
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("[GetPayrollHistoryHandler] START");
            System.Diagnostics.Debug.WriteLine("========================================");

            // Get all pay runs
            var payRunService = new PayRunService();
            var payRuns = await payRunService.GetAllAsync();

            System.Diagnostics.Debug.WriteLine($"[GetPayrollHistoryHandler] Found {payRuns?.Count ?? 0} pay runs");

            var history = (payRuns ?? new List<PayRun>()).Select(pr => new
            {
                id = pr.Id,
                payRunNumber = pr.PayRunNumber,
                description = pr.Description,
                payPeriodStart = pr.PayPeriodStart.ToString("MMM dd, yyyy"),
                payPeriodEnd = pr.PayPeriodEnd.ToString("MMM dd, yyyy"),
                period = $"{pr.PayPeriodStart:MMM dd} - {pr.PayPeriodEnd:MMM dd, yyyy}",
                totalEmployees = pr.TotalEmployees,
                totalGrossSalary = pr.TotalGrossSalary,
                totalDeductions = pr.TotalDeductions,
                totalNetSalary = pr.TotalNetSalary,
                status = pr.Status,
                payDate = pr.PayDate.ToString("MMM dd, yyyy"),
                approvedBy = pr.ApprovedBy ?? pr.CreatedBy ?? "N/A",
                approvedAt = pr.ApprovedAt?.ToString("MMM dd, yyyy") ?? pr.CreatedAt.ToString("MMM dd, yyyy"),
                createdAt = pr.CreatedAt.ToString("MMM dd, yyyy"),
                isFinalized = pr.IsFinalized,
                isSentToFinance = pr.IsSentToFinance,
                isPayslipsGenerated = pr.IsPayslipsGenerated
            }).ToList();

            System.Diagnostics.Debug.WriteLine($"[GetPayrollHistoryHandler] Returning {history.Count} items");

            var response = new
            {
                success = true,
                data = history,
                count = history.Count
            };

            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(response));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[GetPayrollHistoryHandler] ERROR: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"[GetPayrollHistoryHandler] Stack: {ex.StackTrace}");

            var errorResponse = new
            {
                success = false,
                message = ex.Message
            };

            context.Response.StatusCode = 500;
            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(errorResponse));
        }
    }

    public bool IsReusable => false;
}
