using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// PayrollDiagnosticService - System diagnostic and validation tool
    /// Provides comprehensive analysis of payroll system health and data integrity
    /// </summary>
    public class PayrollDiagnosticService
    {
        private readonly IMongoCollection<User> _usersCollection;
        private readonly IMongoCollection<Employee> _employeesCollection;
        private readonly IMongoCollection<PayrollConfiguration> _configsCollection;
        private readonly IMongoCollection<Attendance> _attendanceCollection;
        private readonly IMongoCollection<PayRun> _payRunsCollection;

        public PayrollDiagnosticService()
        {
            var database = MongoDBHelper.GetDatabase();
            _usersCollection = database.GetCollection<User>("Users");
            _employeesCollection = database.GetCollection<Employee>("Employees");
            _configsCollection = database.GetCollection<PayrollConfiguration>("PayrollConfigurations");
            _attendanceCollection = database.GetCollection<Attendance>("Attendance");
            _payRunsCollection = database.GetCollection<PayRun>("PayRuns");
        }

        /// <summary>
        /// Run comprehensive payroll system diagnostic
        /// </summary>
        public async Task<PayrollDiagnosticResult> RunComprehensiveDiagnosticAsync()
        {
            var result = new PayrollDiagnosticResult
            {
                DiagnosticDate = DateTime.UtcNow,
                Status = "Running..."
            };

            try
            {
                System.Diagnostics.Debug.WriteLine("?? Starting payroll system diagnostic...");

                // 1. Count Users
                result.TotalUsers = await _usersCollection.CountDocumentsAsync(Builders<User>.Filter.Empty);
                result.UsersWithEmployeeRole = await _usersCollection.CountDocumentsAsync(
                    Builders<User>.Filter.Eq("Role", "Employee")
                );

                // 2. Count Employees
                result.TotalEmployees = await _employeesCollection.CountDocumentsAsync(Builders<Employee>.Filter.Empty);
                result.ActiveEmployees = await _employeesCollection.CountDocumentsAsync(
                    Builders<Employee>.Filter.Eq("IsActive", true)
                );

                // 3. Count Payroll Configurations
                result.PayrollConfigurations = await _configsCollection.CountDocumentsAsync(
                    Builders<PayrollConfiguration>.Filter.Empty
                );
                result.ActivePayrollConfigurations = await _configsCollection.CountDocumentsAsync(
                    Builders<PayrollConfiguration>.Filter.Eq("IsActive", true)
                );

                // 4. Count Attendance Records
                result.AttendanceRecords = await _attendanceCollection.CountDocumentsAsync(Builders<Attendance>.Filter.Empty);

                // 5. Count Pay Runs
                result.PayRuns = await _payRunsCollection.CountDocumentsAsync(Builders<PayRun>.Filter.Empty);

                // 6. Find employees without payroll configurations
                var allEmployees = await _employeesCollection.Find(
                    Builders<Employee>.Filter.Eq("IsActive", true)
                ).ToListAsync();

                var configuredEmployeeIds = await _configsCollection.Find(
                    Builders<PayrollConfiguration>.Filter.Eq("IsActive", true)
                ).Project(c => c.EmployeeId).ToListAsync();

                result.EmployeesWithoutConfig = allEmployees
                    .Where(e => !configuredEmployeeIds.Contains(e.Id))
                    .Select(e => new EmployeeDiagnostic
                    {
                        EmployeeId = e.Id,
                        EmployeeName = e.FullName,
                        EmployeeNumber = e.EmployeeId,
                        Department = e.Department,
                        Issue = "Missing PayrollConfiguration"
                    }).ToList();

                // 7. Check for recent attendance data
                var oneMonthAgo = DateTime.UtcNow.AddMonths(-1);
                result.RecentAttendanceRecords = await _attendanceCollection.CountDocumentsAsync(
                    Builders<Attendance>.Filter.Gte("Date", oneMonthAgo)
                );

                // 8. Check system status
                result.Status = DetermineSystemStatus(result);
                result.Recommendations = GenerateRecommendations(result);

                System.Diagnostics.Debug.WriteLine($"? Diagnostic completed. Status: {result.Status}");
                return result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"? Diagnostic failed: {ex.Message}");
                result.Status = "Error";
                result.ErrorMessage = ex.Message;
                return result;
            }
        }

        /// <summary>
        /// Get quick system health status
        /// </summary>
        public async Task<string> GetSystemHealthStatusAsync()
        {
            try
            {
                var hasEmployees = await _employeesCollection.CountDocumentsAsync(Builders<Employee>.Filter.Empty) > 0;
                var hasConfigs = await _configsCollection.CountDocumentsAsync(Builders<PayrollConfiguration>.Filter.Empty) > 0;
                var hasAttendance = await _attendanceCollection.CountDocumentsAsync(Builders<Attendance>.Filter.Empty) > 0;

                if (!hasEmployees) return "No Employees";
                if (!hasConfigs) return "Missing Configs";
                if (!hasAttendance) return "No Attendance";

                return "Operational";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"? Health check failed: {ex.Message}");
                return "Error";
            }
        }

        /// <summary>
        /// Validate payroll readiness for specific employees
        /// </summary>
        public async Task<PayrollValidationResult> ValidatePayrollReadinessAsync(List<string> employeeIds, DateTime startDate, DateTime endDate)
        {
            var result = new PayrollValidationResult
            {
                ValidationDate = DateTime.UtcNow,
                PeriodStart = startDate,
                PeriodEnd = endDate,
                IsReady = false
            };

            try
            {
                var issues = new List<string>();

                // Check each employee
                foreach (var employeeId in employeeIds)
                {
                    // 1. Check if employee exists and is active
                    var employee = await _employeesCollection.Find(
                        Builders<Employee>.Filter.And(
                            Builders<Employee>.Filter.Eq("_id", employeeId),
                            Builders<Employee>.Filter.Eq("IsActive", true)
                        )
                    ).FirstOrDefaultAsync();

                    if (employee == null)
                    {
                        issues.Add($"Employee {employeeId} not found or inactive");
                        continue;
                    }

                    // 2. Check if payroll configuration exists
                    var config = await _configsCollection.Find(
                        Builders<PayrollConfiguration>.Filter.And(
                            Builders<PayrollConfiguration>.Filter.Eq("EmployeeId", employeeId),
                            Builders<PayrollConfiguration>.Filter.Eq("IsActive", true)
                        )
                    ).FirstOrDefaultAsync();

                    if (config == null)
                    {
                        issues.Add($"Employee {employee.FullName} ({employee.EmployeeId}) missing payroll configuration");
                        continue;
                    }

                    // 3. Check if attendance data exists for the period
                    var attendanceCount = await _attendanceCollection.CountDocumentsAsync(
                        Builders<Attendance>.Filter.And(
                            Builders<Attendance>.Filter.Eq("EmployeeId", employeeId),
                            Builders<Attendance>.Filter.Gte("Date", startDate),
                            Builders<Attendance>.Filter.Lte("Date", endDate)
                        )
                    );

                    if (attendanceCount == 0)
                    {
                        issues.Add($"Employee {employee.FullName} has no attendance data for the selected period");
                    }
                }

                result.Issues = issues;
                result.IsReady = issues.Count == 0;
                result.Status = result.IsReady ? "Ready" : "Issues Found";

                return result;
            }
            catch (Exception ex)
            {
                result.Status = "Error";
                result.Issues = new List<string> { $"Validation error: {ex.Message}" };
                return result;
            }
        }

        private string DetermineSystemStatus(PayrollDiagnosticResult result)
        {
            if (result.TotalEmployees == 0)
                return "No Employees";

            if (result.PayrollConfigurations == 0)
                return "Missing Configurations";

            if (result.EmployeesWithoutConfig.Count > 0)
                return $"Incomplete Setup ({result.EmployeesWithoutConfig.Count} employees missing config)";

            if (result.AttendanceRecords == 0)
                return "No Attendance Data";

            if (result.RecentAttendanceRecords == 0)
                return "Outdated Attendance";

            return "Operational";
        }

        private List<string> GenerateRecommendations(PayrollDiagnosticResult result)
        {
            var recommendations = new List<string>();

            if (result.TotalEmployees == 0)
            {
                recommendations.Add("Add employees to the system using Employee Management");
            }

            if (result.EmployeesWithoutConfig.Count > 0)
            {
                recommendations.Add($"Create payroll configurations for {result.EmployeesWithoutConfig.Count} employees using the Configuration tab");
                recommendations.Add("Go to Payroll Configuration ? Add New Configuration");
            }

            if (result.RecentAttendanceRecords == 0)
            {
                recommendations.Add("Import or add attendance data for the current pay period");
                recommendations.Add("Use Attendance Management to add employee attendance");
            }

            if (result.PayRuns == 0)
            {
                recommendations.Add("System is ready for first payroll run");
                recommendations.Add("Use Processing tab to generate payroll");
            }

            if (recommendations.Count == 0)
            {
                recommendations.Add("System is fully operational");
                recommendations.Add("You can proceed with payroll processing");
            }

            return recommendations;
        }
    }

    /// <summary>
    /// Payroll diagnostic result model
    /// </summary>
    public class PayrollDiagnosticResult
    {
        public DateTime DiagnosticDate { get; set; }
        public string Status { get; set; }
        public string ErrorMessage { get; set; }

        // Statistics
        public long TotalUsers { get; set; }
        public long UsersWithEmployeeRole { get; set; }
        public long TotalEmployees { get; set; }
        public long ActiveEmployees { get; set; }
        public long PayrollConfigurations { get; set; }
        public long ActivePayrollConfigurations { get; set; }
        public long AttendanceRecords { get; set; }
        public long RecentAttendanceRecords { get; set; }
        public long PayRuns { get; set; }

        // Issues
        public List<EmployeeDiagnostic> EmployeesWithoutConfig { get; set; } = new List<EmployeeDiagnostic>();
        public List<string> Recommendations { get; set; } = new List<string>();
    }

    /// <summary>
    /// Employee diagnostic information
    /// </summary>
    public class EmployeeDiagnostic
    {
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string EmployeeNumber { get; set; }
        public string Department { get; set; }
        public string Issue { get; set; }
    }

    /// <summary>
    /// Payroll validation result
    /// </summary>
    public class PayrollValidationResult
    {
        public DateTime ValidationDate { get; set; }
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public bool IsReady { get; set; }
        public string Status { get; set; }
        public List<string> Issues { get; set; } = new List<string>();
    }
}