<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" Async="true" CodeBehind="WebForm1.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        /* ✅ Pure white background — no gradient */
        .dashboard-wrapper {
            background-color: white;
            min-height: 100vh;
            padding: 30px 20px;
        }

        .dashboard-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .dashboard-header {
            color: #333;
            margin-bottom: 30px;
        }

        .dashboard-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand color */
        }

        .dashboard-header p {
            opacity: 0.8;
            font-size: 14px;
            color: #666;
        }

        .top-cards {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 25px;
        }

        .dashboard-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
        }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        .card-title {
            font-size: 14px;
            color: #555;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .card-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            background-color: #A36A66; /* ✅ Unified icon bg */
            color: white;
        }

        /* Removed old icon-specific classes — all use same style above */

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }

        .stat-item {
            text-align: center;
            padding: 10px;
            background: #fafafa;
            border-radius: 8px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #A36A66; /* ✅ Brand color */
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 12px;
            color: #777;
        }

        .announcement-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .announcement-item {
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }

        .announcement-item:last-child {
            border-bottom: none;
        }

        .announcement-title {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 3px;
        }

        .announcement-date {
            font-size: 12px;
            color: #999;
        }

        .bottom-section {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
        }

        .large-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
        }

        .card-title-main {
            font-size: 18px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand color */
            margin-bottom: 20px;
        }

        .attendance-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }

        .attendance-stat {
            text-align: center;
            padding: 15px;
            border-radius: 8px;
            background: #fafafa;
        }

        .attendance-stat.present {
            background: #fde8e5; /* soft tint of #A36A66 */
            color: #A36A66;
        }

        .attendance-stat.absent {
            background: #A36A66;
            color: white;
        }

        .attendance-stat.absent .attendance-value,
        .attendance-stat.absent .attendance-label {
            color: white;
        }

        .attendance-value {
            font-size: 28px;
            font-weight: bold;
            color: #A36A66; /* default — overridden in .absent */
            margin-bottom: 5px;
        }

        .attendance-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
        }

        .attendance-chart {
            height: 250px;
            background: #fafafa;
            border-radius: 8px;
            padding: 15px;
            position: relative;
        }

        .attendance-chart canvas {
            max-height: 100%;
        }

        .right-column {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .right-column .large-card {
            min-height: auto;
        }

        .table-container {
            overflow-x: auto;
        }

        .employee-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .employee-table thead {
            background-color: #A36A66; /* ✅ Solid brand header */
        }

        .employee-table th {
            padding: 12px 8px;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 11px;
            text-transform: uppercase;
        }

        .employee-table td {
            padding: 12px 8px;
            border-bottom: 1px solid #f0f0f0;
        }

        .employee-img {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: #A36A66; /* ✅ Unified avatar bg */
            display: inline-block;
            vertical-align: middle;
        }

        .employee-info {
            display: inline-block;
            vertical-align: middle;
            margin-left: 8px;
        }

        .employee-name {
            font-size: 12px;
            font-weight: 600;
            color: #333;
        }

        .employee-role {
            font-size: 11px;
            color: #888;
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }

        .status-paid {
            background: #d4edda;
            color: #155724;
        }

        .status-unpaid {
            background: #f8d7da;
            color: #721c24;
        }

        .chart-container {
            display: flex;
            gap: 20px;
            align-items: flex-end;
            height: 150px;
        }

        .chart-bar {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }

        .bar-wrapper {
            width: 100%;
            height: 120px;
            background: #f5f5f5;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            overflow: hidden;
            position: relative;
        }

        .chart-fill {
            width: 100%;
            border-radius: 6px 6px 0 0;
            transition: height 0.3s ease;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding-top: 10px;
            background-color: #A36A66; /* ✅ Unified fill */
        }

        .chart-value {
            font-size: 18px;
            font-weight: bold;
            color: white;
        }

        .chart-label {
            font-size: 13px;
            font-weight: 600;
            color: #555;
            text-align: center;
        }

        @media (max-width: 1200px) {
            .top-cards {
                grid-template-columns: 1fr;
            }

            .bottom-section {
                grid-template-columns: 1fr;
            }

            .attendance-stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .top-cards {
                grid-template-columns: 1fr;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .attendance-stats {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="dashboard-wrapper">
        <div class="dashboard-container">
            <div class="dashboard-header">
                <h1>Manager Dashboard</h1>
                <p>Welcome back! Here's what's happening in your department today.</p>
            </div>

            <div class="top-cards">
                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Total Employees</span>
                        <div class="card-icon icon-employees">👥</div>
                    </div>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value"><%= GetTotalEmployees() %></div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= GetFemaleCount() %></div>
                            <div class="stat-label">Female</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= GetMaleCount() %></div>
                            <div class="stat-label">Male</div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Announcements from admin</span>
                        <div class="card-icon icon-announcement">📢</div>
                    </div>
                    <ul class="announcement-list">
                        <% if (RecentAnnouncements != null && RecentAnnouncements.Count > 0) { %>
                            <% foreach (var announcement in RecentAnnouncements) { %>
                                <li class="announcement-item">
                                    <div class="announcement-title"><%= Server.HtmlEncode(announcement.Content) %></div>
                                    <div class="announcement-date"><%= announcement.PostedDate.ToLocalTime().ToString("MMMM dd, yyyy") %></div>
                                </li>
                            <% } %>
                        <% } else { %>
                            <li class="announcement-item">
                                <div class="announcement-title" style="color: #999; font-style: italic;">No announcements available</div>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>

            <div class="bottom-section">
                <div class="large-card">
                    <h2 class="card-title-main">Attendance Overview - Today</h2>
                    <div class="attendance-stats">
                        <div class="attendance-stat present">
                            <div class="attendance-value"><%= GetPresentCount() %></div>
                            <div class="attendance-label">Present</div>
                        </div>
                        <div class="attendance-stat absent">
                            <div class="attendance-value"><%= GetAbsentCount() %></div>
                            <div class="attendance-label">Absent</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value"><%= GetOnLeaveCount() %></div>
                            <div class="attendance-label">On Leave</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value"><%= GetLateCount() %></div>
                            <div class="attendance-label">Late</div>
                        </div>
                    </div>
                    <div class="attendance-chart">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <div class="right-column">
                    <div class="large-card">
                        <h2 class="card-title-main">Employee Summary</h2>
                        <div class="table-container">
                            <table class="employee-table">
                                <thead>
                                    <tr>
                                        <th>Employee</th>
                                        <th>Salary</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (GetEmployeeSummaryList() != null && GetEmployeeSummaryList().Count > 0) { %>
                                        <% foreach (var employee in GetEmployeeSummaryList()) { %>
                                            <tr>
                                                <td>
                                                    <div class="employee-img" style="background-color: #A36A66; color: white; display: inline-flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600;"><%= GetEmployeeInitials(employee) %></div>
                                                    <div class="employee-info">
                                                        <div class="employee-name"><%= Server.HtmlEncode(employee.FullName) %></div>
                                                        <div class="employee-role"><%= Server.HtmlEncode(employee.Role ?? "N/A") %></div>
                                                    </div>
                                                </td>
                                                <td style="font-weight: 600;">—</td>
                                                <td><span class="status-badge status-paid">Active</span></td>
                                            </tr>
                                        <% } %>
                                    <% } else { %>
                                        <tr>
                                            <td colspan="3" style="text-align: center; padding: 20px; color: #999;">
                                                No employees found in your department.
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Initialize attendance chart when page loads
        document.addEventListener('DOMContentLoaded', function() {
            const ctx = document.getElementById('attendanceChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['Present', 'Absent', 'On Leave', 'Late'],
                        datasets: [{
                            label: 'Today\'s Attendance',
                            data: [
                                <%= GetPresentCount() %>,
                                <%= GetAbsentCount() %>,
                                <%= GetOnLeaveCount() %>,
                                <%= GetLateCount() %>
                            ],
                            backgroundColor: [
                                '#fde8e5',  // Present - soft pink
                                '#A36A66',  // Absent - brand color
                                '#e0e0e0',  // On Leave - grey
                                '#ffc107'   // Late - yellow
                            ],
                            borderColor: [
                                '#A36A66',
                                '#8B5A58',
                                '#999',
                                '#ff9800'
                            ],
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return context.label + ': ' + context.parsed.y + ' employee(s)';
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    stepSize: 1,
                                    precision: 0
                                },
                                grid: {
                                    color: 'rgba(0, 0, 0, 0.05)'
                                }
                            },
                            x: {
                                grid: {
                                    display: false
                                }
                            }
                        }
                    }
                });
            }
        });
    </script>
</asp:Content>