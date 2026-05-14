<%@ WebHandler Language="C#" Class="ExportDepartmentReport" %>

using System;
using System.Linq;
using System.Text;
using System.Web;
using System.Threading.Tasks;
using System.Collections.Generic;
using ExWebAppSia.Models;

public class ExportDepartmentReport : HttpTaskAsyncHandler
{
    public override async Task ProcessRequestAsync(HttpContext context)
    {
        try
        {
            var department = context.Request.QueryString["department"];
            var format = context.Request.QueryString["format"] ?? "pdf";
            department = HttpUtility.UrlDecode(department ?? "").Trim();

            // Normalize Department Name for database consistency
            if (department.Equals("Research & Development", StringComparison.OrdinalIgnoreCase) || 
                department.Equals("Research and Development", StringComparison.OrdinalIgnoreCase))
            {
                department = "R&D";
            }
            else if (department.Equals("HR", StringComparison.OrdinalIgnoreCase))
            {
                department = "Human Resources";
            }
            else if (department.Equals("Finance", StringComparison.OrdinalIgnoreCase))
            {
                department = "Finance/Accounting";
            }

            if (string.IsNullOrEmpty(department))
            {
                context.Response.StatusCode = 400;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Department is required.");
                return;
            }

            var employeeService = new EmployeeService();
            var attendanceService = new AttendanceService();
            var otService = new OvertimeService();
            var utService = new UndertimeService();

            var endDate = DateTime.UtcNow.Date;
            var startDate = endDate.AddDays(-29);

            List<Employee> employees;
            string reportTitle = "Department Attendance Audit";
            if (department.Equals("All", StringComparison.OrdinalIgnoreCase) || 
                department.Equals("Company", StringComparison.OrdinalIgnoreCase) ||
                department.Equals("Development Report (All Employees)", StringComparison.OrdinalIgnoreCase))
            {
                employees = await employeeService.GetAllEmployeesAsync();
                department = "Development Report (All Employees)";
                reportTitle = "Company Development Report";
            }
            else
            {
                employees = await employeeService.GetEmployeesByDepartmentAsync(department);
            }

            if (employees == null || employees.Count == 0)
            {
                context.Response.StatusCode = 404;
                context.Response.ContentType = "text/plain";
                context.Response.Write($"No active employees found.");
                return;
            }

            // Fetch data
            var allAttendance = department.Contains("Development Report") 
                ? await attendanceService.GetAllAttendanceAsync(startDate, endDate)
                : await attendanceService.GetDepartmentAttendanceAsync(department, startDate, endDate);
            
            var allOT = await otService.GetAllAsync();
            var approvedOT = allOT.Where(o => o.Status == "Approved" && o.Date >= startDate && o.Date <= endDate).ToList();
            
            var allUT = await utService.GetAllRequestsAsync();
            var approvedUT = allUT.Where(u => u.Status == "Approved" && u.Date >= startDate && u.Date <= endDate).ToList();

            var attendanceMap = allAttendance
                .GroupBy(a => a.EmployeeId)
                .ToDictionary(g => g.Key, g => g.ToList());
                
            var otMap = approvedOT
                .GroupBy(o => o.EmployeeId)
                .ToDictionary(g => g.Key, g => g.Sum(x => x.RequestedHours));
                
            var utMap = approvedUT
                .GroupBy(u => u.EmployeeId)
                .ToDictionary(g => g.Key, g => g.Count());

            int totalWorkingDays = AttendanceService.GetWorkingDaysCount(startDate, endDate);

            var rows = new List<DepartmentEmployeeRow>();
            foreach (var emp in employees)
            {
                attendanceMap.TryGetValue(emp.EmployeeId, out var empAttendance);
                empAttendance = empAttendance ?? new List<Attendance>();

                int daysPresent = empAttendance
                    .Where(a => a.TimeIn.HasValue)
                    .Select(a => a.Date.Date)
                    .Distinct()
                    .Count();

                int daysAbsent = Math.Max(0, totalWorkingDays - daysPresent);
                int daysLate = empAttendance.Count(a => !string.IsNullOrEmpty(a.LateTime));
                
                otMap.TryGetValue(emp.EmployeeId, out var otHours);
                utMap.TryGetValue(emp.EmployeeId, out var utCount);

                decimal attendanceRate = totalWorkingDays == 0 ? 0 : Math.Round((decimal)daysPresent / totalWorkingDays * 100, 1);
                attendanceRate = Math.Min(100, attendanceRate); // Cap at 100%

                decimal performanceScore = 100 - (daysAbsent * 5) - (daysLate * 2) - (utCount * 3) + ((decimal)otHours * 0.5m);
                performanceScore = Math.Max(0, Math.Min(100, performanceScore));

                rows.Add(new DepartmentEmployeeRow
                {
                    EmployeeId = emp.EmployeeId,
                    EmployeeName = emp.FullName,
                    DaysPresent = daysPresent,
                    DaysAbsent = daysAbsent,
                    DaysLate = daysLate,
                    AttendanceRate = attendanceRate,
                    PerformanceScore = performanceScore,
                    OTHours = (double)otHours,
                    UTCount = utCount
                });
            }

            var html = BuildPremiumHtmlReport(department, reportTitle, startDate, endDate, rows, format == "html");

            if (format.ToLower() == "html")
            {
                context.Response.ContentType = "text/html";
                context.Response.Write(html);
                return;
            }

            var pdfService = new PayslipPdfService();
            var pdfBytes = pdfService.GeneratePdfFromHtml(html);
            var fileName = $"Report_{SanitizeFileName(department)}_{DateTime.Now:yyyyMMdd}.pdf";
            
            context.Response.Clear();
            context.Response.ContentType = "application/pdf";
            context.Response.AddHeader("Content-Disposition", $"inline; filename=\"{fileName}\"");
            context.Response.AddHeader("Content-Length", pdfBytes.Length.ToString());
            context.Response.BinaryWrite(pdfBytes);
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("Internal Server Error: " + ex.Message + "\n" + ex.StackTrace);
        }
    }

