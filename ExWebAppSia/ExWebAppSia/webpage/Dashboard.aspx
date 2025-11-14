<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm1" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        /* Dashboard Content Styles */
        .dashboard-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .card {
            background-color: #FFFFFF;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.12);
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #A85B5B;
            margin-bottom: 15px;
        }

        /* Stat Cards */
        .stat-card {
            text-align: center;
            padding: 20px;
        }

        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #A85B5B;
            margin: 10px 0;
        }

        .stat-label {
            font-size: 14px;
            color: #6B3838;
            margin-bottom: 5px;
        }

        .stat-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            margin: 0 5px;
        }

        .badge-in-progress {
            background-color: #D4999C;
        }

        .badge-progress {
            background-color: #A85B5B;
        }

        .gender-stats {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
        }

        .gender-stat {
            background-color: #F5DDD8;
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            color: #6B3838;
        }

        /* Announcement Card */
        .announcement-item {
            display: flex;
            align-items: flex-start;
            padding: 10px 0;
            border-bottom: 1px solid #FFCCCC;
        }

        .announcement-avatar {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            overflow: hidden;
            margin-right: 10px;
        }

        .announcement-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .announcement-content {
            flex: 1;
        }

        .announcement-title {
            font-weight: bold;
            margin-bottom: 2px;
            color: #6B3838;
        }

        .announcement-time {
            font-size: 11px;
            color: #8B5858;
        }

        /* Attendance Overview */
        .attendance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .legend {
            display: flex;
            gap: 15px;
            margin-top: 10px;
            font-size: 12px;
            color: #6B3838;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .legend-on-time {
            background-color: #8B0000;
        }

        .legend-late {
            background-color: #FFD700;
        }

        .legend-absent {
            background-color: #D4999C;
        }

        .bar-chart {
            display: flex;
            align-items: flex-end;
            height: 150px;
            gap: 10px;
            padding: 10px 0;
        }

        .bar-group {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 20px;
        }

        .bar-day {
            font-size: 10px;
            margin-top: 5px;
            color: #6B3838;
        }

        .bar-stack {
            display: flex;
            flex-direction: column-reverse;
            width: 100%;
            height: 100%;
        }

        .bar-segment {
            width: 100%;
            border: 1px solid rgba(0,0,0,0.1);
        }

        .bar-on-time {
            background-color: #8B0000;
        }

        .bar-late {
            background-color: #FFD700;
        }

        .bar-absent {
            background-color: #D4999C;
        }

        /* Employee Summary */
        .employee-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .employee-table th,
        .employee-table td {
            padding: 8px 10px;
            text-align: left;
            border-bottom: 1px solid #FFCCCC;
        }

        .employee-table th {
            font-weight: 600;
            color: #A85B5B;
            font-size: 14px;
        }

        .employee-row {
            display: flex;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #FFCCCC;
        }

        .employee-avatar {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            overflow: hidden;
            margin-right: 10px;
        }

        .employee-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .status-badge {
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-paid {
            background-color: #CCFFCC;
            color: #006600;
        }

        .status-pending {
            background-color: #FFFFCC;
            color: #666600;
        }

        /* Working Format */
        .working-format {
            display: flex;
            justify-content: space-around;
            align-items: center;
            margin-top: 15px;
            padding: 15px 0;
            border-top: 1px solid #FFCCCC;
        }

        .format-item {
            text-align: center;
        }

        .format-percent {
            font-size: 32px;
            font-weight: bold;
            color: #A85B5B;
            margin: 5px 0;
        }

        .format-label {
            font-size: 14px;
            color: #6B3838;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .dashboard-content {
                grid-template-columns: 1fr;
            }
            
            .card {
                padding: 15px;
            }
            
            .stat-number {
                font-size: 28px;
            }
            
            .bar-chart {
                height: 120px;
            }
            
            .working-format {
                flex-direction: column;
                gap: 15px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h1 style="text-align: center; color: #A85B5B; margin: 20px 0; font-weight: 600;"></h1>
    
    <div class="dashboard-content">
        <!-- Total Employee Card -->
        <div class="card stat-card">
            <div class="card-title">Total Employee</div>
            <div class="stat-number"><asp:Literal ID="litTotalEmployees" runat="server" Text="0" /></div>
            <div class="gender-stats">
                <div class="gender-stat">Female <asp:Literal ID="litFemaleCount" runat="server" Text="0" /></div>
                <div class="gender-stat">Male <asp:Literal ID="litMaleCount" runat="server" Text="0" /></div>
            </div>
        </div>

        <!-- Total Applicant Card -->
        <div class="card stat-card">
            <div class="card-title">Total Applicant</div>
            <div class="stat-number"><asp:Literal ID="litTotalApplicants" runat="server" Text="0" /></div>
            <div style="display: flex; justify-content: center; gap: 10px;">
                <span class="stat-badge badge-in-progress">IN PROGRESS <asp:Literal ID="litInProgressApplicants" runat="server" Text="0" /></span>
                <span class="stat-badge badge-progress">NEW <asp:Literal ID="litNewApplicants" runat="server" Text="0" /></span>
            </div>
        </div>

        <!-- Recent Announcement Card -->
        <div class="card">
            <div class="card-title">Recent Announcement</div>
            <asp:PlaceHolder ID="phAnnouncements" runat="server" />
        </div>

        <!-- Attendance Overview Card -->
        <div class="card">
            <div class="card-title">Attendance Overview</div>
            <div class="attendance-header">
                <div>Attendance</div>
                <div class="legend">
                    <div class="legend-item"><div class="legend-color legend-on-time"></div> On Time</div>
                    <div class="legend-item"><div class="legend-color legend-late"></div> Late</div>
                    <div class="legend-item"><div class="legend-color legend-absent"></div> Absent</div>
                </div>
            </div>
            <div class="bar-chart">
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 30%;"></div>
                        <div class="bar-segment bar-late" style="height: 30%;"></div>
                        <div class="bar-segment bar-absent" style="height: 40%;"></div>
                    </div>
                    <div class="bar-day">MON</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 40%;"></div>
                        <div class="bar-segment bar-late" style="height: 20%;"></div>
                        <div class="bar-segment bar-absent" style="height: 40%;"></div>
                    </div>
                    <div class="bar-day">TUES</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 20%;"></div>
                        <div class="bar-segment bar-late" style="height: 50%;"></div>
                        <div class="bar-segment bar-absent" style="height: 30%;"></div>
                    </div>
                    <div class="bar-day">WED</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 30%;"></div>
                        <div class="bar-segment bar-late" style="height: 40%;"></div>
                        <div class="bar-segment bar-absent" style="height: 30%;"></div>
                    </div>
                    <div class="bar-day">THURS</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 20%;"></div>
                        <div class="bar-segment bar-late" style="height: 30%;"></div>
                        <div class="bar-segment bar-absent" style="height: 50%;"></div>
                    </div>
                    <div class="bar-day">FRI</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 30%;"></div>
                        <div class="bar-segment bar-late" style="height: 20%;"></div>
                        <div class="bar-segment bar-absent" style="height: 50%;"></div>
                    </div>
                    <div class="bar-day">SAT</div>
                </div>
                <div class="bar-group">
                    <div class="bar-stack">
                        <div class="bar-segment bar-on-time" style="height: 40%;"></div>
                        <div class="bar-segment bar-late" style="height: 30%;"></div>
                        <div class="bar-segment bar-absent" style="height: 30%;"></div>
                    </div>
                    <div class="bar-day">SUN</div>
                </div>
            </div>
        </div>

        <!-- Employee Summary Card -->
        <div class="card">
            <div class="card-title">Employee Summary</div>
            <table class="employee-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Job Title</th>
                        <th>Net Salary</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:PlaceHolder ID="phEmployeeSummary" runat="server">
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px; color: #999;">
                                No employees found
                            </td>
                        </tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>

        <!-- Working Format Card -->
        <div class="card">
            <div class="card-title">Working Format</div>
            <div class="working-format">
                <div class="format-item">
                    <div class="format-percent"><asp:Literal ID="litContractualPercentage" runat="server" Text="0%" /></div>
                    <div class="format-label">Contractual</div>
                </div>
                <div style="border-left: 1px solid #FFCCCC; height: 40px;"></div>
                <div class="format-item">
                    <div class="format-percent"><asp:Literal ID="litRegularPercentage" runat="server" Text="0%" /></div>
                    <div class="format-label">Regular</div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>