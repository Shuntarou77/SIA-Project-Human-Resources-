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

namespace ExWebAppSia.webpage
{
    public partial class Approvals : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private readonly UndertimeService _undertimeService = new UndertimeService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();
        private readonly ManagerService _managerService = new ManagerService();
        private readonly ActivityLogService _activityLogService = new ActivityLogService();

        public List<OvertimeRequest> PendingOvertimeRequests { get; set; } = new List<OvertimeRequest>();
        public List<UndertimeRequest> PendingUndertimeRequests { get; set; } = new List<UndertimeRequest>();

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
                RegisterAsyncTask(new PageAsyncTask(LoadEmployeesData));
            }
        }

        private async Task LoadEmployeesData()
        {
            try
            {
                var otTask = _overtimeService.GetPendingRequestsAsync();
                var utTask = _undertimeService.GetAllPendingRequestsAsync();
                var leavesTask = _leaveService.GetAllLeavesAsync();
                var concernsTask = _concernService.GetAllConcernsAsync();
                var resignedTask = _employeeService.GetPendingResignationsAsync();
                var employeesTask = _employeeService.GetAllEmployeesAsync();

                await Task.WhenAll(otTask, utTask, leavesTask, concernsTask, resignedTask, employeesTask);

                PendingOvertimeRequests = otTask.Result ?? new List<OvertimeRequest>();
                PendingUndertimeRequests = utTask.Result ?? new List<UndertimeRequest>();
                var allLeaves = leavesTask.Result ?? new List<Leave>();
                var allConcerns = concernsTask.Result ?? new List<EmployeeConcern>();
                var pendingResignations = resignedTask.Result ?? new List<Employee>();
                var allEmployees = employeesTask.Result ?? new List<Employee>();
                var hrEmployeeIds = BuildHrEmployeeIdSet(allEmployees);

                PendingOvertimeRequests = PendingOvertimeRequests
                    .Where(r => !string.IsNullOrEmpty(r.EmployeeId) && hrEmployeeIds.Contains(r.EmployeeId))
                    .Where(r => !IsSelfRequest(r.EmployeeId, r.EmployeeName, CurrentAdminId, (Session["Employee"] as Employee)?.FullName))
                    .ToList();
                PendingUndertimeRequests = PendingUndertimeRequests
                    .Where(r => !string.IsNullOrEmpty(r.EmployeeId) && hrEmployeeIds.Contains(r.EmployeeId))
                    .Where(r => !IsSelfRequest(r.EmployeeId, r.EmployeeName, CurrentAdminId, (Session["Employee"] as Employee)?.FullName))
                    .ToList();
                allLeaves = allLeaves
                    .Where(l => !string.IsNullOrEmpty(l.EmployeeId) && hrEmployeeIds.Contains(l.EmployeeId))
                    .Where(l => !IsSelfRequest(l.EmployeeId, l.EmployeeName, CurrentAdminId, (Session["Employee"] as Employee)?.FullName))
                    .ToList();
                allConcerns = allConcerns
                    .Where(c => !string.IsNullOrEmpty(c.EmployeeId) && hrEmployeeIds.Contains(c.EmployeeId))
                    .Where(c => !IsSelfRequest(c.EmployeeId, c.EmployeeName, CurrentAdminId, (Session["Employee"] as Employee)?.FullName))
                    .ToList();
                pendingResignations = pendingResignations
                    .Where(e => IsHumanResourcesDepartment(e.Department))
                    .Where(e => !IsRestrictedExecutiveRole(e.Role))
                    .Where(e => !IsSelfRequest(e.EmployeeId, e.FullName, CurrentAdminId, (Session["Employee"] as Employee)?.FullName))
                    .ToList();

                // Bind Counts to UI
                int leaveCount = allLeaves.Count(l => l.Status == "Pending");
                int otCount = PendingOvertimeRequests.Count;
                int utCount = PendingUndertimeRequests.Count;
                int resignCount = pendingResignations.Count;
                int concernCount = allConcerns.Count(c => string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase));

                // We use FindControl to be safe if the designer is out of sync
                var l_leave = Master.FindControl("ContentPlaceHolder1").FindControl("litLeaveCount") as Literal;
                var l_ot = Master.FindControl("ContentPlaceHolder1").FindControl("litOTCount") as Literal;
                var l_ut = Master.FindControl("ContentPlaceHolder1").FindControl("litUTCount") as Literal;
                var l_resign = Master.FindControl("ContentPlaceHolder1").FindControl("litResignCount") as Literal;
                var l_concern = Master.FindControl("ContentPlaceHolder1").FindControl("litConcernCount") as Literal;

                if (l_leave != null) l_leave.Text = leaveCount.ToString();
                if (l_ot != null) l_ot.Text = otCount.ToString();
                if (l_ut != null) l_ut.Text = utCount.ToString();
                if (l_resign != null) l_resign.Text = resignCount.ToString();
                if (l_concern != null) l_concern.Text = concernCount.ToString();

                // Hidden fields
                var hdnConc = Master.FindControl("ContentPlaceHolder1").FindControl("hdnConcernsJson") as HiddenField;
                if (hdnConc != null) hdnConc.Value = JsonConvert.SerializeObject(allConcerns);

                var hdnCurr = Master.FindControl("ContentPlaceHolder1").FindControl("hdnCurrentAdminId") as HiddenField;
                if (hdnCurr != null) hdnCurr.Value = CurrentAdminId;

                // Run minor background maintenance
                _ = Task.Run(() => {
                    _employeeService.FixProbationarySalariesAsync();
                    _employeeService.FixGovContributionsAsync();
                    _employeeService.ProcessRegularizationAsync();
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading approvals: {ex.Message}");
            }
        }

        // ========== HELPERS ==========

        public string GetEstimatedOTRate(OvertimeRequest req)
        {
            if (req == null) return "0.00";
            decimal multiplier = _overtimeService.GetMultiplier(req.OvertimeType ?? "Regular");
            
            // Assume 22 working days, 8 hours
            decimal baseHourly = (req.BaseSalary > 0 ? req.BaseSalary : 15000) / 22 / 8;
            decimal estAmount = baseHourly * (decimal)req.RequestedHours * multiplier;
            
            if (req.IsNightShift) estAmount *= 1.1m;
            return estAmount.ToString("N2");
        }

        public string getInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "??";
            var parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2) return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        private static bool IsHumanResourcesDepartment(string department)
        {
            return true;
        }

        private static bool IsRestrictedExecutiveRole(string role)
        {
            if (string.IsNullOrEmpty(role)) return false;
            var r = role.Trim().ToLowerInvariant();
            return r.Contains("super admin") || r.Contains("superadmin") || r.Contains("president");
        }

        private static async Task<bool> IsRestrictedEmployeeByEmployeeIdAsync(string employeeId)
        {
            if (string.IsNullOrWhiteSpace(employeeId)) return false;
            var empService = new EmployeeService();
            var emp = await empService.GetByEmployeeIdAsync(employeeId);
            return emp != null && IsRestrictedExecutiveRole(emp.Role);
        }

        private static bool IsSelfRequest(string requestEmployeeId, string requestEmployeeName, string currentAdminId, string currentAdminName)
        {
            if (!string.IsNullOrWhiteSpace(requestEmployeeId) && !string.IsNullOrWhiteSpace(currentAdminId) &&
                string.Equals(requestEmployeeId.Trim(), currentAdminId.Trim(), StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            if (!string.IsNullOrWhiteSpace(requestEmployeeName) && !string.IsNullOrWhiteSpace(currentAdminName) &&
                string.Equals(requestEmployeeName.Trim(), currentAdminName.Trim(), StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            return false;
        }

        private static HashSet<string> BuildHrEmployeeIdSet(IEnumerable<Employee> employees)
        {
            var usersCollection = MongoDBHelper.GetUsersCollection();
            var restrictedRoles = new[] { "Super Admin", "President" };
            var restrictedIds = usersCollection.Find(u => restrictedRoles.Contains(u.Role) && u.IsActive)
                                            .Project(u => u.EmployeeId)
                                            .ToList();
            var restrictedSet = new HashSet<string>(restrictedIds, StringComparer.OrdinalIgnoreCase);

            return new HashSet<string>(
                (employees ?? Enumerable.Empty<Employee>())
                    .Where(e => e != null
                        && !string.IsNullOrEmpty(e.EmployeeId)
                        && e.IsActive
                        && !IsRestrictedExecutiveRole(e.Role)
                        && !restrictedSet.Contains(e.EmployeeId))
                    .Select(e => e.EmployeeId),
                StringComparer.OrdinalIgnoreCase
            );
        }

        private static string CalculateDuration(DateTime start, DateTime end)
        {
            var days = (end.Date - start.Date).Days + 1;
            return days <= 1 ? "1 day" : $"{days} days";
        }

        private static void LogActivity(string action, string targetInfo)
        {
            try
            {
                var context = HttpContext.Current;
                var emp = context?.Session["Employee"] as Employee;
                var logService = new ActivityLogService();
                
                string username = (context?.Session["Username"] as string) ?? "System";
                string hrName = emp?.FullName ?? "Admin";

                System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                    Task.Run(() => logService.LogActionAsync(username, hrName, action, "Approvals", targetInfo))
                );
            }
            catch { }
        }

        // ========== AJAX WEB METHODS ==========

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingLeaveRequests()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            var currentAdminId = currentAdmin?.EmployeeId ?? "";
            var currentAdminName = currentAdmin?.FullName ?? "";
            try
            {
                return Task.Run(async () => {
                    var leaveService = new LeaveService();
                    var employeeService = new EmployeeService();
                    var leaves = await leaveService.GetAllLeavesAsync();
                    var pending = leaves.Where(l => l.Status == "Pending").ToList();
                    
                    var allEmps = await employeeService.GetAllEmployeesAsync();
                    var empCache = allEmps.Where(e => !string.IsNullOrEmpty(e.EmployeeId))
                                          .ToDictionary(e => e.EmployeeId, e => e, StringComparer.OrdinalIgnoreCase);
                    var hrEmployeeIds = BuildHrEmployeeIdSet(allEmps);
                    pending = pending
                        .Where(l => !string.IsNullOrEmpty(l.EmployeeId) && hrEmployeeIds.Contains(l.EmployeeId))
                        .Where(l => !string.IsNullOrEmpty(l.EmployeeId) && empCache.TryGetValue(l.EmployeeId, out var empForRole) && !IsRestrictedExecutiveRole(empForRole.Role))
                        .Where(l => !IsSelfRequest(l.EmployeeId, l.EmployeeName, currentAdminId, currentAdminName))
                        .ToList();

                    var result = pending.Select(l => {
                        string name = l.EmployeeName;
                        string dept = "";
                        if (!string.IsNullOrEmpty(l.EmployeeId) && empCache.TryGetValue(l.EmployeeId, out var emp)) {
                            name = emp.FullName;
                            dept = emp.Department;
                        }
                        return new {
                            id = l.Id,
                            empId = l.EmployeeId,
                            employeeName = name,
                            department = dept,
                            leaveType = l.LeaveType,
                            startDate = l.StartDate.ToLocalTime().ToString("MMM dd, yyyy"),
                            endDate = l.EndDate.ToLocalTime().ToString("MMM dd, yyyy"),
                            duration = CalculateDuration(l.StartDate, l.EndDate),
                            reason = l.Reason,
                            status = l.Status
                        };
                    }).ToList();

                    return serializer.Serialize(new { success = true, data = result, currentAdminId = currentAdminId });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex) { return serializer.Serialize(new { success = false, message = ex.Message }); }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ApproveLeaveRequest(string leaveId)
        {
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            try {
                return Task.Run(async () => {
                    var leaveService = new LeaveService();
                    var leave = await leaveService.GetLeaveByIdAsync(leaveId);
                    if (leave == null) return "{\"success\":false,\"message\":\"Request not found\"}";
                    if (await IsRestrictedEmployeeByEmployeeIdAsync(leave.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve requests from Super Admin or President.\"}";
                    }

                    if (currentAdmin != null && string.Equals(leave.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve your own leave request.\"}";
                    }

                    var success = await leaveService.UpdateLeaveStatusAsync(leaveId, "Approved");
                    if (success) LogActivity("Approved Leave", $"Approved leave for {leave.EmployeeName}");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string DeclineLeaveRequest(string leaveId)
        {
            try {
                return Task.Run(async () => {
                    var leaveService = new LeaveService();
                    var leave = await leaveService.GetLeaveByIdAsync(leaveId);
                    if (leave != null && await IsRestrictedEmployeeByEmployeeIdAsync(leave.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot process requests from Super Admin or President.\"}";
                    }
                    var success = await leaveService.UpdateLeaveStatusAsync(leaveId, "Rejected");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ApproveResignation(string id)
        {
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            try {
                return Task.Run(async () => {
                    var empService = new EmployeeService();
                    var targetEmp = await empService.GetEmployeeByIdAsync(id);
                    if (targetEmp != null && IsRestrictedExecutiveRole(targetEmp.Role))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve requests from Super Admin or President.\"}";
                    }
                    if (targetEmp != null && currentAdmin != null && string.Equals(targetEmp.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve your own resignation request.\"}";
                    }

                    var success = await empService.ResignEmployeeAsync(id);
                    if (success) LogActivity("Resigned Employee", $"Approved resignation for employee record {id}");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string DeclineResignation(string id)
        {
            try {
                return Task.Run(async () => {
                    var empService = new EmployeeService();
                    var targetEmp = await empService.GetEmployeeByIdAsync(id);
                    if (targetEmp != null && IsRestrictedExecutiveRole(targetEmp.Role))
                    {
                        return "{\"success\":false,\"message\":\"You cannot process requests from Super Admin or President.\"}";
                    }
                    var update = Builders<Employee>.Update
                        .Set(e => e.ResignationStatus, "None")
                        .Set(e => e.ResignationDate, (DateTime?)null)
                        .Set(e => e.ResignationReason, "");
                    var success = await empService.UpdateEmployeeFieldsAsync(id, update);
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingResignations()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var currentAdminId = (HttpContext.Current?.Session["Employee"] as Employee)?.EmployeeId ?? "";
            var currentAdminName = (HttpContext.Current?.Session["Employee"] as Employee)?.FullName ?? "";
            try {
                return Task.Run(async () => {
                    var empService = new EmployeeService();
                    var pending = await empService.GetPendingResignationsAsync();
                    var hrEmployeeIds = BuildHrEmployeeIdSet(await empService.GetAllEmployeesAsync());
                    pending = pending.Where(e => hrEmployeeIds.Contains(e.EmployeeId)).ToList();
                    pending = pending.Where(e => !IsSelfRequest(e.EmployeeId, e.FullName, currentAdminId, currentAdminName)).ToList();
                    var result = pending.Select(e => new {
                        id = e.Id,
                        empId = e.EmployeeId,
                        name = e.FullName,
                        department = e.Department,
                        role = e.Role,
                        dateReq = e.ResignationDate?.ToString("MMM dd, yyyy") ?? "N/A"
                    }).ToList();
                    return serializer.Serialize(new { success = true, data = result, currentAdminId = currentAdminId });
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return serializer.Serialize(new { success = false, message = ex.Message }); }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string GetPendingConcerns()
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var currentAdminId = (HttpContext.Current?.Session["Employee"] as Employee)?.EmployeeId ?? "";
            var currentAdminName = (HttpContext.Current?.Session["Employee"] as Employee)?.FullName ?? "";
            try {
                return Task.Run(async () => {
                    var service = new EmployeeConcernService();
                    var employeeService = new EmployeeService();
                    var all = await service.GetAllConcernsAsync();
                    var allEmployees = await employeeService.GetAllEmployeesAsync();
                    var hrEmployeeIds = BuildHrEmployeeIdSet(allEmployees);
                    var pending = all.Where(c => string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)).ToList();
                    pending = pending
                        .Where(c => !string.IsNullOrEmpty(c.EmployeeId) && hrEmployeeIds.Contains(c.EmployeeId))
                        .Where(c => allEmployees.Any(e => string.Equals(e.EmployeeId, c.EmployeeId, StringComparison.OrdinalIgnoreCase) && !IsRestrictedExecutiveRole(e.Role)))
                        .Where(c => !IsSelfRequest(c.EmployeeId, c.EmployeeName, currentAdminId, currentAdminName))
                        .ToList();
                    var result = pending.Select(c => new {
                        id = c.Id,
                        empId = c.EmployeeId,
                        employeeName = c.EmployeeName,
                        concernType = c.ConcernType,
                        subject = c.Subject,
                        priorityLevel = c.PriorityLevel,
                        submittedDate = c.SubmittedDate.ToString("MMM dd, yyyy")
                    }).ToList();
                    return serializer.Serialize(new { success = true, data = result, currentAdminId = currentAdminId });
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return serializer.Serialize(new { success = false, message = ex.Message }); }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ApproveOvertime(string id)
        {
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            try {
                return Task.Run(async () => {
                    var otService = new OvertimeService();
                    var req = await otService.GetByIdAsync(id);
                    if (req != null && await IsRestrictedEmployeeByEmployeeIdAsync(req.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve requests from Super Admin or President.\"}";
                    }

                    if (req != null && currentAdmin != null && string.Equals(req.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve your own overtime request.\"}";
                    }

                    var success = await otService.ApproveAsync(id);
                    if (success) LogActivity("Approved OT", $"Approved OT request {id}");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string RejectOvertime(string id)
        {
            try {
                return Task.Run(async () => {
                    var otService = new OvertimeService();
                    var req = await otService.GetByIdAsync(id);
                    if (req != null && await IsRestrictedEmployeeByEmployeeIdAsync(req.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot process requests from Super Admin or President.\"}";
                    }
                    var success = await otService.RejectAsync(id);
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ApproveUndertime(string id)
        {
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            try {
                return Task.Run(async () => {
                    var utService = new UndertimeService();
                    var req = await utService.GetRequestByIdAsync(id);
                    if (req != null && await IsRestrictedEmployeeByEmployeeIdAsync(req.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve requests from Super Admin or President.\"}";
                    }

                    if (req != null && currentAdmin != null && string.Equals(req.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve your own undertime request.\"}";
                    }

                    var success = await utService.ApproveRequestAsync(id);
                    if (success) LogActivity("Approved UT", $"Approved UT request {id}");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string RejectUndertime(string id)
        {
            try {
                return Task.Run(async () => {
                    var utService = new UndertimeService();
                    var req = await utService.GetRequestByIdAsync(id);
                    if (req != null && await IsRestrictedEmployeeByEmployeeIdAsync(req.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot process requests from Super Admin or President.\"}";
                    }
                    var success = await utService.RejectRequestAsync(id);
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }

        [System.Web.Services.WebMethod(EnableSession = true)]
        public static string ResolveConcern(string id)
        {
            var currentAdmin = HttpContext.Current?.Session["Employee"] as Employee;
            try {
                return Task.Run(async () => {
                    var service = new EmployeeConcernService();
                    var concern = await service.GetConcernByIdAsync(id);
                    if (concern != null && await IsRestrictedEmployeeByEmployeeIdAsync(concern.EmployeeId))
                    {
                        return "{\"success\":false,\"message\":\"You cannot approve requests from Super Admin or President.\"}";
                    }

                    if (concern != null && currentAdmin != null && string.Equals(concern.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        return "{\"success\":false,\"message\":\"You cannot resolve your own concern.\"}";
                    }

                    var success = await service.UpdateConcernStatusAsync(id, "Resolved");
                    if (success) LogActivity("Resolved Concern", $"Resolved concern {id}");
                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            } catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message + "\"}"; }
        }
        [System.Web.Services.WebMethod]
        public static object GetUpdatedCounts()
        {
            try
            {
                return Task.Run(async () => {
                    var otService = new OvertimeService();
                    var utService = new UndertimeService();
                    var leaveService = new LeaveService();
                    var concernService = new EmployeeConcernService();
                    var employeeService = new EmployeeService();

                    var otTask = otService.GetPendingRequestsAsync();
                    var utTask = utService.GetAllPendingRequestsAsync();
                    var leavesTask = leaveService.GetAllLeavesAsync();
                    var concernsTask = concernService.GetAllConcernsAsync();
                    var resignedTask = employeeService.GetPendingResignationsAsync();
                    var employeesTask = employeeService.GetAllEmployeesAsync();

                    await Task.WhenAll(otTask, utTask, leavesTask, concernsTask, resignedTask, employeesTask);

                    var allEmployees = employeesTask.Result ?? new List<Employee>();
                    var hrEmployeeIds = BuildHrEmployeeIdSet(allEmployees);
                    var allLeaves = leavesTask.Result ?? new List<Leave>();
                    var allConcerns = concernsTask.Result ?? new List<EmployeeConcern>();
                    var hrPendingLeaves = allLeaves
                        .Where(l => l.Status == "Pending" && !string.IsNullOrEmpty(l.EmployeeId) && hrEmployeeIds.Contains(l.EmployeeId))
                        .ToList();
                    var hrPendingOt = (otTask.Result ?? new List<OvertimeRequest>())
                        .Where(r => !string.IsNullOrEmpty(r.EmployeeId) && hrEmployeeIds.Contains(r.EmployeeId))
                        .ToList();
                    var hrPendingUt = (utTask.Result ?? new List<UndertimeRequest>())
                        .Where(r => !string.IsNullOrEmpty(r.EmployeeId) && hrEmployeeIds.Contains(r.EmployeeId))
                        .ToList();
                    var hrPendingResign = (resignedTask.Result ?? new List<Employee>())
                        .Where(e => IsHumanResourcesDepartment(e.Department))
                        .Where(e => !IsRestrictedExecutiveRole(e.Role))
                        .Where(e => !IsSelfRequest(e.EmployeeId, e.FullName, (HttpContext.Current?.Session["Employee"] as Employee)?.EmployeeId, (HttpContext.Current?.Session["Employee"] as Employee)?.FullName))
                        .ToList();
                    var hrPendingConcerns = allConcerns
                        .Where(c => (string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase))
                            && !string.IsNullOrEmpty(c.EmployeeId) && hrEmployeeIds.Contains(c.EmployeeId))
                        .ToList();

                    return new {
                        success = true,
                        leaveCount = hrPendingLeaves.Count,
                        otCount = hrPendingOt.Count,
                        utCount = hrPendingUt.Count,
                        resignCount = hrPendingResign.Count,
                        concernCount = hrPendingConcerns.Count
                    };
                }).GetAwaiter().GetResult();
            }
            catch
            {
                return new { success = false };
            }
        }
    }
}
