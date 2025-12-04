using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;
using System.Diagnostics;

namespace ExWebAppSia.Handler
{
    /// <summary>
    /// GeneratePayrollHandler - Async handler for payroll calculation and database save
    /// Handles POST requests from Step 2 "Generate Payroll" button
    /// </summary>
    public class GeneratePayrollHandler : IHttpAsyncHandler, IHttpHandler
    {
        // Lazy initialization to avoid startup issues
        private static PayrollProcessingService _processingService;
        private static PayRunService _payRunService;

        private static PayrollProcessingService ProcessingService
        {
            get
            {
                if (_processingService == null)
                {
                    Debug.WriteLine("[GeneratePayrollHandler] Initializing PayrollProcessingService...");
                    _processingService = new PayrollProcessingService();
                    Debug.WriteLine("[GeneratePayrollHandler] PayrollProcessingService initialized");
                }
                return _processingService;
            }
        }

        private static PayRunService PayRunService
        {
            get
            {
                if (_payRunService == null)
                {
                    Debug.WriteLine("[GeneratePayrollHandler] Initializing PayRunService...");
                    _payRunService = new PayRunService();
                    Debug.WriteLine("[GeneratePayrollHandler] PayRunService initialized");
                }
                return _payRunService;
            }
        }

        // IHttpAsyncHandler implementation
        public IAsyncResult BeginProcessRequest(HttpContext context, AsyncCallback cb, object extraData)
        {
            var task = ProcessRequestAsync(context);
            return task.ContinueWith(t => cb?.Invoke(t));
        }

        public void EndProcessRequest(IAsyncResult result)
        {
            ((Task)result).Wait();
        }

        // IHttpHandler implementation (fallback for non-async)
        public void ProcessRequest(HttpContext context)
        {
            ProcessRequestAsync(context).Wait();
        }

        private async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

            try
            {
                Debug.WriteLine("========================================");
                Debug.WriteLine("🎯 GeneratePayrollHandler - START");
                Debug.WriteLine($"📍 Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
                Debug.WriteLine("========================================");

                // Validate HTTP method
                if (context.Request.HttpMethod != "POST")
                {
                    Debug.WriteLine($"❌ Invalid HTTP method: {context.Request.HttpMethod}");
                    context.Response.StatusCode = 405;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = "Only POST method is allowed"
                    }));
                    return;
                }

                // Read request body
                string requestBody;
                using (var reader = new System.IO.StreamReader(context.Request.InputStream))
                {
                    requestBody = await reader.ReadToEndAsync();
                }

                Debug.WriteLine($"📥 Request body length: {(requestBody?.Length ?? 0)} chars");
                
