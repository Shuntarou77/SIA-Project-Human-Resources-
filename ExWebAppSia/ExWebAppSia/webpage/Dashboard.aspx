<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm1" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
       .dashboard-wrapper {
            background-color: white; /* kept white as requested */
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
            color: #A36A66; /* updated to match theme */
        }

        .dashboard-header p {
            opacity: 0.8;
            font-size: 14px;
            color: #666;
        }

        .top-cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
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
            background-color: #A36A66; /* unified accent */
            color: white;
        }

        /* Removed old gradient icon backgrounds — now all use #A36A66 */
        /* .icon-employees, .icon-applicants, .icon-announcement — all use same style above */

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }

        .stat-item {
            text-align: center;
            padding: 10px;
            background: #f9f9f9;
            border-radius: 8px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #A36A66; /* updated */
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
            color: #A36A66; /* updated */
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
            color: #A36A66; /* default — overridden in .absent above */
            margin-bottom: 5px;
        }

        .attendance-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
        }

        .attendance-chart {
            height: 200px;
            background: #fafafa;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
            font-size: 14px;
            border: 1px dashed #ddd;
        }

        .right-column {
            display: flex;
            flex-direction: column;
            gap: 20px;
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
            background-color: #A36A66; /* unified header bg */
        }

        .employee-table th {
            padding: 12px 8px;
            text-align: left;
            font-weight: 600;
            color: white; /* high contrast */
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
            background-color: #A36A66; /* unified */
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
            background: #e8f5e9;
            color: #2e7d32;
        }

        .status-unpaid {
            background: #ffebee;
            color: #c62828;
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
        }

        /* Unified fill color for both bars */
        .chart-regular .chart-fill,
        .chart-contractual .chart-fill {
            background-color: #A36A66;
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
           

            <div class="top-cards">
                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Total Employees</span>
                        <div class="card-icon icon-employees">👥</div>
                    </div>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value">164</div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">65</div>
                            <div class="stat-label">Female</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">99</div>
                            <div class="stat-label">Male</div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Applicants</span>
                        <div class="card-icon icon-applicants">📋</div>
                    </div>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value">537</div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">231</div>
                            <div class="stat-label">In Progress</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">306</div>
                            <div class="stat-label">Completed</div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Recent Announcements</span>
                        <div class="card-icon icon-announcement">📢</div>
                    </div>
                    <ul class="announcement-list">
                        <asp:PlaceHolder ID="phAnnouncements" runat="server" />
                    </ul>
                </div>
            </div>

            <div class="bottom-section">
                <div class="large-card">
                    <h2 class="card-title-main">Attendance Overview - Today</h2>
                    <div class="attendance-stats">
                        <div class="attendance-stat present">
                            <div class="attendance-value">138</div>
                            <div class="attendance-label">Present</div>
                        </div>
                        <div class="attendance-stat absent">
                            <div class="attendance-value">8</div>
                            <div class="attendance-label">Absent</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value">12</div>
                            <div class="attendance-label">On Leave</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value">6</div>
                            <div class="attendance-label">Late</div>
                        </div>
                    </div>
                    <div class="attendance-chart">
                        📊 Attendance Chart Visualization
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
                                    <tr>
                                        <td>
                                            <div class="employee-img"></div>
                                            <div class="employee-info">
                                                <div class="employee-name">John Doe</div>
                                                <div class="employee-role">Software Engineer</div>
                                            </div>
                                        </td>
                                        <td style="font-weight: 600;">₱45,000</td>
                                        <td><span class="status-badge status-paid">Paid</span></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="employee-img"></div>
                                            <div class="employee-info">
                                                <div class="employee-name">Jane Smith</div>
                                                <div class="employee-role">Project Manager</div>
                                            </div>
                                        </td>
                                        <td style="font-weight: 600;">₱38,500</td>
                                        <td><span class="status-badge status-unpaid">Unpaid</span></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="employee-img"></div>
                                            <div class="employee-info">
                                                <div class="employee-name">Mike Johnson</div>
                                                <div class="employee-role">UI/UX Designer</div>
                                            </div>
                                        </td>
                                        <td style="font-weight: 600;">₱42,000</td>
                                        <td><span class="status-badge status-paid">Paid</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="large-card">
                        <h2 class="card-title-main">Working Format</h2>
                        <div class="chart-container">
                            <div class="chart-bar chart-regular">
                                <div class="bar-wrapper">
                                    <div class="chart-fill" style="height: 70%;">
                                        <span class="chart-value">70%</span>
                                    </div>
                                </div>
                                <div class="chart-label">Regular</div>
                            </div>
                            <div class="chart-bar chart-contractual">
                                <div class="bar-wrapper">
                                    <div class="chart-fill" style="height: 30%;">
                                        <span class="chart-value">30%</span>
                                    </div>
                                </div>
                                <div class="chart-label">Contractual</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>