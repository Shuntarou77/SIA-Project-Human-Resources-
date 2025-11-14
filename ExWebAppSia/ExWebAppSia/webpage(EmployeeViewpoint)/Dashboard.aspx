
<%@ Page Title="Employee Dashboard" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm1" %>
<%@ Import Namespace="ExWebAppSia.Models" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #ff6b6b, #ff8e8e);
            --secondary-gradient: linear-gradient(135deg, #ffebee, #f8bbd0);
            --accent-pink: #ff6b6b;
            --light-pink: #ffebee;
            --card-shadow: 0 25px 50px -12px rgba(255, 107, 107, 0.2);
            --hover-shadow: 0 20px 25px -5px rgba(255, 107, 107, 0.25);
            --border-radius: 20px;
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --text-muted: #9ca3af;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --border-color: #fbb6c2;
        }

        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; 
        }

        html, body { 
            height: 100%; 
            background: linear-gradient(180deg, #F5DDD8 0%, #D4999C 50%, #A85B5B 100%);
        }

        .dashboard {
            min-height: 100vh;
            padding: 24px;
        }

        .dashboard-header {
            margin-bottom: 32px;
        }

        .dashboard-title {
            font-size: 32px;
            font-weight: 800;
            color: #ff6b6b;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
            text-shadow: 0 2px 4px rgba(255, 107, 107, 0.1);
        }

        .dashboard-subtitle {
            font-size: 16px;
            color: var(--text-secondary);
            font-weight: 500;
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
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.1);
            border: 2px solid #fbb6c2;
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            position: relative;
            overflow: hidden;
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
            box-shadow: 0 12px 28px rgba(255, 107, 107, 0.15);
            border-color: #ff8e8e;
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
            background: rgba(255, 107, 107, 0.1);
            color: #ff6b6b;
        }

        .attendance-icon {
            background: rgba(255, 107, 107, 0.15);
            color: #ff6b6b;
        }

        .present-icon {
            background: rgba(255, 107, 107, 0.15);
            color: #ff6b6b;
        }

        .absent-icon {
            background: rgba(255, 107, 107, 0.15);
            color: #ff6b6b;
        }

        .late-icon {
            background: rgba(255, 107, 107, 0.15);
            color: #ff6b6b;
        }

        .stat-label {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 800;
            color: #ff6b6b;
            line-height: 1.2;
        }

        .stat-trend {
            font-size: 13px;
            font-weight: 600;
            margin-top: 4px;
            color: var(--text-secondary);
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
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.1);
            border: 2px solid #fbb6c2;
            height: fit-content;
            position: relative;
            overflow: hidden;
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
            box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
            border: 3px solid white;
        }

        .profile-info {
            flex: 1;
        }

        .profile-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .profile-position {
            font-size: 14px;
            color: #ff6b6b;
            font-weight: 600;
        }

        .profile-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 107, 107, 0.1);
            color: #ff6b6b;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 8px;
            border: 1px solid rgba(255, 107, 107, 0.2);
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
        }

        .detail-value {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .announcements-section {
            background: white;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.1);
            border: 2px solid #fbb6c2;
            position: relative;
            overflow: hidden;
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
            color: #ff6b6b;
        }

        .view-all {
            font-size: 13px;
            color: #ff6b6b;
            font-weight: 600;
            text-decoration: none;
        }

        .announcement-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .announcement-item {
            padding: 16px;
            border-radius: 12px;
            background: rgba(255, 245, 245, 0.7);
            border-left: 4px solid #ff6b6b;
            transition: transform 0.2s ease, background 0.2s ease;
        }

        .announcement-item:hover {
            transform: translateX(4px);
            background: rgba(255, 240, 240, 0.9);
        }

        .announcement-date {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 8px;
            font-weight: 500;
        }

        .announcement-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 6px;
            line-height: 1.4;
        }

        .announcement-content {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.5;
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
            
            .stat-card, .profile-card, .announcements-section {
                padding: 20px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="dashboard">
        <div class="dashboard-header">
            <h1 class="dashboard-title">Employee Dashboard</h1>
            <p class="dashboard-subtitle">Welcome back! Here's your overview for today.</p>
        </div>

        <!-- Statistics Section -->
        <div class="stats-section">
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon attendance-icon">📊</div>
                    <div class="stat-label">Overall Attendance</div>
                </div>
                <div class="stat-value">97%</div>
                <div class="stat-trend trend-up">↑ 2% from last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon present-icon">✓</div>
                    <div class="stat-label">Days Present</div>
                </div>
                <div class="stat-value">154</div>
                <div class="stat-trend trend-up">↑ 12 from last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon absent-icon">✗</div>
                    <div class="stat-label">Days Absent</div>
                </div>
                <div class="stat-value">4</div>
                <div class="stat-trend trend-down">↓ 2 from last month</div>
            </div>

            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon late-icon">🕒</div>
                    <div class="stat-label">Days Late</div>
                </div>
                <div class="stat-value">1</div>
                <div class="stat-trend trend-down">↓ 3 from last month</div>
            </div>
        </div>

        <!-- Profile and Announcements Grid -->
        <div class="dashboard-grid">
            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar"><%= GetEmployeeInitials() %></div>
                    <div class="profile-info">
                        <div class="profile-name"><%= GetEmployeeName() %></div>
                        <div class="profile-position"><%= GetEmployeeRole() %></div>
                        <div class="profile-status">
                            <span>●</span> Active
                        </div>
                    </div>
                </div>
                
                <div class="profile-details">
                    <div class="detail-item">
                        <div class="detail-label">Address</div>
                        <div class="detail-value"><%= GetEmployeeAddress() %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Employee ID</div>
                        <div class="detail-value"><%= ((Employee)Session["Employee"])?.EmployeeId ?? "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Department</div>
                        <div class="detail-value"><%= ((Employee)Session["Employee"])?.Department ?? "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Email</div>
                        <div class="detail-value"><%= ((Employee)Session["Employee"])?.Email ?? "N/A" %></div>
                    </div>
                </div>
            </div>

            <!-- Announcements Section -->
            <div class="announcements-section">
                <div class="section-header">
                    <h2 class="section-title">Latest Announcements</h2>
                    <a href="#" class="view-all">View All</a>
                </div>
                
                <div class="announcement-list">
                    <div class="announcement-item">
                        <div class="announcement-date">December 15, 2024</div>
                        <div class="announcement-title">Holiday Schedule Update</div>
                        <div class="announcement-content">Office will be closed from December 24-26 for Christmas holidays.</div>
                        <div class="announcement-badge">Important</div>
                    </div>
                    
                    <div class="announcement-item">
                        <div class="announcement-date">December 10, 2024</div>
                        <div class="announcement-title">Year-End Performance Reviews</div>
                        <div class="announcement-content">Please schedule your performance review meeting with HR by December 20th.</div>
                    </div>
                    
                    <div class="announcement-item">
                        <div class="announcement-date">December 5, 2024</div>
                        <div class="announcement-title">New Benefits Package</div>
                        <div class="announcement-content">Enhanced health insurance coverage will be effective January 1st, 2025.</div>
                        <div class="announcement-badge">New</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
