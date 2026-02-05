using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Net;
using System.Net.Mail;
using System.Configuration;
using System.Text;
using ExWebAppSia.Models;
using ManagerModel = ExWebAppSia.Models.Manager;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();
        
        protected List<Employee> DepartmentEmployees { get; set; }
        protected List<Attendance> TodayAttendanceRecords { get; set; }
        protected List<Leave> PendingLeaveRequests { get; set; }
        protected List<EmployeeConcern> PendingConcerns { get; set; }
        protected DateTime SelectedDate { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Default to today's date
                SelectedDate = DateTime.Now.Date;
                ViewState["SelectedDate"] = SelectedDate;
                
                // Load employees and attendance data asynchronously
                RegisterAsyncTask(new PageAsyncTask(LoadEmployeesAndAttendanceAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPendingLeaveRequestsAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPendingConcernsAsync));
            }
            else
            {
                // Get selected date from viewstate or query string
                if (ViewState["SelectedDate"] != null)
                {
                    SelectedDate = (DateTime)ViewState["SelectedDate"];
                }
                else
                {
                    SelectedDate = DateTime.Now.Date;
                }
                
                // Handle date change from JavaScript
                string dateSelect = Request.Form["dateSelect"] ?? Request.QueryString["dateSelect"];
                if (!string.IsNullOrEmpty(dateSelect) && DateTime.TryParse(dateSelect, out DateTime selectedDate))
                {
                    SelectedDate = selectedDate.Date;
                    ViewState["SelectedDate"] = SelectedDate;
                }
                
                // Handle leave approval/decline
                string leaveAction = Request.Form["leaveAction"];
                string leaveId = Request.Form["leaveId"];
                if (!string.IsNullOrEmpty(leaveAction) && !string.IsNullOrEmpty(leaveId))
                {
                    var startTime = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Starting leave action: {leaveAction} for leaveId: {leaveId}");
                    
                    ViewState["LeaveActionCompleted"] = false;
                    if (leaveAction == "approve")
                    {
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Registering ApproveLeaveRequestAsync task...");
                        RegisterAsyncTask(new PageAsyncTask(async () =>
                        {
                            try
                            {
                                await ApproveLeaveRequestAsync(leaveId);
                                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveLeaveRequestAsync completed in {elapsed}ms");
                                ViewState["LeaveActionCompleted"] = true;
                                ViewState["LeaveActionMessage"] = "Leave request approved successfully. Email notification sent to admin.";
                                
                                // Redirect after async task completes
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Redirecting page after approval...");
                                Response.Redirect(Request.RawUrl.Split('?')[0], false);
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Error in ApproveLeaveRequestAsync: {ex.Message}");
                            }
                        }));
                        return; // Exit early, let async task handle redirect
                    }
                    else if (leaveAction == "decline")
                    {
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Registering DeclineLeaveRequestAsync task...");
                        RegisterAsyncTask(new PageAsyncTask(async () =>
                        {
                            try
                            {
                                await DeclineLeaveRequestAsync(leaveId);
                                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineLeaveRequestAsync completed in {elapsed}ms");
                                ViewState["LeaveActionCompleted"] = true;
                                ViewState["LeaveActionMessage"] = "Leave request removed successfully.";
                                
                                // Redirect after async task completes
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Redirecting page after decline...");
                                Response.Redirect(Request.RawUrl.Split('?')[0], false);
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Error in DeclineLeaveRequestAsync: {ex.Message}");
                            }
                        }));
                        return; // Exit early, let async task handle redirect
                    }
                }
                
                // Handle concern approval/decline
                string concernAction = Request.Form["concernAction"];
                string concernId = Request.Form["concernId"];
                if (!string.IsNullOrEmpty(concernAction) && !string.IsNullOrEmpty(concernId))
                {
                    var startTime = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Starting concern action: {concernAction} for concernId: {concernId}");
                    
                    ViewState["ConcernActionCompleted"] = false;
                    if (concernAction == "approve")
                    {
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Registering ApproveConcernAsync task...");
                        RegisterAsyncTask(new PageAsyncTask(async () =>
                        {
                            try
                            {
                                await ApproveConcernAsync(concernId);
                                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveConcernAsync completed in {elapsed}ms");
                                ViewState["ConcernActionCompleted"] = true;
                                ViewState["ConcernActionMessage"] = "Concern approved successfully. Email notification sent.";
                                
                                // Redirect after async task completes
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Redirecting page after concern approval...");
                                Response.Redirect(Request.RawUrl.Split('?')[0], false);
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Error in ApproveConcernAsync: {ex.Message}");
                            }
                        }));
                        return; // Exit early, let async task handle redirect
                    }
                    else if (concernAction == "decline")
                    {
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Registering DeclineConcernAsync task...");
                        RegisterAsyncTask(new PageAsyncTask(async () =>
                        {
                            try
                            {
                                await DeclineConcernAsync(concernId);
                                var elapsed = (DateTime.Now - startTime).TotalMilliseconds;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineConcernAsync completed in {elapsed}ms");
                                ViewState["ConcernActionCompleted"] = true;
                                ViewState["ConcernActionMessage"] = "Concern declined. Email notification sent.";
                                
                                // Redirect after async task completes
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Redirecting page after concern decline...");
                                Response.Redirect(Request.RawUrl.Split('?')[0], false);
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Error in DeclineConcernAsync: {ex.Message}");
                            }
                        }));
                        return; // Exit early, let async task handle redirect
                    }
                }
                
                RegisterAsyncTask(new PageAsyncTask(LoadEmployeesAndAttendanceAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPendingLeaveRequestsAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPendingConcernsAsync));
            }
        }

        private async Task LoadEmployeesAndAttendanceAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.Department))
                {
                    DepartmentEmployees = new List<Employee>();
                    TodayAttendanceRecords = new List<Attendance>();
                    return;
                }

                // Get all employees in the manager's department
                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);

                // Get attendance records for the selected date
                var utcDate = SelectedDate.ToUniversalTime().Date;
                var allAttendanceRecords = await _attendanceService.GetAttendanceByDateAsync(utcDate);
                
                // Filter to only include employees from this department and match local date
                var employeeIds = DepartmentEmployees.Select(e => e.EmployeeId).ToList();
                TodayAttendanceRecords = allAttendanceRecords
                    .Where(a => employeeIds.Contains(a.EmployeeId) && 
                               a.TimeIn.HasValue && 
                               a.TimeIn.Value.ToLocalTime().Date == SelectedDate)
                    .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employees and attendance: {ex.Message}");
                DepartmentEmployees = new List<Employee>();
                TodayAttendanceRecords = new List<Attendance>();
            }
        }

        protected ManagerModel CurrentManager
        {
            get
            {
                return Session["Manager"] as ManagerModel;
            }
        }

        protected string GetManagerDepartment()
        {
            var manager = CurrentManager;
            return manager?.Department ?? "N/A";
        }

        protected int GetTeamMembersCount()
        {
            return DepartmentEmployees?.Count ?? 0;
        }

        protected int GetPresentCount()
        {
            if (TodayAttendanceRecords == null || DepartmentEmployees == null)
                return 0;
            
            // Count employees who have timed in today
            var presentEmployeeIds = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.EmployeeId)
                .Distinct()
                .ToList();
            
            return presentEmployeeIds.Count;
        }

        protected int GetLateCount()
        {
            if (TodayAttendanceRecords == null)
                return 0;
            
            // Count employees who timed in after 8:00 AM
            var lateCount = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .GroupBy(a => a.EmployeeId)
                .Count(g =>
                {
                    var firstTimeIn = g.OrderBy(x => x.TimeIn).First().TimeIn.Value.ToLocalTime();
                    return firstTimeIn.Hour > 8 || (firstTimeIn.Hour == 8 && firstTimeIn.Minute > 0);
                });
            
            return lateCount;
        }

        protected int GetAbsentCount()
        {
            if (DepartmentEmployees == null || TodayAttendanceRecords == null)
                return 0;
            
            // Count employees who have NOT timed in today
            var presentEmployeeIds = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.EmployeeId)
                .Distinct()
                .ToList();
            
            var absentCount = DepartmentEmployees.Count(e => !presentEmployeeIds.Contains(e.EmployeeId));
            return absentCount;
        }

        protected string GetSelectedDateDisplay()
        {
            return SelectedDate.ToString("MMMM dd, yyyy");
        }

        protected string GetEmployeeInitials(Employee employee)
        {
            if (employee == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(employee.FirstName))
                initials += employee.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(employee.LastName))
                initials += employee.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected Attendance GetEmployeeAttendance(Employee employee)
        {
            if (TodayAttendanceRecords == null || employee == null)
                return null;
            
            // Get the most recent attendance record for this employee today
            return TodayAttendanceRecords
                .Where(a => a.EmployeeId == employee.EmployeeId)
                .OrderByDescending(a => a.TimeIn)
                .FirstOrDefault();
        }

        protected string FormatTime(DateTime? time)
        {
            if (!time.HasValue) return "—";
            return time.Value.ToLocalTime().ToString("hh:mm tt");
        }

        protected string GetAttendanceStatus(Employee employee, Attendance attendance)
        {
            if (attendance == null || !attendance.TimeIn.HasValue)
                return "Absent";

            var timeIn = attendance.TimeIn.Value.ToLocalTime();
            // Consider late if time in is after 8:00 AM
            if (timeIn.Hour > 8 || (timeIn.Hour == 8 && timeIn.Minute > 0))
                return "Late";

            return "Present";
        }

        protected string GetHoursWorked(Attendance attendance)
        {
            if (attendance == null || !attendance.TimeIn.HasValue)
                return "0h 00m";

            var timeIn = attendance.TimeIn.Value.ToLocalTime();
            var timeOut = attendance.TimeOut?.ToLocalTime();

            if (timeOut.HasValue)
            {
                var duration = timeOut.Value - timeIn;
                var hours = (int)duration.TotalHours;
                var minutes = duration.Minutes;
                return $"{hours}h {minutes:D2}m";
            }

            return "—";
        }

        protected string GetStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "present":
                    return "status-present";
                case "late":
                    return "status-late";
                case "absent":
                    return "status-absent";
                default:
                    return "status-absent";
            }
        }

        protected List<Employee> GetSortedEmployees()
        {
            if (DepartmentEmployees == null)
                return new List<Employee>();
            
            return DepartmentEmployees
                .OrderBy(e => e.LastName ?? "")
                .ThenBy(e => e.FirstName ?? "")
                .ToList();
        }

        private async Task LoadPendingLeaveRequestsAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.Department))
                {
                    PendingLeaveRequests = new List<Leave>();
                    return;
                }

                // Get all employees in the manager's department
                if (DepartmentEmployees == null)
                {
                    DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);
                }

                // Get all pending leave requests
                var allLeaves = await _leaveService.GetAllLeavesAsync();
                var employeeIds = DepartmentEmployees.Select(e => e.EmployeeId).ToList();

                // Filter to only pending leaves from employees in this department
                PendingLeaveRequests = allLeaves
                    .Where(l => l.Status == "Pending" && 
                               employeeIds.Contains(l.EmployeeId) && 
                               l.IsActive)
                    .OrderByDescending(l => l.SubmittedDate)
                    .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading pending leave requests: {ex.Message}");
                PendingLeaveRequests = new List<Leave>();
            }
        }

        private async Task ApproveLeaveRequestAsync(string leaveId)
        {
            var methodStartTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveLeaveRequestAsync START - leaveId: {leaveId}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Updating leave status in database...");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Calling _leaveService.UpdateLeaveStatusAsync with leaveId={leaveId}, status=Approved");
                
                var result = await _leaveService.UpdateLeaveStatusAsync(leaveId, "Approved").ConfigureAwait(false);
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1 completed in {stepElapsed}ms - Result: {result}");
                
                if (result)
                {
                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2: Getting all leaves from database...");
                    var allLeaves = await _leaveService.GetAllLeavesAsync();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2 completed in {stepElapsed}ms - Found {allLeaves?.Count ?? 0} leaves");
                    
                    stepStart = DateTime.Now;
                    var leave = allLeaves?.FirstOrDefault(l => l.Id == leaveId);
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 3: Finding leave record took {stepElapsed}ms - Leave found: {leave != null}");
                    
                    if (leave != null)
                    {
                        // Ensure employees are loaded
                        if (DepartmentEmployees == null)
                        {
                            stepStart = DateTime.Now;
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 4: Loading department employees...");
                            var manager = CurrentManager;
                            if (manager != null && !string.IsNullOrEmpty(manager.Department))
                            {
                                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);
                            }
                            stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 4 completed in {stepElapsed}ms - Found {DepartmentEmployees?.Count ?? 0} employees");
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 4: Skipped - DepartmentEmployees already loaded ({DepartmentEmployees.Count} employees)");
                        }
                        
                        stepStart = DateTime.Now;
                        var employee = GetEmployeeByEmployeeId(leave.EmployeeId);
                        stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 5: Finding employee took {stepElapsed}ms - Employee found: {employee != null}");
                        
                        if (employee != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 6: Starting background email task (fire and forget)...");
                            // Send email asynchronously in background (fire and forget)
                            _ = Task.Run(() =>
                            {
                                var emailStartTime = DateTime.Now;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Starting email send...");
                                try
                                {
                                    SendLeaveApprovalEmail(employee, leave);
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Email sent successfully in {emailElapsed}ms");
                                }
                                catch (Exception emailEx)
                                {
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Error after {emailElapsed}ms: {emailEx.Message}");
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [BACKGROUND EMAIL] Stack trace: {emailEx.StackTrace}");
                                }
                            });
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 6: Background email task started (non-blocking)");
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 6: Skipped - Employee not found");
                        }
                    }
                    
                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 7: Reloading pending leave requests...");
                    await LoadPendingLeaveRequestsAsync();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 7 completed in {stepElapsed}ms - Found {PendingLeaveRequests?.Count ?? 0} pending requests");
                }
                
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveLeaveRequestAsync END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveLeaveRequestAsync ERROR after {totalElapsed}ms: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] Inner exception: {ex.InnerException.Message}");
                }
            }
        }

        private async Task DeclineLeaveRequestAsync(string leaveId)
        {
            var methodStartTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineLeaveRequestAsync START - leaveId: {leaveId}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Deleting leave from database...");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Calling _leaveService.DeleteLeaveAsync with leaveId={leaveId}");
                
                var result = await _leaveService.DeleteLeaveAsync(leaveId).ConfigureAwait(false);
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1 completed in {stepElapsed}ms - Result: {result}");
                
                if (result)
                {
                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2: Reloading pending leave requests...");
                    await LoadPendingLeaveRequestsAsync();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2 completed in {stepElapsed}ms - Found {PendingLeaveRequests?.Count ?? 0} pending requests");
                }
                
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineLeaveRequestAsync END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineLeaveRequestAsync ERROR after {totalElapsed}ms: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] Inner exception: {ex.InnerException.Message}");
                }
            }
        }

        private void SendLeaveApprovalEmail(Employee employee, Leave leave)
        {
            var emailMethodStart = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveApprovalEmail START - Employee: {employee?.FullName}, LeaveId: {leave?.Id}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1: Reading SMTP configuration...");
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1 completed in {stepElapsed}ms - Server: {smtpServer}, Port: {smtpPort}");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Email will be sent TO: {hrEmail} (HR Admin)");

                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] ERROR: SMTP credentials not configured");
                    return;
                }

                stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2: Creating mail message...");
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(fromEmail, "HR Management System");
                    // Send to HR admin instead of employee
                    mail.To.Add(hrEmail);

                    mail.Subject = $"Leave Request Approved - {employee.FullName} ({leave.LeaveType})";
                    mail.IsBodyHtml = true;

                    var body = new StringBuilder();
                    body.AppendLine($"<h2 style='color: #28a745;'>Leave Request Approved</h2>");
                    body.AppendLine($"<p>Dear HR Admin,</p>");
                    body.AppendLine($"<p>A leave request has been <strong>approved</strong> for the following employee:</p>");
                    body.AppendLine($"<div style='background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
                    body.AppendLine($"<p><strong>Employee Name:</strong> {employee.FullName}</p>");
                    body.AppendLine($"<p><strong>Employee ID:</strong> {employee.EmployeeId}</p>");
                    body.AppendLine($"<p><strong>Department:</strong> {employee.Department}</p>");
                    body.AppendLine($"<p><strong>Leave Type:</strong> {leave.LeaveType}</p>");
                    body.AppendLine($"<p><strong>Start Date:</strong> {leave.StartDate.ToLocalTime():MMMM dd, yyyy}</p>");
                    body.AppendLine($"<p><strong>End Date:</strong> {leave.EndDate.ToLocalTime():MMMM dd, yyyy}</p>");
                    body.AppendLine($"<p><strong>Duration:</strong> {(leave.EndDate - leave.StartDate).Days + 1} day(s)</p>");
                    body.AppendLine($"<p><strong>Reason:</strong> {leave.Reason}</p>");
                    body.AppendLine($"</div>");
                    body.AppendLine($"<p>This leave request has been approved by the department manager and is now on record.</p>");
                    body.AppendLine($"<p>Best regards,<br/>HR Management System</p>");

                    mail.Body = body.ToString();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2 completed in {stepElapsed}ms - To: {hrEmail}");

                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3: Creating SMTP client and connecting...");
                    using (var smtpClient = new SmtpClient(smtpServer, smtpPort))
                    {
                        smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtpClient.EnableSsl = enableSsl;
                        
                        var sendStart = DateTime.Now;
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 4: Sending email via SMTP...");
                        smtpClient.Send(mail);
                        var sendElapsed = (DateTime.Now - sendStart).TotalMilliseconds;
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 4 completed in {sendElapsed}ms - Email sent successfully");
                    }
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3 completed in {stepElapsed}ms");
                }
                
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveApprovalEmail END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveApprovalEmail ERROR after {totalElapsed}ms: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [EMAIL] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [EMAIL] Inner exception: {ex.InnerException.Message}");
                }
            }
        }

        private void SendLeaveRejectionEmail(Employee employee, Leave leave)
        {
            var emailMethodStart = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveRejectionEmail START - Employee: {employee?.FullName}, LeaveId: {leave?.Id}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1: Reading SMTP configuration...");
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1 completed in {stepElapsed}ms - Server: {smtpServer}, Port: {smtpPort}");

                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] ERROR: SMTP credentials not configured");
                    return;
                }

                stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2: Creating mail message...");
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(fromEmail, "HR Management System");
                    mail.To.Add(employee.Email);
                    if (!string.IsNullOrEmpty(hrEmail))
                    {
                        mail.CC.Add(hrEmail);
                    }

                    mail.Subject = $"Leave Request Declined - {employee.FullName} ({leave.LeaveType})";
                    mail.IsBodyHtml = true;

                    var body = new StringBuilder();
                    body.AppendLine($"<h2 style='color: #dc3545;'>Leave Request Declined</h2>");
                    body.AppendLine($"<p>Dear {employee.FullName},</p>");
                    body.AppendLine($"<p>We regret to inform you that your leave request has been <strong>declined</strong> by your manager.</p>");
                    body.AppendLine($"<div style='background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
                    body.AppendLine($"<p><strong>Leave Type:</strong> {leave.LeaveType}</p>");
                    body.AppendLine($"<p><strong>Start Date:</strong> {leave.StartDate.ToLocalTime():MMMM dd, yyyy}</p>");
                    body.AppendLine($"<p><strong>End Date:</strong> {leave.EndDate.ToLocalTime():MMMM dd, yyyy}</p>");
                    body.AppendLine($"<p><strong>Reason:</strong> {leave.Reason}</p>");
                    body.AppendLine($"</div>");
                    body.AppendLine($"<p>If you have any questions, please contact your manager or HR department.</p>");
                    body.AppendLine($"<p>Best regards,<br/>HR Management System</p>");

                    mail.Body = body.ToString();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2 completed in {stepElapsed}ms - To: {employee.Email}, CC: {hrEmail}");

                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3: Creating SMTP client and connecting...");
                    using (var smtpClient = new SmtpClient(smtpServer, smtpPort))
                    {
                        smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtpClient.EnableSsl = enableSsl;
                        
                        var sendStart = DateTime.Now;
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 4: Sending email via SMTP...");
                        smtpClient.Send(mail);
                        var sendElapsed = (DateTime.Now - sendStart).TotalMilliseconds;
                        System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 4 completed in {sendElapsed}ms - Email sent successfully");
                    }
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3 completed in {stepElapsed}ms");
                }
                
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveRejectionEmail END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendLeaveRejectionEmail ERROR after {totalElapsed}ms: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [EMAIL] Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [EMAIL] Inner exception: {ex.InnerException.Message}");
                }
            }
        }

        protected Employee GetEmployeeByEmployeeId(string employeeId)
        {
            if (DepartmentEmployees == null || string.IsNullOrEmpty(employeeId))
                return null;
            
            return DepartmentEmployees.FirstOrDefault(e => e.EmployeeId == employeeId);
        }

        protected string FormatLeaveDateRange(Leave leave)
        {
            if (leave == null) return "—";
            
            var startDate = leave.StartDate.ToLocalTime();
            var endDate = leave.EndDate.ToLocalTime();
            
            if (startDate.Date == endDate.Date)
            {
                return startDate.ToString("MMM dd, yyyy");
            }
            
            return $"{startDate:MMM dd} - {endDate:MMM dd, yyyy}";
        }

        protected string GetLeaveDuration(Leave leave)
        {
            if (leave == null) return "—";
            
            var days = (leave.EndDate - leave.StartDate).Days + 1;
            if (days == 1)
                return "1 day";
            else if (days < 1)
                return "0.5 day";
            else
                return $"{days} days";
        }

        protected string GetLeaveStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "status-approved";
                case "rejected":
                    return "status-declined";
                case "pending":
                    return "status-pending";
                default:
                    return "status-pending";
            }
        }

        private async Task LoadPendingConcernsAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.Department))
                {
                    PendingConcerns = new List<EmployeeConcern>();
                    return;
                }

                // Get all employees in the manager's department
                if (DepartmentEmployees == null)
                {
                    DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);
                }

                // Get all pending concerns
                var allConcerns = await _concernService.GetAllConcernsAsync();
                var employeeIds = DepartmentEmployees.Select(e => e.EmployeeId).ToList();

                // Filter to only pending concerns from employees in this department
                PendingConcerns = allConcerns
                    .Where(c => c.Status == "Pending" && 
                               employeeIds.Contains(c.EmployeeId) && 
                               c.IsActive)
                    .OrderByDescending(c => c.SubmittedDate)
                    .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading pending concerns: {ex.Message}");
                PendingConcerns = new List<EmployeeConcern>();
            }
        }

        private async Task ApproveConcernAsync(string concernId)
        {
            var methodStartTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveConcernAsync START - concernId: {concernId}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Updating concern status in database...");
                var result = await _concernService.UpdateConcernStatusAsync(concernId, "In Progress").ConfigureAwait(false);
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1 completed in {stepElapsed}ms - Result: {result}");
                
                if (result)
                {
                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2: Getting concern details...");
                    var allConcerns = await _concernService.GetAllConcernsAsync();
                    var concern = allConcerns?.FirstOrDefault(c => c.Id == concernId);
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2 completed in {stepElapsed}ms - Concern found: {concern != null}");
                    
                    if (concern != null)
                    {
                        // Ensure employees are loaded
                        if (DepartmentEmployees == null)
                        {
                            var manager = CurrentManager;
                            if (manager != null && !string.IsNullOrEmpty(manager.Department))
                            {
                                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);
                            }
                        }
                        
                        var employee = GetEmployeeByEmployeeId(concern.EmployeeId);
                        if (employee != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 3: Starting background email task...");
                            // Send email asynchronously in background (fire and forget)
                            _ = Task.Run(() =>
                            {
                                var emailStartTime = DateTime.Now;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Starting concern approval email send...");
                                try
                                {
                                    SendConcernApprovalEmail(employee, concern);
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Email sent successfully in {emailElapsed}ms");
                                }
                                catch (Exception emailEx)
                                {
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Error after {emailElapsed}ms: {emailEx.Message}");
                                }
                            });
                        }
                    }
                    
                    // Reload concerns
                    await LoadPendingConcernsAsync();
                }
                
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveConcernAsync END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] ApproveConcernAsync ERROR after {totalElapsed}ms: {ex.Message}");
            }
        }

        private async Task DeclineConcernAsync(string concernId)
        {
            var methodStartTime = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineConcernAsync START - concernId: {concernId}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1: Updating concern status in database...");
                var result = await _concernService.UpdateConcernStatusAsync(concernId, "Closed").ConfigureAwait(false);
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 1 completed in {stepElapsed}ms - Result: {result}");
                
                if (result)
                {
                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2: Getting concern details...");
                    var allConcerns = await _concernService.GetAllConcernsAsync();
                    var concern = allConcerns?.FirstOrDefault(c => c.Id == concernId);
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 2 completed in {stepElapsed}ms - Concern found: {concern != null}");
                    
                    if (concern != null)
                    {
                        // Ensure employees are loaded
                        if (DepartmentEmployees == null)
                        {
                            var manager = CurrentManager;
                            if (manager != null && !string.IsNullOrEmpty(manager.Department))
                            {
                                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);
                            }
                        }
                        
                        var employee = GetEmployeeByEmployeeId(concern.EmployeeId);
                        if (employee != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] Step 3: Starting background email task...");
                            // Send email asynchronously in background (fire and forget)
                            _ = Task.Run(() =>
                            {
                                var emailStartTime = DateTime.Now;
                                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Starting concern decline email send...");
                                try
                                {
                                    SendConcernDeclineEmail(employee, concern);
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Email sent successfully in {emailElapsed}ms");
                                }
                                catch (Exception emailEx)
                                {
                                    var emailElapsed = (DateTime.Now - emailStartTime).TotalMilliseconds;
                                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [BACKGROUND EMAIL] Error after {emailElapsed}ms: {emailEx.Message}");
                                }
                            });
                        }
                    }
                    
                    // Reload concerns
                    await LoadPendingConcernsAsync();
                }
                
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineConcernAsync END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - methodStartTime).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] DeclineConcernAsync ERROR after {totalElapsed}ms: {ex.Message}");
            }
        }

        private void SendConcernApprovalEmail(Employee employee, EmployeeConcern concern)
        {
            var emailMethodStart = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernApprovalEmail START - Employee: {employee?.FullName}, ConcernId: {concern?.Id}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1: Reading SMTP configuration...");
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1 completed in {stepElapsed}ms");

                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] ERROR: SMTP credentials not configured");
                    return;
                }

                stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2: Creating mail message...");
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(fromEmail, "HR Management System");
                    mail.To.Add(employee.Email);
                    if (!string.IsNullOrEmpty(hrEmail))
                    {
                        mail.CC.Add(hrEmail);
                    }

                    mail.Subject = $"Concern Acknowledged - {employee.FullName} ({concern.ConcernType})";
                    mail.IsBodyHtml = true;

                    var body = new StringBuilder();
                    body.AppendLine($"<h2 style='color: #28a745;'>Concern Acknowledged</h2>");
                    body.AppendLine($"<p>Dear {employee.FullName},</p>");
                    body.AppendLine($"<p>Your concern has been <strong>acknowledged</strong> and is now being reviewed by management.</p>");
                    body.AppendLine($"<div style='background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
                    body.AppendLine($"<p><strong>Concern Type:</strong> {concern.ConcernType}</p>");
                    body.AppendLine($"<p><strong>Subject:</strong> {concern.Subject}</p>");
                    body.AppendLine($"<p><strong>Priority:</strong> {concern.PriorityLevel}</p>");
                    body.AppendLine($"<p><strong>Description:</strong> {concern.Description}</p>");
                    body.AppendLine($"<p><strong>Submitted:</strong> {concern.SubmittedDate.ToLocalTime():MMMM dd, yyyy 'at' hh:mm tt}</p>");
                    body.AppendLine($"</div>");
                    body.AppendLine($"<p>We will keep you updated on the progress of your concern. If you have any questions, please contact your manager or HR department.</p>");
                    body.AppendLine($"<p>Best regards,<br/>HR Management System</p>");

                    mail.Body = body.ToString();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2 completed in {stepElapsed}ms");

                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3: Sending email via SMTP...");
                    using (var smtpClient = new SmtpClient(smtpServer, smtpPort))
                    {
                        smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtpClient.EnableSsl = enableSsl;
                        smtpClient.Send(mail);
                    }
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3 completed in {stepElapsed}ms - Email sent successfully");
                }
                
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernApprovalEmail END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernApprovalEmail ERROR after {totalElapsed}ms: {ex.Message}");
            }
        }

        private void SendConcernDeclineEmail(Employee employee, EmployeeConcern concern)
        {
            var emailMethodStart = DateTime.Now;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernDeclineEmail START - Employee: {employee?.FullName}, ConcernId: {concern?.Id}");
            
            try
            {
                var stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1: Reading SMTP configuration...");
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
                var stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 1 completed in {stepElapsed}ms");

                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] ERROR: SMTP credentials not configured");
                    return;
                }

                stepStart = DateTime.Now;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2: Creating mail message...");
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(fromEmail, "HR Management System");
                    mail.To.Add(employee.Email);
                    if (!string.IsNullOrEmpty(hrEmail))
                    {
                        mail.CC.Add(hrEmail);
                    }

                    mail.Subject = $"Concern Update - {employee.FullName} ({concern.ConcernType})";
                    mail.IsBodyHtml = true;

                    var body = new StringBuilder();
                    body.AppendLine($"<h2 style='color: #dc3545;'>Concern Closed</h2>");
                    body.AppendLine($"<p>Dear {employee.FullName},</p>");
                    body.AppendLine($"<p>Your concern has been reviewed and <strong>closed</strong> by management.</p>");
                    body.AppendLine($"<div style='background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
                    body.AppendLine($"<p><strong>Concern Type:</strong> {concern.ConcernType}</p>");
                    body.AppendLine($"<p><strong>Subject:</strong> {concern.Subject}</p>");
                    body.AppendLine($"<p><strong>Priority:</strong> {concern.PriorityLevel}</p>");
                    body.AppendLine($"<p><strong>Description:</strong> {concern.Description}</p>");
                    body.AppendLine($"<p><strong>Submitted:</strong> {concern.SubmittedDate.ToLocalTime():MMMM dd, yyyy 'at' hh:mm tt}</p>");
                    body.AppendLine($"</div>");
                    body.AppendLine($"<p>If you have any questions or need further assistance, please contact your manager or HR department.</p>");
                    body.AppendLine($"<p>Best regards,<br/>HR Management System</p>");

                    mail.Body = body.ToString();
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 2 completed in {stepElapsed}ms");

                    stepStart = DateTime.Now;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3: Sending email via SMTP...");
                    using (var smtpClient = new SmtpClient(smtpServer, smtpPort))
                    {
                        smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtpClient.EnableSsl = enableSsl;
                        smtpClient.Send(mail);
                    }
                    stepElapsed = (DateTime.Now - stepStart).TotalMilliseconds;
                    System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] Step 3 completed in {stepElapsed}ms - Email sent successfully");
                }
                
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernDeclineEmail END - Total time: {totalElapsed}ms");
            }
            catch (Exception ex)
            {
                var totalElapsed = (DateTime.Now - emailMethodStart).TotalMilliseconds;
                System.Diagnostics.Debug.WriteLine($"[DEBUG] [{DateTime.Now:HH:mm:ss.fff}] [EMAIL] SendConcernDeclineEmail ERROR after {totalElapsed}ms: {ex.Message}");
            }
        }

        protected string FormatConcernDate(EmployeeConcern concern)
        {
            if (concern == null) return "—";
            return concern.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy");
        }

        protected string GetConcernStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "in progress":
                case "resolved":
                    return "status-approved";
                case "closed":
                    return "status-declined";
                case "pending":
                    return "status-pending";
                default:
                    return "status-pending";
            }
        }

        protected string GetPriorityClass(string priority)
        {
            switch (priority?.ToLower())
            {
                case "urgent":
                    return "status-absent"; // Red
                case "high":
                    return "status-late"; // Orange/Yellow
                case "medium":
                    return "status-present"; // Green
                case "low":
                default:
                    return ""; // Default color
            }
        }

        private async Task<string> GetEmployeeDetailsHtml(string employeeId)
        {
            try
            {
                var employee = await _employeeService.GetEmployeeByEmployeeIdAsync(employeeId);
                if (employee == null)
                {
                    return "<div style='text-align: center; padding: 20px; color: #dc3545;'><p>Employee not found.</p></div>";
                }

                // Load employee data - last 30 days
                var endDate = DateTime.UtcNow.Date;
                var startDate = endDate.AddDays(-30);
                var attendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employeeId, startDate, endDate);
                var leaveRecords = await _leaveService.GetLeavesByEmployeeIdAsync(employeeId);
                var concernRecords = await _concernService.GetConcernsByEmployeeIdAsync(employeeId);

                var html = new StringBuilder();
                
                // Employee Profile Section
                html.AppendLine("<div class='employee-details-section'>");
                html.AppendLine("<h4>👤 Personal Information</h4>");
                html.AppendLine("<div class='employee-info-grid'>");
                html.AppendLine($"<div class='employee-info-item'><label>Employee ID</label><span>{Server.HtmlEncode(employee.EmployeeId)}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Full Name</label><span>{Server.HtmlEncode(employee.FullName)}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Email</label><span>{Server.HtmlEncode(employee.Email ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Contact Number</label><span>{Server.HtmlEncode(employee.ContactNo ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Department</label><span>{Server.HtmlEncode(employee.Department ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Role</label><span>{Server.HtmlEncode(employee.Role ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Gender</label><span>{Server.HtmlEncode(employee.Gender ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Age</label><span>{(employee.Age.HasValue ? employee.Age.Value.ToString() : "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Birth Date</label><span>{(employee.BirthDate.HasValue ? employee.BirthDate.Value.ToLocalTime().ToString("MMMM dd, yyyy") : "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Hired Date</label><span>{employee.HiredDate.ToLocalTime():MMMM dd, yyyy}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Contract Type</label><span>{Server.HtmlEncode(employee.ContractType ?? "—")}</span></div>");
                html.AppendLine($"<div class='employee-info-item'><label>Address</label><span>{Server.HtmlEncode(employee.Address ?? "—")}</span></div>");
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
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{att.Date.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{(att.TimeIn.HasValue ? att.TimeIn.Value.ToLocalTime().ToString("hh:mm tt") : "—")}</td>");
                        html.AppendLine($"<td>{(att.TimeOut.HasValue ? att.TimeOut.Value.ToLocalTime().ToString("hh:mm tt") : "—")}</td>");
                        html.AppendLine($"<td>{(hours > 0 ? $"{Math.Floor(hours)}h {Math.Floor((hours % 1) * 60)}m" : "—")}</td>");
                        html.AppendLine($"<td><span class='{GetStatusClass(status)}'>{status}</span></td>");
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
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{Server.HtmlEncode(leave.LeaveType)}</td>");
                        html.AppendLine($"<td>{leave.StartDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{leave.EndDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td>{duration} day{(duration != 1 ? "s" : "")}</td>");
                        html.AppendLine($"<td><span class='leave-status {GetLeaveStatusClass(leave.Status)}'>{Server.HtmlEncode(leave.Status)}</span></td>");
                        html.AppendLine($"<td style='max-width: 200px; overflow: hidden; text-overflow: ellipsis;' title='{Server.HtmlEncode(leave.Reason)}'>{Server.HtmlEncode(leave.Reason ?? "—")}</td>");
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
                        html.AppendLine("<tr>");
                        html.AppendLine($"<td>{Server.HtmlEncode(concern.ConcernType)}</td>");
                        html.AppendLine($"<td style='max-width: 200px; overflow: hidden; text-overflow: ellipsis;' title='{Server.HtmlEncode(concern.Subject)}'>{Server.HtmlEncode(concern.Subject)}</td>");
                        html.AppendLine($"<td><span class='{GetPriorityClass(concern.PriorityLevel)}'>{Server.HtmlEncode(concern.PriorityLevel)}</span></td>");
                        html.AppendLine($"<td>{concern.SubmittedDate.ToLocalTime():MMM dd, yyyy}</td>");
                        html.AppendLine($"<td><span class='leave-status {GetConcernStatusClass(concern.Status)}'>{Server.HtmlEncode(concern.Status)}</span></td>");
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

                return html.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating employee details HTML: {ex.Message}");
                return $"<div style='text-align: center; padding: 20px; color: #dc3545;'><p>Error loading employee details: {Server.HtmlEncode(ex.Message)}</p></div>";
            }
        }
    }
}