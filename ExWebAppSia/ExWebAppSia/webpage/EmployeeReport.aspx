<%@ Page Title="Employee Report" Language="C#" AutoEventWireup="true" Async="true" CodeBehind="EmployeeReport.aspx.cs" Inherits="ExWebAppSia.webpage.EmployeeReport" %>

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
            border-bottom: 3px solid #8B4755;
        }

        .report-header h1 {
            color: #8B4755;
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
            color: #8B4755;
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
            background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
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

        .chart-container {
            position: relative;
            height: 400px;
            margin-bottom: 30px;
            padding: 20px;
            background: #fafafa;
            border-radius: 10px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .data-table th,
        .data-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }

        .data-table th {
            background-color: #8B4755;
            color: white;
            font-weight: 600;
        }

        .data-table tr:hover {
            background-color: #f5f5f5;
        }

        .print-button {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 24px;
            background: #8B4755;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            z-index: 1000;
        }

        .print-button:hover {
            background: #9B5B65;
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

            .chart-container {
                page-break-inside: avoid;
            }
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
    </style>
</head>
<body>
    <button class="print-button" onclick="window.print()">Print / Save as PDF</button>
    
    <div class="report-container">
        <div class="report-header">
            <h1>Employee Attendance & Performance Report</h1>
            <p>Generated on <span id="reportDate"></span></p>
        </div>

        <!-- Summary Section -->
        <div class="report-section">
            <h2 class="section-title">Summary</h2>
            <div class="summary-grid" id="summaryGrid">
                <!-- Summary cards will be populated here -->
            </div>
        </div>

        <!-- Attendance Section -->
        <div class="report-section">
            <h2 class="section-title">Attendance Overview</h2>
            <div class="chart-container">
                <canvas id="attendanceChart"></canvas>
            </div>
            <div class="chart-container">
                <canvas id="attendanceByDeptChart"></canvas>
            </div>
        </div>

        <!-- Performance Section -->
        <div class="report-section">
            <h2 class="section-title">Performance Overview</h2>
            <div class="chart-container">
                <canvas id="performanceChart"></canvas>
            </div>
        </div>

        <!-- Detailed Data Section -->
        <div class="report-section">
            <h2 class="section-title">Employee Details</h2>
            <div id="employeeDetailsTable">
                <!-- Table will be populated here -->
            </div>
        </div>
    </div>

    <script>
        // Set report date
        document.getElementById('reportDate').textContent = new Date().toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });

        // Chart data will be populated from server-side
        const reportData = <asp:Literal ID="litReportData" runat="server"></asp:Literal>;

        if (reportData) {
            // Summary Cards
            const summaryGrid = document.getElementById('summaryGrid');
            summaryGrid.innerHTML = `
                <div class="summary-card">
                    <h3>Total Employees</h3>
                    <div class="value">${reportData.TotalEmployees}</div>
                </div>
                <div class="summary-card">
                    <h3>Average Attendance Rate</h3>
                    <div class="value">${reportData.AverageAttendanceRate}%</div>
                </div>
                <div class="summary-card">
                    <h3>Total Present Days</h3>
                    <div class="value">${reportData.TotalPresentDays}</div>
                </div>
                <div class="summary-card">
                    <h3>Total Absent Days</h3>
                    <div class="value">${reportData.TotalAbsentDays}</div>
                </div>
                <div class="summary-card">
                    <h3>Average Performance</h3>
                    <div class="value">${reportData.AveragePerformance}%</div>
                </div>
            `;

            // Attendance Chart
            const attendanceCtx = document.getElementById('attendanceChart').getContext('2d');
            new Chart(attendanceCtx, {
                type: 'line',
                data: {
                    labels: reportData.AttendanceLabels,
                    datasets: [{
                        label: 'Present',
                        data: reportData.AttendancePresentData,
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        tension: 0.4
                    }, {
                        label: 'Absent',
                        data: reportData.AttendanceAbsentData,
                        borderColor: '#ef4444',
                        backgroundColor: 'rgba(239, 68, 68, 0.1)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Attendance Trend (Last 30 Days)',
                            font: { size: 16 }
                        },
                        legend: {
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });

            // Attendance by Department Chart
            const deptCtx = document.getElementById('attendanceByDeptChart').getContext('2d');
            new Chart(deptCtx, {
                type: 'bar',
                data: {
                    labels: reportData.DepartmentLabels,
                    datasets: [{
                        label: 'Attendance Rate (%)',
                        data: reportData.DepartmentAttendanceData,
                        backgroundColor: 'rgba(139, 71, 85, 0.8)',
                        borderColor: '#8B4755',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Attendance Rate by Department',
                            font: { size: 16 }
                        },
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                callback: function(value) {
                                    return value + '%';
                                }
                            }
                        }
                    }
                }
            });

            // Performance Chart
            const performanceCtx = document.getElementById('performanceChart').getContext('2d');
            new Chart(performanceCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Excellent', 'Good', 'Average', 'Poor'],
                    datasets: [{
                        data: reportData.PerformanceDistribution,
                        backgroundColor: [
                            '#10b981',
                            '#3b82f6',
                            '#f59e0b',
                            '#ef4444'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Performance Distribution',
                            font: { size: 16 }
                        },
                        legend: {
                            position: 'right'
                        }
                    }
                }
            });

            // Employee Details Table
            const tableContainer = document.getElementById('employeeDetailsTable');
            let tableHTML = '<table class="data-table"><thead><tr><th>Employee ID</th><th>Name</th><th>Department</th><th>Attendance Rate</th><th>Performance</th><th>Status</th></tr></thead><tbody>';
            
            reportData.EmployeeDetails.forEach(emp => {
                const badgeClass = emp.Performance >= 90 ? 'badge-excellent' : 
                                  emp.Performance >= 75 ? 'badge-good' : 
                                  emp.Performance >= 60 ? 'badge-average' : 'badge-poor';
                const performanceText = emp.Performance >= 90 ? 'Excellent' : 
                                       emp.Performance >= 75 ? 'Good' : 
                                       emp.Performance >= 60 ? 'Average' : 'Poor';
                
                tableHTML += `
                    <tr>
                        <td>${emp.EmployeeId}</td>
                        <td>${emp.Name}</td>
                        <td>${emp.Department}</td>
                        <td>${emp.AttendanceRate}%</td>
                        <td>${emp.Performance}%</td>
                        <td><span class="performance-badge ${badgeClass}">${performanceText}</span></td>
                    </tr>
                `;
            });
            
            tableHTML += '</tbody></table>';
            tableContainer.innerHTML = tableHTML;
        }
    </script>
</body>
</html>

