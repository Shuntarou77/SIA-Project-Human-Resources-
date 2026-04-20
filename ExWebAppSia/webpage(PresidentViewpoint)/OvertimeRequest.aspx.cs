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
    public partial class PresidentOvertimeRequest : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtReason;
        protected global::System.Web.UI.WebControls.TextBox txtHours;
        protected global::System.Web.UI.WebControls.TextBox txtDate;
        protected global::System.Web.UI.WebControls.DropDownList ddlType;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtReason.Text) || string.IsNullOrWhiteSpace(txtHours.Text))
            {
                Response.Write("<script>alert('Please fill in all fields.');</script>");
                return;
            }

            try
            {
                var emp = Session["Employee"] as Employee;
                if (emp == null) throw new Exception("Session expired.");

                var otService = new OvertimeService();
                var request = new OvertimeRequest
                {
                    EmployeeId = emp.EmployeeId,
                    EmployeeName = emp.FullName,
                    Department = emp.Department,
                    Date = DateTime.Parse(txtDate.Text),
                    RequestedHours = decimal.Parse(txtHours.Text),
                    OvertimeType = ddlType.SelectedValue,
                    Reason = txtReason.Text,
                    Status = "Approved", // AUTO-ACCEPT for President
                    RequestedAt = DateTime.Now,
                    BaseSalary = emp.BaseSalary
                };

                await otService.SubmitRequestAsync(request);

                Response.Write("<script>alert('Your overtime has been automatically approved and recorded for transparency.'); window.location='Dashboard.aspx';</script>");
            }
            catch (Exception ex)
            {
                Response.Write($"<script>alert('Error: {ex.Message}');</script>");
            }
        }
    }
}

