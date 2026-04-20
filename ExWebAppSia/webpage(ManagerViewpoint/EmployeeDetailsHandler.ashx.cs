using System;
using System.Linq;
using System.Text;
using System.Web;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public class EmployeeDetailsHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var startTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine("========================================");
            System.Diagnostics.Debug.WriteLine($"[{startTime:HH:mm:ss.fff}] EmployeeDetailsHandler.ProcessRequest CALLED");
            System.Diagnostics.Debug.WriteLine($"URL: {context.Request.Url}");
            System.Diagnostics.Debug.WriteLine($"QueryString: {context.Request.QueryString}");
            System.Diagnostics.Debug.WriteLine($"Method: {context.Request.HttpMethod}");
            System.Diagnostics.Debug.WriteLine("========================================");
            
            try
            {
                context.Response.ContentType = "text/html";
                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                
                string employeeId = context.Request.QueryString["employeeId"];
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] EmployeeDetailsHandler - employeeId: {employeeId}");
                
                // Test endpoint
                if (employeeId == "test")
                {
                    System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Test endpoint called - returning success message");
                    context.Response.Write("<div style='text-align: center; padding: 20px; color: #28a745;'><p>✅ Handler is working!</p></div>");
                    return;
                }
                
                if (string.IsNullOrEmpty(employeeId))
                {
                    System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] ERROR: Employee ID is empty");
                    context.Response.Write("<div style='text-align: center; padding: 20px; color: #dc3545;'><p>Employee ID is required.</p></div>");
                    return;
                }
                
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Starting ProcessRequestAsync...");
                // Use async/await with GetAwaiter().GetResult() for synchronous handler
                ProcessRequestAsync(context).GetAwaiter().GetResult();
                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] === EmployeeDetailsHandler.ProcessRequest SUCCESS in {elapsed}ms ===");
            }
            catch (Exception ex)
            {
                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] === EmployeeDetailsHandler.ProcessRequest ERROR after {elapsed}ms ===");
                System.Diagnostics.Debug.WriteLine($"Exception Type: {ex.GetType().FullName}");
                System.Diagnostics.Debug.WriteLine($"Error Message: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner Exception Type: {ex.InnerException.GetType().FullName}");
                    System.Diagnostics.Debug.WriteLine($"Inner exception Message: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"Inner stack trace: {ex.InnerException.StackTrace}");
                }
                
                try
                {
                    context.Response.ContentType = "text/html";
                    context.Response.StatusCode = 500;
                    var errorMsg = HttpUtility.HtmlEncode(ex.Message);
                    var innerMsg = ex.InnerException != null ? $"<br/><strong>Inner Error:</strong> {HttpUtility.HtmlEncode(ex.InnerException.Message)}" : "";
                    var exceptionType = HttpUtility.HtmlEncode(ex.GetType().FullName);
                    var stackTrace = HttpUtility.HtmlEncode(ex.StackTrace ?? "");
                    context.Response.Write($@"
                        <div style='text-align: center; padding: 20px; color: #dc3545;'>
                            <p><strong>Error loading employee details</strong></p>
                            <p style='font-size: 12px; margin-top: 10px;'><strong>Error:</strong> {errorMsg}{innerMsg}</p>
                            <p style='font-size: 11px; color: #999; margin-top: 5px;'><strong>Type:</strong> {exceptionType}</p>
                            <details style='margin-top: 10px; text-align: left;'>
                                <summary style='cursor: pointer; color: #666;'>Show Stack Trace</summary>
                                <pre style='font-size: 10px; overflow: auto; background: #f5f5f5; padding: 10px; border-radius: 4px;'>{stackTrace}</pre>
                            </details>
                            <p style='font-size: 11px; color: #999; margin-top: 10px;'>Check Visual Studio Output window for detailed debug information.</p>
                        </div>");
                }
                catch (Exception responseEx)
                {
                    System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Error writing error response: {responseEx.Message}");
                    System.Diagnostics.Debug.WriteLine($"Response error stack trace: {responseEx.StackTrace}");
                }
            }
        }

        private async Task ProcessRequestAsync(HttpContext context)
        {
            var asyncStartTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[{asyncStartTime:HH:mm:ss.fff}] === EmployeeDetailsHandler.ProcessRequestAsync START ===");
            try
            {
                string employeeId = context.Request.QueryString["employeeId"];
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] ProcessRequestAsync - employeeId: {employeeId}");
                if (string.IsNullOrEmpty(employeeId))
                {
                    System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] ERROR: Employee ID is empty in ProcessRequestAsync");
                    context.Response.ContentType = "text/html";
                    context.Response.Write("<div style='text-align: center; padding: 20px; color: #dc3545;'><p>Employee ID is required.</p></div>");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Creating service instances...");
                var employeeService = new EmployeeService();
                var attendanceService = new AttendanceService();
                var leaveService = new LeaveService();
                var concernService = new EmployeeConcernService();
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Service instances created");

                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Calling GetEmployeeByEmployeeIdAsync with employeeId: {employeeId}...");
                var employeeTask = employeeService.GetEmployeeByEmployeeIdAsync(employeeId);
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Task created, awaiting with ConfigureAwait(false)...");
                var employee = await employeeTask.ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] GetEmployeeByEmployeeIdAsync completed - Employee found: {employee != null}");
                if (employee == null)
                {
                    System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] ERROR: Employee not found for ID: {employeeId}");
                    context.Response.ContentType = "text/html";
                    context.Response.Write("<div style='text-align: center; padding: 20px; color: #dc3545;'><p>Employee not found.</p></div>");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Employee found: {employee.FullName} ({employee.EmployeeId})");

                // Load employee data - last 30 days
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Loading attendance records...");
                var endDate = DateTime.UtcNow.Date;
                var startDate = endDate.AddDays(-30);
                var attendanceRecords = await attendanceService.GetEmployeeAttendanceAsync(employeeId, startDate, endDate).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Attendance records loaded: {attendanceRecords?.Count ?? 0} records");
                
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Loading leave records...");
                var leaveRecords = await leaveService.GetLeavesByEmployeeIdAsync(employeeId).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Leave records loaded: {leaveRecords?.Count ?? 0} records");
                
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Loading concern records...");
                var concernRecords = await concernService.GetConcernsByEmployeeIdAsync(employeeId).ConfigureAwait(false);
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Concern records loaded: {concernRecords?.Count ?? 0} records");

                var html = new StringBuilder();

                // Employee Profile Section
                html.AppendLine("<div class='employee-details-section'>");
                html.AppendLine("<h4>👤 Personal Information</h4>");
                html.AppendLine("<div class='employee-info-grid'>");
                html.AppendLine($"<div class='employee-info-item'><label>Employee ID</label><span>{HttpUtility.HtmlEncode(employee.EmployeeId)}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Full Name</label><span>{HttpUtility.HtmlEncode(employee.FullName)}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Email</label><span>{HttpUtility.HtmlEncode(employee.Email ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Contact Number</label><span>{HttpUtility.HtmlEncode(employee.ContactNo ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Department</label><span>{HttpUtility.HtmlEncode(employee.Department ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Role</label><span>{HttpUtility.HtmlEncode(employee.Role ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Gender</label><span>{HttpUtility.HtmlEncode(employee.Gender ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Age</label><span>{(employee.Age.HasValue ? employee.Age.Value.ToString() : "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Birth Date</label><span>{(employee.BirthDate.HasValue ? employee.BirthDate.Value.ToLocalTime().ToString("MMMM dd, yyyy") : "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Hired Date</label><span>{employee.HiredDate.ToLocalTime():MMMM dd, yyyy}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Availability Status</label><span><span class='leave-status {(employee.AvailabilityStatus == "On Leave" ? "status-declined" : "status-approved")}'>{HttpUtility.HtmlEncode(employee.AvailabilityStatus ?? "Available")}</span></span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Contract Type</label><span>{HttpUtility.HtmlEncode(employee.ContractType ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Address</label><span>{HttpUtility.HtmlEncode(employee.Address ?? "—")}</span></div>");
                html.AppendLine("</div>");
                html.AppendLine("</div>");

                // Attendance History Section
                html.AppendLine("<div class='employee-details-section'>");
                html.AppendLine("<h4>📅 Attendance History (Last 30 Days)</h4>");
                if (attendanceRecords != null && attendanceRecords.Count > 0)
                {
                    html.AppendLine("<table class='employee-details-table'>");
                    html.AppendLine("<thead><tr><th>Date</th><th>Time In</th><th>Time Out</th><th>Hours Worked</th><th>Status</th></tr></thead>");
                    html.AppendLine("<tbody>");
                    foreach (var att in attendanceRecords.OrderByDescending(a => a.Date).Take(30))
                    {
                        var hours = att.TimeOut.HasValue && att.TimeIn.HasValue
                            ? (att.TimeOut.Value - att.TimeIn.Value).TotalHours
                            : 0;
                        var status = att.TimeIn.HasValue ? (att.TimeOut.HasValue ? "Completed" : "In Progress") : "Absent";
                        var statusClass = status == "Completed" ? "status-present" : (status == "In Progress" ? "status-late" : "status-absent");
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{att.Date.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{(att.TimeIn.HasValue ? att.TimeIn.Value.ToLocalTime().ToString("hh:mm tt") : "—")}</td>");
                        html.AppendLine($"<td>{(att.TimeOut.HasValue ? att.TimeOut.Value.ToLocalTime().ToString("hh:mm tt") : "—")}</td>");
                        html.AppendLine($"<td>{(hours > 0 ? $"{Math.Floor(hours)}h {Math.Floor((hours % 1) * 60)}m" : "—")}</td>");
                        html.AppendLine($"<td><span class='{statusClass}'>{status}</span></td>");
                        html.AppendLine("</tr>");
                    }
                    html.AppendLine("</tbody>");
                    html.AppendLine("</table>");
                }
                else
                {
                    html.AppendLine("<p style='color: #999; text-align: center; padding: 20px;'>No attendance records found.</p>");
                }
                html.AppendLine("</div>");

                // Leave History Section
                html.AppendLine("<div class='employee-details-section'>");
                html.AppendLine("<h4>🏖️ Leave History</h4>");
                if (leaveRecords != null && leaveRecords.Count > 0)
                {
                    html.AppendLine("<table class='employee-details-table'>");
                    html.AppendLine("<thead><tr><th>Leave Type</th><th>Start Date</th><th>End Date</th><th>Duration</th><th>Status</th><th>Reason</th></tr></thead>");
                    html.AppendLine("<tbody>");
                    foreach (var leave in leaveRecords.OrderByDescending(l => l.SubmittedDate).Take(20))
                    {
                        var duration = leave.EndDate.Subtract(leave.StartDate).Days + 1;
                        var statusClass = leave.Status?.ToLower() == "approved" ? "status-approved" : 
                                         (leave.Status?.ToLower() == "rejected" ? "status-declined" : "status-pending");
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{HttpUtility.HtmlEncode(leave.LeaveType)}</td>");
                        html.AppendLine($"<td>{leave.StartDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{leave.EndDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{duration} day{(duration != 1 ? "s" : "")}</td>");
                        html.AppendLine($"<td><span class='leave-status {statusClass}'>{HttpUtility.HtmlEncode(leave.Status)}</span></td>");
                        html.AppendLine($"<td style='max-width: 200px; overflow: hidden; text-overflow: ellipsis;' title='{HttpUtility.HtmlEncode(leave.Reason)}'>{HttpUtility.HtmlEncode(leave.Reason ?? "—")}</td>");
                        html.AppendLine("</tr>");
                    }
                    html.AppendLine("</tbody>");
                    html.AppendLine("</table>");
                }
                else
                {
                    html.AppendLine("<p style='color: #999; text-align: center; padding: 20px;'>No leave records found.</p>");
                }
                html.AppendLine("</div>");

                // Concerns History Section
                html.AppendLine("<div class='employee-details-section'>");
                html.AppendLine("<h4>📋 Concerns History</h4>");
                if (concernRecords != null && concernRecords.Count > 0)
                {
                    html.AppendLine("<table class='employee-details-table'>");
                    html.AppendLine("<thead><tr><th>Concern Type</th><th>Subject</th><th>Priority</th><th>Submitted</th><th>Status</th></tr></thead>");
                    html.AppendLine("<tbody>");
                    foreach (var concern in concernRecords.OrderByDescending(c => c.SubmittedDate).Take(20))
                    {
                        var priorityClass = concern.PriorityLevel?.ToLower() == "urgent" ? "status-absent" :
                                          (concern.PriorityLevel?.ToLower() == "high" ? "status-late" :
                                          (concern.PriorityLevel?.ToLower() == "medium" ? "status-present" : ""));
                        var concernStatusClass = concern.Status?.ToLower() == "in progress" || concern.Status?.ToLower() == "resolved" ? "status-approved" :
                                                (concern.Status?.ToLower() == "closed" ? "status-declined" : "status-pending");
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{HttpUtility.HtmlEncode(concern.ConcernType)}</td>");
                        html.AppendLine($"<td style='max-width: 200px; overflow: hidden; text-overflow: ellipsis;' title='{HttpUtility.HtmlEncode(concern.Subject)}'>{HttpUtility.HtmlEncode(concern.Subject)}</td>");
                        html.AppendLine($"<td><span class='{priorityClass}'>{HttpUtility.HtmlEncode(concern.PriorityLevel)}</span></td>");
                        html.AppendLine($"<td>{concern.SubmittedDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td><span class='leave-status {concernStatusClass}'>{HttpUtility.HtmlEncode(concern.Status)}</span></td>");
                        html.AppendLine("</tr>");
                    }
                    html.AppendLine("</tbody>");
                    html.AppendLine("</table>");
                }
                else
                {
                    html.AppendLine("<p style='color: #999; text-align: center; padding: 20px;'>No concern records found.</p>");
                }
                html.AppendLine("</div>");

                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] Building HTML response...");
                context.Response.ContentType = "text/html";
                context.Response.Write(html.ToString());
                var asyncElapsed = (DateTime.Now - asyncStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] === EmployeeDetailsHandler.ProcessRequestAsync SUCCESS in {asyncElapsed}ms ===");
            }
            catch (Exception ex)
            {
                var asyncElapsed = (DateTime.Now - asyncStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[{DateTime.Now:HH:mm:ss.fff}] === EmployeeDetailsHandler.ProcessRequestAsync ERROR after {asyncElapsed}ms ===");
                System.Diagnostics.Debug.WriteLine($"Exception Type: {ex.GetType().FullName}");
                System.Diagnostics.Debug.WriteLine($"Error in EmployeeDetailsHandler.ProcessRequestAsync: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner Exception Type: {ex.InnerException.GetType().FullName}");
                    System.Diagnostics.Debug.WriteLine($"Inner exception Message: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"Inner stack trace: {ex.InnerException.StackTrace}");
                }
                context.Response.ContentType = "text/html";
                context.Response.StatusCode = 500;
                var errorMsg = HttpUtility.HtmlEncode(ex.Message);
                var innerMsg = ex.InnerException != null ? $"<br/><strong>Inner Error:</strong> {HttpUtility.HtmlEncode(ex.InnerException.Message)}" : "";
                var exceptionType = HttpUtility.HtmlEncode(ex.GetType().FullName);
                context.Response.Write($@"
                    <div style='text-align: center; padding: 20px; color: #dc3545;'>
                        <p><strong>Error loading employee details</strong></p>
                        <p style='font-size: 12px; margin-top: 10px;'><strong>Error:</strong> {errorMsg}{innerMsg}</p>
                        <p style='font-size: 11px; color: #999; margin-top: 5px;'><strong>Type:</strong> {exceptionType}</p>
                        <p style='font-size: 11px; color: #999; margin-top: 10px;'>Check Visual Studio Output window for detailed debug information.</p>
                    </div>");
                throw; // Re-throw to be caught by outer catch
            }
        }

        public bool IsReusable => false;
    }
}

