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
    public partial class AttendanceOverview : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.TextBox txtSelectedDate;
        protected global::System.Web.UI.WebControls.Repeater rptAttendance;
        protected global::System.Web.UI.WebControls.Literal litUT;
        protected global::System.Web.UI.WebControls.Literal litRegular;
        protected global::System.Web.UI.WebControls.Literal litProbationary;
        protected global::System.Web.UI.WebControls.Literal litPresent;
        protected global::System.Web.UI.WebControls.Literal litOnLeave;
        protected global::System.Web.UI.WebControls.Literal litLate;
        protected global::System.Web.UI.WebControls.Literal litAbsent;
        protected global::System.Web.UI.WebControls.Literal litOT;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divNoData;
        protected global::System.Web.UI.WebControls.DropDownList ddlDeptFilter;
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private readonly UndertimeService _undertimeService = new UndertimeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtSelectedDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                RegisterAsyncTask(new PageAsyncTask(LoadDataAsync));
            }
        }

        protected async void DateChanged(object sender, EventArgs e)
        {
            await LoadDataAsync();
        }

        private async Task LoadDataAsync()
        {
            try
            {
                DateTime selectedDate;
                if (!DateTime.TryParse(txtSelectedDate.Text, out selectedDate))
                {
                    selectedDate = DateTime.Now;
                }

                var allAttendance = await _attendanceService.GetAllActiveAttendanceAsync();
                var dayAttendance = allAttendance.Where(a => a.TimeIn.HasValue && a.TimeIn.Value.ToLocalTime().Date == selectedDate.Date).ToList();

                // Load all employees to calculate absents
                var allEmployees = await _employeeService.GetAllEmployeesAsync();
                int totalEmpCount = allEmployees.Count;

                // Department Filter
                string selectedDept = ddlDeptFilter.SelectedValue;
                if (!string.IsNullOrEmpty(selectedDept))
                {
                    dayAttendance = dayAttendance.Where(a => a.Department == selectedDept).ToList();
                    totalEmpCount = allEmployees.Count(e => e.Department == selectedDept);
                }

                // Stats calculation
                int present = dayAttendance.Count;
                int late = dayAttendance.Count(a => {
                    var timeIn = a.TimeIn?.ToLocalTime();
                    return timeIn?.Hour >= 8 && (timeIn?.Minute > 0 || timeIn?.Hour > 8);
                });
                
                // Only count absentees on working days (Mon-Sat)
                int absent = 0;
                if (selectedDate.DayOfWeek != DayOfWeek.Sunday)
                {
                    absent = Math.Max(0, totalEmpCount - present);
                }
                
                // For OT and UT, we'd need to check the respective collections
                var otRequests = await _overtimeService.GetAllAsync();
                int otCount = otRequests.Count(r => r.Date.Date == selectedDate.Date && r.Status == "Approved");

                var utRequests = await _undertimeService.GetAllRequestsAsync();
                int utCount = utRequests.Count(r => r.Date.Date == selectedDate.Date && r.Status == "Approved");

                litPresent.Text = present.ToString();
                litLate.Text = late.ToString();
                litAbsent.Text = absent.ToString();
                litOT.Text = otCount.ToString();
                litUT.Text = utCount.ToString();

                // NEW: Working Format Stats
                int regularCount = allEmployees.Count(e => e.EmploymentStatus == "Regular");
                int probationaryCount = allEmployees.Count(e => e.EmploymentStatus == "Probationary");
                
                // Fetch Approved Leaves for the selected date
                var leaveCol = MongoDBHelper.GetLeavesCollection();
                var filter = Builders<Leave>.Filter.And(
                    Builders<Leave>.Filter.Eq(l => l.Status, "Approved"),
                    Builders<Leave>.Filter.Eq(l => l.IsActive, true)
                );
                var cursor = await leaveCol.FindAsync(filter);
                var approvedLeaves = await cursor.ToListAsync();
                int onLeaveCount = approvedLeaves.Count(l => selectedDate.Date >= l.StartDate.Date && selectedDate.Date <= l.EndDate.Date);

                litRegular.Text = regularCount.ToString();
                litProbationary.Text = probationaryCount.ToString();
                litOnLeave.Text = onLeaveCount.ToString();

                if (dayAttendance.Any())
                {
                    rptAttendance.DataSource = dayAttendance.OrderBy(a => a.TimeIn).ToList();
                    rptAttendance.DataBind();
                    divNoData.Visible = false;
                }
                else
                {
                    rptAttendance.DataSource = null;
                    rptAttendance.DataBind();
                    divNoData.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading Attendance Overview: {ex.Message}");
            }
        }

        protected string GetStatusMarkup(object timeInObj, object lateTimeObj)
        {
            if (timeInObj == null) return "<span class='time-chip' style='background:#FFEBEE; color:#C62828;'>Absent</span>";
            
            DateTime? timeIn = (DateTime?)timeInObj;
            if (timeIn.HasValue)
            {
                var local = timeIn.Value.ToLocalTime();
                if (local.Hour > 8 || (local.Hour == 8 && local.Minute > 0))
                {
                    return "<span class='time-chip chip-late'>Late Arrival</span>";
                }
            }
            
            return "<span class='time-chip chip-in'>On Time</span>";
        }
    }
}

