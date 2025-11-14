<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .dashboard-wrapper {
            background: linear-gradient(135deg, #A44F56 0%, #723E43 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }

        .dashboard-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .dashboard-header {
            color: white;
            margin-bottom: 30px;
        }

        .dashboard-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .dashboard-header p {
            opacity: 0.9;
            font-size: 14px;
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
        }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        .card-title {
            font-size: 14px;
            color: #666;
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
        }

        .icon-employees {
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            color: #A44F56;
        }

        .icon-applicants {
            background: linear-gradient(135deg, #F2C2C6, #FDBFC3);
            color: #723E43;
        }

        .icon-announcement {
            background: linear-gradient(135deg, #A44F56, #723E43);
            color: white;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }

        .stat-item {
            text-align: center;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #723E43;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 12px;
            color: #666;
        }

        .announcement-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .announcement-item {
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
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
        }

        .card-title-main {
            font-size: 18px;
            font-weight: 600;
            color: #333;
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
            background: #f8f9fa;
        }

        .attendance-stat.present {
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
        }

        .attendance-stat.absent {
            background: linear-gradient(135deg, #A44F56, #723E43);
            color: white;
        }

        .attendance-stat.absent .attendance-value,
        .attendance-stat.absent .attendance-label {
            color: white;
        }

        .attendance-value {
            font-size: 28px;
            font-weight: bold;
            color: #723E43;
            margin-bottom: 5px;
        }

        .attendance-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
        }

        .attendance-chart {
            height: 200px;
            background: #f8f9fa;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
            font-size: 14px;
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
            background: linear-gradient(135deg, #F2C2C6, #FDBFC3);
        }

        .employee-table th {
            padding: 12px 8px;
            text-align: left;
            font-weight: 600;
            color: #723E43;
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
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
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
            color: #999;
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
            background: #f8f9fa;
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

        .chart-regular .chart-fill {
            background: linear-gradient(to top, #723E43, #A44F56);
        }

        .chart-contractual .chart-fill {
            background: linear-gradient(to top, #F2C2C6, #FDBFC3);
        }

        .chart-value {
            font-size: 18px;
            font-weight: bold;
            color: white;
        }

        .chart-contractual .chart-value {
            color: #723E43;
        }

        .chart-label {
            font-size: 13px;
            font-weight: 600;
            color: #666;
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
                            <div class="stat-value">45</div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">28</div>
                            <div class="stat-label">Female</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">17</div>
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
                            <div class="stat-value">24</div>
                            <div class="stat-label">Total</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">8</div>
                            <div class="stat-label">New</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">16</div>
                            <div class="stat-label">In Progress</div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <span class="card-title">Recent Announcements</span>
                        <div class="card-icon icon-announcement">📢</div>
                    </div>
                    <ul class="announcement-list">
                        <li class="announcement-item">
                            <div class="announcement-title">Team Building Event</div>
                            <div class="announcement-date">November 15, 2025</div>
                        </li>
                        <li class="announcement-item">
                            <div class="announcement-title">Quarterly Training Session</div>
                            <div class="announcement-date">November 10, 2025</div>
                        </li>
                        <li class="announcement-item">
                            <div class="announcement-title">Department Meeting</div>
                            <div class="announcement-date">November 8, 2025</div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="bottom-section">
                <div class="large-card">
                    <h2 class="card-title-main">Attendance Overview - Today</h2>
                    <div class="attendance-stats">
                        <div class="attendance-stat present">
                            <div class="attendance-value">38</div>
                            <div class="attendance-label">Present</div>
                        </div>
                        <div class="attendance-stat absent">
                            <div class="attendance-value">3</div>
                            <div class="attendance-label">Absent</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value">2</div>
                            <div class="attendance-label">On Leave</div>
                        </div>
                        <div class="attendance-stat">
                            <div class="attendance-value">2</div>
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
                                    <div class="chart-fill" style="height: 65%;">
                                        <span class="chart-value">65%</span>
                                    </div>
                                </div>
                                <div class="chart-label">Regular</div>
                            </div>
                            <div class="chart-bar chart-contractual">
                                <div class="bar-wrapper">
                                    <div class="chart-fill" style="height: 35%;">
                                        <span class="chart-value">35%</span>
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