<%@ Page Title="Employee Profile" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master" AutoEventWireup="true" Async="true" CodeBehind="Profile.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

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
        font-family: 'Poppins', sans-serif;
    }

    body {
        font-family: 'Poppins', sans-serif;
    }

    .profile-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .profile-name.compact {
        font-size: 20px;
        font-weight: 700;
        margin-bottom: 4px;
        font-family: 'Poppins', sans-serif;
    }

    .profile-position.compact {
        font-size: 14px;
        opacity: 0.9;
        font-family: 'Poppins', sans-serif;
    }

    .profile-body.compact {
        padding: 16px;
        font-family: 'Poppins', sans-serif;
    }

    .profile-body.compact .info-row {
        padding: 10px 0;
        border-bottom: 1px solid var(--border-color);
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 8px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .profile-body.compact .info-value {
        font-size: 14px;
        font-weight: 600;
        color: var(--text-primary);
        text-align: right;
        font-family: 'Poppins', sans-serif;
    }

    /* Attendance Card */
    .attendance-card {
        background: white;
        border-radius: var(--border-radius);
        box-shadow: var(--card-shadow);
        padding: 24px;
        font-family: 'Poppins', sans-serif;
    }

    .card-title {
        font-size: 20px;
        font-weight: 700;
        color: var(--text-primary);
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .stat-value {
        font-size: 32px;
        font-weight: 800;
        color: var(--primary-color);
        margin-bottom: 8px;
        font-family: 'Poppins', sans-serif;
    }

    .stat-label {
        font-size: 13px;
        font-weight: 600;
        color: var(--text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .action-title {
        font-size: 20px;
        font-weight: 700;
        color: var(--text-primary);
        margin-bottom: 12px;
        font-family: 'Poppins', sans-serif;
    }

    .action-description {
        font-size: 14px;
        color: var(--text-secondary);
        line-height: 1.6;
        margin-bottom: 16px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .action-button:hover {
        transform: scale(1.05);
        box-shadow: 0 5px 15px rgba(164, 79, 86, 0.3);
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
        border-radius: var(--border-radius);
        width: 90%;
        max-width: 600px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        animation: slideDown 0.3s ease;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .modal-title {
        font-size: 24px;
        font-weight: 700;
        font-family: 'Poppins', sans-serif;
    }

    .modal-body {
        padding: 24px;
        max-height: 500px;
        overflow-y: auto;
        font-family: 'Poppins', sans-serif;
    }

    .form-group {
        margin-bottom: 20px;
        font-family: 'Poppins', sans-serif;
    }

    .form-label {
        display: block;
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 8px;
        font-size: 14px;
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .modal-footer {
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
        font-family: 'Poppins', sans-serif;
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
        font-family: 'Poppins', sans-serif;
    }

    .payslip-label {
        font-weight: 600;
        color: var(--text-secondary);
        font-family: 'Poppins', sans-serif;
    }

    .payslip-value {
        font-weight: 700;
        color: var(--text-primary);
        font-size: 16px;
        font-family: 'Poppins', sans-serif;
    }

    .payslip-total {
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        color: white;
        padding: 16px;
        border-radius: 12px;
        margin-top: 16px;
        font-family: 'Poppins', sans-serif;
    }

    .payslip-total .payslip-value {
        color: white;
        font-size: 24px;
        font-family: 'Poppins', sans-serif;
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
                        <span class="info-label">🎂 Birthdate</span>
                        <span class="info-value"><%= GetEmployeeBirthdate() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">👤 Age</span>
                        <span class="info-value"><%= GetEmployeeAge() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">⚧ Sex</span>
                        <span class="info-value"><%= GetEmployeeSex() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">📋 Contract Type</span>
                        <span class="info-value" style="color: var(--success-color);"><%= GetEmployeeStatus() %></span>
                    </div>
                </div>
            </div>

            <!-- Right: Attendance Summary (unchanged) -->
            <div class="attendance-card">
                <h2 class="card-title">📊 Attendance Summary</h2>
                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="stat-value"><%= GetDaysPresent() %></div>
                        <div class="stat-label">Days Present</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value"><%= GetDaysAbsent() %></div>
                        <div class="stat-label">Days Absent</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value"><%= GetDaysLate() %></div>
                        <div class="stat-label">Days Late</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-value" style="color: var(--success-color);"><%= GetAttendanceRate() %>%</div>
                        <div class="stat-label">Attendance Rate</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Cards -->
        <div class="actions-grid">
            <div class="action-card">
                <div class="action-icon">💰</div>
                <h3 class="action-title">View Payslip</h3>
                <p class="action-description">View your salary breakdown including gross salary, deductions, and net pay.</p>
                <button type="button" class="action-button" onclick="openPayslipModal(event); return false;">View Details</button>
            </div>

            <div class="action-card">
                <div class="action-icon">📝</div>
                <h3 class="action-title">File Leave of Absence</h3>
                <p class="action-description">Submit your leave request for sick leave, vacation, or personal matters.</p>
                <button type="button" class="action-button" onclick="openLeaveModal(event); return false;">File Leave</button>
            </div>

            <div class="action-card">
                <div class="action-icon">💬</div>
                <h3 class="action-title">Report Employee Concern</h3>
                <p class="action-description">Submit any workplace concerns, complaints, or suggestions to HR.</p>
                <button type="button" class="action-button" onclick="openConcernModal(event); return false;">Submit Concern</button>
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
                <h2 class="modal-title">💬 Submit Employee Concern</h2>
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
        function openPayslipModal(event) {
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }
            document.getElementById('payslipModal').style.display = 'block';
            return false;
        }

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