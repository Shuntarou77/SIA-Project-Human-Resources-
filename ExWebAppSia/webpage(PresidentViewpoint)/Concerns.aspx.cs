using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class PresidentConcerns : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtSubject;
        protected global::System.Web.UI.WebControls.TextBox txtDescription;
        protected global::System.Web.UI.WebControls.DropDownList ddlConcernType;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlConcernType.SelectedValue) || 
                string.IsNullOrWhiteSpace(txtSubject.Text) || 
                string.IsNullOrWhiteSpace(txtDescription.Text))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            ShowMessage("✓ Your concern has been submitted successfully for HR review.", true);
            ClearForm();
        }

        private void ShowMessage(string msg, bool isSuccess)
        {
            pnlMessage.Style["display"] = "block";
            pnlMessage.BackColor = isSuccess ? System.Drawing.Color.FromArgb(212, 237, 218) : System.Drawing.Color.FromArgb(248, 215, 218);
            lblMessage.Text = msg;
            lblMessage.ForeColor = isSuccess ? System.Drawing.Color.FromArgb(21, 87, 36) : System.Drawing.Color.FromArgb(114, 28, 36);
        }

        private void ClearForm()
        {
            ddlConcernType.SelectedIndex = 0;
            txtSubject.Text = "";
            txtDescription.Text = "";
        }
    }
}

