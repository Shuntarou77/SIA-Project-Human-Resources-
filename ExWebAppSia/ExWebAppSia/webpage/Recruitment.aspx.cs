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
                System.Diagnostics.Debug.WriteLine("=== btnAddApplicant_Click started ===");
                System.Diagnostics.Debug.WriteLine($"FirstName: {txtFirstName.Text}");
                System.Diagnostics.Debug.WriteLine($"LastName: {txtLastName.Text}");
                System.Diagnostics.Debug.WriteLine($"AppliedPosition: {ddlAppliedPosition.SelectedValue}");
                System.Diagnostics.Debug.WriteLine($"Role (from hidden field): {hdnSelectedRole.Value}");
                System.Diagnostics.Debug.WriteLine($"HowDidYouHearUs: {ddlHowDidYouHearUs.SelectedValue}");

                // Validate required fields
                if (string.IsNullOrEmpty(txtFirstName.Text.Trim()) || 
                    string.IsNullOrEmpty(txtLastName.Text.Trim()) || 
                    string.IsNullOrEmpty(ddlAppliedPosition.SelectedValue) ||
                    string.IsNullOrEmpty(hdnSelectedRole.Value) ||
                    string.IsNullOrEmpty(ddlHowDidYouHearUs.SelectedValue))
                {
                    ShowMessage("Please fill in all required fields (First Name, Last Name, Applied Position, Role, How did you hear us?).", false);
                    System.Diagnostics.Debug.WriteLine("Validation failed - missing required fields");
                    return;
                }

                // Create applicant object
                var applicant = new Applicant
                {
                    // Personal Info
                    FirstName = txtFirstName.Text.Trim(),
                    MiddleName = txtMiddleName.Text.Trim(),
                    LastName = txtLastName.Text.Trim(),
                    Email = txtEmail.Text.Trim(),
                    ContactNo = txtContactNo.Text.Trim(),
                    Address = txtAddress.Text.Trim(),
                    Education = txtEducation.Text.Trim(),
                    
                    // Age
                    Age = !string.IsNullOrEmpty(txtAge.Text.Trim()) ? int.Parse(txtAge.Text.Trim()) : (int?)null,
                    
                    // Birthdate
                    BirthDate = !string.IsNullOrEmpty(txtBirthDate.Text.Trim()) ? DateTime.Parse(txtBirthDate.Text.Trim()) : (DateTime?)null,
                    
                    // Gender
                    Gender = ddlGender.SelectedValue,
                    
                    // Previous Company
                    HasPreviousCompany = chkPreviousCompany.Checked,
                    PreviousCompanyName = txtCompanyName.Text.Trim(),
                    JobIndustry = txtJobIndustry.Text.Trim(),
                    PreviousPosition = txtPreviousPosition.Text.Trim(),
                    Years = !string.IsNullOrEmpty(txtYears.Text.Trim()) ? int.Parse(txtYears.Text.Trim()) : (int?)null,
                    Months = !string.IsNullOrEmpty(txtMonths.Text.Trim()) ? int.Parse(txtMonths.Text.Trim()) : (int?)null,
                    
                    // Guardian Info
                    GuardianName = txtGuardianName.Text.Trim(),
                    GuardianContactNo = txtGuardianContactNo.Text.Trim(),
                    GuardianEmail = txtGuardianEmail.Text.Trim(),
                    GuardianHomeAddress = txtGuardianHomeAddress.Text.Trim(),
                    
                    // Application Info
                    AppliedPosition = ddlAppliedPosition.SelectedValue,
                    Role = hdnSelectedRole.Value,
                    HowDidYouHearUs = ddlHowDidYouHearUs.SelectedValue,
                    ReferralName = txtReferralName.Text.Trim(),
                    
                    // Contract Type
                    ContractType = rbContractual.Checked ? "Contractual" : "Regular",
                    
                    // Hiring Type
                    HiringType = ddlHiringType.SelectedValue
                };

                // Add applicant to database
                System.Diagnostics.Debug.WriteLine($"Attempting to save applicant: {applicant.FirstName} {applicant.LastName}");
                System.Diagnostics.Debug.WriteLine($"Department: {applicant.AppliedPosition}, Role: {applicant.Role}");
                
                bool success = await _applicantService.CreateApplicantAsync(applicant);
                
                System.Diagnostics.Debug.WriteLine($"Save result: {success}");

                if (success)
                {
                    ShowMessage("Applicant added successfully!", true);
                    System.Diagnostics.Debug.WriteLine("Applicant saved successfully to database");
                    
                    // Clear form
                    ClearForm();

                    // Reload data
                    await LoadApplicantsData();

                    // Close modal after a short delay and refresh page
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeModalAndRefresh", 
                        "setTimeout(function() { closeModal(); window.location.reload(); }, 1500);", true);
                }
                else
                {
                    ShowMessage("Failed to add applicant. Please try again.", false);
                    System.Diagnostics.Debug.WriteLine("Failed to save applicant to database");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, false);
                System.Diagnostics.Debug.WriteLine($"Error adding applicant: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
            }
        }

        protected async void btnViewDetails_Click(object sender, EventArgs e)
        {
            try
            {
                string applicantId = hdnApplicantId.Value;
                if (string.IsNullOrEmpty(applicantId))
                {
                    return;
                }

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
                System.Diagnostics.Debug.WriteLine($"Error loading applicant details: {ex.Message}");
            }
        }

        private void DisplayApplicantDetails(Applicant applicant)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='padding: 20px;'>");
            
            // Personal Info
            sb.Append("<h3 style='color: var(--accent); margin-bottom: 15px; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Personal Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>First Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.FirstName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Middle Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.MiddleName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Last Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.LastName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Age:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.Age.HasValue ? applicant.Age.Value.ToString() : "");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Birthdate:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.BirthDate.HasValue ? applicant.BirthDate.Value.ToLocalTime().ToString("MMM dd, yyyy") : "");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Gender:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Gender ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Email Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Email ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contact No.:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ContactNo ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Address ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Education:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Education ?? ""));
            sb.Append("</table>");

            // Previous Company
            if (applicant.HasPreviousCompany)
            {
                sb.Append("<h3 style='color: var(--accent); margin: 20px 0 15px 0; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Previous Company</h3>");
                sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Company Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.PreviousCompanyName ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Job Industry:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.JobIndustry ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Years:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.Years.HasValue ? applicant.Years.Value.ToString() : "");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Months:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.Months.HasValue ? applicant.Months.Value.ToString() : "");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Position:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.PreviousPosition ?? ""));
                sb.Append("</table>");
            }

            // Guardian Info
            sb.Append("<h3 style='color: var(--accent); margin: 20px 0 15px 0; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Guardian Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Guardian Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianName ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contact No.:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianContactNo ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Email Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianEmail ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Home Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianHomeAddress ?? ""));
            sb.Append("</table>");

            // Application Info
            sb.Append("<h3 style='color: var(--accent); margin: 20px 0 15px 0; border-bottom: 2px solid var(--border-color); padding-bottom: 8px;'>Application Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Applied Position (Department):</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.AppliedPosition ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Role (Job Title):</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Role ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>How did you hear us?:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.HowDidYouHearUs ?? ""));
            if (!string.IsNullOrEmpty(applicant.ReferralName))
            {
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Referral Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ReferralName));
            }
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Contract Type:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ContractType ?? "Regular"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Status:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Status ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: bold;'>Applied Date:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.AppliedDate.ToLocalTime().ToString("MMM dd, yyyy h:mm tt"));
            sb.Append("</table>");

            sb.Append("</div>");
            applicantDetailsContent.InnerHtml = sb.ToString();
        }

        private void ClearForm()
        {
            txtFirstName.Text = "";
            txtMiddleName.Text = "";
            txtLastName.Text = "";
            txtAge.Text = "";
            txtBirthDate.Text = "";
            ddlGender.SelectedIndex = 0;
            txtEmail.Text = "";
            txtContactNo.Text = "";
            txtAddress.Text = "";
            txtEducation.Text = "";
            chkPreviousCompany.Checked = false;
            txtCompanyName.Text = "";
            txtJobIndustry.Text = "";
            txtYears.Text = "";
            txtMonths.Text = "";
            txtPreviousPosition.Text = "";
            txtGuardianName.Text = "";
            txtGuardianContactNo.Text = "";
            txtGuardianEmail.Text = "";
            txtGuardianHomeAddress.Text = "";
            ddlAppliedPosition.SelectedIndex = 0;
            hdnSelectedRole.Value = "";
            ddlHowDidYouHearUs.SelectedIndex = 0;
            txtReferralName.Text = "";
            rbRegular.Checked = true;
            rbContractual.Checked = false;
            ddlHiringType.SelectedIndex = 1; // Default to Employee
        }

        private async Task LoadApplicantsData()
        {
            try
            {
                // Load new applicants
                var newApplicants = await _applicantService.GetNewApplicantsAsync();
                PopulateNewApplicantsTable(newApplicants);

                // Load in-progress applicants
                var inProgressApplicants = await _applicantService.GetInProgressApplicantsAsync();
                await PopulateInProgressApplicantsTableAsync(inProgressApplicants);

                // Update stat counts
                int newCount = await _applicantService.GetCountByStatusAsync("New");
                int inProgressCount = await _applicantService.GetCountByStatusAsync("In-Progress");

                litNewCount.Text = newCount.ToString();
                litInProgressCount.Text = inProgressCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading applicants: {ex.Message}");
            }
        }

        private void PopulateNewApplicantsTable(List<Applicant> applicants)
        {
            newApplicantsTableBody.Controls.Clear();

            if (applicants == null || applicants.Count == 0)
            {
                newApplicantsTableBody.InnerHtml = @"
                    <tr>
                        <td colspan=""4"" style=""text-align: center; padding: 20px; color: #999;"">
                            No new applicants found.
                        </td>
                    </tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                string fullName = Server.HtmlEncode(applicant.FullName);
                string position = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string applicantId = Server.HtmlEncode(applicant.Id);

                sb.Append($@"
                    <tr>
                        <td class=""checkbox-cell"">
                            <input type=""checkbox"" value=""{applicantId}"" class=""applicant-checkbox"" />
                        </td>
                        <td>{fullName}</td>
                        <td>{position}</td>
                        <td>
                            <a href=""#"" class=""status-link"" onclick=""document.getElementById('{hdnApplicantId.ClientID}').value = '{applicantId}'; __doPostBack('{btnViewDetails.UniqueID}', ''); return false;"">View Details</a>
                        </td>
                    </tr>");
            }

            newApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private async Task PopulateInProgressApplicantsTableAsync(List<Applicant> applicants)
        {
            inProgressApplicantsTableBody.Controls.Clear();

            if (applicants == null || applicants.Count == 0)
            {
                inProgressApplicantsTableBody.InnerHtml = @"
                    <tr>
                        <td colspan=""4"" style=""text-align: center; padding: 20px; color: #999;"">
                            No in-progress applicants found.
                        </td>
                    </tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                string fullName = Server.HtmlEncode(applicant.FullName);
                string position = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string applicantId = Server.HtmlEncode(applicant.Id);
                
                // Check if employee exists (most reliable way to determine if hired)
                var existingEmployee = await _employeeService.GetEmployeeByApplicantIdAsync(applicant.Id);
                bool isHired = existingEmployee != null;
                
                string hireButtonDisabled = isHired ? "disabled" : "";
                string hireButtonText = isHired ? "Already Hired" : "Hire";
                string hireButtonStyle = isHired ? "opacity: 0.6; cursor: not-allowed; margin-right: 5px;" : "margin-right: 5px;";
                string hireButtonOnclick = isHired ? "" : $"var btn = this; btn.disabled = true; btn.textContent = 'Processing...'; document.getElementById('{hdnApplicantId.ClientID}').value = '{applicantId}'; __doPostBack('{btnHireApplicant.UniqueID}', ''); return false;";

                sb.Append($@"
                    <tr>
                        <td>{fullName}</td>
                        <td>{position}</td>
                        <td style=""text-align: center;"">
                            <a href=""#"" class=""status-link"" onclick=""document.getElementById('{hdnApplicantId.ClientID}').value = '{applicantId}'; __doPostBack('{btnViewDetails.UniqueID}', ''); return false;"">View Details</a>
                        </td>
                        <td style=""text-align: center;"">
                            <button type=""button"" class=""btn-hire"" {hireButtonDisabled} onclick=""{hireButtonOnclick}"" style=""{hireButtonStyle}"">{hireButtonText}</button>
                            <button type=""button"" class=""btn-not-hire"" onclick=""var btn = this; btn.disabled = true; btn.textContent = 'Processing...'; document.getElementById('{hdnApplicantId.ClientID}').value = '{applicantId}'; __doPostBack('{btnNotHireApplicant.UniqueID}', ''); return false;"">Not Hired</button>
                        </td>
                    </tr>");
            }

            inProgressApplicantsTableBody.InnerHtml = sb.ToString();
        }

        protected async void btnScheduleInterview_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("=== Schedule Interview Button Clicked ===");
            try
            {
                // Get selected applicant IDs
                string selectedIds = hdnSelectedApplicantIds.Value;
                System.Diagnostics.Debug.WriteLine($"Selected Applicant IDs: {selectedIds}");
                if (string.IsNullOrEmpty(selectedIds))
                {
                    ShowScheduleMessage("No applicants selected. Please select at least one applicant.", false);
                    return;
                }

                // Validate required fields
                if (string.IsNullOrEmpty(txtInterviewDate.Text.Trim()) ||
                    string.IsNullOrEmpty(txtInterviewTime.Text.Trim()) ||
                    string.IsNullOrEmpty(txtInterviewLocation.Text.Trim()) ||
                    string.IsNullOrEmpty(txtInterviewerName.Text.Trim()))
                {
                    ShowScheduleMessage("Please fill in all required fields (Date, Time, Location, Interviewer Name).", false);
                    return;
                }

                // Parse interview date and time
                DateTime interviewDate;
                if (!DateTime.TryParse(txtInterviewDate.Text.Trim(), out interviewDate))
                {
                    ShowScheduleMessage("Invalid interview date format.", false);
                    return;
                }

                // Combine date and time
                DateTime interviewDateTime;
                if (!DateTime.TryParse(txtInterviewDate.Text.Trim() + " " + txtInterviewTime.Text.Trim(), out interviewDateTime))
                {
                    ShowScheduleMessage("Invalid interview time format.", false);
                    return;
                }

                // Get current user (scheduler)
                string scheduledBy = Session["Username"]?.ToString() ?? "System";

                // Split selected IDs
                string[] applicantIds = selectedIds.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                int successCount = 0;
                int failCount = 0;

                // Update each selected applicant and create interview record
                foreach (string applicantId in applicantIds)
                {
                    try
                    {
                        var applicant = await _applicantService.GetApplicantByIdAsync(applicantId.Trim());
                        if (applicant != null)
                        {
                            // Update applicant status to In-Progress
                            bool statusUpdated = await _applicantService.UpdateApplicantStatusAsync(applicantId.Trim(), "In-Progress");
                            
                            // Create interview record in separate collection
                            bool interviewCreated = await _interviewService.CreateInterviewAsync(
                                applicantId.Trim(),
                                applicant.FullName,
                                interviewDateTime,
                                txtInterviewTime.Text.Trim(),
                                txtInterviewLocation.Text.Trim(),
                                txtInterviewerName.Text.Trim(),
                                txtInterviewNotes.Text.Trim(),
                                scheduledBy
                            );

                            if (statusUpdated && interviewCreated)
                            {
                                successCount++;
                            }
                            else
                            {
                                failCount++;
                            }
                        }
                        else
                        {
                            failCount++;
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error scheduling interview for applicant {applicantId}: {ex.Message}");
                        failCount++;
                    }
                }

                if (successCount > 0)
                {
                    ShowScheduleMessage($"Interview scheduled successfully for {successCount} applicant(s)!" + 
                        (failCount > 0 ? $" ({failCount} failed)" : ""), true);
                    
                    // Clear form
                    txtInterviewDate.Text = "";
                    txtInterviewTime.Text = "";
                    txtInterviewLocation.Text = "";
                    txtInterviewerName.Text = "";
                    txtInterviewNotes.Text = "";
                    hdnSelectedApplicantIds.Value = "";

                    // Reload data
                    await LoadApplicantsData();

                    // Close modal and refresh page after delay
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeScheduleModalAndRefresh", 
                        "setTimeout(function() { closeScheduleInterviewModal(); window.location.reload(); }, 1500);", true);
                }
                else
                {
                    ShowScheduleMessage("Failed to schedule interview for selected applicants. Please try again.", false);
                }
            }
            catch (Exception ex)
            {
                ShowScheduleMessage("An error occurred: " + ex.Message, false);
                System.Diagnostics.Debug.WriteLine($"Error scheduling interview: {ex.Message}");
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            messageDiv.InnerText = message;
            messageDiv.Attributes["class"] = isSuccess ? "message success" : "message error";
            messageDiv.Style.Add("display", "block");
        }

        private void ShowScheduleMessage(string message, bool isSuccess)
        {
            scheduleMessageDiv.InnerText = message;
            scheduleMessageDiv.Attributes["class"] = isSuccess ? "message success" : "message error";
            scheduleMessageDiv.Style.Add("display", "block");
        }

        protected async void btnHireApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                string applicantId = hdnApplicantId.Value;
                
                if (string.IsNullOrEmpty(applicantId))
                {
                    return;
                }

                // Get applicant details
                var applicant = await _applicantService.GetApplicantByIdAsync(applicantId);
                if (applicant == null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "hireError", 
                        "alert('Applicant not found.');", true);
                    return;
                }

                // Debug logging
                System.Diagnostics.Debug.WriteLine($"=== Hiring Applicant ===");
                System.Diagnostics.Debug.WriteLine($"Applicant ID: {applicantId}");
                System.Diagnostics.Debug.WriteLine($"Applicant Status: '{applicant.Status}'");
                System.Diagnostics.Debug.WriteLine($"Applicant Name: {applicant.FullName}");
                System.Diagnostics.Debug.WriteLine($"Hiring Type: '{applicant.HiringType}'");

                // Determine hiring type (default to Employee if not specified)
                string hiringType = string.IsNullOrEmpty(applicant.HiringType) ? "Employee" : applicant.HiringType;

                // Check if employee/manager already exists for this applicant
                if (hiringType == "Manager")
                {
                    var existingManager = await _managerService.GetManagerByApplicantIdAsync(applicantId);
                    if (existingManager != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Manager already exists: {existingManager.ManagerId}");
                        
                        // If manager exists, just ensure status is updated and reload
                        string applicantStatus = (applicant.Status ?? "").Trim();
                        if (!string.Equals(applicantStatus, "Hired", StringComparison.OrdinalIgnoreCase))
                        {
                            await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                        }
                        
                        await LoadApplicantsData();
                        ScriptManager.RegisterStartupScript(this, GetType(), "alreadyHiredSilent", 
                            "window.location.reload();", true);
                        return;
                    }
                }
                else
                {
                    var existingEmployee = await _employeeService.GetEmployeeByApplicantIdAsync(applicantId);
                    if (existingEmployee != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Employee already exists: {existingEmployee.EmployeeId}");
                        
                        // If employee exists, just ensure status is updated and reload
                        string applicantStatus = (applicant.Status ?? "").Trim();
                        if (!string.Equals(applicantStatus, "Hired", StringComparison.OrdinalIgnoreCase))
                        {
                            await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                        }
                        
                        await LoadApplicantsData();
                        ScriptManager.RegisterStartupScript(this, GetType(), "alreadyHiredSilent", 
                            "window.location.reload();", true);
                        return;
                    }
                }

                // Create employee or manager record based on hiring type
                if (hiringType == "Manager")
                {
                    // Create manager record from applicant
                    var manager = new Manager
                    {
                        FirstName = applicant.FirstName,
                        MiddleName = applicant.MiddleName,
                        LastName = applicant.LastName,
                        Email = applicant.Email,
                        ContactNo = applicant.ContactNo,
                        Address = applicant.Address,
                        Department = applicant.AppliedPosition,
                        Role = applicant.Role,
                        ContractType = applicant.ContractType ?? "Regular",
                        ApplicantId = applicantId,
                        HiredDate = DateTime.UtcNow,
                        IsActive = true
                    };

                    // Create manager in database and get the created manager with ManagerId
                    Manager createdManager = await _managerService.CreateManagerAndReturnAsync(manager);
                    
                    if (createdManager == null)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireError", 
                            "alert('Failed to create manager record. Please try again.');", true);
                        return;
                    }

                    // Create user account for the manager
                    // Username: Manager's email
                    // Password: Manager's ManagerId
                    if (!string.IsNullOrEmpty(createdManager.Email) && !string.IsNullOrEmpty(createdManager.ManagerId))
                    {
                        string username = createdManager.Email.Trim();
                        string password = createdManager.ManagerId.Trim();
                        
                        System.Diagnostics.Debug.WriteLine($"Creating manager user account:");
                        System.Diagnostics.Debug.WriteLine($"  Username (Email): '{username}'");
                        System.Diagnostics.Debug.WriteLine($"  Password (ManagerId): '{password}'");
                        System.Diagnostics.Debug.WriteLine($"  Role: Manager");
                        
                        bool userCreated = await _userService.CreateUserAsync(
                            username: username,
                            password: password,
                            role: "Manager",
                            email: username
                        );

                        if (userCreated)
                        {
                            System.Diagnostics.Debug.WriteLine($"User account created successfully for manager {createdManager.ManagerId}");
                        }
                        else
                        {
                            var existingUser = await _userService.GetUserByUsernameAsync(username);
                            if (existingUser != null)
                            {
                                System.Diagnostics.Debug.WriteLine($"Existing user found: Username={existingUser.Username}, Role={existingUser.Role}");
                                bool passwordUpdated = await _userService.UpdatePasswordAsync(username, password);
                                if (passwordUpdated)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Password updated for existing manager user account");
                                }
                            }
                        }
                    }

                    // Update applicant status to "Hired"
                    bool statusUpdated = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                    await LoadApplicantsData();
                    
                    string email = (createdManager.Email ?? "").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
                    string managerId = (createdManager.ManagerId ?? "").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
                    
                    if (statusUpdated)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccess", 
                            $"alert('Applicant hired successfully as Manager!\\n\\nManager account created:\\nUsername (Email): {email}\\nPassword (Manager ID): {managerId}\\n\\nManager can now login at the manager dashboard.'); window.location.reload();", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccessWithWarning", 
                            $"alert('Manager created successfully!\\n\\nUsername: {email}\\nPassword: {managerId}\\n\\nNote: Applicant status may need manual update.'); window.location.reload();", true);
                    }
                }
                else
                {
                    // Create employee record from applicant
                    var employee = new Employee
                    {
                        FirstName = applicant.FirstName,
                        MiddleName = applicant.MiddleName,
                        LastName = applicant.LastName,
                        Email = applicant.Email,
                        ContactNo = applicant.ContactNo,
                        Address = applicant.Address,
                        Department = applicant.AppliedPosition,
                        Role = applicant.Role,
                        ContractType = applicant.ContractType ?? "Regular",
                        ApplicantId = applicantId,
                        HiredDate = DateTime.UtcNow,
                        IsActive = true
                    };

                    // Create employee in database and get the created employee with EmployeeId
                    Employee createdEmployee = await _employeeService.CreateEmployeeAndReturnAsync(employee);
                    
                    if (createdEmployee == null)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireError", 
                            "alert('Failed to create employee record. Please try again.');", true);
                        return;
                    }

                    // Create user account for the employee
                    // Username: Employee's email
                    // Password: Employee's EmployeeId
                    if (!string.IsNullOrEmpty(createdEmployee.Email) && !string.IsNullOrEmpty(createdEmployee.EmployeeId))
                    {
                        string username = createdEmployee.Email.Trim();
                        string password = createdEmployee.EmployeeId.Trim();
                        
                        System.Diagnostics.Debug.WriteLine($"Creating user account:");
                        System.Diagnostics.Debug.WriteLine($"  Username (Email): '{username}'");
                        System.Diagnostics.Debug.WriteLine($"  Password (EmployeeId): '{password}'");
                        System.Diagnostics.Debug.WriteLine($"  Role: Employee");
                        
                        bool userCreated = await _userService.CreateUserAsync(
                            username: username,
                            password: password,
                            role: "Employee",
                            email: username
                        );

                        if (userCreated)
                        {
                            System.Diagnostics.Debug.WriteLine($"User account created successfully for employee {createdEmployee.EmployeeId}");
                        }
                        else
                        {
                            var existingUser = await _userService.GetUserByUsernameAsync(username);
                            if (existingUser != null)
                            {
                                System.Diagnostics.Debug.WriteLine($"Existing user found: Username={existingUser.Username}, Role={existingUser.Role}");
                                bool passwordUpdated = await _userService.UpdatePasswordAsync(username, password);
                                if (passwordUpdated)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Password updated for existing user account");
                                }
                            }
                        }
                    }

                    // Update applicant status to "Hired"
                    bool statusUpdated = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                    await LoadApplicantsData();
                    
                    string email = (createdEmployee.Email ?? "").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
                    string employeeId = (createdEmployee.EmployeeId ?? "").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
                    
                    if (statusUpdated)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccess", 
                            $"alert('Applicant hired successfully! Employee account created.\\n\\nUsername: {email}\\nPassword: {employeeId}'); window.location.reload();", true);
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"Warning: Employee {createdEmployee.EmployeeId} created but applicant status update returned false. ApplicantId: {applicantId}");
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccessWithWarning", 
                            $"alert('Employee created successfully! Account created.\\n\\nUsername: {email}\\nPassword: {employeeId}\\n\\nNote: Applicant status may need manual update.'); window.location.reload();", true);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error hiring applicant: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "hireError", 
                    "alert('An error occurred. Please try again.');", true);
            }
        }

        protected async void btnNotHireApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                string applicantId = hdnApplicantId.Value;
                
                if (string.IsNullOrEmpty(applicantId))
                {
                    return;
                }

                bool success = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Not Hired");
                
                if (success)
                {
                    // Reload data
                    await LoadApplicantsData();
                    
                    // Show success message and refresh
                    ScriptManager.RegisterStartupScript(this, GetType(), "notHireSuccess", 
                        "alert('Applicant status updated to Not Hired.'); window.location.reload();", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "notHireError", 
                        "alert('Failed to update applicant status. Please try again.');", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating applicant status: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "notHireError", 
                    "alert('An error occurred. Please try again.');", true);
            }
        }
    }
}
