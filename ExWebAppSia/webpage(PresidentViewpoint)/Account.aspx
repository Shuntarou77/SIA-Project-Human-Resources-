<%@ Page Title="Profile" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
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
                                <div class="stat-label">Working Days (Monthly)</div>
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

                <div class="action-card" onclick="openConcernHistoryModal()">
                    <div class="action-icon">🧾</div>
                    <h3 class="action-title">Concern History</h3>
                    <p class="action-description">Review your submitted employee concerns and track their status updates.</p>
                    <button type="button" class="action-button" onclick="openConcernHistoryModal(); return false;">View History</button>
                </div>

                <div class="action-card" style="border-color: #fca5a5;" onclick="requestResignation();">
                    <div class="action-icon" style="background: linear-gradient(135deg, #ef4444, #fca5a5);">👋</div>
                    <h3 class="action-title">Request Resignation</h3>
                    <p class="action-description" id="resignationDesc">Officially submit your intent to resign. This will require HR approval before processing.</p>
                    <button type="button" class="action-button" style="background: linear-gradient(135deg, #ef4444, #fca5a5);" onclick="event.stopPropagation(); requestResignation();" id="btnResign">Request Resignation</button>
                    <p id="resignationStatusMsg" style="display:none; color: #ef4444; font-weight: bold; margin-top: 10px;"></p>
                </div>

                <div class="action-card" onclick="openOvertimeModal()">
                    <div class="action-icon" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">⏱️</div>
                    <h3 class="action-title">Overtime Request</h3>
                    <p class="action-description">Submit your overtime request for review and approval by HR/Admin.</p>
                    <button type="button" class="action-button" onclick="openOvertimeModal(); return false;" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">Request Overtime</button>
                </div>

                <div class="action-card" onclick="openGovLoanFormsModal()">
                    <div class="action-icon">📥</div>
                    <h3 class="action-title">Downloadable Forms</h3>
                    <p class="action-description">Download official government loan forms (SSS, Pag-IBIG) for filing.</p>
                    <button type="button" class="action-button" onclick="openGovLoanFormsModal(); return false;" style="background: #4f46e5;">Choose Form</button>
                </div>

                <div class="action-card" onclick="openOngoingRequestsModal()">
                    <div class="action-icon">⏳</div>
                    <h3 class="action-title">On Going Requests</h3>
                    <p class="action-description">Monitor your currently pending and under-review requests.</p>
                    <button type="button" class="action-button" onclick="openOngoingRequestsModal(); return false;" style="margin-top:auto; background: linear-gradient(135deg, #8b5cf6, #7c3aed);">View Ongoing</button>
                </div>
                <div class="action-card" onclick="openRequestHistoryModal()">
                    <div class="action-icon">🗂️</div>
                    <h3 class="action-title">Request History</h3>
                    <p class="action-description">Review your recent request submissions and their final statuses.</p>
                    <button type="button" class="action-button" onclick="openRequestHistoryModal(); return false;" style="margin-top:auto;">View History</button>
                </div>
        </div>

        <div id="ongoingRequestsModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 700px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <button type="button" onclick="window.closeCustomModal('ongoingRequestsModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">⏳ On Going Requests</h2>
                </div>
                <div class="custom-modal-v2-body">
                    <div id="ongoingRequestsList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('ongoingRequestsModal')">Close</button>
                    <button type="button" class="btn-submit" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);" onclick="loadRequestMonitor()">Refresh List</button>
                </div>
            </div>
        </div>

        <div id="requestHistoryModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 700px;">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('requestHistoryModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">🗂️ Request History</h2>
                </div>
                <div class="custom-modal-v2-body">
                    <div id="requestHistoryList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('requestHistoryModal')">Close</button>
                    <button type="button" class="btn-submit" onclick="loadRequestMonitor()">Refresh History</button>
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
                    <button type="button" class="btn-cancel" onclick="openConcernHistoryModal()">View Concern History</button>
                    <button class="btn-cancel" onclick="closeModal('concernModal')">Cancel</button>
                    <asp:Button ID="btnSubmitConcern" runat="server" CssClass="btn-submit" Text="Submit Concern"
                        OnClick="btnSubmitConcern_Click" />
                </div>
            </div>
        </div>

        <div id="concernHistoryModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 700px;">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('concernHistoryModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">🧾 Employee Concern History</h2>
                </div>
                <div class="custom-modal-v2-body">
                    <div id="concernHistoryList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('concernHistoryModal')">Close</button>
                    <button type="button" class="btn-submit" onclick="loadConcernHistory()">Refresh</button>
                </div>
            </div>
        </div>

        <div id="govLoanFormsModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 800px;">
                <div class="custom-modal-v2-header">
                    <button type="button" onclick="window.closeCustomModal('govLoanFormsModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">📥 Government Loan Forms</h2>
                </div>
                <div class="custom-modal-v2-body">
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 14px;">
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">SSS</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Official SSS loan and maternity application forms.</p>
                            <button type="button" class="action-button" onclick="openGovForm('https://www.sss.gov.ph/wp-content/uploads/2022/03/mlp_01287.pdf')">Member Loan Application (MLP-01287)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('https://www.sss.gov.ph/wp-content/uploads/2022/03/calamity-loan-assistance-application.pdf')">Calamity Loan Assistance Application</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/MAT-1.pdf") %>')">Maternity Notification (MAT-1)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/MAT-2.pdf") %>')">Maternity Reimbursement (MAT-2)</button>
                        </div>
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">Pag-IBIG</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Official Pag-IBIG downloadable forms (Direct PDF).</p>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/PAG-iBIG-MPL.pdf") %>')">Multi-Purpose Loan (MPL - 09-2023)</button>
                        </div>
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">Other Forms</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Internal company forms and certifications.</p>
                            <button type="button" class="action-button" onclick="downloadCOEForm()">Certificate of Employment (COE)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="downloadClearanceForm()">Employee Clearance Form</button>
                        </div>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('govLoanFormsModal')">Close</button>
                </div>
            </div>
        </div>

        <!-- Overtime Modal -->
        <div id="overtimeModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 450px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <button type="button" onclick="window.closeCustomModal('overtimeModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">⏱️ Request Overtime</h2>
                </div>
                <div class="custom-modal-v2-body" style="padding: 30px;">
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Date of Overtime *</label>
                        <input type="date" id="txtOvertimeDate" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;" />
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div class="form-group">
                            <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Start Time *</label>
                            <input type="time" id="txtOvertimeStart" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;" onchange="calculateOTHours()" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">End Time *</label>
                            <input type="time" id="txtOvertimeEnd" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;" onchange="calculateOTHours()" />
                        </div>
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Total Hours Requested *</label>
                        <input type="number" id="txtOvertimeHours" step="0.1" min="0" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;" placeholder="Calculated hours..." />
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Detailed Justification *</label>
                        <textarea id="txtOvertimeReason" class="form-textarea" style="width: 100%; min-height: 80px; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; resize: none;" placeholder="Provide a detailed justification for the work..."></textarea>
                    </div>
                    <div style="background: #F5F3FF; border-left: 4px solid #8b5cf6; padding: 15px; border-radius: 0 8px 8px 0;">
                        <p style="color: #5b21b6; font-size: 13px; font-weight: 600;">
                            Note: Your request will be sent to Admin for approval.
                        </p>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('overtimeModal')">Cancel</button>
                    <button type="button" class="btn-submit" style="background: #8b5cf6;" onclick="submitOvertimeRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Resignation Modal -->
        <div id="resignationModal" class="custom-modal-v2">
            <div class="custom-modal-v2-content" style="max-width: 600px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #ef4444, #fca5a5);">
                    <button type="button" onclick="window.closeCustomModal('resignationModal'); return false;" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</button>
                    <h2 class="custom-modal-v2-title">👋 Resignation Request</h2>
                </div>
                <div class="custom-modal-v2-body" style="padding: 24px;">
                    <div id="resignationFormGroup">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                            <div class="form-group">
                                <label class="form-label">Resignation Date</label>
                                <input type="text" class="form-input" value="<%= DateTime.Now.ToString("MM/dd/yyyy") %>" readonly style="background: #f8fafc;" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">Effective Last Day *</label>
                                <input type="date" id="resign_lastDay" class="form-input" onchange="calculateNoticePeriod()" />
                                <div id="notice_calc_msg" style="font-size: 11px; margin-top: 4px; font-weight: 500;"></div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Reason Code *</label>
                            <select id="resign_reasonCode" class="form-select">
                                <option value="">-- Select Reason --</option>
                                <option value="Voluntary - Career Advancement">Voluntary - Career Advancement</option>
                                <option value="Voluntary - Personal/Family Reasons">Voluntary - Personal/Family Reasons</option>
                                <option value="Voluntary - Relocation">Voluntary - Relocation</option>
                                <option value="Voluntary - Health Reasons">Voluntary - Health Reasons</option>
                                <option value="Voluntary - Better Opportunities">Voluntary - Better Opportunities</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Comments/Reason *</label>
                            <textarea id="resignationReason" class="form-textarea" placeholder="I am writing to formally resign from my position..."></textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Attachment (Resignation Letter)</label>
                            <div style="border: 2px dashed var(--border-color); padding: 20px; border-radius: 12px; text-align: center; cursor: pointer; transition: all 0.3s ease;" 
                                 onclick="document.getElementById('resign_letter').click()"
                                 onmouseover="this.style.borderColor='var(--primary-color)'; this.style.background='#fdf2f2';"
                                 onmouseout="this.style.borderColor='var(--border-color)'; this.style.background='transparent';">
                                <input type="file" id="resign_letter" style="display: none;" onchange="updateFileName(this)" />
                                <div style="font-size: 24px; margin-bottom: 8px;">📄</div>
                                <div id="file_name_display" style="font-size: 13px; color: var(--text-secondary); font-weight: 500;">
                                    Upload Resignation Letter (PDF/DOC)
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="custom-modal-v2-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('resignationModal')">Cancel</button>
                    <button id="btnConfirmResign" type="button" class="btn-submit" style="background: #ef4444;" onclick="sendResignationRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Success/Alert Modal -->
        <div id="alertModal" class="custom-modal-v2" style="display:none; z-index:1001;">
            <div class="custom-modal-v2-content" style="max-width:400px; text-align:center; padding:40px 30px; border-radius: 24px;">
                <div id="alertIconContainer" style="width:80px; height:80px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 20px; background: #10b981;">
                    <i id="alertIcon" class="fas fa-check" style="font-size:32px; color:white;"></i>
                </div>
                <h3 id="alertModalTitle" style="font-size:24px; font-weight:800; color:var(--primary-color); margin-bottom:10px;">Success</h3>
                <p id="alertModalMessage" style="color:var(--text-secondary); font-size:15px; margin-bottom:30px;"></p>
                <button type="button" class="btn-submit" onclick="closeModal('alertModal')" style="min-width:160px; padding:14px; border-radius: 12px;">Acknowledged</button>
            </div>
        </div>

        <!-- Custom Confirm Modal -->
        <div id="confirmModal" class="custom-modal-v2" style="display:none;">
            <div class="custom-modal-v2-content" style="max-width: 440px;">
                <div class="custom-modal-v2-header" style="background: linear-gradient(135deg, #ef4444, #dc2626); border: none;">
                    <span onclick="closeConfirmModal()" style="position:absolute;top:16px;right:20px;background:rgba(255,255,255,0.25);border:none;color:white;font-size:22px;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;line-height:1;font-weight:bold;z-index:10001;">&times;</span>
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

        <!-- Undertime Modal -->
        <div id="undertimeModal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(5px);">
            <div style="background: white; margin: 100px auto; border-radius: 20px; width: 90%; max-width: 450px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); overflow: hidden; font-family: 'Poppins', sans-serif;">
                <div style="background: #ef4444; padding: 20px; color: white; text-align: center; position: relative;">
                    <span onclick="closeUndertimeModal()" style="position: absolute; left: 20px; top: 15px; font-size: 24px; cursor: pointer;">&times;</span>
                    <h3 style="margin: 0; font-size: 18px; font-weight: 700;">⚠️ Early Time Out</h3>
                </div>
                
                <!-- Question Body -->
                <div id="undertimeQuestionBody" style="padding: 40px 30px; text-align: center;">
                    <div style="background: #f3f4f6; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 32px;">🕒</div>
                    <h2 style="color: #111; font-size: 22px; font-weight: 800; margin-bottom: 12px;">Early Departure Detected</h2>
                    <p style="color: #4b5563; line-height: 1.6; margin-bottom: 30px; font-size: 15px;">
                        It's not yet 5:00 PM. Please select the type of undertime you are filing:
                    </p>
                    <div style="display: flex; flex-direction: column; gap: 15px; align-items: center;">
                        <button type="button" style="background: #ef4444; color: white; width: 100%; border: none; font-weight: 700; padding: 15px; border-radius: 12px; cursor: pointer; text-transform: uppercase;" onclick="emergencyQuickNotify()">🚨 EMERGENCY UT QUICK NOTIFY</button>
                        <button type="button" style="background: #3b82f6; color: white; width: 100%; border: none; font-weight: 700; padding: 15px; border-radius: 12px; cursor: pointer; text-transform: uppercase;" onclick="showRegularUndertimeForm()">📝 REGULAR UT REQUEST</button>
                    </div>
                    <div style="margin-top: 20px; font-size: 13px; color: #6b7280;">
                        Already have an approved request? <a href="javascript:void(0)" onclick="undertimeYes()" style="color: #3b82f6; font-weight: 600; text-decoration: none;">Check status here</a>
                    </div>
                </div>

                <!-- Form Body -->
                <div id="undertimeFormBody" style="display: none; padding: 30px;">
                    <button type="button" onclick="showUndertimeQuestion()" style="background:none; border:none; color:#6b7280; cursor:pointer; margin-bottom:15px; display:flex; align-items:center; gap:5px; font-weight:600; font-size: 14px;">
                        <span>← Back</span>
                    </button>
                    <h3 style="color: #111; margin-bottom: 15px; text-align: center; font-size: 20px;">Regular Undertime Request</h3>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div>
                            <label style="display: block; font-size: 13px; font-weight: 600; color: #4b5563; margin-bottom: 5px;">Departure Date *</label>
                            <input type="date" id="utDate" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 10px; font-size: 13px;" />
                        </div>
                        <div>
                            <label style="display: block; font-size: 13px; font-weight: 600; color: #4b5563; margin-bottom: 5px;">Departure Time *</label>
                            <input type="time" id="utTime" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 10px; font-size: 13px;" />
                        </div>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="display: block; font-size: 14px; font-weight: 600; color: #4b5563; margin-bottom: 8px;">Departure Reason *</label>
                        <textarea id="txtUndertimeReason" style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 10px; font-size: 14px; min-height: 80px; outline: none; transition: border 0.3s; resize: none;" placeholder="e.g., Medical appointment, Personal errands..."></textarea>
                    </div>
                    <div style="background: #F0F9FF; border-left: 4px solid #3b82f6; padding: 12px; border-radius: 4px; margin-bottom: 25px;">
                        <p style="color: #1e3a8a; font-size: 13px; font-weight: 600; margin: 0;">
                            Note: Requires HR STAFF approval before timing out.
                        </p>
                    </div>
                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button" style="padding: 10px 20px; border: none; border-radius: 10px; background: #f3f4f6; color: #4b5563; font-weight: 600; cursor: pointer;" onclick="closeUndertimeModal()">Cancel</button>
                        <button type="button" style="padding: 10px 20px; border: none; border-radius: 10px; background: #3b82f6; color: white; font-weight: 600; cursor: pointer;" onclick="submitRegularUndertime()">Submit Request</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Read server values directly from ASP.NET tags
            var employeeId = '<%= GetEmployeeId() %>';
            var employeeName = '<%= GetEmployeeName() %>';
            var employeeDepartment = '<%= GetEmployeeDepartment() %>';
            var handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
            var attendanceStatus = JSON.parse('<%= GetAttendanceStatusJsonString() %>');
            var resStatus = '<%= GetResignationStatus() %>';

            var hasTimedInSync = attendanceStatus.hasTimedIn || false;
            var hasTimedOutSync = attendanceStatus.hasTimedOut || false;

            // -------- Custom Modal Helpers --------
            function openModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) modal.style.display = 'block';
            }

            function closeModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) modal.style.display = 'none';
            }

            function showAlert(title, message, type = 'success') {
                const modal = document.getElementById('alertModal');
                if (!modal) {
                    alert(title + ": " + message);
                    return;
                }

                const titleEl = document.getElementById('alertModalTitle');
                const msgEl = document.getElementById('alertModalMessage');
                const statusEl = document.getElementById('alertModalStatus');
                const iconEl = document.getElementById('alertModalIcon');

                if (titleEl) titleEl.textContent = title;
                if (msgEl) msgEl.textContent = message;
                if (statusEl) statusEl.textContent = type.toUpperCase();

                if (iconEl) {
                    if (type === 'error') {
                        iconEl.innerHTML = '❌';
                        iconEl.style.color = '#ef4444';
                    } else {
                        iconEl.innerHTML = '✅';
                        iconEl.style.color = '#10b981';
                    }
                }

                modal.style.display = 'block';
            }
            // --------------------------------------

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
                modal.style.display = 'flex';
            }

            function closeConfirmModal() {
                document.getElementById('confirmModal').style.display = 'none';
                _confirmCallback = null;
            }
            // ---------------------------------------------

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
                const now = new Date();
                if (now.getHours() < 17) {
                    document.getElementById('undertimeModal').style.display = 'block';
                    
                    // Set defaults and min date
                    const today = now.toISOString().split('T')[0];
                    const h = String(now.getHours()).padStart(2, '0');
                    const m = String(now.getMinutes()).padStart(2, '0');
                    const dateInput = document.getElementById('utDate');
                    if (dateInput) {
                        dateInput.min = today;
                        dateInput.value = today;
                    }
                    if (document.getElementById('utTime')) document.getElementById('utTime').value = `${h}:${m}`;
                    
                    showUndertimeQuestion();
                } else {
                    handleAttendance('TimeOut');
                }
            }

            function closeUndertimeModal() {
                document.getElementById('undertimeModal').style.display = 'none';
            }

            function showUndertimeQuestion() {
                document.getElementById('undertimeQuestionBody').style.display = 'block';
                document.getElementById('undertimeFormBody').style.display = 'none';
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
                        try {
                            const params = new URLSearchParams({
                                action: 'emergencyundertime',
                                employeeId: employeeId
                            });

                            const response = await fetch(handlerUrl + '?' + params.toString());
                            const result = await response.json();

                            if (result.success) {
                                showAlert('Sent', 'Emergency notification sent! You have been timed out.', 'success');
                                setTimeout(() => location.reload(), 1500);
                            } else {
                                showAlert('Error', result.message, 'error');
                            }
                        } catch (err) {
                            showAlert('Error', 'Connection error', 'error');
                        }
                    }
                );
            }

            async function undertimeYes() {
                try {
                    const response = await fetch(`${handlerUrl}?action=getstatus&employeeId=${employeeId}`);
                    const status = await response.json();

                    if (status.undertimeStatus === 'Approved') {
                        handleAttendance('TimeOut');
                    } else if (status.undertimeStatus === 'Pending') {
                        showAlert('Pending', 'Your undertime request is still pending approval.', 'error');
                    } else {
                        showAlert('Not Found', 'No approved request found. Please submit a request.', 'error');
                    }
                } catch (err) {
                    showAlert('Error', 'Connection error', 'error');
                }
            }

            async function submitRegularUndertime() {
                const reason = document.getElementById('txtUndertimeReason').value.trim();
                const utDate = document.getElementById('utDate').value;
                const utTime = document.getElementById('utTime').value;

                if (!reason) {
                        showAlert('Required', 'Please provide a reason.', 'error');
                        return;
                    }
                    if (!utDate || !utTime) {
                        showAlert('Required', 'Please provide both date and time.', 'error');
                        return;
                    }

                // Date Validation: Current or Future
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const selectedDate = new Date(utDate);
                if (selectedDate < today) {
                    showAlert('Invalid Date', 'Undertime date cannot be in the past. Please select today or a future date.', 'error');
                    return;
                }

                // Time Validation: Must be before 5:00 PM (17:00)
                const depHour = parseInt(utTime.split(':')[0]);
                if (depHour >= 17) {
                    showAlert('Invalid Time', 'Undertime means leaving early. Your departure must be before the shift ends (5:00 PM).', 'error');
                    return;
                }

                // Format time
                let timeFormatted = utTime;
                try {
                    const [h, m] = utTime.split(':');
                    const hrs = parseInt(h);
                    const ampm = hrs >= 12 ? 'PM' : 'AM';
                    const h12 = hrs % 12 || 12;
                    timeFormatted = `${h12}:${m} ${ampm}`;
                } catch (e) {}

                const departureTime = `${utDate} ${timeFormatted}`;

                try {
                    const params = new URLSearchParams({
                        action: 'requestundertime',
                        employeeId: employeeId,
                        reason: reason,
                        type: 'Regular',
                        departureTime: departureTime
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        showAlert('Submitted', 'Undertime request submitted successfully!', 'success');
                        closeUndertimeModal();
                    } else {
                        showAlert('Error', 'Error: ' + result.message, 'error');
                    }
                } catch (err) {
                    showAlert('Error', 'Connection error', 'error');
                }
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
            document.addEventListener('DOMContentLoaded', loadRequestMonitor);

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

            function showAlert(title, message, type = 'success') {
                document.getElementById('alertModalTitle').textContent = title;
                document.getElementById('alertModalMessage').textContent = message;
                const iconContainer = document.getElementById('alertIconContainer');
                const icon = document.getElementById('alertIcon');
                
                if (type === 'success') {
                    iconContainer.style.background = '#10b981';
                    icon.className = 'fas fa-check';
                } else {
                    iconContainer.style.background = '#ef4444';
                    icon.className = 'fas fa-times';
                }
                
                document.getElementById('alertModal').style.display = 'block';
            }

            function requestResignation() {
                document.getElementById('resignationModal').style.display = 'block';
            }

            function updateFileName(input) {
                const display = document.getElementById('file_name_display');
                if (input.files && input.files.length > 0) {
                    display.textContent = input.files[0].name;
                    display.style.color = '#10b981';
                } else {
                    display.textContent = 'Upload Resignation Letter (PDF/DOC)';
                    display.style.color = '#64748b';
                }
            }

            function calculateNoticePeriod() {
                const lastDayInput = document.getElementById('resign_lastDay').value;
                const msg = document.getElementById('notice_calc_msg');
                
                if (!lastDayInput) {
                    msg.textContent = '';
                    return;
                }

                const resignationDate = new Date(); // Today
                const effectiveLastDay = new Date(lastDayInput);
                
                resignationDate.setHours(0,0,0,0);
                effectiveLastDay.setHours(0,0,0,0);

                const diffTime = effectiveLastDay - resignationDate;
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                const standardNotice = 30;
                
                if (diffDays >= standardNotice) {
                    msg.innerHTML = `<span style="color: #10b981;">✓ Notice period met (${diffDays} days provided)</span>`;
                    window.resignationShortfall = 0;
                } else {
                    const shortfall = standardNotice - diffDays;
                    msg.innerHTML = `<span style="color: #ef4444;">⚠ Shortfall: ${shortfall} day(s) (${diffDays} days provided)</span>`;
                    window.resignationShortfall = shortfall;
                }
            }

            function openOvertimeModal() {
                const modal = document.getElementById('overtimeModal');
                if (modal) {
                    modal.style.display = 'block';
                    
                    // Set min date to today to prevent past dates
                    const today = new Date().toISOString().split('T')[0];
                    const dateInput = document.getElementById('txtOvertimeDate');
                    if (dateInput) {
                        dateInput.min = today;
                        dateInput.value = today;
                    }
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

            function submitOvertimeRequest() {
                const reason = document.getElementById('txtOvertimeReason').value.trim();
                const otDate = document.getElementById('txtOvertimeDate').value;
                const startTime = document.getElementById('txtOvertimeStart').value;
                const endTime = document.getElementById('txtOvertimeEnd').value;
                const requestedHours = document.getElementById('txtOvertimeHours').value;

                if (!reason || !otDate || !startTime || !endTime || !requestedHours) {
                    showAlert('Required', 'Please fill in all required fields.', 'error');
                    return;
                }

                // Date Validation: Current or Future
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const selectedDate = new Date(otDate);
                if (selectedDate < today) {
                    showAlert('Invalid Date', 'Overtime date cannot be in the past. Please select today or a future date.', 'error');
                    return;
                }

                // Time Validation: Must be after 5:00 PM (17:00)
                const startHour = parseInt(startTime.split(':')[0]);
                if (startHour < 17 && startHour >= 8) {
                    showAlert('Invalid Time', 'Overtime must be requested for hours after standard shift ends (5:00 PM).', 'error');
                    return;
                }

                fetch(handlerUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `action=requestovertime&employeeId=${employeeId}&reason=${encodeURIComponent(reason)}&otDate=${otDate}&startTime=${startTime}&endTime=${endTime}&requestedHours=${requestedHours}`
                })
                .then(res => res.json())
                .then(data => {
                    closeModal('overtimeModal');
                    if (data.success) {
                        showAlert('Success', 'Overtime request submitted successfully!', 'success');
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showAlert('Failed', data.message || 'Failed to submit request.', 'error');
                    }
                })
                .catch(err => {
                    closeModal('overtimeModal');
                    showAlert('Error', 'Failed to submit request: ' + err.message, 'error');
                });
            }

            function getRequestStatusColor(status) {
                const normalized = (status || '').toLowerCase();
                if (normalized.includes('approved')) return '#10b981';
                if (normalized.includes('rejected')) return '#ef4444';
                if (normalized.includes('pending') || normalized.includes('submitted') || normalized.includes('review')) return '#f59e0b';
                return '#6b7280';
            }

            function renderRequestRows(containerId, items, emptyMessage) {
                const container = document.getElementById(containerId);
                if (!container) return;

                if (!items || items.length === 0) {
                    container.innerHTML = `<div style="padding:12px; border:1px dashed var(--border-color); border-radius:10px; color:var(--text-secondary);">${emptyMessage}</div>`;
                    return;
                }

                container.innerHTML = items.map(item => {
                    const statusColor = getRequestStatusColor(item.status);
                    const dateText = formatRequestDate(item.date);
                    const summary = item.summary || item.type || 'Request';
                    const reason = item.reason ? String(item.reason) : '';
                    return `
                        <div style="padding:12px; border:1px solid var(--border-color); border-radius:10px; background:#fff;">
                            <div style="display:flex; justify-content:space-between; gap:10px; align-items:center;">
                                <strong style="color:var(--text-primary);">${summary}</strong>
                                <span style="font-size:12px; font-weight:700; color:${statusColor};">${item.status || 'Unknown'}</span>
                            </div>
                            <div style="font-size:12px; color:var(--text-secondary); margin-top:4px;">${dateText}</div>
                            ${reason ? `<div style="font-size:12px; color:var(--text-secondary); margin-top:6px;">${reason}</div>` : ''}
                        </div>
                    `;
                }).join('');
            }

            function formatRequestDate(rawDate) {
                if (!rawDate) return '-';

                if (typeof rawDate === 'string') {
                    const msMatch = rawDate.match(/\/Date\((\d+)\)\//);
                    if (msMatch) {
                        const dt = new Date(parseInt(msMatch[1], 10));
                        return isNaN(dt.getTime()) ? 'No date' : dt.toLocaleString();
                    }
                }

                const dt = new Date(rawDate);
                return isNaN(dt.getTime()) ? 'No date' : dt.toLocaleString();
            }

            function loadRequestMonitor() {
                fetch(`${handlerUrl}?action=getrequesthistory&employeeId=${encodeURIComponent(employeeId)}`)
                .then(res => res.json())
                .then(result => {
                    if (!result.success) {
                        renderRequestRows('ongoingRequestsList', [], 'Unable to load ongoing requests.');
                        renderRequestRows('requestHistoryList', [], 'Unable to load request history.');
                        return;
                    }
                    renderRequestRows('ongoingRequestsList', result.ongoingRequests || [], 'No ongoing requests.');
                    renderRequestRows('requestHistoryList', result.requestHistory || [], 'No request history found.');
                })
                .catch(() => {
                    renderRequestRows('ongoingRequestsList', [], 'Unable to load ongoing requests.');
                    renderRequestRows('requestHistoryList', [], 'Unable to load request history.');
                });
            }

            function openOngoingRequestsModal() {
                loadRequestMonitor();
                document.getElementById('ongoingRequestsModal').style.display = 'block';
            }

            function openRequestHistoryModal() {
                loadRequestMonitor();
                document.getElementById('requestHistoryModal').style.display = 'block';
            }

            function renderConcernHistoryRows(items) {
                const container = document.getElementById('concernHistoryList');
                if (!container) return;

                if (!items || items.length === 0) {
                    container.innerHTML = `<div style="padding:12px; border:1px dashed var(--border-color); border-radius:10px; color:var(--text-secondary);">No concern history found.</div>`;
                    return;
                }

                container.innerHTML = items.map(item => {
                    const statusColor = getRequestStatusColor(item.status);
                    const dt = formatRequestDate(item.submittedDate);
                    const title = `${item.concernType || 'Concern'}: ${item.subject || 'No Subject'}`;
                    const desc = item.description ? String(item.description) : '';
                    return `
                        <div style="padding:12px; border:1px solid var(--border-color); border-radius:10px; background:#fff;">
                            <div style="display:flex; justify-content:space-between; gap:10px; align-items:center;">
                                <strong style="color:var(--text-primary);">${title}</strong>
                                <span style="font-size:12px; font-weight:700; color:${statusColor};">${item.status || 'Submitted'}</span>
                            </div>
                            <div style="font-size:12px; color:var(--text-secondary); margin-top:4px;">${dt}</div>
                            ${desc ? `<div style="font-size:12px; color:var(--text-secondary); margin-top:6px;">${desc}</div>` : ''}
                        </div>
                    `;
                }).join('');
            }

            function loadConcernHistory() {
                fetch(`${handlerUrl}?action=getemployeeconcernhistory&employeeId=${encodeURIComponent(employeeId)}`)
                .then(res => res.json())
                .then(result => {
                    if (!result.success) {
                        renderConcernHistoryRows([]);
                        return;
                    }
                    renderConcernHistoryRows(result.concernHistory || []);
                })
                .catch(() => {
                    renderConcernHistoryRows([]);
                });
            }

            function openConcernHistoryModal() {
                loadConcernHistory();
                document.getElementById('concernHistoryModal').style.display = 'block';
            }

            function openGovLoanFormsModal() {
                document.getElementById('govLoanFormsModal').style.display = 'block';
            }

            function openGovForm(url) {
                if (!url) return;
                window.open(url, '_blank', 'noopener,noreferrer');
            }

            function sendResignationRequest() {
                const reason = document.getElementById('resignationReason').value.trim();
                const lastDay = document.getElementById('resign_lastDay').value;
                const reasonCode = document.getElementById('resign_reasonCode').value;
                const fileInput = document.getElementById('resign_letter');
                const shortfall = window.resignationShortfall || 0;

                if (!lastDay) {
                    showAlert('Required', 'Please select your effective last day.', 'error');
                    return;
                }
                if (!reasonCode) {
                    showAlert('Required', 'Please select a reason code.', 'error');
                    return;
                }
                if (!reason) {
                    showAlert('Required', 'Please provide a comment for your resignation.', 'error');
                    return;
                }

                showConfirm(
                    'Confirm Resignation',
                    'Are you sure you want to submit your resignation request? This is a formal action.',
                    '👋',
                    function () {
                        const btn = document.getElementById('btnConfirmResign');
                        const originalText = btn.textContent;
                        btn.disabled = true;
                        btn.textContent = 'Submitting...';

                        const formData = new FormData();
                        formData.append('action', 'requestResignation');
                        formData.append('employeeId', employeeId);
                        formData.append('reason', reason);
                        formData.append('lastDay', lastDay);
                        formData.append('reasonCode', reasonCode);
                        formData.append('noticeDays', 30);
                        formData.append('shortfallDays', shortfall);
                        
                        if (fileInput.files.length > 0) {
                            formData.append('file', fileInput.files[0]);
                        }

                        fetch(handlerUrl, {
                            method: 'POST',
                            body: formData
                        })
                        .then(res => res.json())
                        .then(result => {
                            if (result.success) {
                                closeModal('resignationModal');
                                showAlert('Submitted', 'Resignation request submitted successfully!');
                                setTimeout(() => { window.location.reload(); }, 2000);
                            } else {
                                showAlert('Error', result.message || 'Failed to submit request.', 'error');
                                btn.disabled = false;
                                btn.textContent = originalText;
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            showAlert('Error', 'An unexpected error occurred. Please try again.', 'error');
                            btn.disabled = false;
                            btn.textContent = originalText;
                        });
                    }
                );
            }

            function downloadCOEForm() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is loading. Please wait...');
                        return;
                    }

                    const name = "<%= GetEmployeeName() %>";
                    const dept = "<%= GetEmployeeDepartment() %>";
                    const position = "<%= GetEmployeeRole() %>";
                    const hireDate = "<%= GetHiredDate() %>";
                    const today = new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

                    const element = document.createElement('div');
                    element.innerHTML = `
                        <div style="padding: 60px; font-family: 'Times New Roman', Times, serif; color: #000; width: 750px; margin: auto; line-height: 1.8;">
                            <div style="text-align: center; margin-bottom: 40px;">
                                <img src="/images/shessentials-logo.png" style="width: 120px; height: auto; margin-bottom: 10px;" alt="Logo" onerror="this.style.display='none'">
                                <h2 style="margin: 0; font-size: 20px; letter-spacing: 1px;">SHESSENTIALS SKINCARE AND BEAUTY MANUFACTURING CO.</h2>
                                <p style="margin: 5px 0; font-size: 12px;">Official Employment Certification</p>
                            </div>

                            <div style="text-align: right; margin-bottom: 30px;">
                                <p>Date: <span style="display: inline-block; width: 180px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                            </div>

                            <div style="text-align: center; margin-bottom: 40px;">
                                <h1 style="font-size: 24px; font-weight: bold;">CERTIFICATE OF EMPLOYMENT</h1>
                            </div>

                            <p style="margin-bottom: 25px;">TO WHOM IT MAY CONCERN:</p>

                            <p style="margin-bottom: 25px; text-align: justify;">
                                This is to certify that <span style="display: inline-block; width: 300px; border-bottom: 1px solid #000;">&nbsp;</span> has been a bonafide employee of <strong>Shessentials Skincare and Beauty Manufacturing Co.</strong> under the following details:
                            </p>

                            <table style="width: 95%; margin: 0 auto 30px auto; font-size: 16px; border-collapse: collapse;">
                                <tr>
                                    <td style="padding: 12px; width: 35%;">Position:</td>
                                    <td style="padding: 12px; border-bottom: 1px solid #000;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px;">Department:</td>
                                    <td style="padding: 12px; border-bottom: 1px solid #000;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px;">Employment Type:</td>
                                    <td style="padding: 12px; border-bottom: 1px solid #000;">
                                        ☐ Regular &nbsp;&nbsp; ☐ Probationary &nbsp;&nbsp; ☐ Contractual
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px;">Date of Hire:</td>
                                    <td style="padding: 12px; border-bottom: 1px solid #000;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="padding: 12px;">Employment Status:</td>
                                    <td style="padding: 12px; border-bottom: 1px solid #000;">
                                        ☐ Currently Employed &nbsp;&nbsp; ☐ Separated as of <span style="display: inline-block; width: 120px; border-bottom: 1px solid #000;">&nbsp;</span>
                                    </td>
                                </tr>
                            </table>

                            <p style="margin-bottom: 40px; text-align: justify;">
                                This certification is issued upon the request of the above-named employee for whatever legal purpose it may serve.
                            </p>

                            <div style="margin-top: 50px; page-break-inside: avoid;">
                                <p style="margin-bottom: 10px;">Issued by:</p>
                                <table style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <td style="width: 45%; vertical-align: bottom; padding-right: 10%;">
                                            <div style="height: 60px;"></div>
                                            <div style="border-top: 1px solid #000; text-align: center;">
                                                <p style="margin: 0; font-weight: bold; font-size: 16px;">Name</p>
                                                <p style="margin: 0; font-size: 13px;">Position: HR Staff / HR Manager</p>
                                            </div>
                                        </td>
                                        <td style="width: 45%; vertical-align: bottom;">
                                            <div style="height: 60px;"></div>
                                            <div style="border-top: 1px solid #000; text-align: center;">
                                                <p style="margin: 0; font-size: 13px;">Signature over Printed Name</p>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    `;

                    const opt = {
                        margin: 0,
                        filename: 'COE_Template.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 2, scrollY: 0, useCORS: true },
                        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
                    };

                    html2pdf().from(element).set(opt).save();
                } catch (err) {
                    alert('Error: ' + err.message);
                }
            }

            function downloadLoanForm() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is loading. Please wait...');
                        return;
                    }

                    const name = "<%= GetEmployeeName() %>";
                    const dept = "<%= GetEmployeeDepartment() %>";
                    const id = "<%= GetEmployeeId() %>";

                    const element = document.createElement('div');
                    element.innerHTML = `
                        <div style="padding: 45px; font-family: 'Arial', sans-serif; color: #333; width: 750px; margin: auto; border: 1px solid #eee;">
                            <div style="text-align: center; border-bottom: 2px solid #A44F56; padding-bottom: 15px; margin-bottom: 30px;">
                                <h1 style="color: #A44F56; margin: 0; font-size: 24px;">SHEESSENTIALS ESSENTIALS</h1>
                                <p style="font-size: 14px; color: #666; margin: 5px 0;">LOAN APPLICATION FORM</p>
                            </div>

                            <table style="width: 100%; margin-bottom: 25px; font-size: 14px;">
                                <tr>
                                    <td style="width: 50%; padding: 8px;"><strong>Employee Name:</strong> ${name}</td>
                                    <td style="padding: 8px;"><strong>Employee ID:</strong> ${id}</td>
                                </tr>
                                <tr>
                                    <td style="padding: 8px;"><strong>Department:</strong> ${dept}</td>
                                    <td style="padding: 8px;"><strong>Date:</strong> ${new Date().toLocaleDateString()}</td>
                                </tr>
                            </table>

                            <h3 style="background: #f9f9f9; padding: 10px; border-left: 4px solid #A44F56; font-size: 15px; margin: 0 0 10px 0;">LOAN DETAILS</h3>
                            <table style="width: 100%; margin-bottom: 25px; border-collapse: collapse; font-size: 14px;">
                                <tr>
                                    <td style="border: 1px solid #ddd; padding: 12px; width: 40%;"><strong>Loan Type:</strong></td>
                                    <td style="border: 1px solid #ddd; padding: 12px;">[ ] Government Loan  [ ] Personal Loan  [ ] Emergency</td>
                                </tr>
                                <tr>
                                    <td style="border: 1px solid #ddd; padding: 12px;"><strong>Requested Amount:</strong></td>
                                    <td style="border: 1px solid #ddd; padding: 12px;">₱ __________________________</td>
                                </tr>
                                <tr>
                                    <td style="border: 1px solid #ddd; padding: 12px;"><strong>Purpose of Loan:</strong></td>
                                    <td style="border: 1px solid #ddd; padding: 12px; height: 120px; vertical-align: top;"></td>
                                </tr>
                            </table>

                            <h3 style="background: #f9f9f9; padding: 10px; border-left: 4px solid #A44F56; font-size: 15px; margin: 0 0 10px 0;">DECLARATION</h3>
                            <p style="font-size: 12px; line-height: 1.5; color: #666; margin-bottom: 30px;">
                                I hereby authorize the company to deduct the agreed installment amount from my monthly salary. I understand that any outstanding balance must be settled upon resignation or termination. I certify that the information provided is true and correct.
                            </p>

                            <table style="width: 100%; margin-top: 40px; font-size: 14px;">
                                <tr>
                                    <td style="width: 45%; text-align: center; border-top: 1px solid #333; padding-top: 10px;">
                                        Employee Signature
                                    </td>
                                    <td style="width: 10%;"></td>
                                    <td style="width: 45%; text-align: center; border-top: 1px solid #333; padding-top: 10px;">
                                        Date Signed
                                    </td>
                                </tr>
                            </table>

                            <div style="margin-top: 60px; border-top: 2px dashed #eee; padding-top: 20px;">
                                <p style="font-size: 11px; color: #999; text-align: center; margin-bottom: 15px;">FOR HR USE ONLY</p>
                                <table style="width: 100%; font-size: 12px;">
                                    <tr>
                                        <td style="border: 1px solid #eee; padding: 15px; width: 33%;">Approved By: ____________</td>
                                        <td style="border: 1px solid #eee; padding: 15px; width: 33%;">Date: ____________</td>
                                        <td style="border: 1px solid #eee; padding: 15px; width: 33%;">Status: [ ] Approved [ ] Declined</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    `;

                    const opt = {
                        margin: 10,
                        filename: 'Loan_Application_Form_' + name.replace(/[^a-z0-9]/gi, '_') + '.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 2, scrollY: 0, useCORS: true },
                        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
                    };

                    html2pdf().from(element).set(opt).save();
                } catch (err) {
                    alert('Error: ' + err.message);
                }
            }

            function downloadClearanceForm() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is loading. Please wait...');
                        return;
                    }

                    const element = document.createElement('div');
                    element.innerHTML = `
                        <div style="padding: 30px; font-family: 'Times New Roman', Times, serif; color: #000; width: 750px; margin: auto; line-height: 1.4;">
                            <div style="text-align: center; margin-bottom: 15px; page-break-inside: avoid;">
                                <img src="/images/shessentials-logo.png" style="width: 100px; height: auto; margin-bottom: 5px;" alt="Logo" onerror="this.style.display='none'">
                                <h2 style="margin: 0; font-size: 16px; letter-spacing: 1px; font-weight: bold;">SHESSENTIALS SKINCARE AND BEAUTY MANUFACTURING CO.</h2>
                                <h1 style="margin: 5px 0 0 0; font-size: 18px; font-weight: bold;">EMPLOYEE CLEARANCE FORM</h1>
                            </div>

                            <div style="margin-bottom: 15px; page-break-inside: avoid;">
                                <h3 style="font-size: 14px; font-weight: bold; background-color: #f0f0f0; padding: 5px; border: 1px solid #000; margin-bottom: 10px;">EMPLOYEE INFORMATION</h3>
                                <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                                    <tr>
                                        <td style="width: 25%; padding: 4px;">Name:</td>
                                        <td style="width: 75%; border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Employee ID:</td>
                                        <td style="border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Department:</td>
                                        <td style="border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Position:</td>
                                        <td style="border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Date of Hire:</td>
                                        <td style="border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Last Day of Work:</td>
                                        <td style="border-bottom: 1px solid #000;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 4px;">Reason for Separation:</td>
                                        <td style="padding: 4px;">☐ Resignation &nbsp;&nbsp; ☐ End of Contract &nbsp;&nbsp; ☐ Termination</td>
                                    </tr>
                                </table>
                            </div>

                            <div style="margin-bottom: 15px; page-break-inside: avoid;">
                                <h3 style="font-size: 14px; font-weight: bold; background-color: #f0f0f0; padding: 5px; border: 1px solid #000; margin-bottom: 10px;">CLEARANCE CHECKLIST</h3>
                                
                                <p style="font-weight: bold; font-size: 13px; margin: 5px 0;">A. HR Department</p>
                                <table style="width: 100%; font-size: 12px; border-collapse: collapse; border: 1px solid #000; text-align: left; margin-bottom: 10px;">
                                    <tr>
                                        <th style="border: 1px solid #000; padding: 5px; width: 40%;">Item</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 25%;">Status</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 20%;">Remarks</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 15%;">Signature</th>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Employment records completed and filed</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Government contributions updated (SSS, Pag-IBIG, PhilHealth)</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Certificate of Employment issued</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Loan balances settled or endorsed to payroll for final pay deduction</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                </table>
                                <p style="font-size: 13px; margin: 0 0 15px 0;">HR Staff Name & Signature: <span style="display: inline-block; width: 250px; border-bottom: 1px solid #000;">&nbsp;</span> Date: <span style="display: inline-block; width: 100px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                            </div>

                            <div style="margin-bottom: 15px; page-break-inside: avoid;">
                                <p style="font-weight: bold; font-size: 13px; margin: 5px 0;">B. Finance / Payroll</p>
                                <table style="width: 100%; font-size: 12px; border-collapse: collapse; border: 1px solid #000; text-align: left; margin-bottom: 10px;">
                                    <tr>
                                        <th style="border: 1px solid #000; padding: 5px; width: 40%;">Item</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 25%;">Status</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 20%;">Remarks</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 15%;">Signature</th>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">No outstanding cash advances</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Final pay computation completed</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Loan deductions reflected in final pay</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                </table>
                                <p style="font-size: 13px; margin: 0 0 15px 0;">Finance / Payroll In-charge Name & Signature: <span style="display: inline-block; width: 200px; border-bottom: 1px solid #000;">&nbsp;</span> Date: <span style="display: inline-block; width: 100px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                            </div>

                            <div style="margin-bottom: 15px; page-break-inside: avoid;">
                                <p style="font-weight: bold; font-size: 13px; margin: 5px 0;">C. Immediate Supervisor / Department Head</p>
                                <table style="width: 100%; font-size: 12px; border-collapse: collapse; border: 1px solid #000; text-align: left; margin-bottom: 10px;">
                                    <tr>
                                        <th style="border: 1px solid #000; padding: 5px; width: 40%;">Item</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 25%;">Status</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 20%;">Remarks</th>
                                        <th style="border: 1px solid #000; padding: 5px; width: 15%;">Signature</th>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Company ID returned</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Uniform / equipment returned</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">Pending tasks properly turned over</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 5px;">No pending accountabilities</td>
                                        <td style="border: 1px solid #000; padding: 5px;">☐ Cleared &nbsp; ☐ Not Cleared</td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                        <td style="border: 1px solid #000; padding: 5px;"></td>
                                    </tr>
                                </table>
                                <p style="font-size: 13px; margin: 0 0 15px 0;">Supervisor Name & Signature: <span style="display: inline-block; width: 250px; border-bottom: 1px solid #000;">&nbsp;</span> Date: <span style="display: inline-block; width: 100px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                            </div>

                            <div style="margin-top: 15px; border-top: 2px solid #000; padding-top: 10px; page-break-inside: avoid;">
                                <h3 style="font-size: 14px; font-weight: bold; margin-bottom: 10px;">FINAL APPROVAL</h3>
                                <p style="font-size: 13px; margin-bottom: 20px;">This certifies that the above-named employee has been cleared of all accountabilities and is eligible for final pay processing.</p>
                                
                                <div style="display: flex; justify-content: space-between; font-size: 13px;">
                                    <div style="width: 48%;">
                                        <p style="margin: 0 0 5px 0;">HR Manager / Super Admin Signature:</p>
                                        <div style="border-bottom: 1px solid #000; height: 30px; margin-bottom: 5px;"></div>
                                        <p style="margin: 0;">Date: <span style="display: inline-block; width: 150px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                                    </div>
                                    <div style="width: 48%;">
                                        <p style="margin: 0 0 5px 0;">Employee Received By:</p>
                                        <div style="border-bottom: 1px solid #000; height: 30px; margin-bottom: 5px;"></div>
                                        <p style="margin: 0;">Date: <span style="display: inline-block; width: 150px; border-bottom: 1px solid #000;">&nbsp;</span></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;

                    const opt = {
                        margin: 0,
                        filename: 'Employee_Clearance_Form.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 2, scrollY: 0, useCORS: true },
                        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
                        pagebreak: { mode: ['css', 'legacy'] }
                    };

                    html2pdf().from(element).set(opt).save();
                } catch (err) {
                    alert('Error: ' + err.message);
                }
            }
        </script>
    </asp:Content>

