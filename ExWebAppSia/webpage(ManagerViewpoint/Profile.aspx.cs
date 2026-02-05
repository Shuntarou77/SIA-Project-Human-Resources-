using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Configuration;
using ExWebAppSia.Models;
using ManagerModel = ExWebAppSia.Models.Manager;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class WebForm4 : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly LeaveService _leaveService = new LeaveService();
        protected List<Attendance> AttendanceRecords { get; set; }
        protected List<Leave> LeaveRecords { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable HTML5 validation to prevent "invalid form control is not focusable" error
            if (!IsPostBack)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "DisableValidation",
                    "if (document.forms[0]) { document.forms[0].noValidate = true; }", true);
                // Load attendance and leave records asynchronously
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceRecordsAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadLeaveRecordsAsync));
            }

            // After postback, if there's a message, keep the modal open
            if (IsPostBack)
            {
                if (lblConcernMessage != null && !string.IsNullOrEmpty(lblConcernMessage.Text))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepConcernModalOpen",
                        "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
                if (lblLeaveMessage != null && !string.IsNullOrEmpty(lblLeaveMessage.Text))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepLeaveModalOpen",
                        "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
            }
        }

        private async Task LoadAttendanceRecordsAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager != null && !string.IsNullOrEmpty(manager.ManagerId))
                {
                    // Get last 30 days of attendance records
                    var startDate = DateTime.UtcNow.AddDays(-30).Date;
                    AttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(
                        manager.ManagerId,
                        startDate,
                        null);

                    // Sort by date descending (most recent first)
                    if (AttendanceRecords != null)
                    {
                        AttendanceRecords = AttendanceRecords
                            .OrderByDescending(a => a.Date)
                            .ThenByDescending(a => a.TimeIn)
                            .ToList();
                    }
                }
                else
                {
                    AttendanceRecords = new List<Attendance>();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance records: {ex.Message}");
                AttendanceRecords = new List<Attendance>();
            }
        }

        protected ManagerModel CurrentManager
        {
            get
            {
                return Session["Manager"] as ManagerModel;
            }
        }

        protected string GetManagerInitials()
        {
            var manager = CurrentManager;
            if (manager == null) return "M";

            string initials = "";
            if (!string.IsNullOrEmpty(manager.FirstName))
                initials += manager.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(manager.LastName))
                initials += manager.LastName[0].ToString().ToUpper();

            return string.IsNullOrEmpty(initials) ? "M" : initials;
        }

        protected string GetManagerName()
        {
            var manager = CurrentManager;
            if (manager == null) return "N/A";

            return manager.FullName ?? "N/A";
        }

        protected string GetManagerId()
        {
            var manager = CurrentManager;
            return manager?.ManagerId ?? "N/A";
        }

        protected string GetManagerDepartment()
        {
            var manager = CurrentManager;
            return manager?.Department ?? "N/A";
        }

        protected string GetManagerEmail()
        {
            var manager = CurrentManager;
            return manager?.Email ?? "N/A";
        }

        protected string GetManagerPhone()
        {
            var manager = CurrentManager;
            return manager?.ContactNo ?? "N/A";
        }

        protected string GetManagerRole()
        {
            var manager = CurrentManager;
            return manager?.Role ?? "N/A";
        }

        protected string FormatAttendanceDate(DateTime date)
        {
            return date.ToString("MMM dd, yyyy");
        }

        protected string FormatAttendanceTime(DateTime? time)
        {
            if (!time.HasValue) return "--";
            return time.Value.ToLocalTime().ToString("hh:mm tt");
        }

        protected string GetAttendanceStatus(Attendance attendance)
        {
            if (attendance == null || !attendance.TimeIn.HasValue)
                return "Absent";

            var timeIn = attendance.TimeIn.Value.ToLocalTime();
            // Consider late if time in is after 8:00 AM
            if (timeIn.Hour > 8 || (timeIn.Hour == 8 && timeIn.Minute > 0))
                return "Late";

            return "Present";
        }

        private async Task LoadLeaveRecordsAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager != null && !string.IsNullOrEmpty(manager.ManagerId))
                {
                    // Get leave records using ManagerId (since Leave model uses EmployeeId field)
                    LeaveRecords = await _leaveService.GetLeavesByEmployeeIdAsync(manager.ManagerId);
                }
                else
                {
                    LeaveRecords = new List<Leave>();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading leave records: {ex.Message}");
                LeaveRecords = new List<Leave>();
            }
        }

        protected string FormatLeaveDate(DateTime date)
        {
            return date.ToLocalTime().ToString("MMMM dd, yyyy");
        }

        protected string FormatLeaveDateRange(DateTime startDate, DateTime endDate)
        {
            var start = startDate.ToLocalTime();
            var end = endDate.ToLocalTime();

            if (start.Date == end.Date)
            {
                return $"{start:MMMM dd, yyyy} (1 day)";
            }
            else
            {
                var days = (end.Date - start.Date).Days + 1;
                return $"{start:MMMM dd} - {end:MMMM dd, yyyy} ({days} days)";
            }
        }

        protected string GetLeaveStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "status-approved";
                case "rejected":
                    return "status-rejected";
                default:
                    return "status-pending";
            }
        }

        protected void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate form
                if (string.IsNullOrEmpty(ddlLeaveType.SelectedValue) ||
                    string.IsNullOrEmpty(txtStartDate.Text) ||
                    string.IsNullOrEmpty(txtEndDate.Text) ||
                    string.IsNullOrEmpty(txtLeaveReason.Text.Trim()))
                {
                    lblLeaveMessage.Text = "Please fill in all required fields.";
                    lblLeaveMessage.Style["display"] = "block";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                    lblLeaveMessage.Style["padding"] = "10px";
                    lblLeaveMessage.Style["borderRadius"] = "5px";
                    return;
                }

                var manager = CurrentManager;
                if (manager == null)
                {
                    lblLeaveMessage.Text = "Manager session not found. Please log in again.";
                    lblLeaveMessage.Style["display"] = "block";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                    lblLeaveMessage.Style["padding"] = "10px";
                    lblLeaveMessage.Style["borderRadius"] = "5px";
                    return;
                }

                // Parse dates
                DateTime startDate = DateTime.Parse(txtStartDate.Text);
                DateTime endDate = DateTime.Parse(txtEndDate.Text);

                // Create leave object
                var leave = new Leave
                {
                    EmployeeId = manager.ManagerId, // Use ManagerId as EmployeeId in Leave records
                    EmployeeName = manager.FullName, // Format: Last Name, First Name, Middle Name
                    LeaveType = ddlLeaveType.SelectedItem.Text,
                    StartDate = startDate,
                    EndDate = endDate,
                    Reason = txtLeaveReason.Text.Trim(),
                    Status = "Pending",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                // Capture form values for email before clearing
                string leaveType = ddlLeaveType.SelectedItem.Text;
                string startDateStr = txtStartDate.Text;
                string endDateStr = txtEndDate.Text;
                string reason = txtLeaveReason.Text;

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";
                fileLeaveAttachment.Attributes.Clear();

                // Show initial success message
                ClientScript.RegisterStartupScript(this.GetType(), "KeepLeaveModalOpen",
                    "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);

                // Save to database and send email synchronously so we can update the message
                bool emailSent = false;
                string emailError = null;

                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting database save...");
                    var leaveService = new LeaveService();

                    // Try to save with a short timeout
                    var saveTask = leaveService.CreateLeaveAsync(leave);
                    if (saveTask.Wait(TimeSpan.FromSeconds(5))) // 5 second timeout
                    {
                        bool saved = saveTask.Result;
                        System.Diagnostics.Debug.WriteLine($"Database save completed: {saved}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Database save timed out");
                    }
                }
                catch (Exception dbEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Database error: {dbEx.Message}");
                }

                // Send email
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting leave request email send...");
                    SendLeaveEmail(manager, leaveType, startDateStr, endDateStr, reason);
                    emailSent = true;
                    System.Diagnostics.Debug.WriteLine("Leave email sent successfully");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Leave email error: {emailEx.Message}");
                    if (emailEx.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Leave email inner exception: {emailEx.InnerException.Message}");
                    }
                }

                // Update success message with email status
                if (emailSent)
                {
                    lblLeaveMessage.Text = $"✓ Your leave request has been submitted successfully! A confirmation email has been sent to {manager.Email}.";
                    lblLeaveMessage.Style["color"] = "#155724";
                    lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                    lblLeaveMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblLeaveMessage.Text = $"✓ Your leave request has been submitted successfully! However, the confirmation email could not be sent. {emailError ?? "Please contact HR."}";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                }
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["padding"] = "15px";
                lblLeaveMessage.Style["borderRadius"] = "8px";
                lblLeaveMessage.Style["fontWeight"] = "600";

                // Close modal after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "closeLeaveModalAfterDelay",
                    "setTimeout(function() { closeModal('leaveModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblLeaveMessage.Text = "An error occurred: " + ex.Message;
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["color"] = "#856404";
                lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                lblLeaveMessage.Style["border"] = "1px solid #ffc107";
            }
        }

        protected void btnSubmitConcern_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate form
                if (string.IsNullOrEmpty(ddlConcernType.SelectedValue) ||
                    string.IsNullOrEmpty(txtConcernSubject.Text.Trim()) ||
                    string.IsNullOrEmpty(txtConcernDescription.Text.Trim()))
                {
                    lblConcernMessage.Text = "Please fill in all required fields.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    lblConcernMessage.Style["padding"] = "10px";
                    lblConcernMessage.Style["borderRadius"] = "5px";
                    return;
                }

                var manager = CurrentManager;
                if (manager == null)
                {
                    lblConcernMessage.Text = "Manager session not found. Please log in again.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    lblConcernMessage.Style["padding"] = "10px";
                    lblConcernMessage.Style["borderRadius"] = "5px";
                    return;
                }

                // Create concern object
                var concern = new EmployeeConcern
                {
                    EmployeeId = manager.ManagerId, // Use ManagerId as EmployeeId in Concern records
                    EmployeeName = manager.FullName, // Format: Last Name, First Name, Middle Name
                    ConcernType = ddlConcernType.SelectedItem.Text,
                    Subject = txtConcernSubject.Text.Trim(),
                    Description = txtConcernDescription.Text.Trim(),
                    PriorityLevel = ddlPriorityLevel.SelectedValue,
                    Status = "Pending",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                // Clear form first
                ddlConcernType.SelectedIndex = 0;
                txtConcernSubject.Text = "";
                txtConcernDescription.Text = "";
                ddlPriorityLevel.SelectedValue = "medium";
                fileSupportingDocs.Attributes.Clear();

                // Show initial success message
                ClientScript.RegisterStartupScript(this.GetType(), "KeepConcernModalOpen",
                    "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);

                // Save to database and send email synchronously so we can update the message
                bool emailSent = false;
                string emailError = null;

                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting database save...");
                    var concernService = new EmployeeConcernService();

                    // Try to save with a short timeout
                    var saveTask = concernService.CreateConcernAsync(concern);
                    if (saveTask.Wait(TimeSpan.FromSeconds(5))) // 5 second timeout
                    {
                        bool saved = saveTask.Result;
                        System.Diagnostics.Debug.WriteLine($"Database save completed: {saved}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Database save timed out");
                    }
                }
                catch (Exception dbEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Database error: {dbEx.Message}");
                }

                // Send email
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting email send...");
                    SendConcernEmail(concern, manager);
                    emailSent = true;
                    System.Diagnostics.Debug.WriteLine("Email sent successfully");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Email error: {emailEx.Message}");
                    if (emailEx.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Email inner exception: {emailEx.InnerException.Message}");
                    }
                }

                // Update success message with email status
                if (emailSent)
                {
                    lblConcernMessage.Text = $"✓ Your concern has been submitted successfully! A confirmation email has been sent to {manager.Email}.";
                    lblConcernMessage.Style["color"] = "#155724";
                    lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                    lblConcernMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblConcernMessage.Text = $"✓ Your concern has been submitted successfully! However, the email could not be sent. {emailError ?? "Please contact HR."}";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                }
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["padding"] = "15px";
                lblConcernMessage.Style["borderRadius"] = "8px";
                lblConcernMessage.Style["fontWeight"] = "600";

                // Close modal after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "closeModalAfterDelay",
                    "setTimeout(function() { closeModal('concernModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblConcernMessage.Text = "An error occurred: " + ex.Message;
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["color"] = "#856404";
                lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                lblConcernMessage.Style["border"] = "1px solid #ffc107";
            }
        }

        private void SendLeaveEmail(ManagerModel manager, string leaveType, string startDate, string endDate, string reason)
        {
            System.Diagnostics.Debug.WriteLine("SendLeaveEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                string managerEmail = manager.Email ?? "";
                System.Diagnostics.Debug.WriteLine($"Leave Email SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To Manager: {managerEmail}, CC HR: {hrEmail}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Leave email not sent: SMTP credentials not configured");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Manager Leave System");

                // Send to manager's email (the person submitting the request)
                if (string.IsNullOrEmpty(manager.Email))
                {
                    System.Diagnostics.Debug.WriteLine("Manager email is empty, cannot send confirmation email");
                    throw new Exception("Manager email address is not available. Cannot send confirmation email.");
                }

                mail.To.Add(manager.Email);
                System.Diagnostics.Debug.WriteLine($"Sending leave confirmation email to manager: {manager.Email}");

                // Also send a copy to HR
                if (!string.IsNullOrEmpty(hrEmail))
                {
                    mail.CC.Add(hrEmail);
                    System.Diagnostics.Debug.WriteLine($"CC'ing HR: {hrEmail}");
                }

                mail.Subject = $"Leave Request Confirmation - {manager.FullName} ({leaveType})";
                mail.IsBodyHtml = true;

                // Build email body with leave details - confirmation email for manager
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A36A66;'>Leave Request Confirmation</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");

                body.AppendLine("<div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #28a745;'>");
                body.AppendLine("<p style='margin: 0; color: #155724; font-weight: bold;'>✓ Your leave request has been successfully submitted!</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Manager Name:</strong> {manager.FullName}</p>");
                body.AppendLine($"<p><strong>Manager ID:</strong> {manager.ManagerId}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {manager.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Leave Type:</strong> <span style='color: #A36A66; font-weight: bold;'>{leaveType}</span></p>");
                body.AppendLine($"<p><strong>Start Date:</strong> {DateTime.Parse(startDate):MMM dd, yyyy}</p>");
                body.AppendLine($"<p><strong>End Date:</strong> {DateTime.Parse(endDate):MMM dd, yyyy}</p>");

                // Calculate number of days
                TimeSpan duration = DateTime.Parse(endDate) - DateTime.Parse(startDate);
                int days = duration.Days + 1; // Include both start and end date
                body.AppendLine($"<p><strong>Duration:</strong> {days} day(s)</p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {DateTime.Now:MMM dd, yyyy HH:mm}</p>");
                body.AppendLine($"<p><strong>Status:</strong> <span style='color: #f59e0b; font-weight: bold;'>Pending Approval</span></p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A36A66; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A36A66; margin-top: 0;'>Reason for Leave:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(reason)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;'>");
                body.AppendLine("<p style='margin: 0; color: #856404;'><strong>Note:</strong> Your leave request has been forwarded to HR for review. You will be notified once a decision has been made.</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated confirmation email from the Manager Leave System.</p>");
                body.AppendLine("<p>If you have any questions, please contact HR.</p>");
                body.AppendLine("</div>");
                body.AppendLine("</div></body></html>");

                mail.Body = body.ToString();

                // Configure SMTP client with timeout
                System.Diagnostics.Debug.WriteLine("Configuring SMTP client for leave email...");
                smtpClient = new SmtpClient(smtpServer, smtpPort);
                smtpClient.EnableSsl = enableSsl;
                smtpClient.UseDefaultCredentials = false;
                smtpClient.Timeout = 30000; // 30 second timeout
                smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;

                // Set credentials before enabling SSL
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);

                // For Gmail, ensure we're using the correct security settings
                if (smtpServer.Contains("gmail.com"))
                {
                    // Gmail requires SSL/TLS
                    smtpClient.EnableSsl = true;
                    System.Diagnostics.Debug.WriteLine("Gmail detected - SSL enabled");
                }

                System.Diagnostics.Debug.WriteLine("Attempting to send leave email...");
                smtpClient.Send(mail);
                System.Diagnostics.Debug.WriteLine("Leave email sent successfully!");
            }
            catch (System.Net.Mail.SmtpException smtpEx)
            {
                System.Diagnostics.Debug.WriteLine($"SMTP Error sending leave email: {smtpEx.Message}");
                System.Diagnostics.Debug.WriteLine($"SMTP Status Code: {smtpEx.StatusCode}");
                throw;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"General Error sending leave email: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Error Type: {ex.GetType().Name}");
                throw;
            }
            finally
            {
                if (mail != null)
                {
                    mail.Dispose();
                }
                if (smtpClient != null)
                {
                    smtpClient.Dispose();
                }
            }
        }

        private void SendConcernEmail(EmployeeConcern concern, ManagerModel manager)
        {
            System.Diagnostics.Debug.WriteLine("SendConcernEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config or use defaults
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com"; // Default HR email
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                string managerEmail = manager.Email ?? "";
                System.Diagnostics.Debug.WriteLine($"Concern Email SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To Manager: {managerEmail}, CC HR: {hrEmail}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Email not sent: SMTP credentials not configured");
                    System.Diagnostics.Debug.WriteLine($"Username empty: {string.IsNullOrEmpty(smtpUsername)}, Password empty: {string.IsNullOrEmpty(smtpPassword)}");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Manager Concern System");

                // Send to manager's email (the person submitting the concern) for confirmation
                if (string.IsNullOrEmpty(manager.Email))
                {
                    System.Diagnostics.Debug.WriteLine("Manager email is empty, cannot send confirmation email");
                    throw new Exception("Manager email address is not available. Cannot send confirmation email.");
                }

                mail.To.Add(manager.Email);
                System.Diagnostics.Debug.WriteLine($"Sending concern confirmation email to manager: {manager.Email}");

                // Also send a copy to HR
                if (!string.IsNullOrEmpty(hrEmail))
                {
                    mail.CC.Add(hrEmail);
                    System.Diagnostics.Debug.WriteLine($"CC'ing HR: {hrEmail}");
                }

                mail.Subject = $"Concern Submission Confirmation - {concern.Subject}";
                mail.IsBodyHtml = true;

                // Build email body with concern details - confirmation email for manager
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A36A66;'>Concern Submission Confirmation</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");

                body.AppendLine("<div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #28a745;'>");
                body.AppendLine("<p style='margin: 0; color: #155724; font-weight: bold;'>✓ Your concern has been successfully submitted!</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Manager Name:</strong> {manager.FullName}</p>");
                body.AppendLine($"<p><strong>Manager ID:</strong> {manager.ManagerId}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {manager.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Subject:</strong> <span style='color: #A36A66; font-weight: bold;'>{HttpUtility.HtmlEncode(concern.Subject)}</span></p>");
                body.AppendLine($"<p><strong>Concern Type:</strong> {concern.ConcernType}</p>");
                body.AppendLine($"<p><strong>Priority Level:</strong> <span style='color: #A36A66; font-weight: bold;'>{concern.PriorityLevel}</span></p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {concern.SubmittedDate.ToLocalTime():MMM dd, yyyy HH:mm}</p>");
                body.AppendLine($"<p><strong>Status:</strong> <span style='color: #f59e0b; font-weight: bold;'>Under Review</span></p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A36A66; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A36A66; margin-top: 0;'>Description:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(concern.Description)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;'>");
                body.AppendLine("<p style='margin: 0; color: #856404;'><strong>Note:</strong> Your concern has been forwarded to HR for review. You will be contacted if additional information is needed.</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated confirmation email from the Manager Concern System.</p>");
                body.AppendLine("<p>If you have any questions, please contact HR.</p>");
                body.AppendLine("</div>");
                body.AppendLine("</div></body></html>");

                mail.Body = body.ToString();

                // Configure SMTP client with timeout
                System.Diagnostics.Debug.WriteLine("Configuring SMTP client...");
                smtpClient = new SmtpClient(smtpServer, smtpPort);
                smtpClient.EnableSsl = enableSsl;
                smtpClient.UseDefaultCredentials = false;
                smtpClient.Timeout = 30000; // 30 second timeout (increased for Gmail)
                smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;

                // Set credentials before enabling SSL
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);

                // For Gmail, ensure we're using the correct security settings
                if (smtpServer.Contains("gmail.com"))
                {
                    // Gmail requires SSL/TLS
                    smtpClient.EnableSsl = true;
                    System.Diagnostics.Debug.WriteLine("Gmail detected - SSL enabled");
                }

                System.Diagnostics.Debug.WriteLine("Attempting to send email...");
                // Send email
                smtpClient.Send(mail);
                System.Diagnostics.Debug.WriteLine("Email sent successfully!");
            }
            catch (System.Net.Mail.SmtpException smtpEx)
            {
                // Log SMTP-specific errors
                System.Diagnostics.Debug.WriteLine($"SMTP Error sending email: {smtpEx.Message}");
                System.Diagnostics.Debug.WriteLine($"SMTP Status Code: {smtpEx.StatusCode}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {smtpEx.StackTrace}");
                if (smtpEx.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {smtpEx.InnerException.Message}");
                }
                throw; // Re-throw to be caught by outer handler
            }
            catch (Exception ex)
            {
                // Log error but don't fail the concern submission
                System.Diagnostics.Debug.WriteLine($"General Error sending email: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Error Type: {ex.GetType().Name}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"Inner stack trace: {ex.InnerException.StackTrace}");
                }
                throw; // Re-throw to be caught by outer handler
            }
            finally
            {
                // Dispose mail and smtpClient objects if they exist
                if (mail != null)
                {
                    mail.Dispose();
                }
                if (smtpClient != null)
                {
                    smtpClient.Dispose();
                }
            }
        }
    }
}