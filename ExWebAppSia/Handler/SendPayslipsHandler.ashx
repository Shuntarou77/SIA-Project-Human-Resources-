<%@ WebHandler Language="C#" Class="SendPayslipsHandler" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Web.Script.Serialization;

public class SendPayslipsHandler : IHttpAsyncHandler, IHttpHandler
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

        var serializer = new JavaScriptSerializer();

        try
        {
            Debug.WriteLine("========================================");
            Debug.WriteLine("[SendPayslipsHandler] START");
            Debug.WriteLine("========================================");

            // Read request body
            string requestBody;
            using (var reader = new System.IO.StreamReader(context.Request.InputStream))
            {
                requestBody = await reader.ReadToEndAsync();
            }

            Debug.WriteLine($"[SendPayslipsHandler] Request body: {requestBody}");

            // Parse request
            dynamic requestData = serializer.Deserialize<dynamic>(requestBody);
            
            var dict = requestData as Dictionary<string, object>;
            if (dict == null)
            {
                throw new Exception("Invalid request format");
            }

            string payRunId = dict.ContainsKey("payRunId") ? dict["payRunId"]?.ToString() : null;
            string sentBy = dict.ContainsKey("sentBy") ? dict["sentBy"]?.ToString() : "System";

            if (string.IsNullOrEmpty(payRunId))
            {
                throw new Exception("payRunId is required");
            }

            Debug.WriteLine($"[SendPayslipsHandler] PayRunId: {payRunId}");
            Debug.WriteLine($"[SendPayslipsHandler] SentBy: {sentBy}");

            // Get the pay run
            Debug.WriteLine("[SendPayslipsHandler] Creating PayRunService...");
            var payRunService = new PayRunService();
            
            Debug.WriteLine("[SendPayslipsHandler] Getting pay run from database...");
            var payRun = await payRunService.GetByIdAsync(payRunId);

            if (payRun == null)
            {
                throw new Exception("Pay run not found");
            }

            // Verify status is Approved
            if (payRun.Status != "Approved")
            {
                throw new Exception($"Cannot send payslips for payroll with status '{payRun.Status}'. Only approved payrolls can have payslips sent.");
            }

            Debug.WriteLine($"[SendPayslipsHandler] Found pay run: {payRun.PayRunNumber}");
            Debug.WriteLine($"[SendPayslipsHandler] Status: {payRun.Status}");
            Debug.WriteLine($"[SendPayslipsHandler] Total Employees: {payRun.TotalEmployees}");
            Debug.WriteLine($"[SendPayslipsHandler] Total Items: {payRun.Items?.Count ?? 0}");

            // Initialize services
            Debug.WriteLine("[SendPayslipsHandler] Creating EmailService...");
            var emailService = new EmailService();
            
            Debug.WriteLine("[SendPayslipsHandler] Creating EmployeeService...");
            var employeeService = new EmployeeService();

            int emailsSent = 0;
            int emailsFailed = 0;
            var failedEmployees = new List<string>();

            // Send payslip email to each employee
            if (payRun.Items != null && payRun.Items.Count > 0)
            {
                Debug.WriteLine($"[SendPayslipsHandler] Sending emails to {payRun.Items.Count} employees...");

                foreach (var item in payRun.Items)
                {
                    try
                    {
                        Debug.WriteLine($"[SendPayslipsHandler] Processing employee: {item.EmployeeName} (ID: {item.EmployeeId})");

                        // Get employee details to fetch email address
                        // item.EmployeeId appears to be a MongoDB ObjectId (e.g. "69315af9..."), so we use GetEmployeeByIdAsync
                        var employee = await employeeService.GetEmployeeByIdAsync(item.EmployeeId);
                        
                        // Fallback: If not found by Mongo ID, try by Custom Employee ID (just in case)
                        if (employee == null)
                        {
                            employee = await employeeService.GetByEmployeeIdAsync(item.EmployeeId);
                        }

                        if (employee == null)
                        {
                            Debug.WriteLine($"[SendPayslipsHandler] ⚠️ Employee not found: {item.EmployeeId}");
                            emailsFailed++;
                            failedEmployees.Add($"{item.EmployeeName} (Employee not found)");
                            continue;
                        }

                        if (string.IsNullOrEmpty(employee.Email))
                        {
                            Debug.WriteLine($"[SendPayslipsHandler] ⚠️ No email address for employee: {item.EmployeeName}");
                            emailsFailed++;
                            failedEmployees.Add($"{item.EmployeeName} (No email address)");
                            continue;
                        }

                        Debug.WriteLine($"[SendPayslipsHandler] Sending email to: {employee.Email}");

                        // Format pay period
                        string payPeriod = $"{payRun.PayPeriodStart:MMM dd} - {payRun.PayPeriodEnd:MMM dd, yyyy}";

                        // Send email (without PDF for now - can be added later)
                        bool emailSent = await emailService.SendPayslipEmailAsync(
                            toEmail: employee.Email,
                            employeeName: item.EmployeeName,
                            payPeriod: payPeriod,
                            pdfBytes: null,
                            fileName: $"Payslip_{payRun.PayRunNumber}_{item.EmployeeName.Replace(" ", "_")}.pdf"
                        );

                        if (emailSent)
                        {
                            emailsSent++;
                            Debug.WriteLine($"[SendPayslipsHandler] ✅ Email sent to {employee.Email}");
                        }
                        else
                        {
                            emailsFailed++;
                            failedEmployees.Add($"{item.EmployeeName} (Email send failed)");
                            Debug.WriteLine($"[SendPayslipsHandler] ❌ Failed to send email to {employee.Email}");
                        }
                    }
                    catch (Exception empEx)
                    {
                        emailsFailed++;
                        failedEmployees.Add($"{item.EmployeeName} (Error: {empEx.Message})");
                        Debug.WriteLine($"[SendPayslipsHandler] ❌ Error processing employee {item.EmployeeName}: {empEx.Message}");
                        Debug.WriteLine($"[SendPayslipsHandler] Stack: {empEx.StackTrace}");
                    }
                }
            }

            Debug.WriteLine($"[SendPayslipsHandler] Email sending complete:");
            Debug.WriteLine($"[SendPayslipsHandler]   ✅ Sent: {emailsSent}");
            Debug.WriteLine($"[SendPayslipsHandler]   ❌ Failed: {emailsFailed}");

            // Mark payslips as generated
            payRun.IsPayslipsGenerated = true;
            payRun.PayslipsGeneratedAt = DateTime.UtcNow;
            payRun.PayslipsGeneratedBy = sentBy;

            // Update the pay run
            Debug.WriteLine("[SendPayslipsHandler] Updating pay run in database...");
            await payRunService.UpdateAsync(payRun.Id, payRun);
            Debug.WriteLine("[SendPayslipsHandler] Pay run updated successfully");

            // Prepare response message
            string message;
            if (emailsFailed == 0)
            {
                message = $"Payslips sent successfully to all {emailsSent} employees!";
            }
            else if (emailsSent == 0)
            {
                message = $"Failed to send payslips to all {emailsFailed} employees. Please check employee email addresses.";
            }
            else
            {
                message = $"Payslips sent to {emailsSent} employees. {emailsFailed} failed.";
            }

            var response = new
            {
                success = true,
                message = message,
                data = new
                {
                    payRunId = payRun.Id,
                    payRunNumber = payRun.PayRunNumber,
                    totalEmployees = payRun.TotalEmployees,
                    emailsSent = emailsSent,
                    emailsFailed = emailsFailed,
                    failedEmployees = failedEmployees,
                    sentAt = payRun.PayslipsGeneratedAt,
                    sentBy = payRun.PayslipsGeneratedBy
                }
            };

            Debug.WriteLine($"[SendPayslipsHandler] SUCCESS");
            Debug.WriteLine("========================================");

            context.Response.Write(serializer.Serialize(response));
        }
        catch (Exception ex)
        {
            Debug.WriteLine("========================================");
            Debug.WriteLine($"[SendPayslipsHandler] FATAL ERROR: {ex.Message}");
            Debug.WriteLine($"[SendPayslipsHandler] Error Type: {ex.GetType().FullName}");
            Debug.WriteLine($"[SendPayslipsHandler] Stack Trace:");
            Debug.WriteLine(ex.StackTrace);
            
            if (ex.InnerException != null)
            {
                Debug.WriteLine($"[SendPayslipsHandler] Inner Exception: {ex.InnerException.Message}");
                Debug.WriteLine($"[SendPayslipsHandler] Inner Stack:");
                Debug.WriteLine(ex.InnerException.StackTrace);
            }
            Debug.WriteLine("========================================");

            var errorResponse = new
            {
                success = false,
                message = $"Error: {ex.Message}",
                errorType = ex.GetType().Name,
                stackTrace = ex.StackTrace
            };

            context.Response.StatusCode = 500;
            context.Response.Write(serializer.Serialize(errorResponse));
        }
    }

    public bool IsReusable => false;
}
