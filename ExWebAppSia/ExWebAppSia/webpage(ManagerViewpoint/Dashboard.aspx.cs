using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using ManagerModel = ExWebAppSia.Models.Manager;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly LeaveService _leaveService = new LeaveService();
        private readonly AnnouncementService _announcementService = new AnnouncementService();

        protected List<Employee> DepartmentEmployees { get; set; }
        protected List<Attendance> TodayAttendanceRecords { get; set; }
        protected List<Leave> TodayLeaves { get; set; }
        protected List<Announcement> RecentAnnouncements { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadDashboardDataAsync));
            }
        }

        private async Task LoadDashboardDataAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.Department))
                {
                    DepartmentEmployees = new List<Employee>();
                    TodayAttendanceRecords = new List<Attendance>();
                    TodayLeaves = new List<Leave>();
                    RecentAnnouncements = new List<Announcement>();
                    return;
                }

                // Load employees in manager's department
                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);

                // Load today's attendance
                var today = DateTime.Now.Date;
                var utcToday = today.ToUniversalTime().Date;
                var allAttendance = await _attendanceService.GetAttendanceByDateAsync(utcToday);
                var employeeIds = DepartmentEmployees.Select(e => e.EmployeeId).ToList();
                TodayAttendanceRecords = allAttendance
                    .Where(a => employeeIds.Contains(a.EmployeeId) && 
                               a.TimeIn.HasValue && 
                               a.TimeIn.Value.ToLocalTime().Date == today)
                    .ToList();

                // Load today's leaves
                var allLeaves = await _leaveService.GetAllLeavesAsync();
                var todayLeaves = allLeaves
                    .Where(l => employeeIds.Contains(l.EmployeeId) &&
                               l.Status == "Approved" &&
                               l.StartDate <= today &&
                               l.EndDate >= today)
                    .ToList();
                TodayLeaves = todayLeaves;

                // Load recent announcements
                RecentAnnouncements = await _announcementService.GetRecentAsync(3);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading dashboard data: {ex.Message}");
                DepartmentEmployees = new List<Employee>();
                TodayAttendanceRecords = new List<Attendance>();
                TodayLeaves = new List<Leave>();
                RecentAnnouncements = new List<Announcement>();
            }
        }

        protected ManagerModel CurrentManager
        {
            get
            {
                return Session["Manager"] as ManagerModel;
            }
        }

        protected int GetTotalEmployees()
        {
            return DepartmentEmployees?.Count ?? 0;
        }

        protected int GetFemaleCount()
        {
            if (DepartmentEmployees == null) return 0;
            return DepartmentEmployees.Count(e => e.Gender?.ToLower() == "female");
        }

        protected int GetMaleCount()
        {
            if (DepartmentEmployees == null) return 0;
            return DepartmentEmployees.Count(e => e.Gender?.ToLower() == "male");
        }

        protected int GetPresentCount()
        {
            if (TodayAttendanceRecords == null || DepartmentEmployees == null)
                return 0;
            
            var presentEmployeeIds = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.EmployeeId)
                .Distinct()
                .ToList();
            
            return presentEmployeeIds.Count;
        }

        protected int GetAbsentCount()
        {
            if (DepartmentEmployees == null || TodayAttendanceRecords == null)
                return 0;
            
            var presentEmployeeIds = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.EmployeeId)
                .Distinct()
                .ToList();
            
            return DepartmentEmployees.Count(e => !presentEmployeeIds.Contains(e.EmployeeId));
        }

        protected int GetOnLeaveCount()
        {
            return TodayLeaves?.Count ?? 0;
        }

        protected int GetLateCount()
        {
            if (TodayAttendanceRecords == null)
                return 0;
            
            var lateCount = TodayAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .GroupBy(a => a.EmployeeId)
                .Count(g =>
                {
                    var firstTimeIn = g.OrderBy(x => x.TimeIn).First().TimeIn.Value.ToLocalTime();
                    return firstTimeIn.Hour > 8 || (firstTimeIn.Hour == 8 && firstTimeIn.Minute > 0);
                });
            
            return lateCount;
        }

        protected string GetEmployeeInitials(Employee employee)
        {
            if (employee == null) return "??";
            var first = employee.FirstName?.Substring(0, 1).ToUpper() ?? "";
            var last = employee.LastName?.Substring(0, 1).ToUpper() ?? "";
            return first + last;
        }

        protected List<Employee> GetEmployeeSummaryList()
        {
            if (DepartmentEmployees == null) return new List<Employee>();
            // Return first 5 employees for summary
            return DepartmentEmployees.Take(5).ToList();
        }
    }
}