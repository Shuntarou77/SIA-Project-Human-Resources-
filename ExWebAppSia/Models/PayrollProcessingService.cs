using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayrollProcessingService - Core payroll calculation engine (Function 6.2)
    /// Handles data aggregation, salary calculations, and pay run generation
    /// </summary>
    public class PayrollProcessingService
    {
     private readonly PayrollConfigurationService _configService;
        private readonly AttendanceService _attendanceService;
  private readonly LeaveService _leaveService;
        private readonly EmployeeService _employeeService;
 private readonly PayScheduleService _scheduleService;

        public PayrollProcessingService()
  {
            _configService = new PayrollConfigurationService();
    _attendanceService = new AttendanceService();
      _leaveService = new LeaveService();
         _employeeService = new EmployeeService();
     _scheduleService = new PayScheduleService();
     }

        // ========== FUNCTION 6.2.1: DATA AGGREGATION ==========

        /// <summary>
        /// Aggregate attendance data for an employee in a pay period
        /// </summary>
        public async Task<(int daysPresent, int daysAbsent, int daysLate, int lateMinutes)> 
            GetAttendanceDataAsync(string employeeId, DateTime startDate, DateTime endDate)
        {
     try
            {
     // Get all attendance records for period
        var attendanceRecords = await _attendanceService.GetAttendanceByEmployeeAndDateRangeAsync(
          employeeId, startDate, endDate);

              int daysPresent = 0;
         int daysAbsent = 0;
       int daysLate = 0;
        int totalLateMinutes = 0;

   // Calculate working days in period (excluding weekends)
     var workingDays = new List<DateTime>();
   for (var date = startDate; date <= endDate; date = date.AddDays(1))
             {
           if (date.DayOfWeek != DayOfWeek.Saturday && date.DayOfWeek != DayOfWeek.Sunday)
      workingDays.Add(date.Date);
        }

       // Analyze each working day
   foreach (var day in workingDays)
    {
           var attendance = attendanceRecords.FirstOrDefault(a => a.Date.Date == day.Date);

     if (attendance == null)
    {
               // No attendance record = absent
            daysAbsent++;
           }
        else if (attendance.TimeIn.HasValue)
                    {
            // Present
         daysPresent++;

     // Check if late (after 8:00 AM)
        var timeIn = attendance.TimeIn.Value;
 var expectedTime = new DateTime(timeIn.Year, timeIn.Month, timeIn.Day, 8, 0, 0);

           if (timeIn > expectedTime)
        {
      daysLate++;
     var lateMinutes = (int)(timeIn - expectedTime).TotalMinutes;
             totalLateMinutes += lateMinutes;
    }
         }
    }

                return (daysPresent, daysAbsent, daysLate, totalLateMinutes);
            }
          catch (Exception ex)
            {
       System.Diagnostics.Debug.WriteLine($"Error getting attendance data: {ex.Message}");
return (0, 0, 0, 0);
   }
      }

/// <summary>
        /// Get overtime hours for an employee (placeholder - implement based on your OT tracking)
   /// </summary>
        public async Task<(decimal regularOT, decimal holidayOT, decimal nightDiff)>
            GetOvertimeDataAsync(string employeeId, DateTime startDate, DateTime endDate)
  {
    // TODO: Implement based on your overtime tracking system
            // For now, return zeros. You can add OT tracking later.
    await Task.CompletedTask;
        return (0m, 0m, 0m);
  }

        /// <summary>
   /// Get unpaid leave days for an employee
     /// </summary>
      public async Task<int> GetUnpaidLeaveDaysAsync(string employeeId, DateTime startDate, DateTime endDate)
        {
            try
            {
       var leaves = await _leaveService.GetLeavesByEmployeeAndDateRangeAsync(
   employeeId, startDate, endDate);

    // Count only approved unpaid leaves
                var unpaidLeaves = leaves.Where(l => 
        l.Status == "Approved" && 
           (l.LeaveType == "Unpaid" || l.LeaveType == "Emergency")).ToList();

     int unpaidDays = 0;
  foreach (var leave in unpaidLeaves)
     {
     // Calculate days between start and end (inclusive)
            var days = (leave.EndDate.Date - leave.StartDate.Date).Days + 1;
  unpaidDays += days;
    }

                return unpaidDays;
            }
          catch (Exception ex)
            {
   System.Diagnostics.Debug.WriteLine($"Error getting leave data: {ex.Message}");
            return 0;
            }
        }

        // ========== FUNCTION 6.2.2: GROSS SALARY CALCULATION ==========

/// <summary>
        /// Calculate gross salary for an employee
        /// Formula: (Basic � Days Present / Total Days) + Overtime + Allowances + Bonuses
    /// </summary>
  public decimal CalculateGrossSalary(
            PayrollConfiguration config,
            int daysPresent,
      int totalWorkingDays,
            decimal regularOTHours,
            decimal holidayOTHours,
            decimal nightDiffHours,
            decimal bonuses = 0)
        {
 if (config == null) return 0;

            // 1. Prorated Basic Salary
          decimal proratedBasic = 0;
            if (totalWorkingDays > 0)
      {
         proratedBasic = config.BasicSalary * daysPresent / totalWorkingDays;
            }

          // 2. Allowances (usually full amount regardless of attendance)
  decimal allowances = config.TotalAllowances;

         // 3. Overtime Pay
        decimal overtimePay = (regularOTHours * config.RegularOvertimeRate) +
  (holidayOTHours * config.HolidayOvertimeRate) +
          (nightDiffHours * config.NightDifferentialRate);

        // 4. Bonuses
            // bonuses parameter allows for performance/special bonuses

  // Total Gross
      decimal grossSalary = proratedBasic + allowances + overtimePay + bonuses;

   return Math.Round(grossSalary, 2);
        }

    // ========== FUNCTION 6.2.3: DEDUCTIONS CALCULATION ==========

        /// <summary>
        /// Calculate total deductions
        /// Formula: Statutory + Loans + Penalties
   /// </summary>
        public decimal CalculateDeductions(
      PayrollConfiguration config,
            int daysAbsent,
 int lateMinutes,
   int unpaidLeaveDays)
        {
   if (config == null) return 0;

         // 1. Statutory Deductions (fixed from config)
     decimal statutory = config.TotalStatutoryDeductions;

        // 2. Loan Deductions (fixed from config)
            decimal loans = config.TotalLoanDeductions;

 // 3. Absence Penalty
   decimal absencePenalty = daysAbsent * config.AbsencePenaltyRate;

      // 4. Late Penalty (convert minutes to hours)
            decimal lateHours = lateMinutes / 60m;
            decimal latePenalty = lateHours * config.LatePenaltyRate;

  // 5. Unpaid Leave Deduction (daily rate)
    decimal dailyRate = config.BasicSalary / 22; // Assuming 22 working days/month
            decimal unpaidLeaveDeduction = unpaidLeaveDays * dailyRate;

            // 6. Other Deductions
    decimal other = config.OtherDeductions;

     // Total Deductions
decimal totalDeductions = statutory + loans + absencePenalty + latePenalty + 
               unpaidLeaveDeduction + other;

            return Math.Round(totalDeductions, 2);
        }

      // ========== FUNCTION 6.2.4: NET SALARY CALCULATION ==========

        /// <summary>
        /// Calculate net salary
        /// Formula: Gross - Deductions
        /// </summary>
        public decimal CalculateNetSalary(decimal grossSalary, decimal deductions)
        {
  return Math.Round(grossSalary - deductions, 2);
        }

        // ========== FUNCTION 6.2.5: PAY RUN GENERATION ==========

   /// <summary>
        /// Generate complete payroll for selected employees (6.2.5)
        /// </summary>
  public async Task<PayRun> GeneratePayRunAsync(
       List<string> employeeIds,
          DateTime startDate,
            DateTime endDate,
 string createdBy)
   {
       try
 {
         System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] START - {employeeIds.Count} employees");
         
         // Get active pay schedule with fallback
         var schedule = await _scheduleService.GetActiveScheduleAsync().ConfigureAwait(false);
         
         if (schedule == null)
         {
             System.Diagnostics.Debug.WriteLine("[GeneratePayRunAsync] WARNING: No active pay schedule found, using defaults");
             
             // Create a temporary default schedule instead of throwing
             schedule = new PaySchedule
             {
                 ScheduleType = "Semi-Monthly",
                 PayFrequency = 2, // int: 2 times per month
                 FirstCutoffDay = 15,
                 SecondCutoffDay = DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month),
                 FirstPayDay = 20,
                 SecondPayDay = 5,
                 TotalWorkingDaysPerMonth = 22,
                 WorkingHoursPerDay = 8,
                 IsActive = false // Mark as temporary
             };
         }

          // Calculate working days
      int totalWorkingDays = _scheduleService.CalculateWorkingDays(startDate, endDate);
      System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] Total working days: {totalWorkingDays}");

         // Create pay run
   var payRun = new PayRun
     {
 PayPeriodStart = startDate,
     PayPeriodEnd = endDate,
               PayPeriodType = schedule.ScheduleType,
             CutoffDate = endDate,
     PayRunNumber = await GeneratePayRunNumberAsync().ConfigureAwait(false),
Description = $"{schedule.ScheduleType} Payroll: {startDate:MMM dd} - {endDate:MMM dd, yyyy}",
           Status = "Calculated",
      CreatedBy = createdBy,
     CreatedAt = DateTime.UtcNow,
  UpdatedAt = DateTime.UtcNow
       };

     // Calculate pay date
     try
     {
         var (_, __, payDate) = await _scheduleService.GetCurrentPayPeriodAsync().ConfigureAwait(false);
         payRun.PayDate = payDate;
     }
     catch (Exception pdEx)
     {
         System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] Pay date calculation failed: {pdEx.Message}, using default");
         payRun.PayDate = endDate.AddDays(5); // Default: 5 days after period end
     }

    // Process each employee
    int processedCount = 0;
    int skippedCount = 0;
                foreach (var employeeId in employeeIds)
           {
          var item = await ProcessEmployeePayrollAsync(employeeId, startDate, endDate, totalWorkingDays).ConfigureAwait(false);
  if (item != null)
         {
          payRun.Items.Add(item);
          processedCount++;
    }
    else
    {
        skippedCount++;
        System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] Skipped employee {employeeId} (no config or error)");
    }
     }

    System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] Processed: {processedCount}, Skipped: {skippedCount}");

    if (payRun.Items.Count == 0)
    {
        System.Diagnostics.Debug.WriteLine("[GeneratePayRunAsync] WARNING: No payroll items generated (all employees skipped)");
        throw new Exception("No payroll items generated. Ensure employees have payroll configurations.");
    }

             // Calculate totals
    payRun.RecalculateTotals();
    
    System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] SUCCESS - Total Gross: {payRun.TotalGrossSalary:C}, Net: {payRun.TotalNetSalary:C}");

        return payRun;
            }
 catch (Exception ex)
    {
  System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] ERROR: {ex.Message}");
  System.Diagnostics.Debug.WriteLine($"[GeneratePayRunAsync] Stack: {ex.StackTrace}");
           throw;
   }
        }

        /// <summary>
        /// Process payroll for a single employee
        /// </summary>
        private async Task<PayrollItem> ProcessEmployeePayrollAsync(
        string employeeId,
            DateTime startDate,
        DateTime endDate,
    int totalWorkingDays)
        {
     try
          {
       System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] START for employee {employeeId}");
       
       // Get employee details
       System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Fetching employee details...");
          var employee = await _employeeService.GetEmployeeByIdAsync(employeeId).ConfigureAwait(false);
           if (employee == null)
           {
               System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Employee {employeeId} not found");
               return null;
           }
           System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Employee found: {employee.FullName}");

           // Get payroll configuration
           System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Fetching payroll config...");
     var config = await _configService.GetByEmployeeIdAsync(employeeId).ConfigureAwait(false);
                if (config == null)
{
              System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] No payroll config for {employeeId} ({employee.FullName})");
        return null;
      }
      System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Config found - Basic: {config.BasicSalary:C}");

                // STEP 1: Aggregate Data (6.2.1)
                System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Aggregating attendance data...");
      var (daysPresent, daysAbsent, daysLate, lateMinutes) = 
             await GetAttendanceDataAsync(employeeId, startDate, endDate).ConfigureAwait(false);
        System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Attendance: Present={daysPresent}, Absent={daysAbsent}");

        System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Aggregating overtime data...");
        var (regularOT, holidayOT, nightDiff) = 
        await GetOvertimeDataAsync(employeeId, startDate, endDate).ConfigureAwait(false);

       System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Aggregating leave data...");
       var unpaidLeaveDays = await GetUnpaidLeaveDaysAsync(employeeId, startDate, endDate).ConfigureAwait(false);

        // STEP 2: Calculate Gross Salary (6.2.2)
        System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Calculating gross salary...");
       decimal proratedBasic = (config.BasicSalary * daysPresent) / totalWorkingDays;
  decimal allowances = config.TotalAllowances;
             decimal overtimePay = (regularOT * config.RegularOvertimeRate) +
      (holidayOT * config.HolidayOvertimeRate) +
             (nightDiff * config.NightDifferentialRate);

           decimal grossSalary = CalculateGrossSalary(
            config, daysPresent, totalWorkingDays, regularOT, holidayOT, nightDiff);

    // STEP 3: Calculate Deductions (6.2.3)
    System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Calculating deductions...");
             decimal absencePenalty = daysAbsent * config.AbsencePenaltyRate;
                decimal latePenalty = (lateMinutes / 60m) * config.LatePenaltyRate;
   decimal dailyRate = config.BasicSalary / 22;
  decimal unpaidLeaveDeduction = unpaidLeaveDays * dailyRate;

    // Check if basic salary is below 25,000 - if so, exclude withholding tax
    bool isTaxExempt = config.BasicSalary < 25000m;
    decimal withholdingTax = isTaxExempt ? 0m : config.WithholdingTax;
    
    // Calculate statutory deductions (SSS, PhilHealth, PagIbig) - always included
    decimal statutoryDeductions = config.SSSContribution + 
                                   config.PhilHealthContribution + 
                                   config.PagIbigContribution + 
                                   withholdingTax;

    if (isTaxExempt)
    {
        System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Basic salary {config.BasicSalary:C} is below 25,000 - withholding tax excluded");
    }

         decimal totalDeductions = statutoryDeductions + 
                 config.TotalLoanDeductions +
          absencePenalty + latePenalty + unpaidLeaveDeduction +
                  config.OtherDeductions;

         // STEP 4: Calculate Net Salary (6.2.4)
   decimal netSalary = CalculateNetSalary(grossSalary, totalDeductions);

     System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Calculations complete - Gross: {grossSalary:C}, Net: {netSalary:C}");

     // Create PayrollItem
        var item = new PayrollItem
    {
EmployeeId = employeeId,
  EmployeeName = employee.FullName,
         Department = employee.Department,
    Position = employee.Role,

// Attendance
     TotalWorkingDays = totalWorkingDays,
        DaysPresent = daysPresent,
           DaysAbsent = daysAbsent,
    DaysLate = daysLate,
    LateMinutes = lateMinutes,
      UnpaidLeaveDays = unpaidLeaveDays,

              // Overtime
RegularOvertimeHours = regularOT,
      HolidayOvertimeHours = holidayOT,
         NightDifferentialHours = nightDiff,

              // Earnings
            BasicSalary = config.BasicSalary,
    ProratedBasicSalary = Math.Round(proratedBasic, 2),
            Allowances = allowances,
           OvertimePay = Math.Round(overtimePay, 2),
         GrossSalary = grossSalary,

// Deductions
          SSSDeduction = config.SSSContribution,
      PhilHealthDeduction = config.PhilHealthContribution,
         PagIbigDeduction = config.PagIbigContribution,
     WithholdingTax = withholdingTax, // Will be 0 if basic salary < 25,000
           SSSLoan = config.SSSLoan,
      PagIbigLoan = config.PagIbigLoan,
          CompanyLoan = config.CompanyLoan,
            AbsencePenalty = Math.Round(absencePenalty, 2), // Penalties always applied
           LatePenalty = Math.Round(latePenalty, 2), // Penalties always applied
UnpaidLeaveDeduction = Math.Round(unpaidLeaveDeduction, 2), // Penalties always applied
   OtherDeductions = config.OtherDeductions,
  TotalDeductions = Math.Round(totalDeductions, 2),

       // Net
     NetSalary = netSalary,

     Status = "Calculated",
      IsManuallyAdjusted = false
    };

      System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] SUCCESS for {employee.FullName}");
      return item;
            }
 catch (Exception ex)
            {
      System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] ERROR for {employeeId}: {ex.Message}");
      System.Diagnostics.Debug.WriteLine($"[ProcessEmployeePayrollAsync] Stack: {ex.StackTrace}");
                return null;
 }
 }
        /// <summary>
        /// Generate unique pay run number
        /// </summary>
   private async Task<string> GeneratePayRunNumberAsync()
        {
       await Task.CompletedTask; // Placeholder for async
            var year = DateTime.Now.Year;
            var month = DateTime.Now.Month;
            var random = new Random().Next(100, 999);
     return $"PR-{year}-{month:D2}-{random}";
        }
 }
}
