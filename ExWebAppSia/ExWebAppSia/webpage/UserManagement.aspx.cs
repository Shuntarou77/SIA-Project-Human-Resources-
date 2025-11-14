using System;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class UserManagement : System.Web.UI.Page
    {
        private readonly UserService _userService = new UserService();

        protected async void btnAddUser_Click(object sender, EventArgs e)
        {
            try
            {
                string username = txtNewUsername.Text.Trim();
                string password = txtNewPassword.Text.Trim();
                string role = ddlRole.SelectedValue;
                string email = txtEmail.Text.Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    lblMessage.Text = "Please fill in all required fields.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                bool success = await _userService.CreateUserAsync(username, password, role, email);

                if (success)
                {
                    lblMessage.Text = "User created successfully!";
                    lblMessage.ForeColor = System.Drawing.Color.Green;

                    // Clear form
                    txtNewUsername.Text = "";
                    txtNewPassword.Text = "";
                    txtEmail.Text = "";
                }
                else
                {
                    lblMessage.Text = "Failed to create user. Username might already exist.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "An error occurred: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}