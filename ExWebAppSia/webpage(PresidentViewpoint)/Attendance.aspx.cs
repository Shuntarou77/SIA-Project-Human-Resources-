using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class PresidentAttendance : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private string _attendanceStatusJson = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatusAsync));
            }
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

        protected Employee CurrentEmployee => Session["Employee"] as Employee;

        protected string GetEmployeeInitials()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(employee.FirstName)) initials += employee.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(employee.LastName)) initials += employee.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected string GetEmployeeName() => CurrentEmployee?.FullName ?? "N/A";
        protected string GetEmployeeId() => CurrentEmployee?.EmployeeId ?? "N/A";
        protected string GetEmployeeDepartment() => CurrentEmployee?.Department ?? "N/A";

        protected string GetAttendanceStatusJson()
        {
            return _attendanceStatusJson ?? "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
        }
    }
}
