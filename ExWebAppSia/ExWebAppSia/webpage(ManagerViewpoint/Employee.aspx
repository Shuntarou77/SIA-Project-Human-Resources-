<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Inherit base reset & fonts from master */
        .attendance-wrapper {
            background: linear-gradient(135deg, #A44F56 0%, #723E43 100%);
            min-height: 100vh;
            padding: 30px 20px;
        }

        .attendance-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .page-header {
            color: white;
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
        }

        /* Payment Status */
.status-paid {
    color: #28a745;
    font-weight: 600;
}
.status-unpaid {
    color: #dc3545;
    font-weight: 600;
}

        .page-header p {
            opacity: 0.9;
            font-size: 14px;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #A44F56;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 13px;
            color: #666;
            text-transform: uppercase;
            font-weight: 600;
        }

        .stat-icon {
            font-size: 24px;
            margin-bottom: 10px;
            color: #723E43;
        }

        /* Controls Bar */
        .controls-bar {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            align-items: center;
        }

        .control-group {
            display: flex;
            flex-direction: column;
            min-width: 180px;
        }

        .control-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .control-input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }

        .btn {
            background: linear-gradient(135deg, #A44F56, #723E43);
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid #A44F56;
            color: #A44F56;
        }

        .btn-outline:hover {
            background: rgba(164, 79, 86, 0.1);
        }

        /* Attendance & Leave Tables */
        .attendance-table-container {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .table-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .attendance-table thead {
            background: linear-gradient(135deg, #F2C2C6, #FDBFC3);
        }

        .attendance-table th {
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            color: #723E43;
            font-size: 12px;
            text-transform: uppercase;
        }

        .attendance-table td {
            padding: 14px 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .attendance-table tbody tr:hover {
            background: #f9f9f9;
        }

        .time-badge {
            padding: 4px 10px;
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

        .status-present { color: #28a745; font-weight: 600; }
        .status-late { color: #ffc107; font-weight: 600; }
        .status-absent { color: #dc3545; font-weight: 600; }

        .avatar-initial {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #FDBFC3, #F2C2C6);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: bold;
            color: #A44F56;
            margin-right: 10px;
        }

        /* Leave Status Badges */
        .leave-status {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-approved {
            background: #d4edda;
            color: #155724;
        }

        .status-declined {
            background: #f8d7da;
            color: #721c24;
        }

        /* Scrollable container */
        .table-scroll {
            max-height: 500px;
            overflow-y: auto;
            margin-top: 10px;
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

        /* Responsive */
        @media (max-width: 1200px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .controls-bar { flex-direction: column; align-items: stretch; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="attendance-wrapper">
        <div class="attendance-container">
            <!-- Header -->
            <div class="page-header">
                <h1>IT Team Attendance</h1>
                <p>Attendance records for your department — Information Technology</p>
            </div>

            <!-- Stats Overview -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-value">8</div>
                    <div class="stat-label">Team Members</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-value">6</div>
                    <div class="stat-label">Present Today</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⏰</div>
                    <div class="stat-value">1</div>
                    <div class="stat-label">Late</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">❌</div>
                    <div class="stat-value">1</div>
                    <div class="stat-label">Absent</div>
                </div>
            </div>

            <!-- Controls Bar -->
            <div class="controls-bar">
                <div class="control-group">
                    <label class="control-label">Date</label>
                    <input type="date" class="control-input" value="2025-11-07" />
                </div>
                <div class="control-group">
                    <label class="control-label">Status</label>
                    <select class="control-input">
                        <option>All Statuses</option>
                        <option>Present</option>
                        <option>Late</option>
                        <option>Absent</option>
                        <option>On Leave</option>
                    </select>
                </div>
                <div style="margin-left: auto; display: flex; gap: 10px;">
                    <button class="btn btn-outline">Reset</button>
                    <button class="btn">🔍 Apply Filter</button>
                </div>
            </div>

            <!-- Attendance Table -->
<div class="attendance-table-container">
    <h3 class="table-title">📅 Daily Log — November 07, 2025 (IT Department)</h3>
    <div class="table-scroll">
        <table class="attendance-table">
            <thead>
                <tr>
                    <th>Employee</th>
                    <th>ID</th>
                    <th>Time In</th>
                    <th>Time Out</th>
                    <th>Hours</th>
                    <th>Status</th>
                    <th>Salary</th>
                    <th>Payment</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><span class="avatar-initial">JS</span>Francis Santos</td>
                    <td>EMP-2021</td>
                    <td><span class="time-badge time-in">08:00 AM</span></td>
                    <td><span class="time-badge time-out">05:00 PM</span></td>
                    <td>9h 00m</td>
                    <td><span class="status-present">Present</span></td>
                    <td>₱45,000.00</td>
                    <td><span class="status-paid">Paid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
                <tr>
                    <td><span class="avatar-initial">AR</span>Anna Reyes</td>
                    <td>EMP-2023</td>
                    <td><span class="time-badge time-in">08:05 AM</span></td>
                    <td><span class="time-badge time-out">05:10 PM</span></td>
                    <td>9h 05m</td>
                    <td><span class="status-late">Late</span></td>
                    <td>₱28,500.00</td>
                    <td><span class="status-paid">Paid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
                <tr>
                    <td><span class="avatar-initial">MB</span>Mark Borja</td>
                    <td>EMP-2045</td>
                    <td><span class="time-badge time-in">08:00 AM</span></td>
                    <td><span class="time-badge time-out">04:30 PM</span></td>
                    <td>8h 30m</td>
                    <td><span class="status-present">Present</span></td>
                    <td>₱32,000.00</td>
                    <td><span class="status-unpaid">Unpaid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
                <tr>
                    <td><span class="avatar-initial">CL</span>Carmen Lim</td>
                    <td>EMP-2067</td>
                    <td>—</td>
                    <td>—</td>
                    <td>0h 00m</td>
                    <td><span class="status-absent">Absent</span></td>
                    <td>₱26,750.00</td>
                    <td><span class="status-unpaid">Unpaid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
                <tr>
                    <td><span class="avatar-initial">DK</span>Daniel Kim</td>
                    <td>EMP-2071</td>
                    <td><span class="time-badge time-in">08:12 AM</span></td>
                    <td>—</td>
                    <td>—</td>
                    <td><span class="status-late">Late</span></td>
                    <td>₱30,200.00</td>
                    <td><span class="status-paid">Paid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
                <tr>
                    <td><span class="avatar-initial">SJ</span>Sarah Jimenez</td>
                    <td>EMP-2088</td>
                    <td><span class="time-badge time-in">08:00 AM</span></td>
                    <td><span class="time-badge time-out">05:00 PM</span></td>
                    <td>9h 00m</td>
                    <td><span class="status-present">Present</span></td>
                    <td>₱35,800.00</td>
                    <td><span class="status-paid">Paid</span></td>
                    <td><button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">📤 Send Report</button></td>
                </tr>
            </tbody>
        </table>
    </div>

    <div style="margin-top: 20px; text-align: right;">
        <button class="btn">📥 Export to Excel</button>
    </div>
</div>

            <!-- ✅ NEW: Leave Requests Table -->
            <div class="attendance-table-container">
                <h3 class="table-title">📝 Leave Requests — Pending Approval</h3>
                <div class="table-scroll" style="max-height: 350px;">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>ID</th>
                                <th>Leave Type</th>
                                <th>Date(s) Requested</th>
                                <th>Duration</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><span class="avatar-initial">CL</span>Carmen Lim</td>
                                <td>EMP-2067</td>
                                <td>Vacation Leave</td>
                                <td>Nov 10–12, 2025</td>
                                <td>3 days</td>
                                <td>Family trip</td>
                                <td><span class="leave-status status-pending">Pending</span></td>
                                <td>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; margin-right: 6px;"
                                        onclick="if(confirm('Approve leave for Carmen Lim?')) { this.parentNode.innerHTML='<span class=\'leave-status status-approved\'>✅ Approved</span>'; }">
                                        ✅ Approve
                                    </button>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; background: #dc3545; border-color: #dc3545; color: white;"
                                        onclick="if(confirm('Decline leave for Carmen Lim?')) { this.parentNode.innerHTML='<span class=\'leave-status status-declined\'>❌ Declined</span>'; }">
                                        ❌ Decline
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><span class="avatar-initial">DK</span>Daniel Kim</td>
                                <td>EMP-2071</td>
                                <td>Sick Leave</td>
                                <td>Nov 08, 2025</td>
                                <td>1 day</td>
                                <td>Fever & flu</td>
                                <td><span class="leave-status status-pending">Pending</span></td>
                                <td>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; margin-right: 6px;"
                                        onclick="if(confirm('Approve leave for Daniel Kim?')) { this.parentNode.innerHTML='<span class=\'leave-status status-approved\'>✅ Approved</span>'; }">
                                        ✅ Approve
                                    </button>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; background: #dc3545; border-color: #dc3545; color: white;"
                                        onclick="if(confirm('Decline leave for Daniel Kim?')) { this.parentNode.innerHTML='<span class=\'leave-status status-declined\'>❌ Declined</span>'; }">
                                        ❌ Decline
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><span class="avatar-initial">SJ</span>Sarah Jimenez</td>
                                <td>EMP-2088</td>
                                <td>Emergency Leave</td>
                                <td>Nov 07, 2025</td>
                                <td>0.5 day</td>
                                <td>Medical emergency (child)</td>
                                <td><span class="leave-status status-pending">Pending</span></td>
                                <td>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; margin-right: 6px;"
                                        onclick="if(confirm('Approve leave for Sarah Jimenez?')) { this.parentNode.innerHTML='<span class=\'leave-status status-approved\'>✅ Approved</span>'; }">
                                        ✅ Approve
                                    </button>
                                    <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; background: #dc3545; border-color: #dc3545; color: white;"
                                        onclick="if(confirm('Decline leave for Sarah Jimenez?')) { this.parentNode.innerHTML='<span class=\'leave-status status-declined\'>❌ Declined</span>'; }">
                                        ❌ Decline
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div> <!-- .attendance-container -->
    </div> <!-- .attendance-wrapper -->
</asp:Content>