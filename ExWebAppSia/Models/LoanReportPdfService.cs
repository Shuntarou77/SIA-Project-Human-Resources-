using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SelectPdf;

namespace ExWebAppSia.Models
{
    public class LoanReportPdfService
    {
        public byte[] GenerateLoanHistoryReport(List<LoanRequest> loans)
        {
            var html = new StringBuilder();
            html.Append(@"
                <html>
                <head>
                    <style>
                        body { font-family: 'Helvetica', sans-serif; padding: 20px; color: #333; }
                        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #059669; padding-bottom: 10px; }
                        .title { font-size: 24px; color: #059669; font-weight: bold; }
                        .subtitle { font-size: 14px; color: #666; margin-top: 5px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th { background-color: #059669; color: white; padding: 12px; text-align: left; font-size: 11px; }
                        td { padding: 10px; border-bottom: 1px solid #eee; font-size: 10px; }
                        tr:nth-child(even) { background-color: #f9f9f9; }
                        .status-approved { color: #10B981; font-weight: bold; }
                        .status-pending { color: #F59E0B; font-weight: bold; }
                        .status-declined { color: #EF4444; font-weight: bold; }
                        .footer { margin-top: 30px; font-size: 10px; color: #999; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class='header'>
                        <div class='title'>Loan Requests Report</div>
                        <div class='subtitle'>Generated on " + DateTime.Now.ToString("MMMM dd, yyyy h:mm tt") + @"</div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Date Requested</th>
                                <th>Employee</th>
                                <th>Loan Type</th>
                                <th>Agency</th>
                                <th>Status</th>
                                <th>Last Updated</th>
                            </tr>
                        </thead>
                        <tbody>");

            foreach (var loan in loans.OrderByDescending(l => l.RequestDate))
            {
                string statusClass = "status-" + (loan.Status?.ToLower() ?? "pending");

                html.Append($@"
                    <tr>
                        <td>{loan.RequestDate.ToString("MMM dd, yyyy")}</td>
                        <td>{loan.EmployeeName} ({loan.EmployeeId})</td>
                        <td>{loan.LoanType}</td>
                        <td>{loan.Agency}</td>
                        <td><span class='{statusClass}'>{loan.Status}</span></td>
                        <td>{loan.LastUpdated.ToString("MMM dd, yyyy")}</td>
                    </tr>");
            }

            html.Append(@"
                        </tbody>
                    </table>
                    <div class='footer'>
                        Sheessentials HRMS - Official Loan Registry Document
                    </div>
                </body>
                </html>");

            return ConvertHtmlToPdf(html.ToString());
        }

        private byte[] ConvertHtmlToPdf(string htmlContent)
        {
            HtmlToPdf converter = new HtmlToPdf();
            converter.Options.PdfPageSize = PdfPageSize.A4;
            converter.Options.PdfPageOrientation = PdfPageOrientation.Portrait;
            converter.Options.MarginLeft = 20;
            converter.Options.MarginRight = 20;
            converter.Options.MarginTop = 20;
            converter.Options.MarginBottom = 20;

            PdfDocument doc = converter.ConvertHtmlString(htmlContent);
            byte[] pdf = doc.Save();
            doc.Close();
            return pdf;
        }
    }
}
