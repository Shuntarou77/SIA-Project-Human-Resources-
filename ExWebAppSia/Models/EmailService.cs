using System;
using System.Net;
using System.Net.Mail;
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
    _smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
    _smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
         _smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
            _smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
            _fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? "";
         _fromName = ConfigurationManager.AppSettings["FromName"] ?? "HR Department";
     _enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");
        }

        /// <summary>
        /// Send interview invitation email to applicant
     /// </summary>
        public async Task<bool> SendInterviewInvitationEmailAsync(string toEmail, string applicantName, DateTime interviewDateTime, string location, string interviewerName, string notes = "")
 {
          try
     {
                string subject = "Interview Invitation - Essentials Beauty Product Company";
    
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
        .button {{ display: inline-block; background: #A36A66; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }}
      .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1 style='margin: 0; font-size: 28px;'>Interview Invitation</h1>
            <p style='margin: 10px 0 0; opacity: 0.95;'>Essentials Beauty Product Company</p>
    </div>
        <div class='content'>
        <p>Dear <strong>{applicantName}</strong>,</p>
     
   <p>Congratulations! We are pleased to invite you for an interview for the position you applied for.</p>
      
 <div class='details'>
     <p><strong>?? Interview Date & Time:</strong><br/>{interviewDateTime.ToLocalTime():dddd, MMMM dd, yyyy} at {interviewDateTime.ToLocalTime():h:mm tt}</p>
     <p><strong>?? Location:</strong><br/>{location}</p>
                <p><strong>?? Interviewer:</strong><br/>{interviewerName}</p>
    {(!string.IsNullOrEmpty(notes) ? $"<p><strong>?? Additional Notes:</strong><br/>{notes}</p>" : "")}
            </div>
    
          <p><strong>What to Bring:</strong></p>
          <ul>
 <li>Updated resume/CV</li>
 <li>Valid ID</li>
                <li>Professional portfolio (if applicable)</li>
            </ul>
     
            <p><strong>Please confirm your attendance</strong> by replying to this email at your earliest convenience.</p>
         
  <p>If you have any questions or need to reschedule, please don't hesitate to contact us.</p>
            
   <p>We look forward to meeting you!</p>
            
        <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
   Essentials Beauty Product Company</p>
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
        public async Task<bool> SendHiredEmailAsync(string toEmail, string applicantName, string department, string role, string username, string password, bool isManager = false)
        {
   try
        {
    string subject = "Congratulations! You're Hired - Essentials Beauty Product Company";
        string portalType = isManager ? "Manager Portal" : "Employee Self-Service Portal";
  string loginUrl = isManager ? "http://localhost:54257/ManagerFolder/ManagerLogin.aspx" : "http://localhost:54257/LoginFolder/Login.aspx";

  string body = $@"
<!DOCTYPE html>
<html>
<head>
 <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #4CAF50, #45a049); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background: white; padding: 30px; border: 1px solid #e8e8e8; border-top: none; border-radius: 0 0 8px 8px; }}
   .credentials {{ background: #F8ECEB; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #A36A66; }}
        .button {{ display: inline-block; background: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }}
        .warning {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; }}
        .footer {{ text-align: center; margin-top: 20px; font-size: 12px; color: #999; }}
    </style>
</head>
<body>
    <div class='container'>
   <div class='header'>
       <h1 style='margin: 0; font-size: 32px;'>?? Congratulations!</h1>
            <p style='margin: 10px 0 0; opacity: 0.95; font-size: 18px;'>Welcome to Essentials Beauty Product Company</p>
      </div>
        <div class='content'>
 <p>Dear <strong>{applicantName}</strong>,</p>
            
 <p>We are thrilled to inform you that you have been selected for the position of <strong>{role}</strong> in the <strong>{department}</strong> department.</p>
         
     <p>Welcome to the Essentials Beauty Product Company family!</p>
    
      <div class='credentials'>
  <h3 style='margin-top: 0; color: #A36A66;'>?? Your Account Credentials</h3>
       <p><strong>Portal:</strong> {portalType}</p>
       <p><strong>Username:</strong> {username}</p>
   <p><strong>Temporary Password:</strong> {password}</p>
  <p><strong>Login URL:</strong><br/><a href='{loginUrl}' style='color: #A36A66; word-break: break-all;'>{loginUrl}</a></p>
  </div>
     
      <div class='warning'>
         <p style='margin: 0;'><strong>?? Important:</strong> Please change your password after your first login for security purposes.</p>
      </div>
            
        <p><strong>Next Steps:</strong></p>
            <ol>
     <li>Log in to your account using the credentials above</li>
     <li>Complete your employee profile</li>
    <li>Review company policies and guidelines</li>
         <li>Wait for your official start date notification</li>
     </ol>
        
            <p>If you have any questions or face any issues accessing your account, please contact our HR department.</p>
      
            <p>Once again, congratulations and welcome aboard!</p>
 
        <p>Best regards,<br/>
     <strong>HR Department</strong><br/>
       Essentials Beauty Product Company</p>
        </div>
        <div class='footer'>
            <p>This email contains confidential information. Please keep your credentials secure.</p>
        </div>
    </div>
</body>
</html>";

    return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
   catch (Exception ex)
   {
    System.Diagnostics.Debug.WriteLine($"Error sending hired email: {ex.Message}");
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
              string subject = "Application Status Update - Essentials Beauty Product Company";
      
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
            <p style='margin: 10px 0 0; opacity: 0.95;'>Essentials Beauty Product Company</p>
        </div>
        <div class='content'>
            <p>Dear <strong>{applicantName}</strong>,</p>
            
    <p>Thank you for your interest in joining Essentials Beauty Product Company and for taking the time to interview with us.</p>
            
  <p>After careful consideration, we regret to inform you that we have decided to move forward with other candidates whose qualifications more closely match our current needs.</p>
      
            {(!string.IsNullOrEmpty(reason) ? $"<p>{reason}</p>" : "")}
            
 <p>We truly appreciate the time and effort you invested in the application process. Your skills and experience are impressive, and we encourage you to apply for future openings that align with your qualifications.</p>
            
         <p>We wish you all the best in your job search and future career endeavors.</p>
         
            <p>Best regards,<br/>
            <strong>HR Department</strong><br/>
          Essentials Beauty Product Company</p>
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
            Essentials Beauty Product Company</p>
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
      System.Diagnostics.Debug.WriteLine($"Would have sent email to: {toEmail}");
     System.Diagnostics.Debug.WriteLine($"Subject: {subject}");
     return true; // Return true to not block the workflow
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
   smtpClient.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
          smtpClient.EnableSsl = _enableSsl;

      await smtpClient.SendMailAsync(mailMessage);
      System.Diagnostics.Debug.WriteLine($"Email sent successfully to: {toEmail}");
  return true;
    }
       }
      }
        catch (Exception ex)
            {
          System.Diagnostics.Debug.WriteLine($"Error sending email: {ex.Message}");
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
    }
}
