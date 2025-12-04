using ExWebAppSia.Models;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;

namespace ExWebAppSia.webpage
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string _announcementHtml = string.Empty;
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly ApplicantService _applicantService = new ApplicantService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
  private readonly LeaveService _leaveService = new LeaveService();

protected void Page_Load(object sender, EventArgs e)
        {
     // Check authentication first
    if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
    Response.Redirect("~/LoginFolder/Login.aspx", false);
   Context.ApplicationInstance.CompleteRequest();
 return;
   }

   if (!IsPostBack)
         {
      // Load all dashboard data asynchronously
     RegisterAsyncTask(new PageAsyncTask(LoadDashboardDataAsync));
     }
        }

        private async Task LoadDashboardDataAsync()
   {
try
       {
        // Load all data in parallel for better performance
 var employeesTask = LoadEmployeeData();
   var applicantsTask = LoadApplicantData();
      var attendanceTask = LoadAttendanceData();
      var announcementsTask = LoadRecentAnnouncementsAsync();

     await Task.WhenAll(employeesTask, applicantsTask, attendanceTask, announcementsTask);
     }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading dashboard data: {ex.Message}");
   }
        }

      private async Task LoadEmployeeData()
        {
      try
            {
     var employees = await _employeeService.GetAllEmployeesAsync();

     // Total employees
                int totalEmployees = employees.Count;
       int femaleCount = employees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
         e.Gender.Equals("Female", StringComparison.OrdinalIgnoreCase));
  int maleCount = employees.Count(e => !string.IsNullOrEmpty(e.Gender) && 
        e.Gender.Equals("Male", StringComparison.OrdinalIgnoreCase));

      // Working format (Contract Type)
       int regularCount = employees.Count(e => e.ContractType == "Regular");
    int contractualCount = employees.Count(e => e.ContractType == "Contractual");

                double regularPercentage = totalEmployees > 0 ? (regularCount * 100.0 / totalEmployees) : 0;
     double contractualPercentage = totalEmployees > 0 ? (contractualCount * 100.0 / totalEmployees) : 0;

     // Update UI elements
    if (litTotalEmployees != null) litTotalEmployees.Text = totalEmployees.ToString();
     if (litFemaleCount != null) litFemaleCount.Text = femaleCount.ToString();
           if (litMaleCount != null) litMaleCount.Text = maleCount.ToString();
              
                // Update Working Format percentages
                if (litRegularPercentage != null) litRegularPercentage.Text = regularPercentage.ToString("F0");
                if (litRegularPercentageDisplay != null) litRegularPercentageDisplay.Text = $"{regularPercentage:F0}%";
                if (litContractualPercentage != null) litContractualPercentage.Text = contractualPercentage.ToString("F0");
                if (litContractualPercentageDisplay != null) litContractualPercentageDisplay.Text = $"{contractualPercentage:F0}%";
             
                // Load employee summary (top 3 recent)
         var recentEmployees = employees
          .Where(e => e.IsActive)
  .OrderByDescending(e => e.HiredDate)
       .Take(3)
  .ToList();
          LoadEmployeeSummary(recentEmployees);
            }
        catch (Exception ex)
         {
    System.Diagnostics.Debug.WriteLine($"Error loading employee data: {ex.Message}");
      // Set default values on error
            if (litTotalEmployees != null) litTotalEmployees.Text = "0";
  if (litFemaleCount != null) litFemaleCount.Text = "0";
                if (litMaleCount != null) litMaleCount.Text = "0";
                if (litRegularPercentage != null) litRegularPercentage.Text = "0";
                if (litRegularPercentageDisplay != null) litRegularPercentageDisplay.Text = "0%";
                if (litContractualPercentage != null) litContractualPercentage.Text = "0";
                if (litContractualPercentageDisplay != null) litContractualPercentageDisplay.Text = "0%";
            }
     }

        private async Task LoadApplicantData()
     {
            try
          {
var applicants = await _applicantService.GetAllApplicantsAsync();

   int totalApplicants = applicants.Count;
         int inProgressCount = applicants.Count(a => 
            a.Status != null && a.Status.Equals("In-Progress", StringComparison.OrdinalIgnoreCase));
           int completedCount = applicants.Count(a => 
     a.Status != null && (a.Status.Equals("Hired", StringComparison.OrdinalIgnoreCase) || 
           a.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase)));

           if (litTotalApplicants != null) litTotalApplicants.Text = totalApplicants.ToString();
              if (litInProgressApplicants != null) litInProgressApplicants.Text = inProgressCount.ToString();
    if (litCompletedApplicants != null) litCompletedApplicants.Text = completedCount.ToString();
            }
            catch (Exception ex)
     {
             System.Diagnostics.Debug.WriteLine($"Error loading applicant data: {ex.Message}");
     if (litTotalApplicants != null) litTotalApplicants.Text = "0";
     if (litInProgressApplicants != null) litInProgressApplicants.Text = "0";
 if (litCompletedApplicants != null) litCompletedApplicants.Text = "0";
}
        }

    private async Task LoadAttendanceData()
   {
       try
   {
                var today = DateTime.Today;
     var attendanceRecords = await _attendanceService.GetAttendanceByDateAsync(today);
     
              // Get all employees to calculate absent count
      var allEmployees = await _employeeService.GetAllEmployeesAsync();
 int totalActiveEmployees = allEmployees.Count(e => e.IsActive);
                
       // Get leave records for today
    var leavesToday = await _leaveService.GetLeavesByDateAsync(today);
       int onLeaveCount = leavesToday.Count(l => l.Status == "Approved");
           
           // Calculate attendance status based on TimeIn
        // Present: Has TimeIn record
           // Late: Clocked in after 9:00 AM
          // Absent: No time in record and not on leave
          
    int presentCount = attendanceRecords.Count(a => a.TimeIn.HasValue);
          int lateCount = attendanceRecords.Count(a => a.TimeIn.HasValue && 
      a.TimeIn.Value.ToLocalTime().Hour >= 9);
       
  // Calculate absent: Total employees - Present - On Leave
       int absentCount = totalActiveEmployees - presentCount - onLeaveCount;
      if (absentCount < 0) absentCount = 0;

           // Update UI elements
          if (litPresentCount != null) litPresentCount.Text = presentCount.ToString();
 if (litAbsentCount != null) litAbsentCount.Text = absentCount.ToString();
    if (litOnLeaveCount != null) litOnLeaveCount.Text = onLeaveCount.ToString();
      if (litLateCount != null) litLateCount.Text = lateCount.ToString();
        
    // Update JavaScript literals for chart
  if (litPresentCountJS != null) litPresentCountJS.Text = presentCount.ToString();
          if (litAbsentCountJS != null) litAbsentCountJS.Text = absentCount.ToString();
        if (litOnLeaveCountJS != null) litOnLeaveCountJS.Text = onLeaveCount.ToString();
if (litLateCountJS != null) litLateCountJS.Text = lateCount.ToString();
        }
   catch (Exception ex)
    {
 System.Diagnostics.Debug.WriteLine($"Error loading attendance data: {ex.Message}");
              if (litPresentCount != null) litPresentCount.Text = "0";
  if (litAbsentCount != null) litAbsentCount.Text = "0";
                if (litOnLeaveCount != null) litOnLeaveCount.Text = "0";
  if (litLateCount != null) litLateCount.Text = "0";
  }
        }

     private void LoadEmployeeSummary(System.Collections.Generic.List<Employee> employees)
        {
            var sb = new StringBuilder();

    if (employees == null || employees.Count == 0)
      {
     sb.Append(@"<tr><td colspan='3' style='text-align:center; padding:20px; color:#999;'>No employees found</td></tr>");
        }
   else
       {
          foreach (var emp in employees)
   {
       string name = Server.HtmlEncode(emp.FullName ?? "N/A");
          string role = Server.HtmlEncode(emp.Role ?? "No Role");
           string salary = "₱0"; // You can add salary field to Employee model if needed
              string status = "Unpaid"; // Default status, can be updated based on payroll data
       string statusClass = status.ToLower();

    sb.Append($@"
            <tr>
     <td>
        <div class='employee-img'></div>
     <div class='employee-info'>
        <div class='employee-name'>{name}</div>
       <div class='employee-role'>{role}</div>
         </div>
      </td>
           <td style='font-weight: 600;'>{salary}</td>
           <td><span class='status-badge status-{statusClass}'>{status}</span></td>
    </tr>");
        }
            }

            if (phEmployeeSummary != null)
            {
            phEmployeeSummary.Controls.Clear();
                phEmployeeSummary.Controls.Add(new LiteralControl(sb.ToString()));
     }
   }

    private async Task LoadRecentAnnouncementsAsync()
   {
    // Use a timeout to prevent hanging
    var loadTask = LoadRecentAnnouncements();
            var timeoutTask = Task.Delay(5000); // 5 second timeout

   var completedTask = await Task.WhenAny(loadTask, timeoutTask);

            if (completedTask == timeoutTask)
      {
  _announcementHtml = "<li class='announcement-item' style='text-align:center; padding:10px; color:#666;'>Loading announcements...</li>";
  }
  else
         {
    // Task completed successfully, make sure we wait for it
    await loadTask;
         }
        }

        protected override void OnPreRender(EventArgs e)
        {
    base.OnPreRender(e);
     
       System.Diagnostics.Debug.WriteLine($"=== OnPreRender Called ===");
  System.Diagnostics.Debug.WriteLine($"_announcementHtml length: {_announcementHtml?.Length ?? 0}");
System.Diagnostics.Debug.WriteLine($"_announcementHtml content: {_announcementHtml?.Substring(0, Math.Min(100, _announcementHtml?.Length ?? 0))}...");
      System.Diagnostics.Debug.WriteLine($"phAnnouncements is null: {phAnnouncements == null}");
            
   if (!string.IsNullOrEmpty(_announcementHtml) && phAnnouncements != null)
        {
            System.Diagnostics.Debug.WriteLine("Adding announcement HTML to placeholder");
      phAnnouncements.Controls.Clear();
      phAnnouncements.Controls.Add(new LiteralControl(_announcementHtml));
       System.Diagnostics.Debug.WriteLine($"Placeholder now has {phAnnouncements.Controls.Count} controls");
            }
   else
     {
    if (string.IsNullOrEmpty(_announcementHtml))
   {
        System.Diagnostics.Debug.WriteLine("WARNING: _announcementHtml is empty or null");
  }
          if (phAnnouncements == null)
   {
  System.Diagnostics.Debug.WriteLine("WARNING: phAnnouncements placeholder is null!");
  }
  }
System.Diagnostics.Debug.WriteLine("=== OnPreRender Completed ===");
    }

        private async Task LoadRecentAnnouncements()
        {
     try
          {
        System.Diagnostics.Debug.WriteLine("=== LoadRecentAnnouncements Started ===");
var service = new AnnouncementService();
   
     System.Diagnostics.Debug.WriteLine("Fetching announcements from database...");
     var items = await service.GetRecentAsync(3); // Show top 3 recent announcements

 System.Diagnostics.Debug.WriteLine($"Fetched {items?.Count ?? 0} announcements");

   var sb = new StringBuilder();

 if (items == null || items.Count == 0)
         {
System.Diagnostics.Debug.WriteLine("No announcements found");
     sb.Append("<li class='announcement-item' style='text-align:center; padding:15px; color:#999;'>No announcements yet</li>");
   }
          else
    {
 System.Diagnostics.Debug.WriteLine($"Processing {items.Count} announcements:");
    foreach (var a in items)
 {
      // Handle null values gracefully
 string content = !string.IsNullOrEmpty(a.Content) ? a.Content : "No content";
string postedBy = !string.IsNullOrEmpty(a.PostedBy) ? a.PostedBy : "HR Admin";
    string dateStr = a.PostedDate.ToLocalTime().ToString("MMM dd, yyyy");
     
          System.Diagnostics.Debug.WriteLine($"  - Content: {content.Substring(0, Math.Min(30, content.Length))}..., Posted by: {postedBy}, Date: {dateStr}");

   string title = Server.HtmlEncode(content.Length > 50
 ? content.Substring(0, 50) + "..."
: content);

      sb.Append($@"
 <li class='announcement-item'>
  <div class='announcement-title'>{title}</div>
     <div class='announcement-date'>{postedBy} • {dateStr}</div>
        </li>");
    }
 }

        _announcementHtml = sb.ToString();
   System.Diagnostics.Debug.WriteLine($"HTML Length: {_announcementHtml.Length} characters");
     
      // CRITICAL FIX: Set the placeholder content directly here, not in OnPreRender
     if (phAnnouncements != null && !string.IsNullOrEmpty(_announcementHtml))
        {
          System.Diagnostics.Debug.WriteLine("Setting placeholder content directly in LoadRecentAnnouncements");
  phAnnouncements.Controls.Clear();
         phAnnouncements.Controls.Add(new LiteralControl(_announcementHtml));
      System.Diagnostics.Debug.WriteLine($"Placeholder set with {phAnnouncements.Controls.Count} controls");
}
     
   System.Diagnostics.Debug.WriteLine("=== LoadRecentAnnouncements Completed Successfully ===");
}
   catch (Exception ex)
     {
     System.Diagnostics.Debug.WriteLine($"=== ERROR in LoadRecentAnnouncements ===");
System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
    System.Diagnostics.Debug.WriteLine($"Stack: {ex.StackTrace}");
  _announcementHtml = $"<li class='announcement-item' style='color:#c62828; padding:10px;'>Error: {Server.HtmlEncode(ex.Message)}</li>";
       }
        }
    }
}