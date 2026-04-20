using System;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

using System.Web.SessionState;

namespace ExWebAppSia.webpage_SuperAdminViewpoint_.api
{
    public class AttendanceHandler : IHttpHandler, IRequiresSessionState
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
                
                // Security: Prefer Identity from Session to prevent "automatic" timing in/out for wrong users
                string sessionEmployeeId = context.Session?["Employee"] is Employee sessionEmp ? sessionEmp.EmployeeId : null;
                string employeeId = (context.Request["employeeId"] ?? context.Request.QueryString["employeeId"] ?? "").Trim();
                
                if (string.IsNullOrEmpty(employeeId))
                {
                    employeeId = sessionEmployeeId;
                }
                
                // If session is active, override param if mismatch to prevent accidental errors
                if (!string.IsNullOrEmpty(sessionEmployeeId) && employeeId != sessionEmployeeId)
                {
                    System.Diagnostics.Debug.WriteLine($"[Security] Identity mismatch in Handler: Param={employeeId}, Session={sessionEmployeeId}. Using Session.");
                    employeeId = sessionEmployeeId;
                }

                string employeeName = context.Request["employeeName"] ?? context.Request.QueryString["employeeName"] ?? "";
                string department = context.Request["department"] ?? context.Request.QueryString["department"] ?? "";

                if (string.IsNullOrEmpty(employeeName) && context.Session?["Employee"] is Employee empData)
                {
                    employeeName = empData.FullName;
                    department = empData.Department;
                }

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

                                // NEW: 16-minute late restriction
                                var nowLocal = DateTime.UtcNow.AddHours(8);
                                // Fetch employee once for all checks
                                var empInfo = Task.Run(() => _employeeService.GetByEmployeeIdAsync(employeeId)).GetAwaiter().GetResult();

                                if (nowLocal.TimeOfDay >= new TimeSpan(8, 16, 0) && (empInfo == null || (empInfo.Role != "President" && empInfo.Role != "CEO")))
                                {
                                    result = false;
                                    message = "Time in is restricted after 8:16 AM. You are late by 16 minutes or more and cannot time in for today according to company policy. Please contact HR.";
                                    System.Diagnostics.Debug.WriteLine($"Blocked Late TimeIn for {employeeId}: {nowLocal:HH:mm:ss}");
                                }
                                else if (empInfo != null && empInfo.HiredDate.Date == DateTime.UtcNow.Date
                                    && empInfo.Role != "President" && empInfo.Role != "CEO")
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

