<%@ Page Title="Employee Profile" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm2" %>
<%@ Import Namespace="ExWebAppSia.Models" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --primary-color: #A44F56;
            --secondary-color: #DE9D9D;
            --accent-color: #FFE8E8;
            --card-shadow: 0 10px 30px rgba(164, 79, 86, 0.15);
            --hover-shadow: 0 15px 40px rgba(164, 79, 86, 0.25);
            --border-radius: 20px;
            --text-primary: #4A2E2E;
            --text-secondary: #6B4545;
            --text-muted: #9B7B7B;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --border-color: #E8C4C4;
        }

        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
        }

        .profile-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .profile-grid {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }

        /* Compact Profile Card */
        .profile-card.compact {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            max-width: 320px;
        }

        .profile-card.compact:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }

        .profile-header.compact {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            padding: 20px 16px;
            text-align: center;
            color: white;
        }

        .profile-avatar.compact {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(10px);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            border: 3px solid rgba(255, 255, 255, 0.5);
            font-size: 32px;
            font-weight: 800;
        }

        .profile-name.compact {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .profile-position.compact {
            font-size: 14px;
            opacity: 0.9;
        }

        .profile-body.compact {
            padding: 16px;
        }

        .profile-body.compact .info-row {
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
        }

        .profile-body.compact .info-row:last-child {
            border-bottom: none;
        }

        .profile-body.compact .info-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .profile-body.compact .info-value {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            text-align: right;
        }

        /* Attendance Card (unchanged) */
        .attendance-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            padding: 24px;
        }

        .card-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 16px;
        }

        .stat-box {
            background: linear-gradient(135deg, var(--accent-color), #FFF5F5);
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            border: 1px solid var(--border-color);
        }

        .stat-value {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary-color);
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Action Cards Grid */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-top: 24px;
        }

        .action-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            padding: 28px;
            transition: all 0.3s ease;
            cursor: pointer;
            border: 2px solid transparent;
        }

        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
            border-color: var(--primary-color);
        }

        .action-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 16px;
            color: white;
        }

        .action-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 12px;
        }

        .action-description {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 16px;
        }

        .action-button {
            width: 100%;
            padding: 12px 24px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .action-button:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(164, 79, 86, 0.3);
        }

        /* Modal Styles (unchanged) */
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
            border-radius: var(--border-radius);
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
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 24px;
            border-radius: var(--border-radius) var(--border-radius) 0 0;
        }

        .modal-title {
            font-size: 24px;
            font-weight: 700;
        }

        .modal-body {
            padding: 24px;
            max-height: 500px;
            overflow-y: auto;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(164, 79, 86, 0.1);
        }

        .form-textarea {
            resize: vertical;
            min-height: 100px;
        }

        .modal-footer {
            padding: 16px 24px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            border-top: 1px solid var(--border-color);
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
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
        }

        .btn-submit:hover {
            transform: scale(1.05);
        }

        .btn-cancel {
            background: #E5E7EB;
            color: var(--text-primary);
        }

        .btn-cancel:hover {
            background: #D1D5DB;
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

        /* Payslip Styles */
        .payslip-item {
            padding: 12px 16px;
            background: var(--accent-color);
            border-radius: 8px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .payslip-label {
            font-weight: 600;
            color: var(--text-secondary);
        }

        .payslip-value {
            font-weight: 700;
            color: var(--text-primary);
            font-size: 16px;
        }

        .payslip-total {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 16px;
            border-radius: 12px;
            margin-top: 16px;
        }

        .payslip-total .payslip-value {
            color: white;
            font-size: 24px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }
            .profile-card.compact {
                max-width: none;
            }
        }

        @media (max-width: 768px) {
            .actions-grid {
                grid-template-columns: 1fr;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="profile-container">
        <div class="profile-grid">
            <!-- Left: Compact Profile Card -->
            <div class="profile-card compact">
                <div class="profile-header compact">
                    <div class="profile-avatar compact"><%= GetEmployeeInitials() %></div>
                    <div class="profile-name compact"><%= GetEmployeeName() %></div>
                    <div class="profile-position compact"><%= GetEmployeeRole() %></div>
                </div>
                <div class="profile-body compact">
                    <div class="info-row">
                        <span class="info-label">🆔 Employee ID</span>
                        <span class="info-value"><%= GetEmployeeId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📧 Email</span>
                        <span class="info-value"><%= GetEmployeeEmail() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📞 Contact</span>
                        <span class="info-value"><%= GetEmployeeContact() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📍 Address</span>
                        <span class="info-value"><%= GetEmployeeAddress() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">🏢 Department</span>
                        <span class="info-value"><%= CurrentEmployee?.Department ?? "N/A" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📅 Hired Date</span>
                        <span class="info-value"><%= CurrentEmployee?.HiredDate.ToLocalTime().ToString("MMM dd, yyyy") ?? "N/A" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📋 Contract Type</span>
                        <span class="info-value" style="color: var(--success-color);"><%= CurrentEmployee?.ContractType ?? "Regular" %></span>
                    </div>
                </div>
            </div>

            <!-- Right: Attendance Summary (unchanged) -->
            <div class="attendance-card">
                <h2 class="card-title">📊 Attendance Summary</h2>
                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="stat-value">154</div>
                        <div class="stat-label">Days Present</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value">4</div>
                        <div class="stat-label">Days Absent</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value">1</div>
                        <div class="stat-label">Days Late</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value" style="color: var(--success-color);">97%</div>
                        <div class="stat-label">Attendance Rate</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Cards -->
        <div class="actions-grid">
            <div class="action-card" onclick="openPayslipModal()">
                <div class="action-icon">💰</div>
                <h3 class="action-title">View Payslip</h3>
                <p class="action-description">View your salary breakdown including gross salary, deductions, and net pay.</p>
                <button class="action-button">View Details</button>
            </div>

            <div class="action-card" onclick="openLeaveModal()">
                <div class="action-icon">📝</div>
                <h3 class="action-title">File Leave of Absence</h3>
                <p class="action-description">Submit your leave request for sick leave, vacation, or personal matters.</p>
                <button class="action-button">File Leave</button>
            </div>

            <div class="action-card" onclick="openConcernModal()">
                <div class="action-icon">💬</div>
                <h3 class="action-title">Report Employee Concern</h3>
                <p class="action-description">Submit any workplace concerns, complaints, or suggestions to HR.</p>
                <button class="action-button">Submit Concern</button>
            </div>
        </div>
    </div>

    <!-- Payslip Modal -->
    <div id="payslipModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('payslipModal')">&times;</span>
                <h2 class="modal-title">💰 Payslip Details</h2>
            </div>
            <div class="modal-body">
                <h3 style="margin-bottom: 16px; color: var(--text-primary);">Gross Salary</h3>
                <div class="payslip-item">
                    <span class="payslip-label">Basic Salary</span>
                    <span class="payslip-value">₱35,000.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Allowances</span>
                    <span class="payslip-value">₱5,000.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Overtime Pay</span>
                    <span class="payslip-value">₱2,500.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label"><strong>Total Gross</strong></span>
                    <span class="payslip-value"><strong>₱42,500.00</strong></span>
                </div>

                <h3 style="margin: 24px 0 16px; color: var(--text-primary);">Deductions</h3>
                <div class="payslip-item">
                    <span class="payslip-label">SSS</span>
                    <span class="payslip-value" style="color: var(--warning-color);">- ₱1,350.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">PhilHealth</span>
                    <span class="payslip-value" style="color: var(--warning-color);">- ₱850.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Pag-IBIG</span>
                    <span class="payslip-value" style="color: var(--warning-color);">- ₱200.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Withholding Tax</span>
                    <span class="payslip-value" style="color: var(--warning-color);">- ₱3,200.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label"><strong>Total Deductions</strong></span>
                    <span class="payslip-value" style="color: var(--warning-color);"><strong>- ₱5,600.00</strong></span>
                </div>

                <div class="payslip-total">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span class="payslip-label" style="color: white; font-size: 18px;">Net Salary</span>
                        <span class="payslip-value">₱36,900.00</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" onclick="closeModal('payslipModal')">Close</button>
                <button class="btn-submit">Download PDF</button>
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
            <asp:Panel ID="pnlLeaveForm" runat="server">
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label" for="<%= ddlLeaveType.ClientID %>">Leave Type *</label>
                        <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="form-select">
                            <asp:ListItem Value="">Select leave type</asp:ListItem>
                            <asp:ListItem Value="sick">Sick Leave</asp:ListItem>
                            <asp:ListItem Value="vacation">Vacation Leave</asp:ListItem>
                            <asp:ListItem Value="personal">Personal Leave</asp:ListItem>
                            <asp:ListItem Value="emergency">Emergency Leave</asp:ListItem>
                            <asp:ListItem Value="maternity">Maternity Leave</asp:ListItem>
                            <asp:ListItem Value="paternity">Paternity Leave</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= txtStartDate.ClientID %>">Start Date *</label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-input" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= txtEndDate.ClientID %>">End Date *</label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-input" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= txtLeaveReason.ClientID %>">Reason for Leave *</label>
                        <asp:TextBox ID="txtLeaveReason" runat="server" CssClass="form-textarea" TextMode="MultiLine" Rows="4" placeholder="Please provide details about your leave request..."></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= fileLeaveAttachment.ClientID %>">Attachment (Optional)</label>
                        <asp:FileUpload ID="fileLeaveAttachment" runat="server" CssClass="form-input" />
                    </div>
                    <asp:Label ID="lblLeaveMessage" runat="server" CssClass="form-label" style="display:none; margin-top: 10px; padding: 10px; border-radius: 5px;"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('leaveModal')">Cancel</button>
                    <asp:Button ID="btnSubmitLeave" runat="server" Text="Submit Leave Request" CssClass="btn-submit" OnClick="btnSubmitLeave_Click" UseSubmitBehavior="true" CausesValidation="false" OnClientClick="return submitLeaveForm();" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Concern Modal -->
    <div id="concernModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('concernModal')">&times;</span>
                <h2 class="modal-title">💬 Submit Employee Concern</h2>
            </div>
            <asp:Panel ID="pnlConcernForm" runat="server">
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label" for="<%= ddlConcernType.ClientID %>">Concern Type *</label>
                        <asp:DropDownList ID="ddlConcernType" runat="server" CssClass="form-select">
                            <asp:ListItem Value="">Select concern type</asp:ListItem>
                            <asp:ListItem Value="workplace">Workplace Issue</asp:ListItem>
                            <asp:ListItem Value="harassment">Harassment/Bullying</asp:ListItem>
                            <asp:ListItem Value="safety">Safety Concern</asp:ListItem>
                            <asp:ListItem Value="payroll">Payroll Issue</asp:ListItem>
                            <asp:ListItem Value="benefits">Benefits Inquiry</asp:ListItem>
                            <asp:ListItem Value="equipment">Equipment/Facilities</asp:ListItem>
                            <asp:ListItem Value="suggestion">Suggestion/Feedback</asp:ListItem>
                            <asp:ListItem Value="other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= txtConcernSubject.ClientID %>">Subject *</label>
                        <asp:TextBox ID="txtConcernSubject" runat="server" CssClass="form-input" placeholder="Brief subject of your concern"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= txtConcernDescription.ClientID %>">Description *</label>
                        <asp:TextBox ID="txtConcernDescription" runat="server" CssClass="form-textarea" TextMode="MultiLine" Rows="5" placeholder="Please provide detailed information about your concern..."></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= ddlPriorityLevel.ClientID %>">Priority Level</label>
                        <asp:DropDownList ID="ddlPriorityLevel" runat="server" CssClass="form-select">
                            <asp:ListItem Value="low">Low</asp:ListItem>
                            <asp:ListItem Value="medium" Selected="True">Medium</asp:ListItem>
                            <asp:ListItem Value="high">High</asp:ListItem>
                            <asp:ListItem Value="urgent">Urgent</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="<%= fileSupportingDocs.ClientID %>">Supporting Documents (Optional)</label>
                        <asp:FileUpload ID="fileSupportingDocs" runat="server" CssClass="form-input" AllowMultiple="true" />
                    </div>
                    <asp:Label ID="lblConcernMessage" runat="server" CssClass="form-label" style="display:none; margin-top: 10px; padding: 10px; border-radius: 5px;"></asp:Label>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('concernModal')">Cancel</button>
                    <asp:Button ID="btnSubmitConcern" runat="server" Text="Submit Concern" CssClass="btn-submit" OnClick="btnSubmitConcern_Click" UseSubmitBehavior="true" CausesValidation="false" OnClientClick="if (!submitConcernForm()) { return false; }" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <script>
        function openPayslipModal() {
            document.getElementById('payslipModal').style.display = 'block';
        }

        function openLeaveModal() {
            var modal = document.getElementById('leaveModal');
            if (modal) {
                modal.style.display = 'block';
                // Disable HTML5 validation when modal opens
                var forms = document.getElementsByTagName('form');
                for (var i = 0; i < forms.length; i++) {
                    forms[i].noValidate = true;
                    forms[i].setAttribute('novalidate', 'novalidate');
                }
            }
        }

        function submitLeaveForm() {
            console.log('submitLeaveForm called');
            
            // Disable HTML5 validation
            var forms = document.getElementsByTagName('form');
            for (var i = 0; i < forms.length; i++) {
                forms[i].noValidate = true;
            }
            
            var leaveType = document.getElementById('<%= ddlLeaveType.ClientID %>');
            var startDate = document.getElementById('<%= txtStartDate.ClientID %>');
            var endDate = document.getElementById('<%= txtEndDate.ClientID %>');
            var reason = document.getElementById('<%= txtLeaveReason.ClientID %>');
            var messageLabel = document.getElementById('<%= lblLeaveMessage.ClientID %>');

            // Clear previous messages
            if (messageLabel) {
                messageLabel.style.display = 'none';
                messageLabel.textContent = '';
            }

            // Validate Leave Type
            if (!leaveType || leaveType.value === '' || leaveType.selectedIndex === 0) {
                if (messageLabel) {
                    messageLabel.textContent = 'Please select a leave type.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (leaveType) leaveType.focus();
                return false;
            }

            // Validate Start Date
            if (!startDate || startDate.value.trim() === '') {
                if (messageLabel) {
                    messageLabel.textContent = 'Please select a start date.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (startDate) startDate.focus();
                return false;
            }

            // Validate End Date
            if (!endDate || endDate.value.trim() === '') {
                if (messageLabel) {
                    messageLabel.textContent = 'Please select an end date.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (endDate) endDate.focus();
                return false;
            }

            // Validate Reason
            if (!reason || reason.value.trim() === '') {
                if (messageLabel) {
                    messageLabel.textContent = 'Please provide a reason for your leave.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (reason) reason.focus();
                return false;
            }

            // All validations passed
            console.log('Leave form validation passed');
            return true;
        }

        function openConcernModal() {
            var modal = document.getElementById('concernModal');
            if (modal) {
                modal.style.display = 'block';
                // Disable HTML5 validation when modal opens
                var forms = document.getElementsByTagName('form');
                for (var i = 0; i < forms.length; i++) {
                    forms[i].noValidate = true;
                    forms[i].setAttribute('novalidate', 'novalidate');
                }
            }
        }

        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }

        window.onclick = function (event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }

        function submitConcernForm() {
            console.log('submitConcernForm called');
            
            // Disable HTML5 validation on all forms and inputs
            var forms = document.getElementsByTagName('form');
            for (var i = 0; i < forms.length; i++) {
                forms[i].noValidate = true;
                forms[i].setAttribute('novalidate', 'novalidate');
            }
            
            // Remove required attributes from all inputs in the modal
            var modal = document.getElementById('concernModal');
            if (modal) {
                var inputs = modal.querySelectorAll('input, select, textarea');
                for (var i = 0; i < inputs.length; i++) {
                    inputs[i].removeAttribute('required');
                    inputs[i].required = false;
                }
            }
            
            var concernType = document.getElementById('<%= ddlConcernType.ClientID %>');
            var subject = document.getElementById('<%= txtConcernSubject.ClientID %>');
            var description = document.getElementById('<%= txtConcernDescription.ClientID %>');
            var messageLabel = document.getElementById('<%= lblConcernMessage.ClientID %>');

            // Clear previous messages
            if (messageLabel) {
                messageLabel.style.display = 'none';
                messageLabel.textContent = '';
            }

            // Validate Concern Type
            if (!concernType || concernType.value === '' || concernType.selectedIndex === 0) {
                if (messageLabel) {
                    messageLabel.textContent = 'Please select a concern type.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (concernType) concernType.focus();
                return false;
            }

            // Validate Subject
            if (!subject || subject.value.trim() === '') {
                if (messageLabel) {
                    messageLabel.textContent = 'Please enter a subject for your concern.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (subject) subject.focus();
                return false;
            }

            // Validate Description
            if (!description || description.value.trim() === '') {
                if (messageLabel) {
                    messageLabel.textContent = 'Please provide a description of your concern.';
                    messageLabel.style.display = 'block';
                    messageLabel.style.color = '#856404';
                    messageLabel.style.backgroundColor = '#fff3cd';
                    messageLabel.style.border = '1px solid #ffc107';
                }
                if (description) description.focus();
                return false;
            }

            // All validations passed - allow form submission
            console.log('Validation passed, submitting form');
            return true;
        }
    </script>
</asp:Content>