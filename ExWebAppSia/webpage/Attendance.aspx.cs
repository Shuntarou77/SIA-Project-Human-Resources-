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

                // Convert local date to UTC date for querying
                // The attendance records are stored with UTC dates
                var localDate = SelectedDate.Date;
                var utcDate = localDate.ToUniversalTime().Date;
                
                System.Diagnostics.Debug.WriteLine($"=== Loading Attendance Data ===");
                System.Diagnostics.Debug.WriteLine($"Selected local date: {localDate:yyyy-MM-dd}");
                System.Diagnostics.Debug.WriteLine($"UTC date for query: {utcDate:yyyy-MM-dd}");
                System.Diagnostics.Debug.WriteLine($"Current UTC time: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}");
                System.Diagnostics.Debug.WriteLine($"Current local time: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
                
                // Query using UTC date directly
                var records = await _attendanceService.GetAttendanceByDateAsync(utcDate);
                System.Diagnostics.Debug.WriteLine($"Records for UTC date {utcDate:yyyy-MM-dd}: {records.Count}");
                foreach (var r in records)
                {
                    System.Diagnostics.Debug.WriteLine($"  - EmployeeId: {r.EmployeeId}, Date: {r.Date:yyyy-MM-dd}, TimeIn: {r.TimeIn?.ToString("yyyy-MM-dd HH:mm:ss") ?? "null"}");
                }
                
                // Also check the day before and after in UTC to catch timezone edge cases
                var recordsBefore = await _attendanceService.GetAttendanceByDateAsync(utcDate.AddDays(-1));
                var recordsAfter = await _attendanceService.GetAttendanceByDateAsync(utcDate.AddDays(1));
                
                System.Diagnostics.Debug.WriteLine($"Records for UTC date {utcDate.AddDays(-1):yyyy-MM-dd}: {recordsBefore.Count}");
                System.Diagnostics.Debug.WriteLine($"Records for UTC date {utcDate.AddDays(1):yyyy-MM-dd}: {recordsAfter.Count}");
                
                // Filter records to only include those where TimeIn falls on the selected local date
                var allRecords = new List<Attendance>();
                allRecords.AddRange(records);
                allRecords.AddRange(recordsBefore);
                allRecords.AddRange(recordsAfter);
                
                System.Diagnostics.Debug.WriteLine($"Total records before filtering: {allRecords.Count}");
                
                // Filter by local time to ensure we show records for the correct local day
                AttendanceRecords = allRecords.Where(a =>
                {
                    if (a.TimeIn == null) 
                    {
                        System.Diagnostics.Debug.WriteLine($"  Skipping record (no TimeIn): EmployeeId={a.EmployeeId}");
                        return false;
                    }
                    var localTimeIn = a.TimeIn.Value.ToLocalTime();
                    bool matches = localTimeIn.Date == localDate;
                    if (matches)
                    {
                        System.Diagnostics.Debug.WriteLine($"  Match found: EmployeeId={a.EmployeeId}, LocalTimeIn={localTimeIn:yyyy-MM-dd HH:mm:ss}");
                    }
                    return matches;
                }).ToList();
                
                System.Diagnostics.Debug.WriteLine($"Found {AttendanceRecords.Count} attendance records for local date {localDate:yyyy-MM-dd}");

                // NEW: Ensure ALL employees are shown in the list for the current day
                // Only do this if there is AT LEAST one record, otherwise it's just an empty day
                if (AttendanceRecords.Count > 0)
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
                            // Create a dummy "Absent" record for display
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
                        var emp = AllEmployees.FirstOrDefault(e => e.EmployeeId == record.EmployeeId);
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