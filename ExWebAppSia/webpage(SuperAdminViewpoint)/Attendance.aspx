<%@ Page Title="" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Attendance.aspx.cs" Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.WebForm3" %>
    <%@ Import Namespace="ExWebAppSia.Models" %>
        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
            <style>
                :root {
                    --bg-color: #ffffff;
                    /* âœ… Pure white background */
                    --panel-bg: #ffffff;
                    --stat-bg: #A36A66;
                    /* âœ… Unified accent color */
                    --text-dark: #333333;
                    --text-light: #ffffff;
                    --border-color: #e5e5e5;
                    --hover-bg: #f9f9f9;
                    --stat-hover: #905A57;
                    /* Slightly darker on hover */
                }

                html,
                body {
                    margin: 0;
                    padding: 0;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background-color: var(--bg-color);
                    height: 100%;
                    width: 100%;
                    box-sizing: border-box;
                }

                .attendance-container {
                    width: 100%;
                    min-height: 100vh;
                    padding: 20px;
                    background-color: var(--bg-color);
                    box-sizing: border-box;
                    display: flex;
                    flex-direction: column;
                    gap: 20px;
                    max-width: 1400px;
                    margin: 0 auto;
                }

                .header-panel {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    gap: 20px;
                    padding: 16px 20px;
                    background-color: var(--panel-bg);
                    border-radius: 12px;
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                    border: 1px solid var(--border-color);
                }

                .date-selector {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    background-color: #fafafa;
                    border: 1px solid var(--border-color);
                    border-radius: 24px;
                    padding: 8px 16px;
                }

                .date-text {
                    font-size: 16px;
                    font-weight: 500;
                    color: var(--text-dark);
                }

                .nav-button {
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    background: var(--border-color);
                    color: var(--text-dark);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    font-size: 14px;
                    transition: background 0.2s;
                }

                .nav-button:hover {
                    background: #d0d0d0;
                }

                .calendar-icon {
                    width: 20px;
                    height: 20px;
                    fill: var(--text-dark);
                }

                .stats-container {
                    display: flex;
                    gap: 16px;
                }

                .stat-card {
                    background-color: var(--stat-bg);
                    color: var(--text-light);
                    border-radius: 12px;
                    padding: 12px 20px;
                    text-align: center;
                    min-width: 80px;
                    transition: background-color 0.2s ease;
                }

                .stat-card:hover {
                    background-color: var(--stat-hover);
                    transform: translateY(-1px);
                }

                .stat-number {
                    font-size: 24px;
                    font-weight: bold;
                    margin: 0;
                    line-height: 1;
                }

                .stat-label {
                    font-size: 12px;
                    font-weight: 600;
                    opacity: 0.9;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }

                /* Tab Styles */
                .tab-btn {
                    background: none;
                    border: none;
                    padding: 10px 20px;
                    font-size: 14px;
                    font-weight: 600;
                    color: #64748b;
                    cursor: pointer;
                    border-bottom: 3px solid transparent;
                    transition: all 0.3s ease;
                }

                .tab-btn.active {
                    color: #A36A66;
                    border-bottom-color: #A36A66;
                }

                .tab-btn:hover {
                    color: #A36A66;
                    background-color: #f8fafc;
                }

                .tab-content {
                    animation: fadeIn 0.4s ease;
                }

                @keyframes fadeIn {
                    from {
                        opacity: 0;
                        transform: translateY(10px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                /* Filter & Search Row */
                .filter-search-row {
                    display: flex;
                    gap: 20px;
                    margin-bottom: 20px;
                    flex-wrap: wrap;
                }

                .dept-dropdown {
                    position: relative;
                    width: 200px;
                    background-color: var(--panel-bg);
                    border: 1px solid var(--border-color);
                    border-radius: 24px;
                    padding: 8px 16px;
                    display: flex;
                    align-items: center;
                }

                .dept-dropdown select {
                    width: 100%;
                    padding: 6px 8px;
                    border: none;
                    outline: none;
                    background: transparent;
                    font-size: 14px;
                    color: var(--text-dark);
                    -webkit-appearance: none;
                    -moz-appearance: none;
                    appearance: none;
                    cursor: pointer;
                }

                .search-bar {
                    flex: 1;
                    min-width: 250px;
                    background-color: var(--panel-bg);
                    border: 1px solid var(--border-color);
                    border-radius: 24px;
                    padding: 8px 16px;
                    display: flex;
                    align-items: center;
                }

                .search-icon {
                    width: 16px;
                    height: 16px;
                    fill: #888;
                    margin-right: 8px;
                }

                .search-input {
                    flex: 1;
                    border: none;
                    outline: none;
                    background: transparent;
                    font-size: 14px;
                    color: var(--text-dark);
                }

                .search-input::placeholder {
                    color: #aaa;
                }

                /* Attendance Table â€” SLIM & CLEAN */
                .attendance-table-wrapper {
                    background-color: var(--panel-bg);
                    border-radius: 12px;
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                    border: 1px solid var(--border-color);
                    overflow: hidden;
                    width: 100%;
                }

                .attendance-table {
                    width: 100%;
                    border-collapse: collapse;
                    background-color: transparent;
                    margin: 0;
                }

                .table-header {
                    background-color: #fafafa;
                }

                .table-header th {
                    padding: 12px 16px;
                    text-align: left;
                    font-weight: 600;
                    color: #555;
                    font-size: 13px;
                    border-bottom: 2px solid var(--border-color);
                    white-space: nowrap;
                }

                .table-header th:nth-child(1) {
                    width: 12%;
                }

                .table-header th:nth-child(2) {
                    width: 25%;
                }

                .table-header th:nth-child(3) {
                    width: 25%;
                }

                .table-header th:nth-child(4),
                .table-header th:nth-child(5) {
                    width: 19%;
                }

                .table-row {
                    transition: background-color 0.2s ease;
                }

                .table-row td {
                    padding: 12px 16px;
                    color: var(--text-dark);
                    font-size: 13px;
                    vertical-align: middle;
                    border-bottom: 1px solid #f0f0f0;
                }

                .table-row:last-child td {
                    border-bottom: none;
                }

                .table-row:hover {
                    background-color: var(--hover-bg);
                }

                /* Time-In and Time-Out styled boxes */
                .time-in-box {
                    display: inline-block;
                    background-color: #E8D5C4;
                    color: #8B6F47;
                    padding: 6px 12px;
                    border-radius: 6px;
                    font-weight: 600;
                    font-size: 12px;
                    min-width: 80px;
                    text-align: center;
                }

                .time-out-box {
                    display: inline-block;
                    background-color: #E5E5E5;
                    color: #666666;
                    padding: 6px 12px;
                    border-radius: 6px;
                    font-weight: 600;
                    font-size: 12px;
                    min-width: 80px;
                    text-align: center;
                }

                .time-empty {
                    color: #999;
                    font-style: italic;
                }

                /* Responsive */
                @media (max-width: 768px) {
                    .header-panel {
                        flex-direction: column;
                        align-items: stretch;
                        gap: 16px;
                    }

                    .stats-container {
                        width: 100%;
                        justify-content: space-around;
                    }

                    .filter-search-row {
                        flex-direction: column;
                        gap: 12px;
                    }

                    .dept-dropdown,
                    .search-bar {
                        width: 100%;
                    }

                    .table-header th,
                    .table-row td {
                        padding: 5px 8px;
                        font-size: 11px;
                    }
                }

                /* Custom Modal Styles */
                .custom-modal-v2 {
                    display: none;
                    position: fixed;
                    z-index: 100000;
                    left: 0;
                    top: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.8);
                    backdrop-filter: blur(5px);
                    align-items: center;
                    justify-content: center;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                }

                .custom-modal-v2.active {
                    display: flex !important;
                }

                .custom-modal-v2-content {
                    background: white;
                    margin: auto;
                    padding: 0;
                    border-radius: 12px;
                    width: 90%;
                    max-width: 450px;
                    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                    animation: customSlideDown 0.3s ease;
                    position: relative;
                    overflow: hidden;
                }

                .custom-modal-v2-header {
                    padding: 16px 20px;
                    background: #A36A66;
                    color: white;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }

                .custom-modal-v2-title {
                    margin: 0;
                    font-size: 1.1rem;
                    font-weight: 600;
                }

                .custom-modal-v2-body {
                    padding: 24px;
                }

                .custom-modal-v2-footer {
                    padding: 16px 24px;
                    display: flex;
                    gap: 12px;
                    justify-content: flex-end;
                    border-top: 1px solid var(--border-color);
                }

                .btn-submit,
                .btn-cancel {
                    padding: 8px 16px;
                    border: none;
                    border-radius: 8px;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s ease;
                }

                .btn-submit {
                    background: #A36A66;
                    color: white;
                }

                .btn-cancel {
                    background: #f0f0f0;
                    color: #333;
                }

                .btn-submit:hover {
                    background: #905A57;
                }

                .btn-cancel:hover {
                    background: #e0e0e0;
                }

                .close {
                    color: white;
                    font-size: 24px;
                    font-weight: bold;
                    cursor: pointer;
                    line-height: 1;
                    opacity: 0.8;
                    transition: opacity 0.2s;
                }

                .close:hover {
                    opacity: 1;
                }

                @keyframes customSlideDown {
                    from {
                        opacity: 0;
                        transform: translateY(-30px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            </style>
        </asp:Content>

        <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
            <div class="attendance-container">
                <!-- Tabs Navigation -->
                <div
                    style="display: flex; gap: 10px; margin-bottom: 24px; border-bottom: 2px solid #f1f5f9; padding-bottom: 2px;">
                    <button type="button" onclick="switchTab('attendance-tab')" class="tab-btn active"
                        id="tab-attendance">Attendance Logs</button>
                </div>

                <!-- Attendance Tab Content -->
                <div id="attendance-tab" class="tab-content">
                    <!-- Select Date / Stats Section Area -->
                    <div class="date-selector">
                        <span class="date-text" id="dateDisplay">
                            <%= GetDateDisplay() %>
                        </span>
                        <div class="nav-button" onclick="changeDate(-1)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                        </div>
                        <input type="date" id="datePicker" style="display: none;" onchange="selectDate(this.value)" />
                        <svg class="calendar-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                            onclick="document.getElementById('datePicker').showPicker()" style="cursor: pointer;">
                            <path
                                d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14z" />
                        </svg>
                        <div class="nav-button" onclick="changeDate(1)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                        </div>
                    </div>

                    <div class="stats-container">
                        <div class="stat-card">
                            <div class="stat-number">
                                <%= GetPresentCount() %>
                            </div>
                            <div class="stat-label">Present</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <%= GetAbsentCount() %>
                            </div>
                            <div class="stat-label">Absent</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">
                                <%= GetLateCount() %>
                            </div>
                            <div class="stat-label">Late</div>
                        </div>
                    </div>

                    <!-- Filter & Search Row -->
                    <div class="filter-search-row">
                        <div class="dept-dropdown">
                            <select id="attendanceDeptFilter">
                                <option value="">All Departments</option>
                                <option value="research & development">Research & Development</option>
                                <option value="human resources">Human Resources</option>
                                <option value="finance/accounting">Finance/Accounting</option>
                                <option value="marketing">Marketing</option>
                                <option value="operations">Operations</option>
                                <option value="inventory">Inventory</option>
                                <option value="executive">Executive</option>
                            </select>
                        </div>
                        <div class="search-bar">
                            <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                <path
                                    d="M15.5 14h-.79l-.28-.28C15.41 12.59 16 11.11 16 9.5 16 5.91 12.91 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
                            </svg>
                            <input type="text" class="search-input" id="attendanceSearchInput" placeholder="Search..." />
                        </div>
                    </div>

                    <!-- Attendance Table â€” SLIM, COMPACT, EXACTLY LIKE IMAGE -->
                    <div class="attendance-table-wrapper">
                        <table class="attendance-table">
                            <thead class="table-header">
                                <tr>
                                    <th>Employee No.</th>
                                    <th>Name</th>
                                    <th>Department</th>
                                    <th>Time-In</th>
                                    <th>Time-Out</th>
                                    <th>Late</th>
                                    <th>Absence Allowance</th>
                                </tr>
                            </thead>
                            <tbody id="attendanceTableBody" runat="server">
                                <asp:Repeater ID="rptAttendance" runat="server">
                                    <ItemTemplate>
                                        <tr class="table-row">
                                            <td>
                                                <%# Eval("EmployeeId") %>
                                            </td>
                                            <td>
                                                <%# Eval("EmployeeName") %>
                                            </td>
                                            <td>
                                                <%# Eval("Department") %>
                                            </td>
                                            <td>
                                                <%# FormatTimeIn((DateTime?)Eval("TimeIn")) %>
                                            </td>
                                            <td>
                                                <%# FormatTimeOut((DateTime?)Eval("TimeOut")) %>
                                            </td>
                                            <td style="color: #ef4444; font-weight: 600;">
                                                <%# FormatLateTime((DateTime?)Eval("TimeIn"), (string)Eval("LateTime"))
                                                    %>
                                            </td>
                                            <td>
                                                <%# GetAbsenceAllowance((string)Eval("EmployeeId")) %>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="noRecordsRow" runat="server" class="table-row" style="display: none;">
                                    <td colspan="8" style="text-align: center; padding: 20px; color: #999;">
                                        No attendance records found for this date.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div> <!-- End Attendance Tab Content -->


            </div>

            <!-- Notification Modal -->
            <div id="notificationModal" class="custom-modal-v2">
                <div class="custom-modal-v2-content"
                    style="max-width: 400px; transform: scale(0.95); transition: transform 0.3s ease;">
                    <div id="notificationHeader" class="custom-modal-v2-header">
                        <h2 id="notificationTitle" class="custom-modal-v2-title">Notification</h2>
                        <span class="close" onclick="closeModal('notificationModal')">&times;</span>
                    </div>
                    <div class="custom-modal-v2-body" style="text-align: center; padding: 30px 20px;">
                        <div id="notificationIcon" style="font-size: 48px; margin-bottom: 16px;">âœ…</div>
                        <p id="notificationMessage" style="color: #333; font-size: 15px; margin: 0; line-height: 1.5;">
                        </p>
                    </div>
                    <div class="custom-modal-v2-footer"
                        style="justify-content: center; padding-bottom: 20px; border-top: none;">
                        <button type="button" class="btn-submit" id="btnNotificationOk" style="min-width: 100px;"
                            onclick="closeModal('notificationModal')">OK</button>
                    </div>
                </div>
            </div>

            <!-- Confirm Modal -->
            <div id="confirmModal" class="custom-modal-v2">
                <div class="custom-modal-v2-content"
                    style="max-width: 400px; transform: scale(0.95); transition: transform 0.3s ease;">
                    <div id="confirmHeader" class="custom-modal-v2-header">
                        <h2 id="confirmTitle" class="custom-modal-v2-title">Confirm</h2>
                        <span class="close" onclick="closeModal('confirmModal')">&times;</span>
                    </div>
                    <div class="custom-modal-v2-body" style="text-align: center; padding: 30px 20px;">
                        <div id="confirmIcon" style="font-size: 48px; margin-bottom: 16px;">â“</div>
                        <p id="confirmMessage" style="color: #333; font-size: 15px; margin: 0; line-height: 1.5;"></p>
                    </div>
                    <div class="custom-modal-v2-footer"
                        style="justify-content: center; padding-bottom: 20px; border-top: none; gap: 16px;">
                        <button type="button" class="btn-cancel" style="min-width: 100px;"
                            onclick="closeModal('confirmModal')">Cancel</button>
                        <button type="button" class="btn-submit" id="btnConfirmYes"
                            style="min-width: 100px;">Yes</button>
                    </div>
                </div>
            </div>

            <script>
                function switchTab(tabId) {
                    // Hide all tabs
                    document.querySelectorAll('.tab-content').forEach(tab => {
                        tab.style.display = 'none';
                    });

                    // Remove active class from all buttons
                    document.querySelectorAll('.tab-btn').forEach(btn => {
                        btn.classList.remove('active');
                    });

                    // Show selected tab
                    document.getElementById(tabId).style.display = 'block';

                    // Add active class to clicked button
                    if (tabId === 'attendance-tab') document.getElementById('tab-attendance').classList.add('active');

                    // Save last tab in session storage to persist across postbacks if needed
                    sessionStorage.setItem('activeAttendanceTab', tabId);
                }

                // Persistence for tabs
                document.addEventListener('DOMContentLoaded', function () {
                    const activeTab = sessionStorage.getItem('activeAttendanceTab');
                    if (activeTab) {
                        switchTab(activeTab);
                    }
                });

                function closeModal(modalId) {
                    const modal = document.getElementById(modalId);
                    if (modal) {
                        modal.classList.remove('active');
                    }
                }

                function showNotification(message, isSuccess = true, callback = null) {
                    const modal = document.getElementById('notificationModal');
                    const header = document.getElementById('notificationHeader');
                    const title = document.getElementById('notificationTitle');
                    const icon = document.getElementById('notificationIcon');
                    const messageEl = document.getElementById('notificationMessage');
                    const btn = document.getElementById('btnNotificationOk');

                    messageEl.textContent = message;

                    btn.onclick = function () {
                        closeModal('notificationModal');
                        if (callback && typeof callback === 'function') {
                            callback();
                        }
                    };

                    if (isSuccess) {
                        header.style.background = '#10b981';
                        title.textContent = 'Success';
                        icon.textContent = 'âœ…';
                        btn.style.background = '#10b981';
                    } else {
                        header.style.background = '#ef4444';
                        title.textContent = 'Error';
                        icon.textContent = 'âŒ';
                        btn.style.background = '#ef4444';
                    }

                    modal.classList.add('active');
                }

                function showConfirm(message, titleText = 'Confirm', isDanger = false, onConfirm = null) {
                    const modal = document.getElementById('confirmModal');
                    const header = document.getElementById('confirmHeader');
                    const title = document.getElementById('confirmTitle');
                    const icon = document.getElementById('confirmIcon');
                    const messageEl = document.getElementById('confirmMessage');
                    const btnYes = document.getElementById('btnConfirmYes');

                    messageEl.textContent = message;
                    title.textContent = titleText;

                    if (isDanger) {
                        header.style.background = '#ef4444';
                        icon.textContent = 'âš ï¸';
                        btnYes.style.background = '#ef4444';
                        btnYes.textContent = 'Proceed';
                    } else {
                        header.style.background = '#A36A66';
                        icon.textContent = 'â“';
                        btnYes.style.background = '#A36A66';
                        btnYes.textContent = 'Yes';
                    }

                    btnYes.onclick = function () {
                        closeModal('confirmModal');
                        if (onConfirm && typeof onConfirm === 'function') {
                            onConfirm();
                        }
                    };

                    modal.classList.add('active');
                }

                function changeDate(days) {
                    // Read the current date from the display
                    var dateText = document.getElementById('dateDisplay').textContent.trim();
                    var currentDate = new Date(dateText);

                    // If invalid, fallback to today
                    if (isNaN(currentDate.getTime())) {
                        currentDate = new Date();
                    }

                    // Add or subtract days
                    currentDate.setDate(currentDate.getDate() + days);

                    // Format YYYY-MM-DD
                    var formatted =
                        currentDate.getFullYear() + '-' +
                        String(currentDate.getMonth() + 1).padStart(2, '0') + '-' +
                        String(currentDate.getDate()).padStart(2, '0');

                    // Create form
                    var form = document.createElement('form');
                    form.method = 'POST';
                    form.action = window.location.pathname;

                    // Send selected date
                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'dateSelect';
                    input.value = formatted;
                    form.appendChild(input);

                    document.body.appendChild(form);
                    form.submit();
                }

                function selectDate(dateString) {
                    // Create a form and submit it to select the date
                    var form = document.createElement('form');
                    form.method = 'POST';
                    form.action = window.location.pathname;

                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'dateSelect';
                    input.value = dateString;
                    form.appendChild(input);

                    document.body.appendChild(form);
                    form.submit();
                }

                // Set the date picker value to match the current selected date
                document.addEventListener('DOMContentLoaded', function () {
                    var dateDisplay = document.getElementById('dateDisplay');
                    if (dateDisplay) {
                        var dateText = dateDisplay.textContent.trim();
                        // Parse the date text (e.g., "September 26, 2025")
                        var date = new Date(dateText);
                        if (!isNaN(date.getTime())) {
                            var datePicker = document.getElementById('datePicker');
                            if (datePicker) {
                                // Format as YYYY-MM-DD for the date input
                                var year = date.getFullYear();
                                var month = String(date.getMonth() + 1).padStart(2, '0');
                                var day = String(date.getDate()).padStart(2, '0');
                                datePicker.value = year + '-' + month + '-' + day;
                            }
                        }
                    }

                    const deptFilter = document.getElementById('attendanceDeptFilter');
                    const searchInput = document.getElementById('attendanceSearchInput');
                    const tableBody = document.getElementById('<%= attendanceTableBody.ClientID %>');

                    function applyAttendanceFilters() {
                        if (!tableBody) return;

                        function normalizeDepartment(value) {
                            const v = (value || '').toString().trim().toLowerCase();
                            if (v === 'r&d' || v === 'research and development' || v === 'research & development') {
                                return 'research & development';
                            }
                            if (v === 'hr' || v === 'human resources') return 'human resources';
                            if (v === 'finance' || v === 'finance/accounting') return 'finance/accounting';
                            return v;
                        }

                        const selectedDept = (deptFilter ? deptFilter.value : '').toLowerCase().trim();
                        const searchTerm = (searchInput ? searchInput.value : '').toLowerCase().trim();
                        const rows = tableBody.querySelectorAll('tr.table-row');

                        rows.forEach(row => {
                            if (row.id === 'noRecordsRow') return;

                            const rowText = (row.textContent || '').toLowerCase();
                            const deptCell = row.cells && row.cells[2] ? normalizeDepartment(row.cells[2].textContent) : '';

                            const matchesDept = !selectedDept || deptCell === normalizeDepartment(selectedDept);
                            const matchesSearch = !searchTerm || rowText.includes(searchTerm);

                            row.style.display = (matchesDept && matchesSearch) ? '' : 'none';
                        });
                    }

                    if (deptFilter) deptFilter.addEventListener('change', applyAttendanceFilters);
                    if (searchInput) searchInput.addEventListener('input', applyAttendanceFilters);
                });

                const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';


            </script>
        </asp:Content>