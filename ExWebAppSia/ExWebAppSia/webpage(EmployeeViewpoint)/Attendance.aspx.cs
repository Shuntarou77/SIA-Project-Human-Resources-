using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm3 : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private string _attendanceStatusJson = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load attendance status asynchronously
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

        protected string GetAttendanceStatusJson()
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
}