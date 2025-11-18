using ExWebAppSia.Models;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;

namespace ExWebAppSia.webpage
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string _announcementHtml = string.Empty;
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly AttendanceService _attendanceService = new AttendanceService();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication first
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/LoginFolder/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                // Load all dashboard data asynchronously
                RegisterAsyncTask(new PageAsyncTask(LoadDashboardDataAsync));
            }
        }

        private async Task LoadDashboardDataAsync()
        {
            try
            {
                // Load all data in parallel for better performance
                var employeesTask = LoadEmployeeData();
                var applicantsTask = LoadApplicantData();
                var attendanceTask = LoadAttendanceData();
                var announcementsTask = LoadRecentAnnouncementsAsync();

                await Task.WhenAll(employeesTask, applicantsTask, attendanceTask, announcementsTask);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading dashboard data: {ex.Message}");
            }
        }

        private async Task LoadEmployeeData()
        {
            try
            {
                var employees = await _employeeService.GetAllEmployeesAsync();

                // Total employees
                int totalEmployees = employees.Count;
                int femaleCount = employees.Count(e => e.Department != null &&
                    !string.IsNullOrEmpty(e.Department) &&
                    (e.Department.Contains("Female") || IsLikelyFemale(e.FirstName)));
                int maleCount = totalEmployees - femaleCount;

                // Working format (Contract Type)
                int regularCount = employees.Count(e => e.ContractType == "Regular");
                int contractualCount = employees.Count(e => e.ContractType == "Contractual");

                double regularPercentage = totalEmployees > 0 ? (regularCount * 100.0 / totalEmployees) : 0;
                double contractualPercentage = totalEmployees > 0 ? (contractualCount * 100.0 / totalEmployees) : 0;

                // Update UI elements
                if (litTotalEmployees != null) litTotalEmployees.Text = totalEmployees.ToString();
                if (litFemaleCount != null) litFemaleCount.Text = femaleCount.ToString();
                if (litMaleCount != null) litMaleCount.Text = maleCount.ToString();
                if (litRegularPercentage != null) litRegularPercentage.Text = regularPercentage.ToString("F1") + "%";
                if (litContractualPercentage != null) litContractualPercentage.Text = contractualPercentage.ToString("F1") + "%";

                // Load employee summary (top 3 recent)
                var recentEmployees = employees.OrderByDescending(e => e.HiredDate).Take(3).ToList();
                LoadEmployeeSummary(recentEmployees);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employee data: {ex.Message}");
            }
        }

        private bool IsLikelyFemale(string firstName)
        {
            if (string.IsNullOrEmpty(firstName)) return false;
            var femaleNames = new[] { "Maria", "Ana", "Jane", "Sarah", "Emma", "Sophia", "Isabella", "Olivia" };
            return femaleNames.Any(name => firstName.IndexOf(name, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        private async Task LoadApplicantData()
        {
            try
            {
                var applicants = await _applicantService.GetAllApplicantsAsync();

                int totalApplicants = applicants.Count;
                int inProgressCount = applicants.Count(a => a.Status == "In-Progress");
                int newCount = applicants.Count(a => a.Status == "New");

                if (litTotalApplicants != null) litTotalApplicants.Text = totalApplicants.ToString();
                if (litInProgressApplicants != null) litInProgressApplicants.Text = inProgressCount.ToString();
                if (litNewApplicants != null) litNewApplicants.Text = newCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading applicant data: {ex.Message}");
            }
        }

        private async Task LoadAttendanceData()
        {
            try
            {
                var today = DateTime.Today;
                var attendanceRecords = await _attendanceService.GetAttendanceByDateAsync(today);
                
                // Calculate attendance status based on TimeIn
                // On Time: Clocked in before 9:00 AM
                // Late: Clocked in after 9:00 AM
                // Absent: No time in record
                
                int onTimeCount = attendanceRecords.Count(a => a.TimeIn.HasValue && a.TimeIn.Value.ToLocalTime().Hour < 9);
                int lateCount = attendanceRecords.Count(a => a.TimeIn.HasValue && a.TimeIn.Value.ToLocalTime().Hour >= 9);
                
                // Get total employees to calculate absent count
                var totalEmployees = await _employeeService.GetAllEmployeesAsync();
                int absentCount = totalEmployees.Count - attendanceRecords.Count(a => a.TimeIn.HasValue);

                // Note: Dashboard doesn't have these literal controls yet, so we're just calculating the values
                // You can add them to the ASPX file if needed
                System.Diagnostics.Debug.WriteLine($"Attendance - On Time: {onTimeCount}, Late: {lateCount}, Absent: {absentCount}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance data: {ex.Message}");
            }
        }

        private void LoadEmployeeSummary(System.Collections.Generic.List<Employee> employees)
        {
            var sb = new StringBuilder();

            foreach (var emp in employees)
            {
                string name = Server.HtmlEncode(emp.FullName ?? "N/A");
                string role = Server.HtmlEncode(emp.Role ?? "No Role");
                string salary = "₱0"; // You can add salary field to Employee model if needed
                string status = "Paid"; // You can add payment status if needed

                sb.Append($@"
                    <tr>
                        <td>
                            <div class='employee-avatar'></div>
                            <div class='employee-info'>
                                <div class='employee-name'>{name}</div>
                                <div class='employee-role'>{role}</div>
                            </div>
                        </td>
                        <td class='salary'>{salary}</td>
                        <td><span class='status-badge status-{status.ToLower()}'>{status}</span></td>
                    </tr>");
            }

            if (phEmployeeSummary != null)
            {
                phEmployeeSummary.Controls.Clear();
                phEmployeeSummary.Controls.Add(new LiteralControl(sb.ToString()));
            }
        }

        private async Task LoadRecentAnnouncementsAsync()
        {
            // Use a timeout to prevent hanging
            var loadTask = LoadRecentAnnouncements();
            var timeoutTask = Task.Delay(3000); // 3 second timeout

            var completedTask = await Task.WhenAny(loadTask, timeoutTask);

            if (completedTask == timeoutTask)
            {
                _announcementHtml = "<div style='padding:10px; color:#666;'>Loading announcements...</div>";
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (!string.IsNullOrEmpty(_announcementHtml) && phAnnouncements != null)
            {
                phAnnouncements.Controls.Clear();
                phAnnouncements.Controls.Add(new LiteralControl(_announcementHtml));
            }
        }

        private async Task LoadRecentAnnouncements()
        {
            try
            {
                var service = new AnnouncementService();
                var items = await service.GetRecentAsync(4); // Show 4 like image

                var sb = new StringBuilder();
                sb.Append("<ul class=\"announcement-list\">");

                if (items == null || items.Count == 0)
                {
                    sb.Append("<li style='text-align:center; padding:10px; color:#A85B5B;'>No announcements yet</li>");
                }
                else
                {
                    foreach (var a in items)
                    {
                        string content = Server.HtmlEncode(a.Content?.Length > 40
                            ? a.Content.Substring(0, 40) + "..."
                            : a.Content ?? "No content");

                        string postedBy = Server.HtmlEncode(a.PostedBy ?? "Unknown");
                        string time = a.PostedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt");

                        sb.Append($@"
<li class='announcement-item'>
    <div class='announcement-avatar'>
        <img src='data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMCIgaGVpZ2h0PSIzMCIgdmlld0JveD0iMCAwIDMwIDMwIj4KICA8Y2lyY2xlIGN4PSIxNSIgY3k9IjE1IiByPSIxNSIgZmlsbD0iIzk5OTkiLz4KICA8Y2lyY2xlIGN4PSIxNSIgY3k9IjEwIiByPSI3IiBmaWxsPSIjRkZGRkZGIi8+Cjwvc3ZnPg==' alt='Avatar' />
    </div>
    <div class='announcement-content'>
        <div class='announcement-title'>{content}</div>
        <div class='announcement-time'>{postedBy} • {time}</div>
    </div>
</li>");
                    }
                }

                sb.Append("</ul>");
                _announcementHtml = sb.ToString();
            }
            catch (Exception ex)
            {
                _announcementHtml = $"<div style='color:red; padding:10px;'>Failed to load announcements: {Server.HtmlEncode(ex.Message)}</div>";
            }
        }
    }
}