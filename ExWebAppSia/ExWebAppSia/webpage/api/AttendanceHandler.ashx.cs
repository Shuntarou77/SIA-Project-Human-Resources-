using System;
using System.Web;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage.api
{
    public class AttendanceHandler : IHttpHandler
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                context.Response.ContentType = "application/json";
                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                
                // Handle CORS if needed
                if (context.Request.HttpMethod == "OPTIONS")
                {
                    context.Response.StatusCode = 200;
                    context.Response.End();
                    return;
                }

                string action = context.Request["action"] ?? context.Request.QueryString["action"] ?? "";
                string employeeId = context.Request["employeeId"] ?? context.Request.QueryString["employeeId"] ?? "";
                string employeeName = context.Request["employeeName"] ?? context.Request.QueryString["employeeName"] ?? "";
                string department = context.Request["department"] ?? context.Request.QueryString["department"] ?? "";

                System.Diagnostics.Debug.WriteLine($"AttendanceHandler called - Action: {action}, EmployeeId: {employeeId}, EmployeeName: {employeeName}");

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
                                // Use async method synchronously with ConfigureAwait(false) to avoid deadlock
                                result = Task.Run(async () => await _attendanceService.TimeInAsync(employeeId, employeeName, department).ConfigureAwait(false)).GetAwaiter().GetResult();
                                message = result ? "Time in recorded successfully" : "Failed to record time in or already timed in today";
                                System.Diagnostics.Debug.WriteLine($"TimeIn result: {result}, Message: {message}");
                                
                                if (result)
                                {
                                    // Verify the record was saved
                                    var verifyTask = Task.Run(async () => 
                                    {
                                        var today = DateTime.UtcNow.Date;
                                        var record = await _attendanceService.GetTodayAttendanceAsync(employeeId);
                                        if (record != null)
                                        {
                                            System.Diagnostics.Debug.WriteLine($"Verified: Record saved with Date={record.Date:yyyy-MM-dd}, TimeIn={record.TimeIn}");
                                        }
                                        else
                                        {
                                            System.Diagnostics.Debug.WriteLine($"Warning: Record not found after save!");
                                        }
                                    });
                                    verifyTask.Wait();
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error in TimeIn: {ex.Message}\n{ex.StackTrace}");
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
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error in TimeOut: {ex.Message}\n{ex.StackTrace}");
                                message = "Error: " + ex.Message;
                                result = false;
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

