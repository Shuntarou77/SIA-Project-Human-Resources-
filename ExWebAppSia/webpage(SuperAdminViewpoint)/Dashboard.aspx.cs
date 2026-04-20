using ExWebAppSia.Models;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace ExWebAppSia.webpage_SuperAdminViewpoint_
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string _announcementHtml = string.Empty;
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly LeaveService _leaveService = new LeaveService();
        private string _attendanceStatusJson = null;
        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private const int TOTAL_WORKING_DAYS_PER_YEAR = 260;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;

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
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatusAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadPersonalAttendanceStatisticsAsync));
            }
        }

        protected Employee CurrentEmployee => Session["Employee"] as Employee;

        protected string GetEmployeeName() => CurrentEmployee?.FullName ?? "N/A";
        protected string GetEmployeeId() => CurrentEmployee?.EmployeeId ?? "N/A";
        protected string GetEmployeeDepartment() => CurrentEmployee?.Department ?? "N/A";

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

                // Optimize: Only fetch attendance for the current year as that's all we display
                var currentYear = DateTime.Now.Year;
                var startDate = new DateTime(currentYear, 1, 1);
                _employeeAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId, startDate);
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
            var currentMonth = new DateTime(now.Year, now.Month, 1);

            var currentMonthRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime >= currentMonth && x.LocalTime < currentMonth.AddMonths(1))
                .ToList();

            var currentMonthPresent = currentMonthRecords.Select(x => x.LocalTime.Date).Distinct().Count();
            var pastWeekdays = Enumerable.Range(0, (today - currentMonth).Days + 1)
                .Select(i => currentMonth.AddDays(i))
                .Count(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);
            
            var currentMonthAbsent = Math.Max(0, pastWeekdays - currentMonthPresent);
            var currentMonthLate = currentMonthRecords.GroupBy(x => x.LocalTime.Date).Count(g => g.OrderBy(x => x.LocalTime).First().LocalTime.Hour >= 9);

            // Yearly stats
            var currentYear = now.Year;
            var yearlyRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.TimeIn.Value.ToLocalTime())
                .Where(t => t.Year == currentYear)
                .ToList();

            var yearStart = new DateTime(currentYear, 1, 1);
            var yearlyPresent = yearlyRecords.Select(t => t.Date).Distinct().Count();
            
            var pastYearWeekdays = Enumerable.Range(0, (today - yearStart).Days + 1)
                .Select(i => yearStart.AddDays(i))
                .Count(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);
            
            var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent);
            var remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);

            _attendanceStats = new Dictionary<string, object>
            {
                { "daysPresent", currentMonthPresent },
                { "daysAbsent", currentMonthAbsent },
                { "daysLate", currentMonthLate },
                { "remainingAbsences", remainingAbsences },
                { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR }
            };
        }

        private Dictionary<string, object> GetDefaultStats() => new Dictionary<string, object> 
        { 
            { "daysPresent", 0 }, 
            { "daysAbsent", 0 }, 
            { "daysLate", 0 }, 
            { "remainingAbsences", TOTAL_ALLOWED_ABSENCES_PER_YEAR },
            { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR }
        };

        public string GetDaysPresent() => _attendanceStats?["daysPresent"].ToString() ?? "0";
        public string GetDaysAbsent() => _attendanceStats?["daysAbsent"].ToString() ?? "0";
        public string GetDaysLate() => _attendanceStats?["daysLate"].ToString() ?? "0";
        public string GetRemainingAbsences() => _attendanceStats?["remainingAbsences"].ToString() ?? "0";
        public string GetTargetWorkingDays() => _attendanceStats?["targetWorkingDays"].ToString() ?? "0";

        private async Task LoadDashboardDataAsync()
        {
            try
            {
                // Core optimization: Pre-fetch employees to share across other calculations
                var employeesTask = _employeeService.GetAllEmployeesAsync();

                // Run data cleanup and automation tasks in parallel with the data loading 
                // instead of blocking sequentially at the start.
                var cleanupTask = Task.Run(async () => {
                   try {
                       await _employeeService.ProcessRegularizationAsync();
                       await _employeeService.FixProbationarySalariesAsync();
                       await _employeeService.FixMissingGendersAsync();
                   } catch { /* Background cleanup failures shouldn't crash dashboard */ }
                });

                // Load all specific dashboard datasets in parallel
                var applicantsTask = LoadApplicantData();
                var announcementsTask = LoadRecentAnnouncementsAsync();
                
                // Wait for employees first as it's a dependency for LoadEmployeeData and LoadAttendanceData
                var employees = await employeesTask;

                var empDataTask = LoadEmployeeData(employees);
                var attDataTask = LoadAttendanceData(employees);

                await Task.WhenAll(cleanupTask, applicantsTask, announcementsTask, empDataTask, attDataTask);
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
                // Filter out Executive department from dashboard counts as requested
                var countableEmployees = employees.Where(e => e.Department != "Executive").ToList();

                int totalEmployees = countableEmployees.Count;
                int femaleCount = countableEmployees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Female", StringComparison.OrdinalIgnoreCase));
                int maleCount = countableEmployees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
                    e.Gender.Equals("Male", StringComparison.OrdinalIgnoreCase));

                int contractualCount = countableEmployees.Count(e => !string.IsNullOrEmpty(e.ContractType) && e.ContractType.ToLower().Contains("contract") && e.IsActive && (e.ResignationStatus == "None" || string.IsNullOrEmpty(e.ResignationStatus)));
                int regularCount = countableEmployees.Count(e => e.EmploymentStatus == "Regular" && e.IsActive && !(e.ContractType != null && e.ContractType.ToLower().Contains("contract")) && (e.ResignationStatus == "None" || string.IsNullOrEmpty(e.ResignationStatus)));
                int probationaryCount = countableEmployees.Count(e => e.EmploymentStatus == "Probationary" && e.IsActive && !(e.ContractType != null && e.ContractType.ToLower().Contains("contract")) && (e.ResignationStatus == "None" || string.IsNullOrEmpty(e.ResignationStatus)));

                int activeTotal = regularCount + probationaryCount + contractualCount;

                double regularPercentage = activeTotal > 0 ? (regularCount * 100.0 / activeTotal) : 0;
                double probationaryPercentage = activeTotal > 0 ? (probationaryCount * 100.0 / activeTotal) : 0;
                double contractualPercentage = activeTotal > 0 ? (contractualCount * 100.0 / activeTotal) : 0;

                if (litTotalEmployees != null) litTotalEmployees.Text = totalEmployees.ToString();
                if (litFemaleCount != null) litFemaleCount.Text = femaleCount.ToString();
                if (litMaleCount != null) litMaleCount.Text = maleCount.ToString();
                
                if (litRegularPercentage != null) litRegularPercentage.Text = regularPercentage.ToString("F0");
                if (litRegularPercentageDisplay != null) litRegularPercentageDisplay.Text = $"{regularCount} ({regularPercentage:F0}%)";

                if (litProbationaryPercentage != null) litProbationaryPercentage.Text = probationaryPercentage.ToString("F0");
                if (litProbationaryPercentageDisplay != null) litProbationaryPercentageDisplay.Text = $"{probationaryCount} ({probationaryPercentage:F0}%)";
                
                if (litContractualPercentage != null) litContractualPercentage.Text = contractualPercentage.ToString("F0"); 
                if (litContractualPercentageDisplay != null) litContractualPercentageDisplay.Text = $"{contractualCount} ({contractualPercentage:F0}%)";
             
                // Headcount per Department (excluding Executive)
                var headcountData = countableEmployees
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
                
                var allAttendanceRecords = attendanceTask.Result;
                var attendanceRecords = allAttendanceRecords.Where(a => a.Department != "Executive").ToList();
                var leavesToday = leavesTask.Result;

                int totalActiveEmployees = allEmployees.Count(e => e.IsActive && e.Department != "Executive");
                int onLeaveCount = leavesToday.Count(l => l.Status == "Approved" && l.Department != "Executive");
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
                                <div class='announcement-date'>{postedBy} â€¢ {dateStr}</div>
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
