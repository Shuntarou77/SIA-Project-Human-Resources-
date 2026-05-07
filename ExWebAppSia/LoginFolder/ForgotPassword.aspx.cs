using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.LoginFolder
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        private readonly UserService _userService = new UserService();
        private readonly EmailService _emailService = new EmailService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                // Pre-fill email from query string if available
                string emailParam = Request.QueryString["email"];
                if (!string.IsNullOrEmpty(emailParam))
                {
                    txtEmail.Text = emailParam;
                }
            }
        }

        protected async void btnSendLink_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowMessage("Please enter your email address.", true);
                return;
            }

            try
            {
                // Check if user exists (checking both Email and Username fields for flexibility)
                var user = await _userService.GetUserByEmailAsync(email);
                if (user == null)
                {
                    user = await _userService.GetUserByUsernameAsync(email);
                }
                
                if (user == null || !user.IsActive)
                {
                    // USER REQUEST: Only recognize registered emails
                    ShowMessage("This email address is not registered in our system. Please check and try again.", true);
                    return;
                }

                // Use the primary email from the record if found, otherwise the input
                string targetEmail = !string.IsNullOrEmpty(user.Email) ? user.Email : email;
                
                // Generate reset token
                string token = Guid.NewGuid().ToString("N");
                DateTime expiration = DateTime.UtcNow.AddHours(2);

                // Update user with reset token
                bool updated = await _userService.UpdateResetTokenByIdAsync(user.Id, token, expiration);

                if (updated)
                {
                    // Create reset link
                    string baseUrl = Request.Url.GetLeftPart(UriPartial.Authority);
                    string resetLink = $"{baseUrl}/LoginFolder/ResetPassword.aspx?token={token}";

                    // Send email
                    bool emailSent = await _emailService.SendPasswordResetEmailAsync(targetEmail, user.FirstName ?? user.Username, resetLink);

                    if (emailSent)
                    {
                        ShowMessage("A password reset link has been sent to your email.", false);
                        pnlForm.Visible = false;
                    }
                    else
                    {
                        ShowMessage("Failed to send reset email. Please try again later.", true);
                    }
                }
                else
                {
                    ShowMessage("An error occurred while processing your request.", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in ForgotPassword: {ex.Message}");
                ShowMessage("An unexpected error occurred. Please try again later.", true);
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            pnlMessage.Visible = true;
            pnlMessage.Attributes["class"] = isError ? "message error" : "message success";
            litMessage.Text = text;
        }
    }
}
