<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm1" Async="true" %>
    <%@ Import Namespace="ExWebAppSia.Models" %>
        <%@ Import Namespace="System.Collections.Generic" %>

            <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
                <!-- Add Chart.js CDN -->
                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                <!-- Modern Theme CSS -->
                <link href="css/modern-theme.css" rel="stylesheet" type="text/css" />
                <script src="js/svg-icons.js"></script>
                <style type="text/css">
                    /* Dashboard Override Styles */
                    .dashboard-wrapper {
                        background: linear-gradient(135deg, #FCFAF9 0%, #FFFFFF 100%);
                        min-height: calc(100vh - 72px);
                        padding: 30px 20px;
                    }

                    .dashboard-container {
                        max-width: 1400px;
                        margin: 0 auto;
                        animation: fadeIn 0.6s ease-out;
                    }

                    .dashboard-header {
                        color: #333;
                        margin-bottom: 40px;
                        animation: slideInDown 0.6s ease-out;
                    }

                    .dashboard-header h1 {
                        font-size: 36px;
                        margin-bottom: 8px;
                        font-weight: 700;
                        background: linear-gradient(135deg, #A36A66, #C49A99);
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                        background-clip: text;
                    }

                    .dashboard-header p {
                        opacity: 0.8;
                        font-size: 15px;
                        color: #6B4F4E;
                    }

                    .top-cards {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 24px;
                        margin-bottom: 30px;
                    }

                    .dashboard-card {
                        background: white;
                        border-radius: 20px;
                        padding: 24px;
                        box-shadow: 0 8px 24px rgba(163, 106, 102, 0.12);
                        border: 1px solid #F8ECEB;
                        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                        animation: fadeIn 0.6s ease-out backwards;
                        animation-fill-mode: both;
                        cursor: pointer;
                    }

                    .dashboard-card:nth-child(1) {
                        animation-delay: 0.1s;
                    }

                    .dashboard-card:nth-child(2) {
                        animation-delay: 0.2s;
                    }

                    .dashboard-card:nth-child(3) {
                        animation-delay: 0.3s;
                    }

                    .dashboard-card:hover {
                        transform: translateY(-6px);
                        box-shadow: 0 16px 40px rgba(163, 106, 102, 0.2);
                    }

                    .card-header {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 20px;
                    }

                    .card-title {
                        font-size: 13px;
                        color: #6B4F4E;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                    }

                    .card-icon {
                        width: 56px;
                        height: 56px;
                        border-radius: 16px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: linear-gradient(135deg, #A36A66, #C49A99);
                        color: white;
                        box-shadow: 0 4px 16px rgba(163, 106, 102, 0.3);
                        transition: all 0.3s ease;
                    }

                    .card-icon svg {
                        width: 28px;
                        height: 28px;
                        fill: white;
                    }

                    .dashboard-card:hover .card-icon {
                        transform: scale(1.1) rotate(5deg);
                        box-shadow: 0 8px 20px rgba(163, 106, 102, 0.4);
                    }

                    .stats-grid {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 16px;
                    }

                    .stat-item {
                        text-align: center;
                        padding: 16px 12px;
                        background: linear-gradient(135deg, #F8ECEB 0%, #FEF4F3 100%);
                        border-radius: 12px;
                        transition: all 0.3s ease;
                    }

                    .stat-item:hover {
                        transform: scale(1.05);
                        background: linear-gradient(135deg, #F8ECEB 0%, #F8ECEB 100%);
                    }

                    .stat-value {
                        font-size: 28px;
                        font-weight: 800;
                        color: #A36A66;
                        margin-bottom: 6px;
                    }

                    .stat-label {
                        font-size: 11px;
                        color: #9B7D7B;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                    }

                    .announcement-list {
                        list-style: none;
                        padding: 0;
                        margin: 0;
                    }

                    .announcement-item {
                        padding: 14px 0;
                        border-bottom: 1px solid #F0EEEE;
                        transition: all 0.3s ease;
                    }

                    .announcement-item:hover {
                        padding-left: 8px;
                        background: linear-gradient(90deg, #F8ECEB 0%, transparent 100%);
                    }

                    .announcement-item:last-child {
                        border-bottom: none;
                    }

                    .announcement-title {
                        font-size: 14px;
                        font-weight: 600;
                        color: #4A3534;
                        margin-bottom: 4px;
                    }

                    .announcement-date {
                        font-size: 11px;
                        color: #B8A19F;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .announcement-date svg {
                        width: 12px;
                        height: 12px;
                        fill: #B8A19F;
                    }

                    .bottom-section {
                        display: grid;
                        grid-template-columns: 2fr 1fr;
                        gap: 24px;
                    }

                    .large-card {
                        background: white;
                        border-radius: 20px;
                        padding: 28px;
                        box-shadow: 0 8px 24px rgba(163, 106, 102, 0.12);
                        border: 1px solid #F8ECEB;
                        animation: fadeIn 0.6s ease-out 0.4s backwards;
                        cursor: pointer;
                        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                    }

                    .large-card:hover {
                        transform: translateY(-6px);
                        box-shadow: 0 16px 40px rgba(163, 106, 102, 0.2);
                    }

                    .card-title-main {
                        font-size: 20px;
                        font-weight: 700;
                        color: #A36A66;
                        margin-bottom: 24px;
                        display: flex;
                        align-items: center;
                        gap: 12px;
                    }

                    .card-title-main svg {
                        width: 24px;
                        height: 24px;
                        fill: #A36A66;
                    }

                    .attendance-stats {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 16px;
                        margin-bottom: 24px;
                    }

                    .attendance-stat {
                        text-align: center;
                        padding: 20px 16px;
                        border-radius: 16px;
                        background: linear-gradient(135deg, #F8F6F5 0%, #FCFAF9 100%);
                        transition: all 0.3s ease;
                    }

                    .attendance-stat:hover {
                        transform: translateY(-4px);
                        box-shadow: 0 8px 20px rgba(163, 106, 102, 0.15);
                    }

                    .attendance-stat.present {
                        background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
                        color: #065F46;
                    }

                    .attendance-stat.absent {
                        background: linear-gradient(135deg, #A36A66, #8B5A58);
                        color: white;
                        box-shadow: 0 8px 20px rgba(163, 106, 102, 0.3);
                    }

                    .attendance-stat.absent .attendance-value,
                    .attendance-stat.absent .attendance-label {
                        color: white;
                    }

                    .attendance-value {
                        font-size: 32px;
                        font-weight: 800;
                        color: #A36A66;
                        margin-bottom: 6px;
                    }

                    .attendance-label {
                        font-size: 11px;
                        color: #6B4F4E;
                        text-transform: uppercase;
                        font-weight: 600;
                        letter-spacing: 0.8px;
                    }

                    .attendance-chart {
                        height: 260px;
                        background: #FCFAF9;
                        border-radius: 16px;
                        padding: 20px;
                        position: relative;
                    }

                    #attendanceChartCanvas {
                        max-height: 220px;
                    }

                    .right-column {
                        display: flex;
                        flex-direction: column;
                        gap: 24px;
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
                        background: linear-gradient(135deg, #A36A66, #8B5A58);
                    }

                    .employee-table th {
                        padding: 14px 12px;
                        text-align: left;
                        font-weight: 700;
                        color: white;
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 0.8px;
                    }

                    .employee-table td {
                        padding: 14px 12px;
                        border-bottom: 1px solid #F0EEEE;
                    }

                    .employee-table tbody tr {
                        transition: all 0.3s ease;
                    }

                    .employee-table tbody tr:hover {
                        background: linear-gradient(90deg, #F8ECEB 0%, transparent 100%);
                    }

                    .employee-img {
                        width: 36px;
                        height: 36px;
                        border-radius: 50%;
                        background: linear-gradient(135deg, #C49A99, #A36A66);
                        display: inline-block;
                        vertical-align: middle;
                    }

                    .employee-info {
                        display: inline-block;
                        vertical-align: middle;
                        margin-left: 10px;
                    }

                    .employee-name {
                        font-size: 13px;
                        font-weight: 600;
                        color: #4A3534;
                    }

                    .employee-role {
                        font-size: 11px;
                        color: #9B7D7B;
                    }

                    .status-badge {
                        padding: 6px 12px;
                        border-radius: 20px;
                        font-size: 11px;
                        font-weight: 700;
                        display: inline-block;
                        letter-spacing: 0.5px;
                    }

                    .status-paid {
                        background: linear-gradient(135deg, #D1FAE5, #A7F3D0);
                        color: #065F46;
                    }

                    .status-unpaid {
                        background: linear-gradient(135deg, #FEE2E2, #FECACA);
                        color: #991B1B;
                    }

                    .chart-container {
                        display: flex;
                        gap: 24px;
                        align-items: flex-end;
                        height: 160px;
                    }

                    .chart-bar {
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 12px;
                    }

                    .bar-wrapper {
                        width: 100%;
                        height: 130px;
                        background: linear-gradient(135deg, #F8F6F5 0%, #F0EEEE 100%);
                        border-radius: 12px;
                        display: flex;
                        flex-direction: column;
                        justify-content: flex-end;
                        overflow: hidden;
                        position: relative;
                        box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.05);
                    }

                    .chart-fill {
                        width: 100%;
                        border-radius: 8px 8px 0 0;
                        transition: height 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
                        display: flex;
                        align-items: flex-start;
                        justify-content: center;
                        padding-top: 12px;
                        background: linear-gradient(180deg, #C49A99 0%, #A36A66 100%);
                        box-shadow: 0 -4px 16px rgba(163, 106, 102, 0.3);
                    }

                    .chart-value {
                        font-size: 20px;
                        font-weight: 800;
                        color: white;
                    }

                    .chart-label {
                        font-size: 13px;
                        font-weight: 700;
                        color: #6B4F4E;
                        text-align: center;
                    }

                    /* New Dashboard Elements */
                    .dashboard-upper {
                        display: flex;
                        justify-content: space-between;
                        align-items: flex-start;
                        margin-bottom: 40px;
                    }

                    .clock-card {
                        background: white;
                        padding: 15px 25px;
                        border-radius: 15px;
                        box-shadow: 0 4px 15px rgba(163, 106, 102, 0.08);
                        text-align: right;
                        border: 1px solid #F8ECEB;
                    }

                    .clock-time {
                        font-size: 24px;
                        font-weight: 800;
                        color: #A36A66;
                        display: block;
                        font-family: 'Courier New', Courier, monospace;
                    }

                    .clock-date {
                        font-size: 13px;
                        color: #9B7D7B;
                        font-weight: 600;
                    }

                    .quick-actions {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 20px;
                        margin-bottom: 30px;
                    }

                    .action-btn {
                        background: white;
                        border: 1px solid #F8ECEB;
                        border-radius: 16px;
                        padding: 16px;
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        cursor: pointer;
                        transition: all 0.2s ease;
                        text-decoration: none;
                        color: inherit;
                    }

                    .action-btn:hover {
                        background: #FDFBFA;
                        transform: translateY(-3px);
                        box-shadow: 0 8px 20px rgba(163, 106, 102, 0.1);
                        border-color: #A36A66;
                    }

                    .action-icon {
                        width: 40px;
                        height: 40px;
                        border-radius: 10px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: #F8ECEB;
                        color: #A36A66;
                    }

                    .action-text {
                        font-weight: 700;
                        font-size: 14px;
                    }

                    @media (max-width: 1200px) {
                        .top-cards {
                            grid-template-columns: 1fr;
                        }

                        .bottom-section {
                            grid-template-columns: 1fr;
                        }

                        .quick-actions {
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

                        .dashboard-upper {
                            flex-direction: column;
                            gap: 20px;
                        }

                        .clock-card {
                            text-align: left;
                            width: 100%;
                        }
                    }
                </style>
                <script>
                    function updateClock() {
                        const now = new Date();
                        const timeStr = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
                        const dateStr = now.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });

                        const timeEl = document.getElementById('currentTime');
                        const dateEl = document.getElementById('currentDate');

                        if (timeEl) timeEl.textContent = timeStr;
                        if (dateEl) dateEl.textContent = dateStr;
                    }

                    const hrTips = [
                        "Pro-tip: Focus on employee growth to boost retention.",
                        "Reminder: Check for pending applicant reviews today.",
                        "Tip: Regular feedback sessions improve team morale.",
                        "Happy HR-ing! Remember to take a quick break.",
                        "Modern HR is about people, not just paperwork."
                    ];

                    function showRandomTip() {
                        const tipEl = document.getElementById('hrTip');
                        if (tipEl) {
                            const randomTip = hrTips[Math.floor(Math.random() * hrTips.length)];
                            tipEl.textContent = randomTip;
                        }
                    }

                    setInterval(updateClock, 1000);
                    window.onload = function () {
                        updateClock();
                        showRandomTip();
                    };
                </script>

                <!-- Custom Modal Styles for Personal Use -->
                <style>
                    .custom-modal-v2 {
                        display: none;
                        position: fixed;
                        z-index: 10000;
                        left: 0;
                        top: 0;
                        width: 100%;
                        height: 100%;
                        background: rgba(0, 0, 0, 0.6);
                        backdrop-filter: blur(8px);
                    }
                    .custom-modal-v2-content {
                        background: white;
                        margin: 100px auto;
                        padding: 0;
                        border-radius: 20px;
                        width: 90%;
                        max-width: 500px;
                        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                        animation: customSlideDown 0.3s ease;
                        font-family: 'Poppins', sans-serif;
                    }
                    @keyframes customSlideDown {
                        from { opacity: 0; transform: translateY(-50px); }
                        to { opacity: 1; transform: translateY(0); }
                    }
                    .custom-modal-v2-header {
                        padding: 24px;
                        border-radius: 20px 20px 0 0;
                        color: white;
                    }
                    .custom-modal-v2-body { padding: 30px; }
                    .custom-modal-v2-footer {
                        padding: 20px 24px;
                        border-top: 1px solid #F0EEEE;
                        display: flex;
                        justify-content: flex-end;
                        gap: 12px;
                    }
                    .btn-modal-cancel {
                        padding: 10px 20px;
                        border: none;
                        border-radius: 10px;
                        background: #F3F4F6;
                        color: #4B5563;
                        font-weight: 600;
                        cursor: pointer;
                    }
                    .btn-modal-confirm {
                        padding: 10px 20px;
                        border: none;
                        border-radius: 10px;
                        color: white;
                        font-weight: 600;
                        cursor: pointer;
                    }
                </style>


            </asp:Content>

            <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
                <div class="dashboard-wrapper">
                    <div class="dashboard-container">
                        <div class="dashboard-upper">
                            <div class="dashboard-header">
                                <h1>
                                    <asp:Literal ID="litGreeting" runat="server" Text="Welcome back!" />
                                </h1>
                                <p>Here's what's happening with your team today.</p>
                                <asp:Literal ID="litDashboardTitle" runat="server" Visible="false" />
                            </div>
                            <div class="clock-card">
                                <span class="clock-time" id="currentTime">--:--:--</span>
                                <span class="clock-date" id="currentDate">----------</span>
                                <div id="hrTip"
                                    style="font-size: 11px; color: #A36A66; margin-top: 8px; font-style: italic; max-width: 200px;">
                                </div>
                            </div>
                        </div>

                        <!-- Quick Actions Section -->
                        <div class="quick-actions stagger-animation">
                            <a href="Employee.aspx" class="action-btn">
                                <div class="action-icon">
                                    <i class="fas fa-user-plus"></i>
                                </div>
                                <span class="action-text">Add Employee</span>
                            </a>
                            <a href="Recruitment.aspx" class="action-btn">
                                <div class="action-icon">
                                    <i class="fas fa-file-invoice"></i>
                                </div>
                                <span class="action-text">Review Applicants</span>
                            </a>
                            <a href="Announcement.aspx" class="action-btn">
                                <div class="action-icon">
                                    <i class="fas fa-bullhorn"></i>
                                </div>
                                <span class="action-text">Post Announcement</span>
                            </a>
                            <a href="Payroll.aspx" class="action-btn">
                                <div class="action-icon">
                                    <i class="fas fa-money-check-alt"></i>
                                </div>
                                <span class="action-text">Process Payroll</span>
                            </a>
                        </div>

                        <div class="top-cards stagger-animation">
                            <div class="dashboard-card hover-lift" onclick="location.href='Employee.aspx'">
                                <div class="card-header">
                                    <span class="card-title">Total Employees</span>
                                    <div class="card-icon">
                                        <svg viewBox="0 0 24 24" fill="currentColor">
                                            <path
                                                d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" />
                                        </svg>
                                    </div>
                                </div>
                                <div class="stats-grid">
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litTotalEmployees" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="stat-label">Total</div>
                                    </div>
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litFemaleCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="stat-label">Female</div>
                                    </div>
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litMaleCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="stat-label">Male</div>
                                    </div>
                                </div>
                            </div>

                            <div class="dashboard-card hover-lift" onclick="location.href='Recruitment.aspx'">
                                <div class="card-header">
                                    <span class="card-title">Applicants</span>
                                    <div class="card-icon">
                                        <svg viewBox="0 0 24 24" fill="currentColor">
                                            <path
                                                d="M10 16v-1H3.01L3 19c0 1.11.89 2 2 2h14c1.11 0 2-.89 2-2v-4h-7v1h-4zm10-9h-4.01V5l-2-2h-4l-2 2v2H4c-1.1 0-2 .9-2 2v3c0 1.11.89 2 2 2h6v-2h4v2h6c1.1 0 2-.9 2-2V9c0-1.1-.9-2-2-2zm-6 0h-4V5h4v2z" />
                                        </svg>
                                    </div>
                                </div>
                                <div class="stats-grid">
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litTotalApplicants" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="stat-label">Total</div>
                                    </div>
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litInProgressApplicants" runat="server" Text="0">
                                            </asp:Literal>
                                        </div>
                                        <div class="stat-label">Progress</div>
                                    </div>
                                    <div class="stat-item">
                                        <div class="stat-value">
                                            <asp:Literal ID="litCompletedApplicants" runat="server" Text="0">
                                            </asp:Literal>
                                        </div>
                                        <div class="stat-label">Completed</div>
                                    </div>
                                </div>
                            </div>

                            <div class="dashboard-card hover-lift" onclick="location.href='Announcement.aspx'">
                                <div class="card-header">
                                    <span class="card-title">Announcements</span>
                                    <div class="card-icon">
                                        <svg viewBox="0 0 24 24" fill="currentColor">
                                            <path
                                                d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z" />
                                        </svg>
                                    </div>
                                </div>
                                <ul class="announcement-list">
                                    <asp:PlaceHolder ID="phAnnouncements" runat="server" />
                                </ul>
                            </div>
                        </div>

                        <div class="bottom-section">
                            <div class="large-card" onclick="location.href='Attendance.aspx'">
                                <h2 class="card-title-main">
                                    <svg viewBox="0 0 24 24" fill="currentColor">
                                        <path
                                            d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z" />
                                    </svg>
                                    Attendance Overview - Today
                                </h2>
                                <div class="attendance-stats stagger-animation">
                                    <div class="attendance-stat present">
                                        <div class="attendance-value">
                                            <asp:Literal ID="litPresentCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="attendance-label">Present</div>
                                    </div>
                                    <div class="attendance-stat absent">
                                        <div class="attendance-value">
                                            <asp:Literal ID="litAbsentCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="attendance-label">Absent</div>
                                    </div>
                                    <div class="attendance-stat">
                                        <div class="attendance-value">
                                            <asp:Literal ID="litOnLeaveCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="attendance-label">On Leave</div>
                                    </div>
                                    <div class="attendance-stat">
                                        <div class="attendance-value">
                                            <asp:Literal ID="litLateCount" runat="server" Text="0"></asp:Literal>
                                        </div>
                                        <div class="attendance-label">Late</div>
                                    </div>
                                </div>
                                <div class="attendance-chart">
                                    <canvas id="attendanceChartCanvas"></canvas>
                                </div>
                            </div>

                            <div class="right-column">
                                <div class="large-card" onclick="location.href='Payroll.aspx'">
                                    <h2 class="card-title-main">
                                        <svg viewBox="0 0 24 24" fill="currentColor">
                                            <path
                                                d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                                        </svg>
                                        Employee Summary
                                    </h2>
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
                                                <asp:PlaceHolder ID="phEmployeeSummary" runat="server" />
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <div class="large-card" onclick="location.href='Employee.aspx'">
                                    <h2 class="card-title-main">
                                        <svg viewBox="0 0 24 24" fill="currentColor">
                                            <path
                                                d="M10 16v-1H3.01L3 19c0 1.11.89 2 2 2h14c1.11 0 2-.89 2-2v-4h-7v1h-4zm10-9h-4.01V5l-2-2h-4l-2 2v2H4c-1.1 0-2 .9-2 2v3c0 1.11.89 2 2 2h6v-2h4v2h6c1.1 0 2-.9 2-2V9c0-1.1-.9-2-2-2zm-6 0h-4V5h4v2z" />
                                        </svg>
                                        Working Format
                                    </h2>
                                    <div class="chart-container">
                                        <div class="chart-bar chart-regular">
                                            <div class="bar-wrapper">
                                                <div class="chart-fill"
                                                    style="height: <asp:Literal ID='litRegularPercentage' runat='server' Text='0' />%;">
                                                    <span class="chart-value">
                                                        <asp:Literal ID='litRegularPercentageDisplay' runat='server'
                                                            Text='0%' />
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="chart-label">Regular</div>
                                        </div>
                                        <div class="chart-bar chart-contractual">
                                            <div class="bar-wrapper">
                                                <div class="chart-fill"
                                                    style='height: <asp:Literal ID="litContractualPercentage" runat="server" Text="0" />%;'>
                                                    <span class="chart-value">
                                                        <asp:Literal ID="litContractualPercentageDisplay" runat="server"
                                                            Text="0%" />
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="chart-label">Probationary</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="large-card" style="margin-top: 24px;">
                                <h2 class="card-title-main">
                                    <svg viewBox="0 0 24 24" fill="currentColor">
                                        <path
                                            d="M12 7V3H2v18h20V7H12zM6 19H4v-2h2v2zm0-4H4v-2h2v2zm0-4H4V9h2v2zm0-4H4V5h2v2zm4 12H8v-2h2v2zm0-4H8v-2h2v2zm0-4H8V9h2v2zm0-4H8V5h2v2zm10 12h-8v-2h2v-2h-2v-2h2v-2h-2V9h8v10zm-2-8h-2v2h2v-2zm0 4h-2v2h2v-2z" />
                                    </svg>
                                    Department Headcount
                                </h2>
                                <div class="table-container">
                                    <table class="employee-table">
                                        <thead>
                                            <tr>
                                                <th>Department</th>
                                                <th>Count</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% var headcount=Session["DeptHeadcount"] as Dictionary<string, int>;
                                                if (headcount != null) {
                                                foreach(var item in headcount) {
                                                %>
                                                <tr>
                                                    <td style="font-weight: 600;">
                                                        <%= item.Key %>
                                                    </td>
                                                    <td style="color: #A36A66; font-weight: 800;">
                                                        <%= item.Value %>
                                                    </td>
                                                </tr>
                                                <% } } else { %>
                                                    <tr>
                                                        <td colspan="2">No data available</td>
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
                    // Wait for DOM to be ready
                    document.addEventListener('DOMContentLoaded', function () {
                        // Get attendance data from server-side literals
                        const presentCount = parseInt('<asp:Literal ID="litPresentCountJS" runat="server" Text="0"></asp:Literal>') || 0;
                        const absentCount = parseInt('<asp:Literal ID="litAbsentCountJS" runat="server" Text="0"></asp:Literal>') || 0;
                        const onLeaveCount = parseInt('<asp:Literal ID="litOnLeaveCountJS" runat="server" Text="0"></asp:Literal>') || 0;
                        const lateCount = parseInt('<asp:Literal ID="litLateCountJS" runat="server" Text="0"></asp:Literal>') || 0;

                        // Create the chart
                        const ctx = document.getElementById('attendanceChartCanvas');
                        if (ctx) {
                            new Chart(ctx, {
                                type: 'bar',
                                data: {
                                    labels: ['Present', 'Absent', 'On Leave', 'Late'],
                                    datasets: [{
                                        label: 'Employees',
                                        data: [presentCount, absentCount, onLeaveCount, lateCount],
                                        backgroundColor: [
                                            'rgba(163, 106, 102, 0.8)',  // Present
                                            'rgba(163, 106, 102, 1)',    // Absent
                                            'rgba(163, 106, 102, 0.6)',  // On Leave
                                            'rgba(163, 106, 102, 0.4)'   // Late
                                        ],
                                        borderColor: [
                                            'rgba(163, 106, 102, 1)',
                                            'rgba(163, 106, 102, 1)',
                                            'rgba(163, 106, 102, 1)',
                                            'rgba(163, 106, 102, 1)'
                                        ],
                                        borderWidth: 2,
                                        borderRadius: 8
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: {
                                            display: false
                                        },
                                        title: {
                                            display: false
                                        }
                                    },
                                    scales: {
                                        y: {
                                            beginAtZero: true,
                                            ticks: {
                                                stepSize: 1,
                                                color: '#666'
                                            },
                                            grid: {
                                                color: '#f0f0f0'
                                            }
                                        },
                                        x: {
                                            ticks: {
                                                color: '#666',
                                                font: {
                                                    weight: '600'
                                                }
                                            },
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