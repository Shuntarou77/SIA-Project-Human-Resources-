using System;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage.api
{
    public class AttendanceHandler : IHttpHandler
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ActivityLogService _logService = new ActivityLogService();
        private readonly OvertimeService _overtimeService = new OvertimeService();

        public void ProcessRequest(HttpContext context)
        {
            // Immediate logging to ensure we see something
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine("AttendanceHandler.ProcessRequest CALLED");
            System.Diagnostics.Debug.WriteLine($"Time: {DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}");
            System.Diagnostics.Debug.WriteLine($"Method: {context.Request.HttpMethod}");
            System.Diagnostics.Debug.WriteLine($"URL: {context.Request.Url}");
            System.Diagnostics.Debug.WriteLine($"QueryString: {context.Request.QueryString}");
            System.Diagnostics.Debug.WriteLine("========================================");
            
            try
            {
                context.Response.ContentType = "application/json";
                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                
                // Handle CORS if needed
                if (context.Request.HttpMethod == "OPTIONS")
                {
                    System.Diagnostics.Debug.WriteLine("OPTIONS request - returning early");
                    context.Response.StatusCode = 200;
                    context.Response.End();
                    return;
                }

                string action = context.Request["action"] ?? context.Request.QueryString["action"] ?? "";
                string employeeId = context.Request["employeeId"] ?? context.Request.QueryString["employeeId"] ?? "";
                string employeeName = context.Request["employeeName"] ?? context.Request.QueryString["employeeName"] ?? "";
                string department = context.Request["department"] ?? context.Request.QueryString["department"] ?? "";

                System.Diagnostics.Debug.WriteLine($"AttendanceHandler called - Action: {action}, EmployeeId: {employeeId}, EmployeeName: {employeeName}");
                System.Diagnostics.Trace.WriteLine($"TRACE: AttendanceHandler - Action: {action}, EmployeeId: {employeeId}");

                var serializer = new JavaScriptSerializer();

                // Test endpoint to verify handler is working
                if (action.ToLower() == "test")
                {
                    var testResponse = new { success = true, message = "Handler is working!" };
                    context.Response.Write(serializer.Serialize(testResponse));
                    return;
                }

                bool result = false;
                string message = "";

                switch (action.ToLower())
                {
                    case "timein":
                        if (string.IsNullOrEmpty(employeeId) || string.IsNullOrEmpty(employeeName))
                        {
                            message = "Missing required parameters";
                            System.Diagnostics.Debug.WriteLine($"Missing parameters - EmployeeId: {employeeId}, EmployeeName: {employeeName}");
                        }
                        else
                        {
                            try
                            {
                                System.Diagnostics.Debug.WriteLine($"=== Starting TimeIn Process ===");
                                System.Diagnostics.Debug.WriteLine($"EmployeeId: {employeeId}");
                                System.Diagnostics.Debug.WriteLine($"EmployeeName: {employeeName}");
                                System.Diagnostics.Debug.WriteLine($"Department: {department}");

                                // NEW: Restriction - Newly hired employees cannot time in on their hiring date
                                var employee = Task.Run(() => _employeeService.GetByEmployeeIdAsync(employeeId)).GetAwaiter().GetResult();
                                if (employee != null && employee.HiredDate.Date == DateTime.UtcNow.Date)
                                {
                                    result = false;
                                    message = "New employees are restricted from timing in on their first day of hiring. You may begin clocking in starting tomorrow. Welcome to the team!";
                                    System.Diagnostics.Debug.WriteLine($"Blocked TimeIn for new hire: {employeeId} (Hired today)");
                                }
                                else
                                {
                                    // Use async method synchronously with ConfigureAwait(false) to avoid deadlock
                                    var timeInTask = Task.Run(async () =>
                                    {
                                        try
                                        {
                                            return await _attendanceService.TimeInAsync(employeeId, employeeName, department).ConfigureAwait(false);
                                        }
                                        catch (Exception taskEx)
                                        {
                                            System.Diagnostics.Debug.WriteLine($"Exception in TimeInAsync task: {taskEx.Message}\n{taskEx.StackTrace}");
                                            if (taskEx.InnerException != null)
                                            {
                                                System.Diagnostics.Debug.WriteLine($"Inner exception: {taskEx.InnerException.Message}\n{taskEx.InnerException.StackTrace}");
                                            }
                                            throw;
                                        }
                                    });

                                    result = timeInTask.GetAwaiter().GetResult();
                                    message = result ? "Time in recorded successfully" : "Failed to record time in or already timed in today";
                                    System.Diagnostics.Debug.WriteLine($"TimeIn result: {result}, Message: {message}");

                                    if (result)
                                    {
                                        // Verify the record was saved
                                        var verifyTask = Task.Run(async () =>
                                        {
                                            try
                                            {
                                                await System.Threading.Tasks.Task.Delay(200); // Wait a bit for write to complete
                                                var today = DateTime.UtcNow.Date;
                                                System.Diagnostics.Debug.WriteLine($"Verifying record for EmployeeId: {employeeId}, Date: {today:yyyy-MM-dd}");
                                                var record = await _attendanceService.GetTodayAttendanceAsync(employeeId);
                                                if (record != null)
                                                {
                                                    System.Diagnostics.Debug.WriteLine($"Verified: Record saved with Date={record.Date:yyyy-MM-dd}, TimeIn={record.TimeIn:yyyy-MM-dd HH:mm:ss}, ID={record.Id}");
                                                }
                                                else
                                                {
                                                    System.Diagnostics.Debug.WriteLine($"WARNING: Record not found after save! Trying to get all records...");
                                                    var allRecords = await _attendanceService.GetAllActiveAttendanceAsync();
                                                    System.Diagnostics.Debug.WriteLine($"Total active records in database: {allRecords.Count}");
                                                    foreach (var r in allRecords.Take(5))
                                                    {
                                                        System.Diagnostics.Debug.WriteLine($"  - EmployeeId: {r.EmployeeId}, Date: {r.Date:yyyy-MM-dd}, TimeIn: {r.TimeIn?.ToString("yyyy-MM-dd HH:mm:ss") ?? "null"}");
                                                    }
                                                }
                                            }
                                            catch (Exception verifyEx)
                                            {
                                                System.Diagnostics.Debug.WriteLine($"Error during verification: {verifyEx.Message}\n{verifyEx.StackTrace}");
                                            }
                                        });
                                        verifyTask.Wait(TimeSpan.FromSeconds(5)); // 5 second timeout
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error in TimeIn: {ex.Message}\n{ex.StackTrace}");
                                if (ex.InnerException != null)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}\n{ex.InnerException.StackTrace}");
                                }
                                message = "Error: " + ex.Message;
                                result = false;
                            }
                        }
                        break;

                    case "timeout":
                        if (string.IsNullOrEmpty(employeeId))
                        {
                            message = "Missing employee ID";
                        }
                        else
                        {
                            try
                            {
                                // Use async method synchronously with ConfigureAwait(false) to avoid deadlock
                                result = Task.Run(async () => await _attendanceService.TimeOutAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                message = result ? "Time out recorded successfully" : "Failed to record time out or not timed in yet";
                                System.Diagnostics.Debug.WriteLine($"TimeOut result: {result}, Message: {message}");

                                // NEW: Notify HR via Activity Log for Undertime or OT
                                if (result)
                                {
                                    try 
                                    {
                                        var nowLocal = DateTime.UtcNow.AddHours(8); // UTC+8
                                        if (nowLocal.Hour < 17) // Before 5:00 PM
                                        {
                                            System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                                                Task.Run(() => _logService.LogActionAsync(employeeId, employeeName, "Undertime Notification", "Attendance", $"Clocked out early at {nowLocal:hh:mm tt}. Potential undertime detected."))
                                            );
                                        }
                                        else if (nowLocal.Hour >= 18) // 6:00 PM or later is considered OT
                                        {
                                            System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                                                Task.Run(() => _logService.LogActionAsync(employeeId, employeeName, "Overtime Notification", "Attendance", $"Clocked out at {nowLocal:hh:mm tt} (OT) "))
                                            );
                                        }
                                    }
                                    catch { /* Silent fail */ }
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error in TimeOut: {ex.Message}\n{ex.StackTrace}");
                                message = "Error: " + ex.Message;
                                result = false;
                            }
                        }
                        break;

                    case "getstatus":
                        if (string.IsNullOrEmpty(employeeId))
                        {
                            message = "Missing employee ID";
                        }
                        else
                        {
                            try
                            {
                                var todayAttendance = Task.Run(async () => await _attendanceService.GetTodayAttendanceAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                
                                string otStatus = "None";
                                if (todayAttendance != null)
                                {
                                    var otRequest = Task.Run(async () => await _overtimeService.GetByAttendanceIdAsync(todayAttendance.Id).ConfigureAwait(false)).GetAwaiter().GetResult();
                                    if (otRequest != null)
                                    {
                                        otStatus = otRequest.Status;
                                    }
                                }

                                var statusResponse = new
                                {
                                    success = true,
                                    hasTimedIn = todayAttendance != null && todayAttendance.TimeIn.HasValue,
                                    hasTimedOut = todayAttendance != null && todayAttendance.TimeOut.HasValue,
                                    timeIn = todayAttendance?.TimeIn?.ToLocalTime().ToString("h:mm tt"),
                                    timeOut = todayAttendance?.TimeOut?.ToLocalTime().ToString("h:mm tt"),
                                    overtimeStatus = otStatus
                                };

                                string jsonStatus = serializer.Serialize(statusResponse);
                                context.Response.Write(jsonStatus);
                                return; // End request here since we sent custom response
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error in GetStatus: {ex.Message}");
                                message = "Error: " + ex.Message;
                                result = false;
                            }
                        }
                        break;

                    case "requestovertime":
                        string reason = context.Request["reason"] ?? context.Request.QueryString["reason"] ?? "No reason provided";
                        if (string.IsNullOrEmpty(employeeId))
                        {
                            message = "Missing employee ID";
                        }
                        else
                        {
                            // Get today's attendance record to get its ID
                            var todayAttendance = Task.Run(async () => await _attendanceService.GetTodayAttendanceAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            if (todayAttendance == null || todayAttendance.TimeOut.HasValue)
                            {
                                result = false;
                                message = "No active shift found. Make sure you are timed in.";
                            }
                            else
                            {
                                // Get employee details for the request
                                var emp = Task.Run(async () => await _employeeService.GetEmployeeByIdAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                string empName = emp?.FullName ?? todayAttendance.EmployeeName;
                                string dept = emp?.Department ?? todayAttendance.Department;
                                result = Task.Run(async () => await _overtimeService.RequestOvertimeAsync(todayAttendance.Id, employeeId, empName, dept, reason).ConfigureAwait(false)).GetAwaiter().GetResult();
                                message = result ? "Overtime request submitted successfully" : "Failed to submit overtime request. A request may already be pending.";
                            }
                        }
                        break;

                    case "approveovertime":
                        string overtimeRequestId = context.Request["attendanceId"] ?? context.Request.QueryString["attendanceId"] ?? "";
                        if (string.IsNullOrEmpty(overtimeRequestId))
                        {
                            message = "Missing overtime request ID";
                        }
                        else
                        {
                            result = Task.Run(async () => await _overtimeService.ApproveAsync(overtimeRequestId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            message = result ? "Overtime approved successfully" : "Failed to approve overtime";
                        }
                        break;

                    case "rejectovertime":
                        string rejOvertimeId = context.Request["attendanceId"] ?? context.Request.QueryString["attendanceId"] ?? "";
                        if (string.IsNullOrEmpty(rejOvertimeId))
                        {
                            message = "Missing overtime request ID";
                        }
                        else
                        {
                            result = Task.Run(async () => await _overtimeService.RejectAsync(rejOvertimeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            message = result ? "Overtime rejected successfully" : "Failed to reject overtime";
                        }
                        break;

                    default:
                        message = "Invalid action: " + action;
                        System.Diagnostics.Debug.WriteLine($"Invalid action: {action}");
                        break;
                }

                var response = new
                {
                    success = result,
                    message = message
                };

                string jsonResponse = serializer.Serialize(response);
                System.Diagnostics.Debug.WriteLine($"Sending response: {jsonResponse}");
                context.Response.Write(jsonResponse);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Fatal error in AttendanceHandler: {ex.Message}\n{ex.StackTrace}");
                var errorResponse = new
                {
                    success = false,
                    message = "Error: " + ex.Message
                };
                var serializer = new JavaScriptSerializer();
                try
                {
                    context.Response.Write(serializer.Serialize(errorResponse));
                }
                catch
                {
                    // If we can't write JSON, write plain text
                    context.Response.Write("{\"success\":false,\"message\":\"Error: " + ex.Message.Replace("\"", "\\\"") + "\"}");
                }
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}

