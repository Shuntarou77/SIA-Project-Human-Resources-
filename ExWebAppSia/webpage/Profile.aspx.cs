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
            // Ensure we have an employee record, if not try to fetch it
            if (CurrentEmployee == null && Session["Username"] != null)
            {
                var username = Session["Username"].ToString();
                var empId = Session["EmployeeId"]?.ToString();
                
                var employeeService = new EmployeeService();
                Employee emp = null;
                
                if (!string.IsNullOrEmpty(empId))
                    emp = await employeeService.GetByEmployeeIdAsync(empId);
                
                if (emp == null)
                    emp = await employeeService.GetEmployeeByEmailAsync(username);
                    
                if (emp != null)
                    Session["Employee"] = emp;
            }

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
            get 
            { 
                var emp = Session["Employee"] as Employee;
                
                // CRITICAL: Prevent cross-account data leakage
                if (emp != null)
                {
                    string expectedEmail = Session["ExpectedEmail"] as string;
                    string expectedId = Session["ExpectedId"] as string;
                    string employeeEmail = emp.Email;
                    string employeeId = emp.EmployeeId;
                    
                    bool isMismatch = false;
                    
                    if (!string.IsNullOrEmpty(expectedEmail) && !string.Equals(expectedEmail, employeeEmail, StringComparison.OrdinalIgnoreCase))
                    {
                        isMismatch = true;
                        System.Diagnostics.Debug.WriteLine($"[AdminProfile] SECURITY ALERT: Email Mismatch! Expected={expectedEmail}, Actual={employeeEmail}");
                    }
                    
                    if (!string.IsNullOrEmpty(expectedId) && !string.Equals(expectedId, employeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        isMismatch = true;
                        System.Diagnostics.Debug.WriteLine($"[AdminProfile] SECURITY ALERT: ID Mismatch! Expected={expectedId}, Actual={employeeId}");
                    }

                    if (isMismatch)
                    {
                        System.Diagnostics.Debug.WriteLine($"[AdminProfile] Identity Mismatch detected. Re-fetching correct record...");
                        
                        var employeeService = new EmployeeService();
                        Employee correctEmp = null;
                        
                        if (!string.IsNullOrEmpty(expectedId))
                            correctEmp = Task.Run(() => employeeService.GetByEmployeeIdAsync(expectedId)).GetAwaiter().GetResult();
                        else if (!string.IsNullOrEmpty(expectedEmail))
                            correctEmp = Task.Run(() => employeeService.GetEmployeeByEmailAsync(expectedEmail)).GetAwaiter().GetResult();
                            
                        if (correctEmp != null)
                        {
                            Session["Employee"] = correctEmp;
                            return correctEmp;
                        }
                        
                        Session["Employee"] = null;
                        return null;
                    }
                }
                return emp; 
            }
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
        private bool _isOnLeave = false;
        protected string GetEmployeeStatus()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "N/A";
            string status = employee.EmploymentStatus;
            if (_isOnLeave) status += " - On Leave";
            return status;
        }
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

        protected string GetResignationStatus()
        {
            return CurrentEmployee?.ResignationStatus ?? "None";
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

                // Check leave status
                var leaveService = new LeaveService();
                _isOnLeave = await leaveService.IsEmployeeOnLeaveAsync(employee.EmployeeId);

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

                // UNIFIED LOGIC: Use centralized AttendanceService for consistent MONTHLY stats
                var stats = await _attendanceService.GetMonthlyAttendanceStatsAsync(employee.EmployeeId, employee.HiredDate);

                _attendanceStats = new Dictionary<string, object>
                {
                    { "daysPresent", stats.PresentCount },
                    { "daysAbsent", stats.AbsentCount },
                    { "daysLate", stats.LateCount },
                    { "attendanceRate", (int)Math.Round(stats.AttendanceRate) },
                    { "remainingAbsences", stats.RemainingAbsences },
                    { "targetWorkingDays", stats.WorkingDaysToDate }
                };
                
                // Add Overtime and Undertime Async
                await LoadOvertimeAndUndertimeStatsAsync(employee.EmployeeId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance stats: {ex.Message}");
                _attendanceStats = GetDefaultStats();
            }
        }

        // Removed legacy CalculateAttendanceStatisticsAsync as it is now handled by AttendanceService.GetYearlyAttendanceStatsAsync

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
            { "targetWorkingDays", AttendanceService.GetWorkingDaysCount(AttendanceService.TRACKING_START_DATE, DateTime.Now.Date.AddDays(-1)) }
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

        protected async void btnSubmitConcern_Click(object sender, EventArgs e)
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
                await concernService.CreateConcernAsync(concern);
                
                // Send email using optimized service
                var emailService = new EmailService();
                bool emailSent = await emailService.SendConcernEmailAsync(
                    employee.Email,
                    employee.FullName,
                    employee.EmployeeId,
                    employee.Department ?? "N/A",
                    concern.ConcernType,
                    concern.Subject,
                    concern.Description
                );

                // Clear form
                ddlConcernType.SelectedIndex = 0;
                txtConcernSubject.Text = "";
                txtConcernDescription.Text = "";

                ClientScript.RegisterStartupScript(this.GetType(), "showSuccessConcern", 
                    "closeModal('concernModal'); openSuccessModal('" + (emailSent ? "Your concern has been submitted successfully! HR will review it and get back to you." : "Your concern has been submitted, but confirmation email failed.") + "'); setTimeout(function() { window.location.reload(); }, 3500);", true);
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

                // Send email using optimized service
                var emailService = new EmailService();
                bool emailSent = await emailService.SendLeaveEmailAsync(
                    employee.Email,
                    employee.FullName,
                    employee.EmployeeId,
                    employee.Department ?? "N/A",
                    leave.LeaveType,
                    leave.StartDate.ToLocalTime().ToString("MMM dd, yyyy"),
                    leave.EndDate.ToLocalTime().ToString("MMM dd, yyyy"),
                    leave.Reason
                );

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";

                ClientScript.RegisterStartupScript(this.GetType(), "showSuccessLeave", 
                    "closeModal('leaveModal'); openSuccessModal('" + (emailSent ? "Your leave request has been submitted successfully! One of our HR personnel will review it shortly." : "Your leave request was submitted, but confirmation email failed.") + "'); setTimeout(function() { window.location.reload(); }, 3500);", true);
            }
            catch (Exception ex)
            {
                lblLeaveMessage.Text = "Error: " + ex.Message;
                lblLeaveMessage.Style["display"] = "block";
            }
        }
    }
}
