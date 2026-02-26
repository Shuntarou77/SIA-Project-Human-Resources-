using ExWebAppSia.Models;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;

namespace ExWebAppSia.webpage
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string _announcementHtml = string.Empty;
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly LeaveService _leaveService = new LeaveService();

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
                string displayName = "Admin";
                if (Session["Username"] != null)
                {
                    string username = Session["Username"].ToString();
                    displayName = username.Split('@')[0]; // Simple fallback: use part of email
                    
                    // If we have employee data in session, use full name
                    var emp = Session["Employee"] as Employee;
                    if (emp != null)
                    {
                        displayName = emp.FirstName;
                    }
                }

                if (litGreeting != null) 
                    litGreeting.Text = $"Welcome back, <strong>{displayName}</strong>!";
                
                if (litDashboardTitle != null)
                    litDashboardTitle.Visible = false;

                RegisterAsyncTask(new PageAsyncTask(LoadDashboardDataAsync));
            }
        }

        private async Task LoadDashboardDataAsync()
        {
            try
            {
                // Auto-promote probationary employees who reached 6 months
                await _employeeService.ProcessRegularizationAsync();
                
                // Ensure all probationary employees have the correct starting salary
                await _employeeService.FixProbationarySalariesAsync();

                // Fix missing genders for dashboard counts
                await _employeeService.FixMissingGendersAsync();

                // Seed specific HR employees requested by the user
                await EmployeeSeeder.SeedSpecificHREmployeesAsync();

                // Core optimization: Load employees once to share across all other tasks
                var employees = await _employeeService.GetAllEmployeesAsync();

                // Load all specific datasets in parallel
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
                int totalEmployees = employees.Count;
                int femaleCount = employees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Female", StringComparison.OrdinalIgnoreCase));
                int maleCount = employees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Male", StringComparison.OrdinalIgnoreCase));

                int regularCount = employees.Count(e => e.ContractType == "Regular");
                int probationaryCount = employees.Count(e => e.ContractType == "Probationary");

                double regularPercentage = totalEmployees > 0 ? (regularCount * 100.0 / totalEmployees) : 0;
                double probationaryPercentage = totalEmployees > 0 ? (probationaryCount * 100.0 / totalEmployees) : 0;

                if (litTotalEmployees != null) litTotalEmployees.Text = totalEmployees.ToString();
                if (litFemaleCount != null) litFemaleCount.Text = femaleCount.ToString();
                if (litMaleCount != null) litMaleCount.Text = maleCount.ToString();
                
                if (litRegularPercentage != null) litRegularPercentage.Text = regularPercentage.ToString("F0");
                if (litRegularPercentageDisplay != null) litRegularPercentageDisplay.Text = $"{regularPercentage:F0}%";
                if (litContractualPercentage != null) litContractualPercentage.Text = probationaryPercentage.ToString("F0"); // Reusing Contractual Literal for Probationary
                if (litContractualPercentageDisplay != null) litContractualPercentageDisplay.Text = $"{probationaryPercentage:F0}%";
             
                // Headcount per Department
                var headcountData = employees
                    .GroupBy(e => e.Department ?? "Unassigned")
                    .Select(g => new { Dept = g.Key, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .ToDictionary(x => x.Dept, x => x.Count);
                
                Session["DeptHeadcount"] = headcountData;
             
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
                if (litTotalEmployees != null) litTotalEmployees.Text = "0";
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
                
                var attendanceRecords = attendanceTask.Result;
                var leavesToday = leavesTask.Result;

                int totalActiveEmployees = allEmployees.Count(e => e.IsActive);
                int onLeaveCount = leavesToday.Count(l => l.Status == "Approved");
                int presentCount = attendanceRecords.Count(a => a.TimeIn.HasValue);
                int lateCount = attendanceRecords.Count(a => a.TimeIn.HasValue && 
                    (a.TimeIn.Value.ToLocalTime().Hour > 8 || 
                     (a.TimeIn.Value.ToLocalTime().Hour == 8 && a.TimeIn.Value.ToLocalTime().Minute > 0) ||
                     (a.TimeIn.Value.ToLocalTime().Hour == 8 && a.TimeIn.Value.ToLocalTime().Second > 0)));
                
                int absentCount = totalActiveEmployees - presentCount - onLeaveCount;
                if (absentCount < 0) absentCount = 0;

                if (litPresentCount != null) litPresentCount.Text = presentCount.ToString();
                if (litAbsentCount != null) litAbsentCount.Text = absentCount.ToString();
                if (litOnLeaveCount != null) litOnLeaveCount.Text = onLeaveCount.ToString();
                if (litLateCount != null) litLateCount.Text = lateCount.ToString();
                
                if (litPresentCountJS != null) litPresentCountJS.Text = presentCount.ToString();
                if (litAbsentCountJS != null) litAbsentCountJS.Text = absentCount.ToString();
                if (litOnLeaveCountJS != null) litOnLeaveCountJS.Text = onLeaveCount.ToString();
                if (litLateCountJS != null) litLateCountJS.Text = lateCount.ToString();
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
                
                // Parallel fetching of payroll info for faster renders
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
            var loadTask = LoadRecentAnnouncements();
            var timeoutTask = Task.Delay(5000);
            var completedTask = await Task.WhenAny(loadTask, timeoutTask);
            if (completedTask == timeoutTask)
            {
                _announcementHtml = "<li class='announcement-item' style='text-align:center; padding:10px; color:#666;'>Loading announcements...</li>";
            }
            else
            {
                await loadTask;
            }
        }

        private async Task LoadRecentAnnouncements()
        {
            try
            {
                var service = new AnnouncementService();
                var items = await service.GetRecentAsync(3);
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
                        string postedBy = !string.IsNullOrEmpty(a.PostedBy) ? a.PostedBy : "HR Admin";
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
                _announcementHtml = $"<li class='announcement-item' style='color:#c62828; padding:10px;'>Error: {Server.HtmlEncode(ex.Message)}</li>";
            }
        }
    }
}
