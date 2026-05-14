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
using MongoDB.Driver;
using System.IO;

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
                // 1. Fetch all data
                var leavesTask = _leaveService.GetAllLeavesAsync();
                var otTask = _otService.GetPendingRequestsAsync();
                var utTask = _utService.GetAllPendingRequestsAsync();
                var resignedTask = _employeeService.GetPendingResignationsAsync();
                var concernsTask = _concernService.GetAllConcernsAsync();
                var loanTask = new LoanService().GetAllLoansAsync();
                
                // Get Admin IDs from Users collection instead of Employee.Role
                var usersCollection = MongoDBHelper.GetUsersCollection();
                var adminFilter = Builders<User>.Filter.And(
                    Builders<User>.Filter.Regex(u => u.Role, new MongoDB.Bson.BsonRegularExpression("super admin", "i")),
                    Builders<User>.Filter.Eq(u => u.IsActive, true)
                );
                var adminIdsTask = usersCollection.Find(adminFilter).Project(u => u.EmployeeId).ToListAsync();

                await Task.WhenAll(leavesTask, otTask, utTask, resignedTask, concernsTask, loanTask, adminIdsTask).ConfigureAwait(false);

                var adminIds = adminIdsTask.Result ?? new List<string>();

                // Filter for ONLY Super Admin pending requests
                var pLeaves = leavesTask.Result?.Where(l => string.Equals(l.Status, "Pending", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId)).ToList() ?? new List<Leave>();
                var pOT = otTask.Result?.Where(o => adminIds.Contains(o.EmployeeId)).ToList() ?? new List<OvertimeRequest>();
                var pUT = utTask.Result?.Where(u => adminIds.Contains(u.EmployeeId)).ToList() ?? new List<UndertimeRequest>();
                var pResign = resignedTask.Result?.Where(e => adminIds.Contains(e.EmployeeId)).ToList() ?? new List<Employee>();
                var pConcerns = concernsTask.Result?.Where(c => (string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)) && adminIds.Contains(c.EmployeeId)).OrderByDescending(c => c.SubmittedDate).ToList() ?? new List<EmployeeConcern>();
                var pLoans = loanTask.Result?.Where(l => string.Equals(l.Status, "PENDING", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId)).ToList() ?? new List<LoanRequest>();

                // Bind Counts
                litLeaveCount.Text = pLeaves.Count.ToString();
                litOTCount.Text = pOT.Count.ToString();
                litUTCount.Text = pUT.Count.ToString();
                litResignCount.Text = pResign.Count.ToString();
                litConcernCount.Text = pConcerns.Count.ToString();
                
                var l_loan = Master.FindControl("ContentPlaceHolder1").FindControl("cnt-loan") as Literal; // Or handle via JS
                // Actually JS handles the cnt-loan span, so we just need to ensure the data is in the GetSuperAdminRequests method.
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"President Approvals Error: {ex.Message}"); }
        }


        [WebMethod(EnableSession = true)]
        public static string GetSuperAdminRequests()
        {
            var serializer = new JavaScriptSerializer();
            var currentAdminId = (HttpContext.Current?.Session["Employee"] as Employee)?.EmployeeId ?? "";
            try
            {
                return Task.Run(async () => {
                    var usersCollection = MongoDBHelper.GetUsersCollection();
                    var adminFilter = Builders<User>.Filter.And(
                        Builders<User>.Filter.Regex(u => u.Role, new MongoDB.Bson.BsonRegularExpression("super admin", "i")),
                        Builders<User>.Filter.Eq(u => u.IsActive, true)
                    );
                    var adminIds = await usersCollection.Find(adminFilter).Project(u => u.EmployeeId).ToListAsync();

                    var leaveS = new LeaveService();
                    var otS = new OvertimeService();
                    var utS = new UndertimeService();
                    var resS = new EmployeeService();
                    var conS = new EmployeeConcernService();

                    var leaves = (await leaveS.GetAllLeavesAsync())
                        .Where(l => string.Equals(l.Status, "Pending", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId))
                        .Select(l => new {
                            id = l.Id, empId = l.EmployeeId, name = l.EmployeeName, type = l.LeaveType, range = $"{l.StartDate:MMM dd} - {l.EndDate:MMM dd}", reason = l.Reason
                        }).ToList();

                    var ot = (await otS.GetPendingRequestsAsync())
                        .Where(o => adminIds.Contains(o.EmployeeId))
                        .Select(o => new {
                            id = o.Id, empId = o.EmployeeId, name = o.EmployeeName, date = o.Date.ToString("MMM dd, yyyy"), 
                            startTime = o.StartTime, endTime = o.EndTime,
                            hours = o.RequestedHours, reason = o.Reason
                        }).ToList();

                    var ut = (await utS.GetAllPendingRequestsAsync())
                        .Where(u => adminIds.Contains(u.EmployeeId))
                        .Select(u => new {
                            id = u.Id, 
                            empId = u.EmployeeId, 
                            name = u.EmployeeName, 
                            date = u.Date.ToString("MMM dd, yyyy"), 
                            departureTime = u.RequestedDepartureTime ?? "Anytime",
                            reason = u.Reason
                        }).ToList();

                    var resign = (await resS.GetPendingResignationsAsync())
                        .Where(e => adminIds.Contains(e.EmployeeId))
                        .Select(e => new {
                            id = e.Id, empId = e.EmployeeId, name = e.FullName, hired = e.HiredDate.ToString("MMM dd, yyyy"), effective = e.ResignationDate?.ToString("MMM dd, yyyy") ?? "Pending"
                        }).ToList();

                    var concerns = (await conS.GetAllConcernsAsync())
                        .Where(c => (string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)) && adminIds.Contains(c.EmployeeId))
                        .Select(c => new {
                            id = c.Id, empId = c.EmployeeId, name = c.EmployeeName, subject = c.Subject, type = c.ConcernType, date = c.SubmittedDate.ToString("MMM dd, yyyy")
                        }).ToList();

                    var loans = (await new LoanService().GetAllLoansAsync())
                        .Where(l => string.Equals(l.Status, "PENDING", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId))
                        .Select(l => new {
                            id = l.Id, empId = l.EmployeeId, name = l.EmployeeName, type = l.LoanType, agency = l.Agency, date = l.RequestDate.ToString("MMM dd, yyyy")
                        }).ToList();

                    return serializer.Serialize(new { success = true, leaves, ot, ut, resign, concerns, loans, currentAdminId = currentAdminId });
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex) { return serializer.Serialize(new { success = false, message = ex.Message }); }
        }

        [WebMethod(EnableSession = true)]
        public static string ProcessApproval(string type, string id, bool isApprove)
        {
            var emp = HttpContext.Current?.Session["Employee"] as Employee;
            try
            {
                return Task.Run(async () => {
                    bool success = false;
                    string status = isApprove ? "Approved" : "Rejected";

                    if (type == "Leave") {
                        var leave = await new LeaveService().GetLeaveByIdAsync(id);
                        if (leave != null && emp != null && string.Equals(leave.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        success = await new LeaveService().UpdateLeaveStatusAsync(id, status);
                    }
                    else if (type == "OT") {
                        var ot = await new OvertimeService().GetByIdAsync(id);
                        if (ot != null && emp != null && string.Equals(ot.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        success = isApprove ? await new OvertimeService().ApproveAsync(id) : await new OvertimeService().RejectAsync(id);
                    }
                    else if (type == "UT") {
                        var ut = await new UndertimeService().GetRequestByIdAsync(id);
                        if (ut != null && emp != null && string.Equals(ut.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        success = isApprove ? await new UndertimeService().ApproveRequestAsync(id) : await new UndertimeService().RejectRequestAsync(id);
                    }
                    else if (type == "Resign") {
                        var target = await new EmployeeService().GetEmployeeByIdAsync(id);
                        if (target != null && emp != null && string.Equals(target.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        var update = MongoDB.Driver.Builders<Employee>.Update.Set(e => e.ResignationStatus, status);
                        success = await new EmployeeService().UpdateEmployeeFieldsAsync(id, update);
                    }
                    else if (type == "Concern") {
                        var concern = await new EmployeeConcernService().GetConcernByIdAsync(id);
                        if (concern != null && emp != null && string.Equals(concern.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        success = await new EmployeeConcernService().UpdateConcernStatusAsync(id, "Resolved");
                    }
                    else if (type == "Loan") {
                        var loan = await new LoanService().GetLoanByIdAsync(id);
                        if (loan != null && emp != null && string.Equals(loan.EmployeeId, emp.EmployeeId, StringComparison.OrdinalIgnoreCase)) return "{\"success\":false,\"message\":\"Self-approval not allowed\"}";
                        await new LoanService().UpdateLoanStatusAsync(id, status);
                        success = true;
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

        [WebMethod(EnableSession = true)]
        public static string FinalizeResignation(string id, string type, string forcedReason, string clearanceBase64)
        {
            var admin = HttpContext.Current?.Session["Employee"] as Employee;
            try
            {
                return Task.Run(async () => {
                    var empService = new EmployeeService();
                    var target = await empService.GetEmployeeByIdAsync(id);
                    if (target == null) return "{\"success\":false,\"message\":\"Employee not found or already inactive\"}";

                    string filePath = null;
                    if (type == "Standard" && !string.IsNullOrEmpty(clearanceBase64))
                    {
                        try {
                            byte[] bytes = Convert.FromBase64String(clearanceBase64);
                            string folder = HttpContext.Current.Server.MapPath("~/Uploads/ClearanceForms/");
                            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                            string fileName = $"Clearance_{target.EmployeeId}_{DateTime.Now:yyyyMMddHHmm}.pdf";
                            filePath = "/Uploads/ClearanceForms/" + fileName;
                            File.WriteAllBytes(folder + fileName, bytes);
                        } catch (Exception ex) {
                            return "{\"success\":false,\"message\":\"File upload failed: " + ex.Message + "\"}";
                        }
                    }

                    var update = Builders<Employee>.Update
                        .Set(e => e.ResignationStatus, "Approved")
                        .Set(e => e.IsActive, type == "Forced" ? false : true)
                        .Set(e => e.TerminationType, type)
                        .Set(e => e.ClearanceFormPath, filePath)
                        .Set(e => e.TerminationReason, type == "Forced" ? forcedReason : null)
                        .Set(e => e.ResignationLastDay, DateTime.UtcNow);

                    bool success = await empService.UpdateEmployeeFieldsAsync(id, update);
                    
                    if (success)
                    {
                        // 3. ONE-CLICK INSTANT SYSTEM LOCKOUT (Conditional)
                        // If it's a Forced termination, lockout is instant.
                        // If it's Standard but NO file was uploaded (Approval phase), we DON'T lockout yet 
                        // so they can download the form from their profile.
                        if (type == "Forced" || !string.IsNullOrEmpty(filePath))
                        {
                            var users = MongoDBHelper.GetUsersCollection();
                            await users.UpdateOneAsync(u => u.EmployeeId == target.EmployeeId, Builders<User>.Update.Set(u => u.IsActive, false));
                        }

                        // Log Activity to Audit Trail
                        var log = new ActivityLogService();
                        string actionDetail = type == "Standard" ? "Standard Termination with Clearance Form" : $"Forced Termination. Reason: {forcedReason}";
                        await log.LogActionAsync(admin?.Email ?? "President", admin?.FullName ?? "President", "Employee Terminated", "Resignation", $"Employee {target.FullName} ({target.EmployeeId}) status set to INACTIVE. {actionDetail}");
                    }

                    return "{\"success\":" + success.ToString().ToLower() + "}";
                }).GetAwaiter().GetResult();
            }
            catch (Exception ex) { return "{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}"; }
        }
        [System.Web.Services.WebMethod]
        public static object GetUpdatedCounts()
        {
            try
            {
                return Task.Run(async () => {
                    var usersCollection = MongoDBHelper.GetUsersCollection();
                    var adminFilter = Builders<User>.Filter.And(
                        Builders<User>.Filter.Regex(u => u.Role, new MongoDB.Bson.BsonRegularExpression("super admin", "i")),
                        Builders<User>.Filter.Eq(u => u.IsActive, true)
                    );
                    var adminIds = await usersCollection.Find(adminFilter).Project(u => u.EmployeeId).ToListAsync();

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
                    var loanTask = new LoanService().GetAllLoansAsync();

                    await Task.WhenAll(otTask, utTask, leavesTask, concernsTask, resignedTask, loanTask);

                    var pLeaves = leavesTask.Result?.Where(l => string.Equals(l.Status, "Pending", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId)).ToList() ?? new List<Leave>();
                    var pOT = otTask.Result?.Where(o => adminIds.Contains(o.EmployeeId)).ToList() ?? new List<OvertimeRequest>();
                    var pUT = utTask.Result?.Where(u => adminIds.Contains(u.EmployeeId)).ToList() ?? new List<UndertimeRequest>();
                    var pResign = resignedTask.Result?.Where(e => adminIds.Contains(e.EmployeeId)).ToList() ?? new List<Employee>();
                    var pConcerns = concernsTask.Result?.Where(c => (string.Equals(c.Status, "Submitted", StringComparison.OrdinalIgnoreCase) || string.Equals(c.Status, "In Progress", StringComparison.OrdinalIgnoreCase)) && adminIds.Contains(c.EmployeeId)).ToList() ?? new List<EmployeeConcern>();
                    var pLoans = loanTask.Result?.Where(l => string.Equals(l.Status, "PENDING", StringComparison.OrdinalIgnoreCase) && adminIds.Contains(l.EmployeeId)).ToList() ?? new List<LoanRequest>();

                    return new {
                        success = true,
                        leaveCount = pLeaves.Count,
                        otCount = pOT.Count,
                        utCount = pUT.Count,
                        resignCount = pResign.Count,
                        concernCount = pConcerns.Count,
                        loanCount = pLoans.Count
                    };
                }).GetAwaiter().GetResult();
            }
            catch
            {
                return new { success = false };
            }
        }

        protected void btnLoanReport_Click(object sender, EventArgs e)
        {
            try
            {
                var loanService = new LoanService();
                var loans = Task.Run(async () => await loanService.GetAllLoansAsync()).Result;

                var pdfService = new LoanReportPdfService();
                byte[] pdfBytes = pdfService.GenerateLoanHistoryReport(loans);

                ServePdf(pdfBytes, "Executive_Loan_Report");
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", $"alert('Error generating report: {ex.Message}');", true);
            }
        }

        private void ServePdf(byte[] pdfBytes, string fileNamePrefix)
        {
            if (pdfBytes != null)
            {
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", $"attachment;filename={fileNamePrefix}_{DateTime.Now:yyyyMMdd_HHmm}.pdf");
                Response.Buffer = true;
                Response.BinaryWrite(pdfBytes);
                Response.Flush();
                Response.SuppressContent = true;
                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
        }
    }
}

