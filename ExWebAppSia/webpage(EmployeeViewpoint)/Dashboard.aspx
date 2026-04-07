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
            <div class="custom-modal-v2-content" style="max-width: 450px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <span class="close" onclick="closeModal('undertimeModal')">&times;</span>
                    <h2 class="custom-modal-v2-title">⚠️ Early Time Out</h2>
                </div>
                <div class="custom-modal-v2-body" style="text-align: center; padding: 30px;">
                    <div style="font-size: 50px; margin-bottom: 20px;">🕒</div>
                    <h3 style="color: var(--text-primary); margin-bottom: 15px;">You are timing out early!</h3>
                    <p style="color: var(--text-secondary); line-height: 1.6; margin-bottom: 20px;">
                        It is not yet 5:00 PM. Timing out now will be recorded as <strong>Undertime</strong>.
                    </p>
                    <div
                        style="background: #FFFBEB; border-left: 4px solid #f59e0b; padding: 15px; text-align: left; margin-bottom: 25px; border-radius: 0 8px 8px 0;">
                        <p style="color: #92400e; font-size: 14px; font-weight: 600;">
                            Note: Please make sure to inform HR or your supervisor about your undertime.
                        </p>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('undertimeModal')">Cancel</button>
                    <button type="button" class="btn-submit" style="background: #f59e0b;"
                        onclick="proceedWithTimeOut()">Proceed anyway</button>
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
                    <div style="margin-bottom: 20px;">
                        <label for="otReason" style="display: block; font-weight: 600; color: var(--text-primary); margin-bottom: 8px;">Reason for Overtime:</label>
                        <textarea id="otReason" rows="3" class="form-control" 
                            style="width: 100%; padding: 12px; border-radius: 10px; border: 2px solid var(--border-color); font-family: inherit; resize: none;"
                            placeholder="Please provide a brief reason for requesting overtime..."></textarea>
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
                if (modal) modal.classList.add('active');
            }

            async function submitOvertimeRequest() {
                const reason = document.getElementById('otReason').value.trim();
                if (!reason) {
                    showNotification('Please provide a reason for overtime.', false);
                    return;
                }

                const otBtn = document.getElementById('overtimeBtn');
                const submitBtn = document.querySelector('#overtimeModal .btn-submit');
                
                submitBtn.disabled = true;
                submitBtn.textContent = 'Submitting...';

                try {
                    const params = new URLSearchParams({
                        action: 'requestovertime',
                        employeeId: employeeId,
                        reason: reason
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
                const now = new Date();
                const currentHour = now.getHours();
                const currentMinutes = now.getMinutes();

                console.log(`Time Out Validation - Status: In=${hasTimedIn}, Out=${hasTimedOut}, Time=${currentHour}:${currentMinutes}`);

                if (hasTimedOut) {
                    showNotification('You have already timed out today.', false);
                    return;
                }

                if (!hasTimedIn) {
                    showNotification('Please time in first before timing out.', false);
                    return;
                }

                // If it's before 5:00 PM (17:00), show undertime warning
                if (currentHour < 17) {
                    console.log('Undertime detected! Opening modal.');
                    const modal = document.getElementById('undertimeModal');
                    if (modal) {
                        modal.classList.add('active');
                        return;
                    } else {
                        console.error('Modal element "undertimeModal" not found in DOM!');
                        if (confirm('Regular shift ends at 5:00 PM. Timing out now is considered UNDERTIME. Do you want to proceed?')) {
                            await proceedWithTimeOut();
                        }
                    }
                } else {
                    console.log('Valid shift end. Proceeding with time out.');
                    await proceedWithTimeOut();
                }
            }

            async function proceedWithTimeOut() {
                if (hasTimedOut) {
                    showNotification('You have already timed out today.', false);
                    return;
                }

                if (!hasTimedIn) {
                    showNotification('Please time in first before timing out.', false);
                    return;
                }

                if (!employeeId || employeeId === 'N/A') {
                    showNotification('Employee ID not found. Please contact HR.', false);
                    return;
                }

                closeModal('undertimeModal');

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
                        showNotification('Time out recorded successfully!', true, () => {
                            window.location.reload();
                        });
                    } else {
                        showNotification(result.message || 'Failed to record time out. Please make sure you have timed in first.', false);
                        timeOutBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showNotification('An error occurred while recording time out. Please try again.', false);
                    timeOutBtn.disabled = false;
                } finally {
                    timeOutBtn.textContent = 'TIME OUT';
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