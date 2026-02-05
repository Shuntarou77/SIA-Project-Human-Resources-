using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage
{
    public partial class EmployeeReport : System.Web.UI.Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();
        private readonly AttendanceService _attendanceService = new AttendanceService();
        private readonly EmployeeConcernService _concernService = new EmployeeConcernService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(GenerateReport));
            }
        }

        private async Task GenerateReport()
        {
            try
            {
                var employees = await _employeeService.GetAllEmployeesAsync();
                var endDate = DateTime.UtcNow;
                var startDate = endDate.AddDays(-30); // Last 30 days

                // Get attendance data for all employees
                var attendanceData = new Dictionary<string, List<Attendance>>();
                var employeeAttendanceStats = new Dictionary<string, AttendanceStats>();

                foreach (var employee in employees)
                {
                    var attendanceRecords = await _attendanceService.GetEmployeeAttendanceAsync(
                        employee.EmployeeId, startDate, endDate);
                    attendanceData[employee.EmployeeId] = attendanceRecords;
                    
                    // Calculate attendance stats
                    var stats = CalculateAttendanceStats(attendanceRecords, startDate, endDate);
                    employeeAttendanceStats[employee.EmployeeId] = stats;
                }

                // Get performance data (based on concerns and attendance)
                var performanceData = await CalculatePerformanceData(employees, employeeAttendanceStats);

                // Generate report data
                var reportData = GenerateReportData(employees, attendanceData, employeeAttendanceStats, performanceData, startDate, endDate);

                // Output JSON data to page
                litReportData.Text = reportData;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating report: {ex.Message}");
                litReportData.Text = "{}";
            }
        }

        private AttendanceStats CalculateAttendanceStats(List<Attendance> records, DateTime startDate, DateTime endDate)
        {
            var stats = new AttendanceStats();
            
            // Count only workdays (Monday-Friday) in the period
            var workdays = 0;
            var presentDays = 0;
            var currentDate = startDate.Date;
            
            while (currentDate <= endDate.Date)
            {
                // Only count weekdays (Monday = 1, Friday = 5)
                if (currentDate.DayOfWeek >= DayOfWeek.Monday && currentDate.DayOfWeek <= DayOfWeek.Friday)
                {
                    workdays++;
                    
                    // Check if there's an attendance record for this workday
                    var hasRecord = records.Any(r => r.Date.Date == currentDate && r.TimeIn != null);
                    if (hasRecord)
                    {
                        presentDays++;
                    }
                }
                currentDate = currentDate.AddDays(1);
            }
            
            var absentDays = workdays - presentDays;
            
            stats.PresentDays = presentDays;
            stats.AbsentDays = absentDays;
            stats.TotalDays = workdays;
            stats.AttendanceRate = workdays > 0 ? (double)presentDays / workdays * 100 : 0;
            
            // Calculate late arrivals (assuming 9 AM is standard start time)
            var lateCount = records.Count(r => r.TimeIn != null && 
                r.TimeIn.Value.ToLocalTime().Hour >= 9 && 
                r.TimeIn.Value.ToLocalTime().Minute > 0);
            stats.LateCount = lateCount;
            
            return stats;
        }

        private async Task<Dictionary<string, double>> CalculatePerformanceData(
            List<Employee> employees, 
            Dictionary<string, AttendanceStats> attendanceStats)
        {
            var performance = new Dictionary<string, double>();

            foreach (var employee in employees)
            {
                // Base performance on attendance (70%) and concerns (30%)
                var attendanceRate = attendanceStats.ContainsKey(employee.EmployeeId) 
                    ? attendanceStats[employee.EmployeeId].AttendanceRate 
                    : 0;

                // Get concerns for this employee
                var concerns = await _concernService.GetConcernsByEmployeeIdAsync(employee.Id);
                var activeConcerns = concerns.Count(c => c.Status != "Resolved" && c.Status != "Closed");
                
                // Calculate performance score
                // Attendance contributes 70%, concerns reduce score
                var baseScore = attendanceRate * 0.7;
                var concernPenalty = Math.Min(activeConcerns * 5, 30); // Max 30 point penalty
                var performanceScore = Math.Max(0, baseScore - concernPenalty);

                // Add bonus for good attendance (no lates, high attendance rate)
                if (attendanceStats.ContainsKey(employee.EmployeeId))
                {
                    var stats = attendanceStats[employee.EmployeeId];
                    if (stats.LateCount == 0 && attendanceRate >= 95)
                    {
                        performanceScore = Math.Min(100, performanceScore + 10);
                    }
                }

                performance[employee.EmployeeId] = Math.Round(performanceScore, 1);
            }

            return performance;
        }

        private string GenerateReportData(
            List<Employee> employees,
            Dictionary<string, List<Attendance>> attendanceData,
            Dictionary<string, AttendanceStats> attendanceStats,
            Dictionary<string, double> performanceData,
            DateTime startDate,
            DateTime endDate)
        {
            var sb = new StringBuilder();
            sb.Append("{");

            // Summary data
            var totalEmployees = employees.Count;
            var totalPresentDays = attendanceStats.Values.Sum(s => s.PresentDays);
            var totalAbsentDays = attendanceStats.Values.Sum(s => s.AbsentDays);
            var avgAttendanceRate = attendanceStats.Values.Any() 
                ? attendanceStats.Values.Average(s => s.AttendanceRate) 
                : 0;
            var avgPerformance = performanceData.Values.Any() 
                ? performanceData.Values.Average() 
                : 0;

            sb.AppendFormat("\"TotalEmployees\": {0},", totalEmployees);
            sb.AppendFormat("\"TotalPresentDays\": {0},", totalPresentDays);
            sb.AppendFormat("\"TotalAbsentDays\": {0},", totalAbsentDays);
            sb.AppendFormat("\"AverageAttendanceRate\": {0},", Math.Round(avgAttendanceRate, 1));
            sb.AppendFormat("\"AveragePerformance\": {0},", Math.Round(avgPerformance, 1));

            // Attendance trend data (last 30 days)
            var attendanceLabels = new List<string>();
            var presentData = new List<int>();
            var absentData = new List<int>();

            for (int i = 29; i >= 0; i--)
            {
                var date = endDate.AddDays(-i).Date;
                attendanceLabels.Add(date.ToString("MMM dd"));
                
                var presentCount = 0;
                var absentCount = 0;
                
                foreach (var emp in employees)
                {
                    if (attendanceData.ContainsKey(emp.EmployeeId))
                    {
                        var hasRecord = attendanceData[emp.EmployeeId]
                            .Any(a => a.Date.Date == date && a.TimeIn != null);
                        if (hasRecord)
                            presentCount++;
                        else
                            absentCount++;
                    }
                    else
                    {
                        absentCount++;
                    }
                }
                
                presentData.Add(presentCount);
                absentData.Add(absentCount);
            }

            sb.Append("\"AttendanceLabels\": [");
            sb.Append(string.Join(",", attendanceLabels.Select(l => "\"" + l + "\"")));
            sb.Append("],");

            sb.Append("\"AttendancePresentData\": [");
            sb.Append(string.Join(",", presentData));
            sb.Append("],");

            sb.Append("\"AttendanceAbsentData\": [");
            sb.Append(string.Join(",", absentData));
            sb.Append("],");

            // Department attendance data
            var deptGroups = employees.GroupBy(e => e.Department ?? "Unknown");
            var deptLabels = new List<string>();
            var deptAttendanceData = new List<double>();

            foreach (var deptGroup in deptGroups)
            {
                deptLabels.Add(deptGroup.Key);
                var deptEmployees = deptGroup.ToList();
                var deptAttendanceRates = deptEmployees
                    .Where(e => attendanceStats.ContainsKey(e.EmployeeId))
                    .Select(e => attendanceStats[e.EmployeeId].AttendanceRate)
                    .ToList();
                
                var avgDeptRate = deptAttendanceRates.Any() 
                    ? deptAttendanceRates.Average() 
                    : 0;
                deptAttendanceData.Add(Math.Round(avgDeptRate, 1));
            }

            sb.Append("\"DepartmentLabels\": [");
            sb.Append(string.Join(",", deptLabels.Select(l => "\"" + l.Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"")));
            sb.Append("],");

            sb.Append("\"DepartmentAttendanceData\": [");
            sb.Append(string.Join(",", deptAttendanceData));
            sb.Append("],");

            // Performance distribution
            var excellent = performanceData.Values.Count(p => p >= 90);
            var good = performanceData.Values.Count(p => p >= 75 && p < 90);
            var average = performanceData.Values.Count(p => p >= 60 && p < 75);
            var poor = performanceData.Values.Count(p => p < 60);

            sb.AppendFormat("\"PerformanceDistribution\": [{0}, {1}, {2}, {3}],", 
                excellent, good, average, poor);

            // Employee details
            sb.Append("\"EmployeeDetails\": [");
            var employeeDetails = new List<string>();

            foreach (var employee in employees.OrderBy(e => e.Department).ThenBy(e => e.FullName))
            {
                var attendanceRate = attendanceStats.ContainsKey(employee.EmployeeId) 
                    ? attendanceStats[employee.EmployeeId].AttendanceRate 
                    : 0;
                var performance = performanceData.ContainsKey(employee.EmployeeId) 
                    ? performanceData[employee.EmployeeId] 
                    : 0;

                var detail = string.Format(
                    "{{\"EmployeeId\": \"{0}\", \"Name\": \"{1}\", \"Department\": \"{2}\", \"AttendanceRate\": {3}, \"Performance\": {4}}}",
                    (employee.EmployeeId ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r"),
                    (employee.FullName ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r"),
                    (employee.Department ?? "Unknown").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r"),
                    Math.Round(attendanceRate, 1),
                    performance
                );
                employeeDetails.Add(detail);
            }

            sb.Append(string.Join(",", employeeDetails));
            sb.Append("]");

            sb.Append("}");
            return sb.ToString();
        }

        private class AttendanceStats
        {
            public int PresentDays { get; set; }
            public int AbsentDays { get; set; }
            public int TotalDays { get; set; }
            public double AttendanceRate { get; set; }
            public int LateCount { get; set; }
        }
    }
}

