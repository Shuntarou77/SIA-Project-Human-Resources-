<%@ Page Title="Account" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Account.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.Account" %>
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
                max-width: 1500px;
                margin: 0 auto;
                padding: 40px;
                font-family: 'Poppins', sans-serif;
            }

            .profile-grid {
                display: grid;
                grid-template-columns: 380px 1fr;
                gap: 40px;
                margin-bottom: 40px;
                align-items: start;
            }

            /* Compact Profile Card */
            .profile-card.compact {
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                width: 100%;
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
                padding: 12px 0;
                border-bottom: 1px solid var(--border-color);
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
                font-family: 'Poppins', sans-serif;
            }

            @media (min-width: 300px) {
                .profile-body.compact .info-row {
                    flex-direction: row;
                    justify-content: space-between;
                    align-items: center;
                }
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
                word-break: break-word;
                flex: 1;
                margin-left: 20px;
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
                grid-template-columns: repeat(4, 1fr);
                gap: 16px;
            }

            .stat-box {
                background: linear-gradient(135deg, var(--accent-color), #FFF5F5);
                padding: 25px 15px;
                border-radius: 16px;
                text-align: center;
                border: 1.5px solid var(--border-color);
                font-family: 'Poppins', sans-serif;
                transition: transform 0.2s ease;
            }
            
            .stat-box:hover {
                transform: scale(1.05);
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
                grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                gap: 30px;
                margin-top: 40px;
            }

            .action-card {
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                padding: 35px;
                transition: all 0.3s ease;
                cursor: pointer;
                border: 2px solid transparent;
                font-family: 'Poppins', sans-serif;
                display: flex;
                flex-direction: column;
                min-height: 380px;
                justify-content: space-between;
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
                margin-top: auto;
            }

            .action-button:hover {
                transform: scale(1.05);
                box-shadow: 0 5px 15px rgba(164, 79, 86, 0.3);
            }

            /* Attendance Tracking Specific Styles */
            .attendance-status-info {
                text-align: center;
                margin-bottom: 25px;
                padding: 15px;
                background: var(--accent-color);
                border-radius: 12px;
                border: 1px solid var(--border-color);
            }

            .status-text {
                font-size: 16px;
                font-weight: 700;
                color: var(--primary-color);
            }

            .attendance-time-display {
                font-size: 24px;
                font-weight: 700;
                font-family: monospace;
                background: rgba(255, 255, 255, 0.4);
                padding: 5px 15px;
                border-radius: 10px;
                display: inline-block;
                color: var(--primary-color);
                margin-top: 10px;
            }

            .attendance-actions {
                display: flex;
                gap: 20px;
                justify-content: center;
            }

            .attendance-btn {
                padding: 15px 40px;
                border-radius: 12px;
                font-weight: 700;
                font-size: 16px;
                cursor: pointer;
                border: none;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                gap: 10px;
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
                text-transform: uppercase;
                color: white;
            }

            #timeInBtn {
                background: linear-gradient(135deg, #48BB78, #38A169);
            }

            #timeOutBtn {
                background: linear-gradient(135deg, #F56565, #E53E3E);
            }

            .attendance-btn:hover:not(:disabled) {
                transform: translateY(-3px);
                box-shadow: 0 12px 25px rgba(0, 0, 0, 0.15);
                filter: brightness(1.1);
            }

            .attendance-btn:disabled {
                background: #CBD5E0;
                cursor: not-allowed;
                box-shadow: none;
                transform: none;
            }

            .stats-row {
                display: flex !important;
                flex-direction: row !important;
                justify-content: space-between !important;
                gap: 16px !important;
                margin-top: 20px !important;
                margin-bottom: 25px !important;
                width: 100% !important;
            }

            .stats-row .stat-box {
                flex: 1 !important;
                background: linear-gradient(135deg, var(--accent-color), #FFF5F5);
                padding: 15px;
                border-radius: 12px;
                text-align: center;
                border: 1px solid var(--border-color);
                min-width: 0;
            }

            .stat-value {
                font-size: 28px;
                font-weight: 800;
                color: var(--primary-color);
                margin-bottom: 5px;
                font-family: 'Poppins', sans-serif;
            }

            .stat-label {
                font-size: 11px;
                font-weight: 700;
                color: var(--text-secondary);
                text-transform: uppercase;
                letter-spacing: 0.5px;
                font-family: 'Poppins', sans-serif;
            }

            /* Custom Modal Styles */
            .custom-modal-v2 {
                display: none;
                position: fixed;
                z-index: 9999 !important;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(8px);
            }

            .custom-modal-v2-content {
                background: white;
                margin: 50px auto;
                padding: 0;
                border-radius: var(--border-radius);
                width: 90%;
                max-width: 600px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                animation: customSlideDown 0.3s ease;
                font-family: 'Poppins', sans-serif;
                position: relative;
                z-index: 10000 !important;
            }

            @keyframes customSlideDown {
                from { opacity: 0; transform: translateY(-50px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .custom-modal-v2-header {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                padding: 24px;
                border-radius: var(--border-radius) var(--border-radius) 0 0;
                font-family: 'Poppins', sans-serif;
            }

            .custom-modal-v2-title {
                font-size: 24px;
                font-weight: 700;
                font-family: 'Poppins', sans-serif;
                margin: 0;
            }

            .custom-modal-v2-body {
                padding: 24px;
                max-height: 70vh;
                overflow-y: auto;
                font-family: 'Poppins', sans-serif;
            }

            .custom-modal-v2-footer {
                padding: 20px 24px;
                border-top: 1px solid var(--border-color);
                display: flex;
                justify-content: flex-end;
                gap: 12px;
                border-radius: 0 0 var(--border-radius) var(--border-radius);
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

            .btn-submit:hover { transform: scale(1.05); }

            .btn-cancel {
                background: #E5E7EB;
                color: var(--text-primary);
            }

            .btn-cancel:hover { background: #D1D5DB; }

            .modal-close-btn { cursor: pointer; }

            

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
            @media (max-width: 1200px) {
                .profile-grid { grid-template-columns: 1fr; }
                .profile-card.compact { max-width: 600px; margin: 0 auto; }
            }

            @media (max-width: 900px) {
                .actions-grid { grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }
            }

            @media (max-width: 768px) {
                .actions-grid { grid-template-columns: 1fr; }
                .stats-grid { grid-template-columns: repeat(2, 1fr); }
            }
        </style>
        
        <!-- html2pdf Library -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    </asp:Content>


    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <asp:HiddenField ID="hdnEmployeeName" runat="server" Value='<%# GetEmployeeName() %>' />
        
        <div class="profile-container">
            <div class="profile-grid">
                <!-- Left: Compact Profile Card -->
                <div class="profile-card compact">
                    <div class="profile-header compact">
                        <div class="profile-avatar compact">
                            <%= GetEmployeeInitials() %>
                        </div>
                        <div class="profile-name compact">
                            <%= GetEmployeeName() %>
                        </div>
                        <div class="profile-position compact">
                            <%= GetEmployeeRole() %>
                        </div>
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
                            <span class="info-label">📍 Dept</span>
                            <span class="info-value">
                                <%: GetEmployeeDepartment() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">💼 Role</span>
                            <span class="info-value">
                                <%: GetEmployeeRole() %>
                            </span>
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
                            <span class="info-label">🗓️ Probationary Start</span>
                            <span class="info-value"><%= GetHiredDate() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">📅 Regularization Start</span>
                            <span class="info-value"><%= GetRegularizationDate() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">📋 Status</span>
                            <span class="info-value" style="color: var(--success-color);"><%= GetEmployeeStatus() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">💰 Base Salary</span>
                            <span class="info-value" style="font-weight: 700; color: var(--primary-color);"><%= GetEmployeeSalary() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏢 SSS No.</span>
                            <span class="info-value"><%= GetSSSNumber() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏥 PhilHealth No.</span>
                            <span class="info-value"><%= GetPhilHealthNumber() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏠 Pag-IBIG No.</span>
                            <span class="info-value"><%= GetPagIbigNumber() %></span>
                        </div>
                    </div>
                </div>

                <!-- Right: Attendance Tracker -->
                <div class="attendance-card">
                    <h2 class="card-title">
                        <svg style="width:24px;height:24px;fill:currentColor" viewBox="0 0 24 24">
                            <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z" />
                        </svg>
                        Attendance Tracker
                    </h2>

                    <div class="attendance-body">
                        <div class="attendance-status-info">
                            <span id="attendanceStatusLabel" class="status-text">Not timed in yet</span>
                            <div id="currentDate" style="font-size: 13px; color: var(--text-secondary); margin-top: 5px;">--</div>
                            <div id="currentTime" class="attendance-time-display">00:00:00</div>
                        </div>

                        <div class="stats-row">
                            <div class="stat-box">
                                <div class="stat-value"><%= GetDaysPresent() %></div>
                                <div class="stat-label">Present</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-value"><%= GetDaysAbsent() %></div>
                                <div class="stat-label">Absent</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-value"><%= GetDaysLate() %></div>
                                <div class="stat-label">Late</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-value" style="color: var(--warning-color);"><%= GetRemainingAbsences() %></div>
                                <div class="stat-label">Absence Allowance</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-value" style="color: var(--success-color);"><%= GetTargetWorkingDays() %></div>
                                <div class="stat-label">Target</div>
                            </div>
                        </div>

                        <div class="attendance-actions" style="margin-bottom: 30px;">
                            <button id="timeInBtn" type="button" class="attendance-btn" onclick="timeIn()" disabled>
                                <svg style="width:20px;height:20px" viewBox="0 0 24 24"><path fill="currentColor" d="M14,12L10,8V11H2V13H10V16L14,12M22,12A10,10 0 0,1 12,22A10,10 0 0,1 2,12A10,10 0 0,1 12,2A10,10 0 0,1 22,12M20,12A8,8 0 0,0 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20A8,8 0 0,0 20,12Z" /></svg>
                                Time In
                            </button>
                            <button id="timeOutBtn" type="button" class="attendance-btn" onclick="timeOut()" disabled>
                                <svg style="width:20px;height:20px" viewBox="0 0 24 24"><path fill="currentColor" d="M10,17L15,12L10,7V10H2V14H10V17M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12,20A8,8 0 0,1 4,12A8,8 0 0,1 12,4A8,8 0 0,1 20,12A8,8 0 0,1 12,20Z" /></svg>
                                Time Out
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Cards -->
            <div class="actions-grid">
                <div class="action-card" onclick="document.getElementById('payslipModal').style.display='block';">
                    <div class="action-icon">💰</div>
                    <h3 class="action-title">View Payslip</h3>
                    <p class="action-description">View your salary breakdown including gross salary, deductions, and net pay.</p>
                    <button type="button" class="action-button" onclick="event.stopPropagation(); document.getElementById('payslipModal').style.display='block';">View Details</button>
                </div>

                <div class="action-card" onclick="document.getElementById('leaveModal').style.display='block';">
                    <div class="action-icon">📄</div>
                    <h3 class="action-title">File Leave of Absence</h3>
                    <p class="action-description">Submit your leave request for sick leave, vacation, or personal matters.</p>
                    <button type="button" class="action-button" onclick="event.stopPropagation(); document.getElementById('leaveModal').style.display='block';">File Leave</button>
                </div>

                <div class="action-card" onclick="document.getElementById('concernModal').style.display='block';">
                    <div class="action-icon">💬</div>
                    <h3 class="action-title">Report Employee Concern</h3>
                    <p class="action-description">Submit any workplace concerns, complaints, or suggestions to HR.</p>
                    <button type="button" class="action-button" onclick="event.stopPropagation(); document.getElementById('concernModal').style.display='block';">Submit Concern</button>
                </div>

                <div class="action-card" style="border-color: #fca5a5;" onclick="requestResignation();">
                    <div class="action-icon" style="background: linear-gradient(135deg, #ef4444, #fca5a5);">👋</div>
                    <h3 class="action-title">Request Resignation</h3>
                    <p class="action-description" id="resignationDesc">Officially submit your intent to resign. This will require HR approval before processing.</p>
                    <button type="button" class="action-button" style="background: linear-gradient(135deg, #ef4444, #fca5a5);" onclick="event.stopPropagation(); requestResignation();" id="btnResign">Request Resignation</button>
                    <p id="resignationStatusMsg" style="display:none; color: #ef4444; font-weight: bold; margin-top: 10px;"></p>
                </div>
            </div>
        </div>

        <!-- Payslip Modal -->
        <div id="payslipModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('payslipModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">💰 Payslip Details</h2>
                </div>
                <div class="custom-modal-v2-body">
                    <div class="payslip-item" style="margin-top: 15px; border-top: 1px solid #eee; padding-top: 10px;">
                        <span class="payslip-label">Pay Period</span>
                        <span id="ps_period" class="payslip-value" style="font-size: 14px; color: #666;"><%= GetPayPeriod() %></span>
                    </div>

                    <h3 style="margin: 20px 0 10px; color: #333; font-size: 18px;">Gross Salary</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">Basic Salary</span>
                        <div style="text-align: right;">
                            <span id="ps_basic" class="payslip-value">₱<%= GetBasicSalary() %></span>
                            <div style="font-size: 10px; color: #666; margin-top: 2px;"><%= GetSalaryValidationMessage() %></div>
                        </div>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Allowances</span>
                        <span id="ps_allowances" class="payslip-value">₱<%= GetAllowances() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Overtime Pay</span>
                        <span id="ps_ot" class="payslip-value">₱<%= GetOvertimePay() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label"><strong>Total Gross</strong></span>
                        <span id="ps_gross" class="payslip-value"><strong>₱<%= GetGrossSalary() %></strong></span>
                    </div>

                    <h3 style="margin: 20px 0 10px; color: #333; font-size: 18px;">Deductions</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">SSS</span>
                        <span id="ps_sss" class="payslip-value" style="color: #ef4444;">- ₱<%= GetSSSDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">PhilHealth</span>
                        <span id="ps_ph" class="payslip-value" style="color: #ef4444;">- ₱<%= GetPhilHealthDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Pag-IBIG</span>
                        <span id="ps_pi" class="payslip-value" style="color: #ef4444;">- ₱<%= GetPagIbigDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Withholding Tax</span>
                        <span id="ps_tax" class="payslip-value" style="color: #ef4444;">- ₱<%= GetWithholdingTax() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Absences &amp; Lates</span>
                        <span id="ps_absences" class="payslip-value" style="color: #ef4444;">- ₱<%= GetAbsenceDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Penalties</span>
                        <span id="ps_pen" class="payslip-value" style="color: #ef4444;">- ₱<%= GetPenalties() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label"><strong>Total Deductions</strong></span>
                        <span id="ps_total_deduct" class="payslip-value" style="color: #ef4444;"><strong>- ₱<%= GetTotalDeductions() %></strong></span>
                    </div>

                    <div class="payslip-total" style="background: #8B4755; color: white; padding: 15px; border-radius: 10px; margin-top: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="payslip-label" style="color: white; font-size: 18px;">Net Salary</span>
                            <span id="ps_net" class="payslip-value" style="font-size: 24px; font-weight: bold; color: white;">₱<%= GetNetSalary() %></span>
                        </div>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('payslipModal')">Close</button>
                    <button type="button" class="btn-submit" style="background: #8B4755; border: none; color: white; padding: 10px 20px; border-radius: 5px; cursor: pointer;" onclick="downloadPDF()">Download PDF</button>
                </div>
            </div>
        </div>

        <!-- Leave Modal -->
        <div id="leaveModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('leaveModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">📄 File Leave of Absence</h2>
                </div>
                <div class="custom-modal-v2-body">
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
                        <asp:TextBox ID="txtLeaveReason" runat="server" CssClass="form-textarea" TextMode="MultiLine"
                            placeholder="Please provide details about your leave request..."></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Attachment (Optional)</label>
                        <asp:FileUpload ID="fileLeaveAttachment" runat="server" CssClass="form-input"
                            accept=".pdf,.jpg,.png,.doc,.docx" />
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button class="btn-cancel" onclick="closeModal('leaveModal')">Cancel</button>
                    <asp:Button ID="btnSubmitLeave" runat="server" CssClass="btn-submit" Text="Submit Leave Request"
                        OnClick="btnSubmitLeave_Click" />
                </div>
            </div>
        </div>

        <!-- Concern Modal -->
        <div id="concernModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('concernModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">💬 Submit Employee Concern</h2>
                </div>
                <div class="custom-modal-v2-body">
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
                        <asp:TextBox ID="txtConcernSubject" runat="server" CssClass="form-input"
                            placeholder="Brief subject of your concern"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Description *</label>
                        <asp:TextBox ID="txtConcernDescription" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine"
                            placeholder="Please provide detailed information about your concern..."></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Supporting Documents (Optional)</label>
                        <asp:FileUpload ID="fileSupportingDocs" runat="server" CssClass="form-input"
                            accept=".pdf,.jpg,.png,.doc,.docx" />
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button class="btn-cancel" onclick="closeModal('concernModal')">Cancel</button>
                    <asp:Button ID="btnSubmitConcern" runat="server" CssClass="btn-submit" Text="Submit Concern"
                        OnClick="btnSubmitConcern_Click" />
                </div>
            </div>
        </div>

        <!-- Resignation Modal -->
        <div id="resignationModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 500px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #ef4444, #fca5a5);">
                    <button type="button" onclick="window.closeCustomModal('resignationModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">👋 Request Resignation</h2>
                </div>
                <div class="custom-modal-v2-body" style="padding: 25px;">
                    <p style="color: var(--text-secondary); margin-bottom: 20px; font-size: 15px;">
                        We're sorry to see you go. Please provide a brief reason for your resignation to help us improve.
                    </p>
                    <div class="form-group">
                        <label class="form-label" style="font-weight: 700;">Reason for Resignation *</label>
                        <textarea id="resignationReason" class="form-textarea" style="width: 100%; height: 120px; padding: 12px; border-radius: 12px; border: 1.5px solid var(--border-color); font-family: inherit; resize: none;" placeholder="Tell us why you're leaving (e.g., career growth, relocation, personal reasons)"></textarea>
                    </div>
                    <p style="color: #ef4444; font-size: 13px; margin-top: 15px; background: #fff1f2; padding: 10px; border-radius: 8px;">
                        <strong>Warning:</strong> This request will be sent to HR for approval. Account deactivation will occur once approved.
                    </p>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('resignationModal')">Cancel</button>
                    <button type="button" id="btnConfirmResign" class="btn-submit" style="background: #ef4444;" onclick="sendResignationRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Alert Modal -->
        <div id="alertModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 450px;">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('alertModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title" id="alertModalTitle">Notification</h2>
                </div>
                <div class="custom-modal-v2-body" style="text-align: center; padding: 40px 25px;">
                    <div id="alertModalIcon" style="font-size: 64px; margin-bottom: 20px;"></div>
                    <h3 id="alertModalStatus" style="font-size: 20px; color: var(--text-primary); margin-bottom: 10px;"></h3>
                    <p id="alertModalMessage" style="font-size: 15px; color: var(--text-secondary); line-height: 1.6;"></p>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-submit" onclick="closeModal('alertModal')">Close</button>
                </div>
            </div>
        </div>

        <div id="pageData"
            data-employee-id="<%= GetEmployeeId() %>"
            data-employee-name="<%= System.Web.HttpUtility.HtmlAttributeEncode(GetEmployeeName()) %>"
            data-employee-dept="<%= System.Web.HttpUtility.HtmlAttributeEncode(GetEmployeeDepartment()) %>"
            data-handler-url="<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>"
            data-attendance='<%= GetAttendanceStatusJsonString() %>'
            data-resignation-status="<%= GetResignationStatus() %>"
            style="display:none;"></div>

        <script>
            // Read server values from data attributes safely
            var pageData = document.getElementById('pageData');
            var employeeId = pageData.getAttribute('data-employee-id');
            var employeeName = pageData.getAttribute('data-employee-name');
            var employeeDepartment = pageData.getAttribute('data-employee-dept');
            var handlerUrl = pageData.getAttribute('data-handler-url');
            var attendanceStatus = {};
            try { attendanceStatus = JSON.parse(pageData.getAttribute('data-attendance')); } catch(e) { attendanceStatus = {}; }
            var resStatus = pageData.getAttribute('data-resignation-status');

            var hasTimedInSync = attendanceStatus.hasTimedIn || false;
            var hasTimedOutSync = attendanceStatus.hasTimedOut || false;

            function updateDateTime() {
                const now = new Date();
                const dateOpts = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                const timeOpts = { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true };
                document.getElementById('currentDate').textContent = now.toLocaleDateString(undefined, dateOpts);
                document.getElementById('currentTime').textContent = now.toLocaleTimeString(undefined, timeOpts);
            }

            setInterval(updateDateTime, 1000);
            updateDateTime();

            function loadStatus() {
                const statusLabel = document.getElementById('attendanceStatusLabel');
                const timeInBtn = document.getElementById('timeInBtn');
                const timeOutBtn = document.getElementById('timeOutBtn');
                
                if (attendanceStatus.hasTimedIn) {
                    if (attendanceStatus.hasTimedOut) {
                        if (statusLabel) {
                            statusLabel.textContent = `Timed Out at ${attendanceStatus.timeOut}`;
                            statusLabel.style.color = 'var(--warning-color)';
                        }
                        if (timeInBtn) timeInBtn.disabled = true;
                        if (timeOutBtn) timeOutBtn.disabled = true;
                    } else {
                        if (statusLabel) {
                            statusLabel.textContent = `Timed In at ${attendanceStatus.timeIn}`;
                            statusLabel.style.color = 'var(--success-color)';
                        }
                        if (timeInBtn) timeInBtn.disabled = true;
                        if (timeOutBtn) timeOutBtn.disabled = false;
                    }
                } else {
                    if (statusLabel) statusLabel.textContent = 'Not timed in yet';
                    if (timeInBtn) timeInBtn.disabled = false;
                    if (timeOutBtn) timeOutBtn.disabled = true;
                }
            }

            function timeIn() {
                handleAttendance('TimeIn');
            }

            function timeOut() {
                handleAttendance('TimeOut');
            }

            function handleAttendance(action) {
                const btn = action === 'TimeIn' ? document.getElementById('timeInBtn') : document.getElementById('timeOutBtn');
                const originalText = btn.innerHTML;
                
                btn.disabled = true;
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> processing...';

                fetch(handlerUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `action=${action}&employeeId=${employeeId}`
                })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showAlert('Success', data.message, 'success');
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        showAlert('Error', data.message, 'error');
                        btn.disabled = false;
                        btn.innerHTML = originalText;
                    }
                })
                .catch(err => {
                    showAlert('Error', 'Network error occurred.', 'error');
                    btn.disabled = false;
                    btn.innerHTML = originalText;
                });
            }

            document.addEventListener('DOMContentLoaded', loadStatus);

            function closeModal(modalId) {
                var el = document.getElementById(modalId);
                if (el) el.style.display = 'none';
            }

            function downloadPDF() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is still loading. Please wait a moment.');
                        return;
                    }

                    var name = employeeName;
                    var period = document.getElementById('ps_period').innerText;

                    var getVal = function(id) {
                        var el = document.getElementById(id);
                        return el ? el.innerText : '0.00';
                    };

                    var basic = getVal('ps_basic');
                    var allowances = getVal('ps_allowances');
                    var ot = getVal('ps_ot');
                    var gross = getVal('ps_gross');
                    var sss = getVal('ps_sss');
                    var ph = getVal('ps_ph');
                    var pi = getVal('ps_pi');
                    var tax = getVal('ps_tax');
                    var abs = getVal('ps_absences');
                    var pen = getVal('ps_pen');
                    var ded = getVal('ps_total_deduct');
                    var net = getVal('ps_net');

                    var element = document.createElement('div');
                    element.innerHTML = '<div style="padding:45px;font-family:Arial,sans-serif;color:#333;width:750px;margin:auto">'
                        + '<div style="text-align:center;border-bottom:3px solid #8B4755;padding-bottom:20px;margin-bottom:30px">'
                        + '<h1 style="color:#8B4755;margin:0;font-size:28px">SHEESSENTIALS HR SYSTEM</h1>'
                        + '<p style="font-size:14px;color:#666">OFFICIAL EMPLOYEE PAYSLIP</p></div>'
                        + '<table style="width:100%;margin-bottom:35px;background:#fafafa;padding:15px"><tr>'
                        + '<td><b>Employee:</b> ' + name + '</td>'
                        + '<td style="text-align:right"><b>Pay Period:</b> ' + period + '</td></tr></table>'
                        + '<h3 style="border-left:6px solid #8B4755;padding:10px;color:#8B4755">EARNINGS</h3>'
                        + '<table style="width:100%;border-collapse:collapse;margin-bottom:25px">'
                        + '<tr><td>Basic Salary</td><td style="text-align:right">' + basic + '</td></tr>'
                        + '<tr><td>Allowances</td><td style="text-align:right">' + allowances + '</td></tr>'
                        + '<tr><td>Overtime Pay</td><td style="text-align:right">' + ot + '</td></tr>'
                        + '<tr><td><b>Total Gross Pay</b></td><td style="text-align:right;color:#8B4755"><b>' + gross + '</b></td></tr></table>'
                        + '<h3 style="border-left:6px solid #dc2626;padding:10px;color:#dc2626">DEDUCTIONS</h3>'
                        + '<table style="width:100%;border-collapse:collapse;margin-bottom:25px">'
                        + '<tr><td>SSS</td><td style="text-align:right;color:#dc2626">' + sss + '</td></tr>'
                        + '<tr><td>PhilHealth</td><td style="text-align:right;color:#dc2626">' + ph + '</td></tr>'
                        + '<tr><td>Pag-IBIG</td><td style="text-align:right;color:#dc2626">' + pi + '</td></tr>'
                        + '<tr><td>Withholding Tax</td><td style="text-align:right;color:#dc2626">' + tax + '</td></tr>'
                        + '<tr><td>Absences and Lates</td><td style="text-align:right;color:#dc2626">' + abs + '</td></tr>'
                        + '<tr><td>Penalties</td><td style="text-align:right;color:#dc2626">' + pen + '</td></tr>'
                        + '<tr><td><b>Total Deductions</b></td><td style="text-align:right;color:#dc2626"><b>' + ded + '</b></td></tr></table>'
                        + '<div style="background:#8B4755;color:white;padding:30px;text-align:center;border-radius:12px">'
                        + '<p style="margin:0;font-size:14px">NET TAKE-HOME PAY</p>'
                        + '<h2 style="margin:5px 0 0;font-size:36px">' + net + '</h2></div>'
                        + '<p style="margin-top:40px;font-size:11px;color:#999;text-align:center">Generated: ' + new Date().toLocaleString() + '</p></div>';

                    var opt = {
                        margin: 0,
                        filename: 'Payslip_' + name.replace(/[^a-z0-9]/gi, '_') + '.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 3, useCORS: true },
                        jsPDF: { unit: 'in', format: 'letter', orientation: 'portrait' }
                    };

                    html2pdf().from(element).set(opt).save();
                } catch (err) {
                    alert('Error generating PDF: ' + err.message);
                }
            }

            // Global alias used by close buttons
            window.closeCustomModal = function(modalId) {
                var el = document.getElementById(modalId);
                if (el) { el.style.display = 'none'; }
                return false;
            };

            window.onclick = function (event) {
                if (event.target && event.target.classList && event.target.classList.contains('custom-modal-v2')) {
                    event.target.style.display = 'none';
                }
            };

            // Check resignation status on load
            // resStatus already set from pageData at top of script
            if (resStatus === 'Pending') {
                var btn = document.getElementById('btnResign');
                if (btn) {
                    btn.disabled = true;
                    btn.textContent = 'Resignation Pending Approval';
                    btn.style.background = '#94a3b8';
                }
                var msg = document.getElementById('resignationStatusMsg');
                if (msg) {
                    msg.textContent = 'Your resignation request is currently being reviewed by HR.';
                    msg.style.display = 'block';
                }
            }

            function showAlert(title, message, type = 'info') {
                document.getElementById('alertModalTitle').textContent = title;
                document.getElementById('alertModalMessage').textContent = message;
                const icon = document.getElementById('alertModalIcon');
                const status = document.getElementById('alertModalStatus');
                if (type === 'success') {
                    icon.innerHTML = '✅';
                    status.textContent = 'Success!';
                } else if (type === 'error') {
                    icon.innerHTML = '❌';
                    status.textContent = 'Error';
                } else {
                    icon.innerHTML = 'ℹ️';
                    status.textContent = 'Note';
                }
                document.getElementById('alertModal').style.display = 'block';
            }

            function requestResignation() {
                document.getElementById('resignationModal').style.display = 'block';
            }

            function sendResignationRequest() {
                const reason = document.getElementById('resignationReason').value.trim();
                if (!reason) {
                    showAlert('Required', 'Please provide a reason for resignation.', 'error');
                    return;
                }

                const btn = document.getElementById('btnConfirmResign');
                btn.disabled = true;
                btn.textContent = 'Processing...';

                fetch(handlerUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `action=requestResignation&employeeId=${employeeId}&reason=${encodeURIComponent(reason)}`
                })
                .then(res => res.json())
                .then(data => {
                    closeModal('resignationModal');
                    if (data.success) {
                        showAlert('Success', 'Resignation request submitted successfully. HR will review it.', 'success');
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showAlert('Failed', data.message, 'error');
                        btn.disabled = false;
                        btn.textContent = 'Submit Request';
                    }
                })
                .catch(err => {
                    closeModal('resignationModal');
                    showAlert('Error', 'Failed to submit request: ' + err.message, 'error');
                });
            }
        </script>
    </asp:Content>

