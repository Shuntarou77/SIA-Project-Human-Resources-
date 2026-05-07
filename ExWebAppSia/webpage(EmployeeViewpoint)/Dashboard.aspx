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
                background: #fdfaf9;
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

            .btn-overtime {
                background: linear-gradient(135deg, #8b5cf6, #a78bfa);
                color: white;
                box-shadow: 0 8px 20px rgba(139, 92, 246, 0.3);
                margin-top: 8px;
            }

            .btn-overtime:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 12px 25px rgba(139, 92, 246, 0.4);
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

            /* Custom Modal Styles */
            .custom-modal-v2 {
                display: none;
                position: fixed;
                z-index: 100000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.8);
                backdrop-filter: blur(5px);
                align-items: center;
                justify-content: center;
            }

            .custom-modal-v2.active {
                display: flex !important;
            }

            .custom-modal-v2-content {
                background: white;
                margin: auto;
                padding: 0;
                border-radius: 20px;
                width: 90%;
                max-width: 450px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                animation: customSlideDown 0.3s ease;
                font-family: 'Poppins', sans-serif;
                position: relative;
                overflow: hidden;
            }

            .custom-modal-v2-header {
                padding: 16px 24px;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-family: 'Poppins', sans-serif;
            }

            .custom-modal-v2-title {
                margin: 0;
                font-size: 1.25rem;
                font-weight: 700;
                font-family: 'Poppins', sans-serif;
            }

            .custom-modal-v2-body {
                padding: 24px;
                font-family: 'Poppins', sans-serif;
            }

            .custom-modal-v2-footer {
                padding: 16px 24px;
                display: flex;
                gap: 12px;
                justify-content: flex-end;
                border-top: 1px solid var(--border-color);
                font-family: 'Poppins', sans-serif;
            }

            .btn-submit,
            .btn-cancel {
                padding: 10px 24px;
                border: none;
                border-radius: 10px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                font-family: 'Poppins', sans-serif;
            }

            .btn-submit {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
            }

            .btn-cancel {
                background: #E5E7EB;
                color: var(--text-primary);
            }

            .close {
                color: white;
                float: right;
                font-size: 32px;
                font-weight: bold;
                cursor: pointer;
                line-height: 1;
                font-family: 'Poppins', sans-serif;
            }

            @keyframes customSlideDown {
                from {
                    opacity: 0;
                    transform: translateY(-50px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
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
                                    <div class="info-icon status-icon" style="background: rgba(245, 158, 11, 0.15); color: #f59e0b;">
                                        <span class="icon">📅</span>
                                    </div>
                                    <div class="info-label">Absence Allowance</div>
                                </div>
                                <div class="info-value" style="color: #f59e0b;"><%= GetRemainingAbsences() %> Days</div>
                                <div style="font-size: 13px; color: var(--text-muted); margin-top: 5px;">Remaining for this year</div>
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
                            <button id="timeInBtn" type="button" class="action-btn btn-time-in" onclick="timeIn()">
                                <span class="time-in-icon icon"></span>
                                TIME IN
                            </button>
                            <button id="timeOutBtn" type="button" class="action-btn btn-time-out" onclick="timeOut()">
                                <span class="time-out-icon icon"></span>
                                TIME OUT
                            </button>
                            <button id="overtimeBtn" type="button" class="action-btn btn-overtime" onclick="openOvertimeModal()" style="display: none;">
                                <span class="clock-icon icon" style="font-style: normal;">⏰</span>
                                REQUEST OVERTIME
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Undertime Warning Modal -->
        <div id="undertimeModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 550px;">
                <div class="custom-modal-v2-header" style="background: var(--primary-gradient); border: none;">
                    <span class="close" onclick="closeModal('undertimeModal')" style="color: white; opacity: 1;">&times;</span>
                    <h2 class="custom-modal-v2-title" style="color: white;">⚠️ Early Time Out</h2>
                </div>
                <!-- Initial Question Body -->
                <div class="custom-modal-v2-body" id="undertimeQuestionBody" style="text-align: center; padding: 40px 30px;">
                    <div style="font-size: 50px; margin-bottom: 20px;">🕒</div>
                    <h3 style="color: var(--text-primary); margin-bottom: 15px;">Early Departure Detected</h3>
                    <p style="color: var(--text-secondary); line-height: 1.6; margin-bottom: 25px;">
                        It's not yet 5:00 PM. Please select the type of undertime you are filing:
                    </p>
                    <div style="display: flex; flex-direction: column; gap: 15px; align-items: center;">
                        <button type="button" class="action-btn" style="background: #ef4444; color: white; width: 100%; border: none; font-weight: 700; padding: 15px;" onclick="emergencyQuickNotify()">🚨 EMERGENCY UT QUICK NOTIFY</button>
                        <button type="button" class="action-btn" style="background: var(--info-color); color: white; width: 100%; border: none; font-weight: 700; padding: 15px;" onclick="showRegularUndertimeForm()">📝 REGULAR UT REQUEST</button>
                    </div>
                    <div style="margin-top: 20px; font-size: 13px; color: var(--text-muted);">
                        Already have an approved request? <a href="javascript:void(0)" onclick="checkUndertimeRequestStatus()" style="color: var(--primary-color); font-weight: 600;">Check status here</a>
                    </div>
                </div>
                
                <!-- Undertime Form Body (Regular) -->
                <div class="custom-modal-v2-body" id="undertimeFormBody" style="display: none; padding: 30px; text-align: left;">
                    <button type="button" onclick="showUndertimeQuestion()" style="background:none; border:none; color:var(--text-muted); cursor:pointer; margin-bottom:15px; display:flex; align-items:center; gap:5px; font-weight:600;">
                        <span>← Back</span>
                    </button>
                    <h3 style="color: var(--text-primary); margin-bottom: 15px; text-align: center;">Regular Undertime Request</h3>
                    <p style="color: var(--text-secondary); font-size: 14px; margin-bottom: 20px;">
                        Please fill in the details for your regular undertime request.
                    </p>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div>
                            <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--text-primary); font-size: 13px;">Departure Date:</label>
                            <input type="date" id="utDate" style="width: 100%; border: 1.5px solid var(--border-color); border-radius: 12px; padding: 10px; font-size: 13px; outline: none;" />
                        </div>
                        <div>
                            <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--text-primary); font-size: 13px;">Departure Time:</label>
                            <input type="time" id="utTime" style="width: 100%; border: 1.5px solid var(--border-color); border-radius: 12px; padding: 10px; font-size: 13px; outline: none;" />
                        </div>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: 600; margin-bottom: 8px; color: var(--text-primary); font-size: 13px;">Departure Reason:</label>
                        <textarea id="utReason" style="width: 100%; border: 1.5px solid var(--border-color); border-radius: 12px; padding: 12px; height: 80px; resize: none; font-family: inherit; font-size: 13px;" placeholder="e.g., Medical appointment, Personal errands, etc."></textarea>
                    </div>
                    <div style="background: #F0F9FF; border-left: 4px solid #3b82f6; padding: 12px; border-radius: 4px; margin-top: 10px;">
                        <p style="color: #1e3a8a; font-size: 13px; font-weight: 600;">
                            Note: This requires HR STAFF approval before timing out.
                        </p>
                    </div>
                    <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 25px;">
                        <button type="button" class="btn-cancel" onclick="closeModal('undertimeModal')">Cancel</button>
                        <button type="button" class="action-btn btn-status" id="btnSubmitUT" style="background: var(--primary-color); color: white; width: fit-content; border: none; padding: 8px 20px;" onclick="submitUndertimeRequest('Regular')">Submit Request</button>
                    </div>
                </div>

                <!-- Status Check Body -->
                <div class="custom-modal-v2-body" id="undertimeStatusBody" style="display: none; padding: 40px 30px; text-align: center;">
                    <div style="font-size: 60px; margin-bottom: 20px;">⏳</div>
                    <h3 id="utStatusTitle" style="color: var(--text-primary); margin-bottom: 10px;">Checking status...</h3>
                    <p id="utStatusMessage" style="color: var(--text-secondary); line-height: 1.6;"></p>
                    <button type="button" class="action-btn btn-status" style="margin: 25px auto 0; width: 150px; border: 2px solid var(--border-color);" onclick="closeModal('undertimeModal')">Close</button>
                </div>
            </div>
        </div>

        <!-- Overtime Request Modal -->
        <div id="overtimeModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 450px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <span class="close" onclick="closeModal('overtimeModal')">&times;</span>
                    <h2 class="custom-modal-v2-title">⏰ Request Overtime</h2>
                </div>
                <div class="custom-modal-v2-body" style="padding: 30px;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <div style="font-size: 50px; margin-bottom: 10px;">⏳</div>
                        <h3 style="color: var(--text-primary);">Extended Shift Request</h3>
                        <p style="color: var(--text-secondary); font-size: 14px; margin-bottom: 20px;">
                            Maximum overtime is 8 hours (total 16-hour shift).
                        </p>
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Date of Overtime *</label>
                        <input type="date" id="txtOvertimeDate" style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; font-size: 14px;" />
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div class="form-group">
                            <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Start Time *</label>
                            <input type="time" id="txtOvertimeStart" style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; font-size: 14px;" onchange="calculateOTHours()" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">End Time *</label>
                            <input type="time" id="txtOvertimeEnd" style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; font-size: 14px;" onchange="calculateOTHours()" />
                        </div>
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Total Hours Requested *</label>
                        <input type="number" id="txtOvertimeHours" step="0.1" min="0" style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; font-size: 14px;" placeholder="Calculated hours..." />
                    </div>
                    <div style="margin-bottom: 20px;">
                        <label for="txtOvertimeReason" style="display: block; font-weight: 600; color: var(--text-primary); margin-bottom: 8px;">Detailed Justification *</label>
                        <textarea id="txtOvertimeReason" rows="3" class="form-control" 
                            style="width: 100%; padding: 12px; border-radius: 10px; border: 2px solid var(--border-color); font-family: inherit; resize: none;"
                            placeholder="Provide a detailed justification for the work..."></textarea>
                    </div>
                    <div style="background: #F5F3FF; border-left: 4px solid #8b5cf6; padding: 15px; border-radius: 0 8px 8px 0;">
                        <p style="color: #5b21b6; font-size: 13px; font-weight: 600;">
                            Note: Your request will be sent to Admin for approval. You will be automatically timed out after 16 hours of total work.
                        </p>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('overtimeModal')">Cancel</button>
                    <button type="button" class="btn-submit" style="background: #8b5cf6;" onclick="submitOvertimeRequest()">Submit Request</button>
                </div>
            </div>
        </div>
        <!-- Custom Confirm Modal -->
        <div id="confirmModal" class="custom-modal-v2" style="display:none;">
            <div class="custom-modal-v2-content" style="max-width: 440px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #ef4444, #dc2626); border: none;">
                    <span class="close" onclick="closeConfirmModal()" style="color: white; opacity: 1;">&times;</span>
                    <h2 id="confirmModalTitle" class="custom-modal-v2-title" style="color: white;">Confirm Action</h2>
                </div>
                <div class="custom-modal-v2-body" style="text-align: center; padding: 40px 30px;">
                    <div id="confirmModalIcon" style="font-size: 60px; margin-bottom: 20px;">⚠️</div>
                    <p id="confirmModalMessage" style="color: var(--text-primary); font-size: 15px; font-weight: 500; line-height: 1.6;"></p>
                </div>
                <div class="custom-modal-v2-footer" style="justify-content: center; gap: 15px; padding-bottom: 30px;">
                    <button type="button" class="btn-cancel" onclick="closeConfirmModal()">Cancel</button>
                    <button type="button" id="confirmModalOkBtn" class="btn-submit" style="background: #ef4444; min-width: 120px;">Confirm</button>
                </div>
            </div>
        </div>

        <!-- Notification Modal (Success/Error) -->
        <div id="notificationModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 400px; transform: scale(0.9); transition: transform 0.3s ease;">
                <div id="notificationHeader" class="custom-modal-v2-header" style="background: linear-gradient(135deg, #10b981, #059669);">
                    <span class="close" onclick="closeModal('notificationModal')">&times;</span>
                    <h2 id="notificationTitle" class="custom-modal-v2-title">Notification</h2>
                </div>
                <div class="custom-modal-v2-body" style="text-align: center; padding: 40px 30px;">
                    <div id="notificationIcon" style="font-size: 60px; margin-bottom: 20px;">✅</div>
                    <p id="notificationMessage" style="color: var(--text-primary); font-size: 16px; font-weight: 500; line-height: 1.6;"></p>
                </div>
                <div class="custom-modal-v2-footer" style="justify-content: center; padding-bottom: 30px;">
                    <button type="button" class="btn-submit" style="min-width: 120px; background: #10b981;" onclick="closeModal('notificationModal')">OK</button>
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

            // -------- Custom Confirm Modal Helper --------
            let _confirmCallback = null;

            function showConfirm(title, message, icon, onConfirm) {
                document.getElementById('confirmModalTitle').textContent = title;
                document.getElementById('confirmModalMessage').textContent = message;
                document.getElementById('confirmModalIcon').textContent = icon || '⚠️';
                _confirmCallback = onConfirm;
                document.getElementById('confirmModalOkBtn').onclick = function () {
                    if (_confirmCallback) _confirmCallback();
                    closeConfirmModal();
                };
                const modal = document.getElementById('confirmModal');
                modal.classList.add('active');
                modal.style.display = 'flex';
            }

            function closeConfirmModal() {
                const modal = document.getElementById('confirmModal');
                modal.classList.remove('active');
                modal.style.display = 'none';
                _confirmCallback = null;
            }
            // ---------------------------------------------

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

            function showNotification(message, isSuccess = true, callback = null) {
                const modal = document.getElementById('notificationModal');
                const header = document.getElementById('notificationHeader');
                const title = document.getElementById('notificationTitle');
                const icon = document.getElementById('notificationIcon');
                const messageEl = document.getElementById('notificationMessage');
                const btn = modal.querySelector('.btn-submit');

                messageEl.textContent = message;
                
                // Clear previous onclick and set new one
                btn.onclick = function() {
                    closeModal('notificationModal');
                    if (callback && typeof callback === 'function') {
                        callback();
                    }
                };

                if (isSuccess) {
                    header.style.background = 'linear-gradient(135deg, #10b981, #059669)';
                    title.textContent = 'Success';
                    icon.textContent = '✅';
                    btn.style.background = '#10b981';
                } else {
                    header.style.background = 'linear-gradient(135deg, #ef4444, #dc2626)';
                    title.textContent = 'Error';
                    icon.textContent = '❌';
                    btn.style.background = '#ef4444';
                }

                modal.classList.add('active');
                modal.style.display = 'flex';
                setTimeout(() => {
                    modal.querySelector('.custom-modal-v2-content').style.transform = 'scale(1)';
                }, 10);
            }

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
                            // Employee has timed out
                            hasTimedOut = true;
                            const timeOutStr = attendanceStatus.timeOut || 'earlier today';
                            statusEl.textContent = `Timed Out at ${timeOutStr}`;
                            if (attendanceStatus.overtime) {
                                statusEl.textContent += ` (OT Worked: ${attendanceStatus.overtime})`;
                            }
                            statusEl.style.color = '#f59e0b';
                            timeInBtn.disabled = false;
                            timeOutBtn.disabled = true; // Still disabled if already timed out for that shift
                            hasTimedIn = false;
                            
                            // Hide OT button if timed out
                            document.getElementById('overtimeBtn').style.display = 'none';
                        } else {
                            // Employee has timed in but not timed out yet
                            statusEl.textContent = `Timed In at ${timeInStr}`;
                            statusEl.style.color = '#10b981';
                            timeInBtn.disabled = true;
                            timeOutBtn.disabled = false; // Enabled for valid timeout
                            
                            // Handle Overtime Button/Status
                            const otBtn = document.getElementById('overtimeBtn');
                            if (attendanceStatus.overtimeStatus === 'Approved') {
                                statusEl.textContent += ' (Overtime Approved)';
                                statusEl.style.color = '#8b5cf6';
                                otBtn.style.display = 'flex';
                                otBtn.disabled = true;
                                otBtn.innerHTML = '<span class="check-icon icon"></span> OVERTIME APPROVED';
                            } else if (attendanceStatus.overtimeStatus === 'Pending') {
                                statusEl.textContent += ' (Overtime Pending)';
                                statusEl.style.color = '#f59e0b';
                                otBtn.style.display = 'flex';
                                otBtn.disabled = true;
                                otBtn.innerHTML = '<span class="clock-icon icon"></span> OT REQUEST PENDING';
                            } else if (attendanceStatus.overtimeStatus === 'Rejected') {
                                statusEl.textContent += ' (Overtime Rejected)';
                                statusEl.style.color = '#ef4444';
                                otBtn.style.display = 'none';
                            } else {
                                // Rule: OT button only appears starting 3:00 PM (2 hours before shift ends)
                                const now = new Date();
                                const isOTTime = now.getHours() >= 15;
                                otBtn.style.display = isOTTime ? 'flex' : 'none';
                            }
                        }
                    } else {
                        statusEl.textContent = 'Not timed in yet';
                        statusEl.style.color = '';
                        timeInBtn.disabled = false;
                        // We keep the button enabled visually but handle it in JS for better feedback
                        timeOutBtn.disabled = false;
                        document.getElementById('overtimeBtn').style.display = 'none';
                    }

                    console.log('Status loaded - hasTimedIn:', hasTimedIn, 'hasTimedOut:', hasTimedOut);
                } catch (error) {
                    console.error('Error loading attendance status:', error);
                }
            }

            function openOvertimeModal() {
                if (!hasTimedIn) {
                    showNotification('Please time in first before requesting overtime.', false);
                    return;
                }
                const modal = document.getElementById('overtimeModal');
                if (modal) {
                    modal.classList.add('active');
                    
                    // Set min date to today to prevent past dates
                    const today = new Date().toISOString().split('T')[0];
                    const dateInput = document.getElementById('txtOvertimeDate');
                    dateInput.min = today;
                    dateInput.value = today;
                }
            }

            function calculateOTHours() {
                const start = document.getElementById('txtOvertimeStart').value;
                const end = document.getElementById('txtOvertimeEnd').value;
                if (!start || !end) return;

                const startDate = new Date(`2000-01-01T${start}`);
                const endDate = new Date(`2000-01-01T${end}`);
                
                let diff = (endDate - startDate) / (1000 * 60 * 60);
                if (diff < 0) diff += 24;

                document.getElementById('txtOvertimeHours').value = diff.toFixed(1);
            }

            async function submitOvertimeRequest() {
                const reason = document.getElementById('txtOvertimeReason').value.trim();
                const otDate = document.getElementById('txtOvertimeDate').value;
                const startTime = document.getElementById('txtOvertimeStart').value;
                const endTime = document.getElementById('txtOvertimeEnd').value;
                const requestedHours = document.getElementById('txtOvertimeHours').value;

                if (!reason || !otDate || !startTime || !endTime || !requestedHours) {
                    showNotification('Please fill in all required fields.', false);
                    return;
                }

                // Date Validation: Current or Future
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const selectedDate = new Date(otDate);
                if (selectedDate < today) {
                    showNotification('Overtime date cannot be in the past. Please select today or a future date.', false);
                    return;
                }

                // Time Validation: Must be after 5:00 PM (17:00)
                const startHour = parseInt(startTime.split(':')[0]);
                if (startHour < 17 && startHour >= 8) {
                    showNotification('Overtime must be requested for hours after standard shift ends (5:00 PM).', false);
                    return;
                }

                const submitBtn = document.querySelector('#overtimeModal .btn-submit');
                
                submitBtn.disabled = true;
                submitBtn.textContent = 'Submitting...';

                try {
                    const params = new URLSearchParams({
                        action: 'requestovertime',
                        employeeId: employeeId,
                        reason: reason,
                        otDate: otDate,
                        startTime: startTime,
                        endTime: endTime,
                        requestedHours: requestedHours
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        showNotification('Overtime request submitted successfully!', true, () => {
                            window.location.reload();
                        });
                    } else {
                        showNotification(result.message || 'Failed to submit overtime request.', false);
                        submitBtn.disabled = false;
                        submitBtn.textContent = 'Submit Request';
                    }
                } catch (error) {
                    console.error('Error submitting overtime request:', error);
                    showNotification('An error occurred. Please try again.', false);
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Submit Request';
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
                    showNotification('You have already timed in today. Please time out first.', false);
                    return;
                }

                if (!employeeId || employeeId === 'N/A') {
                    showNotification('Employee ID not found. Please contact HR.', false);
                    return;
                }

                // Client-side late check (8:16 AM cutoff)
                const now = new Date();
                const hours = now.getHours();
                const minutes = now.getMinutes();
                if (hours > 8 || (hours === 8 && minutes >= 16)) {
                    showNotification('Time-in is restricted after 8:16 AM. You are late by 16 minutes or more and cannot time-in for today. Please contact HR.', false);
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
                        showNotification('Time in recorded successfully!', true, () => {
                            window.location.reload();
                        });
                    } else {
                        showNotification(result.message || 'Failed to record time in. You may have already timed in today.', false);
                        timeInBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showNotification('An error occurred while recording time in: ' + error.message, false);
                    timeInBtn.disabled = false;
                } finally {
                    if (!hasTimedIn) {
                        timeInBtn.textContent = 'TIME IN';
                    }
                }
            }

            async function timeOut() {
                if (hasTimedOut) {
                    showNotification('You have already timed out today.', false);
                    return;
                }

                if (!hasTimedIn) {
                    showNotification('Please time in first before timing out.', false);
                    return;
                }

                const now = new Date();
                const currentHour = now.getHours();

                // If it's before 5:00 PM (17:00), show undertime workflow
                if (currentHour < 17) {
                    // Reset modal state
                    document.getElementById('undertimeQuestionBody').style.display = 'block';
                    document.getElementById('undertimeFormBody').style.display = 'none';
                    document.getElementById('undertimeStatusBody').style.display = 'none';
                    
                    if (modal) {
                        modal.classList.add('active');
                        modal.style.display = 'flex';
                        
                        // Set min date to today to prevent past dates
                        const now = new Date();
                        const today = now.toISOString().split('T')[0];
                        const dateInput = document.getElementById('utDate');
                        dateInput.min = today;
                        dateInput.value = today;
                        
                        // Set default time to now
                        const hours = String(now.getHours()).padStart(2, '0');
                        const minutes = String(now.getMinutes()).padStart(2, '0');
                        document.getElementById('utTime').value = `${hours}:${minutes}`;
                    }
                } else {
                    showConfirm(
                        'Confirm Time Out',
                        'Are you sure you want to time out now?',
                        '🕔',
                        async function () { await proceedWithTimeOut(); }
                    );
                }
            }

            function showUndertimeQuestion() {
                document.getElementById('undertimeQuestionBody').style.display = 'block';
                document.getElementById('undertimeFormBody').style.display = 'none';
                document.getElementById('undertimeStatusBody').style.display = 'none';
            }

            function showRegularUndertimeForm() {
                document.getElementById('undertimeQuestionBody').style.display = 'none';
                document.getElementById('undertimeFormBody').style.display = 'block';
            }

            async function emergencyQuickNotify() {
                showConfirm(
                    '🚨 Emergency Notification',
                    'This will immediately notify HR of your emergency departure and record your undertime. Are you sure?',
                    '🚨',
                    async function () {
                        const questionBody = document.getElementById('undertimeQuestionBody');
                        const statusBody = document.getElementById('undertimeStatusBody');
                        const statusTitle = document.getElementById('utStatusTitle');
                        const statusMsg = document.getElementById('utStatusMessage');

                        questionBody.style.display = 'none';
                        statusBody.style.display = 'block';
                        statusTitle.textContent = "Processing Emergency...";
                        statusMsg.textContent = "Sending high priority alerts and recording your shift...";

                        try {
                            const params = new URLSearchParams({
                                action: 'emergencyundertime',
                                employeeId: employeeId
                            });

                            const response = await fetch(handlerUrl + '?' + params.toString());
                            const result = await response.json();

                            if (result.success) {
                                showNotification('Emergency notification sent! You have been timed out. Please take care.', true, () => {
                                    window.location.reload();
                                });
                            } else {
                                showNotification('Failed: ' + result.message, false);
                                showUndertimeQuestion();
                            }
                        } catch (error) {
                            showNotification('Error: ' + error.message, false);
                            showUndertimeQuestion();
                        }
                    }
                );
            }

            async function checkUndertimeRequestStatus() {
                const questionBody = document.getElementById('undertimeQuestionBody');
                const statusBody = document.getElementById('undertimeStatusBody');
                const statusTitle = document.getElementById('utStatusTitle');
                const statusMsg = document.getElementById('utStatusMessage');

                questionBody.style.display = 'none';
                statusBody.style.display = 'block';
                statusTitle.textContent = "Checking Account...";
                statusMsg.textContent = "Please wait while we verify your request status.";

                try {
                    const params = new URLSearchParams({
                        action: 'getstatus',
                        employeeId: employeeId
                    });
                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const data = await response.json();

                    if (data.undertimeStatus === 'Approved') {
                        statusTitle.textContent = "Request Approved!";
                        statusMsg.textContent = "Your undertime request has been approved. You may now proceed to time out.";
                        statusMsg.innerHTML += '<br><br><button type="button" class="action-btn btn-status" style="background:#10b981; color:white; border:none; width:180px; margin:0 auto;" onclick="proceedWithTimeOut()">Proceed to Time Out</button>';
                    } else if (data.undertimeStatus === 'Pending') {
                        statusTitle.textContent = "Request Pending";
                        statusMsg.textContent = "Please wait for confirmation of HR STAFF. Your request is still being reviewed.";
                    } else if (data.undertimeStatus === 'Rejected') {
                        statusTitle.textContent = "Request Rejected";
                        statusMsg.textContent = "Your undertime request was rejected. Please contact HR if you believe this is an error.";
                    } else {
                        statusTitle.textContent = "No Request Found";
                        let debugText = "";
                        if (data.debugInfo) {
                            debugText = `<br><br><div style="font-size: 11px; opacity: 0.7; border-top: 1px solid #eee; pt-2">DEBUG: ID[${data.debugInfo.receivedEmployeeId}] Status[${data.debugInfo.foundStatus}]</div>`;
                        }
                        statusMsg.innerHTML = "We couldn't find an approved request for today. If you haven't submitted one, please fill out the form." + debugText;
                        statusMsg.innerHTML += '<br><br><button type="button" class="btn-cancel" style="width:150px; margin:0 auto;" onclick="showRegularUndertimeForm()">Fill out Form</button>';
                    }
                } catch (error) {
                    statusTitle.textContent = "Connection Error";
                    statusMsg.textContent = "Failed to verify status. Please try again later.";
                }
            }

            async function submitUndertimeRequest(type = 'Regular') {
                const reason = document.getElementById('utReason').value.trim();
                const utDate = document.getElementById('utDate').value;
                const utTime = document.getElementById('utTime').value;

                if (!reason) {
                    showNotification('Please provide a reason for timing out early.', false);
                    return;
                }
                if (!utDate || !utTime) {
                    showNotification('Please provide both date and time for your departure.', false);
                    return;
                }

                // Date Validation: Current or Future
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const selectedDate = new Date(utDate);
                if (selectedDate < today) {
                    showNotification('Undertime date cannot be in the past. Please select today or a future date.', false);
                    return;
                }

                // Time Validation: Must be before 5:00 PM (17:00)
                const depHour = parseInt(utTime.split(':')[0]);
                if (depHour >= 17) {
                    showNotification('Undertime means leaving early. Your departure must be before the shift ends (5:00 PM).', false);
                    return;
                }

                // Format time for display (e.g., 03:30 PM)
                let timeFormatted = utTime;
                try {
                    const [h, m] = utTime.split(':');
                    const hrs = parseInt(h);
                    const ampm = hrs >= 12 ? 'PM' : 'AM';
                    const h12 = hrs % 12 || 12;
                    timeFormatted = `${h12}:${m} ${ampm}`;
                } catch (e) {}

                const departureTime = `${utDate} ${timeFormatted}`;

                const btn = document.getElementById('btnSubmitUT');
                btn.disabled = true;
                btn.textContent = 'Submitting...';

                try {
                    const params = new URLSearchParams({
                        action: 'requestundertime',
                        employeeId: employeeId,
                        reason: reason,
                        type: type,
                        departureTime: departureTime
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        showNotification('Undertime request submitted successfully. Please wait for Admin approval.', true);
                        
                        // Switch to status view
                        document.getElementById('undertimeFormBody').style.display = 'none';
                        const statusBody = document.getElementById('undertimeStatusBody');
                        const statusTitle = document.getElementById('utStatusTitle');
                        const statusMsg = document.getElementById('utStatusMessage');
                        
                        statusBody.style.display = 'block';
                        statusTitle.textContent = "Request Pending";
                        statusMsg.textContent = "Your request has been submitted. Once an administrator approves it, you can return here to time out.";
                    } else {
                        showNotification('Failed: ' + result.message, false);
                        btn.disabled = false;
                        btn.textContent = 'Submit Request';
                    }
                } catch (error) {
                    showNotification('Error: ' + error.message, false);
                    btn.disabled = false;
                    btn.textContent = 'Submit Request';
                }
            }

            async function proceedWithTimeOut() {
                const modal = document.getElementById('undertimeModal');
                if (modal) {
                    modal.classList.remove('active');
                    modal.style.display = 'none';
                }

                const timeOutBtn = document.getElementById('timeOutBtn');
                const statusEl = document.getElementById('attendanceStatus');

                timeOutBtn.disabled = true;
                timeOutBtn.textContent = 'Processing...';

                try {
                    const params = new URLSearchParams({
                        action: 'timeout',
                        employeeId: employeeId
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        showNotification('Time out recorded successfully!', true, () => {
                            window.location.reload();
                        });
                    } else {
                        showNotification(result.message || 'Failed to record time out.', false);
                        timeOutBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showNotification('An error occurred during time out.', false);
                    timeOutBtn.disabled = false;
                } finally {
                    if (!hasTimedOut) {
                        timeOutBtn.textContent = 'TIME OUT';
                    }
                }
            }

            function closeModal(modalId) {
                document.getElementById(modalId).classList.remove('active');
                // Fallback for old style
                document.getElementById(modalId).style.display = 'none';
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                if (event.target.classList.contains('custom-modal-v2')) {
                    event.target.classList.remove('active');
                    event.target.style.display = 'none';
                }
            }

            function showStatus() {
                const status = document.getElementById('attendanceStatus').textContent;
                showNotification('Current attendance status:\n' + status, true);
            }
        </script>
    </asp:Content>