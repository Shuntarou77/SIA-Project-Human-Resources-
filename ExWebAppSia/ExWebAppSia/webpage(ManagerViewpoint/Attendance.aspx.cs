using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;
using ManagerModel = ExWebAppSia.Models.Manager;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class WebForm3 : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private string _attendanceStatusJson = null;

        private List<Attendance> _weeklyAttendanceRecords = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load attendance status and weekly data asynchronously
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatusAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadWeeklyAttendanceAsync));
            }
        }

        private async Task LoadAttendanceStatusAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.ManagerId))
                {
                    _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
                    return;
                }

                // Use ManagerId as the employeeId in attendance records
                var attendance = await _attendanceService.GetTodayAttendanceAsync(manager.ManagerId);

                var status = new
                {
                    hasTimedIn = attendance != null && attendance.TimeIn.HasValue,
                    hasTimedOut = attendance != null && attendance.TimeOut.HasValue,
                    timeIn = attendance?.TimeIn.HasValue == true 
                        ? attendance.TimeIn.Value.ToLocalTime().ToString("hh:mm:ss tt") 
                        : (string)null,
                    timeOut = attendance?.TimeOut.HasValue == true 
                        ? attendance.TimeOut.Value.ToLocalTime().ToString("hh:mm:ss tt") 
                        : (string)null
                };

                var serializer = new JavaScriptSerializer();
                _attendanceStatusJson = serializer.Serialize(status);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance status: {ex.Message}");
                _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
            }
        }

        protected string AttendanceStatusJson
        {
            get
            {
                if (_attendanceStatusJson != null)
                {
                    return _attendanceStatusJson;
                }
                return "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
            }
        }

        protected ManagerModel CurrentManager
        {
            get
            {
                return Session["Manager"] as ManagerModel;
            }
        }

        protected string GetManagerInitials()
        {
            var manager = CurrentManager;
            if (manager == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(manager.FirstName))
                initials += manager.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(manager.LastName))
                initials += manager.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected string GetManagerName()
        {
            var manager = CurrentManager;
            if (manager == null) return "N/A";
            
            return manager.FullName ?? "N/A";
        }

        protected string GetManagerId()
        {
            var manager = CurrentManager;
            return manager?.ManagerId ?? "N/A";
        }

        protected string GetManagerRole()
        {
            var manager = CurrentManager;
            return manager?.Role ?? "N/A";
        }

        protected string GetManagerDepartment()
        {
            var manager = CurrentManager;
            return manager?.Department ?? "N/A";
        }

        private async Task LoadWeeklyAttendanceAsync()
        {
            try
            {
                var manager = CurrentManager;
                if (manager == null || string.IsNullOrEmpty(manager.ManagerId))
                {
                    _weeklyAttendanceRecords = new List<Attendance>();
                    return;
                }

                // Calculate week start (Monday) and end (Sunday)
                var now = DateTime.Now;
                var daysSinceMonday = ((int)now.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
                var weekStart = now.AddDays(-daysSinceMonday).Date;
                var weekEnd = weekStart.AddDays(7);

                // Get attendance records for the current week
                _weeklyAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(
                    manager.ManagerId, 
                    weekStart, 
                    weekEnd);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading weekly attendance: {ex.Message}");
                _weeklyAttendanceRecords = new List<Attendance>();
            }
        }

        protected string GetWeeklyHoursWorked()
        {
            try
            {
                if (_weeklyAttendanceRecords == null || _weeklyAttendanceRecords.Count == 0)
                    return "0";

                double totalHours = 0;
                foreach (var record in _weeklyAttendanceRecords)
                {
                    if (record.TimeIn.HasValue && record.TimeOut.HasValue)
                    {
                        var timeIn = record.TimeIn.Value.ToLocalTime();
                        var timeOut = record.TimeOut.Value.ToLocalTime();
                        var hours = (timeOut - timeIn).TotalHours;
                        totalHours += hours;
                    }
                }

                return totalHours.ToString("F1");
            }
            catch
            {
                return "0";
            }
        }

        protected string GetWeeklyDaysPresent()
        {
            try
            {
                if (_weeklyAttendanceRecords == null || _weeklyAttendanceRecords.Count == 0)
                    return "0";

                // Count unique days with time in
                var presentDays = _weeklyAttendanceRecords
                    .Where(a => a.TimeIn.HasValue)
                    .Select(a => a.TimeIn.Value.ToLocalTime().Date)
                    .Distinct()
                    .Count();

                return presentDays.ToString();
            }
            catch
            {
                return "0";
            }
        }

        protected string GetWeeklyTimesLate()
        {
            try
            {
                if (_weeklyAttendanceRecords == null || _weeklyAttendanceRecords.Count == 0)
                    return "0";

                // Count days where time in was after 8:00 AM
                var lateCount = _weeklyAttendanceRecords
                    .Where(a => a.TimeIn.HasValue)
                    .GroupBy(a => a.TimeIn.Value.ToLocalTime().Date)
                    .Count(g =>
                    {
                        var firstTimeIn = g.OrderBy(x => x.TimeIn).First().TimeIn.Value.ToLocalTime();
                        // Consider late if after 8:00 AM (8 hours, 0 minutes)
                        return firstTimeIn.Hour > 8 || (firstTimeIn.Hour == 8 && firstTimeIn.Minute > 0);
                    });

                return lateCount.ToString();
            }
            catch
            {
                return "0";
            }
        }

        protected string GetWeeklyBreakHours()
        {
            // Break hours tracking would require additional data
            // For now, return 0 or calculate from time differences if needed
            // This could be enhanced if break tracking is implemented
            return "0";
        }
    }
}