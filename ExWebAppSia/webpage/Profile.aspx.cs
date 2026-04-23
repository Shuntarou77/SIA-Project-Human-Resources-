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
using MongoDB.Driver;
using System.Text.RegularExpressions;
using MongoDB.Bson;

namespace ExWebAppSia.webpage
{
    public partial class HRProfile : System.Web.UI.Page
    {
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private readonly UndertimeService _undertimeService = new UndertimeService();
        private string _attendanceStatusJson = null;
        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private PayrollSnapshot _latestSnapshot = null;

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
        protected string GetEmployeePosition() => CurrentEmployee?.Position ?? "N/A";
        protected string GetEmployeeEmail() => CurrentEmployee?.Email ?? "N/A";
        protected string GetEmployeeContact() => CurrentEmployee?.ContactNo ?? "N/A";
        protected string GetEmployeeDepartment() => CurrentEmployee?.Department ?? "N/A";
        protected string GetEmployeeBirthdate() => CurrentEmployee?.BirthDate?.ToLocalTime().ToString("MMM dd, yyyy") ?? "N/A";
        protected string GetEmployeeAge() => CurrentEmployee?.CalculatedAge?.ToString() ?? "N/A";
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

        protected string GetEmployeeEducationLevel() => CurrentEmployee?.EducationLevel ?? "N/A";
        protected string GetEmployeeSchool() => CurrentEmployee?.School ?? "N/A";
        protected string GetEmployeeDegree() => CurrentEmployee?.Degree ?? "N/A";
        protected string GetEmergencyContactName() => CurrentEmployee?.GuardianName ?? "N/A";
        protected string GetEmergencyContactRelationship() => CurrentEmployee?.GuardianRelationship ?? "N/A";
        protected string GetEmergencyContactNo() => CurrentEmployee?.GuardianContactNo ?? "N/A";
        protected string GetEmergencyContactAddress() => CurrentEmployee?.GuardianHomeAddress ?? "N/A";
        protected string GetEmployeeCivilStatus() => CurrentEmployee?.CivilStatus ?? "Single";
        protected string GetEmployeeAddress() => CurrentEmployee?.Address ?? "N/A";

        protected string GetPreviousCompany() => CurrentEmployee?.PreviousCompanyName ?? "N/A";
        protected string GetPreviousPosition() => CurrentEmployee?.PreviousPosition ?? "N/A";
        protected string GetYearsOfExperience() => CurrentEmployee?.YearsOfExperience.ToString() ?? "0";

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
                
                OvertimeRequest otRequest = null;
                if (attendance != null)
                {
                    otRequest = await _overtimeService.GetByAttendanceIdAsync(attendance.Id);
                }

                var status = new
                {
                    hasTimedIn = attendance != null && attendance.TimeIn.HasValue,
                    hasTimedOut = attendance != null && attendance.TimeOut.HasValue,
                    timeIn = attendance?.TimeIn?.ToLocalTime().ToString("h:mm tt"),
                    timeOut = attendance?.TimeOut?.ToLocalTime().ToString("h:mm tt"),
                    overtimeStatus = otRequest?.Status ?? "None",
                    resignationStatus = employee.ResignationStatus ?? "None"
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
                
                // Fetch approved leaves
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId);
                var approvedLeaves = leaves.Where(l => l.Status == "Approved").ToList();

                await CalculateAttendanceStatisticsAsync(employee, approvedLeaves);
                
                // Add Overtime and Undertime Async
                await LoadOvertimeAndUndertimeStatsAsync(employee.EmployeeId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance stats: {ex.Message}");
                _attendanceStats = GetDefaultStats();
            }
        }

        private async Task CalculateAttendanceStatisticsAsync(Employee employee, List<Leave> approvedLeaves)
        {
            if (_employeeAttendanceRecords == null)
            {
                _attendanceStats = GetDefaultStats();
                return;
            }

            var now = DateTime.Now;
            var today = now.Date;
            var hiredDate = employee.HiredDate.ToLocalTime().Date;
            
            // System tracking started on March 19, 2026
            var trackingStartDate = AttendanceService.TRACKING_START_DATE;

            // 1. Current Month Stats
            var currentMonthStart = new DateTime(now.Year, now.Month, 1);
            // Don't count days before hired date or before tracking started
            var monthlyStatsStart = hiredDate > currentMonthStart ? hiredDate : currentMonthStart;
            if (monthlyStatsStart < trackingStartDate) monthlyStatsStart = trackingStartDate;

            var currentMonthRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime.Date >= currentMonthStart && x.LocalTime.Date <= today)
                .ToList();

            var currentMonthPresent = currentMonthRecords.Select(x => x.LocalTime.Date).Distinct().Count();
            
