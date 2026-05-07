using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class WebForm3 : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly UndertimeService _undertimeService = new UndertimeService();
        protected List<Attendance> AttendanceRecords { get; set; }
        protected List<OvertimeRequest> PendingOvertimeRequests { get; set; } = new List<OvertimeRequest>();
        protected List<UndertimeRequest> PendingUndertimeRequests { get; set; } = new List<UndertimeRequest>();
        protected List<UndertimeRecord> UndertimeRecords { get; set; } = new List<UndertimeRecord>();
        protected List<Employee> AllEmployees { get; set; } = new List<Employee>();
        protected Dictionary<string, int> AbsenceAllowanceCache { get; set; } = new Dictionary<string, int>();
        protected DateTime SelectedDate { get; set; }

        private static string NormalizeEmployeeId(string id)
        {
            return (id ?? "").Trim().ToUpperInvariant();
        }

        private Employee FindEmployeeByPossiblyMismatchedId(string employeeId)
        {
            var key = NormalizeEmployeeId(employeeId);
            if (string.IsNullOrEmpty(key) || AllEmployees == null || AllEmployees.Count == 0) return null;

            var exact = AllEmployees.FirstOrDefault(e => NormalizeEmployeeId(e.EmployeeId) == key);
            if (exact != null) return exact;

            // Handle occasional prefix/suffix mismatches (e.g., data coming from different sources)
            return AllEmployees.FirstOrDefault(e =>
            {
                var eid = NormalizeEmployeeId(e.EmployeeId);
                return (!string.IsNullOrEmpty(eid) && (key.StartsWith(eid) || eid.StartsWith(key)));
            });
        }

        protected string CurrentAdminId 
        { 
            get 
            {
                var emp = Session["Employee"] as Employee;
                return emp?.EmployeeId;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle date change from JavaScript (check both Form and QueryString)
            string dateChange = Request.Form["dateChange"] ?? Request.QueryString["dateChange"];
            string dateSelect = Request.Form["dateSelect"] ?? Request.QueryString["dateSelect"];
            
            System.Diagnostics.Debug.WriteLine($"Page_Load - dateChange: {dateChange}, dateSelect: {dateSelect}, IsPostBack: {IsPostBack}");
            
            if (!string.IsNullOrEmpty(dateSelect))
            {
                // Direct date selection from calendar
                if (DateTime.TryParse(dateSelect, out DateTime selectedDate))
                {
                    SelectedDate = selectedDate.Date;
                    ViewState["SelectedDate"] = SelectedDate;
                    System.Diagnostics.Debug.WriteLine($"Date selected from calendar: {SelectedDate:yyyy-MM-dd}");
                }
            }
            else if (!string.IsNullOrEmpty(dateChange))
            {
                // Relative date change (previous/next day)
                if (int.TryParse(dateChange, out int days))
                {
                    DateTime currentDate = ViewState["SelectedDate"] != null 
                        ? (DateTime)ViewState["SelectedDate"] 
                        : DateTime.Now.Date;
                    SelectedDate = currentDate.AddDays(days);
                    ViewState["SelectedDate"] = SelectedDate;
                    System.Diagnostics.Debug.WriteLine($"Date changed by {days} days. Old: {currentDate:yyyy-MM-dd}, New: {SelectedDate:yyyy-MM-dd}");
                }
            }
            else if (!IsPostBack)
            {
                // Default to today's date
                SelectedDate = DateTime.Now.Date;
                ViewState["SelectedDate"] = SelectedDate;
                System.Diagnostics.Debug.WriteLine($"Initial load, setting date to: {SelectedDate:yyyy-MM-dd}");
            }
            else
            {
                SelectedDate = ViewState["SelectedDate"] != null 
                    ? (DateTime)ViewState["SelectedDate"] 
                    : DateTime.Now.Date;
                System.Diagnostics.Debug.WriteLine($"PostBack, using ViewState date: {SelectedDate:yyyy-MM-dd}");
            }

            RegisterAsyncTask(new PageAsyncTask(LoadAttendanceData));
        }

        private async Task LoadAttendanceData()
        {
            try
            {
                // Load all active employees once for lookups
                AllEmployees = await _employeeService.GetAllEmployeesAsync();

                // Load pending overtime requests from OvertimeRequests collection
                PendingOvertimeRequests = await _overtimeService.GetPendingRequestsAsync();

                // Load pending undertime requests
                PendingUndertimeRequests = await _undertimeService.GetAllPendingRequestsAsync();

                // Load undertime records for selected date
                UndertimeRecords = await _undertimeService.GetUndertimeRecordsByDateAsync(SelectedDate);

                // FETCH ALL EMPLOYEES FIRST
                AllEmployees = await _employeeService.GetAllEmployeesAsync();

                // The attendance records are stored with PH local dates at midnight UTC
                var localDate = SelectedDate.Date;
                var queryDate = localDate; // Use local date directly
                
                System.Diagnostics.Debug.WriteLine($"=== Loading Attendance Data ===");
                System.Diagnostics.Debug.WriteLine($"Selected local date: {localDate:yyyy-MM-dd}");
                System.Diagnostics.Debug.WriteLine($"Query date: {queryDate:yyyy-MM-dd}");
                
                // Query using date directly
                var records = await _attendanceService.GetAttendanceByDateAsync(queryDate);
                System.Diagnostics.Debug.WriteLine($"Records for query date {queryDate:yyyy-MM-dd}: {records.Count}");
                AttendanceRecords = new List<Attendance>();
                
                System.Diagnostics.Debug.WriteLine($"Found {records.Count} raw records for date {localDate:yyyy-MM-dd}");

                // Apply filtering to ensure we only show records specifically for this local day
                foreach (var r in records)
                {
                    if (r.TimeIn.HasValue && r.TimeIn.Value.ToLocalTime().Date == localDate)
                    {
                        AttendanceRecords.Add(r);
                    }
                    else if (!r.TimeIn.HasValue && r.Date == localDate)
                    {
                        AttendanceRecords.Add(r);
                    }
                }
                
                System.Diagnostics.Debug.WriteLine($"Found {AttendanceRecords.Count} filtered records for local date {localDate:yyyy-MM-dd}");
                
                System.Diagnostics.Debug.WriteLine($"Found {AttendanceRecords.Count} attendance records for local date {localDate:yyyy-MM-dd}");

                // Always show ALL employees for any past/current workday,
                // inserting an Absent placeholder for those with no time-in record.
                bool isWorkday = localDate.DayOfWeek != DayOfWeek.Sunday;
                bool isPastOrToday = localDate.Date <= DateTime.Now.Date;

                if (isWorkday && isPastOrToday)
                {
                    var finalDisplayList = new List<Attendance>();
                    foreach (var emp in AllEmployees)
                    {
                        var record = AttendanceRecords.FirstOrDefault(r => r.EmployeeId == emp.EmployeeId);
                        if (record != null)
                        {
                            finalDisplayList.Add(record);
                        }
                        else
                        {
                            // Insert an in-memory "Absent" placeholder for display
                            finalDisplayList.Add(new Attendance
                            {
                                EmployeeId = emp.EmployeeId,
                                EmployeeName = emp.FullName,
                                Department = emp.Department,
                                Date = localDate,
                                TimeIn = null,
                                TimeOut = null
                            });
                        }
                    }
                    AttendanceRecords = finalDisplayList.OrderBy(a => a.EmployeeName).ToList();
                }
                
                // Calculate statistics
                var presentCount = AttendanceRecords.Count(a => a.TimeIn != null);
                
                // Real calculation: All Active Employees - Those who showed up
                var absentCount = Math.Max(0, AllEmployees.Count - presentCount);

                // Count as late if time in is after 8:15 AM local time (since shift starts at 8:00 AM)
                var lateCount = AttendanceRecords.Count(a => 
                    {
                        if (a.TimeIn == null) return false;
                        var localTime = a.TimeIn.Value.ToLocalTime();
                        return localTime.Hour > 8 || (localTime.Hour == 8 && localTime.Minute > 15);
                    });

                var undertimeCount = UndertimeRecords.Count;

                ViewState["PresentCount"] = presentCount;
                ViewState["AbsentCount"] = absentCount;
                ViewState["LateCount"] = lateCount;
                ViewState["UndertimeCount"] = undertimeCount;
                ViewState["OvertimeCount"] = PendingOvertimeRequests.Count;

                // Pre-calculate Absence Allowance for all employees in the records
                AbsenceAllowanceCache.Clear();
                foreach (var record in AttendanceRecords)
                {
                    if (!AbsenceAllowanceCache.ContainsKey(record.EmployeeId))
                    {
                        var emp = FindEmployeeByPossiblyMismatchedId(record.EmployeeId);
                        if (emp != null)
                        {
                            int remaining = await _attendanceService.GetRemainingAbsencesAsync(record.EmployeeId, emp.HiredDate);
                            AbsenceAllowanceCache[record.EmployeeId] = remaining;
                        }
                    }
                }

                // Bind the Repeater
                if (rptAttendance != null)
                {
                    rptAttendance.DataSource = AttendanceRecords;
                    rptAttendance.DataBind();
                    System.Diagnostics.Debug.WriteLine($"Repeater bound with {AttendanceRecords.Count} items");
                }

                // Show/hide no records message
                if (noRecordsRow != null)
                {
                    noRecordsRow.Style["display"] = AttendanceRecords.Count == 0 ? "table-row" : "none";
                    System.Diagnostics.Debug.WriteLine($"No records row display: {noRecordsRow.Style["display"]}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance data: {ex.Message}\n{ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}\n{ex.InnerException.StackTrace}");
                }
                AttendanceRecords = new List<Attendance>();
                
                if (rptAttendance != null)
                {
                    rptAttendance.DataSource = AttendanceRecords;
                    rptAttendance.DataBind();
                }
                
                if (noRecordsRow != null)
                {
                    noRecordsRow.Style["display"] = "table-row";
                }
            }
        }

        protected string FormatTime(DateTime? time)
        {
            if (time == null) return "<span style=\"color: #ef4444; font-weight: 700;\">ABSENT</span>";
            // Convert UTC time to local time for display
            return time.Value.ToLocalTime().ToString("h:mm tt");
        }

        protected string FormatTimeIn(DateTime? time)
        {
            if (time == null) return "<span style=\"color: #ef4444; font-weight: 700;\">ABSENT</span>";
            string timeStr = time.Value.ToLocalTime().ToString("h:mm:ss tt");
            return $"<span class=\"time-in-box\">{Server.HtmlEncode(timeStr)}</span>";
        }

        protected string FormatTimeOut(DateTime? time)
        {
            if (time == null) return "<span style=\"color: #ef4444; font-weight: 700;\">ABSENT</span>";
            string timeStr = time.Value.ToLocalTime().ToString("h:mm:ss tt");
            return $"<span class=\"time-out-box\">{Server.HtmlEncode(timeStr)}</span>";
        }

        protected string GetDateDisplay()
        {
            return SelectedDate.ToString("MMMM dd, yyyy");
        }

        protected string FormatLateTime(DateTime? timeIn, string storedLateTime)
        {
            if (timeIn == null) return "<span class=\"time-empty\">-</span>";
            
            // Recalculate late time on the fly to include seconds accurately
            var localTime = timeIn.Value.ToLocalTime();
            var shiftStart = new DateTime(localTime.Year, localTime.Month, localTime.Day, 8, 0, 0);
            
            if (localTime <= shiftStart) return "<span class=\"time-empty\">-</span>";
            
            var diff = localTime - shiftStart;
            return $"{(int)diff.TotalHours:D2}:{(int)diff.Minutes:D2}:{(int)diff.Seconds:D2}";
        }

        protected int GetPresentCount()
        {
            return ViewState["PresentCount"] != null ? (int)ViewState["PresentCount"] : 0;
        }

        protected int GetAbsentCount()
        {
            return ViewState["AbsentCount"] != null ? (int)ViewState["AbsentCount"] : 0;
        }

        protected int GetLateCount()
        {
            return ViewState["LateCount"] != null ? (int)ViewState["LateCount"] : 0;
        }

        protected int GetUndertimeCount()
        {
            return ViewState["UndertimeCount"] != null ? (int)ViewState["UndertimeCount"] : 0;
        }

        protected int GetOvertimeCount()
        {
            return ViewState["OvertimeCount"] != null ? (int)ViewState["OvertimeCount"] : 0;
        }

        protected string GetUndertimeDisplay(string attendanceId)
        {
            var ut = UndertimeRecords.FirstOrDefault(u => u.AttendanceId == attendanceId);
            if (ut == null) return "<span class=\"time-empty\">-</span>";
            
            return $"<span style=\"color: #ef4444; font-weight: 700;\">-{ut.HoursUndertime:N1}h (₱{ut.DeductionAmount:N2})</span>";
        }

        protected string GetAbsenceAllowance(string employeeId)
        {
            if (AbsenceAllowanceCache.TryGetValue(employeeId, out int allowance))
            {
                string color = allowance <= 3 ? "#ef4444" : (allowance <= 7 ? "#f59e0b" : "#10b981");
                return $"<span style=\"color: {color}; font-weight: 700;\">{allowance} Days</span>";
            }
            return "<span class=\"time-empty\">-</span>";
        }

        protected string GetOTStatusBadgeStyle(object statusObj)
        {
            string status = statusObj as string;
            if (string.IsNullOrEmpty(status) || status == "None") 
                return "display: none;";
            
            string color = "#9ca3af";
            if (status == "Approved") color = "#10b981";
            else if (status == "Pending") color = "#f59e0b";
            else if (status == "Rejected") color = "#ef4444";
            
            return $"background: {color}; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 700;";
        }

        protected string GetEstimatedOTRate(OvertimeRequest req)
        {
            var emp = AllEmployees?.FirstOrDefault(e => e.EmployeeId == req.EmployeeId);
            if (emp == null || emp.BaseSalary <= 0) return "0.00";

            // Monthly Salary (BaseSalary) -> Daily Rate
            // Assuming 313 working days per year for 6 days/week or similar standard
            decimal dailyRate = (emp.BaseSalary * 12) / 313m; 
            
            // Re-calculate based on user formula: Daily Rate / 8 = Hourly Rate
            decimal multiplier = _overtimeService.GetMultiplier(req.OvertimeType ?? "Regular");
            
            decimal estimatedHourlyRate = (dailyRate / 8m) * multiplier;
            
            // Note: NSD (Night Shift Differential) is 10%
            if (req.IsNightShift)
            {
                estimatedHourlyRate *= 1.10m;
            }

            return estimatedHourlyRate.ToString("N2");
        }
    }
}