    private string BuildPremiumHtmlReport(string department, string reportTitle, DateTime start, DateTime end, List<DepartmentEmployeeRow> rows, bool isPreview)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<!DOCTYPE html><html><head><meta charset='UTF-8'>");
        sb.AppendLine("<style>");
        sb.AppendLine(@"
            body { font-family: 'Segoe UI', Arial, sans-serif; padding: " + (isPreview ? "80px 40px 40px" : "40px") + @"; color: #4A3534; background: #fff; }
            .preview-bar { position: fixed; top: 0; left: 0; right: 0; background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); padding: 15px 40px; border-bottom: 2px solid #E8E0DF; display: flex; justify-content: space-between; align-items: center; z-index: 1000; box-shadow: 0 2px 15px rgba(0,0,0,0.05); }
            .preview-msg { color: #A36A66; font-weight: 700; font-size: 14px; display: flex; align-items: center; gap: 10px; }
            .btn-download { background: #A36A66; color: white; border: none; padding: 10px 25px; border-radius: 8px; font-weight: 600; cursor: pointer; text-decoration: none; font-size: 14px; transition: all 0.2s; }
            .btn-download:hover { background: #8B5A58; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(163, 106, 102, 0.3); }

            .header { border-bottom: 3px solid #A36A66; padding-bottom: 20px; margin-bottom: 30px; position: relative; }
            .logo { color: #A36A66; font-size: 28px; font-weight: 800; letter-spacing: -1px; }
            .report-title { font-size: 18px; font-weight: 300; color: #6B4F4E; margin-top: 5px; text-transform: uppercase; letter-spacing: 2px; }
            .dept-name { font-size: 28px; font-weight: 700; color: #A36A66; margin: 15px 0 5px 0; }
            .period { font-size: 13px; color: #9B7D7B; }
            
            .summary-card { background: #F8ECEB; border-radius: 12px; padding: 15px 20px; border-left: 5px solid #A36A66; }
            .summary-label { font-size: 11px; text-transform: uppercase; font-weight: 700; color: #9B7D7B; margin-bottom: 5px; }
            .summary-value { font-size: 24px; font-weight: 800; color: #4A3534; }

            .chart-section { margin: 30px 0; display: flex; align-items: center; gap: 40px; background: #FAF7F7; padding: 25px; border-radius: 15px; }
            .chart-container { position: relative; width: 150px; height: 150px; }
            .chart-legend { flex: 1; }
            .legend-item { display: flex; align-items: center; margin-bottom: 10px; font-size: 14px; }
            .legend-color { width: 12px; height: 12px; border-radius: 3px; margin-right: 10px; }

            table { width: 100%; border-collapse: collapse; margin-top: 10px; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(163,106,102,0.1); }
            th { background: #A36A66; color: white; padding: 14px 10px; text-align: left; font-size: 11px; font-weight: 600; text-transform: uppercase; }
            td { padding: 12px 10px; border-bottom: 1px solid #F0EEEE; font-size: 12px; }
            tr:nth-child(even) { background: #FCFAF9; }
            
            .badge { padding: 4px 10px; border-radius: 20px; font-size: 10px; font-weight: 700; display: inline-block; }
            .badge-perfect { background: #D1FAE5; color: #065F46; }
            .badge-good { background: #DBEAFE; color: #1E40AF; }
            .badge-warning { background: #FEF3C7; color: #92400E; }
            
            .progress-bg { background: #E8E0DF; height: 8px; border-radius: 4px; width: 60px; display: inline-block; vertical-align: middle; margin-right: 8px; }
            .progress-fill { height: 100%; border-radius: 4px; background: #A36A66; }
            .perc { font-weight: 700; color: #A36A66; width: 45px; display: inline-block; }
            
            .footer { margin-top: 40px; font-size: 11px; color: #9B7D7B; text-align: center; border-top: 1px solid #E8E0DF; padding-top: 20px; }
        ");
        sb.AppendLine("</style></head><body>");

        if (isPreview)
        {
            sb.AppendLine("<div class='preview-bar'>");
            sb.AppendLine("  <div class='preview-msg'>");
            sb.AppendLine("    <svg style='width:24px;height:24px;' viewBox='0 0 24 24'><path fill='currentColor' d='M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'/></svg>");
            sb.AppendLine("    Report Preview Mode — Review data before export");
            sb.AppendLine("  </div>");
            string downloadUrl = $"?department={HttpUtility.UrlEncode(department)}&format=pdf";
            sb.AppendLine($"  <a href='{downloadUrl}' class='btn-download'>");
            sb.AppendLine("    <svg style='width:18px;height:18px;vertical-align:middle;margin-right:8px;' viewBox='0 0 24 24'><path fill='currentColor' d='M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z'/></svg>");
            sb.AppendLine("    Download PDF");
            sb.AppendLine("  </a>");
            sb.AppendLine("</div>");
        }

        sb.AppendLine("<div class='header'>");
        sb.AppendLine("<div class='logo'>Sheessentials</div>");
        sb.AppendLine($"<div class='report-title'>{reportTitle}</div>");
        sb.AppendLine($"<div class='dept-name'>{HttpUtility.HtmlEncode(department)}</div>");
        sb.AppendLine($"<div class='period'>Report Period: {start:MMM dd, yyyy} — {end:MMM dd, yyyy}</div>");
        sb.AppendLine("</div>");

        int totalEmployees = rows.Count;
        decimal avgAtt = rows.Count == 0 ? 0 : Math.Round(rows.Average(x => x.AttendanceRate), 1);
        decimal avgPerf = rows.Count == 0 ? 0 : Math.Round(rows.Average(x => x.PerformanceScore), 1);
        double totalOT = rows.Sum(x => x.OTHours);
        int totalUT = rows.Sum(x => x.UTCount);

        sb.AppendLine("<div style='display:table; width:100%; border-spacing: 15px 0; margin-left: -15px;'>");
        sb.AppendLine($"<div style='display:table-cell;'><div class='summary-card'><div class='summary-label'>Headcount</div><div class='summary-value'>{totalEmployees}</div></div></div>");
        sb.AppendLine($"<div style='display:table-cell;'><div class='summary-card'><div class='summary-label'>Team Attendance</div><div class='summary-value'>{avgAtt}%</div></div></div>");
        sb.AppendLine($"<div style='display:table-cell;'><div class='summary-card'><div class='summary-label'>Total OT Hours</div><div class='summary-value'>{totalOT:F1}</div></div></div>");
        sb.AppendLine($"<div style='display:table-cell;'><div class='summary-card'><div class='summary-label'>Undertime Requests</div><div class='summary-value'>{totalUT}</div></div></div>");
        sb.AppendLine("</div>");

        // Graphical Section
        sb.AppendLine("<div class='chart-section'>");
        sb.AppendLine("<div class='chart-container'>");
        
        // SVG Pie/Donut Chart for Overall Attendance
        double radius = 15.91549430918954;
        double circumference = 2 * Math.PI * radius; // 100
        double dashArray = (double)avgAtt;
        double dashOffset = 100 - dashArray;

        sb.AppendLine("<svg viewBox='0 0 42 42' style='width: 150px; height: 150px; transform: rotate(-90deg);'>");
        sb.AppendLine("  <circle cx='21' cy='21' r='15.91549430918954' fill='transparent' stroke='#E8E0DF' stroke-width='3'></circle>");
        sb.AppendLine($"  <circle cx='21' cy='21' r='15.91549430918954' fill='transparent' stroke='#A36A66' stroke-width='4' stroke-dasharray='{dashArray} {dashOffset}' stroke-dashoffset='0'></circle>");
        sb.AppendLine("</svg>");
        sb.AppendLine("<div style='position:absolute; top:50%; left:50%; transform:translate(-50%, -50%); text-align:center;'>");
        sb.AppendLine($"<div style='font-size:24px; font-weight:800; color:#A36A66;'>{avgAtt}%</div>");
        sb.AppendLine("<div style='font-size:10px; color:#9B7D7B; text-transform:uppercase;'>Present</div>");
        sb.AppendLine("</div>");
        sb.AppendLine("</div>");

        sb.AppendLine("<div class='chart-legend'>");
        sb.AppendLine("<h3 style='margin-top:0; color:#4A3534;'>Attendance Insight</h3>");
        sb.AppendLine("<p style='font-size:14px; margin-bottom:15px;'>Visual breakdown of department-wide attendance and efficiency data for the last 30 working days.</p>");
        sb.AppendLine("<div class='legend-item'><div class='legend-color' style='background:#A36A66;'></div><span>Team Presence Rate (" + avgAtt + "%)</span></div>");
        sb.AppendLine("<div class='legend-item'><div class='legend-color' style='background:#E8E0DF;'></div><span>Absence/Leave Vacancy (" + (100 - avgAtt) + "%)</span></div>");
        sb.AppendLine("</div>");
        sb.AppendLine("</div>");

        sb.AppendLine("<table><thead><tr>");
        sb.AppendLine("<th>ID</th><th>Employee Name</th><th>Present</th><th>Late</th><th>Absent</th><th>OT Hrs</th><th>UT</th><th>Att. Rate</th><th>Score</th>");
        sb.AppendLine("</tr></thead><tbody>");

        foreach (var r in rows.OrderByDescending(x => x.AttendanceRate))
        {
            string scoreBadge = "badge-good";
            if (r.PerformanceScore >= 95) scoreBadge = "badge-perfect";
            else if (r.PerformanceScore < 85) scoreBadge = "badge-warning";

            sb.AppendLine("<tr>");
            sb.AppendLine($"<td>{HttpUtility.HtmlEncode(r.EmployeeId)}</td>");
            sb.AppendLine($"<td style='font-weight:600;'>{HttpUtility.HtmlEncode(r.EmployeeName)}</td>");
            sb.AppendLine($"<td>{r.DaysPresent}d</td>");
            sb.AppendLine($"<td><span style='color:{(r.DaysLate > 0 ? "#EF4444" : "inherit")}'>{r.DaysLate}</span></td>");
            sb.AppendLine($"<td>{r.DaysAbsent}</td>");
            sb.AppendLine($"<td style='color:#059669; font-weight:600;'>{r.OTHours:F1}</td>");
            sb.AppendLine($"<td style='color:#D97706;'>{r.UTCount}</td>");
            sb.AppendLine($"<td>");
            sb.AppendLine($"<div class='progress-bg'><div class='progress-fill' style='width:{r.AttendanceRate}%'></div></div>");
            sb.AppendLine($"<span class='perc'>{r.AttendanceRate:F1}%</span>");
            sb.AppendLine($"</td>");
            sb.AppendLine($"<td><span class='badge {scoreBadge}'>{r.PerformanceScore:F0}</span></td>");
            sb.AppendLine("</tr>");
        }
        sb.AppendLine("</tbody></table>");

        sb.AppendLine("<div class='footer'>");
        sb.AppendLine($"Generated by Sheessentials HR System on {DateTime.Now:MMMM dd, yyyy HH:mm}");
        sb.AppendLine("<br/>Confidential Personnel Development Report");
        sb.AppendLine("</div>");

        sb.AppendLine("</body></html>");
        return sb.ToString();
    }

    private string SanitizeFileName(string name)
    {
        foreach (var c in System.IO.Path.GetInvalidFileNameChars())
            name = name.Replace(c, '_');
        return name.Replace(" ", "_");
    }

    private class DepartmentEmployeeRow
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public int DaysPresent { get; set; }
        public int DaysAbsent { get; set; }
        public int DaysLate { get; set; }
        public double OTHours { get; set; }
        public int UTCount { get; set; }
        public decimal AttendanceRate { get; set; }
        public decimal PerformanceScore { get; set; }
    }

    public override bool IsReusable => false;
}
