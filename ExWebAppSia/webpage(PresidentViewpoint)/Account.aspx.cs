using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Configuration;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Driver;
using Newtonsoft.Json;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class Account : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Label lblConcernMessage;
        protected global::System.Web.UI.WebControls.DropDownList ddlConcernType;
        protected global::System.Web.UI.WebControls.TextBox txtConcernSubject;
        protected global::System.Web.UI.WebControls.TextBox txtConcernDescription;
        protected global::System.Web.UI.WebControls.FileUpload fileSupportingDocs;
        protected global::System.Web.UI.WebControls.Label lblLeaveMessage;
        protected global::System.Web.UI.WebControls.DropDownList ddlLeaveType;
        protected global::System.Web.UI.WebControls.TextBox txtStartDate;
        protected global::System.Web.UI.WebControls.TextBox txtEndDate;
        protected global::System.Web.UI.WebControls.TextBox txtLeaveReason;
        protected global::System.Web.UI.WebControls.FileUpload fileLeaveAttachment;
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly OvertimeService _overtimeService = new OvertimeService();
        private readonly UndertimeService _undertimeService = new UndertimeService();
        private List<Attendance> _employeeAttendanceRecords = null;
        private Dictionary<string, object> _attendanceStats = null;
        private PayrollSnapshot _latestPayroll = null;
        private string _attendanceStatusJson = null;

        private const int TOTAL_WORKING_DAYS_PER_YEAR = 260;
        private const int TOTAL_ALLOWED_ABSENCES_PER_YEAR = 15;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable HTML5 validation to prevent "invalid form control is not focusable" error
            if (!IsPostBack)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "DisableValidation", 
                    "if (document.forms[0]) { document.forms[0].noValidate = true; }", true);
            }
            
            // Always load statistics and sync missing data
            RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatisticsAsync));
            RegisterAsyncTask(new PageAsyncTask(LoadLatestPayrollAsync));
            RegisterAsyncTask(new PageAsyncTask(SyncMissingDataAsync));
            RegisterAsyncTask(new PageAsyncTask(LoadAttendanceStatusAsync));

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

        protected string GetEmployeeBirthdate()
        {
            var employee = CurrentEmployee;
            if (employee == null || !employee.BirthDate.HasValue) return "N/A";
            return employee.BirthDate.Value.ToLocalTime().ToString("MMM dd, yyyy");
        }

        protected string GetEmployeeAge()
        {
            var employee = CurrentEmployee;
            return employee?.CalculatedAge?.ToString() ?? "N/A";
        }

        protected string GetEmployeeSex()
        {
            var employee = CurrentEmployee;
            if (employee == null || string.IsNullOrEmpty(employee.Gender)) return "N/A";
            return employee.Gender;
        }

        protected string GetEmployeeStatus()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "N/A";
            // Return EmploymentStatus (Regular/Probationary based on 6 months rule)
            return employee.EmploymentStatus;
        }

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
            // Regularization is usually after 6 months
            return employee.HiredDate.ToLocalTime().AddMonths(6).ToString("MMM dd, yyyy");
        }

        protected string GetEmployeeSalary()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "₱0.00";
            return $"₱{employee.BaseSalary:N2}";
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
                    _employeeAttendanceRecords = new List<Attendance>();
                    _attendanceStats = GetDefaultStats();
                    return;
                }

                // Get all attendance records for this employee
                _employeeAttendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(employee.EmployeeId);
                
                // Calculate statistics
                var leaveService = new LeaveService();
                var leaves = await leaveService.GetLeavesByEmployeeIdAsync(employee.EmployeeId);
                var approvedLeaves = leaves?.Where(l => l.Status == "Approved").ToList() ?? new List<Leave>();
                CalculateAttendanceStatistics(approvedLeaves);
                
                // Add Overtime and Undertime Async
                await LoadOvertimeAndUndertimeStatsAsync(employee.EmployeeId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance statistics: {ex.Message}");
                _employeeAttendanceRecords = new List<Attendance>();
                _attendanceStats = GetDefaultStats();
            }
        }

        private void CalculateAttendanceStatistics(List<Leave> approvedLeaves)
        {
            if (_employeeAttendanceRecords == null || _employeeAttendanceRecords.Count == 0)
            {
                _attendanceStats = GetDefaultStats();
                return;
            }

            var now = DateTime.Now;
            var today = now.Date;
            var currentMonth = new DateTime(now.Year, now.Month, 1);

            // Current month records - filter by local time
            var currentMonthRecords = _employeeAttendanceRecords
                .Where(a => a.TimeIn.HasValue)
                .Select(a => new { Record = a, LocalTime = a.TimeIn.Value.ToLocalTime() })
                .Where(x => x.LocalTime >= currentMonth && x.LocalTime < currentMonth.AddMonths(1))
                .ToList();

            // Calculate current month stats - count UNIQUE days
            var currentMonthPresentDays = currentMonthRecords
                .Select(x => x.LocalTime.Date)
                .Distinct()
                .ToList();
            var currentMonthPresent = currentMonthPresentDays.Count;

            // Count past weekdays only (exclude weekends and future days)
            var pastWeekdays = Enumerable.Range(0, (today - currentMonth).Days + 1)
                .Select(i => currentMonth.AddDays(i))
                .Where(d => d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday)
                .Count();
            var currentMonthAbsent = Math.Max(0, pastWeekdays - currentMonthPresent);

            // Calculate late count - use first time-in per day
            var currentMonthLate = currentMonthRecords
                .GroupBy(x => x.LocalTime.Date)
                .Count(g => g.OrderBy(x => x.LocalTime).First().LocalTime.Hour >= 9);

            var currentMonthAttendancePercent = pastWeekdays > 0 
                ? (int)Math.Round((double)currentMonthPresent / pastWeekdays * 100) 
                : 0;

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
            
            int yearlyLeaveDays = 0;
            foreach (var leave in approvedLeaves)
            {
                for (var d = leave.StartDate.ToLocalTime().Date; d <= leave.EndDate.ToLocalTime().Date; d = d.AddDays(1))
                {
                    if (d.Year == currentYear && d >= yearStart && d <= today && d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday)
                    {
                        yearlyLeaveDays++;
                    }
                }
            }
            
            var yearlyAbsent = Math.Max(0, pastYearWeekdays - yearlyPresent - yearlyLeaveDays);
            var remainingAbsences = Math.Max(0, TOTAL_ALLOWED_ABSENCES_PER_YEAR - yearlyAbsent);

            _attendanceStats = new Dictionary<string, object>
            {
                { "daysPresent", currentMonthPresent },
                { "daysAbsent", currentMonthAbsent },
                { "daysLate", currentMonthLate },
                { "attendanceRate", currentMonthAttendancePercent },
                { "remainingAbsences", remainingAbsences },
                { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR },
                { "overtimeHours", 0.0 }, // placeholder
                { "undertimeCount", 0 }    // placeholder
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

        private Dictionary<string, object> GetDefaultStats()
        {
            return new Dictionary<string, object>
            {
                { "daysPresent", 0 },
                { "daysAbsent", 0 },
                { "daysLate", 0 },
                { "attendanceRate", 0 },
                { "remainingAbsences", TOTAL_ALLOWED_ABSENCES_PER_YEAR },
                { "targetWorkingDays", TOTAL_WORKING_DAYS_PER_YEAR },
                { "overtimeHours", 0.0 },
                { "undertimeCount", 0 }
            };
        }

        // Public methods for ASPX page
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

        protected string GetAttendanceRate()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["attendanceRate"].ToString();
        }

        protected string GetRemainingAbsences()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["remainingAbsences"].ToString();
        }

        protected string GetTargetWorkingDays()
        {
            if (_attendanceStats == null) return "0";
            return _attendanceStats["targetWorkingDays"].ToString();
        }

        protected string GetOvertimeHours()
        {
            if (_attendanceStats == null || !_attendanceStats.ContainsKey("overtimeHours")) return "0.0";
            return _attendanceStats["overtimeHours"].ToString();
        }

        protected string GetUndertimeCount()
        {
            if (_attendanceStats == null || !_attendanceStats.ContainsKey("undertimeCount")) return "0";
            return _attendanceStats["undertimeCount"].ToString();
        }

        private async Task LoadLatestPayrollAsync()
        {
            try 
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId)) return;

                string employeeId = employee.EmployeeId;
                string fullName = employee.FullName;

                var client = new MongoClient(ConfigurationManager.ConnectionStrings["MongoDBConnection"].ConnectionString);
                var database = client.GetDatabase("sia_payroll_db");
                var collection = database.GetCollection<PayrollSnapshot>("PayrollSnapshots");

                // Use the same fuzzy logic as the Admin side
                var idFilter = Builders<PayrollSnapshot>.Filter.Regex("employee_number", new BsonRegularExpression(employeeId, "i"));
                var nameFilter = Builders<PayrollSnapshot>.Filter.Regex("full_name", new BsonRegularExpression(fullName, "i"));
                var combinedFilter = Builders<PayrollSnapshot>.Filter.Or(idFilter, nameFilter);

                _latestPayroll = await collection.Find(combinedFilter)
                    .SortByDescending(p => p.PayPeriodEnd)
                    .FirstOrDefaultAsync();

                if (_latestPayroll != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Found payroll for {fullName} in sia_payroll_db");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading payroll: {ex.Message}");
            }
        }

        // Payroll Helper Methods
        protected string GetBasicSalary() 
        {
            if (_latestPayroll == null) return "0.00";
            return _latestPayroll.BasicSalary.ToString("N2");
        }
        protected string GetAllowances() => (_latestPayroll != null ? (_latestPayroll.HousingAllowance + _latestPayroll.TransportAllowance + _latestPayroll.MealAllowance + _latestPayroll.OtherAllowances) : 0).ToString("N2");
        protected string GetOvertimePay() => _latestPayroll?.TotalOvertime.ToString("N2") ?? "0.00";
        protected string GetGrossSalary() => _latestPayroll?.GrossPay.ToString("N2") ?? "0.00";
        protected string GetSSSDeduction() => _latestPayroll?.SSSDeduction.ToString("N2") ?? "0.00";
        protected string GetPhilHealthDeduction() => _latestPayroll?.PhilHealthDeduction.ToString("N2") ?? "0.00";
        protected string GetPagIbigDeduction() => _latestPayroll?.PagIbigDeduction.ToString("N2") ?? "0.00";
        protected string GetWithholdingTax() => _latestPayroll?.WithholdingTax.ToString("N2") ?? "0.00";
        protected string GetAbsenceDeduction() => _latestPayroll?.AbsenceDeduction.ToString("N2") ?? "0.00";
        protected string GetPenalties() => _latestPayroll?.TotalPenalties.ToString("N2") ?? "0.00";
        protected string GetTotalDeductions() => _latestPayroll?.TotalDeductions.ToString("N2") ?? "0.00";
        protected string GetNetSalary() => _latestPayroll?.NetPay.ToString("N2") ?? "0.00";
        protected string GetPayPeriod() => _latestPayroll != null ? (_latestPayroll.PayPeriodStart.ToString("MMMM dd, yyyy") + " - " + _latestPayroll.PayPeriodEnd.ToString("MMMM dd, yyyy")) : "N/A";
        
        protected string GetSalaryValidationMessage()
        {
            var employee = CurrentEmployee;
            if (employee == null || _latestPayroll == null) return "";
            
            // Allow for small rounding differences
            if (Math.Abs(_latestPayroll.BasicSalary - employee.BaseSalary) > 0.01m)
            {
                return "Note: This salary reflects your rate at the time of payroll processing.";
            }
            return "âœ“ Verified";
        }

        protected void btnSubmitConcern_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("btnSubmitConcern_Click called");
            
            // Ensure modal stays open after postback
            ClientScript.RegisterStartupScript(this.GetType(), "OpenModal", 
                "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
            
            try
            {
                // Validate form
                if (string.IsNullOrWhiteSpace(ddlConcernType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtConcernSubject.Text) || 
                    string.IsNullOrWhiteSpace(txtConcernDescription.Text))
                {
                    lblConcernMessage.Text = "Please fill in all required fields.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    lblConcernMessage.Style["padding"] = "10px";
                    lblConcernMessage.Style["borderRadius"] = "5px";
                    
                    // Keep modal open
                    ClientScript.RegisterStartupScript(this.GetType(), "KeepModalOpenError", 
                        "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);
                    return;
                }

                var employee = CurrentEmployee;
                if (employee == null)
                {
                    lblConcernMessage.Text = "Employee session not found. Please log in again.";
                    lblConcernMessage.Style["display"] = "block";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                    return;
                }

                // Create concern object
                var concern = new EmployeeConcern
                {
                    EmployeeId = employee.EmployeeId,
                    EmployeeName = employee.FullName, // Format: Last Name, First Name Middle Name
                    ConcernType = ddlConcernType.SelectedItem.Text,
                    Subject = txtConcernSubject.Text.Trim(),
                    Description = txtConcernDescription.Text.Trim(),
                    PriorityLevel = "Low",
                    Status = "Submitted",
                    SubmittedDate = DateTime.UtcNow,
                    IsActive = true
                };

                // Clear form first
                ddlConcernType.SelectedIndex = 0;
                txtConcernSubject.Text = "";
                txtConcernDescription.Text = "";
                fileSupportingDocs.Attributes.Clear();

                // Show initial success message
                lblConcernMessage.Text = $"âœ“ Your concern has been submitted successfully! Sending confirmation email to {employee.Email}...";
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["color"] = "#155724";
                lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                lblConcernMessage.Style["border"] = "1px solid #c3e6cb";
                lblConcernMessage.Style["padding"] = "15px";
                lblConcernMessage.Style["borderRadius"] = "8px";
                lblConcernMessage.Style["fontWeight"] = "600";

                // Keep modal open
                ClientScript.RegisterStartupScript(this.GetType(), "showModal", 
                    "var modal = document.getElementById('concernModal'); if (modal) { modal.style.display = 'block'; }", true);

                // Save to database and send email synchronously so we can update the message
                bool emailSent = false;
                string emailError = null;
                
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting database save...");
                    var concernService = new EmployeeConcernService();
                    
                    // Try to save with a short timeout
                    var saveTask = concernService.CreateConcernAsync(concern);
                    if (saveTask.Wait(TimeSpan.FromSeconds(5))) // 5 second timeout
                    {
                        bool saved = saveTask.Result;
                        System.Diagnostics.Debug.WriteLine($"Database save completed: {saved}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Database save timed out");
                    }
                }
                catch (Exception dbEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Database error: {dbEx.Message}");
                }

                // Send email
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting email send...");
                    SendConcernEmail(concern, employee);
                    emailSent = true;
                    System.Diagnostics.Debug.WriteLine("Email sent successfully");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Email error: {emailEx.Message}");
                    if (emailEx.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Email inner exception: {emailEx.InnerException.Message}");
                    }
                }
                
                // Update success message with email status
                if (emailSent)
                {
                    lblConcernMessage.Text = $"âœ“ Your concern has been submitted successfully! A confirmation email has been sent to {employee.Email}.";
                    lblConcernMessage.Style["color"] = "#155724";
                    lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                    lblConcernMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblConcernMessage.Text = $"âœ“ Your concern has been submitted successfully! However, the email could not be sent. {emailError ?? "Please contact HR."}";
                    lblConcernMessage.Style["color"] = "#856404";
                    lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                    lblConcernMessage.Style["border"] = "1px solid #ffc107";
                }
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["padding"] = "15px";
                lblConcernMessage.Style["borderRadius"] = "8px";
                lblConcernMessage.Style["fontWeight"] = "600";
                
                // Close modal after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "closeModalAfterDelay", 
                    "setTimeout(function() { closeModal('concernModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblConcernMessage.Text = "An error occurred: " + ex.Message;
                lblConcernMessage.Style["display"] = "block";
                lblConcernMessage.Style["color"] = "#856404";
                lblConcernMessage.Style["backgroundColor"] = "#fff3cd";
                lblConcernMessage.Style["border"] = "1px solid #ffc107";
            }
        }

        private void SendConcernEmail(EmployeeConcern concern, Employee employee)
        {
            System.Diagnostics.Debug.WriteLine("SendConcernEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config or use defaults
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com"; // Default HR email
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                string employeeEmail = employee.Email ?? "";
                System.Diagnostics.Debug.WriteLine($"Concern Email SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To Employee: {employeeEmail}, CC HR: {hrEmail}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Email not sent: SMTP credentials not configured");
                    System.Diagnostics.Debug.WriteLine($"Username empty: {string.IsNullOrEmpty(smtpUsername)}, Password empty: {string.IsNullOrEmpty(smtpPassword)}");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Employee Concern System");
                
                // Send to employee's email (the person submitting the concern) for confirmation
                if (string.IsNullOrEmpty(employee.Email))
                {
                    System.Diagnostics.Debug.WriteLine("Employee email is empty, cannot send confirmation email");
                    throw new Exception("Employee email address is not available. Cannot send confirmation email.");
                }
                
                mail.To.Add(employee.Email);
                System.Diagnostics.Debug.WriteLine($"Sending concern confirmation email to employee: {employee.Email}");
                
                // Also send a copy to HR
                if (!string.IsNullOrEmpty(hrEmail))
                {
                    mail.CC.Add(hrEmail);
                    System.Diagnostics.Debug.WriteLine($"CC'ing HR: {hrEmail}");
                }
                
                mail.Subject = $"Concern Submission Confirmation - {concern.Subject}";
                mail.IsBodyHtml = true;

                // Build email body with concern details - confirmation email for employee
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A44F56;'>Concern Submission Confirmation</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");
                
                body.AppendLine("<div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #28a745;'>");
                body.AppendLine("<p style='margin: 0; color: #155724; font-weight: bold;'>âœ“ Your concern has been successfully submitted!</p>");
                body.AppendLine("</div>");
                
                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Employee Name:</strong> {employee.FullName}</p>");
                body.AppendLine($"<p><strong>Employee ID:</strong> {employee.EmployeeId}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {employee.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Subject:</strong> <span style='color: #A44F56; font-weight: bold;'>{HttpUtility.HtmlEncode(concern.Subject)}</span></p>");
                body.AppendLine($"<p><strong>Concern Type:</strong> {concern.ConcernType}</p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {concern.SubmittedDate.ToLocalTime():MMM dd, yyyy HH:mm}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A44F56; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A44F56; margin-top: 0;'>Description:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(concern.Description)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;'>");
                body.AppendLine("<p style='margin: 0; color: #856404;'><strong>Note:</strong> Your concern has been forwarded to HR for review. You will be contacted if additional information is needed.</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated confirmation email from the Employee Concern System.</p>");
                body.AppendLine("<p>If you have any questions, please contact HR.</p>");
                body.AppendLine("</div>");
                body.AppendLine("</div></body></html>");

                mail.Body = body.ToString();

                // Configure SMTP client with timeout
                System.Diagnostics.Debug.WriteLine("Configuring SMTP client...");
                smtpClient = new SmtpClient(smtpServer, smtpPort);
                smtpClient.EnableSsl = enableSsl;
                smtpClient.UseDefaultCredentials = false;
                smtpClient.Timeout = 30000; // 30 second timeout (increased for Gmail)
                smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                
                // Set credentials before enabling SSL
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                
                // For Gmail, ensure we're using the correct security settings
                if (smtpServer.Contains("gmail.com"))
                {
                    // Gmail requires SSL/TLS
                    smtpClient.EnableSsl = true;
                    System.Diagnostics.Debug.WriteLine("Gmail detected - SSL enabled");
                }

                System.Diagnostics.Debug.WriteLine("Attempting to send email...");
                // Send email
                smtpClient.Send(mail);
                System.Diagnostics.Debug.WriteLine("Email sent successfully!");
            }
            catch (System.Net.Mail.SmtpException smtpEx)
            {
                // Log SMTP-specific errors
                System.Diagnostics.Debug.WriteLine($"SMTP Error sending email: {smtpEx.Message}");
                System.Diagnostics.Debug.WriteLine($"SMTP Status Code: {smtpEx.StatusCode}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {smtpEx.StackTrace}");
                if (smtpEx.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {smtpEx.InnerException.Message}");
                }
                throw; // Re-throw to be caught by outer handler
            }
            catch (Exception ex)
            {
                // Log error but don't fail the concern submission
                System.Diagnostics.Debug.WriteLine($"General Error sending email: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Error Type: {ex.GetType().Name}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"Inner stack trace: {ex.InnerException.StackTrace}");
                }
                throw; // Re-throw to be caught by outer handler
            }
            finally
            {
                // Dispose mail and smtpClient objects if they exist
                if (mail != null)
                {
                    mail.Dispose();
                }
                if (smtpClient != null)
                {
                    smtpClient.Dispose();
                }
            }
        }

        protected async void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("btnSubmitLeave_Click called");
            
            // Ensure modal stays open after postback
            ClientScript.RegisterStartupScript(this.GetType(), "OpenLeaveModal", 
                "var modal = document.getElementById('leaveModal'); if (modal) { modal.style.display = 'block'; }", true);
            
            try
            {
                // Validate form
                if (string.IsNullOrWhiteSpace(ddlLeaveType.SelectedValue) || 
                    string.IsNullOrWhiteSpace(txtStartDate.Text) || 
                    string.IsNullOrWhiteSpace(txtEndDate.Text) ||
                    string.IsNullOrWhiteSpace(txtLeaveReason.Text))
                {
                    lblLeaveMessage.Text = "Please fill in all required fields.";
                    lblLeaveMessage.Style["display"] = "block";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                    lblLeaveMessage.Style["padding"] = "10px";
                    lblLeaveMessage.Style["borderRadius"] = "5px";
                    return;
                }

                var employee = CurrentEmployee;
                if (employee == null)
                {
                    lblLeaveMessage.Text = "Employee session not found. Please log in again.";
                    lblLeaveMessage.Style["display"] = "block";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                    lblLeaveMessage.Style["padding"] = "10px";
                    lblLeaveMessage.Style["borderRadius"] = "5px";
                    return;
                }

                // Create leave object
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

                // Capture form values for email before clearing
                string leaveType = ddlLeaveType.SelectedItem.Text;
                string startDateStr = txtStartDate.Text;
                string endDateStr = txtEndDate.Text;
                string reason = txtLeaveReason.Text;

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";
                fileLeaveAttachment.Attributes.Clear();

                // Show initial success message
                lblLeaveMessage.Text = $"âœ“ Your leave request has been submitted successfully! Sending confirmation email to {employee.Email}...";
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["color"] = "#155724";
                lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                lblLeaveMessage.Style["border"] = "1px solid #c3e6cb";
                lblLeaveMessage.Style["padding"] = "15px";
                lblLeaveMessage.Style["borderRadius"] = "8px";
                lblLeaveMessage.Style["fontWeight"] = "600";

                // Save to database
                System.Diagnostics.Debug.WriteLine("Starting database save for leave request...");
                var leaveService = new LeaveService();
                try {
                    await leaveService.CreateLeaveAsync(leave);
                    System.Diagnostics.Debug.WriteLine("Leave database save completed.");
                } catch (Exception dbEx) {
                    System.Diagnostics.Debug.WriteLine($"Leave database error: {dbEx.Message}");
                }

                // Send email
                bool emailSent = false;
                string emailError = null;
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting leave request email send...");
                    SendLeaveEmail(employee, leaveType, startDateStr, endDateStr, reason);
                    emailSent = true;
                    System.Diagnostics.Debug.WriteLine("Leave email sent successfully");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Leave email error: {emailEx.Message}");
                    if (emailEx.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"Leave email inner exception: {emailEx.InnerException.Message}");
                    }
                }
                
                // Update success message with email status
                if (emailSent)
                {
                    lblLeaveMessage.Text = $"âœ“ Your leave request has been submitted successfully! A confirmation email has been sent to {employee.Email}.";
                    lblLeaveMessage.Style["color"] = "#155724";
                    lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                    lblLeaveMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblLeaveMessage.Text = $"âœ“ Your leave request has been submitted successfully! However, the confirmation email could not be sent. {emailError ?? "Please contact HR."}";
                    lblLeaveMessage.Style["color"] = "#856404";
                    lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                    lblLeaveMessage.Style["border"] = "1px solid #ffc107";
                }
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["padding"] = "15px";
                lblLeaveMessage.Style["borderRadius"] = "8px";
                lblLeaveMessage.Style["fontWeight"] = "600";
                
                // Close modal after 3 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "closeLeaveModalAfterDelay", 
                    "setTimeout(function() { closeModal('leaveModal'); }, 3000);", true);
            }
            catch (Exception ex)
            {
                lblLeaveMessage.Text = "An error occurred: " + ex.Message;
                lblLeaveMessage.Style["display"] = "block";
                lblLeaveMessage.Style["color"] = "#856404";
                lblLeaveMessage.Style["backgroundColor"] = "#fff3cd";
                lblLeaveMessage.Style["border"] = "1px solid #ffc107";
            }
        }

        private void SendLeaveEmail(Employee employee, string leaveType, string startDate, string endDate, string reason)
        {
            System.Diagnostics.Debug.WriteLine("SendLeaveEmail method called");
            MailMessage mail = null;
            SmtpClient smtpClient = null;
            try
            {
                // Get email configuration from Web.config
                string smtpServer = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string hrEmail = ConfigurationManager.AppSettings["HREmail"] ?? "hr@company.com";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["EnableSsl"] ?? "true");

                string employeeEmail = employee.Email ?? "";
                System.Diagnostics.Debug.WriteLine($"Leave Email SMTP Config - Server: {smtpServer}, Port: {smtpPort}, From: {fromEmail}, To Employee: {employeeEmail}, CC HR: {hrEmail}");

                // Skip email if credentials are not configured
                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("Leave email not sent: SMTP credentials not configured");
                    return;
                }

                // Create email message
                mail = new MailMessage();
                mail.From = new MailAddress(fromEmail, "Employee Leave System");
                
                // Send to employee's email (the person submitting the request)
                if (string.IsNullOrEmpty(employee.Email))
                {
                    System.Diagnostics.Debug.WriteLine("Employee email is empty, cannot send confirmation email");
                    throw new Exception("Employee email address is not available. Cannot send confirmation email.");
                }
                
                mail.To.Add(employee.Email);
                System.Diagnostics.Debug.WriteLine($"Sending leave confirmation email to employee: {employee.Email}");
                
                // Also send a copy to HR
                if (!string.IsNullOrEmpty(hrEmail))
                {
                    mail.CC.Add(hrEmail);
                    System.Diagnostics.Debug.WriteLine($"CC'ing HR: {hrEmail}");
                }
                
                mail.Subject = $"Leave Request Confirmation - {employee.FullName} ({leaveType})";
                mail.IsBodyHtml = true;

                // Build email body with leave details - confirmation email for employee
                StringBuilder body = new StringBuilder();
                body.AppendLine("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
                body.AppendLine("<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>");
                body.AppendLine("<h2 style='color: #A44F56;'>Leave Request Confirmation</h2>");
                body.AppendLine("<hr style='border: 1px solid #E8C4C4; margin: 20px 0;'>");
                
                body.AppendLine("<div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #28a745;'>");
                body.AppendLine("<p style='margin: 0; color: #155724; font-weight: bold;'>âœ“ Your leave request has been successfully submitted!</p>");
                body.AppendLine("</div>");
                
                body.AppendLine("<div style='background-color: #FFE8E8; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Employee Name:</strong> {employee.FullName}</p>");
                body.AppendLine($"<p><strong>Employee ID:</strong> {employee.EmployeeId}</p>");
                body.AppendLine($"<p><strong>Department:</strong> {employee.Department ?? "N/A"}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-bottom: 20px;'>");
                body.AppendLine($"<p><strong>Leave Type:</strong> <span style='color: #A44F56; font-weight: bold;'>{leaveType}</span></p>");
                body.AppendLine($"<p><strong>Start Date:</strong> {DateTime.Parse(startDate):MMM dd, yyyy}</p>");
                body.AppendLine($"<p><strong>End Date:</strong> {DateTime.Parse(endDate):MMM dd, yyyy}</p>");
                
                // Calculate number of days
                TimeSpan duration = DateTime.Parse(endDate) - DateTime.Parse(startDate);
                int days = duration.Days + 1; // Include both start and end date
                body.AppendLine($"<p><strong>Duration:</strong> {days} day(s)</p>");
                body.AppendLine($"<p><strong>Submitted Date:</strong> {DateTime.Now:MMM dd, yyyy HH:mm}</p>");
                body.AppendLine($"<p><strong>Status:</strong> <span style='color: #f59e0b; font-weight: bold;'>Pending Approval</span></p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #A44F56; margin-bottom: 20px;'>");
                body.AppendLine("<h3 style='color: #A44F56; margin-top: 0;'>Reason for Leave:</h3>");
                body.AppendLine($"<p style='white-space: pre-wrap;'>{HttpUtility.HtmlEncode(reason)}</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;'>");
                body.AppendLine("<p style='margin: 0; color: #856404;'><strong>Note:</strong> Your leave request has been forwarded to HR for review. You will be notified once a decision has been made.</p>");
                body.AppendLine("</div>");

                body.AppendLine("<div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #E8C4C4; font-size: 12px; color: #9B7B7B;'>");
                body.AppendLine("<p>This is an automated confirmation email from the Employee Leave System.</p>");
                body.AppendLine("<p>If you have any questions, please contact HR.</p>");
                body.AppendLine("</div>");
                body.AppendLine("</div></body></html>");

                mail.Body = body.ToString();

                // Configure SMTP client with timeout
                System.Diagnostics.Debug.WriteLine("Configuring SMTP client for leave email...");
                smtpClient = new SmtpClient(smtpServer, smtpPort);
                smtpClient.EnableSsl = enableSsl;
                smtpClient.UseDefaultCredentials = false;
                smtpClient.Timeout = 30000; // 30 second timeout
                smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
                
                // Set credentials before enabling SSL
                smtpClient.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
                
                // For Gmail, ensure we're using the correct security settings
                if (smtpServer.Contains("gmail.com"))
                {
                    // Gmail requires SSL/TLS
                    smtpClient.EnableSsl = true;
                    System.Diagnostics.Debug.WriteLine("Gmail detected - SSL enabled");
                }

                System.Diagnostics.Debug.WriteLine("Attempting to send leave email...");
                smtpClient.Send(mail);
                System.Diagnostics.Debug.WriteLine("Leave email sent successfully!");
            }
            catch (System.Net.Mail.SmtpException smtpEx)
            {
                System.Diagnostics.Debug.WriteLine($"SMTP Error sending leave email: {smtpEx.Message}");
                System.Diagnostics.Debug.WriteLine($"SMTP Status Code: {smtpEx.StatusCode}");
                throw;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"General Error sending leave email: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Error Type: {ex.GetType().Name}");
                throw;
            }
            finally
            {
                if (mail != null)
                {
                    mail.Dispose();
                }
                if (smtpClient != null)
                {
                    smtpClient.Dispose();
                }
            }
        }
    }
}

