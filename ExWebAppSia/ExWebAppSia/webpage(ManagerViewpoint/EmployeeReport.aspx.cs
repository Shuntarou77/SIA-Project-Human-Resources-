using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using ExWebAppSia.Models;
using ManagerModel = ExWebAppSia.Models.Manager;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class EmployeeReport : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();

        protected List<Employee> DepartmentEmployees { get; set; }
        protected List<Attendance> TodayAttendanceRecords { get; set; }
        protected List<EmployeePerformanceData> PerformanceData { get; set; }
        protected DateTime SelectedDate { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Get selected date from query string or default to today
            string dateParam = Request.QueryString["date"];
            if (!string.IsNullOrEmpty(dateParam) && DateTime.TryParse(dateParam, out DateTime selectedDate))
            {
                SelectedDate = selectedDate.Date;
            }
            else
            {
                SelectedDate = DateTime.Now.Date;
            }

            RegisterAsyncTask(new PageAsyncTask(LoadReportDataAsync));
        }

        private async Task LoadReportDataAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.Department))
                {
                    DepartmentEmployees = new List<Employee>();
                    TodayAttendanceRecords = new List<Attendance>();
                    PerformanceData = new List<EmployeePerformanceData>();
                    return;
                }

                // Get all employees in the manager's department
                DepartmentEmployees = await _employeeService.GetEmployeesByDepartmentAsync(manager.Department);

                // Get attendance records for the selected date
                var utcDate = SelectedDate.ToUniversalTime().Date;
                var allAttendanceRecords = await _attendanceService.GetAttendanceByDateAsync(utcDate);
                
                var employeeIds = DepartmentEmployees.Select(e => e.EmployeeId).ToList();
                TodayAttendanceRecords = allAttendanceRecords
                    .Where(a => employeeIds.Contains(a.EmployeeId) && 
                               a.TimeIn.HasValue && 
                               a.TimeIn.Value.ToLocalTime().Date == SelectedDate)
                    .ToList();

                // Calculate performance data for last 30 days
                var endDate = DateTime.UtcNow;
                var startDate = endDate.AddDays(-30);
                PerformanceData = new List<EmployeePerformanceData>();

                foreach (var employee in DepartmentEmployees)
                {
                    var attendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(
                        employee.EmployeeId, startDate, endDate);
                    
                    var stats = CalculateAttendanceStats(attendanceRecords, startDate, endDate);
                    var concerns = await _concernService.GetConcernsByEmployeeIdAsync(employee.EmployeeId);
                    var activeConcerns = concerns.Count(c => c.Status != "Resolved" && c.Status != "Closed");
                    
                    var performanceScore = CalculatePerformanceScore(stats, activeConcerns);
                    
                    PerformanceData.Add(new EmployeePerformanceData
                    {
                        EmployeeId = employee.EmployeeId,
                        EmployeeName = employee.FullName,
                        Department = employee.Department,
                        AttendanceRate = stats.AttendanceRate,
                        PerformanceScore = performanceScore
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading report data: {ex.Message}");
                DepartmentEmployees = new List<Employee>();
                TodayAttendanceRecords = new List<Attendance>();
                PerformanceData = new List<EmployeePerformanceData>();
            }
        }

        private AttendanceStats CalculateAttendanceStats(List<Attendance> records, DateTime startDate, DateTime endDate)
        {
            var stats = new AttendanceStats();
            var totalDays = (endDate - startDate).Days + 1;
            
            var presentDays = records
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.TimeIn.Value.ToLocalTime().Date)
                .Distinct()
                .Count();
            
            stats.PresentDays = presentDays;
            stats.AbsentDays = totalDays - presentDays;
            stats.TotalDays = totalDays;
            stats.AttendanceRate = totalDays > 0 ? (presentDays * 100.0 / totalDays) : 0;
            stats.LateCount = records.Count(a => 
                a.TimeIn.HasValue && 
                (a.TimeIn.Value.ToLocalTime().Hour > 8 || 
                 (a.TimeIn.Value.ToLocalTime().Hour == 8 && a.TimeIn.Value.ToLocalTime().Minute > 0)));
            
            return stats;
        }

        private double CalculatePerformanceScore(AttendanceStats stats, int activeConcerns)
        {
            // Base performance on attendance (70%) and concerns (30%)
            var baseScore = stats.AttendanceRate * 0.7;
            var concernPenalty = Math.Min(activeConcerns * 5, 30); // Max 30 point penalty
            var performanceScore = Math.Max(0, baseScore - concernPenalty);

            // Add bonus for good attendance (no lates, high attendance rate)
            if (stats.LateCount == 0 && stats.AttendanceRate >= 95)
            {
                performanceScore = Math.Min(100, performanceScore + 10);
            }

            return Math.Round(performanceScore, 1);
        }

        protected ManagerModel CurrentManager
        {
            get
            {
                return Session["Manager"] as ManagerModel;
            }
        }

        protected string GetManagerDepartment()
        {
            var manager = CurrentManager;
            return manager?.Department ?? "N/A";
        }

        protected int GetTeamMembersCount()
        {
            return DepartmentEmployees?.Count ?? 0;
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

        protected string GetReportDateDisplay()
        {
            return SelectedDate.ToString("MMMM dd, yyyy");
        }

        protected List<Employee> GetSortedEmployees()
        {
            if (DepartmentEmployees == null)
                return new List<Employee>();
            
            return DepartmentEmployees
                .OrderBy(e => e.LastName ?? "")
                .ThenBy(e => e.FirstName ?? "")
                .ToList();
        }

        protected Attendance GetEmployeeAttendance(Employee employee)
        {
            if (TodayAttendanceRecords == null || employee == null)
                return null;
            
            return TodayAttendanceRecords
                .Where(a => a.EmployeeId == employee.EmployeeId)
                .OrderByDescending(a => a.TimeIn)
                .FirstOrDefault();
        }

        protected string FormatTime(DateTime? time)
        {
            if (!time.HasValue) return "—";
            return time.Value.ToLocalTime().ToString("hh:mm tt");
        }

        protected string GetAttendanceStatus(Employee employee, Attendance attendance)
        {
            if (attendance == null || !attendance.TimeIn.HasValue)
                return "Absent";

            var timeIn = attendance.TimeIn.Value.ToLocalTime();
            if (timeIn.Hour > 8 || (timeIn.Hour == 8 && timeIn.Minute > 0))
                return "Late";

            return "Present";
        }

        protected string GetHoursWorked(Attendance attendance)
        {
            if (attendance == null || !attendance.TimeIn.HasValue)
                return "0h 00m";

            var timeIn = attendance.TimeIn.Value.ToLocalTime();
            var timeOut = attendance.TimeOut?.ToLocalTime();

            if (timeOut.HasValue)
            {
                var duration = timeOut.Value - timeIn;
                var hours = (int)duration.TotalHours;
                var minutes = duration.Minutes;
                return $"{hours}h {minutes:D2}m";
            }

            return "—";
        }

        protected string GetStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "present":
                    return "status-present";
                case "late":
                    return "status-late";
                case "absent":
                    return "status-absent";
                default:
                    return "status-absent";
            }
        }

        protected string GetPerformanceBadgeClass(double score)
        {
            if (score >= 90) return "badge-excellent";
            if (score >= 75) return "badge-good";
            if (score >= 60) return "badge-average";
            return "badge-poor";
        }

        protected string GetPerformanceStatus(double score)
        {
            if (score >= 90) return "Excellent";
            if (score >= 75) return "Good";
            if (score >= 60) return "Average";
            return "Needs Improvement";
        }

        protected int GetExcellentCount()
        {
            if (PerformanceData == null) return 0;
            return PerformanceData.Count(p => p.PerformanceScore >= 90);
        }

        protected int GetGoodCount()
        {
            if (PerformanceData == null) return 0;
            return PerformanceData.Count(p => p.PerformanceScore >= 75 && p.PerformanceScore < 90);
        }

        protected int GetAverageCount()
        {
            if (PerformanceData == null) return 0;
            return PerformanceData.Count(p => p.PerformanceScore >= 60 && p.PerformanceScore < 75);
        }

        protected int GetPoorCount()
        {
            if (PerformanceData == null) return 0;
            return PerformanceData.Count(p => p.PerformanceScore < 60);
        }

        private class AttendanceStats
        {
            public int PresentDays { get; set; }
            public int AbsentDays { get; set; }
            public int TotalDays { get; set; }
            public double AttendanceRate { get; set; }
            public int LateCount { get; set; }
        }

        protected class EmployeePerformanceData
        {
            public string EmployeeId { get; set; }
            public string EmployeeName { get; set; }
            public string Department { get; set; }
            public double AttendanceRate { get; set; }
            public double PerformanceScore { get; set; }
        }
    }
}

