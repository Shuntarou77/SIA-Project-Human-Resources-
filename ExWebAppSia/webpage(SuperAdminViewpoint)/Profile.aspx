<%@ Page Title="HR Profile" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Profile.aspx.cs"
    Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.HRProfile" %>
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
                border: 1px solid var(--border-color);
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
                word-break: break-all;
                max-width: 180px;
            }

            /* Attendance Card */
            .attendance-card {
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                padding: 24px;
                font-family: 'Poppins', sans-serif;
                border: 1px solid var(--border-color);
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
                display: flex;
                flex-direction: column;
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

            /* Page-specific Modal Styles */
            .page-modal {
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

            .modal-footer {
                padding: 16px 24px;
                display: flex;
                gap: 12px;
                justify-content: flex-end;
                border-top: 1px solid var(--border-color);
                font-family: 'Poppins', sans-serif;
                background: #F9FAFB;
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

            /* Attendance Tracking Specific Styles (HR Side) */
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

            .action-btn {
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
                letter-spacing: 1px;
            }

            .btn-time-in {
                background: linear-gradient(135deg, #10b981, #34d399);
                color: white;
            }

            .btn-time-out {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
            }

            .btn-overtime {
                background: linear-gradient(135deg, #8b5cf6, #c4b5fd);
                color: white;
            }

            .action-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
                transform: none !important;
                box-shadow: none !important;
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

            /* Form Styles */
            .form-group {
                margin-bottom: 20px;
                text-align: left;
                font-family: 'Poppins', sans-serif;
            }

            .form-label {
                display: block;
                font-size: 14px;
                font-weight: 600;
                color: var(--text-secondary);
                margin-bottom: 8px;
                font-family: 'Poppins', sans-serif;
            }

            .form-input,
            .form-select,
            .form-textarea {
                width: 100%;
                padding: 12px 16px;
                border: 1px solid var(--border-color);
                border-radius: 10px;
                font-size: 14px;
                color: var(--text-primary);
                font-family: 'Poppins', sans-serif;
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
                min-height: 120px;
                resize: vertical;
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

                .attendance-actions {
                    flex-direction: column;
                }
            }
        </style>
        <!-- html2pdf Library -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
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
                            <span class="info-value">
                                <%: GetEmployeeEmail() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">📞 Contact</span>
                            <span class="info-value">
                                <%: GetEmployeeContact() %>
                            </span>
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
                            <span class="info-label">🎂 Birthday</span>
                            <span class="info-value">
                                <%: GetEmployeeBirthdate() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">👤 Age</span>
                            <span class="info-value">
                                <%: GetEmployeeAge() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">⚧ Sex</span>
                            <span class="info-value">
                                <%: GetEmployeeSex() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🗓️ Hired Date</span>
                            <span class="info-value">
                                <%= GetHiredDate() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">📅 Regularization</span>
                            <span class="info-value">
                                <%= GetRegularizationDate() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">📋 Status</span>
                            <span class="info-value" style="color: var(--success-color);">
                                <%: GetEmployeeStatus() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">💰 Salary</span>
                            <span class="info-value" style="font-weight: 700; color: var(--primary-color);">
                                <%= GetEmployeeSalary() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏢 SSS No.</span>
                            <span class="info-value">
                                <%= GetSSSNumber() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏥 PhilHealth No.</span>
                            <span class="info-value">
                                <%= GetPhilHealthNumber() %>
                            </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">🏠 Pag-IBIG No.</span>
                            <span class="info-value">
                                <%= GetPagIbigNumber() %>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Right: Attendance Column -->
                <div class="attendance-column">
                    <div class="attendance-card">
                        <div class="card-title">
                            <svg style="width:24px;height:24px;fill:currentColor" viewBox="0 0 24 24">
                                <path
                                    d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z" />
                            </svg>
                            Attendance Tracker
                        </div>
                        <div class="attendance-body" style="background: transparent; padding: 0;">
                            <div class="attendance-status-info">
                                <span id="attendanceStatusLabel" class="status-text">Not timed in yet</span>
                                <div id="currentDate"
                                    style="font-size: 13px; color: var(--text-muted); margin-top: 5px;">--</div>
                                <div id="currentTime" class="attendance-time-display">00:00:00</div>
                            </div>

                            <div class="stats-row" style="flex-wrap: wrap; gap: 10px;">
                                <div class="stat-box">
                                    <div class="stat-value">
                                        <%= GetDaysPresent() %>
                                    </div>
                                    <div class="stat-label">Present</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value">
                                        <%= GetDaysAbsent() %>
                                    </div>
                                    <div class="stat-label">Absent</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value">
                                        <%= GetDaysLate() %>
                                    </div>
                                    <div class="stat-label">Late</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value" style="color: var(--warning-color);">
                                        <%= GetRemainingAbsences() %>
                                    </div>
                                    <div class="stat-label">Absence Allowance</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value" style="color: var(--success-color);">
                                        <%= GetTargetWorkingDays() %>
                                    </div>
                                    <div class="stat-label">Working Days (Monthly)</div>
                                </div>
                            </div>

                            <div class="attendance-actions">
                                <button id="timeInBtn" type="button" class="action-btn btn-time-in" onclick="timeIn()">
                                    <svg style="width:20px;height:20px;fill:currentColor" viewBox="0 0 24 24">
                                        <path
                                            d="M13 3h-2v10h2V3zm4.83 2.17l-1.42 1.42C17.99 7.86 19 9.81 19 12c0 3.87-3.13 7-7 7s-7-3.13-7-7c0-2.19 1.01-4.14 2.58-5.42L6.17 5.17C4.23 6.82 3 9.26 3 12c0 4.97 4.03 9 9 9s9-4.03 9-9c0-2.74-1.23-5.18-3.17-6.83z" />
                                    </svg>
                                    Time In
                                </button>
                                <button id="timeOutBtn" type="button" class="action-btn btn-time-out"
                                    onclick="timeOut()" disabled>
                                    <svg style="width:20px;height:20px;fill:currentColor" viewBox="0 0 24 24">
                                        <path
                                            d="M10.09 15.59L11.5 17l5-5-5-5-1.41 1.41L12.67 11H3v2h9.67l-2.58 2.59zM19 3H5c-1.11 0-2 .9-2 2v4h2V5h14v14H5v-4H3v4c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z" />
                                    </svg>
                                    Time Out
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Action Cards -->
                    <div class="actions-grid">
                        <div class="action-card" onclick="openPayslipModal()">
                            <div class="action-icon">💰</div>
                            <h3 class="action-title">View Payslip</h3>
                            <p class="action-description">View your salary breakdown including gross salary, deductions,
                                and net pay.</p>
                            <button type="button" class="action-button" onclick="openPayslipModal()">View
                                Details</button>
                        </div>

                        <div class="action-card" onclick="openLeaveModal()">
                            <div class="action-icon">📝</div>
                            <h3 class="action-title">File Leave of Absence</h3>
                            <p class="action-description">Submit your leave request for sick leave, vacation, or
                                personal matters.</p>
                            <button type="button" class="action-button" onclick="openLeaveModal()">File Leave</button>
                        </div>

                        <div class="action-card" onclick="openConcernModal()">
                            <div class="action-icon">💬</div>
                            <h3 class="action-title">Report Employee Concern</h3>
                            <p class="action-description">Submit any workplace concerns, complaints, or suggestions to
                                HR.</p>
                            <button type="button" class="action-button" onclick="openConcernModal()">Submit
                                Concern</button>
                        </div>

                        <div class="action-card" onclick="openConcernHistoryModal()">
                            <div class="action-icon">🧾</div>
                            <h3 class="action-title">Concern History</h3>
                            <p class="action-description">Review your submitted employee concerns and track their status
                                updates.</p>
                            <button type="button" class="action-button"
                                onclick="openConcernHistoryModal(); return false;">View History</button>
                        </div>


                        <div class="action-card" onclick="openResignationRequestModal()">
                            <div class="action-icon">👋</div>
                            <h3 class="action-title">Resignation Request</h3>
                            <p class="action-description">Submit a formal resignation request to start the offboarding
                                process.</p>
                            <button id="btnResignationCard" type="button" class="action-button"
                                onclick="openResignationRequestModal()" style="background: #ef4444;">Submit
                                Request</button>
                        </div>

                        <div class="action-card" onclick="openOvertimeModal()">
                            <div class="action-icon" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">⏱️
                            </div>
                            <h3 class="action-title">Overtime Request</h3>
                            <p class="action-description">Submit your overtime request for review and approval by
                                HR/Admin.</p>
                            <button type="button" class="action-button" onclick="openOvertimeModal(); return false;"
                                style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">Request Overtime</button>
                        </div>

                        <div class="action-card" onclick="openGovLoanFormsModal()">
                            <div class="action-icon">📥</div>
                            <h3 class="action-title">Downloadable Forms</h3>
                            <p class="action-description">Download official government loan forms (SSS, Pag-IBIG) for
                                filing.</p>
                            <button type="button" class="action-button" onclick="openGovLoanFormsModal(); return false;"
                                style="background: #4f46e5;">Choose Form</button>
                        </div>

                        <div class="action-card" onclick="openOngoingRequestsModal()">
                            <div class="action-icon">⏳</div>
                            <h3 class="action-title">On Going Requests</h3>
                            <p class="action-description">Monitor your currently pending and under-review requests.</p>
                            <button type="button" class="action-button"
                                onclick="openOngoingRequestsModal(); return false;"
                                style="margin-top:auto; background: linear-gradient(135deg, #8b5cf6, #7c3aed);">View
                                Ongoing</button>
                        </div>
                        <div class="action-card" onclick="openRequestHistoryModal()">
                            <div class="action-icon">🗂️</div>
                            <h3 class="action-title">Request History</h3>
                            <p class="action-description">Review your recent request submissions and their final
                                statuses.</p>
                            <button type="button" class="action-button"
                                onclick="openRequestHistoryModal(); return false;" style="margin-top:auto;">View
                                History</button>
                        </div>
                        <div class="action-card" id="cardClearance" style="display: none; border-color: #10b981; background: #f0fdf4;" onclick="downloadClearanceForm();">
                            <div class="action-icon" style="background: linear-gradient(135deg, #10b981, #34d399);">📋</div>
                            <h3 class="action-title" style="color: #065f46;">Download Clearance Form</h3>
                            <p class="action-description">Your resignation has been approved. Please download, complete, and sign your clearance form.</p>
                            <button type="button" class="action-button" style="background: #10b981;" onclick="downloadClearanceForm(); return false;">Download PDF</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="ongoingRequestsModal" class="page-modal">
            <div class="modal-content" style="max-width:700px;">
                <div class="modal-header" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <span class="close" onclick="closeModal('ongoingRequestsModal')">&times;</span>
                    <h2 class="modal-title">⏳ On Going Requests</h2>
                </div>
                <div class="modal-body">
                    <div id="ongoingRequestsList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('ongoingRequestsModal')">Close</button>
                    <button type="button" class="btn-submit"
                        style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);"
                        onclick="loadRequestMonitor()">Refresh List</button>
                </div>
            </div>
        </div>

        <div id="requestHistoryModal" class="page-modal">
            <div class="modal-content" style="max-width:700px;">
                <div class="modal-header">
                    <span class="close" onclick="closeModal('requestHistoryModal')">&times;</span>
                    <h2 class="modal-title">🗂️ Request History</h2>
                </div>
                <div class="modal-body">
                    <div id="requestHistoryList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('requestHistoryModal')">Close</button>
                    <button type="button" class="btn-submit" onclick="loadRequestMonitor()">Refresh History</button>
                </div>
            </div>
        </div>

        <!-- Payslip Modal -->
        <div id="payslipModal" class="page-modal">
            <div class="modal-content">
                <div class="modal-header">
                    <span class="close" onclick="closeModal('payslipModal')">&times;</span>
                    <h2 class="modal-title">💰 Payslip Details</h2>
                </div>
                <div class="modal-body">
                    <div id="ps_period_container"
                        style="background: rgba(163, 106, 102, 0.05); border-radius: 12px; padding: 15px; margin-bottom: 25px; text-align: center; border: 1px dashed var(--primary-color);">
                        <span style="font-size: 13px; color: var(--text-muted); display: block; margin-bottom: 5px;">Pay
                            Period</span>
                        <span style="font-weight: 700; color: var(--primary-color); font-size: 15px;">
                            <%= GetPayPeriod() %>
                        </span>
                    </div>

                    <h3 style="margin-bottom: 16px; color: var(--text-primary);">Gross Salary</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">Basic Salary</span>
                        <span class="payslip-value">&#8369;<%= GetBasicSalary() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Allowances</span>
                        <span class="payslip-value">&#8369;<%= GetAllowances() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Overtime Pay</span>
                        <span class="payslip-value">&#8369;<%= GetOvertimePay() %></span>
                    </div>
                    <div class="payslip-item"
                        style="background: var(--accent-color); border: 1px solid var(--primary-color);">
                        <span class="payslip-label" style="color: var(--primary-color);">Total Gross</span>
                        <span class="payslip-value" style="color: var(--primary-color);">&#8369;<%= GetGrossSalary() %>
                        </span>
                    </div>

                    <h3 style="margin: 24px 0 16px; color: var(--text-primary);">Deductions</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">SSS</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetSSSDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">PhilHealth</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetPhilHealthDeduction() %>
                        </span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Pag-IBIG</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetPagIbigDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Withholding Tax</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetWithholdingTax() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Absences & Lates</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetAbsenceDeduction() %></span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Penalties</span>
                        <span class="payslip-value" style="color: #ef4444;">- &#8369;<%= GetPenalties() %></span>
                    </div>
                    <div class="payslip-item" style="background: #FFF5F5; border: 1px solid #FEB2B2;">
                        <span class="payslip-label" style="color: #C53030;">Total Deductions</span>
                        <span class="payslip-value" style="color: #C53030;">- &#8369;<%= GetTotalDeductions() %></span>
                    </div>

                    <div class="payslip-total">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="payslip-label" style="color: white; font-size: 18px;">Net Salary</span>
                            <span class="payslip-value" style="color: white; font-size: 24px;">&#8369;<%= GetNetSalary()
                                    %></span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('payslipModal')">Close</button>
                    <button type="button" class="btn-submit" onclick="downloadPDF()">Print</button>
                </div>
            </div>
        </div>

        <!-- Leave Modal -->
        <div id="leaveModal" class="page-modal">
            <div class="modal-content">
                <div class="modal-header">
                    <span class="close" onclick="closeModal('leaveModal')">&times;</span>
                    <h2 class="modal-title">📝 File Leave of Absence</h2>
                </div>
                    <div class="leave-balance-info" style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 15px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="font-size: 20px;">📊</span>
                            <div>
                                <div style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 600;">Available Leave Credits</div>
                                <div style="font-size: 16px; font-weight: 700; color: #1e293b;"><%= GetRemainingAbsences() %> Days Remaining</div>
                            </div>
                        </div>
                        <div style="font-size: 11px; color: #94a3b8; font-style: italic;">Reset every January 1st</div>
                    </div>
                    <asp:Label ID="lblLeaveMessage" runat="server" style="display: none;"></asp:Label>
                    <div class="form-group">
                        <label class="form-label">Leave Type *</label>
                        <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="form-select" onchange="updateLeaveHint()">
                            <asp:ListItem Value="" Text="Select leave type"></asp:ListItem>
                            <asp:ListItem Value="sick" Text="Sick Leave"></asp:ListItem>
                            <asp:ListItem Value="vacation" Text="Vacation Leave"></asp:ListItem>
                            <asp:ListItem Value="personal" Text="Personal Leave"></asp:ListItem>
                            <asp:ListItem Value="emergency" Text="Emergency Leave"></asp:ListItem>
                            <asp:ListItem Value="maternity" Text="Maternity Leave"></asp:ListItem>
                            <asp:ListItem Value="paternity" Text="Paternity Leave"></asp:ListItem>
                        </asp:DropDownList>
                        <div id="leaveHint" style="font-size: 11px; margin-top: 6px; padding: 8px; border-radius: 4px; display: none;"></div>
                    </div>
                    <script type="text/javascript">
                        function updateLeaveHint() {
                            var ddl = document.getElementById('<%= ddlLeaveType.ClientID %>');
                            var hint = document.getElementById('leaveHint');
                            var attachmentLabel = document.getElementById('attachmentLabel');
                            var type = ddl.value;
                            
                            hint.style.display = 'block';
                            hint.style.background = '#f0f9ff';
                            hint.style.color = '#0369a1';
                            hint.style.border = '1px solid #bae6fd';
                            
                            if (type === 'sick') {
                                hint.innerHTML = '<strong>Note:</strong> Medical proof is required. If credits are exhausted, the excess days will be unpaid.';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Medical Certificate (Required) *';
                            } else if (type === 'vacation' || type === 'personal') {
                                hint.innerHTML = '<strong>Note:</strong> Requests cannot exceed your remaining leave credits.';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Attachment (Optional)';
                            } else if (type === 'emergency') {
                                hint.innerHTML = '<strong>Note:</strong> Allowed up to 5 days even if credits are zero.';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Attachment (Optional)';
                            } else if (type === 'maternity') {
                                hint.innerHTML = '<strong>Note:</strong> Allowed up to 105 days as per government policy.';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Attachment (Optional)';
                            } else if (type === 'paternity') {
                                hint.innerHTML = '<strong>Note:</strong> Allowed up to 7 days as per government policy.';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Attachment (Optional)';
                            } else {
                                hint.style.display = 'none';
                                if (attachmentLabel) attachmentLabel.innerHTML = 'Attachment (Optional)';
                            }
                        }
                    </script>
                    <div class="form-group">
                        <label class="form-label">Start Date *</label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-input" TextMode="Date">
                        </asp:TextBox>
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
                        <label id="attachmentLabel" class="form-label">Attachment (Optional)</label>
                        <asp:FileUpload ID="fileLeaveAttachment" runat="server" CssClass="form-input"
                            accept=".pdf,.jpg,.png,.doc,.docx" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('leaveModal')">Cancel</button>
                    <asp:Button ID="btnSubmitLeave" runat="server" CssClass="btn-submit" Text="Confirm Leave Request"
                        OnClick="btnSubmitLeave_Click" />
                </div>
            </div>
        </div>

        <!-- Overtime Modal -->
        <div id="overtimeModal" class="page-modal">
            <div class="modal-content" style="max-width: 450px;">
                <div class="modal-header" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
                    <span class="close" onclick="closeModal('overtimeModal')">&times;</span>
                    <h2 class="modal-title">⏱️ Request Overtime</h2>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Date of
                            Overtime *</label>
                        <input type="date" id="txtOvertimeDate"
                            style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;" />
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div class="form-group">
                            <label class="form-label"
                                style="display: block; margin-bottom: 5px; font-weight: 600;">Start Time *</label>
                            <input type="time" id="txtOvertimeStart"
                                style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;"
                                onchange="calculateOTHours()" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">End
                                Time *</label>
                            <input type="time" id="txtOvertimeEnd"
                                style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;"
                                onchange="calculateOTHours()" />
                        </div>
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Total
                            Hours Requested *</label>
                        <input type="number" id="txtOvertimeHours" step="0.1" min="0"
                            style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;"
                            placeholder="Calculated hours..." />
                    </div>
                    <div class="form-group" style="margin-bottom: 15px;">
                        <label class="form-label" style="display: block; margin-bottom: 5px; font-weight: 600;">Detailed
                            Justification *</label>
                        <textarea id="txtOvertimeReason" class="form-textarea"
                            style="width: 100%; min-height: 80px; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; resize: none;"
                            placeholder="Provide a detailed justification for the work..."></textarea>
                    </div>
                    <div
                        style="background: #F5F3FF; border-left: 4px solid #8b5cf6; padding: 15px; border-radius: 0 8px 8px 0;">
                        <p style="color: #5b21b6; font-size: 13px; font-weight: 600;">
                            Note: Your request will be sent to Admin for approval.
                        </p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('overtimeModal')">Cancel</button>
                    <button type="button" class="btn-submit" style="background: #8b5cf6;"
                        onclick="submitOvertimeRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Concern Modal -->
        <div id="concernModal" class="page-modal">
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
                        <asp:TextBox ID="txtConcernSubject" runat="server" CssClass="form-input"
                            placeholder="Brief subject of your concern"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Description *</label>
                        <asp:TextBox ID="txtConcernDescription" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine"
                            placeholder="Please provide detailed information about your concern..."></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('concernModal')">Cancel</button>
                    <asp:Button ID="btnSubmitConcern" runat="server" CssClass="btn-submit" Text="Submit Concern"
                        OnClick="btnSubmitConcern_Click" />
                </div>
            </div>
        </div>

        <div id="concernHistoryModal" class="page-modal">
            <div class="modal-content" style="max-width:700px;">
                <div class="modal-header">
                    <span class="close" onclick="closeModal('concernHistoryModal')">&times;</span>
                    <h2 class="modal-title">🧾 Employee Concern History</h2>
                </div>
                <div class="modal-body">
                    <div id="concernHistoryList" style="display:flex; flex-direction:column; gap:10px;"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('concernHistoryModal')">Close</button>
                    <button type="button" class="btn-submit" onclick="loadConcernHistory()">Refresh</button>
                </div>
            </div>
        </div>

        <div id="govLoanFormsModal" class="page-modal">
            <div class="modal-content" style="max-width: 800px;">
                <div class="modal-header">
                    <span class="close" onclick="closeModal('govLoanFormsModal')">&times;</span>
                    <h2 class="modal-title">📥 Government Loan Forms</h2>
                </div>
                <div class="modal-body">
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 14px;">
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">SSS</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Official SSS loan
                                and maternity application forms.</p>
                            <button type="button" class="action-button"
                                onclick="openGovForm('https://www.sss.gov.ph/wp-content/uploads/2022/03/mlp_01287.pdf')">Member
                                Loan Application (MLP-01287)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button"
                                onclick="openGovForm('https://www.sss.gov.ph/wp-content/uploads/2022/03/calamity-loan-assistance-application.pdf')">Calamity
                                Loan Assistance Application</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/MAT-1.pdf") %>')">Maternity Notification (MAT-1)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/MAT-2.pdf") %>')">Maternity Reimbursement (MAT-2)</button>

                        </div>
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">Pag-IBIG</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Official Pag-IBIG
                                downloadable forms (Direct PDF).</p>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/PAG-iBIG-MPL.pdf") %>')">Multi-Purpose Loan (MPL - 09-2023)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="openGovForm('<%= ResolveUrl("~/webpage/forms/PAG-iBIG-MPL-09-2023 (1).pdf") %>')">Multi-Purpose Loan (Updated 09-2023)</button>
                        </div>
                        <div style="border:1px solid var(--border-color); border-radius:14px; padding:16px;">
                            <h3 style="margin:0 0 6px 0; color:var(--text-primary);">Other Forms</h3>
                            <p style="margin:0 0 12px 0; color:var(--text-secondary); font-size:13px;">Internal company
                                forms and certifications.</p>
                            <button type="button" class="action-button" onclick="downloadCOEForm()">Certificate of
                                Employment (COE)</button>
                            <div style="height:10px;"></div>
                            <button type="button" class="action-button" onclick="downloadClearanceForm()">Employee
                                Clearance Form</button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('govLoanFormsModal')">Close</button>
                </div>
            </div>
        </div>


        <!-- Custom Confirm Modal -->
        <div id="confirmModal" class="page-modal" style="display:none;">
            <div class="modal-content"
                style="max-width: 440px; text-align:center; padding: 0; border-radius:20px; overflow:hidden;">
                <div class="modal-header" style="background: linear-gradient(135deg, #ef4444, #dc2626);">
                    <span class="close" onclick="closeConfirmModal()" style="color:white; opacity:1;">&times;</span>
                    <h2 id="confirmModalTitle" class="modal-title" style="color:white;">Confirm Action</h2>
                </div>
                <div class="modal-body" style="padding: 40px 30px; text-align:center;">
                    <div id="confirmModalIcon" style="font-size: 60px; margin-bottom: 20px;">⚠️</div>
                    <p id="confirmModalMessage"
                        style="color: var(--text-primary); font-size: 15px; font-weight: 500; line-height: 1.6;"></p>
                </div>
                <div class="modal-footer" style="justify-content: center; gap: 15px; padding-bottom: 30px;">
                    <button type="button" class="btn-cancel" onclick="closeConfirmModal()">Cancel</button>
                    <button type="button" id="confirmModalOkBtn" class="btn-submit"
                        style="background: #ef4444; min-width: 120px;">Confirm</button>
                </div>
            </div>
        </div>

        <!-- Undertime Modal -->
        <div id="undertimeModal"
            style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(5px);">
            <div
                style="background: white; margin: 100px auto; border-radius: 20px; width: 90%; max-width: 450px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); overflow: hidden; font-family: 'Poppins', sans-serif;">
                <div style="background: #f59e0b; padding: 20px; color: white; text-align: center; position: relative;">
                    <span onclick="closeModal('undertimeModal')"
                        style="position: absolute; left: 20px; top: 15px; font-size: 24px; cursor: pointer;">&times;</span>
                    <h3 style="margin: 0; font-size: 18px; font-weight: 700;">⚠️ Early Time Out</h3>
                </div>

                <div id="undertimeSelection" style="padding: 30px; text-align: center;">
                    <div style="font-size: 50px; margin-bottom: 15px;">🕒</div>
                    <h3 style="color: #333; margin-bottom: 10px;">It's not yet 5:00 PM</h3>
                    <p style="color: #666; line-height: 1.6; margin-bottom: 25px;">
                        Timing out now will be recorded as <strong>Undertime</strong>. Please select the type of
                        undertime:
                    </p>

                    <div style="display: flex; flex-direction: column; gap: 12px;">
                        <button type="button" onclick="showEmergencyForm()"
                            style="display: flex; align-items: center; gap: 15px; padding: 15px; border: 2px solid #fee2e2; border-radius: 12px; background: #fff1f2; cursor: pointer; text-align: left; transition: all 0.2s;">
                            <div style="font-size: 24px;">🚨</div>
                            <div>
                                <div style="font-weight: 700; color: #991b1b; margin-bottom: 2px; font-size: 14px;">
                                    Emergency Quick Notify</div>
                                <div style="font-size: 11px; color: #b91c1c; opacity: 0.8;">Medical or urgent matters.
                                </div>
                            </div>
                        </button>

                        <button type="button" onclick="showRegularUTForm()"
                            style="display: flex; align-items: center; gap: 15px; padding: 15px; border: 2px solid #fef3c7; border-radius: 12px; background: #fffbeb; cursor: pointer; text-align: left; transition: all 0.2s;">
                            <div style="font-size: 24px;">📄</div>
                            <div>
                                <div style="font-weight: 700; color: #92400e; margin-bottom: 2px; font-size: 14px;">
                                    Regular Undertime</div>
                                <div style="font-size: 11px; color: #a16207; opacity: 0.8;">Personal errands or
                                    non-emergency.</div>
                            </div>
                        </button>
                    </div>
                    <div style="margin-top: 15px; font-size: 12px; color: #6b7280;">
                        Already have an approved request? <a href="javascript:void(0)" onclick="undertimeYes()"
                            style="color: #3b82f6; font-weight: 600; text-decoration: none;">Check status</a>
                    </div>
                </div>

                <!-- Emergency Form -->
                <div id="emergencyForm" style="display: none; padding: 30px;">
                    <div
                        style="background: #fff1f2; border-left: 4px solid #ef4444; padding: 12px; border-radius: 8px; margin-bottom: 15px;">
                        <h4 style="color: #991b1b; margin: 0 0 5px 0; font-size: 14px;">🚨 Emergency Notification</h4>
                        <p style="color: #b91c1c; font-size: 11px; margin: 0;">This will immediately notify HR and allow
                            you to time out.</p>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Emergency
                            Reason *</label>
                        <textarea id="emergencyReason"
                            style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; min-height: 80px; resize: none;"
                            placeholder="Briefly describe the emergency..."></textarea>
                    </div>
                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button"
                            style="padding: 8px 16px; border: none; border-radius: 8px; background: #f3f4f6; cursor: pointer;"
                            onclick="backToSelection()">Back</button>
                        <button type="button"
                            style="padding: 8px 16px; border: none; border-radius: 8px; background: #ef4444; color: white; cursor: pointer;"
                            onclick="submitEmergencyUndertime()">Send & Time Out</button>
                    </div>
                </div>

                <!-- Regular Form -->
                <div id="regularUTForm" style="display: none; padding: 30px;">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                        <div>
                            <label
                                style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Departure
                                Date *</label>
                            <input type="date" id="utDate"
                                style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;" />
                        </div>
                        <div>
                            <label
                                style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Departure
                                Time *</label>
                            <input type="time" id="utTime"
                                style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;" />
                        </div>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Reason for
                            Undertime *</label>
                        <textarea id="utReason"
                            style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; min-height: 80px; resize: none;"
                            placeholder="Please provide a reason..."></textarea>
                    </div>
                    <div
                        style="background: #fffbeb; border-left: 4px solid #f59e0b; padding: 12px; border-radius: 8px; margin-bottom: 15px;">
                        <p style="color: #92400e; font-size: 11px; margin: 0;"><strong>Note:</strong> Requires HR/Admin
                            approval.</p>
                    </div>
                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button"
                            style="padding: 8px 16px; border: none; border-radius: 8px; background: #f3f4f6; cursor: pointer;"
                            onclick="backToSelection()">Back</button>
                        <button type="button"
                            style="padding: 8px 16px; border: none; border-radius: 8px; background: #f59e0b; color: white; cursor: pointer;"
                            onclick="submitRegularUndertime()">Submit Request</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Undertime Request Modal (Manual) -->
        <div id="undertimeRequestModal" class="page-modal">
            <div class="modal-content" style="max-width: 450px;">
                <div class="modal-header" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <span class="close" onclick="closeModal('undertimeRequestModal')">&times;</span>
                    <h2 class="modal-title">🕒 Request Undertime</h2>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <div class="form-group">
                        <label class="form-label">Reason for Undertime *</label>
                        <textarea id="txtUndertimeReason" class="form-textarea"
                            placeholder="Please provide details about why you need to leave early..."></textarea>
                    </div>
                    <div
                        style="background: #FFFBEB; border-left: 4px solid #f59e0b; padding: 15px; border-radius: 0 8px 8px 0;">
                        <p style="color: #92400e; font-size: 13px; font-weight: 600;">
                            Note: Your request will be sent to Admin for approval. This is for formal record keeping.
                        </p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel"
                        onclick="closeModal('undertimeRequestModal')">Cancel</button>
                    <button type="button" class="btn-submit" style="background: #f59e0b;"
                        onclick="submitUndertimeRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Resignation Request Modal -->
        <div id="resignationRequestModal" class="page-modal">
            <div class="modal-content" style="max-width: 600px;">
                <div class="modal-header" style="background: linear-gradient(135deg, #ef4444, #dc2626);">
                    <span class="close" onclick="closeModal('resignationRequestModal')">&times;</span>
                    <h2 class="modal-title">👋 Resignation Request</h2>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <div id="resignationStatusMsg"
                        style="display: none; margin-bottom: 20px; padding: 15px; background: #FEF2F2; color: #991B1B; border-radius: 8px; border-left: 4px solid #EF4444;">
                        <p id="resignationStatusText" style="font-weight: 700;"></p>
                    </div>

                    <div id="resignationFormGroup">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                            <div class="form-group">
                                <label class="form-label">Resignation Date</label>
                                <input type="text" class="form-input" value="<%= DateTime.Now.ToString(" MM/dd/yyyy")
                                    %>" readonly style="background: #f8fafc;" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">Effective Last Day *</label>
                                <input type="date" id="resign_lastDay" class="form-input"
                                    onchange="calculateNoticePeriod()" />
                                <div id="notice_calc_msg" style="font-size: 11px; margin-top: 4px; font-weight: 500;">
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Reason Code *</label>
                            <select id="resign_reasonCode" class="form-select">
                                <option value="">-- Select Reason --</option>
                                <option value="Voluntary - Career Advancement">Voluntary - Career Advancement</option>
                                <option value="Voluntary - Personal/Family Reasons">Voluntary - Personal/Family Reasons
                                </option>
                                <option value="Voluntary - Relocation">Voluntary - Relocation</option>
                                <option value="Voluntary - Health Reasons">Voluntary - Health Reasons</option>
                                <option value="Voluntary - Better Opportunities">Voluntary - Better Opportunities
                                </option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Comments/Reason *</label>
                            <textarea id="txtResignationReason" class="form-textarea"
                                placeholder="I am writing to formally resign from my position..."></textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Attachment (Resignation Letter)</label>
                            <div style="border: 2px dashed var(--border-color); padding: 20px; border-radius: 12px; text-align: center; cursor: pointer; transition: all 0.3s ease;"
                                onclick="document.getElementById('resign_letter').click()"
                                onmouseover="this.style.borderColor='var(--primary-color)'; this.style.background='#fdf2f2';"
                                onmouseout="this.style.borderColor='var(--border-color)'; this.style.background='transparent';">
                                <input type="file" id="resign_letter" style="display: none;"
                                    onchange="updateFileName(this)" />
                                <div style="font-size: 24px; margin-bottom: 8px;">📄</div>
                                <div id="file_name_display"
                                    style="font-size: 13px; color: var(--text-secondary); font-weight: 500;">
                                    Upload Resignation Letter (PDF/DOC)
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel"
                        onclick="closeModal('resignationRequestModal')">Cancel</button>
                    <button id="btnConfirmResignation" type="button" class="btn-submit" style="background: #ef4444;"
                        onclick="submitResignationRequest()">Submit Request</button>
                </div>
            </div>
        </div>

        <!-- Success/Alert Modal -->
        <div id="alertActionModal" class="page-modal" style="display:none; z-index:1001;">
            <div class="modal-content"
                style="max-width:400px; text-align:center; padding:40px 30px; border-radius: 24px;">
                <div id="alertIconContainer"
                    style="width:80px; height:80px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 20px; background: #10b981;">
                    <i id="alertIcon" class="fas fa-check" style="font-size:32px; color:white;"></i>
                </div>
                <h3 id="alertModalTitle"
                    style="font-size:24px; font-weight:800; color:var(--primary-color); margin-bottom:10px;">Success
                </h3>
                <p id="alertModalMessage" style="color:var(--text-secondary); font-size:15px; margin-bottom:30px;"></p>
                <button type="button" class="btn-submit" onclick="closeAlertModal()"
                    style="min-width:160px; padding:14px; border-radius: 12px;">Acknowledged</button>
            </div>
        </div>

        <script>
            // Data from server
            const employeeId = '<%= GetEmployeeId() %>';
            const employeeName = '<%= GetEmployeeName() %>';
            const employeeDepartment = '<%= GetEmployeeDepartment() %>';
            const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
            const attendanceStatus = JSON.parse('<%= GetAttendanceStatusJsonString() %>');

            let hasTimedIn = attendanceStatus.hasTimedIn || false;
            let hasTimedOut = attendanceStatus.hasTimedOut || false;

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
                const modal = document.getElementById('alertActionModal');
                if (!modal) {
                    // Fallback to basic alert if modal missing
                    alert(title + ": " + message);
                    return;
                }

                const titleEl = document.getElementById('alertModalTitle');
                const msgEl = document.getElementById('alertModalMessage');
                const iconContainer = document.getElementById('alertIconContainer');
                const icon = document.getElementById('alertIcon');

                if (titleEl) titleEl.textContent = title;
                if (msgEl) msgEl.textContent = message;

                if (type === 'error') {
                    if (iconContainer) iconContainer.style.background = '#ef4444';
                    if (icon) icon.className = 'fas fa-times';
                } else {
                    if (iconContainer) iconContainer.style.background = '#10b981';
                    if (icon) icon.className = 'fas fa-check';
                }

                modal.style.display = 'block';
            }

            function closeAlertModal() {
                closeModal('alertActionModal');
            }

            let _confirmCallback = null;
            function showConfirm(title, message, icon, onConfirm) {
                const modal = document.getElementById('confirmModal');
                if (!modal) {
                    if (confirm(message)) onConfirm();
                    return;
                }

                document.getElementById('confirmModalTitle').textContent = title;
                document.getElementById('confirmModalMessage').textContent = message;
                document.getElementById('confirmModalIcon').textContent = icon || '⚠️';
                _confirmCallback = onConfirm;
                document.getElementById('confirmModalOkBtn').onclick = function () {
                    if (_confirmCallback) _confirmCallback();
                    closeConfirmModal();
                };
                modal.style.display = 'block';
            }

            function closeConfirmModal() {
                closeModal('confirmModal');
                _confirmCallback = null;
            }

            // Specific openers to handle events
            function openLeaveModal(e) {
                if (e) { e.preventDefault(); e.stopPropagation(); }
                openModal('leaveModal');
            }

            function openConcernModal(e) {
                if (e) { e.preventDefault(); e.stopPropagation(); }
                openModal('concernModal');
            }

            function openPayslipModal(e) {
                if (e) { e.preventDefault(); e.stopPropagation(); }
                openModal('payslipModal');
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

            // Check resignation status on load
            const resStatus = '<%= GetResignationStatus() %>';
            if (resStatus === 'Pending') {
                const card = document.getElementById('btnResignationCard');
                if (card) {
                    card.disabled = true;
                    card.textContent = 'Pending Approval';
                    card.style.background = '#94a3b8';
                }
            } else if (resStatus === 'Approved') {
                const card = document.getElementById('cardClearance');
                if (card) card.style.display = 'flex';
                
                const btnResign = document.getElementById('btnResignationCard');
                if (btnResign) {
                    btnResign.disabled = true;
                    btnResign.textContent = 'Resignation Approved';
                    btnResign.parentElement.style.opacity = '0.6';
                    btnResign.parentElement.style.pointerEvents = 'none';
                }
            }

            function openResignationRequestModal() {
                openModal('resignationRequestModal');
            }
            // --------------------------------------

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
                const overtimeBtn = document.getElementById('overtimeBtn');

                if (attendanceStatus.hasTimedIn) {
                    if (attendanceStatus.hasTimedOut) {
                        statusLabel.textContent = `Timed Out at ${attendanceStatus.timeOut}`;
                        statusLabel.style.color = 'var(--warning-color)';
                        timeInBtn.disabled = false;
                        timeOutBtn.disabled = true;
                        if (overtimeBtn) overtimeBtn.style.display = 'none';
                        hasTimedIn = false;
                    } else {
                        statusLabel.textContent = `Timed In at ${attendanceStatus.timeIn}`;
                        statusLabel.style.color = 'var(--success-color)';
                        timeInBtn.disabled = true;
                        timeOutBtn.disabled = false;
                        hasTimedIn = true;
                    }
                } else {
                    statusLabel.textContent = 'Not timed in yet';
                    timeInBtn.disabled = false;
                    timeOutBtn.disabled = true;
                }

                // Handle Resignation Status in UI
                if (attendanceStatus.resignationStatus === 'Pending') {
                    const resCard = document.getElementById('btnResignationCard');
                    if (resCard) {
                        resCard.innerText = 'Resignation Pending';
                        resCard.disabled = true;
                        resCard.style.opacity = '0.7';
                    }
                } else if (attendanceStatus.resignationStatus === 'Approved') {
                    const resCard = document.getElementById('btnResignationCard');
                    if (resCard) {
                        resCard.innerText = 'Resignation Approved';
                        resCard.disabled = true;
                        resCard.style.opacity = '0.7';
                    }
                }
            }

            document.addEventListener('DOMContentLoaded', loadStatus);
            document.addEventListener('DOMContentLoaded', loadRequestMonitor);

            async function timeIn() {
                if (hasTimedIn && !hasTimedOut) {
                    alert('Already timed in.');
                    return;
                }

                const btn = document.getElementById('timeInBtn');
                btn.disabled = true;
                btn.innerHTML = 'Processing...';

                try {
                    const params = new URLSearchParams({
                        action: 'timein',
                        employeeId: employeeId,
                        employeeName: employeeName,
                        department: employeeDepartment
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        window.location.reload();
                    } else {
                        alert(result.message || 'Time in failed.');
                        btn.disabled = false;
                        btn.innerHTML = 'Time In';
                    }
                } catch (error) {
                    console.error(error);
                    alert('Error occurring.');
                    btn.disabled = false;
                }
            }

            function timeOut() {
                const now = new Date();
                const hours = now.getHours();

                if (hours < 17) {
                    const modal = document.getElementById('undertimeModal');
                    if (modal) {
                        modal.style.display = 'block';

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
                    }
                } else {
                    proceedWithTimeOut();
                }
            }

            function showEmergencyForm() {
                document.getElementById('undertimeSelection').style.display = 'none';
                document.getElementById('emergencyForm').style.display = 'block';
            }

            function showRegularUTForm() {
                document.getElementById('undertimeSelection').style.display = 'none';
                document.getElementById('regularUTForm').style.display = 'block';
            }

            function backToSelection() {
                document.getElementById('undertimeSelection').style.display = 'block';
                document.getElementById('emergencyForm').style.display = 'none';
                document.getElementById('regularUTForm').style.display = 'none';
            }

            async function submitEmergencyUndertime() {
                const reason = document.getElementById('emergencyReason').value.trim();
                if (!reason) {
                    showAlert('Required', 'Please provide a reason.', 'error');
                    return;
                }

                showConfirm(
                    '🚨 Emergency Notification',
                    'This will immediately notify HR of your emergency departure and record your undertime. Are you sure?',
                    '🚨',
                    async function () {
                        try {
                            const params = new URLSearchParams({
                                action: 'emergencyundertime',
                                employeeId: employeeId,
                                reason: reason
                            });

                            const response = await fetch(handlerUrl + '?' + params.toString());
                            const result = await response.json();

                            if (result.success) {
                                showAlert('Emergency Sent', 'Emergency notification sent! You have been timed out.', 'success');
                                setTimeout(() => { window.location.reload(); }, 2000);
                            } else {
                                showAlert('Error', result.message || 'Failed to record emergency.', 'error');
                            }
                        } catch (error) {
                            console.error(error);
                            showAlert('Error', 'Connection error.', 'error');
                        }
                    }
                );
            }

            async function undertimeYes() {
                try {
                    const response = await fetch(`${handlerUrl}?action=getstatus&employeeId=${employeeId}`);
                    const status = await response.json();

                    if (status.undertimeStatus === 'Approved') {
                        proceedWithTimeOut();
                    } else if (status.undertimeStatus === 'Pending') {
                        showAlert('Pending', 'Your undertime request is still pending admin approval. Please wait for approval before timing out.', 'error');
                    } else {
                        showAlert('Not Found', 'No approved undertime request found. Please select "Regular UT Request" to submit one.', 'error');
                    }
                } catch (error) {
                    console.error('Error fetching status:', error);
                    showAlert('Error', 'Could not verify undertime status. Please try again.', 'error');
                }
            }

            function undertimeNo() {
                showRegularUndertimeForm();
            }

            async function submitRegularUndertime() {
                const reason = document.getElementById('utReason').value.trim();
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
                } catch (e) { }

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
                        closeModal('undertimeModal');
                        showAlert('Success', 'Undertime request submitted successfully!');
                    } else {
                        showAlert('Error', result.message || 'Failed to submit request.', 'error');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showAlert('Error', 'An error occurred. Please try again.', 'error');
                }
            }

            function calculateOTHours() {
                const start = document.getElementById('txtOvertimeStart').value;
                const end = document.getElementById('txtOvertimeEnd').value;
                if (!start || !end) return;

                const startDate = new Date(`2000-01-01T${start}`);
                const endDate = new Date(`2000-01-01T${end}`);

                let diff = (endDate - startDate) / (1000 * 60 * 60); // Difference in hours
                if (diff < 0) diff += 24; // Handle shift crossing midnight

                document.getElementById('txtOvertimeHours').value = diff.toFixed(1);
            }

            async function submitOvertimeRequest() {
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

                try {
                    const params = new URLSearchParams({
                        action: 'requestovertime',
                        employeeId: employeeId,
                        reason: reason,
                        otDate: otDate,
                        startTime: startTime,
                        endTime: endTime,
                        requestedHours: requestedHours
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        closeModal('overtimeModal');
                        showAlert('Success', 'Overtime request submitted successfully!');
                        setTimeout(() => { window.location.reload(); }, 1500);
                    } else {
                        showAlert('Error', result.message || 'Failed to submit request.', 'error');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showAlert('Error', 'An error occurred. Please try again.', 'error');
                }
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

                resignationDate.setHours(0, 0, 0, 0);
                effectiveLastDay.setHours(0, 0, 0, 0);

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

            async function submitResignationRequest() {
                const reason = document.getElementById('txtResignationReason').value.trim();
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
                    async function () {
                        const btn = document.getElementById('btnConfirmResignation');
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

                        try {
                            const response = await fetch(`${handlerUrl}`, {
                                method: 'POST',
                                body: formData
                            });
                            const result = await response.json();

                            if (result.success) {
                                closeModal('resignationRequestModal');
                                showAlert('Submitted', 'Resignation request submitted successfully!');
                                setTimeout(() => { window.location.reload(); }, 2000);
                            } else {
                                showAlert('Error', result.message || 'Failed to submit request.', 'error');
                                btn.disabled = false;
                                btn.textContent = originalText;
                            }
                        } catch (error) {
                            console.error('Error:', error);
                            showAlert('Error', 'An unexpected error occurred. Please try again.', 'error');
                            btn.disabled = false;
                            btn.textContent = originalText;
                        }
                    }
                );
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

            async function loadRequestMonitor() {
                try {
                    const response = await fetch(`${handlerUrl}?action=getrequesthistory&employeeId=${encodeURIComponent(employeeId)}`);
                    const result = await response.json();

                    if (!result.success) {
                        renderRequestRows('ongoingRequestsList', [], 'Unable to load ongoing requests.');
                        renderRequestRows('requestHistoryList', [], 'Unable to load request history.');
                        return;
                    }

                    renderRequestRows('ongoingRequestsList', result.ongoingRequests || [], 'No ongoing requests.');
                    renderRequestRows('requestHistoryList', result.requestHistory || [], 'No request history found.');
                } catch (error) {
                    renderRequestRows('ongoingRequestsList', [], 'Unable to load ongoing requests.');
                    renderRequestRows('requestHistoryList', [], 'Unable to load request history.');
                }
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

            async function loadConcernHistory() {
                try {
                    const response = await fetch(`${handlerUrl}?action=getemployeeconcernhistory&employeeId=${encodeURIComponent(employeeId)}`);
                    const result = await response.json();

                    if (!result.success) {
                        renderConcernHistoryRows([]);
                        return;
                    }
                    renderConcernHistoryRows(result.concernHistory || []);
                } catch (error) {
                    renderConcernHistoryRows([]);
                }
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

            function openOngoingRequestsModal() {
                loadRequestMonitor();
                document.getElementById('ongoingRequestsModal').style.display = 'block';
            }

            function openRequestHistoryModal() {
                loadRequestMonitor();
                document.getElementById('requestHistoryModal').style.display = 'block';
            }


            // Close modal when clicking outside
            window.onclick = function (event) {
                if (event.target.classList.contains('page-modal')) {
                    event.target.style.display = 'none';
                }
            }

            function downloadCOEForm() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is loading. Please wait...');
                        return;
                    }

                    const element = document.createElement('div');
                    const logoUrl = '<%= ResolveUrl("~/images/shessentials-logo.png") %>';
                    element.innerHTML = `
                        <div style="padding: 60px; font-family: 'Times New Roman', Times, serif; color: #000; width: 750px; margin: auto; line-height: 1.6;">
                            <div style="text-align: center; margin-bottom: 30px;">
                                <img src="${logoUrl}" style="width: 100px; height: auto; margin-bottom: 10px;" alt="Logo" crossorigin="anonymous" onerror="this.style.display='none'">
                                <h2 style="margin: 0; font-size: 18px; font-weight: bold;">SHEESSENTIALS SKINCARE AND BEAUTY MANUFACTURING CO.</h2>
                                <p style="margin: 2px 0; font-size: 12px;">673 Quirino Hwy, Novaliches, Quezon City, Metro Manila</p>
                                <p style="margin: 2px 0; font-size: 12px;">sheessentials.it3l@gmail.com</p>
                            </div>

                            <div style="text-align: center; margin-bottom: 40px;">
                                <h1 style="font-size: 24px; font-weight: bold; text-decoration: underline;">CERTIFICATE OF EMPLOYMENT</h1>
                            </div>

                            <div style="margin-bottom: 20px;">
                                Date: _________________
                            </div>

                            <p style="margin-bottom: 20px;">TO WHOM IT MAY CONCERN:</p>

                            <p style="margin-bottom: 30px; text-align: justify;">
                                This is to certify that _____________________________ has been a bonafide employee of Sheessentials Skincare and Beauty Manufacturing Co. under the following details:
                            </p>

                            <div style="margin-left: 20px; margin-bottom: 30px;">
                                <p style="margin-bottom: 15px;">Position: _____________________________</p>
                                <p style="margin-bottom: 15px;">Department: _____________________________</p>
                                <p style="margin-bottom: 15px;">Employment Type: ☐ Regular &nbsp; ☐ Probationary &nbsp; ☐ Contractual</p>
                                <p style="margin-bottom: 15px;">Date of Hire: _____________________________</p>
                                <p style="margin-bottom: 15px;">Employment Status: ☐ Currently Employed &nbsp; ☐ Separated as of _____________</p>
                            </div>

                            <p style="margin-bottom: 40px; text-align: justify;">
                                This certification is issued upon the request of the above-named employee for whatever legal purpose it may serve.
                            </p>

                            <div style="margin-top: 50px;">
                                <p style="margin-bottom: 15px; font-weight: bold;">Issued by:</p>
                                <div style="margin-left: 20px;">
                                    <p style="margin-bottom: 10px;">Name: _____________________________</p>
                                    <p style="margin-bottom: 10px;">Position: HR Staff / HR Manager</p>
                                    <p style="margin-bottom: 10px;">Signature: _____________________________</p>
                                    <p style="margin-bottom: 10px;">Date: _____________________________</p>
                                </div>
                            </div>
                        </div>
                    `;

                    const opt = {
                        margin: 0,
                        filename: 'COE_Form.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 2, scrollY: 0, useCORS: true },
                        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
                    };

                    html2pdf().from(element).set(opt).save().then(() => {
                        console.log('COE Downloaded successfully');
                    }).catch(err => {
                        console.error('PDF Error:', err);
                        alert('Failed to generate PDF: ' + err.message);
                    });
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
                    const logoUrl = '<%= ResolveUrl("~/images/shessentials-logo.png") %>';
                    element.innerHTML = `
                        <div style="padding: 30px; font-family: Arial, sans-serif; color: #000; width: 750px; margin: auto; line-height: 1.3; font-size: 11.5px;">
                            <div style="text-align: center; margin-bottom: 15px;">
                                <img src="${logoUrl}" style="width: 80px; height: auto; margin-bottom: 5px;" alt="Logo" crossorigin="anonymous" onerror="this.style.display='none'">
                                <h2 style="margin: 0; font-size: 15px; font-weight: bold;">SHEESSENTIALS SKINCARE AND BEAUTY MANUFACTURING CO.</h2>
                                <h1 style="margin: 5px 0 0 0; font-size: 17px; font-weight: bold;">EMPLOYEE CLEARANCE FORM</h1>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <h3 style="font-size: 13px; font-weight: bold; background-color: #f0f0f0; padding: 4px; border: 1px solid #000; margin: 0 0 8px 0;">EMPLOYEE INFORMATION</h3>
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                                    <div>Name: ___________________________________</div>
                                    <div>Employee ID: _____________________________</div>
                                    <div>Department: _____________________________</div>
                                    <div>Position: _____________________________</div>
                                    <div>Date of Hire: _____________________________</div>
                                    <div>Last Day of Work: _____________________________</div>
                                </div>
                                <div style="margin-top: 8px;">
                                    Reason for Separation: ☐ Resignation &nbsp; ☐ End of Contract &nbsp; ☐ Termination
                                </div>
                            </div>

                            <div style="margin-bottom: 12px;">
                                <h3 style="font-size: 13px; font-weight: bold; background-color: #f0f0f0; padding: 4px; border: 1px solid #000; margin: 0 0 8px 0;">CLEARANCE CHECKLIST</h3>
                                
                                <p style="font-weight: bold; margin: 0 0 5px 0;">A. HR Department</p>
                                <table style="width: 100%; border-collapse: collapse; border: 1px solid #000; margin-bottom: 5px;">
                                    <tr style="background-color: #f9f9f9;">
                                        <th style="border: 1px solid #000; padding: 4px; text-align: left; width: 45%;">Item</th>
                                        <th style="border: 1px solid #000; padding: 4px; text-align: center; width: 20%;">Status</th>
                                        <th style="border: 1px solid #000; padding: 4px; text-align: center; width: 20%;">Remarks</th>
                                        <th style="border: 1px solid #000; padding: 4px; text-align: center; width: 15%;">Signature</th>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Employment records completed and filed</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Government contributions updated (SSS, Pag-IBIG, PhilHealth)</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Certificate of Employment issued</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Loan balances settled or endorsed to payroll</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                </table>
                                <div style="font-size: 11px; margin-bottom: 10px;">HR Staff Name & Signature: ______________________ &nbsp; Date: _________</div>

                                <p style="font-weight: bold; margin: 5px 0 5px 0;">B. Finance / Payroll</p>
                                <table style="width: 100%; border-collapse: collapse; border: 1px solid #000; margin-bottom: 5px;">
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px; width: 45%;">No outstanding cash advances</td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 20%; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 20%;"></td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 15%;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Final pay computation completed</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Loan deductions reflected in final pay</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                </table>
                                <div style="font-size: 11px; margin-bottom: 10px;">Finance / Payroll In-charge Name & Signature: ______________________ &nbsp; Date: _________</div>

                                <p style="font-weight: bold; margin: 5px 0 5px 0;">C. Immediate Supervisor / Department Head</p>
                                <table style="width: 100%; border-collapse: collapse; border: 1px solid #000; margin-bottom: 5px;">
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px; width: 45%;">Company ID returned</td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 20%; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 20%;"></td>
                                        <td style="border: 1px solid #000; padding: 4px; width: 15%;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Uniform / equipment returned</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">Pending tasks properly turned over</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="border: 1px solid #000; padding: 4px;">No pending accountabilities</td>
                                        <td style="border: 1px solid #000; padding: 4px; text-align: center;">☐ Cleared &nbsp; ☐ Not</td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                        <td style="border: 1px solid #000; padding: 4px;"></td>
                                    </tr>
                                </table>
                                <div style="font-size: 11px;">Supervisor Name & Signature: ______________________ &nbsp; Date: _________</div>
                            </div>

                            <div style="margin-top: 15px; border-top: 1px solid #000; padding-top: 8px;">
                                <h3 style="font-size: 13px; font-weight: bold; margin: 0 0 5px 0;">FINAL APPROVAL</h3>
                                <p style="font-style: italic; margin: 0 0 15px 0;">This certifies that the above-named employee has been cleared of all accountabilities and is eligible for final pay processing.</p>
                                <div style="display: flex; justify-content: space-between; gap: 20px;">
                                    <div style="flex: 1; text-align: center; border-top: 1px solid #000; padding-top: 5px;">HR Manager / Super Admin Signature / Date</div>
                                    <div style="flex: 1; text-align: center; border-top: 1px solid #000; padding-top: 5px;">Employee Received By / Date</div>
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

                    html2pdf().from(element).set(opt).save().then(() => {
                        console.log('Clearance Form Downloaded successfully');
                    }).catch(err => {
                        console.error('PDF Error:', err);
                        alert('Failed to generate PDF: ' + err.message);
                    });
                } catch (err) {
                    alert('Error: ' + err.message);
                }
            }
            function downloadPDF() {
                try {
                    if (typeof html2pdf === 'undefined') {
                        alert('PDF library is loading. Please wait...');
                        return;
                    }

                    const name = "<%= GetEmployeeName() %>";
                    const period = "<%= GetPayPeriod() %>";
                    const basic = "<%= GetBasicSalary() %>";
                    const allowances = "<%= GetAllowances() %>";
                    const ot = "<%= GetOvertimePay() %>";
                    const gross = "<%= GetGrossSalary() %>";
                    const sss = "<%= GetSSSDeduction() %>";
                    const ph = "<%= GetPhilHealthDeduction() %>";
                    const pi = "<%= GetPagIbigDeduction() %>";
                    const tax = "<%= GetWithholdingTax() %>";
                    const abs = "<%= GetAbsenceDeduction() %>";
                    const pen = "<%= GetPenalties() %>";
                    const ded = "<%= GetTotalDeductions() %>";
                    const net = "<%= GetNetSalary() %>";

                    const element = document.createElement('div');
                    element.innerHTML = `
                        <div style="padding: 60px 50px; font-family: 'Arial', sans-serif; color: #000; width: 750px; margin: auto; border: 1px solid #000; min-height: 1020px; display: flex; flex-direction: column; justify-content: space-between; box-sizing: border-box;">
                            <div>
                                <div style="text-align: center; border-bottom: 2px solid #000; padding-bottom: 20px; margin-bottom: 40px;">
                                    <h1 style="margin: 0; font-size: 26px;">SHEESSENTIALS SKINCARE AND BEAUTY MANUFACTURING CO.</h1>
                                    <p style="margin: 10px 0; font-size: 18px; font-weight: bold; letter-spacing: 2px;">PAYSLIP</p>
                                </div>
                                
                                <table style="width: 100%; margin-bottom: 40px; font-size: 15px;">
                                    <tr>
                                        <td style="width: 50%; padding: 10px 5px;"><strong>Employee:</strong> ${name}</td>
                                        <td style="text-align: right; padding: 10px 5px;"><strong>Pay Period:</strong> ${period}</td>
                                    </tr>
                                </table>

                                <div style="display: flex; gap: 30px; margin-bottom: 50px;">
                                    <div style="flex: 1;">
                                        <h3 style="font-size: 17px; border-bottom: 2px solid #000; padding-bottom: 8px; margin-bottom: 15px;">EARNINGS</h3>
                                        <table style="width: 100%; font-size: 14px; border-collapse: collapse;">
                                            <tr><td style="padding: 10px 0;">Basic Salary</td><td style="text-align: right;">₱ ${basic}</td></tr>
                                            <tr><td style="padding: 10px 0;">Allowances</td><td style="text-align: right;">₱ ${allowances}</td></tr>
                                            <tr><td style="padding: 10px 0;">Overtime Pay</td><td style="text-align: right;">₱ ${ot}</td></tr>
                                            <tr style="font-weight: bold; border-top: 2px solid #000;"><td style="padding: 15px 0; font-size: 16px;">GROSS PAY</td><td style="text-align: right; font-size: 16px;">₱ ${gross}</td></tr>
                                        </table>
                                    </div>
                                    <div style="flex: 1;">
                                        <h3 style="font-size: 17px; border-bottom: 2px solid #000; padding-bottom: 8px; margin-bottom: 15px;">DEDUCTIONS</h3>
                                        <table style="width: 100%; font-size: 14px; border-collapse: collapse;">
                                            <tr><td style="padding: 10px 0;">Govt Deductions</td><td style="text-align: right;">${sss} / ${ph} / ${pi} / ${tax}</td></tr>
                                            <tr><td style="padding: 10px 0;">Absences & Lates</td><td style="text-align: right;">₱ ${abs}</td></tr>
                                            <tr><td style="padding: 10px 0;">Penalties</td><td style="text-align: right;">₱ ${pen}</td></tr>
                                            <tr style="font-weight: bold; border-top: 2px solid #000;"><td style="padding: 15px 0; font-size: 16px;">TOTAL DEDUCTIONS</td><td style="text-align: right; font-size: 16px;">₱ ${ded}</td></tr>
                                        </table>
                                    </div>
                                </div>

                                <div style="margin-top: 30px; border: 3px solid #000; padding: 30px; text-align: center; background-color: #fcfcfc;">
                                    <span style="font-size: 20px; font-weight: bold;">NET TAKE-HOME PAY: </span>
                                    <span style="font-size: 28px; font-weight: bold;">₱ ${net}</span>
                                </div>
                            </div>

                            <div>
                                <div style="margin-top: 80px; display: flex; justify-content: space-between; font-size: 14px;">
                                    <div style="width: 40%; text-align: center;">
                                        <div style="border-top: 1px solid #000; padding-top: 10px; font-weight: bold;">Employee Signature</div>
                                    </div>
                                    <div style="width: 40%; text-align: center;">
                                        <div style="border-top: 1px solid #000; padding-top: 10px; font-weight: bold;">HR Representative</div>
                                    </div>
                                </div>

                                <p style="margin-top: 40px; font-size: 11px; text-align: center; color: #666;">
                                    Generated on: ${new Date().toLocaleString()}<br>
                                    <em>This is a system-generated document.</em>
                                </p>
                            </div>
                        </div>
                    `;

                    const opt = {
                        margin: 0,
                        filename: 'Payslip_' + name.replace(/[^a-z0-9]/gi, '_') + '.pdf',
                        image: { type: 'jpeg', quality: 0.98 },
                        html2canvas: { scale: 3, useCORS: true },
                        jsPDF: { unit: 'in', format: 'letter', orientation: 'portrait' }
                    };

                    html2pdf().from(element).set(opt).save();
                } catch (err) {
                    alert('Error: ' + err.message);
                }
            }
        </script>
    </asp:Content>