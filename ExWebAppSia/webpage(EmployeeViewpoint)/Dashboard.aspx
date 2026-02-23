<%@ Page Title="Employee Dashboard" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm1" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

            :root {
                --primary-color: #A44F56;
                --secondary-color: #DE9D9D;
                --accent-color: #FFE8E8;
                --primary-gradient: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                --secondary-gradient: linear-gradient(135deg, var(--accent-color), #FFF5F5);
                --card-shadow: 0 10px 30px rgba(164, 79, 86, 0.15);
                --hover-shadow: 0 15px 40px rgba(164, 79, 86, 0.25);
                --border-radius: 20px;
                --text-primary: #4A2E2E;
                --text-secondary: #6B4545;
                --text-muted: #9B7B7B;
                --success-color: #10b981;
                --warning-color: #f59e0b;
                --info-color: #3b82f6;
                --border-color: #E8C4C4;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            }

            /* ✅ Unified background — matches EmployeeHR.master & ManagerHR.master */
            body {
                background: linear-gradient(180deg, #F5DDD8 0%, #D4999C 50%, #A85B5B 100%);
                font-family: 'Poppins', sans-serif;
            }

            .dashboard {
                min-height: 100vh;
                padding: 24px;
                font-family: 'Poppins', sans-serif;
            }

            .dashboard-header {
                margin-bottom: 32px;
            }

            .dashboard-title {
                font-size: 32px;
                font-weight: 800;
                color: var(--primary-color);
                margin-bottom: 8px;
                letter-spacing: -0.5px;
                text-shadow: 0 2px 4px rgba(164, 79, 86, 0.1);
                font-family: 'Poppins', sans-serif;
            }

            .dashboard-subtitle {
                font-size: 16px;
                color: var(--text-secondary);
                font-weight: 500;
                font-family: 'Poppins', sans-serif;
            }

            .dashboard-grid {
                display: grid;
                grid-template-columns: 2fr 1fr;
                gap: 24px;
                margin-bottom: 24px;
            }

            .stats-section {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                margin-bottom: 24px;
            }

            .stat-card {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: var(--card-shadow);
                border: 2px solid var(--border-color);
                transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
                position: relative;
                overflow: hidden;
                font-family: 'Poppins', sans-serif;
            }

            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: var(--primary-gradient);
                opacity: 0.8;
            }

            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: var(--hover-shadow);
                border-color: var(--primary-color);
            }

            .stat-header {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 16px;
            }

            .stat-icon {
                width: 48px;
                height: 48px;
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 20px;
                background: rgba(164, 79, 86, 0.1);
                color: var(--primary-color);
                font-family: 'Poppins', sans-serif;
            }

            .attendance-icon {
                background: rgba(164, 79, 86, 0.15);
                color: var(--primary-color);
            }

            .present-icon {
                background: rgba(164, 79, 86, 0.15);
                color: var(--primary-color);
            }

            .absent-icon {
                background: rgba(164, 79, 86, 0.15);
                color: var(--primary-color);
            }

            .late-icon {
                background: rgba(164, 79, 86, 0.15);
                color: var(--primary-color);
            }

            .stat-label {
                font-size: 14px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: 0.8px;
                font-family: 'Poppins', sans-serif;
            }

            .stat-value {
                font-size: 28px;
                font-weight: 800;
                color: var(--primary-color);
                line-height: 1.2;
                font-family: 'Poppins', sans-serif;
            }

            .stat-trend {
                font-size: 13px;
                font-weight: 600;
                margin-top: 4px;
                color: var(--text-secondary);
                font-family: 'Poppins', sans-serif;
            }

            .trend-up {
                color: var(--success-color);
            }

            .trend-down {
                color: #ef4444;
            }

            .profile-card {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: var(--card-shadow);
                border: 2px solid var(--border-color);
                height: fit-content;
                position: relative;
                overflow: hidden;
                font-family: 'Poppins', sans-serif;
            }

            .profile-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: var(--primary-gradient);
                opacity: 0.8;
            }

            .profile-header {
                display: flex;
                align-items: center;
                gap: 16px;
                margin-bottom: 20px;
            }

            .profile-avatar {
                width: 64px;
                height: 64px;
                border-radius: 50%;
                background: var(--primary-gradient);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 24px;
                font-weight: 700;
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.3);
                border: 3px solid white;
                font-family: 'Poppins', sans-serif;
            }

            .profile-info {
                flex: 1;
            }

            .profile-name {
                font-size: 20px;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 4px;
                font-family: 'Poppins', sans-serif;
            }

            .profile-position {
                font-size: 14px;
                color: var(--primary-color);
                font-weight: 600;
                font-family: 'Poppins', sans-serif;
            }

            .profile-status {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background: rgba(164, 79, 86, 0.1);
                color: var(--primary-color);
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                margin-top: 8px;
                border: 1px solid rgba(164, 79, 86, 0.2);
                font-family: 'Poppins', sans-serif;
            }

            .profile-details {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
                margin-top: 20px;
            }

            .detail-item {
                display: flex;
                flex-direction: column;
            }

            .detail-label {
                font-size: 12px;
                color: var(--text-muted);
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 4px;
                font-family: 'Poppins', sans-serif;
            }

            .detail-value {
                font-size: 15px;
                font-weight: 600;
                color: var(--text-primary);
                font-family: 'Poppins', sans-serif;
            }

            .announcements-section {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: var(--card-shadow);
                border: 2px solid var(--border-color);
                position: relative;
                overflow: hidden;
                font-family: 'Poppins', sans-serif;
            }

            .announcements-section::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: var(--primary-gradient);
                opacity: 0.8;
            }

            .section-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 20px;
            }

            .section-title {
                font-size: 20px;
                font-weight: 700;
                color: var(--primary-color);
                font-family: 'Poppins', sans-serif;
            }

            .view-all {
                font-size: 13px;
                color: var(--primary-color);
                font-weight: 600;
                text-decoration: none;
                font-family: 'Poppins', sans-serif;
            }

            .announcement-list {
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .announcement-item {
                padding: 16px;
                border-radius: 12px;
                background: var(--accent-color);
                border-left: 4px solid var(--primary-color);
                transition: transform 0.2s ease, background 0.2s ease;
                font-family: 'Poppins', sans-serif;
            }

            .announcement-item:hover {
                transform: translateX(4px);
                background: #FFF5F5;
            }

            .announcement-date {
                font-size: 12px;
                color: var(--text-muted);
                margin-bottom: 8px;
                font-weight: 500;
                font-family: 'Poppins', sans-serif;
            }

            .announcement-title {
                font-size: 15px;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 6px;
                line-height: 1.4;
                font-family: 'Poppins', sans-serif;
            }

            .announcement-content {
                font-size: 14px;
                color: var(--text-secondary);
                line-height: 1.5;
                font-family: 'Poppins', sans-serif;
            }

            .announcement-badge {
                display: inline-block;
                background: var(--primary-gradient);
                color: white;
                padding: 2px 8px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 600;
                margin-top: 8px;
                font-family: 'Poppins', sans-serif;
            }

            /* Attendance Card Styles */
            .attendance-card {
                width: 100%;
                border-radius: 20px;
                overflow: hidden;
                background: white;
                box-shadow: var(--card-shadow);
                border: 2px solid var(--border-color);
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                margin-bottom: 24px;
                font-family: 'Poppins', sans-serif;
            }

            .attendance-card:hover {
                transform: translateY(-5px);
                box-shadow: var(--hover-shadow);
            }

            .attendance-header-section {
                background: var(--primary-gradient);
                padding: 32px 24px;
                text-align: center;
                position: relative;
                overflow: hidden;
            }

            .attendance-header-section::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
                animation: rotate 20s linear infinite;
            }

            @keyframes rotate {
                from {
                    transform: rotate(0deg);
                }

                to {
                    transform: rotate(360deg);
                }
            }

            .header-logo {
                width: 72px;
                height: 72px;
                background: rgba(255, 255, 255, 0.25);
                backdrop-filter: blur(10px);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 16px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            }

            .header-logo span {
                font-size: 28px;
                font-weight: 800;
                color: white;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
                font-family: 'Poppins', sans-serif;
            }

            .header-title {
                color: white;
                font-size: 28px;
                font-weight: 800;
                margin-bottom: 8px;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
                font-family: 'Poppins', sans-serif;
            }

            .header-subtitle {
                color: rgba(255, 255, 255, 0.9);
                font-size: 16px;
                font-weight: 500;
                font-family: 'Poppins', sans-serif;
            }

            .attendance-main {
                padding: 32px;
                background: linear-gradient(135deg, var(--accent-color), #FFF5F5);
            }

            .date-time-container {
                display: flex;
                flex-wrap: wrap;
                gap: 16px;
                margin-bottom: 32px;
                justify-content: space-between;
            }

            .current-date {
                background: white;
                padding: 12px 20px;
                border-radius: 16px;
                font-weight: 700;
                color: var(--text-primary);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                display: flex;
                align-items: center;
                gap: 8px;
                font-family: 'Poppins', sans-serif;
            }

            .current-time {
                background: white;
                padding: 12px 20px;
                border-radius: 16px;
                font-weight: 700;
                color: var(--text-primary);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                display: flex;
                align-items: center;
                gap: 8px;
                font-family: 'Poppins', monospace;
            }

            .attendance-content-grid {
                display: grid;
                grid-template-columns: 2fr 1fr;
                gap: 28px;
            }

            @media (max-width: 768px) {
                .attendance-content-grid {
                    grid-template-columns: 1fr;
                    gap: 24px;
                }

                .date-time-container {
                    flex-direction: column;
                }
            }

            .info-section {
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            .info-card {
                background: white;
                border-radius: 18px;
                padding: 24px;
                box-shadow: 0 8px 24px rgba(164, 79, 86, 0.08);
                border: 1px solid var(--border-color);
                transition: transform 0.2s ease;
                font-family: 'Poppins', sans-serif;
            }

            .info-card:hover {
                transform: translateY(-2px);
            }

            .info-header {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 16px;
            }

            .info-icon {
                width: 40px;
                height: 40px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 18px;
                font-family: 'Poppins', sans-serif;
            }

            .employee-icon {
                background: rgba(59, 130, 246, 0.15);
                color: #3b82f6;
            }

            .status-icon {
                background: rgba(16, 185, 129, 0.15);
                color: #10b981;
            }

            .location-icon-bg {
                background: rgba(245, 158, 11, 0.15);
                color: #f59e0b;
            }

            .info-label {
                font-size: 14px;
                font-weight: 600;
                color: var(--text-secondary);
                text-transform: uppercase;
                letter-spacing: 0.5px;
                font-family: 'Poppins', sans-serif;
            }

            .info-value {
                font-size: 24px;
                font-weight: 800;
                color: var(--text-primary);
                line-height: 1.2;
                font-family: 'Poppins', sans-serif;
            }

            .info-note {
                background: rgba(59, 130, 246, 0.08);
                border-left: 4px solid #3b82f6;
                padding: 16px;
                border-radius: 0 12px 12px 0;
                margin-top: 16px;
                font-size: 14px;
                color: var(--text-secondary);
                line-height: 1.5;
                font-family: 'Poppins', sans-serif;
            }

            .actions-section {
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .action-btn {
                padding: 16px 20px;
                border-radius: 16px;
                font-weight: 700;
                font-size: 16px;
                cursor: pointer;
                border: none;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                text-align: center;
                font-family: 'Poppins', sans-serif;
            }

            .btn-time-in {
                background: linear-gradient(135deg, #10b981, #34d399);
                color: white;
                box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
            }

            .btn-time-in:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 12px 25px rgba(16, 185, 129, 0.4);
            }

            .btn-time-out {
                background: linear-gradient(135deg, #f59e0b, #fbbf24);
                color: white;
                box-shadow: 0 8px 20px rgba(245, 158, 11, 0.3);
            }

            .btn-time-out:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 12px 25px rgba(245, 158, 11, 0.4);
            }

            .btn-status {
                background: white;
                color: var(--text-primary);
                border: 2px solid var(--border-color);
                font-weight: 700;
            }

            .btn-status:hover {
                border-color: var(--primary-color);
                transform: translateY(-2px);
                box-shadow: 0 8px 16px rgba(164, 79, 86, 0.1);
            }

            .action-btn:disabled {
                opacity: 0.65;
                cursor: not-allowed;
                transform: none;
            }

            .stats-card {
                background: white;
                border-radius: 18px;
                padding: 20px;
                box-shadow: 0 8px 24px rgba(164, 79, 86, 0.08);
                margin-top: 16px;
                font-family: 'Poppins', sans-serif;
            }

            .stats-title {
                font-size: 16px;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 16px;
                text-align: center;
                font-family: 'Poppins', sans-serif;
            }

            .stats-item {
                display: flex;
                justify-content: space-between;
                padding: 8px 0;
                border-bottom: 1px solid var(--border-color);
                font-family: 'Poppins', sans-serif;
            }

            .stats-item:last-child {
                border-bottom: none;
            }

            .stats-label {
                color: var(--text-secondary);
                font-size: 14px;
                font-family: 'Poppins', sans-serif;
            }

            .stats-value {
                font-weight: 700;
                color: var(--text-primary);
                font-family: 'Poppins', sans-serif;
            }

            .success-value {
                color: var(--success-color);
            }

            .warning-value {
                color: var(--warning-color);
            }

            /* Icons using Unicode characters */
            .icon::before {
                font-weight: bold;
            }

            .user-icon::before {
                content: "👤";
            }

            .check-icon::before {
                content: "✓";
            }

            .location-icon::before {
                content: "📍";
            }

            .clock-icon::before {
                content: "🕒";
            }

            .calendar-icon::before {
                content: "📅";
            }

            .time-in-icon::before {
                content: "🔽";
            }

            .time-out-icon::before {
                content: "🔼";
            }

            /* Responsive design */
            @media (max-width: 1024px) {
                .dashboard-grid {
                    grid-template-columns: 1fr;
                }

                .profile-details {
                    grid-template-columns: 1fr;
                }
            }

            @media (max-width: 768px) {
                .stats-section {
                    grid-template-columns: 1fr;
                }

                .dashboard-title {
                    font-size: 28px;
                }

                .stat-value {
                    font-size: 24px;
                }
            }

            @media (max-width: 480px) {
                .dashboard {
                    padding: 16px;
                }

                .stat-card,
                .profile-card,
                .announcements-section {
                    padding: 20px;
                }
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="dashboard">


            <!-- Attendance Card -->
            <div class="attendance-card" role="region" aria-label="Attendance card">
                <div class="attendance-header-section">
                    <div class="header-logo">
                        <span>ME</span>
                    </div>
                    <h1 class="header-title">Today's Attendance</h1>
                    <p class="header-subtitle">Log your time in and out</p>
                </div>

                <div class="attendance-main">
                    <div class="date-time-container">
                        <div id="currentDate" class="current-date">
                            <span class="calendar-icon icon"></span>
                            <span>--</span>
                        </div>
                        <div id="currentTime" class="current-time">
                            <span class="clock-icon icon"></span>
                            <span>--:--:--</span>
                        </div>
                    </div>

                    <div class="attendance-content-grid">
                        <div class="info-section">
                            <div class="info-card">
                                <div class="info-header">
                                    <div class="info-icon employee-icon">
                                        <span class="user-icon icon"></span>
                                    </div>
                                    <div class="info-label">Employee</div>
                                </div>
                                <div class="info-value">
                                    <%= GetEmployeeName() %>
                                </div>
                            </div>

                            <div class="info-card">
                                <div class="info-header">
                                    <div class="info-icon status-icon">
                                        <span class="check-icon icon"></span>
                                    </div>
                                    <div class="info-label">Attendance Status</div>
                                </div>
                                <div class="info-value" id="attendanceStatus">Not timed in yet</div>
                            </div>

                            <div class="info-card">
                                <div class="info-header">
                                    <div class="info-icon status-icon">
                                        <span class="clock-icon icon"></span>
                                    </div>
                                    <div class="info-label">Standard Shift</div>
                                </div>
                                <div class="info-value">08:00 AM - 05:00 PM</div>
                                <div style="font-size: 13px; color: var(--text-muted); margin-top: 5px;">Monday - Friday
                                </div>
                            </div>

                            <div class="info-note">
                                <div style="margin-bottom: 8px;">
                                    <strong>Status:</strong> <span class="badge"
                                        style="background: var(--accent-color); color: var(--primary-color); padding: 2px 8px; border-radius: 4px; font-weight: 700;">
                                        <%= CurrentEmployee?.EmploymentStatus %>
                                    </span>
                                </div>
                                Press <strong>Time In</strong> when you start your shift and <strong>Time Out</strong>
                                when you leave. Both are required for a complete attendance record.
                            </div>
                        </div>

                        <div class="actions-section">
                            <button id="timeInBtn" class="action-btn btn-time-in" onclick="timeIn()">
                                <span class="time-in-icon icon"></span>
                                TIME IN
                            </button>
                            <button id="timeOutBtn" class="action-btn btn-time-out" onclick="timeOut()" disabled>
                                <span class="time-out-icon icon"></span>
                                TIME OUT
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Employee data from server
            const employeeId = '<%= GetEmployeeId() %>';
            const employeeName = '<%= GetEmployeeName() %>';
            const employeeDepartment = '<%= GetEmployeeDepartment() %>';
            const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';

            // Load attendance status from server
            const attendanceStatus = <%= GetAttendanceStatusJsonString() %>;
            console.log('Dashboard initialized - EmployeeId:', employeeId, 'EmployeeName:', employeeName, 'Department:', employeeDepartment);
            console.log('Handler URL:', handlerUrl);
            console.log('Attendance Status:', attendanceStatus);

            // State flags - initialize from server data
            let hasTimedIn = attendanceStatus.hasTimedIn || false;
            let hasTimedOut = attendanceStatus.hasTimedOut || false;

            // Update date and time in real-time
            function updateDateTime() {
                const now = new Date();
                const dateOpts = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' };
                const timeOpts = { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true };

                document.getElementById('currentDate').innerHTML =
                    '<span class="calendar-icon icon"></span> ' + now.toLocaleDateString(undefined, dateOpts);
                document.getElementById('currentTime').innerHTML =
                    '<span class="clock-icon icon"></span> ' + now.toLocaleTimeString(undefined, timeOpts);
            }

            // Initialize and update every second
            updateDateTime();
            setInterval(updateDateTime, 1000);

            // Load today's attendance status on page load
            function loadTodayStatus() {
                try {
                    const statusEl = document.getElementById('attendanceStatus');
                    const timeInBtn = document.getElementById('timeInBtn');
                    const timeOutBtn = document.getElementById('timeOutBtn');

                    // Update UI based on server-side status
                    if (attendanceStatus.hasTimedIn) {
                        hasTimedIn = true;
                        const timeInStr = attendanceStatus.timeIn || 'earlier today';

                        if (attendanceStatus.hasTimedOut) {
                            // Employee has timed out - allow time in again for new shift
                            hasTimedOut = true;
                            const timeOutStr = attendanceStatus.timeOut || 'earlier today';
                            statusEl.textContent = `Timed Out at ${timeOutStr}`;
                            statusEl.style.color = '#f59e0b';
                            timeInBtn.disabled = false; // Allow time in again
                            timeOutBtn.disabled = true;
                            hasTimedIn = false; // Reset flag to allow new time in
                        } else {
                            // Employee has timed in but not timed out yet
                            statusEl.textContent = `Timed In at ${timeInStr}`;
                            statusEl.style.color = '#10b981';
                            timeInBtn.disabled = true;
                            timeOutBtn.disabled = false;
                        }
                    } else {
                        statusEl.textContent = 'Not timed in yet';
                        statusEl.style.color = '';
                        timeInBtn.disabled = false;
                        timeOutBtn.disabled = true;
                    }

                    console.log('Status loaded - hasTimedIn:', hasTimedIn, 'hasTimedOut:', hasTimedOut);
                } catch (error) {
                    console.error('Error loading attendance status:', error);
                }
            }

            // Call loadTodayStatus when page loads
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', loadTodayStatus);
            } else {
                loadTodayStatus();
            }

            async function timeIn() {
                // Allow time in if employee has timed out (for new shift)
                if (hasTimedIn && !hasTimedOut) {
                    alert('You have already timed in today. Please time out first.');
                    return;
                }

                if (!employeeId || employeeId === 'N/A') {
                    alert('Employee ID not found. Please contact HR.');
                    return;
                }

                const timeInBtn = document.getElementById('timeInBtn');
                const timeOutBtn = document.getElementById('timeOutBtn');
                const statusEl = document.getElementById('attendanceStatus');

                // Disable button during request
                timeInBtn.disabled = true;
                timeInBtn.textContent = 'Processing...';

                try {
                    const params = new URLSearchParams({
                        action: 'timein',
                        employeeId: employeeId,
                        employeeName: employeeName,
                        department: employeeDepartment
                    });

                    const fullUrl = handlerUrl + '?' + params.toString();
                    console.log('Calling handler:', fullUrl);

                    // Add timeout to prevent hanging
                    const controller = new AbortController();
                    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

                    let response;
                    try {
                        response = await fetch(fullUrl, {
                            method: 'GET',
                            headers: {
                                'Accept': 'application/json'
                            },
                            signal: controller.signal
                        });
                        clearTimeout(timeoutId);
                    } catch (fetchError) {
                        clearTimeout(timeoutId);
                        if (fetchError.name === 'AbortError') {
                            throw new Error('Request timed out. Please check if the server is running and the handler is accessible.');
                        }
                        throw fetchError;
                    }

                    console.log('Response status:', response.status);

                    if (!response.ok) {
                        const text = await response.text();
                        console.error('Response error:', text);
                        throw new Error('Server returned error: ' + response.status + ' - ' + text);
                    }

                    const responseText = await response.text();
                    console.log('Response text:', responseText);

                    let result;
                    try {
                        result = JSON.parse(responseText);
                    } catch (parseError) {
                        console.error('JSON parse error:', parseError, 'Response:', responseText);
                        throw new Error('Invalid response from server: ' + responseText);
                    }

                    console.log('Parsed result:', result);

                    if (result.success) {
                        // Refresh the page to load the updated status from the server
                        window.location.reload();
                    } else {
                        alert(result.message || 'Failed to record time in. You may have already timed in today.');
                        timeInBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('An error occurred while recording time in: ' + error.message + '\n\nPlease check the browser console for details.');
                    timeInBtn.disabled = false;
                } finally {
                    if (!hasTimedIn) {
                        timeInBtn.textContent = 'TIME IN';
                    }
                }
            }

            async function timeOut() {
                if (hasTimedOut) {
                    alert('You have already timed out today.');
                    return;
                }

                if (!hasTimedIn) {
                    alert('Please time in first before timing out.');
                    return;
                }

                if (!employeeId || employeeId === 'N/A') {
                    alert('Employee ID not found. Please contact HR.');
                    return;
                }

                const timeOutBtn = document.getElementById('timeOutBtn');
                const statusEl = document.getElementById('attendanceStatus');

                // Disable button during request
                timeOutBtn.disabled = true;
                timeOutBtn.textContent = 'Processing...';

                try {
                    const params = new URLSearchParams({
                        action: 'timeout',
                        employeeId: employeeId
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString(), {
                        method: 'GET'
                    });

                    const result = await response.json();

                    if (result.success) {
                        // Refresh the page to load the updated status from the server
                        window.location.reload();
                    } else {
                        alert(result.message || 'Failed to record time out. Please make sure you have timed in first.');
                        timeOutBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('An error occurred while recording time out. Please try again.');
                    timeOutBtn.disabled = false;
                } finally {
                    timeOutBtn.textContent = 'TIME OUT';
                }
            }

            function showStatus() {
                const status = document.getElementById('attendanceStatus').textContent;
                alert('Current attendance status:\n' + status);
            }
        </script>
    </asp:Content>