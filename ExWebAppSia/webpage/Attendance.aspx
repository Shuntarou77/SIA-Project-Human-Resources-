<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Attendance.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm3" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            :root {
                --bg-color: #ffffff;
                /* ✅ Pure white background */
                --panel-bg: #ffffff;
                --stat-bg: #A36A66;
                /* ✅ Unified accent color */
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
                margin: 4px 0 0;
                opacity: 0.95;
                text-transform: uppercase;
                letter-spacing: 0.5px;
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

            /* Attendance Table — SLIM & CLEAN */
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

            /* Optional enhancement: highlight present/absent in table (if needed later) */
            /* .status-present { color: #2e7d32; }
        .status-absent { color: #c62828; }
        .status-late { color: #f57c00; } */

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
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="attendance-container">
            <!-- Header Panel -->
            <div class="header-panel">
                <div class="date-selector">
                    <span class="date-text" id="dateDisplay">
                        <%= GetDateDisplay() %>
                    </span>
                    <div class="nav-button" onclick="changeDate(-1)">‹</div>
                    <input type="date" id="datePicker" style="display: none;" onchange="selectDate(this.value)" />
                    <svg class="calendar-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                        onclick="document.getElementById('datePicker').showPicker()" style="cursor: pointer;">
                        <path
                            d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14z" />
                    </svg>
                    <div class="nav-button" onclick="changeDate(1)">›</div>
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
            </div>

            <!-- Filter & Search Row -->
            <div class="filter-search-row">
                <div class="dept-dropdown">
                    <select>
                        <option value="">Select Department</option>
                        <option value="hr">Human Resources</option>
                        <option value="finance">Finance</option>
                        <option value="it">IT Support</option>
                        <option value="marketing">Marketing</option>
                        <option value="sales">Sales</option>
                        <option value="operations">Operations</option>
                        <option value="legal">Legal</option>
                        <option value="r&d">Research & Development</option>
                        <option value="quality">Quality Control</option>
                        <option value="customer">Customer Service</option>
                    </select>
                </div>
                <div class="search-bar">
                    <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path
                            d="M15.5 14h-.79l-.28-.28C15.41 12.59 16 11.11 16 9.5 16 5.91 12.91 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
                    </svg>
                    <input type="text" class="search-input" placeholder="Search..." />
                </div>
            </div>

            <!-- Attendance Table — SLIM, COMPACT, EXACTLY LIKE IMAGE -->
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
                                        <%# Eval("LateTime") %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        <tr id="noRecordsRow" runat="server" class="table-row" style="display: none;">
                            <td colspan="5" style="text-align: center; padding: 20px; color: #999;">
                                No attendance records found for this date.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
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
            });
        </script>
    </asp:Content>