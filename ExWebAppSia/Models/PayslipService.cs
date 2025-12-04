using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayslipService - Manages payslip generation and distribution (Function 6.4)
    /// </summary>
    public class PayslipService
    {
        private readonly IMongoCollection<Payslip> _collection;
        private readonly PayRunService _payRunService;

        public PayslipService()
     {
       var database = MongoDBHelper.GetDatabase();
          _collection = database.GetCollection<Payslip>("Payslips");
_payRunService = new PayRunService();
        }

  // ========== FUNCTION 6.4.1: AUTOMATED PAYSLIP GENERATION ==========

        /// <summary>
        /// Generate payslips for all employees in approved payrun
        /// </summary>
   public async Task<List<Payslip>> GeneratePayslipsAsync(string payRunId)
   {
            try
  {
          var payRun = await _payRunService.GetByIdAsync(payRunId);
       if (payRun == null || payRun.Status != "Approved")
      {
  throw new Exception("PayRun must be approved before generating payslips");
         }

    var payslips = new List<Payslip>();

     foreach (var item in payRun.Items)
       {
       var payslip = await GenerateSinglePayslipAsync(payRunId, item.EmployeeId);
if (payslip != null)
   {
      payslips.Add(payslip);
        }
 }

          return payslips;
            }
   catch (Exception ex)
   {
      System.Diagnostics.Debug.WriteLine($"Error generating payslips: {ex.Message}");
       throw;
        }
        }

  /// <summary>
 /// Generate payslip for single employee
 /// </summary>
  public async Task<Payslip> GenerateSinglePayslipAsync(string payRunId, string employeeId)
        {
            try
            {
   var payRun = await _payRunService.GetByIdAsync(payRunId);
       if (payRun == null) return null;

    var item = payRun.Items.FirstOrDefault(i => i.EmployeeId == employeeId);
        if (item == null) return null;

// Generate HTML content
       var htmlContent = GeneratePayslipHTML(payRun, item);

        var payslip = new Payslip
  {
   EmployeeId = item.EmployeeId,
           PayRunId = payRunId,
    PayPeriodStart = payRun.PayPeriodStart,
        PayPeriodEnd = payRun.PayPeriodEnd,
        PayDate = payRun.PayDate,
     HtmlContent = htmlContent,
       PdfFilePath = $"/Payslips/{payRun.PayRunNumber}_{item.EmployeeId}.pdf",
    GeneratedAt = DateTime.UtcNow,
    
           // Snapshot data
           EmployeeName = item.EmployeeName,
      Department = item.Department,
 GrossSalary = item.GrossSalary,
            TotalDeductions = item.TotalDeductions,
      NetSalary = item.NetSalary
     };

await _collection.InsertOneAsync(payslip);
                return payslip;
            }
  catch (Exception ex)
       {
        System.Diagnostics.Debug.WriteLine($"Error generating single payslip: {ex.Message}");
  return null;
      }
        }

        /// <summary>
   /// Generate HTML payslip content
   /// </summary>
  private string GeneratePayslipHTML(PayRun payRun, PayrollItem item)
   {
     var sb = new StringBuilder();
      
        sb.AppendLine("<!DOCTYPE html>");
   sb.AppendLine("<html>");
         sb.AppendLine("<head>");
         sb.AppendLine("<meta charset='UTF-8'>");
  sb.AppendLine("<title>Payslip</title>");
sb.AppendLine("<style>");
       sb.AppendLine(@"
      body { font-family: Arial, sans-serif; margin: 40px; }
      .header { text-align: center; margin-bottom: 30px; border-bottom: 3px solid #A36A66; padding-bottom: 20px; }
           .company-name { font-size: 24px; font-weight: bold; color: #A36A66; }
    .payslip-title { font-size: 20px; margin-top: 10px; }
                .period { color: #666; margin-top: 5px; }
             .employee-info { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 30px 0; }
         .info-row { padding: 8px; background: #f5f5f5; border-radius: 4px; }
        .info-label { font-weight: bold; color: #A36A66; font-size: 12px; }
           .info-value { font-size: 14px; margin-top: 3px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                th { background: #A36A66; color: white; padding: 12px; text-align: left; }
td { padding: 10px; border-bottom: 1px solid #ddd; }
.section-title { font-weight: bold; background: #f0f0f0; }
     .total-row { font-weight: bold; font-size: 16px; background: #f9f9f9; }
           .net-salary { background: #A36A66; color: white; font-size: 18px; text-align: center; padding: 15px; border-radius: 8px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
     ");
  sb.AppendLine("</style>");
     sb.AppendLine("</head>");
            sb.AppendLine("<body>");
            
  // Header
   sb.AppendLine("<div class='header'>");
        sb.AppendLine("<div class='company-name'>YOUR COMPANY NAME</div>");
            sb.AppendLine("<div class='payslip-title'>PAYSLIP</div>");
            sb.AppendLine($"<div class='period'>Pay Period: {payRun.PayPeriodDisplay}</div>");
            sb.AppendLine($"<div class='period'>Pay Date: {payRun.PayDate:MMMM dd, yyyy}</div>");
         sb.AppendLine("</div>");

         // Employee Info
            sb.AppendLine("<div class='employee-info'>");
    sb.AppendLine($"<div class='info-row'><div class='info-label'>Employee ID</div><div class='info-value'>{item.EmployeeId}</div></div>");
   sb.AppendLine($"<div class='info-row'><div class='info-label'>Employee Name</div><div class='info-value'>{item.EmployeeName}</div></div>");
 sb.AppendLine($"<div class='info-row'><div class='info-label'>Department</div><div class='info-value'>{item.Department}</div></div>");
sb.AppendLine($"<div class='info-row'><div class='info-label'>Position</div><div class='info-value'>{item.Position}</div></div>");
            sb.AppendLine("</div>");

            // Earnings & Deductions Table
            sb.AppendLine("<table>");
        sb.AppendLine("<thead>");
sb.AppendLine("<tr><th>EARNINGS</th><th style='text-align:right'>AMOUNT</th><th>DEDUCTIONS</th><th style='text-align:right'>AMOUNT</th></tr>");
       sb.AppendLine("</thead>");
          sb.AppendLine("<tbody>");
        
   // Row 1
  sb.AppendLine($"<tr><td>Basic Salary</td><td style='text-align:right'>&#8369;{item.ProratedBasicSalary:N2}</td>");
            sb.AppendLine($"<td>SSS</td><td style='text-align:right'>&#8369;{item.SSSDeduction:N2}</td></tr>");
            
      // Row 2
     sb.AppendLine($"<tr><td>Allowances</td><td style='text-align:right'>&#8369;{item.Allowances:N2}</td>");
sb.AppendLine($"<td>PhilHealth</td><td style='text-align:right'>&#8369;{item.PhilHealthDeduction:N2}</td></tr>");
        
  // Row 3
     sb.AppendLine($"<tr><td>Overtime Pay</td><td style='text-align:right'>&#8369;{item.OvertimePay:N2}</td>");
          sb.AppendLine($"<td>Pag-IBIG</td><td style='text-align:right'>&#8369;{item.PagIbigDeduction:N2}</td></tr>");
            
            // Row 4
   sb.AppendLine($"<tr><td>Holiday Pay</td><td style='text-align:right'>&#8369;{item.HolidayPay:N2}</td>");
      sb.AppendLine($"<td>Withholding Tax</td><td style='text-align:right'>&#8369;{item.WithholdingTax:N2}</td></tr>");
   
            // Row 5
 sb.AppendLine($"<tr><td>Night Differential</td><td style='text-align:right'>&#8369;{item.NightDifferentialPay:N2}</td>");
       sb.AppendLine($"<td>SSS Loan</td><td style='text-align:right'>&#8369;{item.SSSLoan:N2}</td></tr>");
            
  // Row 6
      sb.AppendLine($"<tr><td>Bonuses</td><td style='text-align:right'>&#8369;{item.Bonuses:N2}</td>");
            sb.AppendLine($"<td>Pag-IBIG Loan</td><td style='text-align:right'>&#8369;{item.PagIbigLoan:N2}</td></tr>");
            
 // Row 7
   sb.AppendLine($"<tr><td>Other Earnings</td><td style='text-align:right'>&#8369;{item.OtherEarnings:N2}</td>");
            sb.AppendLine($"<td>Company Loan</td><td style='text-align:right'>&#8369;{item.CompanyLoan:N2}</td></tr>");
     
       // Row 8
    sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Absence Penalty</td><td style='text-align:right'>&#8369;{item.AbsencePenalty:N2}</td></tr>");
       
   // Row 9
     sb.AppendLine($"<tr><td></td><td></td>");
       sb.AppendLine($"<td>Late Penalty</td><td style='text-align:right'>&#8369;{item.LatePenalty:N2}</td></tr>");
            
       // Row 10
 sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Unpaid Leave</td><td style='text-align:right'>&#8369;{item.UnpaidLeaveDeduction:N2}</td></tr>");
       
   // Row 11
sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Other Deductions</td><td style='text-align:right'>&#8369;{item.OtherDeductions:N2}</td></tr>");
       
      // Totals
        sb.AppendLine($"<tr class='total-row'><td>TOTAL GROSS</td><td style='text-align:right'>&#8369;{item.GrossSalary:N2}</td>");
      sb.AppendLine($"<td>TOTAL DEDUCTIONS</td><td style='text-align:right'>&#8369;{item.TotalDeductions:N2}</td></tr>");
            
   sb.AppendLine("</tbody>");
    sb.AppendLine("</table>");
        
   // Net Salary
       sb.AppendLine($"<div class='net-salary'>NET SALARY: &#8369;{item.NetSalary:N2}</div>");
 
       // Attendance Summary
        sb.AppendLine("<table style='margin-top:30px'>");
       sb.AppendLine("<tr class='section-title'><td colspan='2'>ATTENDANCE SUMMARY</td></tr>");
         sb.AppendLine($"<tr><td>Days Present</td><td>{item.DaysPresent} / {item.TotalWorkingDays}</td></tr>");
       sb.AppendLine($"<tr><td>Days Absent</td><td>{item.DaysAbsent}</td></tr>");
   sb.AppendLine($"<tr><td>Days Late</td><td>{item.DaysLate}</td></tr>");
   sb.AppendLine($"<tr><td>Late Minutes</td><td>{item.LateMinutes}</td></tr>");
        sb.AppendLine($"<tr><td>Unpaid Leave Days</td><td>{item.UnpaidLeaveDays}</td></tr>");
            sb.AppendLine("</table>");
     
       // Remarks
    if (!string.IsNullOrEmpty(item.Remarks))
            {
    sb.AppendLine("<div style='margin-top:20px; padding:10px; background:#fffbcc; border-radius:4px;'>");
       sb.AppendLine($"<strong>Remarks:</strong> {item.Remarks}");
sb.AppendLine("</div>");
       }
   
   // Footer
            sb.AppendLine("<div class='footer'>");
         sb.AppendLine($"Generated on {DateTime.Now:MMMM dd, yyyy 'at' hh:mm tt}<br>");
 sb.AppendLine("This is a computer-generated payslip. No signature required.<br>");
     sb.AppendLine("For inquiries, contact HR Department");
            sb.AppendLine("</div>");
            
      sb.AppendLine("</body>");
            sb.AppendLine("</html>");
      
    return sb.ToString();
        }

// ========== FUNCTION 6.4.2: PAYSLIP PORTAL ==========

        /// <summary>
        /// Get payslips for employee
   /// </summary>
        public async Task<List<Payslip>> GetEmployeePayslipsAsync(string employeeId)
     {
       try
    {
   var filter = Builders<Payslip>.Filter.And(
        Builders<Payslip>.Filter.Eq(p => p.EmployeeId, employeeId),
               Builders<Payslip>.Filter.Eq(p => p.IsActive, true)
    );

     return await _collection.Find(filter)
    .SortByDescending(p => p.PayPeriodStart)
   .ToListAsync();
     }
         catch (Exception ex)
        {
   System.Diagnostics.Debug.WriteLine($"Error getting employee payslips: {ex.Message}");
    return new List<Payslip>();
   }
        }

        /// <summary>
/// Get all payslips
     /// </summary>
        public async Task<List<Payslip>> GetAllPayslipsAsync()
      {
 try
   {
      return await _collection.Find(p => p.IsActive)
  .SortByDescending(p => p.GeneratedAt)
             .ToListAsync();
   }
        catch (Exception ex)
     {
       System.Diagnostics.Debug.WriteLine($"Error getting all payslips: {ex.Message}");
                return new List<Payslip>();
    }
 }

        /// <summary>
   /// Get payslip by ID
 /// </summary>
        public async Task<Payslip> GetPayslipByIdAsync(string id)
{
         var filter = Builders<Payslip>.Filter.Eq(p => p.Id, id);
            return await _collection.Find(filter).FirstOrDefaultAsync();
   }

        /// <summary>
     /// Email payslip to employee
        /// </summary>
        public async Task<bool> EmailPayslipAsync(string payslipId)
        {
         try
            {
     var payslip = await GetPayslipByIdAsync(payslipId);
       if (payslip == null) return false;

                // TODO: Implement email sending
         // var emailService = new EmailService();
   // await emailService.SendPayslipEmailAsync(payslip);

   var update = Builders<Payslip>.Update.Set(p => p.EmailedAt, DateTime.UtcNow);
      var filter = Builders<Payslip>.Filter.Eq(p => p.Id, payslipId);
   await _collection.UpdateOneAsync(filter, update);

      return true;
    }
  catch (Exception ex)
  {
           System.Diagnostics.Debug.WriteLine($"Error emailing payslip: {ex.Message}");
     return false;
  }
        }
    }
}