                if (string.IsNullOrWhiteSpace(requestBody))
                {
                    Debug.WriteLine("❌ Empty request body");
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = "Request body is empty"
                    }));
                    return;
                }

                Debug.WriteLine($"📦 Request body preview: {requestBody.Substring(0, Math.Min(200, requestBody.Length))}...");

                // Parse request data
                dynamic requestData;
                try
                {
                    requestData = serializer.Deserialize<dynamic>(requestBody);
                }
                catch (Exception parseEx)
                {
                    Debug.WriteLine($"❌ JSON parse error: {parseEx.Message}");
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Invalid JSON format: {parseEx.Message}"
                    }));
                    return;
                }

                // Extract parameters
                List<string> employeeIds;
                string startDateStr;
                string endDateStr;
                string createdBy;

                try
                {
                    var dict = requestData as Dictionary<string, object>;
                    
                    if (dict == null)
                    {
                        throw new Exception("Request data is not a valid dictionary");
                    }

                    // Extract employee IDs
                    if (!dict.ContainsKey("employeeIds") || dict["employeeIds"] == null)
                    {
                        throw new Exception("employeeIds parameter is missing");
                    }

                    var idsArray = dict["employeeIds"] as object[];
                    if (idsArray == null || idsArray.Length == 0)
                    {
                        throw new Exception("employeeIds array is empty");
                    }

                    employeeIds = idsArray.Select(id => id?.ToString()).Where(id => !string.IsNullOrEmpty(id)).ToList();

                    if (employeeIds.Count == 0)
                    {
                        throw new Exception("No valid employee IDs provided");
                    }

                    // Extract dates
                    startDateStr = dict.ContainsKey("startDate") ? dict["startDate"]?.ToString() : null;
                    endDateStr = dict.ContainsKey("endDate") ? dict["endDate"]?.ToString() : null;
                    createdBy = dict.ContainsKey("createdBy") ? dict["createdBy"]?.ToString() : "System";

                    if (string.IsNullOrWhiteSpace(startDateStr) || string.IsNullOrWhiteSpace(endDateStr))
                    {
                        throw new Exception("startDate and endDate are required");
                    }

                    Debug.WriteLine($"✅ Extracted parameters:");
                    Debug.WriteLine($"   Employee IDs: {employeeIds.Count}");
                    Debug.WriteLine($"   First 3 IDs: {string.Join(", ", employeeIds.Take(3))}");
                    Debug.WriteLine($"   Date range: {startDateStr} to {endDateStr}");
                    Debug.WriteLine($"   Created by: {createdBy}");
                }
                catch (Exception extractEx)
                {
                    Debug.WriteLine($"❌ Parameter extraction error: {extractEx.Message}");
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Invalid request parameters: {extractEx.Message}"
                    }));
                    return;
                }

                // Parse dates
                DateTime startDate;
                DateTime endDate;
                
                try
                {
                    startDate = DateTime.Parse(startDateStr);
                    endDate = DateTime.Parse(endDateStr);

                    Debug.WriteLine($"📅 Parsed dates: {startDate:yyyy-MM-dd} to {endDate:yyyy-MM-dd}");

                    if (endDate < startDate)
                    {
                        throw new Exception("End date cannot be before start date");
                    }
                }
                catch (Exception dateEx)
                {
                    Debug.WriteLine($"❌ Date parsing error: {dateEx.Message}");
                    context.Response.StatusCode = 400;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Invalid date format: {dateEx.Message}"
                    }));
                    return;
                }

                // ========== STEP 1: GENERATE PAYROLL ==========
                Debug.WriteLine("========================================");
                Debug.WriteLine("STEP 1: Calling PayrollProcessingService.GeneratePayRunAsync...");
                Debug.WriteLine("========================================");

                PayRun payRun = null;

                try
                {
                    // Set timeout for payroll generation (90 seconds)
                    var generationTask = ProcessingService.GeneratePayRunAsync(
                        employeeIds, 
                        startDate, 
                        endDate, 
                        createdBy
                    );

                    var timeoutTask = Task.Delay(TimeSpan.FromSeconds(90));
                    var completedTask = await Task.WhenAny(generationTask, timeoutTask);

                    if (completedTask == timeoutTask)
                    {
                        Debug.WriteLine("⏱️ TIMEOUT: Payroll generation took >90 seconds");
                        context.Response.StatusCode = 504;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            message = "⏱️ Payroll calculation timed out (>90s).\n\n" +
                                     "This usually means:\n" +
                                     "• Complex calculations taking too long\n" +
                                     "• Database connection issues\n" +
                                     "• Missing payroll configurations\n\n" +
                                     "Try:\n" +
                                     "• Select fewer employees\n" +
                                     "• Ensure all employees have payroll configurations\n" +
                                     "• Check MongoDB connection"
                        }));
                        return;
                    }

                    payRun = await generationTask;

                    if (payRun == null)
                    {
                        Debug.WriteLine("❌ GeneratePayRunAsync returned null");
                        context.Response.StatusCode = 500;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            message = "Failed to generate payroll (null result from service)"
                        }));
                        return;
                    }

                    Debug.WriteLine($"✅ PayRun generated successfully:");
                    Debug.WriteLine($"   PayRunNumber: {payRun.PayRunNumber}");
                    Debug.WriteLine($"   Employees: {payRun.TotalEmployees}");
                    Debug.WriteLine($"   Total Gross: ₱{payRun.TotalGrossSalary:N2}");
                    Debug.WriteLine($"   Total Net: ₱{payRun.TotalNetSalary:N2}");
                    Debug.WriteLine($"   Items: {payRun.Items?.Count ?? 0}");
                }
                catch (TimeoutException texGen)
                {
                    Debug.WriteLine($"⏱️ Timeout during generation: {texGen.Message}");
                    context.Response.StatusCode = 504;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Payroll generation timeout: {texGen.Message}"
                    }));
                    return;
                }
                catch (Exception genEx)
                {
                    Debug.WriteLine($"❌ Error during payroll generation:");
                    Debug.WriteLine($"   Type: {genEx.GetType().Name}");
                    Debug.WriteLine($"   Message: {genEx.Message}");
                    Debug.WriteLine($"   Stack: {genEx.StackTrace}");

                    // Check for missing pay schedule (.NET Framework 4.7.2 compatible)
                    if (genEx.Message.ToLower().Contains("pay schedule") ||
                        genEx.Message.ToLower().Contains("payschedule"))
                    {
                        context.Response.StatusCode = 400;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            errorType = "MissingPaySchedule",
                            message = "⚠️ Pay Schedule not configured.\n\n" +
                                     "Please go to Settings → Payroll Configuration to set up your pay schedule first."
                        }));
                        return;
                    }

                    // Check for missing configurations
                    if (genEx.Message.ToLower().Contains("configuration"))
                    {
                        context.Response.StatusCode = 400;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            errorType = "MissingConfiguration",
                            message = $"⚠️ Payroll configuration error:\n\n{genEx.Message}\n\n" +
                                     "Please ensure all selected employees have payroll configurations set up."
                        }));
                        return;
                    }

                    // Return detailed error to help diagnose
                    context.Response.StatusCode = 500;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Error generating payroll: {genEx.Message}",
                        errorDetails = genEx.StackTrace?.Substring(0, Math.Min(500, genEx.StackTrace.Length))
                    }));
                    return;
                }

                // ========== STEP 2: SAVE TO DATABASE ==========
                Debug.WriteLine("========================================");
                Debug.WriteLine("STEP 2: Saving PayRun to MongoDB...");
                Debug.WriteLine("========================================");

                PayRun savedPayRun = null;

                try
                {
                    // Set timeout for database save (60 seconds)
                    var saveTask = PayRunService.CreateAsync(payRun);
                    var saveTimeoutTask = Task.Delay(TimeSpan.FromSeconds(60));
                    var completedSaveTask = await Task.WhenAny(saveTask, saveTimeoutTask);

                    if (completedSaveTask == saveTimeoutTask)
                    {
                        Debug.WriteLine("⏱️ TIMEOUT: Database save took >60 seconds");
                        context.Response.StatusCode = 504;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            message = "⏱️ Database save timed out (>60s).\n\n" +
                                     "Payroll calculated successfully but failed to save.\n\n" +
                                     "This usually means:\n" +
                                     "• MongoDB Atlas is slow or unreachable\n" +
                                     "• Network firewall blocking connection\n" +
                                     "• Connection pool exhausted\n\n" +
                                     "Please check:\n" +
                                     "1. MongoDB Atlas is running\n" +
                                     "2. IP whitelist includes your current IP\n" +
                                     "3. Connection string is correct\n" +
                                     "4. Network connectivity"
                        }));
                        return;
                    }

                    savedPayRun = await saveTask;

                    if (savedPayRun == null || string.IsNullOrEmpty(savedPayRun.Id))
                    {
                        Debug.WriteLine("❌ CreateAsync returned null or empty ID");
                        context.Response.StatusCode = 500;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            message = "Failed to save payroll to database (null result)"
                        }));
                        return;
                    }

                    Debug.WriteLine($"✅ PayRun saved to MongoDB:");
                    Debug.WriteLine($"   ID: {savedPayRun.Id}");
                    Debug.WriteLine($"   PayRunNumber: {savedPayRun.PayRunNumber}");

                    // ========== AUTO-APPROVE AND SEND EMAILS ==========
                    Debug.WriteLine("========================================");
                    Debug.WriteLine("STEP 2.5: Auto-approving and sending emails...");
                    Debug.WriteLine("========================================");
                    
                    try 
                    {
                        // Automatically approve the payroll to trigger email sending
                        await PayRunService.ApproveAsync(savedPayRun.Id, createdBy, "Auto-approved upon generation");
                        
                        // Refresh the payRun object to get the updated status
                        savedPayRun = await PayRunService.GetByIdAsync(savedPayRun.Id);
                        Debug.WriteLine("✅ Payroll auto-approved and emails sent");
                    }
                    catch (Exception approveEx)
                    {
                        Debug.WriteLine($"⚠️ Auto-approval failed: {approveEx.Message}");
                        // We don't fail the whole request, just log the warning
                    }
                }
                catch (TimeoutException texSave)
                {
                    Debug.WriteLine($"⏱️ Timeout during database save: {texSave.Message}");
                    context.Response.StatusCode = 504;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Database save timeout: {texSave.Message}"
                    }));
                    return;
                }
                catch (Exception saveEx)
                {
                    Debug.WriteLine($"❌ Error during database save:");
                    Debug.WriteLine($"   Type: {saveEx.GetType().Name}");
                    Debug.WriteLine($"   Message: {saveEx.Message}");
                    Debug.WriteLine($"   Stack: {saveEx.StackTrace}");

                    // Check if it's a MongoDB connection error
                    if (saveEx.Message.ToLower().Contains("mongodb") ||
                        saveEx.Message.ToLower().Contains("timeout") ||
                        saveEx.GetType().FullName.Contains("Mongo"))
                    {
                        context.Response.StatusCode = 503;
                        context.Response.Write(serializer.Serialize(new
                        {
                            success = false,
                            errorType = "DatabaseConnection",
                            message = $"⚠️ Database connection error while saving payroll:\n\n{saveEx.Message}\n\n" +
                                     "Please check MongoDB Atlas connection and try again."
                        }));
                        return;
                    }

                    context.Response.StatusCode = 500;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Error saving payroll: {saveEx.Message}"
                    }));
                    return;
                }

                // ========== STEP 3: BUILD RESPONSE ==========
                Debug.WriteLine("========================================");
                Debug.WriteLine("STEP 3: Building response DTO...");
                Debug.WriteLine("========================================");

                try
                {
                    var response = new
                    {
                        success = true,
                        message = "Payroll generated and saved successfully",
                        data = new
                        {
                            payRunId = savedPayRun.Id,
                            payRunNumber = savedPayRun.PayRunNumber,
                            status = savedPayRun.Status,
                            period = savedPayRun.PayPeriodDisplay,
                            totalEmployees = savedPayRun.TotalEmployees,
                            totalGrossSalary = savedPayRun.TotalGrossSalary,
                            totalDeductions = savedPayRun.TotalDeductions,
                            totalNetSalary = savedPayRun.TotalNetSalary,
                            items = savedPayRun.Items.Select(item => new
                            {
                                employeeId = item.EmployeeId,
                                employeeName = item.EmployeeName,
                                employeeNumber = item.EmployeeId, // Use EmployeeId as number
                                department = item.Department,
                                position = item.Position,
                                daysPresent = item.DaysPresent,
                                daysAbsent = item.DaysAbsent,
                                daysLate = item.DaysLate,
                                lateMinutes = item.LateMinutes,
                                basicSalary = item.BasicSalary,
                                proratedBasicSalary = item.ProratedBasicSalary,
                                totalAllowances = item.Allowances,
                                overtimePay = item.OvertimePay,
                                grossSalary = item.GrossSalary,
                                sssContribution = item.SSSDeduction,
                                philHealthContribution = item.PhilHealthDeduction,
                                pagIbigContribution = item.PagIbigDeduction,
                                withholdingTax = item.WithholdingTax,
                                sssLoan = item.SSSLoan,
                                pagIbigLoan = item.PagIbigLoan,
                                companyLoan = item.CompanyLoan,
                                absencePenalty = item.AbsencePenalty,
                                latePenalty = item.LatePenalty,
                                unpaidLeaveDeduction = item.UnpaidLeaveDeduction,
                                otherDeductions = item.OtherDeductions,
                                totalDeductions = item.TotalDeductions,
                                netSalary = item.NetSalary,
                                status = item.Status,
                                remarks = item.Remarks
                            }).ToList()
                        }
                    };

                    var json = serializer.Serialize(response);

                    Debug.WriteLine($"✅ Response built successfully:");
                    Debug.WriteLine($"   JSON length: {json.Length} chars");
                    Debug.WriteLine($"   Items count: {savedPayRun.Items.Count}");

                    context.Response.StatusCode = 200;
                    context.Response.Write(json);

                    Debug.WriteLine("========================================");
                    Debug.WriteLine("✅ GeneratePayrollHandler - SUCCESS");
                    Debug.WriteLine($"📍 Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
                    Debug.WriteLine("========================================");
                }
                catch (Exception buildEx)
                {
                    Debug.WriteLine($"❌ Error building response: {buildEx.Message}");
                    context.Response.StatusCode = 500;
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = false,
                        message = $"Error building response: {buildEx.Message}"
                    }));
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("========================================");
                Debug.WriteLine("❌ UNHANDLED EXCEPTION in GeneratePayrollHandler");
                Debug.WriteLine($"   Type: {ex.GetType().FullName}");
                Debug.WriteLine($"   Message: {ex.Message}");
                Debug.WriteLine($"   Stack: {ex.StackTrace}");
                
                if (ex.InnerException != null)
                {
                    Debug.WriteLine($"   Inner Exception: {ex.InnerException.Message}");
                    Debug.WriteLine($"   Inner Stack: {ex.InnerException.StackTrace}");
                }
                Debug.WriteLine("========================================");

                context.Response.StatusCode = 500;
                context.Response.Write(serializer.Serialize(new
                {
                    success = false,
                    message = $"Unexpected error: {ex.Message}",
                    details = ex.StackTrace?.Substring(0, Math.Min(500, ex.StackTrace?.Length ?? 0))
                }));
            }
        }

        public bool IsReusable => false;
    }
}