                                 // Check undertime status even if todayAttendance is null (e.g. if they already timed out)
                                 string utStatus = "None";
                                 var utService = new UndertimeService();
                                 var utRequest = Task.Run(async () => await utService.GetActiveRequestAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                 if (utRequest != null)
                                 {
                                     utStatus = utRequest.Status;
                                 }

                                 var statusResponse = new
                                 {
                                     success = true,
                                     hasTimedIn = todayAttendance != null && todayAttendance.TimeIn.HasValue,
                                     hasTimedOut = todayAttendance != null && todayAttendance.TimeOut.HasValue,
                                     timeIn = todayAttendance?.TimeIn?.ToLocalTime().ToString("h:mm tt"),
                                     timeOut = todayAttendance?.TimeOut?.ToLocalTime().ToString("h:mm tt"),
                                     overtimeStatus = otStatus,
                                     undertimeStatus = utStatus,
                                     debugInfo = new {
                                         receivedEmployeeId = employeeId,
                                         foundStatus = utStatus,
                                         attendanceFound = todayAttendance != null
                                     }
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

                    case "requestundertime":
                        string utReason = context.Request["reason"] ?? context.Request.QueryString["reason"] ?? "No reason provided";
                        if (string.IsNullOrEmpty(employeeId))
                        {
                            message = "Missing employee ID";
                        }
                        else
                        {
                            // Modified: Check for any attendance today, even if already timed out
                            var attendanceRecords = Task.Run(async () => await _attendanceService.GetEmployeeAttendanceAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            var todayDate = DateTime.UtcNow.AddHours(8).Date;
                            
                            // Find the latest record for today
                            var latestTodayAttendance = attendanceRecords
                                .Where(a => a.Date.Date == todayDate || (a.TimeIn.HasValue && a.TimeIn.Value.ToLocalTime().Date == todayDate))
                                .OrderByDescending(a => a.TimeIn)
                                .FirstOrDefault();

                            if (latestTodayAttendance == null)
                            {
                                result = false;
                                message = "No attendance record found for today. Please time in first.";
                            }
                            else
                            {
                                var utService = new UndertimeService();
                                var empUt = Task.Run(async () => await _employeeService.GetEmployeeByIdAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                string empNameUt = empUt?.FullName ?? latestTodayAttendance.EmployeeName;
                                string deptUt = empUt?.Department ?? latestTodayAttendance.Department;
                                result = Task.Run(async () => await utService.RequestUndertimeAsync(latestTodayAttendance.Id, employeeId, empNameUt, deptUt, utReason).ConfigureAwait(false)).GetAwaiter().GetResult();
                                message = result ? "Undertime request submitted successfully" : "Failed to submit undertime request.";
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
                            var currentAttendance = Task.Run(async () => await _attendanceService.GetTodayAttendanceAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            if (currentAttendance == null || currentAttendance.TimeOut.HasValue)
                            {
                                result = false;
                                message = "No active shift found. Make sure you are timed in.";
                            }
                            else
                            {
                                // Get employee details for the request
                                var empOt = Task.Run(async () => await _employeeService.GetEmployeeByIdAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                                string empNameOt = empOt?.FullName ?? currentAttendance.EmployeeName;
                                string deptOt = empOt?.Department ?? currentAttendance.Department;
                                result = Task.Run(async () => await _overtimeService.RequestOvertimeAsync(currentAttendance.Id, employeeId, empNameOt, deptOt, reason).ConfigureAwait(false)).GetAwaiter().GetResult();
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

                    case "approveundertime":
                        string utReqId = context.Request["attendanceId"] ?? context.Request.QueryString["attendanceId"] ?? "";
                        if (string.IsNullOrEmpty(utReqId))
                        {
                            message = "Missing undertime request ID";
                        }
                        else
                        {
                            var utService = new UndertimeService();
                            result = Task.Run(async () => await utService.ApproveRequestAsync(utReqId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            message = result ? "Undertime approved successfully" : "Failed to approve undertime";
                        }
                        break;

                    case "rejectundertime":
                        string rejUtId = context.Request["attendanceId"] ?? context.Request.QueryString["attendanceId"] ?? "";
                        if (string.IsNullOrEmpty(rejUtId))
                        {
                            message = "Missing undertime request ID";
                        }
                        else
                        {
                            var utService = new UndertimeService();
                            result = Task.Run(async () => await utService.RejectRequestAsync(rejUtId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            message = result ? "Undertime rejected successfully" : "Failed to reject undertime";
                        }
                        break;
                    
                    case "requestresignation":
                        string resignReason = context.Request["reason"] ?? context.Request.QueryString["reason"] ?? "";
                        if (string.IsNullOrEmpty(employeeId))
                        {
                            message = "Missing employee ID";
                        }
                        else
                        {
                            // Need to handle Mongodb _id if passed, or convert EmployeeId to Mongodb _id
                            var empResign = Task.Run(async () => await _employeeService.GetByEmployeeIdAsync(employeeId).ConfigureAwait(false)).GetAwaiter().GetResult();
                            if (empResign != null)
                            {
                                result = Task.Run(async () => await _employeeService.RequestResignationAsync(empResign.Id, resignReason).ConfigureAwait(false)).GetAwaiter().GetResult();
                                message = result ? "Resignation request submitted" : "Failed to submit resignation request";
                            }
                            else
                            {
                                message = "Employee not found";
                            }
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

