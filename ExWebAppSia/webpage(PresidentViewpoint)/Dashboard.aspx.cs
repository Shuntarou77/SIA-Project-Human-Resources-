using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Text;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.PlaceHolder phEmployeeSummary;
        protected global::System.Web.UI.WebControls.PlaceHolder phAnnouncements;
        protected global::System.Web.UI.WebControls.Literal litTotalEmployees;
        protected global::System.Web.UI.WebControls.Literal litTotalApplicants;
        protected global::System.Web.UI.WebControls.Literal litPresentCount;
        protected global::System.Web.UI.WebControls.Literal litOnLeaveCount;
        protected global::System.Web.UI.WebControls.Literal litMaleCount;
        protected global::System.Web.UI.WebControls.Literal litLateCount;
        protected global::System.Web.UI.WebControls.Literal litInProgressApplicants;
        protected global::System.Web.UI.WebControls.Literal litGreeting;
        protected global::System.Web.UI.WebControls.Literal litFemaleCount;
        protected global::System.Web.UI.WebControls.Literal litCompletedApplicants;
        protected global::System.Web.UI.WebControls.Literal litAbsentCount;
        protected global::System.Web.UI.WebControls.Repeater rptPendingApprovals;
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly AnnouncementService _announcementService = new AnnouncementService();
        private readonly OvertimeService _overtimeService = new OvertimeService();

        private string _attendanceStatusJson = null;
        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;
        private string _announcementHtml = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/LoginFolder/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                // Set Personalized Greeting
                string displayName = "President";
                var emp = Session["Employee"] as Employee;
                if (emp != null)
                {
                    displayName = emp.FirstName;
                }

                if (litGreeting != null)
                    litGreeting.Text = $"Welcome back, President <strong>{displayName}</strong>!";

                RegisterAsyncTask(new PageAsyncTask(LoadDashboardDataAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatusAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPersonalAttendanceStatisticsAsync));
            }
        }

        protected Employee CurrentEmployee => Session["Employee"] as Employee;

        protected string GetEmployeeName() => CurrentEmployee?.FullName ?? "N/A";
        protected string GetEmployeeId() => CurrentEmployee?.EmployeeId ?? "N/A";

        private async Task LoadAttendanceStatusAsync()
        {
            try
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId))
                {
                    _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
                    return;
                }

                var attendance = await _attendanceService.GetTodayAttendanceAsync(employee.EmployeeId);
                var status = new
                {
                    hasTimedIn = attendance != null && attendance.TimeIn.HasValue,
                    hasTimedOut = attendance != null && attendance.TimeOut.HasValue,
                    timeIn = attendance?.TimeIn?.ToLocalTime().ToString("h:mm tt"),
                    timeOut = attendance?.TimeOut?.ToLocalTime().ToString("h:mm tt")
                };
                _attendanceStatusJson = new JavaScriptSerializer().Serialize(status);
            }
            catch
            {
                _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
            }
        }

        protected string GetAttendanceStatusJsonString() => _attendanceStatusJson ?? "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";

        private async Task LoadPersonalAttendanceStatisticsAsync()
        {
            try
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId))
                {
                    _attendanceStats = GetDefaultStats();
                    return;
                }

                _employeeAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId);
                CalculatePersonalAttendanceStatistics();
            }
            catch
            {
                _attendanceStats = GetDefaultStats();
            }
        }

        private void CalculatePersonalAttendanceStatistics()
        {
            if (_employeeAttendanceRecords == null || _employeeAttendanceRecords.Count == 0)
            {
                _attendanceStats = GetDefaultStats();
                return;
            }

            var now = DateTime.Now;
            var today = now.Date;
            var currentYear = now.Year;
            var yearStart = new DateTime(currentYear, 1, 1);
            
            // System-wide start date for attendance tracking
            var trackingStart = AttendanceService.TRACKING_START_DATE;
            // Get employee hired date
            var employee = CurrentEmployee;
            var hireDate = (employee != null && employee.HiredDate != DateTime.MinValue) ? employee.HiredDate.ToLocalTime().Date : trackingStart;
            var effectiveStart = hireDate > yearStart ? hireDate : yearStart;
            if (effectiveStart < trackingStart) effectiveStart = trackingStart;

            var yesterday = today.AddDays(-1);
            var yearlyRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.TimeIn.Value.ToLocalTime())
                .Where(t => t.Year == currentYear && t.Date >= effectiveStart)
                .ToList();

            // Only count finalized present days (before today)
            var yearlyPresent = yearlyRecords.Select(t => t.Date).Distinct().Count(d => d < today);
            
            // Only count finalized working days (up to yesterday)
            int pastYearWeekdays = 0;
            if (effectiveStart <= yesterday)
            {
                pastYearWeekdays = Enumerable.Range(0, (yesterday - effectiveStart).Days + 1)
                    .Select(i => effectiveStart.AddDays(i))
                    .Count(d => d.DayOfWeek != DayOfWeek.Sunday);
            }
            
            var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent);
            var remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);

            _attendanceStats = new Dictionary<string, object>
            {
                { "remainingAbsences", remainingAbsences }
            };
        }

        private Dictionary<string, object> GetDefaultStats() => new Dictionary<string, object> 
        { 
            { "remainingAbsences", TOTAL_ALLOWED_ABSENCES_PER_YEAR }
        };

        public string GetRemainingAbsences() => _attendanceStats?["remainingAbsences"].ToString() ?? "0";

        private async Task LoadDashboardDataAsync()
        {
            try
            {
                var employees = await _employeeService.GetAllEmployeesAsync();

                var employeesTask = LoadEmployeeData(employees);
                var applicantsTask = LoadApplicantData();
                var attendanceTask = LoadAttendanceData(employees);
                var announcementsTask = LoadRecentAnnouncementsAsync();

                await Task.WhenAll(employeesTask, applicantsTask, attendanceTask, announcementsTask);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading dashboard data: {ex.Message}");
            }
        }

        private async Task LoadEmployeeData(List<Employee> employees)
        {
            try
            {
                // Filter out Executive department from dashboard counts
                var countableEmployees = employees.Where(e => e.Department != "Executive").ToList();

                int totalEmployees = countableEmployees.Count;
                int femaleCount = countableEmployees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Female", StringComparison.OrdinalIgnoreCase));
                int maleCount = countableEmployees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Male", StringComparison.OrdinalIgnoreCase));

                if (litTotalEmployees != null) litTotalEmployees.Text = totalEmployees.ToString();
                if (litFemaleCount != null) litFemaleCount.Text = femaleCount.ToString();
                if (litMaleCount != null) litMaleCount.Text = maleCount.ToString();
                
                var recentEmployees = employees
                    .Where(e => e.IsActive)
                    .OrderByDescending(e => e.HiredDate)
                    .Take(3)
                    .ToList();
                await LoadEmployeeSummary(recentEmployees);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employee data: {ex.Message}");
            }
        }

        private async Task LoadApplicantData()
        {
            try
            {
                var applicants = await _applicantService.GetAllApplicantsAsync();
                int totalApplicants = applicants.Count;
                int inProgressCount = applicants.Count(a => a.Status != null && a.Status.Equals("In-Progress", StringComparison.OrdinalIgnoreCase));
                int completedCount = applicants.Count(a => a.Status != null && (a.Status.Equals("Hired", StringComparison.OrdinalIgnoreCase) || a.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase)));

                if (litTotalApplicants != null) litTotalApplicants.Text = totalApplicants.ToString();
                if (litInProgressApplicants != null) litInProgressApplicants.Text = inProgressCount.ToString();
                if (litCompletedApplicants != null) litCompletedApplicants.Text = completedCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading applicant data: {ex.Message}");
            }
        }

        private async Task LoadAttendanceData(List<Employee> allEmployees)
        {
            try
            {
                var today = DateTime.Today;
                var attendanceTask = _attendanceService.GetAttendanceByDateAsync(today);
                var leavesTask = _leaveService.GetLeavesByDateAsync(today);

                await Task.WhenAll(attendanceTask, leavesTask);
                
                var allAttendanceRecords = attendanceTask.Result;
                var attendanceRecords = allAttendanceRecords.Where(a => a.Department != "Executive").ToList();
                var leavesToday = leavesTask.Result;

                int totalActiveEmployees = allEmployees.Count(e => e.IsActive && e.Department != "Executive");
                int onLeaveCount = leavesToday.Count(l => l.Status == "Approved" && l.Department != "Executive");
                int presentCount = attendanceRecords.Count(a => a.TimeIn.HasValue);
                int lateCount = attendanceRecords.Count(a => a.TimeIn.HasValue && 
                    (a.TimeIn.Value.ToLocalTime().Hour > 8 || 
                    (a.TimeIn.Value.ToLocalTime().Hour == 8 && a.TimeIn.Value.ToLocalTime().Minute > 0)));
                
                int absentCount = totalActiveEmployees - presentCount - onLeaveCount;
                if (absentCount < 0) absentCount = 0;

                if (litPresentCount != null) litPresentCount.Text = presentCount.ToString();
                if (litAbsentCount != null) litAbsentCount.Text = absentCount.ToString();
                if (litOnLeaveCount != null) litOnLeaveCount.Text = onLeaveCount.ToString();
                if (litLateCount != null) litLateCount.Text = lateCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance data: {ex.Message}");
            }
        }

        private async Task LoadEmployeeSummary(List<Employee> employees)
        {
            var sb = new StringBuilder();
            if (employees == null || employees.Count == 0)
            {
                sb.Append(@"<tr><td colspan='3' style='text-align:center; padding:20px; color:#999;'>No employees found</td></tr>");
            }
            else
            {
                var payRunService = new PayRunService();
                
                var payrollTasks = employees.Select(async emp => {
                    try {
                        var latestPayRun = await payRunService.GetLatestPayRunForEmployeeAsync(emp.Id);
                        return new { emp, latestPayRun };
                    } catch {
                        return new { emp, latestPayRun = (PayRun)null };
                    }
                }).ToList();

                var results = await Task.WhenAll(payrollTasks);

                foreach (var result in results)
                {
                    var emp = result.emp;
                    string name = Server.HtmlEncode(emp.FullName ?? "N/A");
                    string role = Server.HtmlEncode(emp.Role ?? "No Role");
                    decimal netSalary = 0;
                    string status = "Unpaid", statusClass = "unpaid";
                    
                    if (result.latestPayRun != null && result.latestPayRun.Items != null)
                    {
                        var payrollItem = result.latestPayRun.Items.FirstOrDefault(i => i.EmployeeId == emp.Id);
                        if (payrollItem != null)
                        {
                            netSalary = payrollItem.NetSalary;
                            if (result.latestPayRun.IsPaid) { status = "Paid"; statusClass = "paid"; }
                            else if (result.latestPayRun.Status == "Approved") { status = "Approved"; statusClass = "approved"; }
                            else { status = "Pending"; statusClass = "pending"; }
                        }
                    }
                    
                    string salary = netSalary > 0 ? $"&#8369;{netSalary:N2}" : "&#8369;0.00";

                    sb.Append($@"
                        <tr>
                            <td>
                                <div class='employee-img'></div>
                                <div class='employee-info'>
                                    <div class='employee-name'>{name}</div>
                                    <div class='employee-role'>{role}</div>
                                </div>
                            </td>
                            <td style='font-weight: 600;'>{salary}</td>
                            <td><span class='status-badge status-{statusClass}'>{status}</span></td>
                        </tr>");
                }
            }

            if (phEmployeeSummary != null)
            {
                phEmployeeSummary.Controls.Clear();
                phEmployeeSummary.Controls.Add(new LiteralControl(sb.ToString()));
            }
        }

        private async Task LoadRecentAnnouncementsAsync()
        {
            try
            {
                var items = await _announcementService.GetRecentAsync(3);
                var sb = new StringBuilder();

                if (items == null || items.Count == 0)
                {
                    sb.Append("<li class='announcement-item' style='text-align:center; padding:15px; color:#999;'>No announcements yet</li>");
                }
                else
                {
                    foreach (var a in items)
                    {
                        string content = !string.IsNullOrEmpty(a.Content) ? a.Content : "No content";
                        string postedBy = !string.IsNullOrEmpty(a.PostedBy) ? a.PostedBy : "Admin";
                        string dateStr = a.PostedDate.ToLocalTime().ToString("MMM dd, yyyy");
                        string title = Server.HtmlEncode(content.Length > 50 ? content.Substring(0, 50) + "..." : content);

                        sb.Append($@"
                            <li class='announcement-item'>
                                <div class='announcement-title'>{title}</div>
                                <div class='announcement-date'>{postedBy} • {dateStr}</div>
                            </li>");
                    }
                }

                _announcementHtml = sb.ToString();
                if (phAnnouncements != null && !string.IsNullOrEmpty(_announcementHtml))
                {
                    phAnnouncements.Controls.Clear();
                    phAnnouncements.Controls.Add(new LiteralControl(_announcementHtml));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in LoadRecentAnnouncements: {ex.Message}");
            }
        }
    }
}

