<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" Async="true" CodeBehind="Employee.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* ✅ Pure white background — no gradient */
        .attendance-wrapper {
            background-color: white;
            min-height: 100vh;
            padding: 30px 20px;
        }

        .attendance-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .page-header {
            color: #333;
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand header */
        }

        .page-header p {
            opacity: 0.8;
            font-size: 14px;
            color: #666;
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
            border: 1px solid #eee;
            text-align: center;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #A36A66; /* ✅ Brand color */
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
            color: #A36A66; /* ✅ Unified icon */
        }

        /* Controls Bar */
        .controls-bar {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
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

        /* Buttons — ✅ #A36A66 theme */
        .btn {
            background: linear-gradient(135deg, #A36A66, #8B5A58);
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
            box-shadow: 0 4px 8px rgba(163, 106, 102, 0.3);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid #A36A66;
            color: #A36A66;
        }

        .btn-outline:hover {
            background: rgba(163, 106, 102, 0.1);
        }

        /* Attendance & Leave Tables */
        .attendance-table-container {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
            margin-bottom: 30px;
        }

        .table-title {
            font-size: 18px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand header */
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
            background-color: #A36A66; /* ✅ Solid header */
        }

        .attendance-table th {
            padding: 14px 12px;
            text-align: left;
            font-weight: 600;
            color: white;
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

        .time-in { background: #d4edda; color: #155724; }
        .time-out { background: #cce5ff; color: #004085; }

        .status-present { color: #28a745; font-weight: 600; }
        .status-late { color: #ffc107; font-weight: 600; }
        .status-absent { color: #dc3545; font-weight: 600; }

        .avatar-initial {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: #A36A66; /* ✅ Unified avatar */
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: bold;
            color: white;
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

        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d4edda; color: #155724; }
        .status-declined { background: #f8d7da; color: #721c24; }

        /* Scrollbar */
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
            background: #A36A66;
            border-radius: 10px;
        }

        /* Modal Styles */
        .leave-confirm-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
        }

        .leave-confirm-modal-content {
            background: white;
            margin: 100px auto;
            padding: 0;
            border-radius: 12px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .leave-confirm-modal-header {
            background: linear-gradient(135deg, #A36A66, #C49A99);
            color: white;
            padding: 24px;
            border-radius: 12px 12px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .leave-confirm-modal-title {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
        }

        .leave-confirm-close {
            color: white;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
            background: none;
            border: none;
            padding: 0;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .leave-confirm-close:hover {
            opacity: 0.7;
        }

        .leave-confirm-modal-body {
            padding: 24px;
        }

        .leave-confirm-info {
            margin-bottom: 20px;
        }

        .leave-confirm-info p {
            margin: 8px 0;
            color: #666;
        }

        .leave-confirm-info strong {
            color: #333;
        }

        .leave-confirm-modal-footer {
            padding: 16px 24px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            border-top: 1px solid #eee;
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
                <h1><%= GetManagerDepartment() %> Team Attendance</h1>
                <p>Attendance records for your department — <%= GetManagerDepartment() %></p>
            </div>

            <!-- Stats Overview -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-value"><%= GetTeamMembersCount() %></div>
                    <div class="stat-label">Team Members</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-value"><%= GetPresentCount() %></div>
                    <div class="stat-label">Present Today</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⏰</div>
                    <div class="stat-value"><%= GetLateCount() %></div>
                    <div class="stat-label">Late</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">❌</div>
                    <div class="stat-value"><%= GetAbsentCount() %></div>
                    <div class="stat-label">Absent</div>
                </div>
            </div>

            <!-- Controls Bar -->
            <div class="controls-bar">
                <div class="control-group">
                    <label class="control-label">Date</label>
                    <input type="date" id="dateFilter" class="control-input" value="<%= SelectedDate.ToString("yyyy-MM-dd") %>" onchange="filterByDate(this.value)" />
                </div>
                <div style="margin-left: auto; display: flex; gap: 10px;">
                    <button class="btn btn-outline" onclick="resetDate()">Reset</button>
                </div>
            </div>

            <!-- Attendance Table -->
<div class="attendance-table-container">
    <h3 class="table-title">📅 Daily Log — <%= GetSelectedDateDisplay() %> (<%= GetManagerDepartment() %> Department)</h3>
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
                </tr>
            </thead>
            <tbody>
                <% if (DepartmentEmployees != null && DepartmentEmployees.Count > 0) { %>
                    <% foreach (var employee in GetSortedEmployees()) { %>
                        <% var attendance = GetEmployeeAttendance(employee); %>
                        <% var status = GetAttendanceStatus(employee, attendance); %>
                        <tr style="cursor: pointer;" onclick="viewEmployeeDetails('<%= employee.EmployeeId %>')" title="Click to view employee details">
                            <td><span class="avatar-initial"><%= GetEmployeeInitials(employee) %></span><%= employee.FullName %></td>
                            <td><%= employee.EmployeeId %></td>
                            <td>
                                <% if (attendance != null && attendance.TimeIn.HasValue) { %>
                                    <span class="time-badge time-in"><%= FormatTime(attendance.TimeIn) %></span>
                                <% } else { %>
                                    —
                                <% } %>
                            </td>
                            <td>
                                <% if (attendance != null && attendance.TimeOut.HasValue) { %>
                                    <span class="time-badge time-out"><%= FormatTime(attendance.TimeOut) %></span>
                                <% } else { %>
                                    —
                                <% } %>
                            </td>
                            <td><%= GetHoursWorked(attendance) %></td>
                            <td><span class="<%= GetStatusClass(status) %>"><%= status %></span></td>
                        </tr>
                    <% } %>
                <% } else { %>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 20px; color: #999;">
                            No employees found in your department.
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <div style="margin-top: 20px; text-align: right;">
        <button class="btn" onclick="exportToPDF()">📥 Export to PDF</button>
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
                            <% if (PendingLeaveRequests != null && PendingLeaveRequests.Count > 0) { %>
                                <% foreach (var leave in PendingLeaveRequests) { %>
                                    <% var employee = GetEmployeeByEmployeeId(leave.EmployeeId); %>
                                    <% if (employee != null) { %>
                                        <tr>
                                            <td><span class="avatar-initial"><%= GetEmployeeInitials(employee) %></span><%= employee.FullName %></td>
                                            <td><%= employee.EmployeeId %></td>
                                            <td><%= leave.LeaveType %></td>
                                            <td><%= FormatLeaveDateRange(leave) %></td>
                                            <td><%= GetLeaveDuration(leave) %></td>
                                            <td><%= leave.Reason %></td>
                                            <td><span class="leave-status <%= GetLeaveStatusClass(leave.Status) %>"><%= leave.Status %></span></td>
                                            <td>
                                                <button type="button" class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; margin-right: 6px;"
                                                    onclick="openLeaveConfirmModal('<%= leave.Id %>', '<%= Server.HtmlEncode(employee.FullName) %>', '<%= Server.HtmlEncode(leave.LeaveType) %>', '<%= FormatLeaveDateRange(leave) %>', 'approve');">
                                                    ✅ Approve
                                                </button>
                                                <button type="button" class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; background: #dc3545; border-color: #dc3545; color: white;"
                                                    onclick="openLeaveConfirmModal('<%= leave.Id %>', '<%= Server.HtmlEncode(employee.FullName) %>', '<%= Server.HtmlEncode(leave.LeaveType) %>', '<%= FormatLeaveDateRange(leave) %>', 'decline');">
                                                    ❌ Decline
                                                </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 20px; color: #999;">
                                        No pending leave requests.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ✅ NEW: Employee Concerns Table -->
            <div class="attendance-table-container">
                <h3 class="table-title">📋 Employee Concerns — Pending Review</h3>
                <div class="table-scroll" style="max-height: 350px;">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>ID</th>
                                <th>Concern Type</th>
                                <th>Subject</th>
                                <th>Priority</th>
                                <th>Submitted</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (PendingConcerns != null && PendingConcerns.Count > 0) { %>
                                <% foreach (var concern in PendingConcerns) { %>
                                    <% var employee = GetEmployeeByEmployeeId(concern.EmployeeId); %>
                                    <% if (employee != null) { %>
                                        <tr>
                                            <td><span class="avatar-initial"><%= GetEmployeeInitials(employee) %></span><%= employee.FullName %></td>
                                            <td><%= employee.EmployeeId %></td>
                                            <td><%= concern.ConcernType %></td>
                                            <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= Server.HtmlEncode(concern.Subject) %>"><%= concern.Subject %></td>
                                            <td><span class="<%= GetPriorityClass(concern.PriorityLevel) %>"><%= concern.PriorityLevel %></span></td>
                                            <td><%= FormatConcernDate(concern) %></td>
                                            <td><span class="leave-status <%= GetConcernStatusClass(concern.Status) %>"><%= concern.Status %></span></td>
                                            <td>
                                                <button type="button" class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; margin-right: 6px;"
                                                    onclick="openConcernConfirmModal('<%= concern.Id %>', '<%= Server.HtmlEncode(employee.FullName) %>', '<%= Server.HtmlEncode(concern.ConcernType) %>', '<%= Server.HtmlEncode(concern.Subject) %>', 'approve');">
                                                    ✅ Approve
                                                </button>
                                                <button type="button" class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; background: #dc3545; border-color: #dc3545; color: white;"
                                                    onclick="openConcernConfirmModal('<%= concern.Id %>', '<%= Server.HtmlEncode(employee.FullName) %>', '<%= Server.HtmlEncode(concern.ConcernType) %>', '<%= Server.HtmlEncode(concern.Subject) %>', 'decline');">
                                                    ❌ Decline
                                                </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 20px; color: #999;">
                                        No pending employee concerns.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div> <!-- .attendance-container -->
    </div> <!-- .attendance-wrapper -->

    <!-- Employee Details Modal -->
    <div id="employeeDetailsModal" class="leave-confirm-modal" style="z-index: 10001;">
        <div class="leave-confirm-modal-content" style="max-width: 900px; max-height: 90vh; overflow-y: auto;">
            <div class="leave-confirm-modal-header">
                <h3 class="leave-confirm-modal-title">👤 Employee Details</h3>
                <button type="button" class="leave-confirm-close" onclick="closeEmployeeDetailsModal()">&times;</button>
            </div>
            <div class="leave-confirm-modal-body" id="employeeDetailsContent" style="padding: 20px;">
                <div style="text-align: center; padding: 20px;">
                    <div class="spinner" style="border: 4px solid #f3f3f3; border-top: 4px solid #8B4513; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto;"></div>
                    <p style="margin-top: 10px; color: #666;">Loading employee information...</p>
                </div>
            </div>
            <div class="leave-confirm-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeEmployeeDetailsModal()">Close</button>
            </div>
        </div>
    </div>

    <!-- Concern Confirmation Modal -->
    <div id="concernConfirmModal" class="leave-confirm-modal">
        <div class="leave-confirm-modal-content">
            <div class="leave-confirm-modal-header">
                <h3 class="leave-confirm-modal-title" id="concernModalTitle">Confirm Concern Action</h3>
                <button type="button" class="leave-confirm-close" onclick="closeConcernConfirmModal()">&times;</button>
            </div>
            <div class="leave-confirm-modal-body">
                <div class="leave-confirm-info">
                    <p><strong>Employee:</strong> <span id="concernModalEmployeeName"></span></p>
                    <p><strong>Concern Type:</strong> <span id="concernModalConcernType"></span></p>
                    <p><strong>Subject:</strong> <span id="concernModalSubject"></span></p>
                </div>
                <p id="concernModalMessage" style="color: #333; font-weight: 600;"></p>
            </div>
            <div class="leave-confirm-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeConcernConfirmModal()">Cancel</button>
                <form id="concernActionForm" method="post" style="display: inline;">
                    <input type="hidden" name="concernId" id="concernModalConcernId" />
                    <input type="hidden" name="concernAction" id="concernModalConcernAction" />
                    <button type="submit" class="btn" id="concernModalSubmitBtn">Confirm</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Leave Confirmation Modal -->
    <div id="leaveConfirmModal" class="leave-confirm-modal">
        <div class="leave-confirm-modal-content">
            <div class="leave-confirm-modal-header">
                <h3 class="leave-confirm-modal-title" id="modalTitle">Confirm Leave Action</h3>
                <button type="button" class="leave-confirm-close" onclick="closeLeaveConfirmModal()">&times;</button>
            </div>
            <div class="leave-confirm-modal-body">
                <div class="leave-confirm-info">
                    <p><strong>Employee:</strong> <span id="modalEmployeeName"></span></p>
                    <p><strong>Leave Type:</strong> <span id="modalLeaveType"></span></p>
                    <p><strong>Date(s):</strong> <span id="modalLeaveDates"></span></p>
                </div>
                <p id="modalMessage" style="color: #333; font-weight: 600;"></p>
            </div>
            <div class="leave-confirm-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeLeaveConfirmModal()">Cancel</button>
                <form id="leaveActionForm" method="post" style="display: inline;">
                    <input type="hidden" name="leaveId" id="modalLeaveId" />
                    <input type="hidden" name="leaveAction" id="modalLeaveAction" />
                    <button type="submit" class="btn" id="modalSubmitBtn">Confirm</button>
                </form>
            </div>
        </div>
    </div>

    <script>
        let currentLeaveId = '';
        let currentLeaveAction = '';

        function openLeaveConfirmModal(leaveId, employeeName, leaveType, leaveDates, action) {
            currentLeaveId = leaveId;
            currentLeaveAction = action;
            
            document.getElementById('modalLeaveId').value = leaveId;
            document.getElementById('modalLeaveAction').value = action;
            document.getElementById('modalEmployeeName').textContent = employeeName;
            document.getElementById('modalLeaveType').textContent = leaveType;
            document.getElementById('modalLeaveDates').textContent = leaveDates;
            
            const modal = document.getElementById('leaveConfirmModal');
            const title = document.getElementById('modalTitle');
            const message = document.getElementById('modalMessage');
            const submitBtn = document.getElementById('modalSubmitBtn');
            
            if (action === 'approve') {
                title.textContent = 'Approve Leave Request';
                message.textContent = 'Are you sure you want to approve this leave request? An email notification will be sent to the employee.';
                submitBtn.textContent = 'Approve';
                submitBtn.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else {
                title.textContent = 'Decline Leave Request';
                message.textContent = 'Are you sure you want to decline this leave request? An email notification will be sent to the employee.';
                submitBtn.textContent = 'Decline';
                submitBtn.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            }
            
            modal.style.display = 'block';
        }

        function closeLeaveConfirmModal() {
            document.getElementById('leaveConfirmModal').style.display = 'none';
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('leaveConfirmModal');
            if (event.target == modal) {
                closeLeaveConfirmModal();
            }
        }

        // Handle form submission
        const leaveActionForm = document.getElementById('leaveActionForm');
        if (leaveActionForm) {
            leaveActionForm.addEventListener('submit', function(e) {
                // Show loading state
                const submitBtn = document.getElementById('modalSubmitBtn');
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Processing...';
                }
            });
        }

        // Concern Confirmation Modal Functions
        function openConcernConfirmModal(concernId, employeeName, concernType, subject, action) {
            document.getElementById('concernModalConcernId').value = concernId;
            document.getElementById('concernModalConcernAction').value = action;
            document.getElementById('concernModalEmployeeName').textContent = employeeName;
            document.getElementById('concernModalConcernType').textContent = concernType;
            document.getElementById('concernModalSubject').textContent = subject;
            
            const modal = document.getElementById('concernConfirmModal');
            const title = document.getElementById('concernModalTitle');
            const message = document.getElementById('concernModalMessage');
            const submitBtn = document.getElementById('concernModalSubmitBtn');
            
            if (action === 'approve') {
                title.textContent = 'Approve Employee Concern';
                message.textContent = 'Are you sure you want to approve this concern? It will be marked as "In Progress" and an email notification will be sent to the employee.';
                submitBtn.textContent = 'Approve';
                submitBtn.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
            } else {
                title.textContent = 'Decline Employee Concern';
                message.textContent = 'Are you sure you want to decline/close this concern? It will be marked as "Closed" and an email notification will be sent to the employee.';
                submitBtn.textContent = 'Decline';
                submitBtn.style.background = 'linear-gradient(135deg, #dc3545, #c82333)';
            }
            
            modal.style.display = 'block';
        }

        function closeConcernConfirmModal() {
            document.getElementById('concernConfirmModal').style.display = 'none';
        }

        // Close concern modal when clicking outside
        window.onclick = function(event) {
            const leaveModal = document.getElementById('leaveConfirmModal');
            const concernModal = document.getElementById('concernConfirmModal');
            if (event.target == leaveModal) {
                closeLeaveConfirmModal();
            }
            if (event.target == concernModal) {
                closeConcernConfirmModal();
            }
        }

        // Handle concern form submission
        const concernActionForm = document.getElementById('concernActionForm');
        if (concernActionForm) {
            concernActionForm.addEventListener('submit', function(e) {
                // Show loading state
                const submitBtn = document.getElementById('concernModalSubmitBtn');
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Processing...';
                }
            });
        }

        // Employee Details Modal Functions
        function viewEmployeeDetails(employeeId) {
            const modal = document.getElementById('employeeDetailsModal');
            const content = document.getElementById('employeeDetailsContent');
            
            // Show modal with loading state
            modal.style.display = 'block';
            content.innerHTML = `
                <div style="text-align: center; padding: 20px;">
                    <div class="spinner" style="border: 4px solid #f3f3f3; border-top: 4px solid #8B4513; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto;"></div>
                    <p style="margin-top: 10px; color: #666;">Loading employee information...</p>
                </div>
            `;
            
            // Fetch employee details via AJAX
            const url = 'EmployeeDetailsHandler.ashx?employeeId=' + encodeURIComponent(employeeId);
            console.log('Fetching employee details from:', url);
            
            fetch(url)
                .then(response => {
                    console.log('Response status:', response.status, response.statusText);
                    return response.text().then(text => {
                        if (!response.ok) {
                            // Return the error HTML from the server
                            throw { status: response.status, html: text, message: `HTTP error! status: ${response.status}` };
                        }
                        return text;
                    });
                })
                .then(html => {
                    console.log('Received HTML length:', html.length);
                    if (html && html.trim().length > 0) {
                        content.innerHTML = html;
                    } else {
                        throw { message: 'Empty response received', html: '' };
                    }
                })
                .catch(error => {
                    console.error('Error loading employee details:', error);
                    // If we have HTML from the server error, use it; otherwise show generic error
                    if (error.html) {
                        content.innerHTML = error.html;
                    } else {
                        content.innerHTML = `
                            <div style="text-align: center; padding: 20px; color: #dc3545;">
                                <p><strong>Error loading employee details</strong></p>
                                <p style="font-size: 12px; color: #999; margin-top: 10px;">${error.message || 'Unknown error'}</p>
                                <p style="font-size: 11px; color: #999; margin-top: 5px;">Please check the Visual Studio Output window for detailed error information.</p>
                                <button class="btn btn-outline" onclick="closeEmployeeDetailsModal()" style="margin-top: 15px;">Close</button>
                            </div>
                        `;
                    }
                });
        }

        function closeEmployeeDetailsModal() {
            document.getElementById('employeeDetailsModal').style.display = 'none';
        }

        // Close employee details modal when clicking outside
        window.onclick = function(event) {
            const leaveModal = document.getElementById('leaveConfirmModal');
            const concernModal = document.getElementById('concernConfirmModal');
            const employeeModal = document.getElementById('employeeDetailsModal');
            if (event.target == leaveModal) {
                closeLeaveConfirmModal();
            }
            if (event.target == concernModal) {
                closeConcernConfirmModal();
            }
            if (event.target == employeeModal) {
                closeEmployeeDetailsModal();
            }
        }
    </script>

    <style>
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #8B4513;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
        }
        .employee-details-section {
            margin-bottom: 25px;
        }
        .employee-details-section h4 {
            color: #8B4513;
            border-bottom: 2px solid #8B4513;
            padding-bottom: 8px;
            margin-bottom: 15px;
        }
        .employee-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }
        .employee-info-item {
            display: flex;
            flex-direction: column;
        }
        .employee-info-item label {
            font-weight: 600;
            color: #666;
            font-size: 12px;
            margin-bottom: 5px;
        }
        .employee-info-item span {
            color: #333;
            font-size: 14px;
        }
        .employee-details-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        .employee-details-table th,
        .employee-details-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        .employee-details-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #666;
        }
    </style>

    <script>
        function filterByDate(dateValue) {
            if (dateValue) {
                // Submit form with date parameter
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = window.location.pathname;
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'dateSelect';
                input.value = dateValue;
                form.appendChild(input);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        function resetDate() {
            // Reset to today's date
            var today = new Date();
            var todayStr = today.getFullYear() + '-' + 
                          String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                          String(today.getDate()).padStart(2, '0');
            document.getElementById('dateFilter').value = todayStr;
            filterByDate(todayStr);
        }

        function exportToPDF() {
            // Redirect to PDF export page with selected date
            var dateValue = document.getElementById('dateFilter').value;
            var url = 'EmployeeReport.aspx?date=' + encodeURIComponent(dateValue);
            window.open(url, '_blank');
        }
    </script>
</asp:Content>