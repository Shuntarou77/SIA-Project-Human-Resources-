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
    public partial class PresidentUndertimeRequest : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtReason;
        protected global::System.Web.UI.WebControls.TextBox txtDate;
        protected global::System.Web.UI.WebControls.TextBox txtHours;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtReason.Text))
            {
                Response.Write("<script>alert('Please provide a reason.');</script>");
                return;
            }

            // Simplified success for UI isolation purposes
            Response.Write("<script>alert('Undertime request submitted successfully!'); window.location='Dashboard.aspx';</script>");
        }
    }
}

