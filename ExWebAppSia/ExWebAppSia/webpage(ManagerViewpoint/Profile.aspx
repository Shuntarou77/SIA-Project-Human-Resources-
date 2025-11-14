<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .profile-wrapper {
            background: linear-gradient(135deg, #A44F56 0%, #723E43 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }

        .profile-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .profile-header {
            color: white;
            margin-bottom: 30px;
        }

        .profile-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .profile-header p {
            opacity: 0.9;
            font-size: 14px;
        }

        /* Top Section - Manager Info Card */
        .manager-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
        }

        .manager-info-section {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 30px;
            align-items: start;
        }

        .manager-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 60px;
            font-weight: bold;
            color: #A44F56;
            border: 5px solid #f0f0f0;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .manager-details {
            flex: 1;
        }

        .manager-name {
            font-size: 28px;
            font-weight: 700;
            color: #333;
            margin-bottom: 5px;
        }

        .manager-id {
            font-size: 14px;
            color: #999;
            margin-bottom: 20px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }

        .info-item {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #A44F56;
        }

        .info-icon {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            margin-right: 12px;
        }

        .info-content {
            flex: 1;
        }

        .info-label {
            font-size: 11px;
            color: #666;
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 3px;
        }

        .info-value {
            font-size: 15px;
            color: #333;
            font-weight: 600;
        }

        .department-badge {
            background: linear-gradient(135deg, #A44F56, #723E43);
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            display: inline-block;
        }

        /* Main Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 25px;
        }

        .profile-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-icon-header {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        /* Attendance Log Table */
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .attendance-table thead {
            background: linear-gradient(135deg, #F2C2C6, #FDBFC3);
        }

        .attendance-table th {
            padding: 12px 10px;
            text-align: left;
            font-weight: 600;
            color: #723E43;
            font-size: 11px;
            text-transform: uppercase;
        }

        .attendance-table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f0f0f0;
        }

        .attendance-table tbody tr:hover {
            background: #f8f9fa;
        }

        .time-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }

        .time-in {
            background: #d4edda;
            color: #155724;
        }

        .time-out {
            background: #cce5ff;
            color: #004085;
        }

        /* Leave History */
        .leave-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .leave-item {
            padding: 15px;
            margin-bottom: 10px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #A44F56;
        }

        .leave-item:last-child {
            margin-bottom: 0;
        }

        .leave-type {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .leave-date {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }

        .leave-status {
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }

        .status-approved {
            background: #d4edda;
            color: #155724;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        /* Forms Section */
        .forms-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.3s ease;
        }

        .form-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
        }

        .form-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            margin: 0 auto 15px;
        }

        .form-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }

        .form-description {
            font-size: 13px;
            color: #666;
            margin-bottom: 15px;
        }

        .form-button {
            background: linear-gradient(135deg, #A44F56, #723E43);
            color: white;
            padding: 10px 25px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .form-button:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .table-scroll {
            max-height: 300px;
            overflow-y: auto;
        }

        .table-scroll::-webkit-scrollbar {
            width: 6px;
        }

        .table-scroll::-webkit-scrollbar-track {
            background: #f0f0f0;
            border-radius: 10px;
        }

        .table-scroll::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #A44F56, #723E43);
            border-radius: 10px;
        }

        @media (max-width: 1200px) {
            .content-grid {
                grid-template-columns: 1fr;
            }

            .forms-section {
                grid-template-columns: 1fr;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="profile-wrapper">
        <div class="profile-container">
            <!-- Header -->
            <div class="profile-header">
                <h1>Manager Profile</h1>
                <p>View and manage your personal information and records</p>
            </div>

            <!-- Manager Info Card -->
            <div class="manager-card">
                <div class="manager-info-section">
                    <div class="manager-avatar">
                        M
                    </div>
                    <div class="manager-details">
                        <h2 class="manager-name">John Michael Santos</h2>
                        <p class="manager-id">Manager ID: MGR-001</p>
                        
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-icon">🏢</div>
                                <div class="info-content">
                                    <div class="info-label">Department</div>
                                    <div class="info-value">
                                        <span class="department-badge">Information Technology</span>
                                    </div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">📧</div>
                                <div class="info-content">
                                    <div class="info-label">Email</div>
                                    <div class="info-value">john.santos@company.com</div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">📞</div>
                                <div class="info-content">
                                    <div class="info-label">Phone</div>
                                    <div class="info-value">+63 912 345 6789</div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">📍</div>
                                <div class="info-content">
                                    <div class="info-label">Location</div>
                                    <div class="info-value">Quezon City, Metro Manila</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Content Grid -->
            <div class="content-grid">
                <!-- Attendance Log -->
                <div class="profile-card">
                    <h3 class="card-title">
                        <span class="card-icon-header">📅</span>
                        Attendance Log
                    </h3>
                    <div class="table-scroll">
                        <table class="attendance-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Time In</th>
                                    <th>Time Out</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Nov 07, 2025</td>
                                    <td><span class="time-badge time-in">08:00 AM</span></td>
                                    <td><span class="time-badge time-out">05:00 PM</span></td>
                                    <td>Present</td>
                                </tr>
                                <tr>
                                    <td>Nov 06, 2025</td>
                                    <td><span class="time-badge time-in">08:05 AM</span></td>
                                    <td><span class="time-badge time-out">05:15 PM</span></td>
                                    <td>Present</td>
                                </tr>
                                <tr>
                                    <td>Nov 05, 2025</td>
                                    <td><span class="time-badge time-in">08:00 AM</span></td>
                                    <td><span class="time-badge time-out">05:00 PM</span></td>
                                    <td>Present</td>
                                </tr>
                                <tr>
                                    <td>Nov 04, 2025</td>
                                    <td><span class="time-badge time-in">08:10 AM</span></td>
                                    <td><span class="time-badge time-out">05:05 PM</span></td>
                                    <td>Late</td>
                                </tr>
                                <tr>
                                    <td>Nov 01, 2025</td>
                                    <td><span class="time-badge time-in">08:00 AM</span></td>
                                    <td><span class="time-badge time-out">05:00 PM</span></td>
                                    <td>Present</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Leave of Absence History -->
                <div class="profile-card">
                    <h3 class="card-title">
                        <span class="card-icon-header">📝</span>
                        Leave of Absence History
                    </h3>
                    <ul class="leave-list">
                        <li class="leave-item">
                            <div class="leave-type">Vacation Leave</div>
                            <div class="leave-date">October 15-17, 2025 (3 days)</div>
                            <span class="leave-status status-approved">Approved</span>
                        </li>
                        <li class="leave-item">
                            <div class="leave-type">Sick Leave</div>
                            <div class="leave-date">September 22, 2025 (1 day)</div>
                            <span class="leave-status status-approved">Approved</span>
                        </li>
                        <li class="leave-item">
                            <div class="leave-type">Emergency Leave</div>
                            <div class="leave-date">August 5, 2025 (0.5 day)</div>
                            <span class="leave-status status-pending">Pending</span>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Forms Section -->
            <div class="forms-section">
                <div class="form-card">
                    <div class="form-icon">📄</div>
                    <h4 class="form-title">Leave Application</h4>
                    <p class="form-description">Submit a request for vacation, sick, or emergency leave.</p>
                    <button class="form-button" onclick="alert('Leave application form opened!')">Apply Now</button>
                </div>
                <div class="form-card">
                    <div class="form-icon">🛠️</div>
                    <h4 class="form-title">Profile Update</h4>
                    <p class="form-description">Update your contact info, emergency contacts, or profile photo.</p>
                    <button class="form-button" onclick="alert('Profile update form opened!')">Edit Profile</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>