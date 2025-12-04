<%@ WebHandler Language="C#" Class="GetPayRunDetailsHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Diagnostics;

public class GetPayRunDetailsHandler : IHttpAsyncHandler, IHttpHandler
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
            System.Diagnostics.Debug.WriteLine("[GetPayRunDetailsHandler] START");
            System.Diagnostics.Debug.WriteLine("========================================");

            // Get payRunId from query string
            var payRunId = context.Request.QueryString["id"];
            if (string.IsNullOrEmpty(payRunId))
            {
                context.Response.StatusCode = 400;
                context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Pay run ID is required"
                }));
                return;
            }

            System.Diagnostics.Debug.WriteLine($"[GetPayRunDetailsHandler] Fetching pay run: {payRunId}");

            // Get pay run by ID
            var payRunService = new PayRunService();
            var payRun = await payRunService.GetByIdAsync(payRunId);

            if (payRun == null)
            {
                context.Response.StatusCode = 404;
                context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Pay run not found"
                }));
                return;
            }

            System.Diagnostics.Debug.WriteLine($"[GetPayRunDetailsHandler] Found pay run: {payRun.PayRunNumber}");

            // Format the response
            var result = new
            {
                id = payRun.Id,
                payRunNumber = payRun.PayRunNumber,
                description = payRun.Description,
                payPeriodStart = payRun.PayPeriodStart.ToString("MMM dd, yyyy"),
                payPeriodEnd = payRun.PayPeriodEnd.ToString("MMM dd, yyyy"),
                period = $"{payRun.PayPeriodStart:MMM dd} - {payRun.PayPeriodEnd:MMM dd, yyyy}",
                payDate = payRun.PayDate.ToString("MMM dd, yyyy"),
                payPeriodType = payRun.PayPeriodType,
                totalEmployees = payRun.TotalEmployees,
                totalGrossSalary = payRun.TotalGrossSalary,
                totalDeductions = payRun.TotalDeductions,
                totalNetSalary = payRun.TotalNetSalary,
                totalOvertimePay = payRun.TotalOvertimePay,
                totalStatutoryDeductions = payRun.TotalStatutoryDeductions,
                totalLoanDeductions = payRun.TotalLoanDeductions,
                status = payRun.Status,
                isFinalized = payRun.IsFinalized,
                isSentToFinance = payRun.IsSentToFinance,
                isPayslipsGenerated = payRun.IsPayslipsGenerated,
                approvedBy = payRun.ApprovedBy ?? payRun.CreatedBy ?? "N/A",
                approvedAt = payRun.ApprovedAt?.ToString("MMM dd, yyyy") ?? payRun.CreatedAt.ToString("MMM dd, yyyy"),
                reviewedBy = payRun.ReviewedBy ?? "N/A",
                reviewedAt = payRun.ReviewedAt?.ToString("MMM dd, yyyy") ?? "N/A",
                createdBy = payRun.CreatedBy ?? "N/A",
                createdAt = payRun.CreatedAt.ToString("MMM dd, yyyy"),
                approvalComments = payRun.ApprovalComments ?? "",
                items = (payRun.Items ?? new List<PayrollItem>()).Select(item => new
                {
                    employeeId = item.EmployeeId,
                    employeeName = item.EmployeeName,
                    department = item.Department,
                    position = item.Position,
                    grossSalary = item.GrossSalary,
                    totalDeductions = item.TotalDeductions,
                    netSalary = item.NetSalary,
                    basicSalary = item.BasicSalary,
                    proratedBasicSalary = item.ProratedBasicSalary,
                    allowances = item.Allowances,
                    overtimePay = item.OvertimePay,
                    holidayPay = item.HolidayPay,
                    nightDifferentialPay = item.NightDifferentialPay,
                    bonuses = item.Bonuses,
                    otherEarnings = item.OtherEarnings,
                    sssDeduction = item.SSSDeduction,
                    philHealthDeduction = item.PhilHealthDeduction,
                    pagIbigDeduction = item.PagIbigDeduction,
                    withholdingTax = item.WithholdingTax,
                    sssLoan = item.SSSLoan,
                    pagIbigLoan = item.PagIbigLoan,
                    companyLoan = item.CompanyLoan,
                    absencePenalty = item.AbsencePenalty,
                    latePenalty = item.LatePenalty,
                    unpaidLeaveDeduction = item.UnpaidLeaveDeduction,
                    otherDeductions = item.OtherDeductions,
                    totalWorkingDays = item.TotalWorkingDays,
                    daysPresent = item.DaysPresent,
                    daysAbsent = item.DaysAbsent,
                    daysLate = item.DaysLate,
                    lateMinutes = item.LateMinutes,
                    regularOvertimeHours = item.RegularOvertimeHours,
                    holidayOvertimeHours = item.HolidayOvertimeHours,
                    nightDifferentialHours = item.NightDifferentialHours,
                    remarks = item.Remarks ?? ""
                }).ToList()
            };

            var response = new
            {
                success = true,
                data = result
            };

            System.Diagnostics.Debug.WriteLine($"[GetPayRunDetailsHandler] Returning pay run details with {result.items.Count} items");

            context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(response));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[GetPayRunDetailsHandler] ERROR: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"[GetPayRunDetailsHandler] Stack: {ex.StackTrace}");

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

