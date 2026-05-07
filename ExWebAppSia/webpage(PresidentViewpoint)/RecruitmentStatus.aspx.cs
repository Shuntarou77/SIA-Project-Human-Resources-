using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using MongoDB.Driver;
using MongoDB.Bson;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class RecruitmentStatus : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Repeater rptJobs;
        protected global::System.Web.UI.WebControls.Repeater rptApplicants;
        protected global::System.Web.UI.WebControls.Literal litTotalApplied;
        protected global::System.Web.UI.WebControls.Literal litRejected;
        protected global::System.Web.UI.WebControls.Literal litInterviewing;
        protected global::System.Web.UI.WebControls.Literal litHired;
        protected global::System.Web.UI.WebControls.Literal litOpenPositions;
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly RoleSalaryService _roleSalaryService = new RoleSalaryService();
        private readonly EmployeeService _employeeService = new EmployeeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadRecruitmentDataAsync));
            }
        }

        private async Task LoadRecruitmentDataAsync()
        {
            try
            {
                var applicants = await _applicantService.GetAllApplicantsAsync();
                
                // Define pipeline early to avoid declaration scope errors
                var applicantsInPipeline = applicants.Where(a => a.Status != "Hired" && a.Status != "Rejected").ToList();

                // Stats - Updated to reflect only active pipeline data
                litTotalApplied.Text = applicantsInPipeline.Count.ToString();
                litInterviewing.Text = applicantsInPipeline.Count(a => a.Status == "Interviewing" || a.Status == "Schedules" || a.Status == "For Viewing").ToString();
                litHired.Text = "0"; 
                litRejected.Text = "0"; 

                // List - Show only active candidates in the pipeline
                rptApplicants.DataSource = applicantsInPipeline.OrderByDescending(a => a.AppliedDate).Take(15).ToList();
                rptApplicants.DataBind();

                // Aggregate Job Postings
                var applicantCounts = applicantsInPipeline.GroupBy(a => a.Role)
                    .ToDictionary(g => g.Key ?? "", g => g.Count(), StringComparer.OrdinalIgnoreCase);

                // Fetch data for vacancy logic
                var roleSalaries = await _roleSalaryService.GetAllRoleSalariesAsync();
                var employees = await _employeeService.GetAllEmployeesAsync();
                var resignedEmployees = await _employeeService.GetAllResignedEmployeesAsync();
                
                // Track on-leave employees for contractual replacements
                var leafIds = new HashSet<string>();
                try {
                    var leaveCol = MongoDBHelper.GetLeavesCollection();
                    var today = DateTime.UtcNow.AddHours(8).Date;
                    var leafFilter = Builders<Leave>.Filter.And(
                        Builders<Leave>.Filter.Eq(l => l.Status, "Approved"),
                        Builders<Leave>.Filter.Lte(l => l.StartDate, today),
                        Builders<Leave>.Filter.Gte(l => l.EndDate, today)
                    );
                    var currentLeaves = await leaveCol.Find(leafFilter).ToListAsync();
                    leafIds = new HashSet<string>(currentLeaves.Select(l => l.EmployeeId));
                } catch { }

                // Determine occupied roles (active employees NOT on leave)
                var occupiedRoles = new HashSet<string>(employees
                    .Where(e => !leafIds.Contains(e.EmployeeId))
                    .Select(e => e.Role?.Trim() ?? "")
                    .Where(r => !string.IsNullOrEmpty(r)), StringComparer.OrdinalIgnoreCase);

                // Determine positions that are open
                var jobs = new List<object>();

                // 1. Regular Vacancies from RoleSalary
                foreach (var rs in roleSalaries.Where(r => r.IsActive))
                {
                    if (!occupiedRoles.Contains(rs.RoleName))
                    {
                        jobs.Add(new {
                            Title = rs.RoleName,
                            Department = rs.Department,
                            Type = "Full-time",
                            ApplicantCount = applicantCounts.ContainsKey(rs.RoleName) ? applicantCounts[rs.RoleName] : 0
                        });
                    }
                }

                // 2. Extra Vacancies from Resigned Employees (if not already in roleSalaries list)
                var existingJobTitles = new HashSet<string>(jobs.Select(j => (string)((dynamic)j).Title), StringComparer.OrdinalIgnoreCase);
                foreach (var resigned in resignedEmployees)
                {
                    if (!string.IsNullOrEmpty(resigned.Role) && !occupiedRoles.Contains(resigned.Role) && !existingJobTitles.Contains(resigned.Role))
                    {
                        jobs.Add(new {
                            Title = resigned.Role,
                            Department = resigned.Department ?? "General",
                            Type = "Full-time",
                            ApplicantCount = applicantCounts.ContainsKey(resigned.Role) ? applicantCounts[resigned.Role] : 0
                        });
                        existingJobTitles.Add(resigned.Role);
                    }
                }

                // 3. Contractual Replacements (specifically for those on leave)
                if (leafIds.Count > 0)
                {
                    var onLeaveEmployees = employees.Where(e => leafIds.Contains(e.EmployeeId)).ToList();
                    foreach (var emp in onLeaveEmployees)
                    {
                        string replacementTitle = $"{emp.Role} (Replacement)";
                        jobs.Insert(0, new {
                            Title = replacementTitle,
                            Department = emp.Department ?? "Operations",
                            Type = "Contractual",
                            ApplicantCount = applicantCounts.ContainsKey(replacementTitle) ? applicantCounts[replacementTitle] : 0
                        });
                    }
                }

                rptJobs.DataSource = jobs;
                rptJobs.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading Recruitment Status: {ex.Message}");
            }
        }

        protected string GetStatusClass(object status)
        {
            string s = status?.ToString() ?? "";
            switch (s)
            {
                case "Hired": return "badge-hired";
                case "Rejected": return "badge-rejected";
                case "Interviewing": 
                case "Scheduled": return "badge-interview";
                default: return "badge-pending";
            }
        }
    }
}

