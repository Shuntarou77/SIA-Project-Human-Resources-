using System;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace ExWebAppSia.Models
{
    public class EmailService
    {
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;
        private readonly bool _enableSsl;

        public EmailService()
        {
            // Load SMTP settings from Web.config
            _smtpHost = (ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com").Trim();
            _smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
            _smtpUsername = (ConfigurationManager.AppSettings["SmtpUsername"] ?? "").Trim();
            _smtpPassword = (ConfigurationManager.AppSettings["SmtpPassword"] ?? "").Trim();
            _fromEmail = (ConfigurationManager.AppSettings["FromEmail"] ?? "").Trim();
            _fromName = ConfigurationManager.AppSettings["FromName"] ?? "HR Department";
            _enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
            
            // Enforce TLS 1.2 for secure SMTP connections
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        }

        /// <summary>
        /// Send interview invitation email to applicant
        /// </summary>
        public async Task<bool> SendInterviewInvitationEmailAsync(string toEmail, string applicantName, DateTime interviewDateTime, string location, string interviewerName, string notes = "")
        {
            try
            {
                string subject = "Interview Invitation - SheEssentials Beauty Product Company";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #A36A66, #8B5A58); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .details {{ background: #F8ECEB; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #A36A66; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Interview Invitation</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{applicantName}</strong>,</p>
            
            <p>Congratulations! Following the approval of your initial application, we are pleased to officially invite you for an interview at <strong>SheEssentials Beauty Product Company</strong>.</p>
            
            <div class='details'>
                <p><strong>📅 Interview Date & Time:</strong><br/>{interviewDateTime.ToLocalTime():dddd, MMMM dd, yyyy} at {interviewDateTime.ToLocalTime():h:mm tt}</p>
                <p><strong>📍 Location:</strong><br/>{location}</p>
                <p><strong>👤 Interviewer:</strong><br/>{interviewerName}</p>
                {(!string.IsNullOrEmpty(notes) ? $"<p><strong>📝 Additional Notes:</strong><br/>{notes}</p>" : "")}
            </div>
            
            <p><strong>Interview Preparation & Guidelines:</strong></p>
            <ul>
                <li><strong>Arrival:</strong> Please arrive 10-15 minutes before your scheduled time for processing.</li>
                <li><strong>Dress Code:</strong> Business Professional attire is recommended.</li>
                <li><strong>Documents to Bring:</strong>
                    <ul>
                        <li>Updated Resume/CV</li>
                        <li>Valid Government-issued ID</li>
                        <li>Professional Portfolio (if applicable)</li>
                    </ul>
                </li>
            </ul>
            
            <p><strong>Confirmation Required:</strong><br/>
            Please <strong>confirm your attendance</strong> by replying directly to this email at your earliest convenience. If you need to reschedule, kindly notify us at least 24 hours in advance.</p>
            
            <p>We look forward to the opportunity to discuss your background and how you can contribute to our team!</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This is an automated message. Please do not reply directly to this email.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending interview invitation email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Send hired notification email with account credentials
        /// </summary>
        public async Task<bool> SendHiredEmailAsync(string toEmail, string applicantName, string department, string role, string username, string password, bool isManager = false, bool isOrientation = false)
        {
            try
            {
                string subject = isOrientation ? "Hiring Update: Mandatory Orientation Required - SheEssentials" : "Congratulations! You're Hired - SheEssentials Beauty Product Company";
                string portalType = isManager ? "Manager Portal" : "Employee Self-Service Portal";
                string headerColor = isOrientation ? "#3b82f6, #2563eb" : "#4CAF50, #45a049";
                string headerTitle = isOrientation ? "Hiring Update" : "Congratulations!";
                
                string mainMessage = isOrientation 
                    ? $"You have been selected for the position of <strong>{role}</strong>! However, before being officially hired, you are <strong>required to attend a mandatory orientation</strong>. Please wait for the announcement regarding the orientation schedule."
                    : $"We are thrilled to inform you that you have been selected for the position of <strong>{role}</strong> in the <strong>{department}</strong> department.";

                var sbBody = new StringBuilder();
                sbBody.Append("<!DOCTYPE html><html><head><style>");
                sbBody.Append("body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }");
                sbBody.Append(".container { max-width: 600px; margin: 0 auto; padding: 20px; }");
                sbBody.AppendFormat(".header {{ background: linear-gradient(135deg, {0}); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}", headerColor);
                sbBody.Append(".content { background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }");
                sbBody.Append(".credentials { background: #F8ECEB; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #A36A66; }");
                sbBody.Append(".warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; }");
                sbBody.Append(".footer { text-align: center; margin-top: 20px; font-size: 12px; color: #999; }");
                sbBody.Append("</style></head><body>");
                sbBody.Append("<div class='container'>");
                sbBody.AppendFormat("<div class='header'><h1 style='margin: 0; font-size: 32px;'>{0}</h1>", headerTitle);
                sbBody.Append("<p style='margin: 10px 0 0; opacity: 0.95; font-size: 18px;'>Welcome to SheEssentials Beauty Product Company</p></div>");
                sbBody.AppendFormat("<div class='content'><p>Dear <strong>{0}</strong>,</p>", applicantName);
                sbBody.AppendFormat("<p>{0}</p>", mainMessage);
                sbBody.Append("<p>Welcome to the SheEssentials Beauty Product Company family!</p><br/>");
                
                if (isOrientation)
                {
                    sbBody.Append("<p><strong>Your account has been pre-created.</strong> You will gain full access once your orientation and final onboarding are complete.</p>");
                }

                sbBody.Append("<div class='credentials'>");
                sbBody.Append("<h3 style='margin-top: 0; color: #A36A66;'>Your Account Credentials</h3>");
                sbBody.AppendFormat("<p><strong>Portal:</strong> {0}</p>", portalType);
                sbBody.AppendFormat("<p><strong>Username:</strong> {0}</p>", username);
                sbBody.AppendFormat("<p><strong>Temporary Password:</strong> {0}</p>", password);
                sbBody.Append("</div>");
                
                sbBody.Append("<div class='warning'>");
                sbBody.Append("<p style='margin: 0;'><strong>Security Note:</strong> Your account is protected. For security reasons, please do not share these credentials with anyone.</p>");
                sbBody.Append("</div>");
                
                sbBody.AppendFormat("<p>If you have any questions, please contact the HR department.</p>");
                sbBody.Append("<p>Best regards,<br/>The SheEssentials HR Team</p>");
                sbBody.Append("</div><div class='footer'><p>&copy; 2026 SheEssentials Beauty Product Company. All rights reserved.</p></div></div></body></html>");

                return await SendEmailAsync(toEmail, subject, sbBody.ToString());
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending hired email: {ex.Message}");
                return false;
            }
        }
        

        /// <summary>
        /// Send physical requirement request email to applicant
        /// </summary>
        public async Task<bool> SendRequirementRequestEmailAsync(string toEmail, string applicantName, DateTime submissionDeadline)
        {
            try
            {
                string subject = "Action Required: Physical Requirements Submission - SheEssentials Beauty Product Company";
                
                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #3b82f6, #2563eb); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .deadline {{ background: #eff6ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #3b82f6; color: #1e40af; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Requirement Submission</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{applicantName}</strong>,</p>
            
            <p>We have reviewed your initial application and would like to proceed to the next step.</p>
            
            <p><strong>You can now submit your physical requirements.</strong> Please ensure all necessary documents are provided to our HR department as soon as possible.</p>
            
            <div class='deadline'>
                <p style='margin: 0; font-weight: bold;'>📅 Submission Deadline:</p>
                <p style='margin: 5px 0 0; font-size: 18px;'>{submissionDeadline:MMMM dd, yyyy}</p>
                <p style='margin: 5px 0 0; font-size: 13px;'>*Please submit within one week from today.</p>
            </div>
            
            <p><strong>List of Physical Requirements:</strong></p>
            <ul>
                <li>Authenticated Birth Certificate</li>
                <li>NBI Clearance or Police Clearance</li>
                <li>SSS, PhilHealth, and Pag-IBIG Numbers</li>
                <li>2x2 ID Pictures (4 copies)</li>
                <li>Medical Examination Results</li>
            </ul>
            
            <p>If you have any questions regarding the submission process, please reply to this email.</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This is an automated message. Please do not reply directly to this email.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending requirement request email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Send approval email to applicant
        /// </summary>
        public async Task<bool> SendApprovalEmailAsync(string toEmail, string applicantName)
        {
            try
            {
                string subject = "Application Approved - SheEssentials Beauty Product Company";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #A36A66, #8B5A58); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .highlight {{ background: #F8ECEB; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #A36A66; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Application Approved</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{applicantName}</strong>,</p>
            
            <p>Congratulations! We are pleased to inform you that your initial application has been approved.</p>
            
            <div class='highlight'>
                <p style='margin: 0;'><strong>📌 Next Step: Interview Schedule</strong></p>
                <p style='margin: 10px 0 0;'>You have been approved for the next stage. Please wait for a separate email regarding your specific interview schedule and further instructions.</p>
            </div>
            
            <p>In the meantime, please ensure you have all your original documents ready for verification.</p>
            
            <p>We look forward to the possibility of having you join our team!</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This is an automated message. Please do not reply directly to this email.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending approval email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Send rejection email to applicant
        /// </summary>
        public async Task<bool> SendRejectionEmailAsync(string toEmail, string applicantName, string reason = "")
        {
            try
            {
                string subject = "Application Status Update - SheEssentials Beauty Product Company";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #6c757d, #5a6268); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Application Status Update</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{applicantName}</strong>,</p>
            
            <p>Thank you for your interest in joining SheEssentials Beauty Product Company.</p>
            
            <p>After careful review of your application, we regret to inform you that we will not be moving forward with your candidacy at this time.</p>
            
            <div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #6c757d;'>
                <p><strong>Reason for decision:</strong><br/>
                We have determined that you are either <strong>missing some key requirements</strong> or your current qualifications <strong>do not match our specific needs</strong> for this position at this time.</p>
            </div>

            {(!string.IsNullOrEmpty(reason) ? $"<p><strong>Additional Feedback:</strong><br/>{reason}</p>" : "")}
            
            <p>We appreciate the time you took to apply and wish you the best of luck in your future endeavors.</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>Thank you for your interest in our company.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending rejection email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Send payslip email with PDF attachment
        /// </summary>
        public async Task<bool> SendPayslipEmailAsync(string toEmail, string employeeName, string payPeriod, byte[] pdfBytes, string fileName)
        {
            try
            {
                string subject = $"Your Payslip for {payPeriod} - SheEssentials";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #A36A66, #8B5A58); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .highlight {{ background: #F8ECEB; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #A36A66; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
        .icon {{ font-size: 48px; margin-bottom: 10px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <div class='icon'>💰</div>
            <h1 style='margin: 0; font-size: 28px;'>Payslip Available</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{employeeName}</strong>,</p>
            
            <p>Your payslip for <strong>{payPeriod}</strong> is now available.</p>
            
            <div class='highlight'>
                <p style='margin: 0;'><strong>📎 Attached Document:</strong></p>
                <p style='margin: 5px 0 0; font-size: 14px;'>{fileName}</p>
            </div>
            
            <p><strong>Important Notes:</strong></p>
            <ul>
                <li>Please review your payslip carefully</li>
                <li>Keep this document for your records</li>
                <li>Contact HR if you have any questions or discrepancies</li>
                <li>This is a confidential document - do not share with unauthorized persons</li>
            </ul>
            
            <p>If you have any questions regarding your payslip, please don't hesitate to contact the HR Department.</p>
            
            <p>Thank you for your continued dedication and hard work!</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This is an automated message. Please do not reply directly to this email.</p>
            <p>For inquiries, please contact: {ConfigurationManager.AppSettings["HREmail"]}</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailWithAttachmentAsync(toEmail, subject, body, pdfBytes, fileName, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending payslip email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Core email sending method
        /// </summary>
        private async Task<bool> SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true)
        {
            try
            {
                // Check if SMTP is configured
                if (string.IsNullOrEmpty(_smtpUsername) || string.IsNullOrEmpty(_smtpPassword) || string.IsNullOrEmpty(_fromEmail))
                {
                    System.Diagnostics.Debug.WriteLine("SMTP not configured. Skipping email send.");
                    return true;
                }

                using (var mailMessage = new MailMessage())
                {
                    mailMessage.From = new MailAddress(_fromEmail, _fromName);
                    mailMessage.To.Add(toEmail);
                    mailMessage.Subject = subject;
                    mailMessage.Body = body;
                    mailMessage.IsBodyHtml = isHtml;

                    using (var smtpClient = new SmtpClient(_smtpHost, _smtpPort))
                    {
                        smtpClient.UseDefaultCredentials = false;
                        smtpClient.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                        smtpClient.EnableSsl = _enableSsl;
                        smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;

                        await smtpClient.SendMailAsync(mailMessage);
                        System.Diagnostics.Debug.WriteLine($"Email sent successfully to: {toEmail}");
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending email to {toEmail} using account {_smtpUsername}: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return false;
            }
        }

        /// <summary>
        /// Send email with PDF attachment
        /// </summary>
        private async Task<bool> SendEmailWithAttachmentAsync(string toEmail, string subject, string body, byte[] attachmentBytes, string attachmentFileName, bool isHtml = true)
        {
            try
            {
                // Check if SMTP is configured
                if (string.IsNullOrEmpty(_smtpUsername) || string.IsNullOrEmpty(_smtpPassword) || string.IsNullOrEmpty(_fromEmail))
                {
                    System.Diagnostics.Debug.WriteLine("SMTP not configured. Skipping email send.");
                    System.Diagnostics.Debug.WriteLine($"Would have sent email to: {toEmail}");
                    System.Diagnostics.Debug.WriteLine($"Subject: {subject}");
                    System.Diagnostics.Debug.WriteLine($"Attachment: {attachmentFileName}");
                    return true; // Return true to not block the workflow
                }

                using (var mailMessage = new MailMessage())
                {
                    mailMessage.From = new MailAddress(_fromEmail, _fromName);
                    mailMessage.To.Add(toEmail);
                    mailMessage.Subject = subject;
                    mailMessage.Body = body;
                    mailMessage.IsBodyHtml = isHtml;

                    // Add PDF attachment
                    if (attachmentBytes != null && attachmentBytes.Length > 0)
                    {
                        var stream = new System.IO.MemoryStream(attachmentBytes);
                        var attachment = new Attachment(stream, attachmentFileName, "application/pdf");
                        mailMessage.Attachments.Add(attachment);
                    }

                    using (var smtpClient = new SmtpClient(_smtpHost, _smtpPort))
                    {
                        smtpClient.UseDefaultCredentials = false;
                        smtpClient.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                        smtpClient.EnableSsl = _enableSsl;

                        await smtpClient.SendMailAsync(mailMessage);
                        System.Diagnostics.Debug.WriteLine($"Email with attachment sent successfully to: {toEmail}");
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending email with attachment: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return false;
            }
        }
        public async Task<bool> SendPasswordResetEmailAsync(string toEmail, string userName, string resetLink)
        {
            try
            {
                string subject = "Password Reset Request - SheEssentials Beauty Product Company";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #A36A66, #8B5A58); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .button-container {{ text-align: center; margin: 30px 0; }}
        .button {{ display: inline-block; background: #A36A66; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; font-weight: bold; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Password Reset</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{userName}</strong>,</p>
            
            <p>We received a request to reset the password for your account. If you didn't make this request, you can safely ignore this email.</p>
            
            <p>To reset your password, please click the button below:</p>
            
            <div class='button-container'>
                <a href='{resetLink}' class='button'>Reset Password</a>
            </div>
            
            <p>Alternatively, you can copy and paste the following link into your browser:</p>
            <p style='word-break: break-all;'><a href='{resetLink}'>{resetLink}</a></p>
            
            <p>This link will expire in 2 hours for security reasons.</p>
            
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This is an automated message. Please do not reply directly to this email.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending password reset email: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Send termination/account deactivation email to employee
        /// </summary>
        public async Task<bool> SendAnnouncementEmailAsync(string toEmail, string employeeName, string announcementContent, string department = "General", string imagePath = null)
        {
            try
            {
                string subject = $"📢 New Official Announcement: {department} - SheEssentials";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #A44F56, #8B5A58); color: white; padding: 30px; text-align: center; border-radius: 12px 12px 0 0; }}
        .content {{ background: white; padding: 35px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 12px 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }}
        .dept-tag {{ display: inline-block; background: #F8ECEB; color: #A44F56; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-bottom: 15px; text-transform: uppercase; }}
        .announcement-box {{ background: #fafafa; padding: 25px; border-radius: 10px; border-left: 5px solid #A44F56; margin: 25px 0; font-size: 16px; white-space: pre-wrap; }}
        .footer {{ text-align: center; margin-top: 30px; font-size: 12px; color: #9B7B7B; }}
        .btn {{ display: inline-block; background: #A44F56; color: white; padding: 12px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; margin-top: 20px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 26px; letter-spacing: 1px;'>OFFICIAL ANNOUNCEMENT</h1>
            <p style='margin: 10px 0 0; opacity: 0.9;'>SheEssentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Hello <strong>{employeeName}</strong>,</p>
            
            <p>New information has been posted on the company bulletin. Please take a moment to review the details below:</p>
            
            <div class='dept-tag'>{department}</div>
            
            <div class='announcement-box'>
                {announcementContent}
            </div>

            {(!string.IsNullOrEmpty(imagePath) ? $"<p style='color: #666; font-style: italic; font-size: 13px;'>* This announcement includes an image attachment. Please log in to the portal to view the full post with all media.</p>" : "")}
            
            <p>Stay informed and stay safe!</p>
            
            <div style='text-align: center;'>
                <a href='http://localhost:54032/Login.aspx' class='btn'>Go to Employee Portal</a>
            </div>

            <p style='margin-top: 40px;'>Best regards,<br/>
            <strong>HR Department</strong><br/>
            SheEssentials Team</p>
        </div>
        <div class='footer'>
            <p>This is an automated company notification. &copy; 2026 SheEssentials Beauty Product Company</p>
            <p>You are receiving this because you are an active employee in our system.</p>
        </div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending announcement email: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendAccountStatusEmailAsync(string toEmail, string employeeName, string statusTitle = "Account Resigned")
        {
            try
            {
                string subject = $"Update Regarding Your Account Status - SheEssentials";

                string body = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #6c757d; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
        .status-badge {{ display: inline-block; background: #f8d7da; color: #721c24; padding: 5px 15px; border-radius: 4px; font-weight: bold; margin: 15px 0; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 24px;'>Account Status Update</h1>
        </div>
        <div class='content'>
            <p>Dear <strong>{employeeName}</strong>,</p>
            
            <p>This is to inform you that your account status has been updated in our system.</p>
            
            <div class='status-badge'>{statusTitle}</div>
            
            <p>If you have any questions regarding this change, please contact the HR department during business hours.</p>
            
            <p>Thank you for your cooperation and service.</p>
            
            <p>Best regards,<br/><strong>HR Department</strong><br/>SheEssentials Beauty Product Company</p>
        </div>
        <div class='footer'><p>&copy; 2026 SheEssentials Beauty Product Company</p></div>
    </div>
</body>
</html>";

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending account status email: {ex.Message}");
                return false;
            }
        }
    }
}
