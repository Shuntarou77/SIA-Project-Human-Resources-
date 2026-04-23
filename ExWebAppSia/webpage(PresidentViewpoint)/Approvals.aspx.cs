using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;
using System.Web.Services;
using System.Web.Script.Serialization;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class Approvals : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Literal litUTCount;
        protected global::System.Web.UI.WebControls.Literal litResignCount;
        protected global::System.Web.UI.WebControls.Literal litOTCount;
        protected global::System.Web.UI.WebControls.Literal litLeaveCount;
        protected global::System.Web.UI.WebControls.Literal litConcernCount;
        protected global::System.Web.UI.WebControls.Literal litActiveTab;
        protected global::System.Web.UI.WebControls.Repeater rptLeave;
        protected global::System.Web.UI.WebControls.Repeater rptOvertime;
        protected global::System.Web.UI.WebControls.Repeater rptUndertime;
        protected global::System.Web.UI.WebControls.Repeater rptConcerns;
        protected global::System.Web.UI.WebControls.Repeater rptResignation;
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly OvertimeService _otService = new OvertimeService();
        private readonly UndertimeService _utService = new UndertimeService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();
        private readonly ActivityLogService _logService = new ActivityLogService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadExecutiveData));
            }
        }

        private async Task LoadExecutiveData()
        {
            try
            {

                // 2. Fetch all data
                var leavesTask = _leaveService.GetAllLeavesAsync();
                var otTask = _otService.GetPendingRequestsAsync();
                var utTask = _utService.GetAllPendingRequestsAsync();
                var resignedTask = _employeeService.GetPendingResignationsAsync();
                var concernsTask = _concernService.GetAllConcernsAsync();
                var employeesTask = _employeeService.GetAllEmployeesAsync();

                await Task.WhenAll(leavesTask, otTask, utTask, resignedTask, concernsTask, employeesTask).ConfigureAwait(false);

                var allEmps = employeesTask.Result ?? new List<Employee>();
                var adminIds = allEmps.Where(e => e.Role == "Super Admin").Select(e => e.EmployeeId).ToList();

                // Filter for ALL pending requests (to sync with SuperAdmin)
                var pLeaves = leavesTask.Result?.Where(l => string.Equals(l.Status, "Pending", StringComparison.OrdinalIgnoreCase)).ToList() ?? new List<Leave>();
                var pOT = otTask.Result ?? new List<OvertimeRequest>();
                var pUT = utTask.Result ?? new List<UndertimeRequest>();
                var pResign = resignedTask.Result ?? new List<Employee>();
                var pConcerns = concernsTask.Result?.Where(c => string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)).OrderByDescending(c => c.SubmittedDate).ToList() ?? new List<EmployeeConcern>();

                // Bind Counts
                litLeaveCount.Text = pLeaves.Count.ToString();
                litOTCount.Text = pOT.Count.ToString();
                litUTCount.Text = pUT.Count.ToString();
                litResignCount.Text = pResign.Count.ToString();
                litConcernCount.Text = pConcerns.Count.ToString();
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"President Approvals Error: {ex.Message}"); }
        }


        [WebMethod(EnableSession = true)]
        public static string GetSuperAdminRequests()
        {
            var serializer = new JavaScriptSerializer();
            try
            {
                return Task.Run(async () => {
                    var empService = new EmployeeService();
                    var all = await empService.GetAllEmployeesAsync();
                    var adminIds = all.Where(e => e.Role == "Super Admin").Select(e => e.EmployeeId).ToList();
                    var empMap = all.ToDictionary(e => e.EmployeeId, e => e);

                    var leaveS = new LeaveService();
                    var otS = new OvertimeService();
                    var utS = new UndertimeService();
                    var resS = new EmployeeService();
                    var conS = new EmployeeConcernService();

                    var leaves = (await leaveS.GetAllLeavesAsync()).Where(l => string.Equals(l.Status, "Pending", StringComparison.OrdinalIgnoreCase)).Select(l => new {
                        id = l.Id, name = l.EmployeeName, type = l.LeaveType, range = $"{l.StartDate:MMM dd} - {l.EndDate:MMM dd}", reason = l.Reason
                    }).ToList();

                    var ot = (await otS.GetPendingRequestsAsync()).Select(o => new {
                        id = o.Id, name = o.EmployeeName, date = o.Date.ToString("MMM dd, yyyy"), hours = o.RequestedHours, reason = o.Reason
                    }).ToList();

                    var ut = (await utS.GetAllPendingRequestsAsync()).Select(u => new {
                        id = u.Id, name = u.EmployeeName, date = u.Date.ToString("MMM dd, yyyy"), reason = u.Reason
                    }).ToList();

                    var resign = (await resS.GetPendingResignationsAsync()).Select(e => new {
                        id = e.Id, name = e.FullName, hired = e.HiredDate.ToString("MMM dd, yyyy"), effective = e.ResignationDate?.ToString("MMM dd, yyyy") ?? "Pending"
                    }).ToList();

                    var concerns = (await conS.GetAllConcernsAsync()).Where(c => string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)).Select(c => new {
                        id = c.Id, name = c.EmployeeName, subject = c.Subject, type = c.ConcernType, date = c.SubmittedDate.ToString("MMM dd, yyyy")
                    }).ToList();

                    return serializer.Serialize(new { success = true, leaves, ot, ut, resign, concerns });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex) { return serializer.Serialize(new { success = false, message = ex.Message }); }
        }

        [WebMethod(EnableSession = true)]
        public static string ProcessApproval(string type, string id, bool isApprove)
        {
            try
            {
                return Task.Run(async () => {
                    bool success = false;
                    string status = isApprove ? "Approved" : "Rejected";
                    var emp = HttpContext.Current?.Session["Employee"] as Employee;

                    if (type == "Leave") success = await new LeaveService().UpdateLeaveStatusAsync(id, status);
                    else if (type == "OT") success = isApprove ? await new OvertimeService().ApproveAsync(id) : await new OvertimeService().RejectAsync(id);
                    else if (type == "UT") success = isApprove ? await new UndertimeService().ApproveRequestAsync(id) : await new UndertimeService().RejectRequestAsync(id);
                    else if (type == "Resign") {
                         var update = MongoDB.Driver.Builders<Employee>.Update.Set(e => e.ResignationStatus, status);
                         success = await new EmployeeService().UpdateEmployeeFieldsAsync(id, update);
                    }
                    else if (type == "Concern") {
                        success = await new EmployeeConcernService().UpdateConcernStatusAsync(id, "Resolved");
                    }

                    if(success) {
                        var log = new ActivityLogService();
                        await log.LogActionAsync(emp?.Email ?? "President", emp?.FullName ?? "President", "Executive " + status, "Approvals", $"{type} request {id}");
                    }

                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            }
            catch { return "{\"success\":false}"; }
        }
    }
}

