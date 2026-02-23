using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.LoginFolder
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private readonly UserService _userService = new UserService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                string token = Request.QueryString["token"];
                if (string.IsNullOrEmpty(token))
                {
                    ShowMessage("Invalid or expired reset link.", true);
                    pnlForm.Visible = false;
                    return;
                }

                // Verify token and expiration
                var user = await _userService.GetUserByResetTokenAsync(token);
                if (user == null)
                {
                    ShowMessage("Invalid or expired reset link. Please request a new one.", true);
                    pnlForm.Visible = false;
                }
            }
        }

        protected async void btnResetPassword_Click(object sender, EventArgs e)
        {
            string newPassword = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();
            string token = Request.QueryString["token"];

            if (string.IsNullOrEmpty(newPassword) || newPassword != confirmPassword)
            {
                ShowMessage("Passwords do not match.", true);
                return;
            }

            try
            {
                // Verify token again before updating
                var user = await _userService.GetUserByResetTokenAsync(token);
                if (user == null)
                {
                    ShowMessage("Invalid or expired reset link. Please request a new one.", true);
                    pnlForm.Visible = false;
                    return;
                }

                // Update password
                bool success = await _userService.UpdatePasswordAsync(user.Username, newPassword);

                if (success)
                {
                    // Clear reset token
                    await _userService.ClearResetTokenAsync(user.Id);

                    ShowMessage("Password updated successfully. You can now log in.", false);
                    pnlForm.Visible = false;
                }
                else
                {
                    ShowMessage("Failed to update password. Please try again later.", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in ResetPassword: {ex.Message}");
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
