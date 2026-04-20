using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using MongoDB.Driver;
using MongoDB.Bson;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class EmployeeList : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtSearch;
        protected global::System.Web.UI.WebControls.Repeater rptEmployees;
        protected global::System.Web.UI.WebControls.Literal litTotalCount;
        protected global::System.Web.UI.WebControls.Literal litResigned;
        protected global::System.Web.UI.WebControls.Literal litRegular;
        protected global::System.Web.UI.WebControls.Literal litProbationary;
        protected global::System.Web.UI.WebControls.Literal litPending;
        protected global::System.Web.UI.WebControls.Literal litInactive;
        protected global::System.Web.UI.WebControls.Literal litContractual;
        protected global::System.Web.UI.WebControls.Literal litActive;
        protected global::System.Web.UI.WebControls.Literal litOnLeave;

        protected global::System.Web.UI.WebControls.DropDownList ddlDepartment;
        private readonly EmployeeService _employeeService = new EmployeeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadEmployeesAsync));
            }
        }

        private async Task LoadEmployeesAsync()
        {
            try
            {
                var allEmployees = await _employeeService.GetAllEmployeesAsync();
                
                // Filter out Executive department to exclude the President from general management metrics/lists
                var employees = allEmployees.Where(e => e.Department != "Executive").ToList();
                
                var filtered = employees.OrderBy(e => e.LastName).ToList();

                // Apply Search
                string search = txtSearch.Text.Trim().ToLower();
                if (!string.IsNullOrEmpty(search))
                {
                    filtered = filtered.Where(e =>
                        e.FullName.ToLower().Contains(search) ||
                        e.EmployeeId.ToLower().Contains(search) ||
                        (e.Position ?? "").ToLower().Contains(search)).ToList();
                }

                // Apply Department Filter
                string dept = ddlDepartment.SelectedValue;
                if (!string.IsNullOrEmpty(dept))
                {
                    filtered = filtered.Where(e => e.Department == dept).ToList();
                }

                // --- Status Counts (over ALL employees, not filtered) ---
                var leaveCol = MongoDBHelper.GetLeavesCollection();
                var todayDate = DateTime.UtcNow.AddHours(8).Date;
                var leaveFilter = Builders<Leave>.Filter.And(
                    Builders<Leave>.Filter.Eq(l => l.Status, "Approved"),
                    Builders<Leave>.Filter.Lte(l => l.StartDate, todayDate),
                    Builders<Leave>.Filter.Gte(l => l.EndDate, todayDate)
                );
                var leavesToday = await leaveCol.Find(leaveFilter).ToListAsync();
                var onLeaveEmpIds = new HashSet<string>(employees.Where(e => e.AvailabilityStatus == "On Leave").Select(e => e.EmployeeId));
                foreach (var l in leavesToday) onLeaveEmpIds.Add(l.EmployeeId);

                int regular     = employees.Count(e => e.EmploymentStatus == "Regular");
                int probationary = employees.Count(e => e.EmploymentStatus == "Probationary");
                int contractual  = employees.Count(e =>
                    !string.IsNullOrEmpty(e.ContractType) &&
                    e.ContractType.ToLower().Contains("contract"));

                int active   = employees.Count(e => e.IsActive && !onLeaveEmpIds.Contains(e.EmployeeId) && (e.ResignationStatus == "None" || string.IsNullOrEmpty(e.ResignationStatus)));
                int onLeave  = employees.Count(e => e.IsActive && onLeaveEmpIds.Contains(e.EmployeeId));
                int inactive = employees.Count(e => !e.IsActive);
                int resigned = employees.Count(e => e.ResignationStatus == "Approved");
                int pending  = employees.Count(e => e.ResignationStatus == "Pending");

                litTotalCount.Text   = filtered.Count.ToString();
                litRegular.Text      = regular.ToString();
                litProbationary.Text = probationary.ToString();
                litContractual.Text  = contractual.ToString();
                litActive.Text       = active.ToString();
                litOnLeave.Text      = onLeave.ToString();
                litInactive.Text     = inactive.ToString();
                litResigned.Text     = resigned.ToString();
                litPending.Text      = pending.ToString();

                // Annotate employees with leave status for rendering
                var displayList = filtered.Select(e => new {
                    e.EmployeeId,
                    e.FullName,
                    e.FirstName,
                    e.LastName,
                    e.Position,
                    e.Department,
                    e.Email,
                    e.ContactNo,
                    e.HiredDate,
                    e.EmploymentStatus,
                    e.ContractType,
                    e.IsActive,
                    e.ResignationStatus,
                    IsOnLeave = e.IsActive && (e.AvailabilityStatus == "On Leave" || onLeaveEmpIds.Contains(e.EmployeeId))
                }).ToList();

                rptEmployees.DataSource = displayList;
                rptEmployees.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading Employee List: {ex.Message}");
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadEmployeesAsync));
        }
    }
}

