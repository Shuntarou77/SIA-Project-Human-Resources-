<%@ Page Title="Employee Report" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="EmployeeReport.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.EmployeeReport" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Employee Attendance & Performance Report</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            color: #333;
        }

        .report-container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .report-header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 3px solid #A36A66;
        }

        .report-header h1 {
            color: #A36A66;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .report-header p {
            color: #666;
            font-size: 14px;
        }

        .report-section {
            margin-bottom: 40px;
        }

        .section-title {
            color: #A36A66;
            font-size: 24px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: linear-gradient(135deg, #A36A66 0%, #8B5A58 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .summary-card h3 {
            font-size: 14px;
            margin-bottom: 10px;
            opacity: 0.9;
        }

        .summary-card .value {
            font-size: 32px;
            font-weight: bold;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 13px;
        }

        .data-table th {
            background-color: #A36A66;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            border: 1px solid #8B5A58;
        }

        .data-table td {
            padding: 12px;
            border: 1px solid #e0e0e0;
        }

        .data-table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .data-table tbody tr:hover {
            background-color: #f0f0f0;
        }

        .performance-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-excellent {
            background: #10b981;
            color: white;
        }

        .badge-good {
            background: #3b82f6;
            color: white;
        }

        .badge-average {
            background: #f59e0b;
            color: white;
        }

        .badge-poor {
            background: #ef4444;
            color: white;
        }

        .status-present {
            color: #28a745;
            font-weight: 600;
        }

        .status-late {
            color: #ffc107;
            font-weight: 600;
        }

        .status-absent {
            color: #dc3545;
            font-weight: 600;
        }

        .print-button {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #A36A66;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            z-index: 1000;
        }

        .print-button:hover {
            background: #8B5A58;
        }

        @media print {
            body {
                background: white;
                padding: 0;
            }

            .print-button {
                display: none;
            }

            .report-container {
                box-shadow: none;
                padding: 20px;
            }

            .data-table {
                page-break-inside: avoid;
            }
        }

        .chart-container {
            position: relative;
            height: 400px;
            margin-bottom: 30px;
            padding: 20px;
            background: #fafafa;
            border-radius: 10px;
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 30px;
            margin-bottom: 40px;
        }

        @media (max-width: 968px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
        }

        @media print {
            .chart-container {
                page-break-inside: avoid;
                height: 350px;
            }
        }
    </style>
</head>
<body>
    <button class="print-button" onclick="window.print()">Print / Save as PDF</button>
    
    <div class="report-container">
        <div class="report-header">
            <h1>Employee Attendance & Performance Report</h1>
            <p><%= GetManagerDepartment() %> Department — <%= GetReportDateDisplay() %></p>
            <p>Generated on <%= DateTime.Now.ToString("MMMM dd, yyyy 'at' hh:mm tt") %></p>
        </div>

        <!-- Summary Section -->
        <div class="report-section">
            <h2 class="section-title">Summary</h2>
            <div class="summary-grid">
                <div class="summary-card">
                    <h3>Total Employees</h3>
                    <div class="value"><%= GetTeamMembersCount() %></div>
                </div>
                <div class="summary-card">
                    <h3>Present Today</h3>
                    <div class="value"><%= GetPresentCount() %></div>
                </div>
                <div class="summary-card">
                    <h3>Late</h3>
                    <div class="value"><%= GetLateCount() %></div>
                </div>
                <div class="summary-card">
                    <h3>Absent</h3>
                    <div class="value"><%= GetAbsentCount() %></div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="report-section">
            <h2 class="section-title">Visual Analytics</h2>
            <div class="charts-grid">
                <div class="chart-container">
                    <canvas id="attendanceStatusChart"></canvas>
                </div>
                <div class="chart-container">
                    <canvas id="performanceDistributionChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Daily Attendance Section -->
        <div class="report-section">
            <h2 class="section-title">Daily Attendance Log</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>ID</th>
                        <th>Time In</th>
                        <th>Time Out</th>
                        <th>Hours Worked</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (DepartmentEmployees != null && DepartmentEmployees.Count > 0) { %>
                        <% foreach (var employee in GetSortedEmployees()) { %>
                            <% var attendance = GetEmployeeAttendance(employee); %>
                            <% var status = GetAttendanceStatus(employee, attendance); %>
                            <tr>
                                <td><%= employee.FullName %></td>
                                <td><%= employee.EmployeeId %></td>
                                <td><%= FormatTime(attendance?.TimeIn) %></td>
                                <td><%= FormatTime(attendance?.TimeOut) %></td>
                                <td><%= GetHoursWorked(attendance) %></td>
                                <td><span class="<%= GetStatusClass(status) %>"><%= status %></span></td>
                            </tr>
                        <% } %>
                    <% } else { %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 20px;">
                                No employees found in your department.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Performance Summary Section -->
        <div class="report-section">
            <h2 class="section-title">Performance Summary</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>ID</th>
                        <th>Department</th>
                        <th>Attendance Rate (30 days)</th>
                        <th>Performance Score</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (PerformanceData != null && PerformanceData.Count > 0) { %>
                        <% foreach (var perf in PerformanceData.OrderByDescending(p => p.PerformanceScore)) { %>
                            <tr>
                                <td><%= perf.EmployeeName %></td>
                                <td><%= perf.EmployeeId %></td>
                                <td><%= perf.Department %></td>
                                <td><%= perf.AttendanceRate.ToString("F1") %>%</td>
                                <td>
                                    <span class="performance-badge <%= GetPerformanceBadgeClass(perf.PerformanceScore) %>">
                                        <%= perf.PerformanceScore.ToString("F1") %>%
                                    </span>
                                </td>
                                <td><%= GetPerformanceStatus(perf.PerformanceScore) %></td>
                            </tr>
                        <% } %>
                    <% } else { %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 20px;">
                                Performance data not available.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Attendance Status Pie Chart
        const attendanceCtx = document.getElementById('attendanceStatusChart');
        if (attendanceCtx) {
            new Chart(attendanceCtx, {
                type: 'pie',
                data: {
                    labels: ['Present', 'Late', 'Absent'],
                    datasets: [{
                        label: 'Attendance Status',
                        data: [
                            <%= GetPresentCount() %>,
                            <%= GetLateCount() %>,
                            <%= GetAbsentCount() %>
                        ],
                        backgroundColor: [
                            '#28a745',
                            '#ffc107',
                            '#dc3545'
                        ],
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Today\'s Attendance Status',
                            font: {
                                size: 16,
                                weight: 'bold'
                            },
                            color: '#A36A66'
                        },
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 15,
                                font: {
                                    size: 12
                                }
                            }
                        }
                    }
                }
            });
        }

        // Performance Distribution Chart
        const performanceCtx = document.getElementById('performanceDistributionChart');
        if (performanceCtx) {
            new Chart(performanceCtx, {
                type: 'bar',
                data: {
                    labels: ['Excellent (90-100%)', 'Good (75-89%)', 'Average (60-74%)', 'Needs Improvement (<60%)'],
                    datasets: [{
                        label: 'Number of Employees',
                        data: [
                            <%= GetExcellentCount() %>,
                            <%= GetGoodCount() %>,
                            <%= GetAverageCount() %>,
                            <%= GetPoorCount() %>
                        ],
                        backgroundColor: [
                            '#10b981',
                            '#3b82f6',
                            '#f59e0b',
                            '#ef4444'
                        ],
                        borderColor: [
                            '#0d9668',
                            '#2563eb',
                            '#d97706',
                            '#dc2626'
                        ],
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Performance Score Distribution (30 Days)',
                            font: {
                                size: 16,
                                weight: 'bold'
                            },
                            color: '#A36A66'
                        },
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1
                            },
                            title: {
                                display: true,
                                text: 'Number of Employees',
                                font: {
                                    size: 12
                                }
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'Performance Category',
                                font: {
                                    size: 12
                                }
                            }
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>

