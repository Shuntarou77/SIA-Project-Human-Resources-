using MongoDB.Driver;
using System;
using System.Web;
using System.Web.SessionState;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using ExWebAppSia.Models;

namespace ExWebAppSia.Handler
{
    public class LoanHandler : HttpTaskAsyncHandler, IRequiresSessionState
    {
        private readonly LoanService _loanService = new LoanService();

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string action = context.Request.QueryString["action"];

            try
            {
                switch (action)
                {
                    case "getall":
                        await GetAllLoans(context);
                        break;
                    case "getbyemployee":
                        await GetLoansByEmployee(context);
                        break;
                    case "create":
                        await CreateLoan(context);
                        break;
                    case "updatestatus":
                        await UpdateStatus(context);
                        break;
                    default:
                        context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Invalid action" }));
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = ex.Message }));
            }
        }

        private async Task GetAllLoans(HttpContext context)
        {
            var loans = await _loanService.GetAllLoansAsync();

            var currentAdmin = context.Session["Employee"] as Employee;
            bool isCurrentAdminHR = currentAdmin != null && 
                (string.Equals(currentAdmin.Department, "Human Resources", StringComparison.OrdinalIgnoreCase) || 
                 string.Equals(currentAdmin.Department, "HR", StringComparison.OrdinalIgnoreCase));

            // Filter out Super Admin and President roles
            var empService = new EmployeeService();
            var allEmps = await empService.GetAllEmployeesAsync();
            // Get restricted IDs from both Employee Role and User Role for maximum security
            var usersCollection = MongoDBHelper.GetUsersCollection();
            var restrictedUserIds = usersCollection.Find(u => (u.Role == "Super Admin" || u.Role == "President") && u.IsActive)
                                                 .Project(u => u.EmployeeId)
                                                 .ToList();

            var restrictedIds = new HashSet<string>(restrictedUserIds, StringComparer.OrdinalIgnoreCase);
            
            // Add any additional employees whose record role contains restricted terms
            foreach (var e in allEmps.Where(e => {
                var r = (e.Role ?? "").ToLowerInvariant().Trim();
                var d = (e.Department ?? "").ToLowerInvariant().Trim();
                
                bool isExecutive = r.Contains("super admin") || r.Contains("superadmin") || r.Contains("president");
                bool isHRStaff = d == "human resources" || d == "hr";
                
                return isExecutive || (isCurrentAdminHR && isHRStaff);
            }))
            {
                restrictedIds.Add(e.EmployeeId);
            }

            var filteredLoans = new List<LoanRequest>();
            foreach (var loan in loans)
            {
                if (!string.IsNullOrEmpty(loan.EmployeeId) && !restrictedIds.Contains(loan.EmployeeId))
                {
                    // Restrict self-requests
                    if (currentAdmin != null && string.Equals(loan.EmployeeId, currentAdmin.EmployeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }
                    filteredLoans.Add(loan);
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = filteredLoans }));
        }

        private async Task GetLoansByEmployee(HttpContext context)
        {
            string employeeId = context.Request.QueryString["employeeId"];
            var loans = await _loanService.GetLoansByEmployeeIdAsync(employeeId);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, data = loans }));
        }

        private async Task CreateLoan(HttpContext context)
        {
            string employeeId = context.Request.Form["employeeId"];
            string employeeName = context.Request.Form["employeeName"];
            string loanType = context.Request.Form["loanType"];
            string agency = context.Request.Form["agency"];
            string remarks = context.Request.Form["remarks"];

            var loan = new LoanRequest
            {
                EmployeeId = employeeId,
                EmployeeName = employeeName,
                LoanType = loanType,
                Agency = agency,
                Remarks = remarks,
                Status = "PENDING",
                RequestDate = DateTime.Now
            };

            await _loanService.CreateLoanAsync(loan);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Loan record created" }));
        }

        private async Task UpdateStatus(HttpContext context)
        {
            string id = context.Request.Form["id"];
            string status = context.Request.Form["status"];

            // Self-approval restriction
            var currentAdmin = context.Session["Employee"] as Employee;
            var currentAdminId = currentAdmin?.EmployeeId;

            var loan = await _loanService.GetLoanByIdAsync(id);
            if (loan != null && !string.IsNullOrEmpty(currentAdminId) && string.Equals(loan.EmployeeId, currentAdminId, StringComparison.OrdinalIgnoreCase))
            {
                context.Response.Write(JsonConvert.SerializeObject(new { success = false, message = "Security Error: You cannot approve or decline your own loan requests." }));
                return;
            }

            await _loanService.UpdateLoanStatusAsync(id, status);
            context.Response.Write(JsonConvert.SerializeObject(new { success = true, message = "Loan status updated to " + status }));
        }
    }
}
