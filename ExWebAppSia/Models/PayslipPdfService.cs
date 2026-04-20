using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using SelectPdf;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// Service for generating payslip PDFs from HTML content
    /// </summary>
    public class PayslipPdfService
    {
        /// <summary>
        /// Generate PDF from payslip HTML content
        /// </summary>
        /// <param name="htmlContent">The HTML content of the payslip</param>
        /// <returns>Byte array of the PDF file</returns>
        public byte[] GeneratePdfFromHtml(string htmlContent)
        {
            try
            {
                // Create HTML to PDF converter
                HtmlToPdf converter = new HtmlToPdf();

                // Set converter options
                converter.Options.PdfPageSize = PdfPageSize.A4;
                converter.Options.PdfPageOrientation = PdfPageOrientation.Portrait;
                converter.Options.MarginTop = 20;
                converter.Options.MarginBottom = 20;
                converter.Options.MarginLeft = 20;
                converter.Options.MarginRight = 20;
                converter.Options.WebPageWidth = 1024;
                converter.Options.WebPageHeight = 0; // Auto height

                // Convert HTML to PDF
                PdfDocument doc = converter.ConvertHtmlString(htmlContent);

                // Save to byte array
                byte[] pdfBytes = doc.Save();

                // Close the document
                doc.Close();

                return pdfBytes;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating PDF: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Generate payslip PDF for a specific employee from PayRun
        /// </summary>
        public async Task<byte[]> GeneratePayslipPdfAsync(string payRunId, string employeeId)
        {
            try
            {
                var payRunService = new PayRunService();
                var payRun = await payRunService.GetByIdAsync(payRunId);

                if (payRun == null)
                    throw new Exception("PayRun not found");

                var payrollItem = payRun.Items.Find(p => p.EmployeeId == employeeId);
                if (payrollItem == null)
                    throw new Exception("Employee payroll item not found");

                // Generate HTML content using our own method
                var htmlContent = GenerateEnhancedPayslipHtml(payRun, payrollItem);

                // Convert to PDF
                return GeneratePdfFromHtml(htmlContent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating payslip PDF: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Generate enhanced payslip HTML with better styling for PDF
        /// </summary>
        public string GenerateEnhancedPayslipHtml(PayRun payRun, PayrollItem item)
        {
            var sb = new StringBuilder();

            sb.AppendLine("<!DOCTYPE html>");
            sb.AppendLine("<html>");
            sb.AppendLine("<head>");
            sb.AppendLine("<meta charset='UTF-8'>");
            sb.AppendLine("<title>Payslip</title>");
            sb.AppendLine("<style>");
            sb.AppendLine(@"
                @page {
                    size: A4;
                    margin: 0;
                }
                body { 
                    font-family: 'Segoe UI', Arial, sans-serif; 
                    margin: 0;
                    padding: 40px;
                    font-size: 12px;
                    color: #333;
                }
                .header { 
                    text-align: center; 
                    margin-bottom: 30px; 
                    border-bottom: 3px solid #A36A66; 
                    padding-bottom: 20px; 
                }
                .company-name { 
                    font-size: 24px; 
                    font-weight: bold; 
                    color: #A36A66; 
                    margin-bottom: 5px;
                }
                .payslip-title { 
                    font-size: 20px; 
                    margin-top: 10px; 
                    font-weight: bold;
                }
                .period { 
                    color: #666; 
                    margin-top: 5px; 
                    font-size: 11px;
                }
                .employee-info { 
                    display: grid; 
                    grid-template-columns: 1fr 1fr; 
                    gap: 15px; 
                    margin: 30px 0; 
                }
                .info-row { 
                    padding: 10px; 
                    background: #f5f5f5; 
                    border-radius: 4px; 
                }
                .info-label { 
                    font-weight: bold; 
                    color: #A36A66; 
                    font-size: 10px; 
                    text-transform: uppercase;
                    margin-bottom: 3px;
                }
                .info-value { 
                    font-size: 13px; 
                }
                table { 
                    width: 100%; 
                    border-collapse: collapse; 
                    margin: 20px 0; 
                }
                th { 
                    background: #A36A66; 
                    color: white; 
                    padding: 12px 8px; 
                    text-align: left; 
                    font-size: 11px;
                    font-weight: 600;
                }
                td { 
                    padding: 8px; 
                    border-bottom: 1px solid #ddd; 
                    font-size: 11px;
                }
                .total-row { 
                    font-weight: bold; 
                    font-size: 12px; 
                    background: #f9f9f9; 
                }
                .net-salary { 
                    background: #A36A66; 
                    color: white; 
                    font-size: 18px; 
                    text-align: center; 
                    padding: 15px; 
                    border-radius: 8px; 
                    margin: 20px 0; 
                    font-weight: bold;
                }
                .footer { 
                    text-align: center; 
                    margin-top: 40px; 
                    padding-top: 20px; 
                    border-top: 1px solid #ddd; 
                    font-size: 10px; 
                    color: #666; 
                }
                .amount-right {
                    text-align: right;
                }
            ");
            sb.AppendLine("</style>");
            sb.AppendLine("</head>");
            sb.AppendLine("<body>");

            // Header
            sb.AppendLine("<div class='header'>");
            sb.AppendLine("<div class='company-name'>Sheessentials</div>");
            sb.AppendLine("<div class='payslip-title'>PAYSLIP</div>");
            sb.AppendLine($"<div class='period'>Pay Period: {payRun.PayPeriodDisplay}</div>");
            sb.AppendLine($"<div class='period'>Pay Date: {payRun.PayDate:MMMM dd, yyyy}</div>");
            sb.AppendLine("</div>");

            // Employee Info
            // Try to get the human-readable Employee ID if available in the item or passed separately
            // For now, we'll use the one from the item, but if we have the employee object we could use that.
            // Since we don't want to break the signature, let's just use what we have but formatted better.
            
            string displayEmployeeId = item.EmployeeId;
            // If it looks like a MongoDB ID (24 hex chars), it's probably internal. 
            // In a real scenario, we'd pass the Employee object to this method.
            
            sb.AppendLine($"<div class='info-row'><div class='info-label'>Employee ID</div><div class='info-value'>{displayEmployeeId}</div></div>");
            sb.AppendLine($"<div class='info-row'><div class='info-label'>Employee Name</div><div class='info-value'>{item.EmployeeName}</div></div>");
            sb.AppendLine($"<div class='info-row'><div class='info-label'>Department</div><div class='info-value'>{item.Department}</div></div>");
            sb.AppendLine($"<div class='info-row'><div class='info-label'>Position</div><div class='info-value'>{item.Position}</div></div>");
            sb.AppendLine($"<div class='info-row'><div class='info-label'>Monthly Rate</div><div class='info-value'>₱{item.BasicSalary:N2}</div></div>");
            sb.AppendLine("</div>");

            // Earnings & Deductions Table
            sb.AppendLine("<table>");
            sb.AppendLine("<thead>");
            sb.AppendLine("<tr><th>EARNINGS</th><th class='amount-right'>AMOUNT</th><th>DEDUCTIONS</th><th class='amount-right'>AMOUNT</th></tr>");
            sb.AppendLine("</thead>");
            sb.AppendLine("<tbody>");

            // Rows
            sb.AppendLine($"<tr><td>Basic Salary</td><td class='amount-right'>₱{item.BasicSalary:N2}</td>");
            sb.AppendLine($"<td>SSS</td><td class='amount-right'>₱{item.SSSDeduction:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Allowances</td><td class='amount-right'>₱{item.Allowances:N2}</td>");
            sb.AppendLine($"<td>PhilHealth</td><td class='amount-right'>₱{item.PhilHealthDeduction:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Overtime Pay</td><td class='amount-right'>₱{item.OvertimePay:N2}</td>");
            sb.AppendLine($"<td>Pag-IBIG</td><td class='amount-right'>₱{item.PagIbigDeduction:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Holiday Pay</td><td class='amount-right'>₱{item.HolidayPay:N2}</td>");
            sb.AppendLine($"<td>Withholding Tax</td><td class='amount-right'>₱{item.WithholdingTax:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Night Differential</td><td class='amount-right'>₱{item.NightDifferentialPay:N2}</td>");
            sb.AppendLine($"<td>SSS Loan</td><td class='amount-right'>₱{item.SSSLoan:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Bonuses</td><td class='amount-right'>₱{item.Bonuses:N2}</td>");
            sb.AppendLine($"<td>Pag-IBIG Loan</td><td class='amount-right'>₱{item.PagIbigLoan:N2}</td></tr>");

            sb.AppendLine($"<tr><td>Other Earnings</td><td class='amount-right'>₱{item.OtherEarnings:N2}</td>");
            sb.AppendLine($"<td>Company Loan</td><td class='amount-right'>₱{item.CompanyLoan:N2}</td></tr>");

            sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Absence Penalty</td><td class='amount-right'>₱{item.AbsencePenalty:N2}</td></tr>");

            sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Late Penalty</td><td class='amount-right'>₱{item.LatePenalty:N2}</td></tr>");

            sb.AppendLine($"<tr><td></td><td></td>");
            sb.AppendLine($"<td>Other Deductions</td><td class='amount-right'>₱{item.OtherDeductions:N2}</td></tr>");

            // Totals
            sb.AppendLine($"<tr class='total-row'><td>TOTAL EARNINGS</td><td class='amount-right'>₱{item.GrossSalary:N2}</td>");
            sb.AppendLine($"<td>TOTAL DEDUCTIONS</td><td class='amount-right'>₱{item.TotalDeductions:N2}</td></tr>");

            sb.AppendLine("</tbody>");
            sb.AppendLine("</table>");

            // Net Salary
            sb.AppendLine($"<div class='net-salary'>NET SALARY: ₱{item.NetSalary:N2}</div>");

            // Footer
            sb.AppendLine("<div class='footer'>");
            sb.AppendLine("<p>This is a computer-generated payslip and does not require a signature.</p>");
            sb.AppendLine($"<p>Generated on: {DateTime.Now:MMMM dd, yyyy hh:mm tt}</p>");
            sb.AppendLine("</div>");

            sb.AppendLine("</body>");
            sb.AppendLine("</html>");

            return sb.ToString();
        }
    }
}
