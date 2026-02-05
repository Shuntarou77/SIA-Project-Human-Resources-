<%@ WebHandler Language="C#" Class="ExportDepartmentReport" %>

using System;
using System.Linq;
using System.Text;
using System.Web;
using ExWebAppSia.Models;
using System.Collections.Generic;

public class ExportDepartmentReport : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        try
        {
            var department = context.Request.QueryString["department"] ?? "";
            department = HttpUtility.UrlDecode(department ?? "").Trim();

            if (string.IsNullOrEmpty(department))
            {
                context.Response.StatusCode = 400;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Department is required.");
                return;
            }

            var employeeService = new EmployeeService();
            var attendanceService = new AttendanceService();

            // Past 30 days window
            var endDate = DateTime.UtcNow.Date;
            var startDate = endDate.AddDays(-29);

            // Get employees in department
            var employees = employeeService.GetEmployeesByDepartmentAsync(department)
                .ConfigureAwait(false)
                .GetAwaiter()
                .GetResult() ?? new List<Employee>();

            // Build attendance and simple "performance" stats
            var random = new Random();
            var rows = new List<DepartmentEmployeeRow>();

            foreach (var emp in employees)
            {
                var attendance = attendanceService.GetEmployeeAttendanceAsync(emp.EmployeeId, startDate, endDate)
                    .ConfigureAwait(false)
                    .GetAwaiter()
                    .GetResult() ?? new List<Attendance>();

                int totalWorkingDays = (int)Enumerable.Range(0, 30)
                    .Select(i => startDate.AddDays(i))
                    .Count(d => d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday);

                int daysPresent = attendance
                    .Where(a => a.TimeIn.HasValue)
                    .Select(a => a.Date.Date)
                    .Distinct()
                    .Count();

                int daysAbsent = Math.Max(0, totalWorkingDays - daysPresent);

                // Use late count as simple performance proxy
                int daysLate = attendance
                    .Where(a => a.TimeIn.HasValue)
                    .Count(a =>
                    {
                        var localIn = a.TimeIn.Value.ToLocalTime();
                        return localIn.Hour > 8 || (localIn.Hour == 8 && localIn.Minute > 0);
                    });

                decimal attendanceRate = totalWorkingDays == 0
                    ? 0
                    : Math.Round((decimal)daysPresent / totalWorkingDays * 100, 1);

                decimal performanceScore = Math.Max(0, 100 - (daysLate * 3)); // simple heuristic

                rows.Add(new DepartmentEmployeeRow
                {
                    EmployeeName = emp.FullName,
                    EmployeeId = emp.EmployeeId,
                    DaysPresent = daysPresent,
                    DaysAbsent = daysAbsent,
                    DaysLate = daysLate,
                    AttendanceRate = attendanceRate,
                    PerformanceScore = performanceScore
                });
            }

            var html = BuildHtmlReport(department, startDate, endDate, rows);

            var pdfService = new PayslipPdfService();
            var pdfBytes = pdfService.GeneratePdfFromHtml(html);

            var fileName = $"DeptReport-{SanitizeFileName(department)}-{DateTime.Now:yyyyMMddHHmm}.pdf";
            context.Response.Clear();
            context.Response.ContentType = "application/pdf";
            // Inline so browser tries to render in the new tab
            context.Response.AddHeader("Content-Disposition", $"inline; filename=\"{fileName}\"");
            context.Response.AddHeader("Content-Length", pdfBytes.Length.ToString());
            context.Response.BinaryWrite(pdfBytes);
            context.Response.Flush();
            context.Response.End();
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("Error generating report: " + ex.Message);
        }
    }

    public bool IsReusable => false;

    private static string BuildHtmlReport(string department, DateTime start, DateTime end, List<DepartmentEmployeeRow> rows)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Department Report</title>");
        sb.AppendLine("<style>");
        sb.AppendLine(@"
            body { font-family: 'Segoe UI', Arial, sans-serif; margin: 40px; color:#333; }
            h1 { color:#A36A66; margin-bottom:4px; }
            h2 { color:#5C4F4E; margin-top:0; }
            .period { color:#666; margin-bottom:20px; }
            table { width:100%; border-collapse:collapse; margin-top:20px; }
            th, td { padding:8px; font-size:11px; }
            th { background:#F3E4E3; color:#5C4F4E; text-align:left; }
            tr:nth-child(even) td { background:#FAF5F5; }
            .bar-container { width:100%; background:#F3F4F6; border-radius:4px; height:10px; }
            .bar { height:10px; border-radius:4px; background:linear-gradient(90deg,#A36A66,#C49A99); }
            .bar-perf { background:linear-gradient(90deg,#16A34A,#4ADE80); }
            .metric { font-size:11px; color:#555; }
            .summary-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-top:20px; }
            .summary-card { padding:10px 12px; border-radius:8px; background:#F9FAFB; border:1px solid #E5E7EB; }
            .summary-label { font-size:10px; color:#6B7280; text-transform:uppercase; letter-spacing:.05em; }
            .summary-value { font-size:16px; font-weight:600; color:#111827; margin-top:4px; }
        ");
        sb.AppendLine("</style></head><body>");

        sb.AppendLine("<h1>Department Attendance & Performance Report</h1>");
        sb.AppendLine($"<h2>{HttpUtility.HtmlEncode(department)}</h2>");
        sb.AppendLine($"<div class='period'>Period: {start.ToLocalTime():MMM dd, yyyy} - {end.ToLocalTime():MMM dd, yyyy}</div>");

        // Summary cards
        int employeeCount = rows.Count;
        decimal avgAttendance = rows.Count == 0 ? 0 : Math.Round(rows.Average(r => r.AttendanceRate), 1);
        decimal avgPerformance = rows.Count == 0 ? 0 : Math.Round(rows.Average(r => r.PerformanceScore), 1);

        sb.AppendLine("<div class='summary-grid'>");
        sb.AppendLine($"<div class='summary-card'><div class='summary-label'>Employees</div><div class='summary-value'>{employeeCount}</div></div>");
        sb.AppendLine($"<div class='summary-card'><div class='summary-label'>Avg Attendance</div><div class='summary-value'>{avgAttendance}%</div></div>");
        sb.AppendLine($"<div class='summary-card'><div class='summary-label'>Avg Performance</div><div class='summary-value'>{avgPerformance}/100</div></div>");
        sb.AppendLine("</div>");

        // Table
        sb.AppendLine("<table><thead><tr>");
        sb.AppendLine("<th>Employee ID</th><th>Name</th><th>Present</th><th>Absent</th><th>Late</th><th>Attendance %</th><th>Attendance Graph</th><th>Performance</th><th>Performance Graph</th>");
        sb.AppendLine("</tr></thead><tbody>");

        foreach (var r in rows.OrderByDescending(x => x.AttendanceRate))
        {
            int attWidth = (int)Math.Min(100, Math.Max(0, r.AttendanceRate));
            int perfWidth = (int)Math.Min(100, Math.Max(0, r.PerformanceScore));

            sb.AppendLine("<tr>");
            sb.AppendLine($"<td>{HttpUtility.HtmlEncode(r.EmployeeId)}</td>");
            sb.AppendLine($"<td>{HttpUtility.HtmlEncode(r.EmployeeName)}</td>");
            sb.AppendLine($"<td>{r.DaysPresent}</td>");
            sb.AppendLine($"<td>{r.DaysAbsent}</td>");
            sb.AppendLine($"<td>{r.DaysLate}</td>");
            sb.AppendLine($"<td>{r.AttendanceRate:F1}%</td>");
            sb.AppendLine("<td><div class='bar-container'><div class='bar' style='width:" + attWidth + "%;'></div></div></td>");
            sb.AppendLine($"<td class='metric'>{r.PerformanceScore:F0}/100</td>");
            sb.AppendLine("<td><div class='bar-container'><div class='bar bar-perf' style='width:" + perfWidth + "%;'></div></div></td>");
            sb.AppendLine("</tr>");
        }

        sb.AppendLine("</tbody></table>");
        sb.AppendLine("</body></html>");
        return sb.ToString();
    }

    private static string SanitizeFileName(string name)
    {
        foreach (var c in System.IO.Path.GetInvalidFileNameChars())
        {
            name = name.Replace(c, '-');
        }
        return name;
    }

    private class DepartmentEmployeeRow
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public int DaysPresent { get; set; }
        public int DaysAbsent { get; set; }
        public int DaysLate { get; set; }
        public decimal AttendanceRate { get; set; }
        public decimal PerformanceScore { get; set; }
    }
}


