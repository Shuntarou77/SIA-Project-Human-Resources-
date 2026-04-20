using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class PresidentResignation : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtReason;
        protected global::System.Web.UI.WebControls.TextBox txtDate;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.AddDays(30).ToString("yyyy-MM-dd");
            }
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtReason.Text))
            {
                Response.Write("<script>alert('Please provide a reason.');</script>");
                return;
            }

            try
            {
                var emp = Session["Employee"] as Employee;
                if (emp == null) throw new Exception("Session expired.");

                var employeeService = new EmployeeService();
                // Set status to approved immediately for President
                await employeeService.SubmitResignationRequestAsync(emp.EmployeeId, txtReason.Text, DateTime.Parse(txtDate.Text));
                
                // Manually update to Approved in DB since standard service might set to Pending
                var collection = MongoDBHelper.GetEmployeesCollection();
                var update = Builders<Employee>.Update.Set(empRecord => empRecord.ResignationStatus, "Approved");
                await collection.UpdateOneAsync(empRecord => empRecord.EmployeeId == emp.EmployeeId, update);

                Response.Write("<script>alert('Your resignation has been automatically approved and recorded for transparency.'); window.location='Dashboard.aspx';</script>");
            }
            catch (Exception ex)
            {
                Response.Write($"<script>alert('Error: {ex.Message}');</script>");
            }
        }
    }
}