            // Calculate finalized working days passed BEFORE today
            var yesterday = today.AddDays(-1);
            int pastWorkingDays = 0;
            if (monthlyStatsStart <= yesterday)
            {
                pastWorkingDays = Enumerable.Range(0, (yesterday - monthlyStatsStart).Days + 1)
                    .Select(i => monthlyStatsStart.AddDays(i))
                    .Count(d => d.DayOfWeek != DayOfWeek.Sunday); // Include Saturdays as workdays
            }

            // Subtract approved leave days from pastWorkingDays to reduce absents (only for past days)
            int leaveDaysUntilYesterday = 0;
            foreach (var leave in approvedLeaves)
            {
                for (var d = leave.StartDate.ToLocalTime().Date; d <= leave.EndDate.ToLocalTime().Date; d = d.AddDays(1))
                {
                    if (d >= monthlyStatsStart && d < today && d.DayOfWeek != DayOfWeek.Sunday)
                    {
                        leaveDaysUntilYesterday++;
                    }
                }
            }

            // Also exclude days already present in the past from the finalized working days
            var presentUntilYesterday = currentMonthRecords.Select(x => x.LocalTime.Date).Distinct().Count(d => d < today);

            // Absent = Past Working Days (Finalized) - Present (Finalized) - Leave (Finalized)
            var currentMonthAbsent = Math.Max(0, pastWorkingDays - presentUntilYesterday - leaveDaysUntilYesterday);
            
            // Late calculation: Shift starts at 8:00 AM, Late after 8:15 AM
            var currentMonthLate = currentMonthRecords.GroupBy(x => x.LocalTime.Date).Count(g => {
                var firstIn = g.OrderBy(x => x.LocalTime).First().LocalTime;
                return firstIn.Hour > 8 || (firstIn.Hour == 8 && firstIn.Minute > 15);
            });
            
            // Attendance Rate based on expected working days (total working days passed so far minus leaves)
            int workingDaysIncludingToday = Enumerable.Range(0, (today - monthlyStatsStart).Days + 1)
                    .Select(i => monthlyStatsStart.AddDays(i))
                    .Count(d => d.DayOfWeek != DayOfWeek.Sunday);
            
            int expectedWorkingDays = Math.Max(1, workingDaysIncludingToday);
            var currentMonthAttendancePercent = (int)Math.Round((double)currentMonthPresent / expectedWorkingDays * 100);

            // 2. Yearly stats — delegated to the centralized service for consistency across all dashboards
            //    The service uses "yesterday" as the finalized cutoff so today's in-progress day
            //    is never counted as an absence.
            int remainingAbsences = await _attendanceService.GetRemainingAbsencesAsync(employee.EmployeeId, employee.HiredDate);

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

