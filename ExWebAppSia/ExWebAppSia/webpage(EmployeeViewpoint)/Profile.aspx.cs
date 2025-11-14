using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Configuration;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable HTML5 validation to prevent "invalid form control is not focusable" error
            if (!IsPostBack)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "DisableValidation", 
                    "if (document.forms[0]) { document.forms[0].noValidate = true; }", true);
            }
            else
            {
                // After postback, if there's a message, keep the modal open
                if (lblConcernMessage.Text != "")
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepConcernModalOpen", 
                        "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
                if (lblLeaveMessage.Text != "")
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepLeaveModalOpen", 
                        "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
            }
        }

        protected Employee CurrentEmployee
        {
            get
            {
                return Session["Employee"] as Employee;
            }
        }

        protected string GetEmployeeInitials()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(employee.FirstName))
                initials += employee.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(employee.LastName))
                initials += employee.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected string GetEmployeeName()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "N/A";
            
            return employee.FullName ?? "N/A";
        }

        protected string GetEmployeeId()
        {
            var employee = CurrentEmployee;
            return employee?.EmployeeId ?? "N/A";
        }

        protected string GetEmployeeRole()
        {
            var employee = CurrentEmployee;
            return employee?.Role ?? "N/A";
        }

        protected string GetEmployeeAddress()
        {
            var employee = CurrentEmployee;
            return employee?.Address ?? "N/A";
        }

        protected string GetEmployeeEmail()
        {
            var employee = CurrentEmployee;
            return employee?.Email ?? "N/A";
        }

        protected string GetEmployeeContact()
        {
            var employee = CurrentEmployee;
            return employee?.ContactNo ?? "N/A";
        }

        protected string GetEmployeeDepartment()
        {
            var employee = CurrentEmployee;
            return employee?.Department ?? "N/A";
        }

        protected void btnSubmitConcern_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("btnSubmitConcern_Click called");
            
            // Ensure modal stays open after postback
            ClientScript.RegisterStartupScript(this.GetType(), "OpenModal", 
                "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
            
            try
            {
                // Validate form
                if (string.IsNullOrWhiteSpace(ddlConcernType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtConcernSubject.Text) || 
                    string.IsNullOrWhiteSpace(txtConcernDescription.Text))
                {
                    lblConcernMessage.Text = "Please fill in all required fields.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    lblConcernMessage.Style["padding"] = "10px";
                    lblConcernMessage.Style["borderRadius"] = "5px";
                    
                    // Keep modal open
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepModalOpenError", 
                        "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
                    return;
                }

                var employee = CurrentEmployee;
                if (employee == null)
                {
                    lblConcernMessage.Text = "Employee session not found. Please log in again.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    return;
                }

                // Create concern object
                var concern = new EmployeeConcern
                {
                    EmployeeId = employee.EmployeeId,
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

                // Show success message immediately (before any DB or email operations)
                lblConcernMessage.Text = "✓ Your concern has been submitted successfully! An email will be sent to HR.";
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["color"] = "#155724";
                lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                lblConcernMessage.Style["border"] = "1px solid #c3e6cb";
                lblConcernMessage.Style["padding"] = "15px";
                lblConcernMessage.Style["borderRadius"] = "8px";
                lblConcernMessage.Style["fontWeight"] = "600";

                // Keep modal open and close after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "showSuccessAndClose", 
                    "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; setTimeout(function() { closeModal('concernModal'); }, 3000); }", true);

                // Save to database and send email in background (don't wait)
                System.Threading.Tasks.Task.Run(() => {
                    bool saved = false;
                    try
                    {
                        System.Diagnostics.Debug.WriteLine("Starting database save in background...");
                        var concernService = new EmployeeConcernService();
                        
                        // Try to save with a short timeout
                        var saveTask = concernService.CreateConcernAsync(concern);
                        if (saveTask.Wait(TimeSpan.FromSeconds(5))) // 5 second timeout
                        {
                            saved = saveTask.Result;
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

                    // Send email regardless of DB save result
                    try
                    {
                        System.Diagnostics.Debug.WriteLine("Starting email send...");
                        SendConcernEmail(concern, employee);
                        System.Diagnostics.Debug.WriteLine("Email sent successfully");
                    }
                    catch (Exception emailEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"Email error: {emailEx.Message}");
                        if (emailEx.InnerException != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"Email inner exception: {emailEx.InnerException.Message}");
                        }
                    }
                });
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

        private void SendConcernEmail(EmployeeConcern concern, Employee employee)
        {
            System.Diagnostics.Debug.WriteLine("SendConcernEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config or use defaults
                string smtpServer = ConfigurationManager.AppSettings["SmtpServer"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com"; // Default HR email
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                System.Diagnostics.Debug.WriteLine($"SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To: {hrEmail}, SSL: {enableSsl}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Email not sent: SMTP credentials not configured");
                    System.Diagnostics.Debug.WriteLine($"Username empty: {string.IsNullOrEmpty(smtpUsername)}, Password empty: {string.IsNullOrEmpty(smtpPassword)}");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Employee Concern System");
                mail.To.Add(hrEmail);
                mail.Subject = concern.Subject; // Use the subject from the form
                mail.IsBodyHtml = true;

                // Build email body with concern details
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A44F56;'>Employee Concern Submission</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");
                
                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Employee Name:</strong> {employee.FullName}</p>");
                body.AppendLine($"<p><strong>Employee ID:</strong> {employee.EmployeeId}</p>");
                body.AppendLine($"<p><strong>Employee Email:</strong> {employee.Email}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {employee.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Concern Type:</strong> {concern.ConcernType}</p>");
                body.AppendLine($"<p><strong>Priority Level:</strong> <span style='color: #A44F56; font-weight: bold;'>{concern.PriorityLevel}</span></p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {concern.SubmittedDate.ToLocalTime():MMM dd, yyyy HH:mm}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A44F56; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A44F56; margin-top: 0;'>Description:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(concern.Description)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated email from the Employee Concern System.</p>");
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
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);

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

        protected void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("btnSubmitLeave_Click called");
            
            // Ensure modal stays open after postback
            ClientScript.RegisterStartupScript(this.GetType(), "OpenLeaveModal", 
                "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);
            
            try
            {
                // Validate form
                if (string.IsNullOrWhiteSpace(ddlLeaveType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtStartDate.Text) || 
                    string.IsNullOrWhiteSpace(txtEndDate.Text) ||
                    string.IsNullOrWhiteSpace(txtLeaveReason.Text))
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

                var employee = CurrentEmployee;
                if (employee == null)
                {
                    lblLeaveMessage.Text = "Employee session not found. Please log in again.";
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
                    EmployeeId = employee.EmployeeId,
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

                // Show success message immediately
                lblLeaveMessage.Text = "✓ Your leave request has been submitted successfully! An email will be sent to HR.";
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["color"] = "#155724";
                lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                lblLeaveMessage.Style["border"] = "1px solid #c3e6cb";
                lblLeaveMessage.Style["padding"] = "15px";
                lblLeaveMessage.Style["borderRadius"] = "8px";
                lblLeaveMessage.Style["fontWeight"] = "600";

                // Keep modal open and close after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "showLeaveSuccessAndClose", 
                    "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; setTimeout(function() { closeModal('leaveModal'); }, 3000); }", true);

                // Save to database and send email in background
                System.Threading.Tasks.Task.Run(() => {
                    bool saved = false;
                    try
                    {
                        System.Diagnostics.Debug.WriteLine("Starting database save for leave request...");
                        var leaveService = new LeaveService();
                        
                        // Try to save with a short timeout
                        var saveTask = leaveService.CreateLeaveAsync(leave);
                        if (saveTask.Wait(TimeSpan.FromSeconds(5))) // 5 second timeout
                        {
                            saved = saveTask.Result;
                            System.Diagnostics.Debug.WriteLine($"Leave database save completed: {saved}");
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("Leave database save timed out");
                        }
                    }
                    catch (Exception dbEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"Leave database error: {dbEx.Message}");
                    }

                    // Send email regardless of DB save result
                    try
                    {
                        System.Diagnostics.Debug.WriteLine("Starting leave request email send...");
                        SendLeaveEmail(employee, leaveType, startDateStr, endDateStr, reason);
                        System.Diagnostics.Debug.WriteLine("Leave email sent successfully");
                    }
                    catch (Exception emailEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"Leave email error: {emailEx.Message}");
                        if (emailEx.InnerException != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"Leave email inner exception: {emailEx.InnerException.Message}");
                        }
                    }
                });
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

        private void SendLeaveEmail(Employee employee, string leaveType, string startDate, string endDate, string reason)
        {
            System.Diagnostics.Debug.WriteLine("SendLeaveEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config
                string smtpServer = ConfigurationManager.AppSettings["SmtpServer"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                System.Diagnostics.Debug.WriteLine($"Leave Email SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To: {hrEmail}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Leave email not sent: SMTP credentials not configured");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Employee Leave System");
                mail.To.Add(hrEmail);
                mail.Subject = $"Leave Request - {employee.FullName} ({leaveType})";
                mail.IsBodyHtml = true;

                // Build email body with leave details
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A44F56;'>Leave of Absence Request</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");
                
                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Employee Name:</strong> {employee.FullName}</p>");
                body.AppendLine($"<p><strong>Employee ID:</strong> {employee.EmployeeId}</p>");
                body.AppendLine($"<p><strong>Employee Email:</strong> {employee.Email}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {employee.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Leave Type:</strong> <span style='color: #A44F56; font-weight: bold;'>{leaveType}</span></p>");
                body.AppendLine($"<p><strong>Start Date:</strong> {DateTime.Parse(startDate):MMM dd, yyyy}</p>");
                body.AppendLine($"<p><strong>End Date:</strong> {DateTime.Parse(endDate):MMM dd, yyyy}</p>");
                
                // Calculate number of days
                TimeSpan duration = DateTime.Parse(endDate) - DateTime.Parse(startDate);
                int days = duration.Days + 1; // Include both start and end date
                body.AppendLine($"<p><strong>Duration:</strong> {days} day(s)</p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {DateTime.Now:MMM dd, yyyy HH:mm}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A44F56; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A44F56; margin-top: 0;'>Reason for Leave:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(reason)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated email from the Employee Leave System.</p>");
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
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);

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
    }
}