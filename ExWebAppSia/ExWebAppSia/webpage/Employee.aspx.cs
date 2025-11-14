using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();

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
                var employees = await _employeeService.GetAllEmployeesAsync();
                var departmentCounts = await _employeeService.GetDepartmentCountsAsync();

                // Update department counts
                UpdateDepartmentCounts(departmentCounts);

                // Populate employee table
                PopulateEmployeeTable(employees);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employees: {ex.Message}");
            }
        }

        private void UpdateDepartmentCounts(Dictionary<string, int> counts)
        {
            // Update the literal controls for each department
            if (litRDCount != null) litRDCount.Text = GetCount(counts, "Research & Development").ToString();
            if (litQCCount != null) litQCCount.Text = GetCount(counts, "Quality Control").ToString();
            if (litHRCount != null) litHRCount.Text = GetCount(counts, "Human Resources").ToString();
            if (litFinanceCount != null) litFinanceCount.Text = GetCount(counts, "Finance").ToString();
            if (litMarketingCount != null) litMarketingCount.Text = GetCount(counts, "Marketing").ToString();
            if (litITCount != null) litITCount.Text = GetCount(counts, "IT Support").ToString();
            if (litOperationsCount != null) litOperationsCount.Text = GetCount(counts, "Operations").ToString();
            if (litSalesCount != null) litSalesCount.Text = GetCount(counts, "Sales").ToString();
            if (litLegalCount != null) litLegalCount.Text = GetCount(counts, "Legal").ToString();
            if (litCustomerServiceCount != null) litCustomerServiceCount.Text = GetCount(counts, "Customer Service").ToString();
        }

        private int GetCount(Dictionary<string, int> counts, string key)
        {
            return counts.ContainsKey(key) ? counts[key] : 0;
        }

        private void PopulateEmployeeTable(List<Employee> employees)
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

            var sb = new StringBuilder();
            foreach (var employee in employees)
            {
                string employeeId = Server.HtmlEncode(employee.Id);
                string dept = Server.HtmlEncode(employee.Department ?? "");
                
                sb.AppendFormat("<tr data-dept='{0}' style='cursor: pointer;' onclick=\"document.getElementById('{1}').value = '{2}'; __doPostBack('{3}', ''); return false;\">", 
                    dept, 
                    hdnEmployeeId.ClientID, 
                    employeeId, 
                    btnViewEmployeeDetails.UniqueID);
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.EmployeeId));
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.FullName));
                sb.AppendFormat("<td>{0}</td>", dept);
                sb.AppendFormat("<td>{0}</td>", Server.HtmlEncode(employee.Role ?? ""));
                sb.Append("</tr>");
            }

            employeeTableBody.InnerHtml = sb.ToString();
        }

        protected async void btnViewEmployeeDetails_Click(object sender, EventArgs e)
        {
            try
            {
                string employeeId = hdnEmployeeId.Value;
                if (string.IsNullOrEmpty(employeeId))
                {
                    return;
                }

                var employee = await _employeeService.GetEmployeeByIdAsync(employeeId);
                if (employee != null)
                {
                    DisplayEmployeeDetails(employee);
                    ScriptManager.RegisterStartupScript(this, GetType(), "openEmployeeDetailsModal", 
                        "document.getElementById('viewEmployeeDetailsModal').style.display = 'block';", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading employee details: {ex.Message}");
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
            sb.Append("</table>");

            sb.Append("</div>");

            // Action Cards
            sb.Append("<div class='actions-grid'>");
            
            // View Payslip Card
            sb.Append("<div class='action-card' onclick='openPayslipModal()'>");
            sb.Append("<div class='action-icon'>💰</div>");
            sb.Append("<h3 class='action-title'>View Payslip</h3>");
            sb.Append("<p class='action-description'>View your salary breakdown including gross salary, deductions, and net pay.</p>");
            sb.Append("<button class='action-button'>View Details</button>");
            sb.Append("</div>");

            // History Leave Card
            sb.AppendFormat("<div class='action-card' onclick='openLeaveHistoryModal(\"{0}\")'>", Server.HtmlEncode(employee.Id));
            sb.Append("<div class='action-icon'>📝</div>");
            sb.Append("<h3 class='action-title'>History Leave of Absence</h3>");
            sb.Append("<p class='action-description'>View the leave history including sick leave, vacation, and personal matters.</p>");
            sb.Append("<button class='action-button'>View History</button>");
            sb.Append("</div>");

            // History Concern Card
            sb.AppendFormat("<div class='action-card' onclick='openConcernHistoryModal(\"{0}\")'>", Server.HtmlEncode(employee.Id));
            sb.Append("<div class='action-icon'>💬</div>");
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

                var leaves = await _leaveService.GetLeavesByEmployeeIdAsync(employeeId);
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

                var concerns = await _concernService.GetConcernsByEmployeeIdAsync(employeeId);
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
                    string priorityColor = concern.PriorityLevel == "Urgent" ? "#ef4444" : 
                                          concern.PriorityLevel == "High" ? "#f59e0b" : 
                                          concern.PriorityLevel == "Medium" ? "#3b82f6" : "#10b981";
                    
                    string statusColor = concern.Status == "Resolved" ? "#10b981" : 
                                        concern.Status == "Closed" ? "#6b7280" : 
                                        concern.Status == "In Progress" ? "#3b82f6" : "#f59e0b";
                    
                    sb.Append("<div style='background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid " + priorityColor + ";'>");
                    sb.AppendFormat("<div style='display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;'>");
                    sb.AppendFormat("<div><strong style='color: #333; font-size: 16px;'>{0}</strong></div>", Server.HtmlEncode(concern.Subject ?? ""));
                    sb.AppendFormat("<div style='display: flex; gap: 8px; flex-wrap: wrap;'>");
                    sb.AppendFormat("<span style='background: {0}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;'>{1}</span>", priorityColor, Server.HtmlEncode(concern.PriorityLevel ?? ""));
                    sb.AppendFormat("<span style='background: {0}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;'>{1}</span>", statusColor, Server.HtmlEncode(concern.Status ?? ""));
                    sb.Append("</div></div>");
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Type:</strong> {0}</div>", Server.HtmlEncode(concern.ConcernType ?? ""));
                    sb.AppendFormat("<div style='margin-bottom: 8px; color: #666;'><strong>Description:</strong> {0}</div>", Server.HtmlEncode(concern.Description ?? ""));
                    sb.AppendFormat("<div style='color: #999; font-size: 12px;'><strong>Submitted:</strong> {0}</div>", concern.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
                    sb.Append("</div>");
                }
            }

            sb.Append("</div>");
            concernHistoryContent.InnerHtml = sb.ToString();
        }
    }
}