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
        protected List<Attendance> AttendanceRecords { get; set; }
        protected DateTime SelectedDate { get; set; }

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
                // Use the new method that handles timezone conversion properly
                System.Diagnostics.Debug.WriteLine($"Loading attendance for local date: {SelectedDate:yyyy-MM-dd}");
                
                // Also check yesterday and tomorrow in case of timezone issues
                var yesterday = SelectedDate.AddDays(-1);
                var tomorrow = SelectedDate.AddDays(1);
                
                var todayRecords = await _attendanceService.GetAttendanceByLocalDateAsync(SelectedDate);
                var yesterdayRecords = await _attendanceService.GetAttendanceByLocalDateAsync(yesterday);
                var tomorrowRecords = await _attendanceService.GetAttendanceByLocalDateAsync(tomorrow);
                
                System.Diagnostics.Debug.WriteLine($"Found {todayRecords?.Count ?? 0} records for today");
                System.Diagnostics.Debug.WriteLine($"Found {yesterdayRecords?.Count ?? 0} records for yesterday");
                System.Diagnostics.Debug.WriteLine($"Found {tomorrowRecords?.Count ?? 0} records for tomorrow");
                
                AttendanceRecords = todayRecords;
                
                // Calculate statistics
                var presentCount = AttendanceRecords?.Count(a => a.TimeIn != null) ?? 0;
                var absentCount = 0; // This would need total employees count - attendance records
                // Count as late if time in is after 9:00 AM local time (convert UTC time to local for comparison)
                var lateCount = AttendanceRecords?.Count(a => 
                    {
                        if (a.TimeIn == null) return false;
                        var localTime = a.TimeIn.Value.ToLocalTime();
                        return localTime.Hour > 9 || (localTime.Hour == 9 && localTime.Minute > 0);
                    }) ?? 0;

                ViewState["PresentCount"] = presentCount;
                ViewState["AbsentCount"] = absentCount;
                ViewState["LateCount"] = lateCount;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance data: {ex.Message}\n{ex.StackTrace}");
                AttendanceRecords = new List<Attendance>();
            }
        }

        protected string FormatTime(DateTime? time)
        {
            if (time == null) return "-";
            // Convert UTC time to local time for display
            return time.Value.ToLocalTime().ToString("h:mm tt");
        }

        protected string GetDateDisplay()
        {
            return SelectedDate.ToString("MMMM dd, yyyy");
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
    }
}