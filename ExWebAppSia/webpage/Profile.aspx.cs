using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class HRProfile : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private string _attendanceStatusJson = null;
        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private PayrollItem _latestPayrollItem = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/LoginFolder/Login.aspx");
                return;
            }

            // Optional: If you want to restrict based on role, you can do it here
            // string role = Session["Role"]?.ToString();
            // if (role != "Admin" && role != "HR" && role != "Employee") ...

            RegisterAsyncTask(new PageAsyncTask(LoadAllDataAsync));
        }

        private async Task LoadAllDataAsync()
        {
            await LoadAttendanceStatusAsync();
            await LoadAttendanceStatisticsAsync();
            await LoadLatestPayrollAsync();
        }

        protected Employee CurrentEmployee
        {
            get { return Session["Employee"] as Employee; }
        }

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
        protected string GetEmployeeRole() => CurrentEmployee?.Role ?? "N/A";
        protected string GetEmployeeEmail() => CurrentEmployee?.Email ?? "N/A";
        protected string GetEmployeeContact() => CurrentEmployee?.ContactNo ?? "N/A";
        protected string GetEmployeeDepartment() => CurrentEmployee?.Department ?? "N/A";
        protected string GetEmployeeBirthdate() => CurrentEmployee?.BirthDate?.ToLocalTime().ToString("MMM dd, yyyy") ?? "N/A";
        protected string GetEmployeeAge() => CurrentEmployee?.Age?.ToString() ?? "N/A";
        protected string GetEmployeeSex() => CurrentEmployee?.Gender ?? "N/A";
        protected string GetEmployeeStatus() => CurrentEmployee?.ContractType ?? "Regular";
        protected string GetEmployeeSalary() => CurrentEmployee != null ? $"&#8369;{CurrentEmployee.BaseSalary:N2}" : "&#8369;0.00";

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
                    timeIn = attendance?.TimeIn?.ToLocalTime().ToString("h:mm tt"),
                    timeOut = attendance?.TimeOut?.ToLocalTime().ToString("h:mm tt")
                };
                _attendanceStatusJson = new JavaScriptSerializer().Serialize(status);
            }
            catch
            {
                _attendanceStatusJson = "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";
            }
        }

        protected string GetAttendanceStatusJsonString() => _attendanceStatusJson ?? "{\"hasTimedIn\":false,\"hasTimedOut\":false,\"timeIn\":null,\"timeOut\":null}";

        private async Task LoadAttendanceStatisticsAsync()
        {
            try
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId))
                {
                    _attendanceStats = GetDefaultStats();
                    return;
                }

                _employeeAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId);
                CalculateAttendanceStatistics();
            }
            catch
            {
                _attendanceStats = GetDefaultStats();
            }
        }

        private void CalculateAttendanceStatistics()
        {
            if (_employeeAttendanceRecords == null || _employeeAttendanceRecords.Count == 0)
            {
                _attendanceStats = GetDefaultStats();
                return;
            }

            var now = DateTime.Now;
            var today = now.Date;
            var currentMonth = new DateTime(now.Year, now.Month, 1);

            var currentMonthRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime >= currentMonth && x.LocalTime < currentMonth.AddMonths(1))
                .ToList();

            var currentMonthPresent = currentMonthRecords.Select(x => x.LocalTime.Date).Distinct().Count();
            var pastWeekdays = Enumerable.Range(0, (today - currentMonth).Days + 1)
                .Select(i => currentMonth.AddDays(i))
                .Count(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);
            var currentMonthAbsent = Math.Max(0, pastWeekdays - currentMonthPresent);
            var currentMonthLate = currentMonthRecords.GroupBy(x => x.LocalTime.Date).Count(g => g.OrderBy(x => x.LocalTime).First().LocalTime.Hour >= 9);
            var currentMonthAttendancePercent = pastWeekdays > 0 ? (int)Math.Round((double)currentMonthPresent / pastWeekdays * 100) : 0;

            _attendanceStats = new Dictionary<string, object>
            {
                { "daysPresent", currentMonthPresent },
                { "daysAbsent", currentMonthAbsent },
                { "daysLate", currentMonthLate },
                { "attendanceRate", currentMonthAttendancePercent }
            };
        }

        private Dictionary<string, object> GetDefaultStats() => new Dictionary<string, object> { { "daysPresent", 0 }, { "daysAbsent", 0 }, { "daysLate", 0 }, { "attendanceRate", 0 } };

        public string GetDaysPresent() => _attendanceStats?["daysPresent"].ToString() ?? "0";
        public string GetDaysAbsent() => _attendanceStats?["daysAbsent"].ToString() ?? "0";
        public string GetDaysLate() => _attendanceStats?["daysLate"].ToString() ?? "0";
        public string GetAttendanceRate() => _attendanceStats?["attendanceRate"].ToString() ?? "0";

        private async Task LoadLatestPayrollAsync()
        {
            try
            {
                if (CurrentEmployee == null || string.IsNullOrEmpty(CurrentEmployee.Id)) return;
                var payRunService = new PayRunService();
                var payRun = await payRunService.GetLatestPayRunForEmployeeAsync(CurrentEmployee.Id);
                _latestPayrollItem = payRun?.Items?.FirstOrDefault(i => i.EmployeeId == CurrentEmployee.Id);
            }
            catch { }
        }

        protected string GetBasicSalary() => _latestPayrollItem?.BasicSalary.ToString("N2") ?? "0.00";
        protected string GetAllowances() => _latestPayrollItem?.Allowances.ToString("N2") ?? "0.00";
        protected string GetOvertimePay() => _latestPayrollItem?.OvertimePay.ToString("N2") ?? "0.00";
        protected string GetGrossSalary() => _latestPayrollItem?.GrossSalary.ToString("N2") ?? "0.00";
        protected string GetSSSDeduction() => _latestPayrollItem?.SSSDeduction.ToString("N2") ?? "0.00";
        protected string GetPhilHealthDeduction() => _latestPayrollItem?.PhilHealthDeduction.ToString("N2") ?? "0.00";
        protected string GetPagIbigDeduction() => _latestPayrollItem?.PagIbigDeduction.ToString("N2") ?? "0.00";
        protected string GetWithholdingTax() => _latestPayrollItem?.WithholdingTax.ToString("N2") ?? "0.00";
        protected string GetTotalDeductions() => _latestPayrollItem?.TotalDeductions.ToString("N2") ?? "0.00";
        protected string GetNetSalary() => _latestPayrollItem?.NetSalary.ToString("N2") ?? "0.00";
    }
}
