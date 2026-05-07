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

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm2 : System.Web.UI.Page
    {
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
                        System.Diagnostics.Debug.WriteLine($"[EmployeeProfile] SECURITY ALERT: Email Mismatch! Expected={expectedEmail}, Actual={employeeEmail}");
                    }
                    
                    if (!string.IsNullOrEmpty(expectedId) && !string.Equals(expectedId, employeeId, StringComparison.OrdinalIgnoreCase))
                    {
                        isMismatch = true;
                        System.Diagnostics.Debug.WriteLine($"[EmployeeProfile] SECURITY ALERT: ID Mismatch! Expected={expectedId}, Actual={employeeId}");
                    }

                    if (isMismatch)
                    {
                        System.Diagnostics.Debug.WriteLine($"[EmployeeProfile] Identity Mismatch detected. Re-fetching correct record...");
                        
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

        protected string GetEmployeePosition()
        {
            var employee = CurrentEmployee;
            return employee?.Position ?? "N/A";
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

                // UNIFIED LOGIC: Use centralized AttendanceService for consistent MONTHLY stats
                var stats = await _attendanceService.GetMonthlyAttendanceStatsAsync(employee.EmployeeId, employee.HiredDate);

                _attendanceStats = new Dictionary<string, object>
                {
                    { "daysPresent", stats.PresentCount },
                    { "daysAbsent", stats.AbsentCount },
                    { "daysLate", stats.LateCount },
                    { "attendanceRate", Math.Round(stats.AttendanceRate, 1) },
                    { "remainingAbsences", stats.RemainingAbsences },
                    { "targetWorkingDays", stats.WorkingDaysToDate },
                    { "overtimeHours", 0.0 }, // placeholder
                    { "undertimeCount", 0 }    // placeholder
                };
                
                // Add Overtime and Undertime Async
                await LoadOvertimeAndUndertimeStatsAsync(employee.EmployeeId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attendance statistics: {ex.Message}");
                _attendanceStats = GetDefaultStats();
            }
        }

        // Removed CalculateAttendanceStatistics as it is now handled by AttendanceService.GetYearlyAttendanceStatsAsync

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
                { "targetWorkingDays", AttendanceService.GetWorkingDaysCount(AttendanceService.TRACKING_START_DATE, DateTime.Now.Date) },
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
            return "✓ Verified";
        }

        protected async void btnSubmitConcern_Click(object sender, EventArgs e)
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
                lblConcernMessage.Text = $"✓ Your concern has been submitted successfully! Sending confirmation email to {employee.Email}...";
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

                // Save to database
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting database save...");
                    var concernService = new EmployeeConcernService();
                    await concernService.CreateConcernAsync(concern);
                }
                catch (Exception dbEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Database error: {dbEx.Message}");
                }

                // Send email using optimized service
                bool emailSent = false;
                string emailError = null;
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting email send via EmailService...");
                    var emailService = new EmailService();
                    emailSent = await emailService.SendConcernEmailAsync(
                        employee.Email,
                        employee.FullName,
                        employee.EmployeeId,
                        employee.Department ?? "N/A",
                        concern.ConcernType,
                        concern.Subject,
                        concern.Description
                    );
                    System.Diagnostics.Debug.WriteLine($"Email sent: {emailSent}");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Email error: {emailEx.Message}");
                }
                
                // Update success message with email status
                if (emailSent)
                {
                    lblConcernMessage.Text = $"✓ Your concern has been submitted successfully! A confirmation email has been sent to {employee.Email}.";
                    lblConcernMessage.Style["color"] = "#155724";
                    lblConcernMessage.Style["backgroundColor"] = "#d4edda";
                    lblConcernMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblConcernMessage.Text = $"✓ Your concern has been submitted successfully! However, the email could not be sent. {emailError ?? "Please contact HR."}";
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

                // Clear form
                ddlLeaveType.SelectedIndex = 0;
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtLeaveReason.Text = "";
                fileLeaveAttachment.Attributes.Clear();

                // Show initial success message
                lblLeaveMessage.Text = $"✓ Your leave request has been submitted successfully! Sending confirmation email to {employee.Email}...";
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

                // Send email using optimized service
                bool emailSent = false;
                string emailError = null;
                try
                {
                    System.Diagnostics.Debug.WriteLine("Starting leave email send via EmailService...");
                    var emailService = new EmailService();
                    emailSent = await emailService.SendLeaveEmailAsync(
                        employee.Email,
                        employee.FullName,
                        employee.EmployeeId,
                        employee.Department ?? "N/A",
                        leave.LeaveType,
                        leave.StartDate.ToLocalTime().ToString("MMM dd, yyyy"),
                        leave.EndDate.ToLocalTime().ToString("MMM dd, yyyy"),
                        leave.Reason
                    );
                    System.Diagnostics.Debug.WriteLine($"Leave email sent: {emailSent}");
                }
                catch (Exception emailEx)
                {
                    emailSent = false;
                    emailError = emailEx.Message;
                    System.Diagnostics.Debug.WriteLine($"Leave email error: {emailEx.Message}");
                }
                
                // Update success message with email status
                if (emailSent)
                {
                    lblLeaveMessage.Text = $"✓ Your leave request has been submitted successfully! A confirmation email has been sent to {employee.Email}.";
                    lblLeaveMessage.Style["color"] = "#155724";
                    lblLeaveMessage.Style["backgroundColor"] = "#d4edda";
                    lblLeaveMessage.Style["border"] = "1px solid #c3e6cb";
                }
                else
                {
                    lblLeaveMessage.Text = $"✓ Your leave request has been submitted successfully! However, the confirmation email could not be sent. {emailError ?? "Please contact HR."}";
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
    }
}