using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private string _attendanceStatusJson = null;

        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load attendance status and statistics asynchronously
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceDataAsync));
            }
        }

        private async Task LoadAttendanceDataAsync()
        {
            await LoadAttendanceStatusAsync();
            await LoadAttendanceStatisticsAsync();
        }

        private async Task LoadAttendanceStatusAsync()
        {
            try
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId))
                {
                    _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
                    return;
                }

                var attendance = await _attendanceService.GetTodayAttendanceAsync(employee.EmployeeId);

                // Load OT request from separate OvertimeRequests collection
                OvertimeRequest otRequest = null;
                if (attendance != null)
                {
                    otRequest = await _overtimeService.GetByAttendanceIdAsync(attendance.Id);
                }

                var status = new
                {
                    hasTimedIn = attendance != null && attendance.TimeIn.HasValue,
                    hasTimedOut = attendance != null && attendance.TimeOut.HasValue,
                    timeIn = attendance?.TimeIn.HasValue == true
                        ? attendance.TimeIn.Value.ToLocalTime().ToString("h:mm tt")
                        : (string)null,
                    timeOut = attendance?.TimeOut.HasValue == true
                        ? attendance.TimeOut.Value.ToLocalTime().ToString("h:mm tt")
                        : (string)null,
                    overtimeStatus = otRequest?.Status ?? "None",
                    overtimeReason = otRequest?.Reason ?? "",
                    overtime = otRequest?.OvertimeWorked ?? ""
                };

                var serializer = new JavaScriptSerializer();
                _attendanceStatusJson = serializer.Serialize(status);
                
                System.Diagnostics.Debug.WriteLine($"Dashboard - Attendance status loaded: hasTimedIn={status.hasTimedIn}, hasTimedOut={status.hasTimedOut}");
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
                // Return cached value if available, otherwise return default
                // The async task will populate this during page load
                if (_attendanceStatusJson != null)
                {
                    return _attendanceStatusJson;
                }
                
                // Return default status if not yet loaded (shouldn't happen, but safe fallback)
                return "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
            }
        }

        protected string GetAttendanceStatusJsonString()
        {
            return AttendanceStatusJson;
        }

        protected Employee CurrentEmployee
        {
            get
            {
                return Session["Employee"] as Employee;
            }
        }

        protected string GetEmployeeInitials()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(employee.FirstName))
                initials += employee.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(employee.LastName))
                initials += employee.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected string GetEmployeeName()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "N/A";
            
            return employee.FullName ?? "N/A";
        }

        protected string GetEmployeeId()
        {
            var employee = CurrentEmployee;
            return employee?.EmployeeId ?? "N/A";
        }

        protected string GetEmployeeRole()
        {
            var employee = CurrentEmployee;
            return employee?.Role ?? "N/A";
        }

        protected string GetEmployeeAddress()
        {
            var employee = CurrentEmployee;
            return employee?.Address ?? "N/A";
        }

        protected string GetEmployeeEmail()
        {
            var employee = CurrentEmployee;
            return employee?.Email ?? "N/A";
        }

        protected string GetEmployeeContact()
        {
            var employee = CurrentEmployee;
            return employee?.ContactNo ?? "N/A";
        }

        protected string GetEmployeeDepartment()
        {
            var employee = CurrentEmployee;
            return employee?.Department ?? "N/A";
        }

        private async Task LoadAttendanceStatisticsAsync()
        {
            try
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId))
                {
                    _employeeAttendanceRecords = new List<Attendance>();
                    _attendanceStats = GetDefaultStats();
                    return;
                }

                // Get all attendance records for this employee
                _employeeAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId);
                
                // Fetch approved leaves
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId);
                var approvedLeaves = leaves?.Where(l => l.Status == "Approved").ToList() ?? new List<Leave>();

                // UNIFIED LOGIC: Use centralized AttendanceService for consistent stats
                var stats = await _attendanceService.GetMonthlyAttendanceStatsAsync(employee.EmployeeId, employee.HiredDate);
                var yearlyStats = await _attendanceService.GetYearlyAttendanceStatsAsync(employee.EmployeeId, employee.HiredDate);

                // Calculate trends and other dashboard-specific metrics
                CalculateAttendanceStatistics(approvedLeaves, stats, yearlyStats);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance statistics: {ex.Message}");
                _employeeAttendanceRecords = new List<Attendance>();
                _attendanceStats = GetDefaultStats();
            }
        }

        private void CalculateAttendanceStatistics(List<Leave> approvedLeaves, AttendanceStats monthlyStats, AttendanceStats yearlyStats)
        {
            if (_employeeAttendanceRecords == null)
            {
                _attendanceStats = GetDefaultStats();
                return;
            }

            var now = DateTime.Now;
            var today = now.Date;
            var currentMonth = new DateTime(now.Year, now.Month, 1);
            var lastMonth = currentMonth.AddMonths(-1);

            // Use unified stats for current display
            var currentMonthPresent = monthlyStats.PresentCount;
            var currentMonthAbsent = monthlyStats.AbsentCount;
            var currentMonthLate = monthlyStats.LateCount;
            var currentMonthAttendancePercent = (int)Math.Round(monthlyStats.AttendanceRate);
            var remainingAbsences = yearlyStats.RemainingAbsences;

            // Calculate historical stats for trends (using last month's range)
            var lastMonthRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime >= lastMonth && x.LocalTime < currentMonth)
                .ToList();

            // Count weekdays in last month
            var lastMonthEnd = currentMonth.AddDays(-1);
            var lastMonthWeekdays = Enumerable.Range(0, (lastMonthEnd - lastMonth).Days + 1)
                .Select(i => lastMonth.AddDays(i))
                .Count(d => d.DayOfWeek != DayOfWeek.Sunday); // Consistent with GetWorkingDaysCount
            
            var lastMonthPresent = lastMonthRecords.Select(x => x.LocalTime.Date).Distinct().Count();
            var lastMonthAbsent = Math.Max(0, lastMonthWeekdays - lastMonthPresent);
            var lastMonthLate = lastMonthRecords
                .GroupBy(x => x.LocalTime.Date)
                .Count(g => {
                    var firstIn = g.OrderBy(x => x.LocalTime).First().LocalTime;
                    return firstIn.Hour >= 9 || (firstIn.Hour == 8 && firstIn.Minute > 15);
                });
            var lastMonthAttendancePercent = lastMonthWeekdays > 0 
                ? (int)Math.Round((double)lastMonthPresent / lastMonthWeekdays * 100) 
                : 0;

            // Calculate trends
            var attendanceTrend = currentMonthAttendancePercent - lastMonthAttendancePercent;
            var presentTrend = currentMonthPresent - lastMonthPresent;
            var absentTrend = currentMonthAbsent - lastMonthAbsent;
            var lateTrend = currentMonthLate - lastMonthLate;

            // This week stats - use Monday as week start
            var daysSinceMonday = ((int)now.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
            var weekStart = now.AddDays(-daysSinceMonday).Date;
            var weekEnd = weekStart.AddDays(7);
            var weekRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime.Date >= weekStart && x.LocalTime.Date < weekEnd)
                .ToList();
            
            // Count unique days in the week
            var weekPresentDays = weekRecords
                .Select(x => x.LocalTime.Date)
                .Distinct()
                .Count();
            
            // Count on-time days (consistent 8:15 AM cutoff)
            var weekOnTimeDays = weekRecords
                .GroupBy(x => x.LocalTime.Date)
                .Count(g => {
                    var firstIn = g.OrderBy(x => x.LocalTime).First().LocalTime;
                    return !(firstIn.Hour >= 9 || (firstIn.Hour == 8 && firstIn.Minute > 15));
                });
            
            var weekOnTimePercent = weekPresentDays > 0 ? (int)Math.Round((double)weekOnTimeDays / weekPresentDays * 100) : 0;

            // Calculate streak (consecutive days with attendance)
            var streak = CalculateStreak();

            _attendanceStats = new Dictionary<string, object>
            {
                { "overallAttendance", currentMonthAttendancePercent },
                { "attendanceTrend", attendanceTrend },
                { "daysPresent", currentMonthPresent },
                { "presentTrend", presentTrend },
                { "daysAbsent", currentMonthAbsent },
                { "absentTrend", absentTrend },
                { "daysLate", currentMonthLate },
                { "lateTrend", lateTrend },
                { "weekPresent", $"{weekPresentDays}/5" },
                { "weekOnTime", weekOnTimePercent },
                { "streak", streak },
                { "remainingAbsences", remainingAbsences }
            };
        }

        public string GetRemainingAbsences() => _attendanceStats != null && _attendanceStats.ContainsKey("remainingAbsences") ? _attendanceStats["remainingAbsences"].ToString() : "0";

        private int CalculateStreak()
        {
            if (_employeeAttendanceRecords == null || _employeeAttendanceRecords.Count == 0)
                return 0;

            // Get unique dates with attendance, sorted descending
            var attendanceDates = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.TimeIn.Value.ToLocalTime().Date)
                .Distinct()
                .OrderByDescending(d => d)
                .ToList();

            if (attendanceDates.Count == 0)
                return 0;

            var streak = 0;
            var currentDate = DateTime.Now.Date;
            
            foreach (var attendanceDate in attendanceDates)
            {
                if (attendanceDate == currentDate)
                {
                    streak++;
                    currentDate = currentDate.AddDays(-1);
                }
                else if (attendanceDate < currentDate)
                {
                    // Check if it's the next consecutive day
                    if (attendanceDate == currentDate.AddDays(-1))
                    {
                        streak++;
                        currentDate = attendanceDate;
                    }
                    else
                    {
                        // Streak broken
                        break;
                    }
                }
            }

            return streak;
        }

        private Dictionary<string, object> GetDefaultStats()
        {
            return new Dictionary<string, object>
            {
                { "overallAttendance", 0 },
                { "attendanceTrend", 0 },
                { "daysPresent", 0 },
                { "presentTrend", 0 },
                { "daysAbsent", 0 },
                { "absentTrend", 0 },
                { "daysLate", 0 },
                { "lateTrend", 0 },
                { "remainingAbsences", 0 },
                { "weekPresent", "0/5" },
                { "weekOnTime", 0 },
                { "streak", 0 }
            };
        }

        // Public methods for ASPX page
        protected string GetOverallAttendance()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["overallAttendance"].ToString();
        }

        protected string GetDaysPresent()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["daysPresent"].ToString();
        }

        protected string GetDaysAbsent()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["daysAbsent"].ToString();
        }

        protected string GetDaysLate()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["daysLate"].ToString();
        }

        protected string GetOverallAttendanceChange()
        {
            if (_attendanceStats == null) return "No data";
            var trend = (int)_attendanceStats["attendanceTrend"];
            if (trend > 0)
                return $"↑ {trend}% from last month";
            else if (trend < 0)
                return $"↓ {Math.Abs(trend)}% from last month";
            else
                return "No change from last month";
        }

        protected bool IsOverallAttendanceUp()
        {
            if (_attendanceStats == null) return false;
            return (int)_attendanceStats["attendanceTrend"] > 0;
        }

        protected string GetDaysPresentChange()
        {
            if (_attendanceStats == null) return "No data";
            var trend = (int)_attendanceStats["presentTrend"];
            if (trend > 0)
                return $"↑ {trend} from last month";
            else if (trend < 0)
                return $"↓ {Math.Abs(trend)} from last month";
            else
                return "No change from last month";
        }

        protected bool IsDaysPresentUp()
        {
            if (_attendanceStats == null) return false;
            return (int)_attendanceStats["presentTrend"] > 0;
        }

        protected string GetDaysAbsentChange()
        {
            if (_attendanceStats == null) return "No data";
            var trend = (int)_attendanceStats["absentTrend"];
            if (trend > 0)
                return $"↑ {trend} from last month";
            else if (trend < 0)
                return $"↓ {Math.Abs(trend)} from last month";
            else
                return "No change from last month";
        }

        protected bool IsDaysAbsentDown()
        {
            if (_attendanceStats == null) return false;
            return (int)_attendanceStats["absentTrend"] < 0;
        }

        protected string GetDaysLateChange()
        {
            if (_attendanceStats == null) return "No data";
            var trend = (int)_attendanceStats["lateTrend"];
            if (trend > 0)
                return $"↑ {trend} from last month";
            else if (trend < 0)
                return $"↓ {Math.Abs(trend)} from last month";
            else
                return "No change from last month";
        }

        protected bool IsDaysLateDown()
        {
            if (_attendanceStats == null) return false;
            return (int)_attendanceStats["lateTrend"] < 0;
        }

        protected string GetWeekPresentDays()
        {
            if (_attendanceStats == null) return "0/5";
            return _attendanceStats["weekPresent"].ToString();
        }

        protected string GetWeekOnTimePercent()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["weekOnTime"].ToString();
        }

        protected string GetStreak()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["streak"].ToString();
        }

        protected string GetOverallAttendanceTrendClass()
        {
            return IsOverallAttendanceUp() ? "trend-up" : "trend-down";
        }

        protected string GetDaysPresentTrendClass()
        {
            return IsDaysPresentUp() ? "trend-up" : "trend-down";
        }

        protected string GetDaysAbsentTrendClass()
        {
            return IsDaysAbsentDown() ? "trend-down" : "trend-up";
        }

        protected string GetDaysLateTrendClass()
        {
            return IsDaysLateDown() ? "trend-down" : "trend-up";
        }
    }
}