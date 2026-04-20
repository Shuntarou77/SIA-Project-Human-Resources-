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
    public partial class PresidentLeaveRequest : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtStartDate;
        protected global::System.Web.UI.WebControls.TextBox txtLeaveReason;
        protected global::System.Web.UI.WebControls.TextBox txtEndDate;
        protected global::System.Web.UI.WebControls.DropDownList ddlLeaveType;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected global::System.Web.UI.WebControls.FileUpload fileAttachment;
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected Employee CurrentEmployee => Session["Employee"] as Employee;

        protected async void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(ddlLeaveType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtStartDate.Text) || 
                    string.IsNullOrWhiteSpace(txtEndDate.Text) || 
                    string.IsNullOrWhiteSpace(txtLeaveReason.Text))
                {
                    ShowMessage("Please fill in all required fields.", false);
                    return;
                }

                var emp = CurrentEmployee;
                if (emp == null) throw new Exception("Session expired.");

                var leave = new Leave
                {
                    EmployeeId = emp.EmployeeId,
                    EmployeeName = emp.FullName,
                    Department = emp.Department,
                    LeaveType = ddlLeaveType.SelectedValue,
                    StartDate = DateTime.Parse(txtStartDate.Text),
                    EndDate = DateTime.Parse(txtEndDate.Text),
                    Reason = txtLeaveReason.Text,
                    Status = "Approved", // AUTO-ACCEPT for President
                    SubmittedDate = DateTime.Now,
                    IsActive = true
                };

                var leaveService = new LeaveService();
                await leaveService.SubmitLeaveRequestAsync(leave);

                ShowMessage("✓ Your leave request has been automatically approved and recorded for transparency.", true);
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
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
            ddlLeaveType.SelectedIndex = 0;
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            txtLeaveReason.Text = "";
        }
    }
}

