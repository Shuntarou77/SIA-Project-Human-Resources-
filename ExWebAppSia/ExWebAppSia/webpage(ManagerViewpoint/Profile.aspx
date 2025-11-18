<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" Async="true" CodeBehind="Profile.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* ✅ Pure white background — no gradient */
        .profile-wrapper {
            background-color: white;
            min-height: 100vh;
            padding: 30px 20px;
        }

        .profile-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .profile-header {
            color: #333;
            margin-bottom: 30px;
        }

        .profile-header h1 {
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand color */
        }

        .profile-header p {
            opacity: 0.8;
            font-size: 14px;
            color: #666;
        }

        /* Top Section - Manager Info Card */
        .manager-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
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
            background-color: #A36A66; /* ✅ Unified avatar */
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 60px;
            font-weight: bold;
            color: white;
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
            background: #fafafa;
            border-radius: 8px;
            border-left: 4px solid #A36A66; /* ✅ Brand accent */
        }

        .info-icon {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background-color: #A36A66; /* ✅ Unified icon bg */
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: white;
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
            background-color: #A36A66; /* ✅ Solid brand badge */
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
            border: 1px solid #eee;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: #A36A66; /* ✅ Brand header */
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-icon-header {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background-color: #A36A66;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: white;
        }

        /* Attendance Log Table */
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .attendance-table thead {
            background-color: #A36A66; /* ✅ Solid header */
        }

        .attendance-table th {
            padding: 12px 10px;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 11px;
            text-transform: uppercase;
        }

        .attendance-table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f0f0f0;
        }

        .attendance-table tbody tr:hover {
            background: #f9f9f9;
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
            background: #fafafa;
            border-radius: 8px;
            border-left: 4px solid #A36A66;
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

        .status-rejected {
            background: #f8d7da;
            color: #721c24;
        }

        /* Modal Styles */
        .modal {
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

        .modal-content {
            background: white;
            margin: 50px auto;
            padding: 0;
            border-radius: 12px;
            width: 90%;
            max-width: 600px;
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

        .modal-header {
            background: linear-gradient(135deg, #A36A66, #C49A99);
            color: white;
            padding: 24px;
            border-radius: 12px 12px 0 0;
        }

        .modal-title {
            font-size: 24px;
            font-weight: 700;
            margin: 0;
        }

        .modal-body {
            padding: 24px;
            max-height: 500px;
            overflow-y: auto;
        }

        .modal-footer {
            padding: 16px 24px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            border-top: 1px solid #eee;
        }

        .close {
            color: white;
            float: right;
            font-size: 32px;
            font-weight: bold;
            cursor: pointer;
            line-height: 1;
        }

        .close:hover {
            opacity: 0.7;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #eee;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: #A36A66;
            box-shadow: 0 0 0 3px rgba(163, 106, 102, 0.1);
        }

        .form-textarea {
            resize: vertical;
            min-height: 100px;
        }

        .btn-submit,
        .btn-cancel {
            padding: 10px 24px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-submit {
            background: linear-gradient(135deg, #A36A66, #C49A99);
            color: white;
        }

        .btn-submit:hover {
            transform: scale(1.05);
        }

        .btn-cancel {
            background: #E5E7EB;
            color: #333;
        }

        .btn-cancel:hover {
            background: #D1D5DB;
        }

        /* Forms Section */
        .forms-section {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 20px;
            margin: 0 auto;
            max-width: 1400px;
        }

        .form-card {
            flex: 0 1 calc(50% - 10px);
            max-width: 600px;
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #eee;
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
            background-color: #A36A66; /* ✅ Unified form icon */
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: white;
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
            background: linear-gradient(135deg, #A36A66, #8B5A58); /* ✅ Gradient to darker */
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
            box-shadow: 0 4px 8px rgba(163, 106, 102, 0.3);
        }

        /* Scrollbar */
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
            background: #A36A66;
            border-radius: 10px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
            .forms-section {
                flex-direction: column;
                align-items: center;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .form-card {
                flex: 0 1 100%;
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
                        <%= GetManagerInitials() %>
                    </div>
                    <div class="manager-details">
                        <h2 class="manager-name"><%= GetManagerName() %></h2>
                        <p class="manager-id">Manager ID: <%= GetManagerId() %></p>
                        
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-icon">🏢</div>
                                <div class="info-content">
                                    <div class="info-label">Department</div>
                                    <div class="info-value">
                                        <span class="department-badge"><%= GetManagerDepartment() %></span>
                                    </div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">📧</div>
                                <div class="info-content">
                                    <div class="info-label">Email</div>
                                    <div class="info-value"><%= GetManagerEmail() %></div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">📞</div>
                                <div class="info-content">
                                    <div class="info-label">Phone</div>
                                    <div class="info-value"><%= GetManagerPhone() %></div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">💼</div>
                                <div class="info-content">
                                    <div class="info-label">Role</div>
                                    <div class="info-value"><%= GetManagerRole() %></div>
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
                                <% if (AttendanceRecords != null && AttendanceRecords.Count > 0) { %>
                                    <% foreach (var record in AttendanceRecords) { %>
                                        <tr>
                                            <td><%= FormatAttendanceDate(record.Date) %></td>
                                            <td>
                                                <% if (record.TimeIn.HasValue) { %>
                                                    <span class="time-badge time-in"><%= FormatAttendanceTime(record.TimeIn) %></span>
                                                <% } else { %>
                                                    <span>--</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if (record.TimeOut.HasValue) { %>
                                                    <span class="time-badge time-out"><%= FormatAttendanceTime(record.TimeOut) %></span>
                                                <% } else { %>
                                                    <span>--</span>
                                                <% } %>
                                            </td>
                                            <td><%= GetAttendanceStatus(record) %></td>
                                        </tr>
                                    <% } %>
                                <% } else { %>
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 20px; color: #999;">
                                            No attendance records found.
                                        </td>
                                    </tr>
                                <% } %>
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
                        <% if (LeaveRecords != null && LeaveRecords.Count > 0) { %>
                            <% foreach (var leave in LeaveRecords) { %>
                                <li class="leave-item">
                                    <div class="leave-type"><%= leave.LeaveType %></div>
                                    <div class="leave-date"><%= FormatLeaveDateRange(leave.StartDate, leave.EndDate) %></div>
                                    <span class="leave-status <%= GetLeaveStatusClass(leave.Status) %>"><%= leave.Status %></span>
                                </li>
                            <% } %>
                        <% } else { %>
                            <li class="leave-item" style="text-align: center; color: #999; padding: 20px;">
                                No leave records found.
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>

            <!-- Forms Section - Now only 2 cards -->
            <div class="forms-section">
                <!-- Leave Application -->
                <div class="form-card">
                    <div class="form-icon">📄</div>
                    <h4 class="form-title">Leave Application</h4>
                    <p class="form-description">Submit a request for vacation, sick, or emergency leave.</p>
                    <button class="form-button" onclick="openLeaveModal(event); return false;">Apply Now</button>
                </div>

                <!-- Admin Concern -->
                <div class="form-card">
                    <div class="form-icon">📢</div>
                    <h4 class="form-title">Admin Concern</h4>
                    <p class="form-description">Submit issues, requests, or concerns to HR administration.</p>
                    <button class="form-button" onclick="openConcernModal(event); return false;">Concern</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Leave Modal -->
    <div id="leaveModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('leaveModal')">&times;</span>
                <h2 class="modal-title">📝 File Leave of Absence</h2>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblLeaveMessage" runat="server" style="display: none;"></asp:Label>
                <div class="form-group">
                    <label class="form-label">Leave Type *</label>
                    <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="form-select">
                        <asp:ListItem Value="" Text="Select leave type"></asp:ListItem>
                        <asp:ListItem Value="sick" Text="Sick Leave"></asp:ListItem>
                        <asp:ListItem Value="vacation" Text="Vacation Leave"></asp:ListItem>
                        <asp:ListItem Value="personal" Text="Personal Leave"></asp:ListItem>
                        <asp:ListItem Value="emergency" Text="Emergency Leave"></asp:ListItem>
                        <asp:ListItem Value="maternity" Text="Maternity Leave"></asp:ListItem>
                        <asp:ListItem Value="paternity" Text="Paternity Leave"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label class="form-label">Start Date *</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-input" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">End Date *</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-input" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Reason for Leave *</label>
                    <asp:TextBox ID="txtLeaveReason" runat="server" CssClass="form-textarea" TextMode="MultiLine" placeholder="Please provide details about your leave request..."></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Attachment (Optional)</label>
                    <asp:FileUpload ID="fileLeaveAttachment" runat="server" CssClass="form-input" accept=".pdf,.jpg,.png,.doc,.docx" />
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" onclick="closeModal('leaveModal')">Cancel</button>
                <asp:Button ID="btnSubmitLeave" runat="server" CssClass="btn-submit" Text="Submit Leave Request" OnClick="btnSubmitLeave_Click" />
            </div>
        </div>
    </div>

    <!-- Concern Modal -->
    <div id="concernModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('concernModal')">&times;</span>
                <h2 class="modal-title">💬 Submit Admin Concern</h2>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblConcernMessage" runat="server" style="display: none;"></asp:Label>
                <div class="form-group">
                    <label class="form-label">Concern Type *</label>
                    <asp:DropDownList ID="ddlConcernType" runat="server" CssClass="form-select">
                        <asp:ListItem Value="" Text="Select concern type"></asp:ListItem>
                        <asp:ListItem Value="workplace" Text="Workplace Issue"></asp:ListItem>
                        <asp:ListItem Value="harassment" Text="Harassment/Bullying"></asp:ListItem>
                        <asp:ListItem Value="safety" Text="Safety Concern"></asp:ListItem>
                        <asp:ListItem Value="payroll" Text="Payroll Issue"></asp:ListItem>
                        <asp:ListItem Value="benefits" Text="Benefits Inquiry"></asp:ListItem>
                        <asp:ListItem Value="equipment" Text="Equipment/Facilities"></asp:ListItem>
                        <asp:ListItem Value="suggestion" Text="Suggestion/Feedback"></asp:ListItem>
                        <asp:ListItem Value="other" Text="Other"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label class="form-label">Subject *</label>
                    <asp:TextBox ID="txtConcernSubject" runat="server" CssClass="form-input" placeholder="Brief subject of your concern"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Description *</label>
                    <asp:TextBox ID="txtConcernDescription" runat="server" CssClass="form-textarea" TextMode="MultiLine" placeholder="Please provide detailed information about your concern..."></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Priority Level</label>
                    <asp:DropDownList ID="ddlPriorityLevel" runat="server" CssClass="form-select">
                        <asp:ListItem Value="low" Text="Low"></asp:ListItem>
                        <asp:ListItem Value="medium" Text="Medium" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="high" Text="High"></asp:ListItem>
                        <asp:ListItem Value="urgent" Text="Urgent"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label class="form-label">Supporting Documents (Optional)</label>
                    <asp:FileUpload ID="fileSupportingDocs" runat="server" CssClass="form-input" accept=".pdf,.jpg,.png,.doc,.docx" />
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" onclick="closeModal('concernModal')">Cancel</button>
                <asp:Button ID="btnSubmitConcern" runat="server" CssClass="btn-submit" Text="Submit Concern" OnClick="btnSubmitConcern_Click" />
            </div>
        </div>
    </div>

    <script>
        function openLeaveModal(event) {
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            document.getElementById('leaveModal').style.display = 'block';
            return false;
        }

        function openConcernModal(event) {
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            document.getElementById('concernModal').style.display = 'block';
            return false;
        }

        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }

        window.onclick = function (event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
    </script>
</asp:Content>