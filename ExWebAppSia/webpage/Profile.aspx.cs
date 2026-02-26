using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Text;
using System.Net.Mail;
using System.Net;
using System.Configuration;
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

        private const int TOTAL_WORKING_DAYS_PER_YEAR = 260;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/LoginFolder/Login.aspx");
                return;
            }

            // Always load data
            RegisterAsyncTask(new PageAsyncTask(LoadAllDataAsync));

            // After postback, if there's a message, keep the modal open
            if (IsPostBack)
            {
                if (lblConcernMessage != null && !string.IsNullOrEmpty(lblConcernMessage.Text))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepConcernModalOpen", 
                        "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
                if (lblLeaveMessage != null && !string.IsNullOrEmpty(lblLeaveMessage.Text))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepLeaveModalOpen", 
                        "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);
                }
            }
        }

        private async Task LoadAllDataAsync()
        {
            await LoadAttendanceStatusAsync();
            await LoadAttendanceStatisticsAsync();
            await LoadLatestPayrollAsync();
            await SyncMissingDataAsync();
        }

        private async Task SyncMissingDataAsync()
        {
            var employee = CurrentEmployee;
            if (employee == null) return;

            // If data is missing in session, try to sync from DB and update session
            if (!employee.BirthDate.HasValue || !employee.Age.HasValue || string.IsNullOrEmpty(employee.Gender))
            {
                var employeeService = new EmployeeService();
                await employeeService.SyncMissingEmployeeDataAsync();
                
                // Refresh employee from DB to get the synced data
                var updatedEmployee = await employeeService.GetEmployeeByEmailAsync(employee.Email);
                if (updatedEmployee != null)
                {
                    Session["Employee"] = updatedEmployee;
                }
            }
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
        protected string GetEmployeeStatus() => CurrentEmployee?.EmploymentStatus ?? "Regular";
        protected string GetEmployeeSalary() => CurrentEmployee != null ? $"₱{CurrentEmployee.BaseSalary:N2}" : "₱0.00";

        protected string GetHiredDate()
        {
            var employee = CurrentEmployee;
            if (employee == null || employee.HiredDate == DateTime.MinValue) return "N/A";
            return employee.HiredDate.ToLocalTime().ToString("MMM dd, yyyy");
        }

        protected string GetRegularizationDate()
        {
            var employee = CurrentEmployee;
            if (employee == null || employee.HiredDate == DateTime.MinValue) return "N/A";
            return employee.HiredDate.ToLocalTime().AddMonths(6).ToString("MMM dd, yyyy");
        }

        private string FormatGovNumber(string number, string type)
        {
            if (string.IsNullOrEmpty(number)) return "Not Set";
            string clean = new string(number.Where(char.IsDigit).ToArray());
            try
            {
                if (type == "SSS" && clean.Length == 10)
                    return $"{clean.Substring(0, 2)}-{clean.Substring(2, 7)}-{clean.Substring(9, 1)}";
                if (type == "PhilHealth" && clean.Length == 12)
                    return $"{clean.Substring(0, 2)}-{clean.Substring(2, 9)}-{clean.Substring(11, 1)}";
                if (type == "Pag-IBIG" && clean.Length == 12)
                    return $"{clean.Substring(0, 4)}-{clean.Substring(4, 4)}-{clean.Substring(8, 4)}";
            }
            catch { }
            return number;
        }

        protected string GetSSSNumber() => FormatGovNumber(CurrentEmployee?.SSSNumber, "SSS");
        protected string GetPhilHealthNumber() => FormatGovNumber(CurrentEmployee?.PhilHealthNumber, "PhilHealth");
        protected string GetPagIbigNumber() => FormatGovNumber(CurrentEmployee?.PagIbigNumber, "Pag-IBIG");

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

            // Yearly stats
            var currentYear = now.Year;
            var yearlyRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => a.TimeIn.Value.ToLocalTime())
                .Where(t => t.Year == currentYear)
                .ToList();

            var yearStart = new DateTime(currentYear, 1, 1);
            var yearlyPresent = yearlyRecords.Select(t => t.Date).Distinct().Count();
            
            var pastYearWeekdays = Enumerable.Range(0, (today - yearStart).Days + 1)
                .Select(i => yearStart.AddDays(i))
                .Count(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);
            
            var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent);
            var remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);

            _attendanceStats = new Dictionary<string, object>
            {
                { "daysPresent", currentMonthPresent },
                { "daysAbsent", currentMonthAbsent },
                { "daysLate", currentMonthLate },
                { "attendanceRate", currentMonthAttendancePercent },
                { "remainingAbsences", remainingAbsences },
                { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR }
            };
        }

        private Dictionary<string, object> GetDefaultStats() => new Dictionary<string, object> 
        { 
            { "daysPresent", 0 }, 
            { "daysAbsent", 0 }, 
            { "daysLate", 0 }, 
            { "attendanceRate", 0 },
            { "remainingAbsences", TOTAL_ALLOWED_ABSENCES_PER_YEAR },
            { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR }
        };

        public string GetDaysPresent() => _attendanceStats?["daysPresent"].ToString() ?? "0";
        public string GetDaysAbsent() => _attendanceStats?["daysAbsent"].ToString() ?? "0";
        public string GetDaysLate() => _attendanceStats?["daysLate"].ToString() ?? "0";
        public string GetAttendanceRate() => _attendanceStats?["attendanceRate"].ToString() ?? "0";
        public string GetRemainingAbsences() => _attendanceStats?["remainingAbsences"].ToString() ?? "0";
        public string GetTargetWorkingDays() => _attendanceStats?["targetWorkingDays"].ToString() ?? "0";

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

        protected void btnSubmitConcern_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(ddlConcernType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtConcernSubject.Text) || 
                    string.IsNullOrWhiteSpace(txtConcernDescription.Text))
                {
                    lblConcernMessage.Text = "Please fill in all required fields.";
                    lblConcernMessage.Style["display"] = "block";
                    return;
                }

                var employee = CurrentEmployee;
                if (employee == null) return;

                var concern = new EmployeeConcern
                {
                    EmployeeId = employee.EmployeeId,
                    EmployeeName = employee.FullName,
                    ConcernType = ddlConcernType.SelectedItem.Text,
                    Subject = txtConcernSubject.Text.Trim(),
                    Description = txtConcernDescription.Text.Trim(),
                    PriorityLevel = "Normal",
                    Status = "New",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                var concernService = new EmployeeConcernService();
                RegisterAsyncTask(new PageAsyncTask(async () => {
                    await concernService.CreateConcernAsync(concern);
                    SendConcernEmail(concern, employee);
                }));

                // Clear form
                ddlConcernType.SelectedIndex = 0;
                txtConcernSubject.Text = "";
                txtConcernDescription.Text = "";

                lblConcernMessage.Text = "✓ Your concern has been submitted successfully!";
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["color"] = "#155724";
                lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                lblConcernMessage.Style["padding"] = "10px";
                lblConcernMessage.Style["borderRadius"] = "5px";
                
                ClientScript.RegisterStartupScript(this.GetType(), "closeConcernModal", 
                    "setTimeout(function() { closeModal('concernModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblConcernMessage.Text = "Error: " + ex.Message;
                lblConcernMessage.Style["display"] = "block";
            }
        }

        protected void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(ddlLeaveType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtStartDate.Text) || 
                    string.IsNullOrWhiteSpace(txtEndDate.Text) ||
                    string.IsNullOrWhiteSpace(txtLeaveReason.Text))
                {
                    lblLeaveMessage.Text = "Please fill in all required fields.";
                    lblLeaveMessage.Style["display"] = "block";
                    return;
                }

                var employee = CurrentEmployee;
                if (employee == null) return;

                var leave = new Leave
                {
                    EmployeeId = employee.EmployeeId,
                    EmployeeName = employee.FullName,
                    LeaveType = ddlLeaveType.SelectedItem.Text,
                    StartDate = DateTime.Parse(txtStartDate.Text),
                    EndDate = DateTime.Parse(txtEndDate.Text),
                    Reason = txtLeaveReason.Text.Trim(),
                    Status = "Pending",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                var leaveService = new LeaveService();
                RegisterAsyncTask(new PageAsyncTask(async () => {
                    await leaveService.CreateLeaveAsync(leave);
                    SendLeaveEmail(employee, leave.LeaveType, txtStartDate.Text, txtEndDate.Text, leave.Reason);
                }));

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";

                lblLeaveMessage.Text = "✓ Your leave request has been submitted successfully!";
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["color"] = "#155724";
                lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                lblLeaveMessage.Style["padding"] = "10px";
                lblLeaveMessage.Style["borderRadius"] = "5px";
                
                ClientScript.RegisterStartupScript(this.GetType(), "closeLeaveModal", 
                    "setTimeout(function() { closeModal('leaveModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblLeaveMessage.Text = "Error: " + ex.Message;
                lblLeaveMessage.Style["display"] = "block";
            }
        }

        private void SendConcernEmail(EmployeeConcern concern, Employee employee)
        {
            try
            {
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"];
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword)) return;

                using (MailMessage mail = new MailMessage())
                {
                    mail.From = new MailAddress(smtpUsername, "Employee Concern System");
                    mail.To.Add(employee.Email);
                    mail.Subject = "Concern Submission Confirmation";
                    mail.Body = $"Hello {employee.FirstName},\n\nYour concern regarding '{concern.Subject}' has been received.\n\nPriority: {concern.PriorityLevel}\nStatus: {concern.Status}\n\nThank you.";
                    
                    using (SmtpClient smtp = new SmtpClient(ConfigurationManager.AppSettings["SmtpHost"], int.Parse(ConfigurationManager.AppSettings["SmtpPort"])))
                    {
                        smtp.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtp.EnableSsl = true;
                        smtp.Send(mail);
                    }
                }
            }
            catch { }
        }

        private void SendLeaveEmail(Employee employee, string leaveType, string startDate, string endDate, string reason)
        {
            try
            {
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"];
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword)) return;

                using (MailMessage mail = new MailMessage())
                {
                    mail.From = new MailAddress(smtpUsername, "Employee Leave System");
                    mail.To.Add(employee.Email);
                    mail.Subject = "Leave Request Confirmation";
                    mail.Body = $"Hello {employee.FirstName},\n\nYour leave request for {leaveType} from {startDate} to {endDate} has been submitted.\n\nReason: {reason}\n\nStatus: Pending Approval";
                    
                    using (SmtpClient smtp = new SmtpClient(ConfigurationManager.AppSettings["SmtpHost"], int.Parse(ConfigurationManager.AppSettings["SmtpPort"])))
                    {
                        smtp.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                        smtp.EnableSsl = true;
                        smtp.Send(mail);
                    }
                }
            }
            catch { }
        }
    }
}