        private async Task LoadOvertimeAndUndertimeStatsAsync(string employeeId)
        {
            try
            {
                var now = DateTime.Now;
                var currentMonth = new DateTime(now.Year, now.Month, 1);
                
                // Load approved overtime
                var overtimeRequests = await MongoDBHelper.GetOvertimeRequestsCollection()
                    .Find(o => o.EmployeeId == employeeId && o.Status == "Approved" && o.IsActive)
                    .ToListAsync();
                
                double totalOt = overtimeRequests
                    .Where(o => o.Date >= currentMonth)
                    .Sum(o => {
                        if (string.IsNullOrEmpty(o.OvertimeWorked)) return 0.0;
                        var parts = o.OvertimeWorked.Split(':');
                        if (parts.Length >= 2 && double.TryParse(parts[0], out double h) && double.TryParse(parts[1], out double m))
                            return h + (m / 60.0);
                        return 0.0;
                    });

                // Load undertime
                var undertimeRecords = await _undertimeService.GetUndertimeRecordsByEmployeeAsync(employeeId);
                int monthlyUt = undertimeRecords.Count(u => u.Date >= currentMonth);

                if (_attendanceStats != null)
                {
                    _attendanceStats["overtimeHours"] = Math.Round(totalOt, 1);
                    _attendanceStats["undertimeCount"] = monthlyUt;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading OT/UT stats: {ex.Message}");
            }
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
        public string GetOvertimeHours() => _attendanceStats != null && _attendanceStats.ContainsKey("overtimeHours") ? _attendanceStats["overtimeHours"].ToString() : "0.0";
        public string GetUndertimeCount() => _attendanceStats != null && _attendanceStats.ContainsKey("undertimeCount") ? _attendanceStats["undertimeCount"].ToString() : "0";

        private async Task LoadLatestPayrollAsync()
        {
            try
            {
                if (CurrentEmployee == null) return;
                
                var collection = MongoDBHelper.GetPayrollSnapshotsCollection();
                
                // Match by EmployeeNumber (most reliable) - Relaxed pattern to handle trailing characters
                var idPattern = "^" + Regex.Escape(CurrentEmployee.EmployeeId?.Trim() ?? "");
                var numFilter = Builders<PayrollSnapshot>.Filter.Regex(p => p.EmployeeNumber, 
                    new MongoDB.Bson.BsonRegularExpression(idPattern, "i"));
                
                _latestSnapshot = await collection.Find(numFilter)
                    .SortByDescending(p => p.PayPeriodEnd)
                    .FirstOrDefaultAsync();

                if (_latestSnapshot == null)
                {
                    // Fallback to name - Match by start of name
                    var namePattern = "^" + Regex.Escape(CurrentEmployee.FullName?.Trim() ?? "");
                    var nameFilter = Builders<PayrollSnapshot>.Filter.Regex(p => p.FullName, 
                        new MongoDB.Bson.BsonRegularExpression(namePattern, "i"));
                    
                    _latestSnapshot = await collection.Find(nameFilter)
                        .SortByDescending(p => p.PayPeriodEnd)
                        .FirstOrDefaultAsync();
                }
            }
            catch { }
        }

        protected string GetBasicSalary() => _latestSnapshot?.BasicSalary.ToString("N2") ?? "0.00";
        protected string GetAllowances() => (_latestSnapshot?.HousingAllowance + _latestSnapshot?.TransportAllowance + _latestSnapshot?.MealAllowance + _latestSnapshot?.OtherAllowances)?.ToString("N2") ?? "0.00";
        protected string GetOvertimePay() => _latestSnapshot?.TotalOvertime.ToString("N2") ?? "0.00";
        protected string GetGrossSalary() => _latestSnapshot?.GrossPay.ToString("N2") ?? "0.00";
        protected string GetSSSDeduction() => _latestSnapshot?.SSSDeduction.ToString("N2") ?? "0.00";
        protected string GetPhilHealthDeduction() => _latestSnapshot?.PhilHealthDeduction.ToString("N2") ?? "0.00";
        protected string GetPagIbigDeduction() => _latestSnapshot?.PagIbigDeduction.ToString("N2") ?? "0.00";
        protected string GetWithholdingTax() => _latestSnapshot?.WithholdingTax.ToString("N2") ?? "0.00";
        protected string GetTotalDeductions() => _latestSnapshot?.TotalDeductions.ToString("N2") ?? "0.00";
        protected string GetNetSalary() => _latestSnapshot?.NetPay.ToString("N2") ?? "0.00";
        protected string GetAbsenceDeduction() => _latestSnapshot?.AbsenceDeduction.ToString("N2") ?? "0.00";
        protected string GetPenalties() => _latestSnapshot?.TotalPenalties.ToString("N2") ?? "0.00";
        protected string GetPayPeriod() => _latestSnapshot != null ? $"{_latestSnapshot.PayPeriodStart:MMMM dd, yyyy} - {_latestSnapshot.PayPeriodEnd:MMMM dd, yyyy}" : "-";

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

                ClientScript.RegisterStartupScript(this.GetType(), "showSuccessConcern", 
                    "closeModal('concernModal'); openSuccessModal('Your concern has been submitted successfully! HR will review it and get back to you.'); setTimeout(function() { window.location.reload(); }, 3500);", true);
            }
            catch (Exception ex)
            {
                lblConcernMessage.Text = "Error: " + ex.Message;
                lblConcernMessage.Style["display"] = "block";
            }
        }

        protected async void btnSubmitLeave_Click(object sender, EventArgs e)
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

                var employee = Session["Employee"] as Employee;
                if (employee == null) return;

                var leave = new Leave
                {
                    EmployeeId = employee.EmployeeId,
                    EmployeeName = employee.FullName,
                    LeaveType = ddlLeaveType.SelectedItem.Text,
                    StartDate = DateTime.Parse(txtStartDate.Text),
                    EndDate = DateTime.Parse(txtEndDate.Text),
                    Reason = txtLeaveReason.Text,
                    Status = "Pending",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                var leaveService = new LeaveService();
                await leaveService.CreateLeaveAsync(leave);

                // Send email
                try {
                    SendLeaveEmail(employee, leave.LeaveType, txtStartDate.Text, txtEndDate.Text, leave.Reason);
                } catch { /* Email error shouldn't block submission */ }

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";

                ClientScript.RegisterStartupScript(this.GetType(), "showSuccessLeave", 
                    "closeModal('leaveModal'); openSuccessModal('Your leave request has been submitted successfully! One of our HR personnel will review it shortly.'); setTimeout(function() { window.location.reload(); }, 3500);", true);
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
