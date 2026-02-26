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
        private readonly RoleSalaryService _roleSalaryService = new RoleSalaryService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["reset"] == "true")
            {
                try
                {
                    var db = Models.MongoDBHelper.GetDatabase();
                    await db.GetCollection<MongoDB.Bson.BsonDocument>("Employees").DeleteManyAsync(new MongoDB.Bson.BsonDocument());
                    await db.GetCollection<MongoDB.Bson.BsonDocument>("Users").DeleteManyAsync(MongoDB.Driver.Builders<MongoDB.Bson.BsonDocument>.Filter.Eq("role", "Employee"));
                    Response.Redirect("Recruitment.aspx?reset_success=true");
                }
                catch { }
            }

            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(async () => {
                    await _roleSalaryService.SeedRoleSalariesAsync();
                    await LoadApplicantsData();
                }));
            }
        }

        protected async void btnAddApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                // Default hiring type to Employee
                string selectedHiringType = "Employee";

                // Basic Field Validation
                if (string.IsNullOrEmpty(txtFirstName.Text.Trim()) ||
                    string.IsNullOrEmpty(txtLastName.Text.Trim()) ||
                    string.IsNullOrEmpty(ddlAppliedPosition.SelectedValue) ||
                    string.IsNullOrEmpty(hdnSelectedRole.Value) ||
                    string.IsNullOrEmpty(ddlHowDidYouHearUs.SelectedValue))
                {
                    ShowMessage("Please fill in all required fields.", false);
                    return;
                }

                string firstName = txtFirstName.Text.Trim();
                string lastName = txtLastName.Text.Trim();

                // 1. Restriction: Unique Name Check
                bool nameExistsInApplicants = await _applicantService.IsNameDuplicateAsync(firstName, lastName);
                bool nameExistsInEmployees = await _employeeService.IsNameDuplicateAsync(firstName, lastName);

                if (nameExistsInApplicants || nameExistsInEmployees)
                {
                    ShowMessage("An employee or applicant with this name already exists in the system.", false);
                    return;
                }

                // 2. Restriction: Age and Birthdate must match
                DateTime birthDate;
                if (!DateTime.TryParse(txtBirthDate.Text.Trim(), out birthDate))
                {
                    ShowMessage("Please enter a valid birthdate.", false);
                    return;
                }

                // Calculate age from birthdate
                var today = DateTime.Today;
                int calculatedAge = today.Year - birthDate.Year;
                if (birthDate.Date > today.AddYears(-calculatedAge)) calculatedAge--;

                int enteredAge;
                if (int.TryParse(txtAge.Text.Trim(), out enteredAge))
                {
                    if (enteredAge != calculatedAge)
                    {
                        ShowMessage($"Entered age ({enteredAge}) does not match the birthdate calculation ({calculatedAge}).", false);
                        return;
                    }
                }
                else
                {
                    // Auto-fill age if not entered
                    txtAge.Text = calculatedAge.ToString();
                }

                // Proceed with applicant creation



                // Handle Resume Upload
                string resumePath = "";
                string resumeFileName = "";
                string resumeFileType = "";

                if (fileResume.HasFile)
                {
                    try
                    {
                        resumeFileName = fileResume.FileName;
                        resumeFileType = fileResume.PostedFile.ContentType;
                        string fileName = Guid.NewGuid().ToString() + "_" + System.IO.Path.GetFileName(fileResume.FileName);
                        string uploadDir = Server.MapPath("~/Uploads/Resumes/");
                        if (!System.IO.Directory.Exists(uploadDir))
                        {
                            System.IO.Directory.CreateDirectory(uploadDir);
                        }
                        string fullPath = System.IO.Path.Combine(uploadDir, fileName);
                        fileResume.SaveAs(fullPath);
                        resumePath = "~/Uploads/Resumes/" + fileName;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error saving resume: {ex.Message}");
                    }
                }

                // Generate Reference Number (format: SHE-YYYYMMDDHHMMSS-RANDOM)
                string refNumber = "SHE-" + DateTime.Now.ToString("yyyyMMddHHmmss") + "-" + new Random().Next(1000, 9999).ToString();

                // Create applicant object
                var applicant = new Applicant
                {
                    FirstName = txtFirstName.Text.Trim(),
                    MiddleName = txtMiddleName.Text.Trim(),
                    LastName = txtLastName.Text.Trim(),
                    Email = txtEmail.Text.Trim(),
                    ContactNo = txtContactNo.Text.Trim(),
                    Address = txtAddress.Text.Trim(),
                    Street = txtStreet.Text.Trim(),
                    City = txtCity.Text.Trim(),
                    State = txtState.Text.Trim(),
                    Country = txtCountry.Text.Trim(),
                    Education = ddlEducationLevel.SelectedValue,
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
                    ContractType = rblContractType.SelectedValue ?? "Provisionary",
                    StartingSalary = 18000, // All probationary employees start at 18,000 PHP
                    HiringType = selectedHiringType,
                    Status = "Pending Review",
                    ReferenceNumber = refNumber,
                    AppointmentStatus = "Pending",
                    IsDraft = false,
                    HasSSS = chkSSS.Checked,
                    HasPhilHealth = chkPhilHealth.Checked,
                    HasPagIbig = chkPagIbig.Checked,
                    SSSNumber = "", 
                    PhilHealthNumber = "",
                    PagIbigNumber = "",
                    ResumePath = resumePath,
                    ResumeFileName = resumeFileName,
                    ResumeFileType = resumeFileType
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
                    // Only show govt details editing for 'For Viewing' tab and later stages
                    // Hide it for 'Pending Review' (which is the 'New' tab)
                    if (govtDetailsSection != null)
                    {
                        govtDetailsSection.Visible = (applicant.Status != "Pending Review");
                    }

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
            sb.Append("<div style='padding: 20px; font-family: sans-serif;'>");

            // Personal Info
            sb.Append("<h3 style='color: var(--primary-color); margin-bottom: 15px; border-bottom: 2px solid #eee; padding-bottom: 8px; font-size: 1.1rem; text-transform: uppercase;'>Personal Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 24px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666; width: 35%;'>Full Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.FullName));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Reference No:</td><td style='padding: 8px;'><span style='background: #f0f7ff; color: #007bff; padding: 2px 8px; border-radius: 4px; font-weight: 700;'>{0}</span></td></tr>", Server.HtmlEncode(applicant.ReferenceNumber ?? "N/A"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Email:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Email ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Contact:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ContactNo ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Birth Date:</td><td style='padding: 8px;'>{0} ({1} yrs old)</td></tr>", applicant.BirthDate?.ToString("MMM dd, yyyy") ?? "N/A", applicant.Age?.ToString() ?? "N/A");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Gender:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Gender ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Address:</td><td style='padding: 8px;'>{0} {1}, {2}, {3}, {4}</td></tr>", 
                Server.HtmlEncode(applicant.Street ?? ""), 
                Server.HtmlEncode(applicant.Address ?? ""),
                Server.HtmlEncode(applicant.City ?? ""), 
                Server.HtmlEncode(applicant.State ?? ""), 
                Server.HtmlEncode(applicant.Country ?? ""));
            sb.Append("</table>");

            // Guardian Info
            sb.Append("<h3 style='color: var(--primary-color); margin: 24px 0 15px 0; border-bottom: 2px solid #eee; padding-bottom: 8px; font-size: 1.1rem; text-transform: uppercase;'>Guardian Information</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 24px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666; width: 35%;'>Guardian Name:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianName ?? "N/A"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Contact No:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianContactNo ?? "N/A"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Email:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianEmail ?? "N/A"));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Home Address:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.GuardianHomeAddress ?? "N/A"));
            sb.Append("</table>");

            // Work History
            if (applicant.HasPreviousCompany)
            {
                sb.Append("<h3 style='color: var(--primary-color); margin: 24px 0 15px 0; border-bottom: 2px solid #eee; padding-bottom: 8px; font-size: 1.1rem; text-transform: uppercase;'>Work Experience</h3>");
                sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 24px;'>");
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666; width: 35%;'>Company:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.PreviousCompanyName ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Previous Role:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.PreviousPosition ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Job Industry:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.JobIndustry ?? ""));
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Experience:</td><td style='padding: 8px;'>{0} Years, {1} Months</td></tr>", applicant.Years ?? 0, applicant.Months ?? 0);
                sb.Append("</table>");
            }

            // Application Info
            sb.Append("<h3 style='color: var(--primary-color); margin: 24px 0 15px 0; border-bottom: 2px solid #eee; padding-bottom: 8px; font-size: 1.1rem; text-transform: uppercase;'>Application Details</h3>");
            sb.Append("<table style='width: 100%; border-collapse: collapse; margin-bottom: 24px;'>");
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666; width: 35%;'>Dept (Position):</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.AppliedPosition ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Role / Job Title:</td><td style='padding: 8px;'><mark style='background: #fff3cd; padding: 2px 6px;'>{0}</mark></td></tr>", Server.HtmlEncode(applicant.Role ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Contract Type:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.ContractType ?? ""));
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Starting Salary:</td><td style='padding: 8px;'>₱{0:N2}</td></tr>", applicant.StartingSalary > 0 ? applicant.StartingSalary : 18000);
            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Status:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.Status ?? ""));
            
            // Govt. Contributions
            string checkIcon = "<span style='color: #28a745; margin-right: 5px;'>✔</span>";
            string xIcon = "<span style='color: #dc3545; margin-right: 5px;'>✘</span>";

            sb.Append("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Govt. Contributions:</td><td style='padding: 8px;'>");
            sb.AppendFormat("<span style='margin-right: 15px;'>{0} SSS</span>", applicant.HasSSS ? checkIcon : xIcon);
            sb.AppendFormat("<span style='margin-right: 15px;'>{0} PhilHealth</span>", applicant.HasPhilHealth ? checkIcon : xIcon);
            sb.AppendFormat("<span>{0} Pag-IBIG</span>", applicant.HasPagIbig ? checkIcon : xIcon);
            sb.Append("</td></tr>");

            if (!string.IsNullOrEmpty(applicant.ResumePath))
            {
                string resumeUrl = ResolveUrl(applicant.ResumePath);
                sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Resume / CV:</td><td style='padding: 8px;'><a href='{0}' target='_blank' style='color: #007bff; text-decoration: underline;'>Download / View {1}</a></td></tr>", 
                    resumeUrl, Server.HtmlEncode(applicant.ResumeFileName ?? "File"));
            }

            if (applicant.InterviewDate.HasValue)
            {
                sb.Append("<tr style='background: rgba(40, 167, 69, 0.05);'>");
                sb.Append("<td style='padding: 8px; font-weight: 700; color: #28a745;'>Interview Schedule:</td>");
                sb.AppendFormat("<td style='padding: 8px; color: #28a745; font-weight: 700;'>{0} at {1}</td>", applicant.InterviewDate.Value.ToString("MMM dd, yyyy"), applicant.InterviewTime ?? "N/A");
                sb.Append("</tr>");
                sb.AppendFormat("<tr style='background: rgba(40, 167, 69, 0.05);'><td style='padding: 8px; font-weight: 700; color: #666;'>Interviewer:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.InterviewerName ?? "N/A"));
                sb.AppendFormat("<tr style='background: rgba(40, 167, 69, 0.05);'><td style='padding: 8px; font-weight: 700; color: #666;'>Location:</td><td style='padding: 8px;'>{0}</td></tr>", Server.HtmlEncode(applicant.InterviewLocation ?? "N/A"));
            }

            sb.AppendFormat("<tr><td style='padding: 8px; font-weight: 700; color: #666;'>Applied Date:</td><td style='padding: 8px;'>{0}</td></tr>", applicant.AppliedDate.ToLocalTime().ToString("MMM dd, yyyy"));
            sb.Append("</table>");

            // Populate Govt Textboxes
            txtSSSNumber.Text = applicant.SSSNumber ?? "";
            txtPhilHealthNumber.Text = applicant.PhilHealthNumber ?? "";
            txtPagIbigNumber.Text = applicant.PagIbigNumber ?? "";

            sb.Append("</div>");
            applicantDetailsContent.InnerHtml = sb.ToString();
        }

        protected async void btnSaveGovtDetails_Click(object sender, EventArgs e)
        {
            try
            {
                string id = hdnApplicantId.Value;
                if (string.IsNullOrEmpty(id)) return;

                string sss = txtSSSNumber.Text.Trim();
                string ph = txtPhilHealthNumber.Text.Trim();
                string pi = txtPagIbigNumber.Text.Trim();

                bool success = await _applicantService.UpdateGovtDetailsAsync(id, sss, ph, pi);
                if (success)
                {
                    await LoadApplicantsData();
                    ShowMessage("Government details updated successfully.", true);
                    
                    // Keep modal open to show updated status
                    ScriptManager.RegisterStartupScript(this, GetType(), "reopenModal",
                        "document.getElementById('viewDetailsModal').style.display = 'block';", true);
                }
                else
                {
                    ShowMessage("Failed to update government details.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void ClearForm()
        {
            txtFirstName.Text = ""; txtLastName.Text = ""; txtEmail.Text = ""; ddlAppliedPosition.SelectedIndex = 0;
            txtAddress.Text = ""; txtStreet.Text = ""; txtCity.Text = ""; txtState.Text = ""; txtCountry.Text = "";
            hdnSelectedRole.Value = ""; ddlHowDidYouHearUs.SelectedIndex = 0; ddlEducationLevel.SelectedIndex = 0;
            chkSSS.Checked = false; chkPhilHealth.Checked = false; chkPagIbig.Checked = false;
        }

        private async Task LoadApplicantsData()
        {
            try
            {
                // Parallelized performance optimization
                var tasks = new List<Task>();
                var newApplicantsTask = _applicantService.GetNewApplicantsAsync();
                var forViewingApplicantsTask = _applicantService.GetForViewingApplicantsAsync();
                var approvedApplicantsTask = _applicantService.GetApprovedApplicantsAsync();
                var declinedApplicantsTask = _applicantService.GetDeclinedApplicantsAsync();
                var inProgressApplicantsTask = _applicantService.GetInProgressApplicantsAsync();

                var newCountTask = _applicantService.GetCountByStatusAsync("New");
                var forViewingCountTask = _applicantService.GetCountByStatusAsync("For Viewing");
                var inProgressCountTask = _applicantService.GetCountByStatusAsync("In-Progress");
                var approvedCountTask = _applicantService.GetCountByStatusAsync("Approved");
                var declinedCountTask = _applicantService.GetCountByStatusAsync("Declined");

                var employeesTask = _employeeService.GetAllEmployeesAsync();
                var roleSalariesTask = _roleSalaryService.GetAllRoleSalariesAsync();

                await Task.WhenAll(
                    newApplicantsTask,
                    forViewingApplicantsTask,
                    approvedApplicantsTask,
                    declinedApplicantsTask,
                    inProgressApplicantsTask,
                    newCountTask,
                    forViewingCountTask,
                    inProgressCountTask,
                    approvedCountTask,
                    declinedCountTask,
                    employeesTask,
                    roleSalariesTask
                );

                PopulateNewApplicantsTable(newApplicantsTask.Result);
                PopulateForViewingApplicantsTable(forViewingApplicantsTask.Result);
                PopulateApprovedApplicantsTable(approvedApplicantsTask.Result);
                PopulateDeclinedApplicantsTable(declinedApplicantsTask.Result);
                await PopulateInProgressApplicantsTableAsync(inProgressApplicantsTask.Result);

                int newCount = newCountTask.Result;
                int forViewingCount = forViewingCountTask.Result;
                int inProgressCount = inProgressCountTask.Result;
                int approvedCount = approvedCountTask.Result;
                int declinedCount = declinedCountTask.Result;
                int currentEmployeeCount = employeesTask.Result.Count;

                if (litNewCount != null) litNewCount.Text = (newCount + forViewingCount + inProgressCount).ToString();
                if (litInProgressCount != null) litInProgressCount.Text = inProgressCount.ToString();
                if (litNewSubCount != null) litNewSubCount.Text = newCount.ToString();
                if (litForViewingCount != null) litForViewingCount.Text = forViewingCount.ToString();
                if (litApprovedCount != null) litApprovedCount.Text = approvedCount.ToString();
                if (litDeclinedCount != null) litDeclinedCount.Text = declinedCount.ToString();

                // Calculate available positions: 50 slots minus (Current Employees + Applicants in pipeline)
                int totalCapacity = 50;
                int totalOccupied = currentEmployeeCount;
                if (litAvailablePositions != null)
                {
                    litAvailablePositions.Text = Math.Max(0, totalCapacity - totalOccupied).ToString();
                }

                if (litAvailablePositionsList != null)
                {
                    // Identify roles that are occupied or reserved
                    var occupiedRoles = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                    // 1. Occupied by hired employees
                    if (employeesTask.Result != null)
                    {
                        foreach (var emp in employeesTask.Result)
                        {
                            if (!string.IsNullOrEmpty(emp.Role)) 
                                occupiedRoles.Add(emp.Role.Trim());
                        }
                    }

                    // 2. Reserved by applicants in critical pipeline stages (Removed per user request)
                    // Roles should now stay in "Currently Hiring" until someone is actually hired.


                    var activeRoleSalaries = (roleSalariesTask.Result ?? new List<RoleSalary>())
                                            .Where(r => r.IsActive == true)
                                            .ToList();
                    var positions = activeRoleSalaries.Select(r => r.RoleName).ToArray();

                    var sbPos = new StringBuilder();
                    int visibleCount = 0;

                    foreach (var pos in positions)
                    {
                        string trimmedPos = pos.Trim();
                        // Only show roles that are NOT yet occupied or reserved
                        if (!occupiedRoles.Contains(trimmedPos))
                        {
                            sbPos.AppendFormat("<div class='pos-item' style='display: flex; align-items: center; gap: 8px; cursor: pointer; transition: all 0.2s; padding: 4px 0;' onclick=\"filterByPosition('{0}')\" onmouseover=\"this.style.color='#3b82f6'\" onmouseout=\"this.style.color=''\" ><svg style='width:14px; height:14px; color:#3b82f6;' fill='currentColor' viewBox='0 0 20 20'><path fill-rule='evenodd' d='M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z' clip-rule='evenodd'></path></svg>{0}</div>", Server.HtmlEncode(pos));
                            visibleCount++;
                        }
                    }

                    if (visibleCount == 0)
                    {
                        sbPos.Append("<div style='color: #6b7280; font-style: italic; font-size: 13px;'>All current positions filled.</div>");
                    }

                    litAvailablePositionsList.Text = sbPos.ToString();

                    // Dynamic Dropdowns and JS Objects
                    if (activeRoleSalaries.Count > 0)
                    {
                        var deptGrouped = activeRoleSalaries.GroupBy(r => r.Department)
                                                            .OrderBy(g => g.Key)
                                                            .ToDictionary(g => g.Key, g => g.Select(r => r.RoleName).ToList());

                        // Populate ddlAppliedPosition if empty (first load)
                        if (ddlAppliedPosition.Items.Count <= 1)
                        {
                            foreach (var dept in deptGrouped.Keys)
                            {
                                ddlAppliedPosition.Items.Add(new ListItem(dept, dept));
                            }
                        }

                        // Inject JS for rolesByDepartment and salaryByRole
                        var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                        string rolesJson = serializer.Serialize(deptGrouped);
                        string salaryJson = serializer.Serialize(activeRoleSalaries.ToDictionary(r => r.RoleName, r => r.BaseSalary));

                        string script = $@"
                            rolesByDepartment = {rolesJson};
                            salaryByRole = {salaryJson};
                            if (typeof updateRoleOptions === 'function') updateRoleOptions();
                        ";
                        ScriptManager.RegisterStartupScript(this, GetType(), "DynamicRoles", script, true);
                    }
                }
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
                string dept = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string role = Server.HtmlEncode(applicant.Role ?? "");
                sb.AppendFormat(@"<tr data-fullname='{0}' data-position='{7}' data-sss='{3}' data-philhealth='{4}' data-pagibig='{5}' data-dept='{6}' data-role='{7}'>
                    <td class='checkbox-cell'><input type='checkbox' value='{2}' class='applicant-checkbox' /></td>
                    <td><strong>{0}</strong></td>
                    <td>{7}</td>
                    <td style='text-align: center;'>
                        <div class='action-buttons'>
                            <button class='btn btn-view-details' onclick=""viewApplicantDetails('{2}'); return false;"">View</button>
                        </div>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), dept, id, applicant.HasSSS.ToString().ToLower(), applicant.HasPhilHealth.ToString().ToLower(), applicant.HasPagIbig.ToString().ToLower(), dept, role);
            }
            newApplicantsTableBody.InnerHtml = sb.ToString();
        }

        private void PopulateForViewingApplicantsTable(List<Applicant> applicants)
        {
            if (applicants == null || applicants.Count == 0)
            {
                forViewingApplicantsTableBody.InnerHtml = "<tr><td colspan='4' class='empty-state'>No applicants currently in viewing</td></tr>";
                return;
            }

            var sb = new StringBuilder();
            foreach (var applicant in applicants)
            {
                string dept = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string role = Server.HtmlEncode(applicant.Role ?? "");
                string id = Server.HtmlEncode(applicant.Id);
                sb.AppendFormat(@"<tr data-sss='{3}' data-philhealth='{4}' data-pagibig='{5}'>
                    <td class='checkbox-cell'><input type='checkbox' value='{2}' class='applicant-checkbox' /></td>
                    <td><strong>{0}</strong></td>
                    <td>{1}</td>
                    <td style='text-align: center;'>
                        <div class='action-buttons'>
                            <button class='btn btn-view-details' style='background: #6c757d;' onclick=""viewApplicantDetails('{2}'); return false;"">View</button>
                            <button class='btn btn-approve' onclick=""approveApplicant('{2}', this); return false;"">Approve</button>
                            <button class='btn btn-decline' onclick=""declineApplicant('{2}', this); return false;"">Decline</button>
                        </div>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), role, id, 
                (!string.IsNullOrEmpty(applicant.SSSNumber)).ToString().ToLower(), 
                (!string.IsNullOrEmpty(applicant.PhilHealthNumber)).ToString().ToLower(), 
                (!string.IsNullOrEmpty(applicant.PagIbigNumber)).ToString().ToLower());
            }
            forViewingApplicantsTableBody.InnerHtml = sb.ToString();
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
                string dept = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string role = Server.HtmlEncode(applicant.Role ?? "");
                string approvedDateStr = (applicant.ApprovedDate ?? applicant.AppliedDate).ToString("yyyy-MM-dd");
                sb.AppendFormat(@"<tr data-fullname='{0}' data-position='{7}' data-sss='{3}' data-philhealth='{4}' data-pagibig='{5}' data-dept='{6}' data-role='{7}' data-approvedate='{8}'>
                    <td class='checkbox-cell'><input type='checkbox' value='{2}' class='applicant-checkbox' /></td>
                    <td><strong>{0}</strong></td>
                    <td>{7}</td>
                    <td style='text-align: center;'>
                        <span class='status-badge status-approved'>Approved</span>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"" style='margin-left: 12px;'>View Details</a>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), dept, Server.HtmlEncode(applicant.Id), applicant.HasSSS.ToString().ToLower(), applicant.HasPhilHealth.ToString().ToLower(), applicant.HasPagIbig.ToString().ToLower(), dept, role, approvedDateStr);
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
                string dept = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string role = Server.HtmlEncode(applicant.Role ?? "");
                sb.AppendFormat(@"<tr data-fullname='{0}' data-position='{7}' data-sss='{3}' data-philhealth='{4}' data-pagibig='{5}' data-dept='{6}' data-role='{7}'>
                    <td><strong>{0}</strong></td>
                    <td>{7}</td>
                    <td style='text-align: center;'>
                        <span class='status-badge status-declined'>Declined</span>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"" style='margin-left: 12px;'>View Details</a>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), Server.HtmlEncode(applicant.Id), applicant.HasSSS.ToString().ToLower(), applicant.HasPhilHealth.ToString().ToLower(), applicant.HasPagIbig.ToString().ToLower(), dept, role);
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
                string dept = Server.HtmlEncode(applicant.AppliedPosition ?? "");
                string role = Server.HtmlEncode(applicant.Role ?? "");
                sb.AppendFormat(@"<tr data-fullname='{0}' data-position='{10}' data-sss='{6}' data-philhealth='{7}' data-pagibig='{8}' data-dept='{9}' data-role='{10}'>
                    <td><strong>{0}</strong></td>
                    <td>{10}</td>
                    <td style='text-align: center;'>
                        <a href='#' class='status-link' onclick=""viewApplicantDetails('{2}'); return false;"">View Details</a>
                    </td>
                    <td style='text-align: center;'>
                        <div class='action-buttons'>
                            <button class='btn btn-hire' {3} onclick=""{4}"">{5}</button>
                            <button class='btn btn-not-hire' onclick=""notHireApplicant('{2}', this); return false;"">Not Hired</button>
                        </div>
                    </td>
                </tr>", Server.HtmlEncode(applicant.FullName), Server.HtmlEncode(applicant.AppliedPosition ?? ""), Server.HtmlEncode(applicant.Id), disabled, onclick, hireText, applicant.HasSSS.ToString().ToLower(), applicant.HasPhilHealth.ToString().ToLower(), applicant.HasPagIbig.ToString().ToLower(), dept, role);
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

                // Secondary safety check: ensure govt numbers are still present
                if (string.IsNullOrEmpty(applicant.SSSNumber) || 
                    string.IsNullOrEmpty(applicant.PhilHealthNumber) || 
                    string.IsNullOrEmpty(applicant.PagIbigNumber))
                {
                    ShowMessage("Cannot hire applicant. Government numbers are incomplete. Please update them in the details view.", false);
                    return;
                }

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
                    ContactNo = applicant.ContactNo,
                    Address = applicant.Address,
                    Street = applicant.Street,
                    City = applicant.City,
                    State = applicant.State,
                    Country = applicant.Country,
                    Age = applicant.Age,
                    BirthDate = applicant.BirthDate,
                    Gender = applicant.Gender,
                    Department = applicant.AppliedPosition,
                    Role = applicant.Role,
                    ContractType = applicant.ContractType ?? "Probationary",
                    BaseSalary = applicant.StartingSalary > 0 ? applicant.StartingSalary : 18000,
                    ApplicantId = applicantId,
                    HiredDate = DateTime.UtcNow,
                    HasSSS = applicant.HasSSS,
                    HasPhilHealth = applicant.HasPhilHealth,
                    HasPagIbig = applicant.HasPagIbig,
                    SSSNumber = applicant.SSSNumber,
                    PhilHealthNumber = applicant.PhilHealthNumber,
                    PagIbigNumber = applicant.PagIbigNumber,
                    ResumePath = applicant.ResumePath,
                    ResumeFileName = applicant.ResumeFileName,
                    IsActive = true
                };

                var created = await _employeeService.CreateEmployeeAndReturnAsync(employee);
                if (created != null)
                {
                    await _userService.EnsureEmployeeAccountAsync(created.Email, created.EmployeeId, created.FirstName, created.LastName,
                        created.MiddleName, created.Department, created.Role, created.HasSSS, created.HasPhilHealth, created.HasPagIbig);
                    await _applicantService.UpdateApplicantStatusAsync(applicantId, "Hired");
                    await _emailService.SendHiredEmailAsync(created.Email, created.FullName, created.Department, created.Role, created.Email, created.EmployeeId, false);
                    await LoadApplicantsData();
                    ShowMessage("Employee hired successfully and welcome email sent!", true);
                    ScriptManager.RegisterStartupScript(this, GetType(), "hireSuccess", "setTimeout(function() { window.location.reload(); }, 2000);", true);
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

            // Trigger premium status modal
            string cleanMessage = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = $"showEmailConfirmation('{cleanMessage}', {isSuccess.ToString().ToLower()});";
            ScriptManager.RegisterStartupScript(this, GetType(), "showStatusModal", script, true);
        }

        // Stubs for other handlers to match existing UI
        protected async void btnApproveApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                string id = hdnApplicantId.Value;
                if (string.IsNullOrEmpty(id)) return;

                var applicant = await _applicantService.GetApplicantByIdAsync(id);
                if (applicant == null) return;

                // Restriction: Must have complete government numbers BEFORE approval
                if (string.IsNullOrEmpty(applicant.SSSNumber) || 
                    string.IsNullOrEmpty(applicant.PhilHealthNumber) || 
                    string.IsNullOrEmpty(applicant.PagIbigNumber))
                {
                    ShowMessage("Cannot approve applicant. Government numbers (SSS, PhilHealth, Pag-IBIG) must be complete first.", false);
                    return;
                }

                bool success = await _applicantService.UpdateApplicantStatusAsync(id, "Approved");
                
                if (success)
                {
                    if (applicant != null && !string.IsNullOrEmpty(applicant.Email))
                    {
                        await _emailService.SendApprovalEmailAsync(applicant.Email, applicant.FullName);
                    }
                    await LoadApplicantsData();
                    ShowMessage("Applicant approved successfully and notification email sent.", true);
                }
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        protected async void btnDeclineApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                string id = hdnApplicantId.Value;
                string reason = hdnDeclineReason.Value;
                if (string.IsNullOrEmpty(id)) return;

                var applicant = await _applicantService.GetApplicantByIdAsync(id);
                bool success = await _applicantService.UpdateDeclinedStatusAsync(id, reason);
                
                if (success)
                {
                    if (applicant != null && !string.IsNullOrEmpty(applicant.Email))
                    {
                        await _emailService.SendRejectionEmailAsync(applicant.Email, applicant.FullName, reason);
                    }
                    await LoadApplicantsData();
                    ShowMessage("Applicant declined and notification email sent.", true);
                    // Clear the reason field
                    txtDeclineReason.Text = "";
                    hdnDeclineReason.Value = "";
                }
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        protected async void btnScheduleInterview_Click(object sender, EventArgs e)
        {
            try
            {
                string idsRaw = hdnSelectedApplicantIds.Value;
                if (string.IsNullOrEmpty(idsRaw)) return;

                string[] applicantIds = idsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                // Automatically set interview to the Upcoming Monday
                DateTime today = DateTime.Now;
                int daysUntilMonday = ((int)DayOfWeek.Monday - (int)today.DayOfWeek + 7) % 7;
                if (daysUntilMonday == 0) daysUntilMonday = 7; // If today is Monday, schedule for next week
                DateTime interviewDate = today.AddDays(daysUntilMonday);
                
                // Get the manually selected time
                string timeStrRaw = txtInterviewTime.Text;
                string timeStr = "";
                DateTime fullInterviewDateTime = interviewDate.Date;

                if (DateTime.TryParse(timeStrRaw, out DateTime parsedTime))
                {
                    timeStr = parsedTime.ToString("hh:mm tt");
                    fullInterviewDateTime = interviewDate.Date.Add(parsedTime.TimeOfDay);
                }
                else
                {
                    // Fallback to 9:00 AM if parsing fails for some reason
                    timeStr = "09:00 AM";
                    fullInterviewDateTime = interviewDate.Date.Add(new TimeSpan(9, 0, 0));
                }

                string location = txtInterviewLocation.Text;
                string interviewer = txtInterviewerName.Text;
                string notes = txtInterviewNotes.Text;

                int successCount = 0;
                int emailCount = 0;

                foreach (string id in applicantIds)
                {
                    var applicant = await _applicantService.GetApplicantByIdAsync(id);
                    if (applicant == null) continue;
                    
                    bool success = await _applicantService.ScheduleInterviewAsync(
                        id, interviewDate, timeStr, location, interviewer, notes, "HR Manager"
                    );

                    if (success)
                    {
                        successCount++;
                        if (applicant != null && !string.IsNullOrEmpty(applicant.Email))
                        {
                            bool emailSent = await _emailService.SendInterviewInvitationEmailAsync(
                                applicant.Email, applicant.FullName, fullInterviewDateTime, location, interviewer, notes
                            );
                            if (emailSent) emailCount++;
                        }
                    }
                }

                if (successCount > 0)
                {
                    await LoadApplicantsData();
                    string msg = $"Successfully scheduled interviews for {successCount} applicant(s).";
                    if (emailCount > 0) msg += $" Sent {emailCount} invitation email(s).";
                    
                    ShowMessage(msg, true);

                    // Trigger modal close and UI refresh on client side
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeScheduleModal",
                        "closeScheduleInterviewModal();", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error scheduling interviews: " + ex.Message, false);
            }
        }

        protected void btnCancelSchedule_Click(object sender, EventArgs e)
        {
        }

        protected async void btnSendRequirementEmail_Click(object sender, EventArgs e)
        {
            try
            {
                string idsRaw = hdnSelectedNewApplicantIds.Value;
                if (string.IsNullOrEmpty(idsRaw)) return;

                string[] applicantIds = idsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                DateTime deadline = DateTime.UtcNow.AddDays(7);
                int successCount = 0;

                foreach (string id in applicantIds)
                {
                    var applicant = await _applicantService.GetApplicantByIdAsync(id);
                    if (applicant != null && !string.IsNullOrEmpty(applicant.Email))
                    {
                        bool emailSent = await _emailService.SendRequirementRequestEmailAsync(applicant.Email, applicant.FullName, deadline);
                        if (emailSent)
                        {
                            await _applicantService.UpdateApplicantStatusAsync(id, "For Viewing");
                            successCount++;
                        }
                    }
                }

                if (successCount > 0)
                {
                    await LoadApplicantsData();
                    ShowMessage($"Successfully requested requirements and moved {successCount} applicant(s) to For Viewing.", true);
                    hdnSelectedNewApplicantIds.Value = "";
                }
                else
                {
                    ShowMessage("Failed to send emails. Please check your SMTP configuration.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }
        protected void btnNotHireApplicant_Click(object sender, EventArgs e) 
        { 
        }
    }
}