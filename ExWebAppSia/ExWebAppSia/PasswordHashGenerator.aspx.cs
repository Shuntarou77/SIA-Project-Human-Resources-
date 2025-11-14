using System;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia
{
    public partial class PasswordHashGenerator : System.Web.UI.Page
    {
        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            string password = txtPassword.Text;
            if (!string.IsNullOrEmpty(password))
            {
                string hashedPassword = PasswordHelper.HashPasswordComplete(password);
                lblHash.Text = $"<strong>Hashed Password:</strong><br/><textarea style='width: 100%; height: 100px;'>{hashedPassword}</textarea>";
                lblHash.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lblHash.Text = "Please enter a password";
                lblHash.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}