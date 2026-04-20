<%@ Page Title="HR Profile" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Profile.aspx.cs" Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.HRProfile" %>
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
                                    <div class="stat-label">Working Days / Year</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value" style="color: #f59e0b;">
                                        <%= GetOvertimeHours() %>h
                                    </div>
                                    <div class="stat-label">Overtime</div>
                                </div>
                                <div class="stat-box">
                                    <div class="stat-value" style="color: #ef4444;">
                                        <%= GetUndertimeCount() %>
                                    </div>
                                    <div class="stat-label">Undertime</div>
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


                        <div class="action-card" onclick="openResignationRequestModal()">
                            <div class="action-icon">👋</div>
                            <h3 class="action-title">Resignation Request</h3>
                            <p class="action-description">Submit a formal resignation request to start the offboarding
                                process.</p>
                            <button id="btnResignationCard" type="button" class="action-button"
                                onclick="openResignationRequestModal()" style="background: #ef4444;">Submit
                                Request</button>
                        </div>
                    </div>
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
                    <button type="button" class="btn-submit" onclick="window.print()">Print</button>
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
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal('leaveModal')">Cancel</button>
                    <asp:Button ID="btnSubmitLeave" runat="server" CssClass="btn-submit" Text="Submit Leave Request"
                        OnClick="btnSubmitLeave_Click" />
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


        <!-- Undertime Warning Modal (Image Match) -->
        <div id="undertimeModal" class="page-modal">
            <div class="modal-content"
                style="max-width: 450px; border-radius: 20px; overflow: hidden; border: none; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
                <div class="modal-header"
                    style="background: #ef4444; border-bottom: none; padding: 12px 20px; position: relative; display: flex; align-items: center; justify-content: center;">
                    <span class="close" onclick="closeModal('undertimeModal')"
                        style="color: white; position: absolute; left: 15px; top: 10px; font-size: 24px;">&times;</span>
                    <h2 class="modal-title"
                        style="color: white; font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                        ⚠️ Early Time Out
                    </h2>
                </div>
                <div class="modal-body" style="text-align: center; padding: 35px 30px;">
                    <div
                        style="background: #f3f4f6; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">
                        <span style="font-size: 32px;">🕒</span>
                    </div>
                    <h2 style="color: #111; font-size: 24px; font-weight: 800; margin-bottom: 12px;">It's not yet 5:00
                        PM!</h2>
                    <p style="color: #4b5563; line-height: 1.6; margin-bottom: 30px; font-size: 15px;">
                        Timing out now will be recorded as <strong>Undertime</strong>. Have you already submitted an
                        early departure request?
                    </p>
                    <div style="display: flex; gap: 12px; justify-content: center; width: 100%;">
                        <button type="button" class="action-btn" onclick="undertimeYes()"
                            style="flex: 1; background: #3b82f6; color: white; border: none; padding: 12px; border-radius: 12px; font-weight: 800; font-size: 14px; cursor: pointer; text-transform: uppercase;">YES</button>
                        <button type="button" class="action-btn" onclick="undertimeNo()"
                            style="flex: 1; background: #ef4444; color: white; border: none; padding: 12px; border-radius: 12px; font-weight: 800; font-size: 14px; cursor: pointer; text-transform: uppercase;">NO</button>
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
            <div class="modal-content" style="max-width: 450px;">
                <div class="modal-header" style="background: linear-gradient(135deg, #ef4444, #dc2626);">
                    <span class="close" onclick="closeModal('resignationRequestModal')">&times;</span>
                    <h2 class="modal-title">👋 Resignation Request</h2>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <div id="resignationStatusMsg"
                        style="display: none; margin-bottom: 20px; padding: 15px; background: #FEF2F2; color: #991B1B; border-radius: 8px; border-left: 4px solid #EF4444;">
                        <p id="resignationStatusText" style="font-weight: 700;"></p>
                    </div>
                    <div class="form-group" id="resignationFormGroup">
                        <label class="form-label">Reason for Resignation *</label>
                        <textarea id="txtResignationReason" class="form-textarea"
                            placeholder="Please state your reason for resigning..."></textarea>
                    </div>
                    <div
                        style="background: #FEF2F2; border-left: 4px solid #ef4444; padding: 15px; border-radius: 0 8px 8px 0;">
                        <p style="color: #991B1B; font-size: 13px; font-weight: 600;">
                            Warning: This is a formal request. Once approved, your account will be scheduled for
                            deactivation.
                        </p>
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

        <script>
            // Data from server
            const employeeId = '<%= GetEmployeeId() %>';
            const employeeName = '<%= GetEmployeeName() %>';
            const employeeDepartment = '<%= GetEmployeeDepartment() %>';
            const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
            const attendanceStatus = JSON.parse('<%= GetAttendanceStatusJsonString() %>');

            let hasTimedIn = attendanceStatus.hasTimedIn || false;
            let hasTimedOut = attendanceStatus.hasTimedOut || false;

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
                    }
                } else {
                    proceedWithTimeOut();
                }
            }

            async function undertimeYes() {
                // Fetch fresh status to check approval
                try {
                    const response = await fetch(`${handlerUrl}?action=getstatus&employeeId=${employeeId}`);
                    const status = await response.json();

                    if (status.undertimeStatus === 'Approved') {
                        proceedWithTimeOut();
                    } else if (status.undertimeStatus === 'Pending') {
                        alert('Your undertime request is still pending admin approval. Please wait for approval before timing out.');
                    } else {
                        alert('No approved undertime request found. Please click "No" to submit a formal request.');
                    }
                } catch (error) {
                    console.error('Error fetching status:', error);
                    alert('Could not verify undertime status. Please try again.');
                }
            }

            function undertimeNo() {
                closeModal('undertimeModal');
                openUndertimeRequestModal();
            }

            async function proceedWithTimeOut() {
                const btn = document.getElementById('timeOutBtn');
                btn.disabled = true;
                btn.innerHTML = 'Processing...';

                // Close modal if it was open
                const utModal = document.getElementById('undertimeModal');
                if (utModal) utModal.style.display = 'none';

                try {
                    const params = new URLSearchParams({
                        action: 'timeout',
                        employeeId: employeeId
                    });

                    const response = await fetch(handlerUrl + '?' + params.toString());
                    const result = await response.json();

                    if (result.success) {
                        window.location.reload();
                    } else {
                        alert(result.message || 'Time out failed.');
                        btn.disabled = false;
                        btn.innerHTML = 'Time Out';
                    }
                } catch (error) {
                    console.error(error);
                    alert('Error occurring.');
                    btn.disabled = false;
                    btn.innerHTML = 'Time Out';
                }
            }

            function closeModal(modalId) {
                document.getElementById(modalId).style.display = 'none';
            }

            function openPayslipModal() {
                document.getElementById('payslipModal').style.display = 'block';
            }

            function openLeaveModal() {
                document.getElementById('leaveModal').style.display = 'block';
            }

            function openConcernModal() {
                document.getElementById('concernModal').style.display = 'block';
            }

            function openUndertimeRequestModal() {
                document.getElementById('undertimeRequestModal').style.display = 'block';
            }

            function openResignationRequestModal() {
                const modal = document.getElementById('resignationRequestModal');
                const formGroup = document.getElementById('resignationFormGroup');
                const statusMsg = document.getElementById('resignationStatusMsg');
                const statusText = document.getElementById('resignationStatusText');
                const btnSubmit = document.getElementById('btnConfirmResignation');

                if (attendanceStatus.resignationStatus === 'Pending') {
                    formGroup.style.display = 'none';
                    statusMsg.style.display = 'block';
                    statusText.innerText = 'Your resignation request is currently pending approval.';
                    btnSubmit.style.display = 'none';
                } else if (attendanceStatus.resignationStatus === 'Approved') {
                    formGroup.style.display = 'none';
                    statusMsg.style.display = 'block';
                    statusText.innerText = 'Your resignation has been approved.';
                    btnSubmit.style.display = 'none';
                } else {
                    formGroup.style.display = 'block';
                    statusMsg.style.display = 'none';
                    btnSubmit.style.display = 'block';
                }

                modal.style.display = 'block';
            }

            async function submitUndertimeRequest() {
                const reason = document.getElementById('txtUndertimeReason').value.trim();
                if (!reason) {
                    alert('Please provide a reason for the undertime.');
                    return;
                }

                try {
                    const response = await fetch(`${handlerUrl}?action=requestundertime&employeeId=${employeeId}&reason=${encodeURIComponent(reason)}`);
                    const result = await response.json();

                    if (result.success) {
                        alert('Undertime request submitted successfully!');
                        window.location.reload();
                    } else {
                        alert(result.message || 'Failed to submit request.');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('An error occurred. Please try again.');
                }
            }

            async function submitResignationRequest() {
                const reason = document.getElementById('txtResignationReason').value.trim();
                if (!reason) {
                    alert('Please provide a reason for your resignation.');
                    return;
                }

                if (!confirm("Are you sure you want to submit your resignation request? This is a formal action.")) {
                    return;
                }

                try {
                    const response = await fetch(`${handlerUrl}?action=requestresignation&employeeId=${employeeId}&reason=${encodeURIComponent(reason)}`);
                    const result = await response.json();

                    if (result.success) {
                        alert('Resignation request submitted successfully!');
                        window.location.reload();
                    } else {
                        alert(result.message || 'Failed to submit request.');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('An error occurred. Please try again.');
                }
            }


            // Close modal when clicking outside
            window.onclick = function (event) {
                if (event.target.classList.contains('page-modal')) {
                    event.target.style.display = 'none';
                }
            }
        </script>
    </asp:Content>