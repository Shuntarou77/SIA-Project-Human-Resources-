using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class WebForm5 : System.Web.UI.Page
    {
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly InterviewService _interviewService = new InterviewService();
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ManagerService _managerService = new ManagerService();
        private readonly UserService _userService = new UserService();
        private readonly EmailService _emailService = new EmailService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadApplicantsData));
            }
        }

        protected async void btnAddApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                // Determine hiring type
                string selectedHiringType = string.IsNullOrEmpty(rblHiringType.SelectedValue) ? "Employee" : rblHiringType.SelectedValue;

                // Validate required fields
                if (string.IsNullOrEmpty(txtFirstName.Text.Trim()) || 
                    string.IsNullOrEmpty(txtLastName.Text.Trim()) || 
                    string.IsNullOrEmpty(ddlAppliedPosition.SelectedValue) ||
                    string.IsNullOrEmpty(hdnSelectedRole.Value) ||
                    string.IsNullOrEmpty(ddlHowDidYouHearUs.SelectedValue))
                {
                    ShowMessage("Please fill in all required fields.", false);
                    return;
                }

                if (selectedHiringType == "Manager" && string.IsNullOrWhiteSpace(txtEmail.Text.Trim()))
                {
                    ShowMessage("Manager applicants must include an email address.", false);
                    return;
                }

                // Create applicant object
                var applicant = new Applicant
                {
                    FirstName = txtFirstName.Text.Trim(),
                    MiddleName = txtMiddleName.Text.Trim(),
                    LastName = txtLastName.Text.Trim(),
                    Email = txtEmail.Text.Trim(),
                    ContactNo = txtContactNo.Text.Trim(),
                    Address = txtAddress.Text.Trim(),
                    Education = txtEducation.Text.Trim(),
                    Age = !string.IsNullOrEmpty(txtAge.Text.Trim()) ? int.Parse(txtAge.Text.Trim()) : (int?)null,
                    BirthDate = !string.IsNullOrEmpty(txtBirthDate.Text.Trim()) ? DateTime.Parse(txtBirthDate.Text.Trim()) : (DateTime?)null,
                    Gender = ddlGender.SelectedValue,
                    HasPreviousCompany = chkPreviousCompany.Checked,
                    PreviousCompanyName = txtCompanyName.Text.Trim(),
                    JobIndustry = txtJobIndustry.Text.Trim(),
                    PreviousPosition = txtPreviousPosition.Text.Trim(),
                    Years = !string.IsNullOrEmpty(txtYears.Text.Trim()) ? int.Parse(txtYears.Text.Trim()) : (int?)null,
                    Months = !string.IsNullOrEmpty(txtMonths.Text.Trim()) ? int.Parse(txtMonths.Text.Trim()) : (int?)null,
                    GuardianName = txtGuardianName.Text.Trim(),
                    GuardianContactNo = txtGuardianContactNo.Text.Trim(),
                    GuardianEmail = txtGuardianEmail.Text.Trim(),
                    GuardianHomeAddress = txtGuardianHomeAddress.Text.Trim(),
                    AppliedPosition = ddlAppliedPosition.SelectedValue,
                    Role = hdnSelectedRole.Value,
                    HowDidYouHearUs = ddlHowDidYouHearUs.SelectedValue,
                    ReferralName = txtReferralName.Text.Trim(),
                    ContractType = rblContractType.SelectedValue ?? "Regular",
                    HiringType = selectedHiringType
                };

                bool success = await _applicantService.CreateApplicantAsync(applicant);
                if (success)
                {
                    ShowMessage("Applicant added successfully!", true);
                    ClearForm();
                    await LoadApplicantsData();
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeModalAndRefresh", 
                        "setTimeout(function() { closeModal(); window.location.reload(); }, 1500);", true);
                }
                else
                {
                    ShowMessage("Failed to add applicant.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, false);
            }
        }

        protected async void btnViewDetails_Click(object sender, EventArgs e)
        {
            try
            {
                string applicantId = hdnApplicantId.Value;
                if (string.IsNullOrEmpty(applicantId)) return;

                var applicant = await _applicantService.GetApplicantByIdAsync(applicantId);
                if (applicant != null)
                {
                    DisplayApplicantDetails(applicant);
                    ScriptManager.RegisterStartupScript(this, GetType(), "openDetailsModal", 
                        "document.getElementById('viewDetailsModal').style.display = 'block';", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
            }
        }

        private void DisplayApplicantDetails(Applicant applicant)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='padding: 20px;'>");
            
            // Personal Info
            sb.Append("<h3 style='color: var(--accent); margin-bottom: 15px; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Personal Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Full Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.FullName));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Email:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Email ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contact:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ContactNo ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Address ?? ""));
            sb.Append("</table>");

            // Application Info
            sb.Append("<h3 style='color: var(--accent); margin: 20px 0 15px 0; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Application Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Position:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.AppliedPosition ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Role:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Role ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Status:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Status ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Date:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.AppliedDate.ToLocalTime().ToString("MMM dd, yyyy"));
            sb.Append("</table>");

            sb.Append("</div>");
            applicantDetailsContent.InnerHtml = sb.ToString();
        }

        private void ClearForm()
        {
            txtFirstName.Text = ""; txtLastName.Text = ""; txtEmail.Text = ""; ddlAppliedPosition.SelectedIndex = 0;
            hdnSelectedRole.Value = ""; ddlHowDidYouHearUs.SelectedIndex = 0;
        }

        private async Task LoadApplicantsData()
        {
            try
            {
                // Parallelized performance optimization
                var tasks = new List<Task>();
                var newApplicantsTask = _applicantService.GetNewApplicantsAsync();
                var approvedApplicantsTask = _applicantService.GetApprovedApplicantsAsync();
                var declinedApplicantsTask = _applicantService.GetDeclinedApplicantsAsync();
                var inProgressApplicantsTask = _applicantService.GetInProgressApplicantsAsync();
                
                var newCountTask = _applicantService.GetCountByStatusAsync("New");
                var inProgressCountTask = _applicantService.GetCountByStatusAsync("In-Progress");
                var approvedCountTask = _applicantService.GetCountByStatusAsync("Approved");
                var declinedCountTask = _applicantService.GetCountByStatusAsync("Declined");

                await Task.WhenAll(
                    newApplicantsTask, 
                    approvedApplicantsTask, 
                    declinedApplicantsTask, 
                    inProgressApplicantsTask,
                    newCountTask,
                    inProgressCountTask,
                    approvedCountTask,
                    declinedCountTask
                );

                PopulateNewApplicantsTable(newApplicantsTask.Result);
                PopulateApprovedApplicantsTable(approvedApplicantsTask.Result);
                PopulateDeclinedApplicantsTable(declinedApplicantsTask.Result);
                await PopulateInProgressApplicantsTableAsync(inProgressApplicantsTask.Result);

                int newCount = newCountTask.Result;
                int inProgressCount = inProgressCountTask.Result;
                int approvedCount = approvedCountTask.Result;
                int declinedCount = declinedCountTask.Result;

                if(litNewCount != null) litNewCount.Text = (newCount + inProgressCount).ToString();
                if(litInProgressCount != null) litInProgressCount.Text = inProgressCount.ToString();
                if(litNewSubCount != null) litNewSubCount.Text = newCount.ToString();
                if(litApprovedCount != null) litApprovedCount.Text = approvedCount.ToString();
                if(litDeclinedCount != null) litDeclinedCount.Text = declinedCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
            }
        }

        private void PopulateNewApplicantsTable(List<Applicant> applicants)
        {
            if (applicants == null || applicants.Count == 0)
            {
                newApplicantsTableBody.InnerHtml = "<tr><td colspan='4' class='empty-state'>No new applicants found</td></tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                string id = Server.HtmlEncode(applicant.Id);
                sb.AppendFormat(@"<tr>
                    <td></td>
                    <td><strong>{0}</strong></td>
                    <td>{1}</td>
                    <td style='text-align: center;'>
                        <div class='action-buttons'>
                            <button class='btn btn-view-details' onclick=""viewApplicantDetails('{2}'); return false;"">View</button>
                            <button class='btn btn-approve' onclick=""approveApplicant('{2}', this); return false;"">Approve</button>
                            <button class='btn btn-decline' onclick=""declineApplicant('{2}', this); return false;"">Decline</button>
                        </div>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), id);
            }
            newApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private void PopulateApprovedApplicantsTable(List<Applicant> applicants)
        {
            if (applicants == null || applicants.Count == 0)
            {
                approvedApplicantsTableBody.InnerHtml = "<tr><td colspan='4' class='empty-state'>No approved applicants</td></tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                sb.AppendFormat(@"<tr>
                    <td class='checkbox-cell'><input type='checkbox' value='{2}' class='applicant-checkbox' /></td>
                    <td><strong>{0}</strong></td>
                    <td>{1}</td>
                    <td style='text-align: center;'>
                        <span class='status-badge status-approved'>Approved</span>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"" style='margin-left: 12px;'>View Details</a>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), Server.HtmlEncode(applicant.Id));
            }
            approvedApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private void PopulateDeclinedApplicantsTable(List<Applicant> applicants)
        {
            if (applicants == null || applicants.Count == 0)
            {
                declinedApplicantsTableBody.InnerHtml = "<tr><td colspan='3' class='empty-state'>No declined applicants</td></tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                sb.AppendFormat(@"<tr>
                    <td><strong>{0}</strong></td>
                    <td>{1}</td>
                    <td style='text-align: center;'>
                        <span class='status-badge status-declined'>Declined</span>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"" style='margin-left: 12px;'>View Details</a>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), Server.HtmlEncode(applicant.Id));
            }
            declinedApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private async Task PopulateInProgressApplicantsTableAsync(List<Applicant> applicants)
        {
            if (applicants == null || applicants.Count == 0)
            {
                inProgressApplicantsTableBody.InnerHtml = "<tr><td colspan='4' class='empty-state'>No in-progress applicants</td></tr>";
                return;
            }

            // Optimization: Fetch all employee records in one go to check hiring status
            var employees = await _employeeService.GetAllEmployeesAsync();
            var hiredApplicantIds = new HashSet<string>(employees.Where(e => !string.IsNullOrEmpty(e.ApplicantId)).Select(e => e.ApplicantId));

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                bool isHired = hiredApplicantIds.Contains(applicant.Id);
                string hireText = isHired ? "Already Hired" : "Hire";
                string disabled = isHired ? "disabled" : "";
                string onclick = isHired ? "" : string.Format("hireApplicant('{0}', this); return false;", Server.HtmlEncode(applicant.Id));

                sb.AppendFormat(@"<tr>
                    <td><strong>{0}</strong></td>
                    <td>{1}</td>
                    <td style='text-align: center;'>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"">View Details</a>
                    </td>
                    <td style='text-align: center;'>
                        <div class='action-buttons'>
                            <button class='btn btn-hire' {3} onclick=""{4}"">{5}</button>
                            <button class='btn btn-not-hire' onclick=""notHireApplicant('{2}', this); return false;"">Not Hired</button>
                        </div>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), Server.HtmlEncode(applicant.Id), disabled, onclick, hireText);
            }
            inProgressApplicantsTableBody.InnerHtml = sb.ToString();
        }

        protected async void btnHireApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                string applicantId = hdnApplicantId.Value;
                if (string.IsNullOrEmpty(applicantId)) return;

                var applicant = await _applicantService.GetApplicantByIdAsync(applicantId);
                if (applicant == null) return;

                // Simple check for existing employee
                var existing = await _employeeService.GetEmployeeByApplicantIdAsync(applicantId);
                if (existing != null)
                {
                    await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                    await LoadApplicantsData();
                    return;
                }

                // Create employee
                var employee = new Employee
                {
                    FirstName = applicant.FirstName,
                    MiddleName = applicant.MiddleName,
                    LastName = applicant.LastName,
                    Email = applicant.Email,
                    Department = applicant.AppliedPosition,
                    Role = applicant.Role,
                    ApplicantId = applicantId,
                    HiredDate = DateTime.UtcNow,
                    IsActive = true
                };

                var created = await _employeeService.CreateEmployeeAndReturnAsync(employee);
                if (created != null)
                {
                    await _userService.EnsureEmployeeAccountAsync(created.Email, created.EmployeeId, created.FirstName, created.LastName);
                    await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                    await _emailService.SendHiredEmailAsync(created.Email, created.FullName, created.Department, created.Role, created.Email, created.EmployeeId, false);
                    await LoadApplicantsData();
                    ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccess", "alert('Employee hired successfully!'); window.location.reload();", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            if (messageDiv != null)
            {
                messageDiv.InnerText = message;
                messageDiv.Attributes["class"] = isSuccess ? "message success" : "message error";
                messageDiv.Style["display"] = "block";
            }
        }
        
        // Stubs for other handlers to match existing UI
        protected void btnScheduleInterview_Click(object sender, EventArgs e) { }
        protected void btnApproveApplicant_Click(object sender, EventArgs e) { }
        protected void btnDeclineApplicant_Click(object sender, EventArgs e) { }
        protected void btnNotHireApplicant_Click(object sender, EventArgs e) { }
    }
}
