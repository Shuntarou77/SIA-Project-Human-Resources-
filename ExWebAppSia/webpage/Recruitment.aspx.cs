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
  ContractType = rblContractType.SelectedValue ?? "Regular",
              
       // Hiring Type (default to Employee if control doesn't exist)
  HiringType = "Employee" // Default hiring type
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
   rblContractType.SelectedIndex = 0; // Default to Regular
      }

    private async Task LoadApplicantsData()
    {
     try
            {
       // Load new applicants
            var newApplicants = await _applicantService.GetNewApplicantsAsync();
        PopulateNewApplicantsTable(newApplicants);

       // Load approved applicants
        var approvedApplicants = await _applicantService.GetApprovedApplicantsAsync();
        PopulateApprovedApplicantsTable(approvedApplicants);

      // Load declined applicants
     var declinedApplicants = await _applicantService.GetDeclinedApplicantsAsync();
       PopulateDeclinedApplicantsTable(declinedApplicants);

        // Load in-progress applicants
            var inProgressApplicants = await _applicantService.GetInProgressApplicantsAsync();
     await PopulateInProgressApplicantsTableAsync(inProgressApplicants);

   // Update stat counts
    int newCount = await _applicantService.GetCountByStatusAsync("New");
           int inProgressCount = await _applicantService.GetCountByStatusAsync("In-Progress");
 int approvedCount = await _applicantService.GetCountByStatusAsync("Approved");
 int declinedCount = await _applicantService.GetCountByStatusAsync("Declined");

     litNewCount.Text = (newCount + inProgressCount).ToString();
      litInProgressCount.Text = inProgressCount.ToString();
    litNewSubCount.Text = newCount.ToString();
          litApprovedCount.Text = approvedCount.ToString();
      litDeclinedCount.Text = declinedCount.ToString();
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
<td colspan=""4"" class=""empty-state"">
    <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 64px; height: 64px; stroke-width: 1.5;"">
      <path d=""M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2""/>
     <circle cx=""12"" cy=""7"" r=""4""/>
   </svg>
  <p style=""margin-top: 16px; font-size: 14px;"">No new applicants found</p>
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

    string viewDetailsOnclick = $"viewApplicantDetails('{applicantId}'); return false;";
   string approveOnclick = $"approveApplicant('{applicantId}', this); return false;";
         string declineOnclick = $"declineApplicant('{applicantId}', this); return false;";

       sb.Append($@"
       <tr>
  <td></td>
   <td><strong>{fullName}</strong></td>
     <td>{position}</td>
       <td style=""text-align: center;"">
     <div class=""action-buttons"">
   <button type=""button"" class=""btn btn-view-details"" onclick=""{viewDetailsOnclick}"">
        <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"">
        <path d=""M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z""/>
       <circle cx=""12"" cy=""12"" r=""3""/>
            </svg>
         View
  </button>
   <button type=""button"" class=""btn btn-approve"" onclick=""{approveOnclick}"">
   <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"">
      <polyline points=""20 6 9 17 4 12""/>
      </svg>
           Approve
  </button>
     <button type=""button"" class=""btn btn-decline"" onclick=""{declineOnclick}"">
   <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"">
      <circle cx=""12"" cy=""12"" r=""10""/>
      <line x1=""15"" y1=""9"" x2=""9"" y2=""15""/>
       <line x1=""9"" y1=""9"" x2=""15"" y2=""15""/>
      </svg>
        Decline
           </button>
   </div>
</td>
         </tr>");
  }

            newApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private void PopulateApprovedApplicantsTable(List<Applicant> applicants)
  {
     approvedApplicantsTableBody.Controls.Clear();

      if (applicants == null || applicants.Count == 0)
  {
                approvedApplicantsTableBody.InnerHtml = @"
 <tr>
    <td colspan=""4"" class=""empty-state"">
  <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 64px; height: 64px; stroke-width: 1.5;"">
      <path d=""M9 11l3 3L22 4""/>
      <path d=""M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11""/>
       </svg>
  <p style=""margin-top: 16px; font-size: 14px;"">No approved applicants found</p>
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

  string viewDetailsOnclick = $"viewApplicantDetails('{applicantId}'); return false;";

    sb.Append($@"
   <tr>
     <td class=""checkbox-cell"">
        <input type=""checkbox"" value=""{applicantId}"" class=""applicant-checkbox"" />
         </td>
      <td><strong>{fullName}</strong></td>
  <td>{position}</td>
      <td style=""text-align: center;"">
   <span class=""status-badge status-approved"">
   <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 14px; height: 14px;"">
         <polyline points=""20 6 9 17 4 12""/>
      </svg>
    Approved
        </span>
       <a href=""#"" class=""status-link"" onclick=""{viewDetailsOnclick}"" style=""margin-left: 12px; color: var(--primary-color); text-decoration: none; font-weight: 600;"">View Details</a>
   </td>
              </tr>");
    }

      approvedApplicantsTableBody.InnerHtml = sb.ToString();
  }

        private void PopulateDeclinedApplicantsTable(List<Applicant> applicants)
 {
        declinedApplicantsTableBody.Controls.Clear();

         if (applicants == null || applicants.Count == 0)
   {
        declinedApplicantsTableBody.InnerHtml = @"
           <tr>
     <td colspan=""3"" class=""empty-state"">
    <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 64px; height: 64px; stroke-width: 1.5;"">
    <circle cx=""12"" cy=""12"" r=""10""/>
  <line x1=""15"" y1=""9"" x2=""9"" y2=""15""/>
      <line x1=""9"" y1=""9"" x2=""15"" y2=""15""/>
    </svg>
  <p style=""margin-top: 16px; font-size: 14px;"">No declined applicants found</p>
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

          string viewDetailsOnclick = $"viewApplicantDetails('{applicantId}'); return false;";

      sb.Append($@"
  <tr>
      <td><strong>{fullName}</strong></td>
    <td>{position}</td>
             <td style=""text-align: center;"">
        <span class=""status-badge status-declined"">
  <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 14px; height: 14px;"">
     <circle cx=""12"" cy=""12"" r=""10""/>
    <line x1=""15"" y1=""9"" x2=""9"" y2=""15""/>
        <line x1=""9"" y1=""9"" x2=""15"" y2=""15""/>
       </svg>
         Declined
   </span>
   <a href=""#"" class=""status-link"" onclick=""{viewDetailsOnclick}"" style=""margin-left: 12px; color: var(--primary-color); text-decoration: none; font-weight: 600;"">View Details</a>
  </td>
        </tr>");
     }

   declinedApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private async Task PopulateInProgressApplicantsTableAsync(List<Applicant> applicants)
  {
            inProgressApplicantsTableBody.Controls.Clear();

    if (applicants == null || applicants.Count == 0)
  {
    inProgressApplicantsTableBody.InnerHtml = @"
 <tr>
     <td colspan=""4"" class=""empty-state"">
   <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 64px; height: 64px; stroke-width: 1.5;"">
    <circle cx=""12"" cy=""12"" r=""10""/>
    <polyline points=""12 6 12 12 16 14""/>
  </svg>
        <p style=""margin-top: 16px; font-size: 14px;"">No in-progress applicants found</p>
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
  
          // Check if employee exists
    var existingEmployee = await _employeeService.GetEmployeeByApplicantIdAsync(applicant.Id);
     bool isHired = existingEmployee != null;

    string hireButtonDisabled = isHired ? "disabled" : "";
  string hireButtonText = isHired ? "Already Hired" : "Hire";
   string hireButtonStyle = isHired ? "opacity: 0.6; cursor: not-allowed;" : "";
  string hireButtonOnclick = isHired ? "" : $"hireApplicant('{applicantId}', this); return false;";
    string notHireButtonOnclick = $"notHireApplicant('{applicantId}', this); return false;";
         string viewDetailsOnclick = $"viewApplicantDetails('{applicantId}'); return false;";

    sb.Append($@"
 <tr>
    <td><strong>{fullName}</strong></td>
 <td>{position}</td>
          <td style=""text-align: center;"">
  <a href=""#"" class=""status-link"" onclick=""{viewDetailsOnclick}"" style=""color: var(--primary-color); text-decoration: none; font-weight: 600;"">
         <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" style=""width: 16px; height: 16px; vertical-align: middle; margin-right: 4px;"">
    <path d=""M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z""/>
       <circle cx=""12"" cy=""12"" r=""3""/>
 </svg>
      View Details
      </a>
   </td>
      <td style=""text-align: center;"">
      <div class=""action-buttons"">
       <button type=""button"" class=""btn btn-hire"" {hireButtonDisabled} onclick=""{hireButtonOnclick}"" style=""{hireButtonStyle}"">
      <svg viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"">
    <path d=""M22 11.08V12a10 10 0 1 1-5.93-9.14""/>
       <polyline points=""22 4 12 14.01 9 11.01""/>
   </svg>
     {hireButtonText}
   </button>
            <button type=""button"" class=""btn btn-not-hire"" onclick=""{notHireButtonOnclick}"">
     <svg viewBox="" 0 0 24 24"" fill=""none"" stroke=""currentColor"">
       <circle cx=""12"" cy=""12"" r=""10""/>
      <line x1=""15"" y1=""9"" x2=""9"" y2=""15""/>
      <line x1=""9"" y1=""9"" x2=""15"" y2=""15""/>
    </svg>
       Not Hired
      </button>
        </div>
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
    // Send interview invitation email
        if (!string.IsNullOrEmpty(applicant.Email))
            {
     await _emailService.SendInterviewInvitationEmailAsync(
           applicant.Email,
        applicant.FullName,
               interviewDateTime,
    txtInterviewLocation.Text.Trim(),
            txtInterviewerName.Text.Trim(),
         txtInterviewNotes.Text.Trim()
      );
         System.Diagnostics.Debug.WriteLine($"Interview invitation email sent to {applicant.Email}");
         }
   
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

      // Close modal after delay (removed window.location.reload to prevent infinite refresh)
    ScriptManager.RegisterStartupScript(this, GetType(), "closeScheduleModal", 
      "setTimeout(function() { closeScheduleInterviewModal(); }, 1500);", true);
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

 protected async void btnApproveApplicant_Click(object sender, EventArgs e)
        {
            try
       {
  string applicantId = hdnApplicantId.Value;

       if (string.IsNullOrEmpty(applicantId))
  {
         return;
  }

    // Update status to "Approved"
        bool success = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Approved");

if (success)
          {
             // Reload data
  await LoadApplicantsData();

        // Show success message - reload AFTER user clicks OK on alert
    ScriptManager.RegisterStartupScript(this, GetType(), "approveSuccess",
   @"if (confirm('Applicant approved successfully! Click OK to refresh.')) { 
        window.location.href = window.location.href; 
      } else { 
    window.location.href = window.location.href; 
      }", true);
       }
  else
  {
    ScriptManager.RegisterStartupScript(this, GetType(), "approveError",
 "alert('Failed to approve applicant. Please try again.');", true);
     }
       }
   catch (Exception ex)
   {
   System.Diagnostics.Debug.WriteLine($"Error approving applicant: {ex.Message}");
        ScriptManager.RegisterStartupScript(this, GetType(), "approveError",
          "alert('An error occurred. Please try again.');", true);
     }
      }

        protected async void btnDeclineApplicant_Click(object sender, EventArgs e)
        {
 try
       {
    string applicantId = hdnApplicantId.Value;

      if (string.IsNullOrEmpty(applicantId))
    {
            return;
      }

    // Get applicant details for email
 var applicant = await _applicantService.GetApplicantByIdAsync(applicantId);

       // Update status to "Declined"
   bool success = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Declined");

     if (success)
            {
            // Send rejection email
      if (applicant != null && !string.IsNullOrEmpty(applicant.Email))
       {
      await _emailService.SendRejectionEmailAsync(
 applicant.Email,
           applicant.FullName,
   reason: "After careful review of your application, we have decided to proceed with other candidates whose qualifications more closely match our current requirements."
                 );
          System.Diagnostics.Debug.WriteLine($"Rejection email sent to {applicant.Email}");
    }

      // Reload data
                await LoadApplicantsData();

         // Show success message - reload AFTER user clicks OK
   ScriptManager.RegisterStartupScript(this, GetType(), "declineSuccess",
   @"if (confirm('Applicant declined. Rejection email has been sent. Click OK to refresh.')) { 
    window.location.href = window.location.href; 
    } else { 
   window.location.href = window.location.href; 
        }", true);
   }
         else
  {
          ScriptManager.RegisterStartupScript(this, GetType(), "declineError",
           "alert('Failed to decline applicant. Please try again.');", true);
      }
 }
catch (Exception ex)
        {
 System.Diagnostics.Debug.WriteLine($"Error declining applicant: {ex.Message}");
      ScriptManager.RegisterStartupScript(this, GetType(), "declineError",
     "alert('An error occurred. Please try again.');", true);
      }
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
                // ...existing manager hiring code...
        }
          else
        {
        // Check if employee already exists
           var existingEmployee = await _employeeService.GetEmployeeByApplicantIdAsync(applicantId);
           if (existingEmployee != null)
        {
          System.Diagnostics.Debug.WriteLine($"Employee already exists: {existingEmployee.EmployeeId}");
         string applicantStatus = (applicant.Status ?? "").Trim();
  if (!string.Equals(applicantStatus, "Hired", StringComparison.OrdinalIgnoreCase))
        {
          await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
 }
       
     await LoadApplicantsData();
     ScriptManager.RegisterStartupScript(this, GetType(), "alreadyHiredSilent", 
         "window.location.href = window.location.href;", true);
return;
    }

       // Create employee record from applicant
     var employee = new Employee
       {
FirstName = applicant.FirstName,
        MiddleName = applicant.MiddleName,
    LastName = applicant.LastName,
           Email = applicant.Email,
     ContactNo = applicant.ContactNo,
    Address = applicant.Address,
         Age = applicant.Age,
      BirthDate = applicant.BirthDate,
              Gender = applicant.Gender,
     Department = applicant.AppliedPosition,
   Role = applicant.Role,
   ContractType = applicant.ContractType ?? "Regular",
             ApplicantId = applicantId,
                HiredDate = DateTime.UtcNow,
           IsActive = true
   };

     // Create employee in database
                Employee createdEmployee = await _employeeService.CreateEmployeeAndReturnAsync(employee);
          
   if (createdEmployee == null)
  {
  ScriptManager.RegisterStartupScript(this, GetType(), "hireError", 
                "alert('Failed to create employee record. Please try again.');", true);
             return;
 }

      System.Diagnostics.Debug.WriteLine($"? Employee Created:");
   System.Diagnostics.Debug.WriteLine($"   - EmployeeId (MongoDB _id): {createdEmployee.EmployeeId}");
       System.Diagnostics.Debug.WriteLine($"   - Full Name: {createdEmployee.FullName}");
            System.Diagnostics.Debug.WriteLine($"   - Department: {createdEmployee.Department}");
   System.Diagnostics.Debug.WriteLine($"   - Position/Role: {createdEmployee.Role}");

     // REMOVED: Auto-create payroll configuration
                    System.Diagnostics.Debug.WriteLine($"? NOTICE: Payroll configuration NOT auto-created. Must be added manually via Payroll > Configuration tab.");

                    // Create user account
                    string employeeUsername = createdEmployee.Email?.Trim() ?? "";
                    string employeePassword = createdEmployee.EmployeeId?.Trim() ?? "";

                    if (!string.IsNullOrEmpty(employeeUsername) && !string.IsNullOrEmpty(employeePassword))
                    {
                        bool userCreated = await _userService.CreateUserAsync(
                            username: employeeUsername,
                            password: employeePassword,
                            role: "Employee",
                            email: employeeUsername
                        );

                        if (userCreated)
                        {
                            System.Diagnostics.Debug.WriteLine($"User account created successfully");
                        }
                        else
                        {
                            var existingUser = await _userService.GetUserByUsernameAsync(employeeUsername);
                            if (existingUser != null)
                            {
                                bool passwordUpdated = await _userService.UpdatePasswordAsync(employeeUsername, employeePassword);
                                if (passwordUpdated)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Password updated for existing user");
                                }
                            }
                        }
                    }
                    
                    // Update applicant status to "Hired"
                    bool statusUpdated = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");

                    // Send hired email
                    if (!string.IsNullOrEmpty(createdEmployee.Email))
                    {
                        await _emailService.SendHiredEmailAsync(
                            createdEmployee.Email,
                            createdEmployee.FullName,
                            createdEmployee.Department ?? "",
                            createdEmployee.Role ?? "",
                            employeeUsername,
                            employeePassword,
                            isManager: false
                        );
                        System.Diagnostics.Debug.WriteLine($"Hired email sent to {createdEmployee.Email}");
                    }
                    
                    await LoadApplicantsData();
                    
                    string email = (createdEmployee.Email ?? "").Replace("'", "\\'");
                    string empId = (createdEmployee.EmployeeId ?? "").Replace("'", "\\'");
                    
                    if (statusUpdated)
                    {
                        // UPDATED: Remove auto-creation message from alert
                        ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccess", 
                            $"alert('Employee hired successfully!\\n\\nAccount created:\\nUsername: {email}\\nPassword: {empId}\\n\\n? IMPORTANT: Add payroll configuration manually via Payroll > Configuration tab.'); window.location.href = window.location.href;", true);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error hiring applicant: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
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

                // Get applicant details
                var applicant = await _applicantService.GetApplicantByIdAsync(applicantId);
                if (applicant == null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "notHireError",
                        "alert('Applicant not found.');", true);
                    return;
                }

                // Update status to Declined (Not Hired)
                bool success = await _applicantService.UpdateApplicantStatusAsync(applicantId, "Declined");

                if (success)
                {
                    // Reload data
                    await LoadApplicantsData();

                    // Show success message - applicant was not hired (declined)
                    ScriptManager.RegisterStartupScript(this, GetType(), "notHireSuccess",
                        "alert('Applicant marked as Not Hired (Declined).'); window.location.href = window.location.href;", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "notHireError",
                        "alert('Failed to update applicant status. Please try again.');", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in btnNotHireApplicant_Click: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ScriptManager.RegisterStartupScript(this, GetType(), "notHireError",
                    "alert('An error occurred. Please try again.');", true);
            }
        }
    }
}
