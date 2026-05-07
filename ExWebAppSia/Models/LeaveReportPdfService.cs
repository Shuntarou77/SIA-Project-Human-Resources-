using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SelectPdf;

namespace ExWebAppSia.Models
{
    public class LeaveReportPdfService
    {
        public byte[] GenerateLeaveBalanceReport(List<Employee> employees, Dictionary<string, int> balances)
        {
            var html = new StringBuilder();
            html.Append(@"
                <html>
                <head>
                    <style>
                        body { font-family: 'Helvetica', sans-serif; padding: 20px; color: #333; }
                        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #8B4755; padding-bottom: 10px; }
                        .title { font-size: 24px; color: #8B4755; font-weight: bold; }
                        .subtitle { font-size: 14px; color: #666; margin-top: 5px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th { background-color: #8B4755; color: white; padding: 12px; text-align: left; font-size: 12px; }
                        td { padding: 10px; border-bottom: 1px solid #eee; font-size: 11px; }
                        tr:nth-child(even) { background-color: #f9f9f9; }
                        .footer { margin-top: 30px; font-size: 10px; color: #999; text-align: center; }
                        .balance-badge { font-weight: bold; color: #10B981; }
                    </style>
                </head>
                <body>
                    <div class='header'>
                        <div class='title'>Leave Balance Report</div>
                        <div class='subtitle'>Generated on " + DateTime.Now.ToString("MMMM dd, yyyy h:mm tt") + @"</div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Employee ID</th>
                                <th>Full Name</th>
                                <th>Department</th>
                                <th>Position</th>
                                <th style='text-align:center;'>Remaining Leave Credits</th>
                            </tr>
                        </thead>
                        <tbody>");

            foreach (var emp in employees.OrderBy(e => e.LastName))
            {
                int balance = balances.ContainsKey(emp.EmployeeId) ? balances[emp.EmployeeId] : 0;
                html.Append($@"
                    <tr>
                        <td>{emp.EmployeeId}</td>
                        <td>{emp.FullName}</td>
                        <td>{emp.Department}</td>
                        <td>{emp.Role}</td>
                        <td style='text-align:center;'><span class='balance-badge'>{balance} Days</span></td>
                    </tr>");
            }

            html.Append(@"
                        </tbody>
                    </table>
                    <div class='footer'>
                        Sheessentials HRMS - Official Leave Audit Document
                    </div>
                </body>
                </html>");

            return ConvertHtmlToPdf(html.ToString());
        }

        public byte[] GenerateLeaveHistoryReport(List<Leave> leaves)
        {
            var html = new StringBuilder();
            html.Append(@"
                <html>
                <head>
                    <style>
                        body { font-family: 'Helvetica', sans-serif; padding: 20px; color: #333; }
                        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #8B4755; padding-bottom: 10px; }
                        .title { font-size: 24px; color: #8B4755; font-weight: bold; }
                        .subtitle { font-size: 14px; color: #666; margin-top: 5px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th { background-color: #8B4755; color: white; padding: 12px; text-align: left; font-size: 11px; }
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
                        <div class='title'>Leave Request History</div>
                        <div class='subtitle'>Full Archive - Generated on " + DateTime.Now.ToString("MMMM dd, yyyy h:mm tt") + @"</div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Date Filed</th>
                                <th>Employee</th>
                                <th>Leave Type</th>
                                <th>Duration</th>
                                <th>Reason</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>");

            foreach (var leave in leaves.OrderByDescending(l => l.SubmittedDate))
            {
                string statusClass = "status-" + (leave.Status?.ToLower() ?? "pending");
                int duration = (leave.EndDate - leave.StartDate).Days + 1;

                html.Append($@"
                    <tr>
                        <td>{leave.SubmittedDate.ToLocalTime().ToString("MMM dd, yyyy")}</td>
                        <td>{leave.EmployeeName}</td>
                        <td>{leave.LeaveType}</td>
                        <td>{leave.StartDate.ToLocalTime().ToString("MM/dd")} - {leave.EndDate.ToLocalTime().ToString("MM/dd")} ({duration}d)</td>
                        <td style='max-width:200px;'>{leave.Reason}</td>
                        <td><span class='{statusClass}'>{leave.Status}</span></td>
                    </tr>");
            }

            html.Append(@"
                        </tbody>
                    </table>
                    <div class='footer'>
                        Sheessentials HRMS - Confidential Administrative Record
                    </div>
                </body>
                </html>");

            return ConvertHtmlToPdf(html.ToString());
        }

        private byte[] ConvertHtmlToPdf(string htmlContent)
        {
            HtmlToPdf converter = new HtmlToPdf();
            converter.Options.PdfPageSize = PdfPageSize.A4;
            converter.Options.PdfPageOrientation = PdfPageOrientation.Landscape;
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
