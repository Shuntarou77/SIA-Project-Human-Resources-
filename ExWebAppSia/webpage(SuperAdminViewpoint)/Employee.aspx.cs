using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;
using Newtonsoft.Json;
using MongoDB.Driver;
using MongoDB.Bson;

namespace ExWebAppSia.webpage_SuperAdminViewpoint_
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();
        private readonly ManagerService _managerService = new ManagerService();
        private const int MaxConcernsToDisplay = 10;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;
        private const int TOTAL_WORKING_DAYS_PER_YEAR = 260;

        protected string CurrentAdminId
        {
            get
            {
                var emp = Session["Employee"] as Employee;
                return emp?.EmployeeId;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Only load the full dataset on initial page load
                RegisterAsyncTask(new PageAsyncTask(LoadEmployeesData));
            }
        }

        private async Task LoadEmployeesData()
        {
            try
            {
                // Speed optimization: Start maintenance tasks and data fetching in parallel
                var scrubTask = Task.WhenAll(
                    _employeeService.FixProbationarySalariesAsync(),
                    _employeeService.FixGovContributionsAsync(),
                    _employeeService.FixMissingGovNumbersAsync(),
                    _employeeService.ProcessRegularizationAsync(),
                    _employeeService.MigrateLegacyResignedEmployeesAsync()
                );

                var employeesTask = _employeeService.GetAllEmployeesAsync();
                var resignedTask = _employeeService.GetAllResignedEmployeesAsync();
                var concernsTask = _concernService.GetAllConcernsAsync();
                var managersTask = _managerService.GetAllManagersAsync();

                // Wait for all data tasks to complete
                await Task.WhenAll(employeesTask, resignedTask, concernsTask, managersTask);

                var activeEmployees = employeesTask.Result ?? new List<Employee>();
                var resignedEmployees = resignedTask.Result ?? new List<Employee>();
                // Ensure resigned employees are marked inactive for the filter
                resignedEmployees.ForEach(e => { e.IsActive = false; });
                // Merge: active first, then resigned
                var allEmployees = activeEmployees.Concat(resignedEmployees).ToList();

                // --- NEW: Leave Detection Logic ---
                var leaveCol = MongoDBHelper.GetLeavesCollection();
                var todayDate = DateTime.UtcNow.AddHours(8).Date;
                var filter = Builders<Leave>.Filter.And(
                    Builders<Leave>.Filter.Eq(l => l.Status, "Approved"),
                    Builders<Leave>.Filter.Lte(l => l.StartDate, todayDate),
                    Builders<Leave>.Filter.Gte(l => l.EndDate, todayDate)
                );
                var leavesToday = await (await leaveCol.FindAsync(filter)).ToListAsync();
                var onLeaveIds = new HashSet<string>(activeEmployees.Where(e => e.AvailabilityStatus == "On Leave").Select(e => e.EmployeeId));
                foreach (var l in leavesToday) onLeaveIds.Add(l.EmployeeId);
                
                // Do not filter out executives so Super Admin can manage President's availability
                var employees = allEmployees.ToList();

                var concerns = concernsTask.Result ?? new List<EmployeeConcern>();
                var managers = managersTask.Result ?? new List<Manager>();

                // Derive department counts locally
                var departmentCounts = employees
                    .Where(e => e.IsActive && !string.IsNullOrEmpty(e.Department))
                    .GroupBy(e => e.Department)
                    .ToDictionary(g => g.Key, g => g.Count(), StringComparer.OrdinalIgnoreCase);

                UpdateDepartmentCounts(departmentCounts);
                PopulateEmployeeTable(employees, onLeaveIds);
                PopulateEmployeeConcerns(concerns, employees);

                // Speed optimization: Store ALL concerns in a hidden field for instant client-side history lookup
                hdnConcernsJson.Value = JsonConvert.SerializeObject(concerns);

                var hdnCurr = Master.FindControl("ContentPlaceHolder1").FindControl("hdnCurrentAdminId") as HiddenField;
                if (hdnCurr != null) hdnCurr.Value = CurrentAdminId;

                // Ensure maintenance tasks finish
                await scrubTask.ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employees: {ex.Message}");
            }
        }

        private void UpdateDepartmentCounts(Dictionary<string, int> counts)
        {
            // Update the literal controls for each department
            if (litRDCount != null) litRDCount.Text = GetCountByAliases(counts, "Research & Development", "R&D").ToString();
            if (litHRCount != null) litHRCount.Text = GetCountByAliases(counts, "Human Resources", "HR").ToString();
            if (litFinanceCount != null) litFinanceCount.Text = GetCountByAliases(counts, "Finance/Accounting", "Finance").ToString();
            if (litMarketingCount != null) litMarketingCount.Text = GetCountByAliases(counts, "Marketing").ToString();
            if (litOperationsCount != null) litOperationsCount.Text = GetCountByAliases(counts, "Operations").ToString();
            if (litInventoryCount != null) litInventoryCount.Text = GetCountByAliases(counts, "Inventory").ToString();
            if (litExecutiveCount != null) litExecutiveCount.Text = GetCountByAliases(counts, "Executive").ToString();
        }

        private int GetCountByAliases(Dictionary<string, int> counts, params string[] aliases)
        {
            if (counts == null || aliases == null) return 0;
            var total = 0;
            foreach (var alias in aliases)
            {
                if (string.IsNullOrWhiteSpace(alias)) continue;
                if (counts.TryGetValue(alias, out var value))
                {
                    total += value;
                }
            }
            return total;
        }

        /*
        private void UpdateDepartmentHeads(List<Manager> managers)
        {
            var literals = new Dictionary<string, Literal>(StringComparer.OrdinalIgnoreCase)
            {
                { "Research & Development", litRDManager },
                { "Quality Control", litQCManager },
                { "Human Resources", litHRManager },
                { "Finance", litFinanceManager },
                { "Marketing", litMarketingManager },
                { "IT Support", litITManager },
                { "Operations", litOperationsManager },
                { "Sales", litSalesManager },
                { "Inventory", litInventoryManager },
                { "Customer Service", litCustomerServiceManager }
            };

            var managerLookup = managers?
                .Where(m => m != null && m.IsActive && !string.IsNullOrEmpty(m.Department))
                .GroupBy(m => m.Department)
                .ToDictionary(g => g.Key, g => g.First().FullName, StringComparer.OrdinalIgnoreCase)
                ?? new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

            foreach (var kvp in literals)
            {
                if (kvp.Value == null) continue;

                string displayName;
                if (managerLookup.TryGetValue(kvp.Key, out displayName))
                {
                    kvp.Value.Text = Server.HtmlEncode(displayName);
                }
                else
                {
                    kvp.Value.Text = "Not assigned";
                }
            }
        }
        */

        private void PopulateEmployeeTable(List<Employee> employees, HashSet<string> onLeaveIds = null)
        {
            if (employeeTableBody == null) return;

            if (employees == null || employees.Count == 0)
            {
                employeeTableBody.InnerHtml = @"
                    <tr>
                        <td colspan='4' style='text-align: center; padding: 40px; color: #999;'>
                            No employees found.
                        </td>
                    </tr>";
                return;
            }

            if (onLeaveIds == null) onLeaveIds = new HashSet<string>();

            var sb = new StringBuilder();
            foreach (var employee in employees)
            {
                string id = HttpUtility.HtmlAttributeEncode(employee.Id);
                string empId = HttpUtility.HtmlAttributeEncode(employee.EmployeeId ?? "");
                string fname = HttpUtility.HtmlAttributeEncode(employee.FirstName ?? "");
                string mname = HttpUtility.HtmlAttributeEncode(employee.MiddleName ?? "");
                string lname = HttpUtility.HtmlAttributeEncode(employee.LastName ?? "");
                string email = HttpUtility.HtmlAttributeEncode(employee.Email ?? "");
                string contact = HttpUtility.HtmlAttributeEncode(employee.ContactNo ?? "");
                string address = HttpUtility.HtmlAttributeEncode(employee.Address ?? "");
                string dept = HttpUtility.HtmlAttributeEncode(employee.Department ?? "");
                string role = HttpUtility.HtmlAttributeEncode(employee.Role ?? "");
                string hired = employee.HiredDate.ToLocalTime().ToString("MMM dd, yyyy");
                string active = employee.IsActive ? "Active" : "Inactive";
                if (employee.IsActive && employee.AvailabilityStatus == "On Leave") active = "On Leave";
                
                string contract = HttpUtility.HtmlAttributeEncode(employee.ContractType ?? "Regular");
                
                string salary = employee.BaseSalary.ToString("N2");
                
                bool isOnLeave = employee.IsActive && (employee.AvailabilityStatus == "On Leave" || onLeaveIds.Contains(employee.EmployeeId));
                
                string sText = employee.IsActive ? "Active" : "Resigned";
                if (employee.ResignationStatus == "Pending") sText = "Pending Resignation";
                if (isOnLeave) sText = "On Leave";
                
                sb.AppendFormat("<tr class='employee-row' onclick=\"viewEmployeeDetails(this)\" style='cursor: pointer;' " +
                                "data-id='{0}' data-emp-id='{1}' data-fname='{2}' data-mname='{3}' data-lname='{4}' " +
                                "data-email='{5}' data-contact='{6}' data-address='{7}' data-dept='{8}' data-role='{9}' " +
                                "data-hired='{10}' data-active='{11}' data-sss='{12}' data-ph='{13}' data-pi='{14}' data-salary='{15}' data-contract='{16}' " +
                                "data-sss-num='{17}' data-ph-num='{18}' data-pi-num='{19}' data-resignation-status='{20}' data-availability='{21}'>",
                    id, empId, fname, mname, lname, email, contact, address, dept, role, 
                    hired, sText, 
                    employee.HasSSS.ToString().ToLower(), 
                    employee.HasPhilHealth.ToString().ToLower(), 
                    employee.HasPagIbig.ToString().ToLower(),
                    salary,
                    contract,
                    HttpUtility.HtmlAttributeEncode(employee.SSSNumber ?? ""),
                    HttpUtility.HtmlAttributeEncode(employee.PhilHealthNumber ?? ""),
                    HttpUtility.HtmlAttributeEncode(employee.PagIbigNumber ?? ""),
                    HttpUtility.HtmlAttributeEncode(employee.ResignationStatus ?? "None"),
                    HttpUtility.HtmlAttributeEncode(employee.AvailabilityStatus ?? "Available"));
                
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.EmployeeId));
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.FullName));
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.Department ?? ""));
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.Role ?? ""));
                
                string sClass = sText == "Active" ? "status-active-emp" : 
                               sText == "On Leave" ? "status-on-leave" :
                               sText == "Pending Resignation" ? "status-pending-res" : "status-inactive";
                
                sb.AppendFormat("<td><span class='{0}'>{1}</span></td>", sClass, sText);
                sb.Append("</tr>");
            }

            employeeTableBody.InnerHtml = sb.ToString();
        }

        private void PopulateEmployeeConcerns(List<EmployeeConcern> concerns, List<Employee> employees)
        {
            if (litConcerns == null)
            {
                return;
            }

            if (concerns == null || concerns.Count == 0)
            {
                litConcerns.Text = @"
                    <div class='concern-card'>
                        <div class='concern-text' style='text-align:center; color:#999;'>
                            No employee concerns submitted yet.
                        </div>
                    </div>";
                return;
            }

            var employeeLookup = employees?
                .Where(e => !string.IsNullOrEmpty(e.EmployeeId))
                .GroupBy(e => e.EmployeeId)
                .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase)
                ?? new Dictionary<string, Employee>(StringComparer.OrdinalIgnoreCase);

            var sb = new StringBuilder();

            foreach (var concern in concerns
                .OrderByDescending(c => c.SubmittedDate)
                .Take(MaxConcernsToDisplay))
            {
                Employee employeeMatch = null;
                if (!string.IsNullOrEmpty(concern.EmployeeId))
                {
                    employeeLookup.TryGetValue(concern.EmployeeId, out employeeMatch);
                }

                var employeeName = ResolveEmployeeName(concern.EmployeeId, employeeLookup);
                var initials = GetInitials(employeeName);
                var subject = Server.HtmlEncode(concern.Subject ?? "Employee Concern");
                var description = Server.HtmlEncode(BuildConcernExcerpt(concern.Description));
                var concernType = Server.HtmlEncode(concern.ConcernType ?? "Employee");
                var submitted = concern.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt");

                string onclick = employeeMatch != null 
                    ? string.Format("onclick=\"openConcernHistoryModal('{0}')\"", HttpUtility.HtmlAttributeEncode(employeeMatch.Id))
                    : "";

                sb.AppendFormat("<div class='concern-card' {0}>", onclick);
                sb.Append("<div class='concern-header-row'>");
                sb.AppendFormat("<div class='concern-avatar concern-initials'>{0}</div>", initials);
                sb.Append("<div>");
                sb.AppendFormat("<div class='concern-title'>{0}</div>", Server.HtmlEncode(employeeName));
                sb.AppendFormat("<div class='concern-role'>{0}</div>", concernType);
                sb.Append("</div>");
                sb.Append("</div>");
                sb.Append("<div class='concern-text'>");
                sb.AppendFormat("<strong>{0}</strong><br/>", subject);
                sb.Append(description);
                sb.Append("</div>");
                sb.AppendFormat("<div style='margin-top:10px; font-size:10px; color:#999;'>{0}</div>",
                    submitted);
                sb.Append("</div>");
            }

            litConcerns.Text = sb.ToString();
        }

        private static string ResolveEmployeeName(string employeeId, Dictionary<string, Employee> employeeLookup)
        {
            if (!string.IsNullOrEmpty(employeeId) &&
                employeeLookup.TryGetValue(employeeId, out var employee) &&
                employee != null)
            {
                return employee.FullName;
            }

            if (!string.IsNullOrEmpty(employeeId))
            {
                return employeeId;
            }

            return "Employee";
        }

        // ========== AJAX WEB METHODS ==========

        /// <summary>
        /// Get employee details as HTML via AJAX
        /// </summary>
        [System.Web.Services.WebMethod]
        public static string GetEmployeeDetails(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                var attendanceService = new AttendanceService();
                var employee = employeeService.GetEmployeeByIdAsync(id).ConfigureAwait(false).GetAwaiter().GetResult();

                if (employee == null) return "Employee not found.";

                // Re-use logic to build HTML but in a static context
                var sb = new StringBuilder();
                sb.Append("<div style='padding: 20px;'>");
                
                // Personal Info
                sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Personal Information</h3>");
                sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Employee ID:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.EmployeeId ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>First Name:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.FirstName ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Middle Name:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.MiddleName ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Last Name:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.LastName ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Email Address:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.Email ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contact No.:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.ContactNo ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Address:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.Address ?? ""));
                sb.Append("</table>");

                // Employment Info
                sb.Append("<h3 style='color: #8B4755; margin: 20px 0 15px 0; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Employment Information</h3>");
                sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Department:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.Department ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Role:</td><td style='padding: 8px;'>{0}</td></tr>", HttpUtility.HtmlEncode(employee.Role ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Hired Date:</td><td style='padding: 8px;'>{0}</td></tr>", employee.HiredDate.ToLocalTime().ToString("MMM dd, yyyy"));
                string activeStatus = employee.IsActive ? "Active" : "Inactive";
                if (employee.IsActive && employee.AvailabilityStatus == "On Leave") activeStatus = "On Leave";
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Status:</td><td style='padding: 8px;'>{0}</td></tr>", activeStatus);
                
                // PRESIDENT AVAILABILITY DISPLAY
                if (employee.Department == "Executive" || employee.Role == "President")
                {
                    string availStatus = employee.AvailabilityStatus ?? "Available";
                    string availColor = availStatus == "Available" ? "#10b981" : "#ef4444";
                    sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Presence Status:</td><td style='padding: 8px;'><span class='status-badge' style='background:{0}; color:white; padding:4px 12px; border-radius:12px;'>{1}</span></td></tr>", availColor, availStatus);
                }
                
                // Gov Contributions
                string checkIcon = "<i class='fas fa-check-circle' style='color: #22c55e; margin-right: 4px;'></i>";
                string xIcon = "<i class='fas fa-times-circle' style='color: #94a3b8; margin-right: 4px;'></i>";

                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Govt. Contributions:</td><td style='padding: 8px;'>");
                sb.AppendFormat("<span style='margin-right: 15px;'>{0} SSS</span>", employee.HasSSS ? checkIcon : xIcon);
                sb.AppendFormat("<span style='margin-right: 15px;'>{0} PhilHealth</span>", employee.HasPhilHealth ? checkIcon : xIcon);
                sb.AppendFormat("<span>{0} Pag-IBIG</span>", employee.HasPagIbig ? checkIcon : xIcon);
                sb.Append("</td></tr>");

                // Absence Allowance (Remaining Days)
                var attendanceRecords = attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId).GetAwaiter().GetResult();
                var leaveService = new LeaveService();
                var employeeLeaves = leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId).GetAwaiter().GetResult();
                var approvedLeaves = employeeLeaves?.Where(l => l.Status == "Approved").ToList() ?? new List<Leave>();

                var now = DateTime.Now;
                var currentYear = now.Year;
                var today = now.Date;
                var hiredDate = employee.HiredDate.ToLocalTime().Date;
                var yearStart = new DateTime(currentYear, 1, 1);
                var yearlyStatsStart = hiredDate > yearStart ? hiredDate : yearStart;

                var yearlyRecords = attendanceRecords?
                    .Where(a => a.TimeIn.HasValue)
                    .Select(a => a.TimeIn.Value.ToLocalTime())
                    .Where(t => t.Year == currentYear)
                    .ToList() ?? new List<DateTime>();

                var yearlyPresent = yearlyRecords.Select(t => t.Date).Distinct().Count();

                int pastYearWeekdays = 0;
                if (yearlyStatsStart <= today)
                {
                    pastYearWeekdays = Enumerable.Range(0, (today - yearlyStatsStart).Days + 1)
                        .Select(i => yearlyStatsStart.AddDays(i))
                        .Count(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);
                }

                int yearlyLeaveDays = 0;
                foreach (var leave in approvedLeaves)
                {
                    for (var d = leave.StartDate.ToLocalTime().Date; d <= leave.EndDate.ToLocalTime().Date; d = d.AddDays(1))
                    {
                        if (d.Year == currentYear && d >= yearlyStatsStart && d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday)
                        {
                            yearlyLeaveDays++;
                        }
                    }
                }
                
                var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent - yearlyLeaveDays);
                var remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);

                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Absence Allowance:</td><td style='padding: 8px;'><span style='color: #8B4755; font-weight: bold;'>{0} Days Remaining</span> <span style='color: #64748b; font-size: 11px;'>(Out of {1} allowed/year)</span></td></tr>", 
                    remainingAbsences, TOTAL_ALLOWED_ABSENCES_PER_YEAR);
                
                sb.Append("</table>");
                sb.Append("</div>");

                // Action Cards
                sb.Append("<div class='actions-grid'>");
                sb.Append("<div class='action-card' onclick='openPayslipModal()'>");
                sb.Append("<div class='action-icon'>ðŸ’°</div>");
                sb.Append("<h3 class='action-title'>View Payslip</h3>");
                sb.Append("<p class='action-description'>View your salary breakdown including gross salary, deductions, and net pay.</p>");
                sb.Append("<button class='action-button'>View Details</button>");
                sb.Append("</div>");

                sb.AppendFormat("<div class='action-card' onclick='openLeaveHistoryModal(\"{0}\")'>", HttpUtility.HtmlEncode(employee.Id));
                sb.Append("<div class='action-icon'>ðŸ“</div>");
                sb.Append("<h3 class='action-title'>History of Requests</h3>");
                sb.Append("<p class='action-description'>View OT, UT, Leave, and Loan request history for this employee.</p>");
                sb.Append("<button class='action-button'>View Requests</button>");
                sb.Append("</div>");

                sb.AppendFormat("<div class='action-card' onclick='openCreateLoanModal(\"{0}\", \"{1}\")'>", HttpUtility.HtmlEncode(employee.EmployeeId ?? employee.Id), HttpUtility.HtmlEncode(employee.FirstName + " " + employee.LastName));
                sb.Append("<div class='action-icon'>💵</div>");
                sb.Append("<h3 class='action-title'>Create Loan</h3>");
                sb.Append("<p class='action-description'>Create a loan request record for this employee.</p>");
                sb.Append("<button class='action-button' style='background: #8B4755;'>Create Record</button>");
                sb.Append("</div>");

                // New Action Cards: Resigned, Rehired, Deploy
                if (employee.IsActive)
                {
                    sb.AppendFormat("<div class='action-card' onclick='resignEmployee(\"{0}\")'>", HttpUtility.HtmlEncode(employee.Id));
                    sb.Append("<div class='action-icon'>ðŸ‘‹</div>");
                    sb.Append("<h3 class='action-title'>Resigned</h3>");
                    sb.Append("<p class='action-description'>Mark this employee as resigned and deactivate their account.</p>");
                    sb.Append("<button class='action-button' style='background: #ef4444;'>Process Resignation</button>");
                    sb.Append("</div>");

                    // Mark as On Leave Toggle
                    bool isOnLeave = (employee.AvailabilityStatus ?? "Available") == "On Leave";
                    string leaveBtnText = isOnLeave ? "Return from Leave" : "Mark as On Leave";
                    string leaveAction = isOnLeave ? "Available" : "On Leave";
                    string leaveIcon = isOnLeave ? "âœˆï¸ " : "ðŸš«";
                    
                    sb.AppendFormat("<div class='action-card' onclick='toggleOnLeave(\"{0}\", \"{1}\")'>", HttpUtility.HtmlEncode(employee.Id), leaveAction);
                    sb.AppendFormat("<div class='action-icon' style='background: #0ea5e9;'>{0}</div>", leaveIcon);
                    sb.AppendFormat("<h3 class='action-title'>{0}</h3>", leaveBtnText);
                    sb.AppendFormat("<p class='action-description'>{0}</p>", isOnLeave ? "Set employee back to active duty." : "Temporary status for employees on vacation or approved leave.");
                    sb.AppendFormat("<button class='action-button' style='background: #0ea5e9;'>{0}</button>", isOnLeave ? "Mark Active" : "Mark On Leave");
                    sb.Append("</div>");

                    // Toggle Availability for Executive
                    if (employee.Department == "Executive" || employee.Role == "President")
                    {
                        bool isAvail = (employee.AvailabilityStatus ?? "Available") == "Available";
                        string btnText = isAvail ? "Set as Unavailable" : "Set as Available";
                        string btnColor = isAvail ? "#ef4444" : "#10b981";
                        string nextStatus = isAvail ? "Unavailable" : "Available";

                        sb.AppendFormat("<div class='action-card' onclick='toggleAvailability(\"{0}\", \"{1}\")'>", HttpUtility.HtmlEncode(employee.Id), nextStatus);
                        sb.AppendFormat("<div class='action-icon' style='background:{0};'>â³</div>", btnColor);
                        sb.AppendFormat("<h3 class='action-title'>{0}</h3>", isAvail ? "President Away" : "President Returns");
                        sb.AppendFormat("<p class='action-description'>Toggle the President's visibility. Current: <strong>{0}</strong>.</p>", employee.AvailabilityStatus ?? "Available");
                        sb.AppendFormat("<button class='action-button' style='background:{0};'>{1}</button>", btnColor, btnText);
                        sb.Append("</div>");
                    }
                }
                else
                {
                    sb.AppendFormat("<div class='action-card' onclick='rehireEmployee(\"{0}\")'>", HttpUtility.HtmlEncode(employee.Id));
                    sb.Append("<div class='action-icon'>ðŸ¤</div>");
                    sb.Append("<h3 class='action-title'>Rehired</h3>");
                    sb.Append("<p class='action-description'>Reactivate this employee's account for active duty.</p>");
                    sb.Append("<button class='action-button' style='background: #10b981;'>Process Rehire</button>");
                    sb.Append("</div>");
                }

                sb.Append("</div>");

                return sb.ToString();
            }
            catch (Exception ex)
            {
                return "Error loading details: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string GetLeaveHistory(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                var employee = employeeService.GetEmployeeByIdAsync(id).ConfigureAwait(false).GetAwaiter().GetResult();
                
                if (employee == null) return "<div style='padding: 20px;'>Employee not found.</div>";

                var leaveService = new LeaveService();
                var leaves = leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId).ConfigureAwait(false).GetAwaiter().GetResult();
                
                var sb = new StringBuilder();
                sb.Append("<div style='padding: 20px;'>");

                if (leaves == null || leaves.Count == 0)
                {
                    sb.Append("<div style='text-align: center; padding: 40px; color: #999;'>");
                    sb.Append("<p style='font-size: 16px;'>No leave records found for this employee.</p>");
                    sb.Append("</div>");
                }
                else
                {
                    sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Leave History</h3>");
                    foreach (var leave in leaves)
                    {
                        string statusColor = leave.Status == "Approved" ? "#10b981" : 
                                            leave.Status == "Rejected" ? "#ef4444" : "#f59e0b";
                        
                        sb.Append("<div style='background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid " + statusColor + ";'>");
                        sb.Append("<div style='display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;'>");
                        sb.AppendFormat("<div><strong style='color: #333; font-size: 16px;'>{0}</strong></div>", HttpUtility.HtmlEncode(leave.LeaveType ?? ""));
                        sb.AppendFormat("<span style='background: {0}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;'>{1}</span>", statusColor, HttpUtility.HtmlEncode(leave.Status ?? ""));
                        sb.Append("</div>");
                        sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Period:</strong> {0} to {1}</div>", 
                            leave.StartDate.ToLocalTime().ToString("MMM dd, yyyy"), 
                            leave.EndDate.ToLocalTime().ToString("MMM dd, yyyy"));
                        sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Reason:</strong> {0}</div>", HttpUtility.HtmlEncode(leave.Reason ?? ""));
                        sb.AppendFormat("<div style='color: #999; font-size: 12px;'><strong>Submitted:</strong> {0}</div>", leave.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
                        sb.Append("</div>");
                    }
                }
                sb.Append("</div>");
                return sb.ToString();
            }
            catch (Exception ex) { return "Error loading leave history: " + ex.Message; }
        }

        [System.Web.Services.WebMethod]
        public static string GetRequestHistory(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                var employee = employeeService.GetEmployeeByIdAsync(id).ConfigureAwait(false).GetAwaiter().GetResult();
                if (employee == null) return "<div style='padding: 20px;'>Employee not found.</div>";

                var leaveService = new LeaveService();
                var undertimeService = new UndertimeService();
                var overtimeService = new OvertimeService();
                var loanService = new LoanService();

                var items = new System.Collections.Generic.List<dynamic>();

                var leaves = leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId).ConfigureAwait(false).GetAwaiter().GetResult();
                foreach (var leave in leaves ?? new System.Collections.Generic.List<Leave>())
                {
                    items.Add(new
                    {
                        Type = "Leave",
                        Summary = $"{leave.LeaveType} ({leave.StartDate:MMM dd, yyyy} - {leave.EndDate:MMM dd, yyyy})",
                        Status = leave.Status ?? "Pending",
                        Date = leave.SubmittedDate,
                        Reason = leave.Reason ?? ""
                    });
                }

                var ots = overtimeService.GetRecentRequestsByEmployeeIdAsync(employee.EmployeeId, 100).ConfigureAwait(false).GetAwaiter().GetResult();
                foreach (var ot in (ots ?? new System.Collections.Generic.List<OvertimeRequest>()))
                {
                    items.Add(new
                    {
                        Type = "OT",
                        Summary = $"Overtime ({ot.Date:MMM dd, yyyy}) - {ot.RequestedHours} hr(s)",
                        Status = ot.Status ?? "Pending",
                        Date = ot.RequestedAt,
                        Reason = ot.Reason ?? ""
                    });
                }

                var uts = undertimeService.GetRecentRequestsByEmployeeIdAsync(employee.EmployeeId, 100).ConfigureAwait(false).GetAwaiter().GetResult();
                foreach (var ut in (uts ?? new System.Collections.Generic.List<UndertimeRequest>()))
                {
                    items.Add(new
                    {
                        Type = "UT",
                        Summary = $"Undertime ({ut.Date:MMM dd, yyyy})",
                        Status = ut.Status ?? "Pending",
                        Date = ut.RequestedAt,
                        Reason = ut.Reason ?? ""
                    });
                }

                var loans = loanService.GetRecentLoansByEmployeeIdAsync(employee.EmployeeId, 100).ConfigureAwait(false).GetAwaiter().GetResult();
                foreach (var loan in loans ?? new System.Collections.Generic.List<LoanRequest>())
                {
                    items.Add(new
                    {
                        Type = "Loan",
                        Summary = $"{loan.Agency} - {loan.LoanType}",
                        Status = loan.Status ?? "PENDING",
                        Date = loan.RequestDate,
                        Reason = loan.Remarks ?? ""
                    });
                }

                var sorted = items
                    .OrderByDescending(x => x.Date is DateTime dt ? dt : DateTime.MinValue)
                    .ToList();

                var sb = new StringBuilder();
                sb.Append("<div style='padding: 20px;'>");
                sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Request History</h3>");

                if (sorted.Count == 0)
                {
                    sb.Append("<div style='text-align:center; padding:40px; color:#9ca3af;'>No request history found.</div>");
                    sb.Append("</div>");
                    return sb.ToString();
                }

                sb.Append("<div style='overflow:auto;'>");
                sb.Append("<table style='width:100%; border-collapse: collapse;'>");
                sb.Append("<thead><tr style='background:#f8fafc;'>");
                sb.Append("<th style='text-align:left; padding:12px; font-size:12px; color:#64748b;'>TYPE</th>");
                sb.Append("<th style='text-align:left; padding:12px; font-size:12px; color:#64748b;'>SUMMARY</th>");
                sb.Append("<th style='text-align:left; padding:12px; font-size:12px; color:#64748b;'>STATUS</th>");
                sb.Append("<th style='text-align:left; padding:12px; font-size:12px; color:#64748b;'>DATE</th>");
                sb.Append("<th style='text-align:left; padding:12px; font-size:12px; color:#64748b;'>REASON / REMARKS</th>");
                sb.Append("</tr></thead><tbody>");

                foreach (var it in sorted.Take(100))
                {
                    string status = (it.Status ?? "").ToString();
                    string statusLower = status.ToLowerInvariant();
                    string badgeBg = statusLower.Contains("approve") ? "#10b981" :
                                     statusLower.Contains("decline") || statusLower.Contains("reject") ? "#ef4444" :
                                     statusLower.Contains("pending") ? "#f59e0b" :
                                     "#64748b";
                    string dateStr = "";
                    try { dateStr = ((DateTime)it.Date).ToLocalTime().ToString("MMM dd, yyyy"); } catch { }

                    sb.Append("<tr style='border-bottom:1px solid #f1f5f9;'>");
                    sb.AppendFormat("<td style='padding:12px; font-weight:800; color:#334155;'>{0}</td>", HttpUtility.HtmlEncode((it.Type ?? "").ToString()));
                    sb.AppendFormat("<td style='padding:12px; color:#334155;'>{0}</td>", HttpUtility.HtmlEncode((it.Summary ?? "").ToString()));
                    sb.AppendFormat("<td style='padding:12px;'><span style='background:{0}; color:white; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:800;'>{1}</span></td>",
                        badgeBg, HttpUtility.HtmlEncode(status));
                    sb.AppendFormat("<td style='padding:12px; color:#64748b;'>{0}</td>", HttpUtility.HtmlEncode(dateStr));
                    sb.AppendFormat("<td style='padding:12px; color:#475569;'>{0}</td>", HttpUtility.HtmlEncode((it.Reason ?? "").ToString()));
                    sb.Append("</tr>");
                }

                sb.Append("</tbody></table></div></div>");
                return sb.ToString();
            }
            catch (Exception ex)
            {
                return "<div style='padding: 20px; color:#dc2626;'>Error loading request history: " + HttpUtility.HtmlEncode(ex.Message) + "</div>";
            }
        }

        [System.Web.Services.WebMethod]
        public static string GetConcernHistory(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                var employee = employeeService.GetEmployeeByIdAsync(id).ConfigureAwait(false).GetAwaiter().GetResult();
                
                if (employee == null) return "<div style='padding: 20px;'>Employee not found.</div>";

                var concernService = new EmployeeConcernService();
                var concerns = concernService.GetConcernsByEmployeeIdAsync(employee.EmployeeId).ConfigureAwait(false).GetAwaiter().GetResult();
                
                var sb = new StringBuilder();
                sb.Append("<div style='padding: 20px;'>");

                if (concerns == null || concerns.Count == 0)
                {
                    sb.Append("<div style='text-align: center; padding: 40px; color: #999;'>");
                    sb.Append("<p style='font-size: 16px;'>No concern records found for this employee.</p>");
                    sb.Append("</div>");
                }
                else
                {
                    sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Concern History</h3>");
                    foreach (var concern in concerns)
                    {
                        string statusColor = concern.Status == "Resolved" ? "#10b981" : 
                                            concern.Status == "Closed" ? "#6b7280" : 
                                            concern.Status == "In Progress" ? "#3b82f6" : "#f59e0b"; // Submitted
                        
                        sb.Append("<div style='background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid #f0f0f0;'>");
                        sb.Append("<div style='display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;'>");
                        sb.AppendFormat("<div><strong style='color: #333; font-size: 16px;'>{0}</strong></div>", HttpUtility.HtmlEncode(concern.Subject ?? ""));
                        sb.Append("<div style='display: flex; gap: 8px; flex-wrap: wrap;'>");
                        sb.AppendFormat("<span style='background: {0}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;'>{1}</span>", statusColor, HttpUtility.HtmlEncode(concern.Status ?? ""));
                        sb.Append("</div></div>");
                        sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Type:</strong> {0}</div>", HttpUtility.HtmlEncode(concern.ConcernType ?? ""));
                        sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Description:</strong> {0}</div>", HttpUtility.HtmlEncode(concern.Description ?? ""));
                        sb.AppendFormat("<div style='color: #999; font-size: 12px;'><strong>Submitted:</strong> {0}</div>", concern.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
                        sb.Append("</div>");
                    }
                }
                sb.Append("</div>");
                return sb.ToString();
            }
            catch (Exception ex) { return "Error loading concern history: " + ex.Message; }
        }


        [System.Web.Services.WebMethod]
        public static string ResignEmployee(string id)
        {
            System.Diagnostics.Debug.WriteLine("==============================================");
            System.Diagnostics.Debug.WriteLine("[ResignEmployee] WebMethod CALLED");
            System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Received ID: '{id}'");
            System.Diagnostics.Debug.WriteLine("==============================================");

            try
            {
                if (string.IsNullOrEmpty(id))
                {
                    System.Diagnostics.Debug.WriteLine("[ResignEmployee] ERROR: ID is null or empty!");
                    return "{\"success\":false,\"message\":\"Employee ID is missing.\"}";
                }

                var employeeService = new EmployeeService();
                var emailService = new EmailService();

                // Use Task.Run to avoid deadlock on Async="true" page
                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Step 1: Looking up employee with ID: {id}");
                var employee = Task.Run(() => employeeService.GetEmployeeByIdAsync(id)).GetAwaiter().GetResult();

                if (employee == null)
                {
                    System.Diagnostics.Debug.WriteLine($"[ResignEmployee] ERROR: No employee found for ID: {id}");
                    return "{\"success\":false,\"message\":\"Employee not found.\"}";
                }

                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Employee found: {employee.FullName}, IsActive: {employee.IsActive}");

                string toEmail = employee.Email;
                string fullName = (employee.FullName ?? "").Replace("\"", "'");

                System.Diagnostics.Debug.WriteLine("[ResignEmployee] Step 2: Calling ResignEmployeeAsync...");
                bool success = Task.Run(() => employeeService.ResignEmployeeAsync(id)).GetAwaiter().GetResult();
                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] ResignEmployeeAsync result: {success}");

                if (success)
                {
                    System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Step 3: Sending email to {toEmail}...");
                    try { 
                        System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                            Task.Run(() => emailService.SendAccountStatusEmailAsync(toEmail, fullName, "Resignation Approved"))
                        ); 
                    }
                    catch (Exception emailEx) { System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Email error: {emailEx.Message}"); }

                    System.Diagnostics.Debug.WriteLine("[ResignEmployee] SUCCESS");
                    LogActivity("Resigned Employee", $"Resigned {fullName} ({id})");
                    return "{\"success\":true,\"message\":\"Employee resigned successfully.\"}";
                }

                System.Diagnostics.Debug.WriteLine("[ResignEmployee] FAILED - ResignEmployeeAsync returned false.");
                return "{\"success\":false,\"message\":\"Failed to process resignation.\"}";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("==============================================");
                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] EXCEPTION: {ex.GetType().FullName}");
                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] Message: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[ResignEmployee] StackTrace: {ex.StackTrace}");
                if (ex.InnerException != null)
                    System.Diagnostics.Debug.WriteLine($"[ResignEmployee] InnerException: {ex.InnerException.Message}");
                System.Diagnostics.Debug.WriteLine("==============================================");

                string msg = (ex.Message ?? "Unknown error").Replace("\"", "'");
                return "{\"success\":false,\"message\":\"" + msg + "\"}";
            }
        }

        [System.Web.Services.WebMethod]
        public static string ToggleEmployeeLeaveStatus(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                var employee = Task.Run(() => employeeService.GetEmployeeByIdAsync(id)).GetAwaiter().GetResult();
                if (employee == null) return "{\"success\":false,\"message\":\"Employee not found.\"}";

                string newStatus = employee.AvailabilityStatus == "On Leave" ? "Available" : "On Leave";
                var update = Builders<Employee>.Filter.Eq(e => e.Id, id);
                var updateDef = Builders<Employee>.Update.Set(e => e.AvailabilityStatus, newStatus);
                
                var collection = MongoDBHelper.GetEmployeesCollection();
                collection.UpdateOne(update, updateDef);
                
                LogActivity("Updated Status", $"Changed {employee.FullName} status to {newStatus}");
                return "{\"success\":true,\"message\":\"Employee marked as " + newStatus + ".\"}";
            }
            catch (Exception ex)
            {
                return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        [System.Web.Services.WebMethod]
        public static string ToggleAvailability(string id, string status)
        {
            try
            {
                var collection = MongoDBHelper.GetEmployeesCollection();
                var update = Builders<Employee>.Update.Set(e => e.AvailabilityStatus, status);
                collection.UpdateOne(Builders<Employee>.Filter.Eq(e => e.Id, id), update);
                
                var employeeService = new EmployeeService();
                var employee = Task.Run(() => employeeService.GetEmployeeByIdAsync(id)).GetAwaiter().GetResult();
                LogActivity("Updated Availability", $"Changed {employee?.FullName ?? id} availability to {status}");
                
                return "{\"success\":true,\"message\":\"Status updated to " + status + ".\"}";
            }
            catch (Exception ex)
            {
                return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        private static void LogActivity(string action, string targetInfo)
        {
            try
            {
                var context = System.Web.HttpContext.Current;
                if (context != null && context.Session != null)
                {
                    string username = context.Session["Username"] as string ?? "Unknown HR";
                    string hrName = "Admin";
                    var emp = context.Session["Employee"] as Employee;
                    if (emp != null) hrName = emp.FullName;

                    var logService = new ActivityLogService();
                    System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                        Task.Run(() => logService.LogActionAsync(username, hrName, action, "Employee Management", targetInfo))
                    );
                }
            }
            catch { /* Ignore logging errors to prevent breaking core functions */ }
        }

        [System.Web.Services.WebMethod]
        public static string RehireEmployee(string id)
        {
            try
            {
                var employeeService = new EmployeeService();
                bool success = employeeService.RehireEmployeeAsync(id).ConfigureAwait(false).GetAwaiter().GetResult();
                if (success) LogActivity("Rehired Employee", $"Reactivated employee ID: {id}");
                return success
                    ? "{\"success\":true,\"message\":\"Employee rehired successfully.\"}"
                    : "{\"success\":false,\"message\":\"Failed to process rehire.\"}";
            }
            catch (Exception ex)
            {
                string msg = (ex.Message ?? "Unknown error").Replace("\"", "'");
                return "{\"success\":false,\"message\":\"" + msg + "\"}";
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeployEmployee(string id, string department)
        {
            try
            {
                var employeeService = new EmployeeService();
                bool success = employeeService.UpdateEmployeeDepartmentAsync(id, department).ConfigureAwait(false).GetAwaiter().GetResult();
                string dept = (department ?? "").Replace("\"", "'");
                if (success) LogActivity("Deployed Employee", $"Transferred employee {id} to {dept}");
                return success
                    ? "{\"success\":true,\"message\":\"Employee deployed to " + dept + " successfully.\"}"
                    : "{\"success\":false,\"message\":\"Failed to deploy employee.\"}";
            }
            catch (Exception ex)
            {
                string msg = (ex.Message ?? "Unknown error").Replace("\"", "'");
                return "{\"success\":false,\"message\":\"" + msg + "\"}";
            }
        }

        [System.Web.Services.WebMethod]
        public static string GetLatestPayslip(string fullName, string employeeNumber = "")
        {
            try
            {
                var collection = MongoDBHelper.GetPayrollSnapshotsCollection();
                
                FilterDefinition<PayrollSnapshot> filter;
                
                // CRITICAL FIX: Use a very permissive contains-match to handle messy data like "26-2282,"
                if (!string.IsNullOrEmpty(employeeNumber))
                {
                    string cleanNum = employeeNumber.Trim();
                    // Match IF the DB field contains this ID OR if the ID contains the DB field
                    filter = Builders<PayrollSnapshot>.Filter.Or(
                        Builders<PayrollSnapshot>.Filter.Regex(p => p.EmployeeNumber, new BsonRegularExpression(cleanNum, "i")),
                        Builders<PayrollSnapshot>.Filter.Regex(p => p.FullName, new BsonRegularExpression(fullName.Trim().Split(',')[0], "i"))
                    );
                }
                else
                {
                    // Fallback to name search - be very lenient
                    filter = Builders<PayrollSnapshot>.Filter.Regex(p => p.FullName, new BsonRegularExpression(fullName.Trim().Split(',')[0], "i"));
                }
                
                var latest = collection.Find(filter)
                    .SortByDescending(p => p.PayPeriodEnd)
                    .FirstOrDefault();

                if (latest == null)
                {
                    string debugInfo = $"Searched for ID: '{employeeNumber}' and Name: '{fullName}' in 'sia_payroll_db.PayrollSnapshots'.";
                    return JsonConvert.SerializeObject(new { success = false, message = debugInfo });
                }

                return JsonConvert.SerializeObject(new
                {
                    success = true,
                    basicSalary = latest.BasicSalary,
                    allowances = latest.HousingAllowance + latest.TransportAllowance + latest.MealAllowance + latest.OtherAllowances,
                    overtimePay = latest.TotalOvertime,
                    totalGross = latest.GrossPay,
                    sss = latest.SSSDeduction,
                    philHealth = latest.PhilHealthDeduction,
                    pagIbig = latest.PagIbigDeduction,
                    withholdingTax = latest.WithholdingTax,
                    absenceDeduction = latest.AbsenceDeduction,
                    penalties = latest.TotalPenalties,
                    totalDeductions = latest.TotalDeductions,
                    netSalary = latest.NetPay,
                    payPeriod = latest.PayPeriodStart.ToString("MMMM dd, yyyy") + " - " + latest.PayPeriodEnd.ToString("MMMM dd, yyyy")
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = "Error: " + ex.Message });
            }
        }

        private string FormatGovNumber(string number, string type)
        {
            if (string.IsNullOrEmpty(number)) return "Not Set";
            
            // Remove any existing hyphens/spaces to reformat cleanly
            string clean = new string(number.Where(char.IsDigit).ToArray());
            
            try
            {
                if (type == "SSS")
                {
                    // Official format: 00-0000000-0 (10 digits)
                    if (clean.Length == 10)
                        return $"{clean.Substring(0, 2)}-{clean.Substring(2, 7)}-{clean.Substring(9, 1)}";
                }
                else if (type == "PhilHealth")
                {
                    // Official format: 00-000000000-0 (12 digits)
                    if (clean.Length == 12)
                        return $"{clean.Substring(0, 2)}-{clean.Substring(2, 9)}-{clean.Substring(11, 1)}";
                }
                else if (type == "Pag-IBIG")
                {
                    // Official format: 0000-0000-0000 (12 digits)
                    if (clean.Length == 12)
                        return $"{clean.Substring(0, 4)}-{clean.Substring(4, 4)}-{clean.Substring(8, 4)}";
                }
            }
            catch { }
            
            return number; // Return original if formatting fails or length doesn't match
        }

        protected async void btnViewEmployeeDetails_Click(object sender, EventArgs e)
        {
            string employeeId = hdnEmployeeId.Value;
            if (string.IsNullOrEmpty(employeeId)) return;
            var employee = await _employeeService.GetEmployeeByIdAsync(employeeId);
            if (employee != null)
            {
                DisplayEmployeeDetails(employee);
                ScriptManager.RegisterStartupScript(this, GetType(), "openEmployeeDetailsModal", 
                    "document.getElementById('viewEmployeeDetailsModal').style.display = 'block';", true);
            }
        }

        private void DisplayEmployeeDetails(Employee employee)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='padding: 20px;'>");
            
            // Personal Info
            sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Personal Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Employee ID:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.EmployeeId ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>First Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.FirstName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Middle Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.MiddleName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Last Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.LastName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Email Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.Email ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contact No.:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.ContactNo ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.Address ?? ""));
            sb.Append("</table>");

            // Employment Info
            sb.Append("<h3 style='color: #8B4755; margin: 20px 0 15px 0; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Employment Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Department:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.Department ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Role:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(employee.Role ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Hired Date:</td><td style='padding: 8px;'>{0}</td></tr>", employee.HiredDate.ToLocalTime().ToString("MMM dd, yyyy"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Status:</td><td style='padding: 8px;'>{0}</td></tr>", employee.IsActive ? "Active" : "Inactive");
            
            // Gov Contributions
            string checkIconModal = "<i class='fas fa-check-circle' style='color: #22c55e; margin-right: 4px;'></i>";
            string xIconModal = "<i class='fas fa-times-circle' style='color: #94a3b8; margin-right: 4px;'></i>";

            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Govt. Contributions:</td><td style='padding: 8px;'>");
            sb.AppendFormat("<div style='margin-bottom: 8px;'><span style='margin-right: 15px;'>{0} SSS</span> <span style='color: #64748b; font-size: 13px;'>{1}</span></div>", 
                            employee.HasSSS ? checkIconModal : xIconModal, 
                            FormatGovNumber(employee.SSSNumber, "SSS"));
            sb.AppendFormat("<div style='margin-bottom: 8px;'><span style='margin-right: 15px;'>{0} PhilHealth</span> <span style='color: #64748b; font-size: 13px;'>{1}</span></div>", 
                            employee.HasPhilHealth ? checkIconModal : xIconModal, 
                            FormatGovNumber(employee.PhilHealthNumber, "PhilHealth"));
            sb.AppendFormat("<div><span>{0} Pag-IBIG</span> <span style='color: #64748b; font-size: 13px;'>{1}</span></div>", 
                            employee.HasPagIbig ? checkIconModal : xIconModal, 
                            FormatGovNumber(employee.PagIbigNumber, "Pag-IBIG"));
            sb.Append("</td></tr>");
            
            sb.Append("</table>");

            sb.Append("</div>");

            // Action Cards
            sb.Append("<div class='actions-grid'>");
            
            // View Payslip Card
            sb.Append("<div class='action-card' onclick='openPayslipModal()'>");
            sb.Append("<div class='action-icon'>ðŸ’°</div>");
            sb.Append("<h3 class='action-title'>View Payslip</h3>");
            sb.Append("<p class='action-description'>View your salary breakdown including gross salary, deductions, and net pay.</p>");
            sb.Append("<button class='action-button'>View Details</button>");
            sb.Append("</div>");

            // History Leave Card
            sb.AppendFormat("<div class='action-card' onclick='openLeaveHistoryModal(\"{0}\")'>", Server.HtmlEncode(employee.Id));
            sb.Append("<div class='action-icon'>ðŸ“</div>");
            sb.Append("<h3 class='action-title'>History Leave of Absence</h3>");
            sb.Append("<p class='action-description'>View the leave history including sick leave, vacation, and personal matters.</p>");
            sb.Append("<button class='action-button'>View History</button>");
            sb.Append("</div>");

            // History Concern Card
            sb.AppendFormat("<div class='action-card' onclick='openConcernHistoryModal(\"{0}\")'>", Server.HtmlEncode(employee.Id));
            sb.Append("<div class='action-icon'>ðŸ’¬</div>");
            sb.Append("<h3 class='action-title'>History of Employee Concern</h3>");
            sb.Append("<p class='action-description'>View all workplace concerns, complaints, or suggestions submitted to HR.</p>");
            sb.Append("<button class='action-button'>View History</button>");
            sb.Append("</div>");

            sb.Append("</div>");

            employeeDetailsContent.InnerHtml = sb.ToString();
        }

        protected async void btnViewLeaveHistory_Click(object sender, EventArgs e)
        {
            try
            {
                string employeeId = hdnEmployeeId.Value;
                if (string.IsNullOrEmpty(employeeId))
                {
                    return;
                }

                var employee = await _employeeService.GetEmployeeByIdAsync(employeeId);
                if (employee == null) return;

                var leaves = await _leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId);
                DisplayLeaveHistory(leaves);
                ScriptManager.RegisterStartupScript(this, GetType(), "openLeaveHistoryModal", 
                    "document.getElementById('leaveHistoryModal').style.display = 'block';", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading leave history: {ex.Message}");
            }
        }

        protected async void btnViewConcernHistory_Click(object sender, EventArgs e)
        {
            try
            {
                string employeeId = hdnEmployeeId.Value;
                if (string.IsNullOrEmpty(employeeId))
                {
                    return;
                }

                 var employee = await _employeeService.GetEmployeeByIdAsync(employeeId);
                if (employee == null) return;

                var concerns = await _concernService.GetConcernsByEmployeeIdAsync(employee.EmployeeId);
                DisplayConcernHistory(concerns);
                ScriptManager.RegisterStartupScript(this, GetType(), "openConcernHistoryModal", 
                    "document.getElementById('concernHistoryModal').style.display = 'block';", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading concern history: {ex.Message}");
            }
        }

        private void DisplayLeaveHistory(List<Leave> leaves)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='padding: 20px;'>");

            if (leaves == null || leaves.Count == 0)
            {
                sb.Append("<div style='text-align: center; padding: 40px; color: #999;'>");
                sb.Append("<p style='font-size: 16px;'>No leave records found for this employee.</p>");
                sb.Append("</div>");
            }
            else
            {
                sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Leave History</h3>");
                
                foreach (var leave in leaves)
                {
                    string statusColor = leave.Status == "Approved" ? "#10b981" : 
                                        leave.Status == "Rejected" ? "#ef4444" : "#f59e0b";
                    
                    sb.Append("<div style='background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid " + statusColor + ";'>");
                    sb.AppendFormat("<div style='display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;'>");
                    sb.AppendFormat("<div><strong style='color: #333; font-size: 16px;'>{0}</strong></div>", Server.HtmlEncode(leave.LeaveType ?? ""));
                    sb.AppendFormat("<span style='background: {0}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600;'>{1}</span>", statusColor, Server.HtmlEncode(leave.Status ?? ""));
                    sb.Append("</div>");
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Period:</strong> {0} to {1}</div>", 
                        leave.StartDate.ToLocalTime().ToString("MMM dd, yyyy"), 
                        leave.EndDate.ToLocalTime().ToString("MMM dd, yyyy"));
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Reason:</strong> {0}</div>", Server.HtmlEncode(leave.Reason ?? ""));
                    sb.AppendFormat("<div style='color: #999; font-size: 12px;'><strong>Submitted:</strong> {0}</div>", leave.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
                    sb.Append("</div>");
                }
            }

            sb.Append("</div>");
            leaveHistoryContent.InnerHtml = sb.ToString();
        }

        private void DisplayConcernHistory(List<EmployeeConcern> concerns)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='padding: 20px;'>");

            if (concerns == null || concerns.Count == 0)
            {
                sb.Append("<div style='text-align: center; padding: 40px; color: #999;'>");
                sb.Append("<p style='font-size: 16px;'>No concern records found for this employee.</p>");
                sb.Append("</div>");
            }
            else
            {
                sb.Append("<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Concern History</h3>");
                
                foreach (var concern in concerns)
                {
                    sb.Append("<div style='background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid #8B4755;'>");
                    sb.AppendFormat("<div style='display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;'>");
                    sb.AppendFormat("<div><strong style='color: #333; font-size: 16px;'>{0}</strong></div>", Server.HtmlEncode(concern.Subject ?? ""));
                    sb.Append("</div>");
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Type:</strong> {0}</div>", Server.HtmlEncode(concern.ConcernType ?? ""));
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Description:</strong> {0}</div>", Server.HtmlEncode(concern.Description ?? ""));
                    sb.AppendFormat("<div style='color: #999; font-size: 12px;'><strong>Submitted:</strong> {0}</div>", concern.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
                    sb.Append("</div>");
                }
            }

            sb.Append("</div>");
            concernHistoryContent.InnerHtml = sb.ToString();
        }

        // ========== LEAVE REQUEST WEB METHODS ==========

        /// <summary>
        /// Get all pending leave requests
        /// </summary>
        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingLeaveRequests()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            System.Diagnostics.Debug.WriteLine("--- GetPendingLeaveRequests CALLED ---");
            
            try
            {
                // Run the entire logic in a background thread to prevent ASP.NET Deadlock
                return Task.Run(async () => {
                    var leaveService = new LeaveService();
                    var employeeService = new EmployeeService();
                    
                    System.Diagnostics.Debug.WriteLine("Fetching all leaves...");
                    var leaves = await leaveService.GetAllLeavesAsync().ConfigureAwait(false);
                    if (leaves == null) {
                        System.Diagnostics.Debug.WriteLine("Leaves collection is NULL");
                        return serializer.Serialize(new { success = false, message = "Database error" });
                    }

                    // Filter for pending leaves only
                    var pendingLeaves = leaves.Where(l => l.Status == "Pending").ToList();
                    System.Diagnostics.Debug.WriteLine($"Found {pendingLeaves.Count} pending leaves");
                    
                    if (pendingLeaves.Count == 0) {
                        return serializer.Serialize(new { success = true, data = new List<object>(), currentAdminId = "" });
                    }

                    // BATCH LOOKUP EMPLOYEES: Get all unique employee IDs from the pending leaves
                    var uniqueEmpIds = pendingLeaves
                        .Where(l => !string.IsNullOrEmpty(l.EmployeeId))
                        .Select(l => l.EmployeeId)
                        .Distinct()
                        .ToList();

                    System.Diagnostics.Debug.WriteLine($"Fetching {uniqueEmpIds.Count} unique employees in batch...");
                    
                    // Optimization: Instead of 1 query per leave, we use a dictionary for O(1) lookup
                    var employeeCache = new Dictionary<string, Employee>(StringComparer.OrdinalIgnoreCase);
                    
                    // Get all employees in the system for lookup - since we have relatively few employees (e.g. < 1000)
                    // Fetching all active ones is faster than multiple individual queries
                    var allEmployees = await employeeService.GetAllEmployeesAsync().ConfigureAwait(false);
                    if (allEmployees != null) {
                        foreach (var emp in allEmployees) {
                            if (!string.IsNullOrEmpty(emp.EmployeeId))
                                employeeCache[emp.EmployeeId] = emp;
                        }
                    }

                    var result = pendingLeaves.Select(l => {
                        Employee emp = null;
                        string empName = l.EmployeeName; // Fallback to what's stored in leave record
                        
                        if (!string.IsNullOrEmpty(l.EmployeeId) && employeeCache.TryGetValue(l.EmployeeId, out emp)) {
                            empName = FormatFullName(emp.FirstName, emp.MiddleName, emp.LastName);
                        } else if (string.IsNullOrWhiteSpace(empName)) {
                            empName = l.EmployeeId ?? "Unknown Employee";
                        } else {
                             empName = FormatNameFromSingleString(empName);
                        }

                        return new
                        {
                            id = l.Id,
                            employeeId = l.EmployeeId,
                            employeeName = empName,
                            leaveType = l.LeaveType,
                            startDate = l.StartDate.ToLocalTime().ToString("MMM dd, yyyy"),
                            endDate = l.EndDate.ToLocalTime().ToString("MMM dd, yyyy"),
                            duration = CalculateDuration(l.StartDate, l.EndDate),
                            reason = l.Reason,
                            status = l.Status,
                            submittedDate = l.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt")
                        };
                    }).ToList();

                    string currentAdminId = "";
                    try {
                        var context = System.Web.HttpContext.Current;
                        var currentAdmin = context?.Session?["Employee"] as Employee;
                        currentAdminId = currentAdmin?.EmployeeId ?? "";
                        System.Diagnostics.Debug.WriteLine($"Current Admin ID: {currentAdminId}");
                    } catch (Exception ex) {
                        System.Diagnostics.Debug.WriteLine($"Session error: {ex.Message}");
                    }

                    System.Diagnostics.Debug.WriteLine("GetPendingLeaveRequests logic COMPLETED successfully");
                    return serializer.Serialize(new { success = true, data = result, currentAdminId = currentAdminId });
                    
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CRITICAL Error in GetPendingLeaveRequests: {ex.Message}");
                System.Diagnostics.Debug.WriteLine(ex.StackTrace);
                return serializer.Serialize(new { success = false, message = "System Error: " + ex.Message });
            }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingResignations()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                return Task.Run(async () =>
                {
                    var employeeService = new EmployeeService();
                    var pending = await employeeService.GetPendingResignationsAsync().ConfigureAwait(false);

                    var result = pending.Select(e => new
                    {
                        id         = e.Id,
                        empId      = e.EmployeeId ?? "",
                        name       = e.FullName ?? "",
                        department = e.Department ?? "",
                        role       = e.Role ?? "",
                        dateReq    = e.ResignationDate.HasValue
                                        ? e.ResignationDate.Value.ToLocalTime().ToString("MMM dd, yyyy")
                                        : "â€”",
                        status     = e.ResignationStatus ?? "Pending"
                    }).ToList();

                    return serializer.Serialize(new { success = true, data = result });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingConcerns()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                return Task.Run(async () =>
                {
                    var concernService = new EmployeeConcernService();
                    var employeeService = new EmployeeService();

                    var allConcerns = await concernService.GetAllConcernsAsync().ConfigureAwait(false);
                    var pendingConcerns = allConcerns.Where(c => c.Status == "Submitted" || c.Status == "In Progress").ToList();

                    var allEmployees = await employeeService.GetAllEmployeesAsync().ConfigureAwait(false);
                    var employeeCache = allEmployees
                        .Where(e => !string.IsNullOrEmpty(e.EmployeeId))
                        .GroupBy(e => e.EmployeeId)
                        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);

                    var result = pendingConcerns.Select(c => {
                        string empName = c.EmployeeName;
                        string dept = "";
                        if (!string.IsNullOrEmpty(c.EmployeeId) && employeeCache.TryGetValue(c.EmployeeId, out var emp))
                        {
                            empName = emp.FullName;
                            dept = emp.Department;
                        }

                        return new
                        {
                            id = c.Id,
                            employeeId = c.EmployeeId,
                            employeeName = empName,
                            department = dept,
                            subject = c.Subject,
                            description = c.Description,
                            concernType = c.ConcernType,
                            priorityLevel = c.PriorityLevel,
                            submittedDate = c.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"),
                            status = c.Status
                        };
                    }).ToList();

                    return serializer.Serialize(new { success = true, data = result });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ResolveConcern(string id)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                return Task.Run(async () => {
                    var concernService = new EmployeeConcernService();
                    var success = await concernService.UpdateConcernStatusAsync(id, "Resolved").ConfigureAwait(false);

                    if (success)
                    {
                        LogActivity("Resolved Concern", $"Resolved employee concern {id}");
                        return serializer.Serialize(new { success = true, message = "Concern marked as resolved." });
                    }
                    return serializer.Serialize(new { success = false, message = "Failed to update concern status." });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string CancelResignation(string id)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                bool success = Task.Run(async () =>
                {
                    var employeeService = new EmployeeService();
                    var update = MongoDB.Driver.Builders<Models.Employee>.Update
                        .Set(e => e.ResignationStatus, "None")
                        .Set(e => e.ResignationDate, (DateTime?)null);
                    var result = await employeeService.UpdateEmployeeFieldsAsync(id, update).ConfigureAwait(false);
                    return result;
                }).GetAwaiter().GetResult();

                if (success) LogActivity("Declined Resignation", $"Declined resignation for employee ID: {id}");
                return serializer.Serialize(new { success, message = success ? "Resignation declined." : "Failed to decline resignation." });
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        private static string ResolveLeaveEmployeeName(Leave leave, EmployeeService employeeService, Dictionary<string, string> cache)
        {
            if (!string.IsNullOrEmpty(leave.EmployeeId))
            {
                if (cache.TryGetValue(leave.EmployeeId, out var cachedName))
                {
                    return cachedName;
                }

                var employee = employeeService.GetByEmployeeIdAsync(leave.EmployeeId)
                    .ConfigureAwait(false)
                    .GetAwaiter()
                    .GetResult();

                if (employee != null)
                {
                    var formattedName = FormatFullName(employee.FirstName, employee.MiddleName, employee.LastName);
                    cache[leave.EmployeeId] = formattedName;
                    return formattedName;
                }
            }

            if (!string.IsNullOrWhiteSpace(leave.EmployeeName))
            {
                return FormatNameFromSingleString(leave.EmployeeName);
            }

            return leave.EmployeeId ?? "Unknown Employee";
        }

        private static string CalculateDuration(DateTime start, DateTime end)
        {
            var days = (end - start).Days + 1;
            if (days == 1) return "1 day";
            if (days <= 0)
            {
                // Same day or invalid range - treat as half day
                return "0.5 day";
            }
            return $"{days} days";
        }

        /// <summary>
        /// Approve a leave request
        /// </summary>
        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ApproveLeaveRequest(string leaveId)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                return Task.Run(async () => {
                    if (string.IsNullOrEmpty(leaveId))
                    {
                        return serializer.Serialize(new { success = false, message = "Leave ID is required" });
                    }

                    var context = System.Web.HttpContext.Current;
                    var currentAdmin = context?.Session?["Employee"] as Employee;
                    var currentAdminId = currentAdmin?.EmployeeId;

                    var leaveService = new LeaveService();
                    var leave = await leaveService.GetLeaveByIdAsync(leaveId).ConfigureAwait(false);
                    
                    if (leave != null && leave.EmployeeId == currentAdminId)
                    {
                        return serializer.Serialize(new { success = false, message = "You cannot approve your own leave request." });
                    }

                    var result = await leaveService.UpdateLeaveStatusAsync(leaveId, "Approved").ConfigureAwait(false);

                    if (result)
                    {
                        return serializer.Serialize(new { success = true, message = "Leave request approved successfully" });
                    }
                    else
                    {
                        return serializer.Serialize(new { success = false, message = "Failed to approve leave request" });
                    }
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        /// <summary>
        /// Decline a leave request
        /// </summary>
        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string DeclineLeaveRequest(string leaveId)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            try
            {
                return Task.Run(async () => {
                    if (string.IsNullOrEmpty(leaveId))
                    {
                        return serializer.Serialize(new { success = false, message = "Leave ID is required" });
                    }

                    var context = System.Web.HttpContext.Current;
                    var currentAdmin = context?.Session?["Employee"] as Employee;
                    var currentAdminId = currentAdmin?.EmployeeId;

                    var leaveService = new LeaveService();
                    var leave = await leaveService.GetLeaveByIdAsync(leaveId).ConfigureAwait(false);

                    if (leave != null && leave.EmployeeId == currentAdminId)
                    {
                        return serializer.Serialize(new { success = false, message = "You cannot decline your own leave request." });
                    }

                    var result = await leaveService.UpdateLeaveStatusAsync(leaveId, "Declined").ConfigureAwait(false);

                    if (result)
                    {
                        return serializer.Serialize(new { success = true, message = "Leave request declined" });
                    }
                    else
                    {
                        return serializer.Serialize(new { success = false, message = "Failed to decline leave request" });
                    }
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return serializer.Serialize(new { success = false, message = ex.Message });
            }
        }

        private static string BuildConcernExcerpt(string text, int maxLength = 220)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return "No description provided.";
            }

            var trimmed = text.Trim();
            if (trimmed.Length <= maxLength)
            {
                return trimmed;
            }

            return $"{trimmed.Substring(0, maxLength).Trim()}...";
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "??";
            }

            var parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
            {
                return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
            }

            var first = parts[0][0];
            var last = parts[parts.Length - 1][0];
            return $"{char.ToUpperInvariant(first)}{char.ToUpperInvariant(last)}";
        }

        private static string FormatFullName(string firstName, string middleName, string lastName)
        {
            var last = lastName?.Trim();
            var first = firstName?.Trim();
            var middle = middleName?.Trim();

            if (!string.IsNullOrEmpty(last) && !string.IsNullOrEmpty(first))
            {
                return string.IsNullOrEmpty(middle)
                    ? $"{last}, {first}"
                    : $"{last}, {first} {middle}";
            }

            var combined = string.Join(" ", new[] { first, middle, last }.Where(s => !string.IsNullOrWhiteSpace(s)));
            return string.IsNullOrEmpty(combined) ? "Unknown Employee" : combined;
        }

        private static string FormatNameFromSingleString(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "Unknown Employee";
            }

            var parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 2)
            {
                return name.Trim();
            }

            var first = parts[0];
            var last = parts[parts.Length - 1];
            var middle = string.Join(" ", parts.Skip(1).Take(parts.Length - 2));

            if (string.IsNullOrEmpty(middle))
            {
                return $"{last}, {first}";
            }

            return $"{last}, {first} {middle}";
        }
    }
}