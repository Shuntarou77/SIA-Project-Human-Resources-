<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true" CodeBehind="Attendance.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm3" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --bg-color: #f9e6eb; /* Soft pink background */
            --panel-bg: #ffffff;
            --stat-bg: #b85c6a; /* Maroon stat cards */
            --text-dark: #333333;
            --text-light: #ffffff;
            --border-color: #e0e0e0;
            --hover-bg: #fafafa;
        }

        html, body {
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
        }

        .attendance-container .attendance-table {
            margin-top: 0;
            margin-bottom: 0;
        }

        /* Ensure table doesn't expand unnecessarily */
        .attendance-table tbody {
            display: table-row-group;
        }

        .attendance-table thead {
            display: table-header-group;
        }

        .header-panel {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            padding: 16px 20px;
            background-color: var(--panel-bg);
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .date-selector {
            display: flex;
            align-items: center;
            gap: 12px;
            background-color: #f5f5f5;
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
            cursor: pointer;
            transition: fill 0.2s;
        }

        .calendar-icon:hover {
            fill: var(--stat-bg);
        }

        /* Calendar Popup */
        .calendar-popup {
            display: none;
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
            z-index: 1000;
            padding: 16px;
            min-width: 280px;
        }

        .calendar-popup.show {
            display: block;
        }

        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .calendar-nav-btn {
            background: none;
            border: none;
            font-size: 18px;
            cursor: pointer;
            color: var(--text-dark);
            padding: 4px 8px;
            border-radius: 4px;
            transition: background 0.2s;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .calendar-nav-btn:hover {
            background: #f5f5f5;
        }

        .calendar-month-year {
            font-weight: 600;
            font-size: 16px;
            color: var(--text-dark);
        }

        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 4px;
        }

        .calendar-day-header {
            text-align: center;
            font-size: 12px;
            font-weight: 600;
            color: #666;
            padding: 8px 4px;
        }

        .calendar-day {
            text-align: center;
            padding: 10px;
            cursor: pointer;
            border-radius: 6px;
            font-size: 14px;
            transition: all 0.2s;
            border: 1px solid transparent;
        }

        .calendar-day:hover {
            background: #f5f5f5;
        }

        .calendar-day.today {
            background: #e8f5e9;
            color: var(--stat-bg);
            font-weight: 600;
        }

        .calendar-day.selected {
            background: var(--stat-bg);
            color: white;
            font-weight: 600;
        }

        .calendar-day.other-month {
            color: #ccc;
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
            opacity: 0.9;
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

        /* Attendance Table — COMPACT AND PROPERLY SPACED */
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            background-color: var(--panel-bg);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            table-layout: auto;
        }

        .table-header {
            background-color: var(--panel-bg);
            border-bottom: 2px solid var(--border-color);
        }

        .table-header th {
            padding: 8px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 13px;
            white-space: nowrap;
        }

        .table-header th:first-child {
            padding-left: 16px;
        }

        .table-header th:last-child {
            padding-right: 16px;
        }

        .table-row {
            border-bottom: 1px solid var(--border-color);
        }

        .table-row:last-child {
            border-bottom: none;
        }

        .table-row td {
            padding: 8px 12px;
            color: var(--text-dark);
            font-size: 13px;
            vertical-align: middle;
        }

        .table-row td:first-child {
            padding-left: 16px;
        }

        .table-row td:last-child {
            padding-right: 16px;
        }

        .table-row:hover {
            background-color: var(--hover-bg);
        }

        tbody {
            display: table-row-group;
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
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="attendance-container">
        <!-- Header Panel -->
        <div class="header-panel">
            <div class="date-selector" style="position: relative;">
                <div class="nav-button" onclick="changeDate(-1); return false;">‹</div>
                <span class="date-text"><%= GetDateDisplay() %></span>
                <svg class="calendar-icon" onclick="toggleCalendar(); return false;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14z"/>
                </svg>
                <div class="nav-button" onclick="changeDate(1); return false;">›</div>
                
                <!-- Calendar Popup -->
                <div id="calendarPopup" class="calendar-popup">
                    <div class="calendar-header">
                        <button class="calendar-nav-btn" onclick="changeCalendarMonth(-1)">‹</button>
                        <span class="calendar-month-year" id="calendarMonthYear"></span>
                        <button class="calendar-nav-btn" onclick="changeCalendarMonth(1)">›</button>
                    </div>
                    <div class="calendar-grid" id="calendarGrid"></div>
                </div>
            </div>

            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number"><%= GetPresentCount() %></div>
                    <div class="stat-label">Present</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= GetAbsentCount() %></div>
                    <div class="stat-label">Absent</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= GetLateCount() %></div>
                    <div class="stat-label">Late</div>
                </div>
            </div>
        </div>

        <!-- Filter & Search Row -->
        <div class="filter-search-row">
            <div class="dept-dropdown">
                <select id="departmentFilter" onchange="filterAttendance()">
                    <option value="">Select Department</option>
                    <option value="Human Resources">Human Resources</option>
                    <option value="Finance">Finance</option>
                    <option value="IT Support">IT Support</option>
                    <option value="Marketing">Marketing</option>
                    <option value="Sales">Sales</option>
                    <option value="Operations">Operations</option>
                    <option value="Legal">Legal</option>
                    <option value="Research & Development">Research & Development</option>
                    <option value="Quality Control">Quality Control</option>
                    <option value="Customer Service">Customer Service</option>
                </select>
            </div>
            <div class="search-bar">
                <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M15.5 14h-.79l-.28-.28C15.41 12.59 16 11.11 16 9.5 16 5.91 12.91 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                </svg>
                <input type="text" id="searchInput" class="search-input" placeholder="Search..." oninput="filterAttendance()" />
            </div>
        </div>

        <!-- Attendance Table — SLIM, COMPACT, EXACTLY LIKE IMAGE -->
        <table class="attendance-table">
            <thead class="table-header">
                <tr>
                    <th>Employee No.</th>
                    <th>Name</th>
                    <th>Department</th>
                    <th>Time-In</th>
                    <th>Time-Out</th>
                </tr>
            </thead>
            <tbody id="attendanceTableBody">
                <% if (AttendanceRecords != null && AttendanceRecords.Count > 0) { %>
                    <% foreach (var record in AttendanceRecords) { %>
                        <tr class="table-row" 
                            data-employee-id="<%= Server.HtmlEncode(record.EmployeeId ?? "") %>"
                            data-employee-name="<%= Server.HtmlEncode(record.EmployeeName ?? "") %>"
                            data-department="<%= Server.HtmlEncode(record.Department ?? "") %>">
                            <td><%= Server.HtmlEncode(record.EmployeeId ?? "-") %></td>
                            <td><%= Server.HtmlEncode(record.EmployeeName ?? "-") %></td>
                            <td><%= Server.HtmlEncode(record.Department ?? "-") %></td>
                            <td><%= FormatTime(record.TimeIn) %></td>
                            <td><%= FormatTime(record.TimeOut) %></td>
                        </tr>
                    <% } %>
                <% } else { %>
                    <tr class="table-row">
                        <td colspan="5" style="text-align: center; padding: 16px; color: #999;">
                            No attendance records found for this date.
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <script>
        // Store all attendance records for filtering
        let allAttendanceRecords = [];
        
        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Store all rows in memory for filtering
            const tableBody = document.getElementById('attendanceTableBody');
            if (tableBody) {
                const rows = Array.from(tableBody.querySelectorAll('tr.table-row'));
                // Only store rows that have data attributes (exclude "no records" rows)
                allAttendanceRecords = rows
                    .filter(row => row.getAttribute('data-employee-id') !== null)
                    .map(row => ({
                        element: row,
                        employeeId: row.getAttribute('data-employee-id') || '',
                        employeeName: row.getAttribute('data-employee-name') || '',
                        department: row.getAttribute('data-department') || ''
                    }));
            }
            
            // Initial filter (to handle any initial state)
            filterAttendance();
        });

        function filterAttendance() {
            const departmentFilter = document.getElementById('departmentFilter');
            const searchInput = document.getElementById('searchInput');
            const tableBody = document.getElementById('attendanceTableBody');
            
            if (!tableBody || allAttendanceRecords.length === 0) return;
            
            const selectedDepartment = departmentFilter ? departmentFilter.value.trim() : '';
            const searchTerm = searchInput ? searchInput.value.toLowerCase().trim() : '';
            
            let visibleCount = 0;
            let presentCount = 0;
            let lateCount = 0;
            
            // Filter and show/hide rows
            allAttendanceRecords.forEach(record => {
                const row = record.element;
                const department = (record.department || '').trim();
                const employeeId = (record.employeeId || '').toLowerCase();
                const employeeName = (record.employeeName || '').toLowerCase();
                
                // Check if row matches filters
                const matchesDepartment = !selectedDepartment || department === selectedDepartment;
                const matchesSearch = !searchTerm || 
                    employeeId.includes(searchTerm) || 
                    employeeName.includes(searchTerm) ||
                    department.toLowerCase().includes(searchTerm);
                
                if (matchesDepartment && matchesSearch) {
                    row.style.display = '';
                    visibleCount++;
                    
                    // Check if timed in (has time-in data)
                    const timeInCell = row.querySelector('td:nth-child(4)');
                    if (timeInCell && timeInCell.textContent.trim() !== '-') {
                        presentCount++;
                        
                        // Check if late (time-in after 9:00 AM)
                        const timeInText = timeInCell.textContent.trim();
                        const timeMatch = timeInText.match(/(\d+):(\d+)\s*(AM|PM)/i);
                        if (timeMatch) {
                            let hour = parseInt(timeMatch[1]);
                            const minute = parseInt(timeMatch[2]);
                            const period = timeMatch[3].toUpperCase();
                            
                            if (period === 'PM' && hour !== 12) hour += 12;
                            if (period === 'AM' && hour === 12) hour = 0;
                            
                            if (hour > 9 || (hour === 9 && minute > 0)) {
                                lateCount++;
                            }
                        }
                    }
                } else {
                    row.style.display = 'none';
                }
            });
            
            // Update statistics
            updateStatistics(visibleCount, presentCount, lateCount);
            
            // Show "no results" message if no rows visible
            if (visibleCount === 0 && allAttendanceRecords.length > 0) {
                // Check if "no results" row already exists
                let noResults = tableBody.querySelector('tr.no-results-row');
                if (!noResults) {
                    noResults = document.createElement('tr');
                    noResults.className = 'table-row no-results-row';
                    noResults.innerHTML = '<td colspan="5" style="text-align: center; padding: 16px; color: #999;">No records match the selected filters.</td>';
                    tableBody.appendChild(noResults);
                }
                noResults.style.display = '';
            } else {
                // Hide "no results" row if there are visible records
                const noResults = tableBody.querySelector('tr.no-results-row');
                if (noResults) {
                    noResults.style.display = 'none';
                }
                
                // Also hide the original "no records" message if it exists
                const originalNoRecords = tableBody.querySelector('tr.table-row:not([data-employee-id])');
                if (originalNoRecords && visibleCount > 0) {
                    originalNoRecords.style.display = 'none';
                }
            }
        }

        function updateStatistics(total, present, late) {
            // Update stat cards
            const statCards = document.querySelectorAll('.stat-card .stat-number');
            if (statCards.length >= 3) {
                statCards[0].textContent = present;
                statCards[1].textContent = Math.max(0, total - present); // Approximate absent count
                statCards[2].textContent = late;
            }
        }

        // Date navigation and calendar
        let calendarViewDate = null;
        let currentSelectedDate = null;

        // Initialize date from server
        document.addEventListener('DOMContentLoaded', function() {
            const serverDateStr = '<%= SelectedDate.ToString("yyyy-MM-dd") %>';
            const [year, month, day] = serverDateStr.split('-').map(Number);
            currentSelectedDate = new Date(year, month - 1, day);
            calendarViewDate = new Date(currentSelectedDate);
        });

        function changeDate(days) {
            try {
                // Create a form and submit to change date
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = window.location.href;
                form.style.display = 'none';
                
                // Add ViewState and other necessary fields if they exist
                var viewStateField = document.querySelector('input[name="__VIEWSTATE"]');
                if (viewStateField) {
                    var viewStateInput = document.createElement('input');
                    viewStateInput.type = 'hidden';
                    viewStateInput.name = '__VIEWSTATE';
                    viewStateInput.value = viewStateField.value;
                    form.appendChild(viewStateInput);
                }
                
                var eventValidationField = document.querySelector('input[name="__EVENTVALIDATION"]');
                if (eventValidationField) {
                    var eventValidationInput = document.createElement('input');
                    eventValidationInput.type = 'hidden';
                    eventValidationInput.name = '__EVENTVALIDATION';
                    eventValidationInput.value = eventValidationField.value;
                    form.appendChild(eventValidationInput);
                }
                
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'dateChange';
                input.value = days.toString();
                form.appendChild(input);
                
                document.body.appendChild(form);
                
                console.log('Submitting date change:', days);
                form.submit();
                return false;
            } catch (error) {
                console.error('Error changing date:', error);
                // Fallback: use window.location with query string
                var currentUrl = window.location.href.split('?')[0];
                window.location.href = currentUrl + '?dateChange=' + days;
                return false;
            }
        }

        function toggleCalendar() {
            const popup = document.getElementById('calendarPopup');
            if (!popup) return;
            
            if (popup.classList.contains('show')) {
                popup.classList.remove('show');
            } else {
                // Refresh current date from server
                const serverDateStr = '<%= SelectedDate.ToString("yyyy-MM-dd") %>';
                const [year, month, day] = serverDateStr.split('-').map(Number);
                currentSelectedDate = new Date(year, month - 1, day);
                calendarViewDate = new Date(currentSelectedDate);
                renderCalendar();
                popup.classList.add('show');
            }
        }

        function changeCalendarMonth(direction) {
            if (!calendarViewDate) {
                const serverDateStr = '<%= SelectedDate.ToString("yyyy-MM-dd") %>';
                const [year, month, day] = serverDateStr.split('-').map(Number);
                calendarViewDate = new Date(year, month - 1, day);
            }
            calendarViewDate.setMonth(calendarViewDate.getMonth() + direction);
            renderCalendar();
        }

        function renderCalendar() {
            const monthYearEl = document.getElementById('calendarMonthYear');
            const gridEl = document.getElementById('calendarGrid');
            
            if (!monthYearEl || !gridEl || !calendarViewDate) return;
            
            const month = calendarViewDate.getMonth();
            const year = calendarViewDate.getFullYear();
            
            const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'];
            monthYearEl.textContent = monthNames[month] + ' ' + year;
            
            gridEl.innerHTML = '';
            
            // Day headers
            const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            dayHeaders.forEach(day => {
                const header = document.createElement('div');
                header.className = 'calendar-day-header';
                header.textContent = day;
                gridEl.appendChild(header);
            });
            
            // Get month info
            const firstDay = new Date(year, month, 1);
            const lastDay = new Date(year, month + 1, 0);
            const daysInMonth = lastDay.getDate();
            const startingDayOfWeek = firstDay.getDay();
            
            // Empty cells for days before month starts
            for (let i = 0; i < startingDayOfWeek; i++) {
                const empty = document.createElement('div');
                empty.className = 'calendar-day other-month';
                gridEl.appendChild(empty);
            }
            
            // Today's date (local device date)
            const today = new Date();
            const todayYear = today.getFullYear();
            const todayMonth = today.getMonth();
            const todayDay = today.getDate();
            
            // Selected date (from server)
            const selectedYear = currentSelectedDate ? currentSelectedDate.getFullYear() : todayYear;
            const selectedMonth = currentSelectedDate ? currentSelectedDate.getMonth() : todayMonth;
            const selectedDay = currentSelectedDate ? currentSelectedDate.getDate() : todayDay;
            
            // Days of month
            for (let day = 1; day <= daysInMonth; day++) {
                const dayEl = document.createElement('div');
                dayEl.className = 'calendar-day';
                dayEl.textContent = day;
                
                // Check if today
                const isToday = (year === todayYear && month === todayMonth && day === todayDay);
                // Check if selected date
                const isSelected = (year === selectedYear && month === selectedMonth && day === selectedDay);
                
                if (isToday && !isSelected) {
                    dayEl.classList.add('today');
                }
                
                if (isSelected) {
                    dayEl.classList.add('selected');
                }
                
                // Click handler
                dayEl.onclick = function() {
                    selectDate(year, month, day);
                };
                
                gridEl.appendChild(dayEl);
            }
            
            // Add days from next month to fill the grid
            const totalCells = startingDayOfWeek + daysInMonth;
            const remainingCells = 42 - totalCells; // 6 rows * 7 days
            for (let day = 1; day <= remainingCells && day <= 14; day++) {
                const dayEl = document.createElement('div');
                dayEl.className = 'calendar-day other-month';
                dayEl.textContent = day;
                gridEl.appendChild(dayEl);
            }
        }

        function selectDate(year, month, day) {
            const selectedDate = new Date(year, month, day);
            const dateStr = year + '-' + 
                String(month + 1).padStart(2, '0') + '-' + 
                String(day).padStart(2, '0');
            
            // Close popup
            const popup = document.getElementById('calendarPopup');
            if (popup) {
                popup.classList.remove('show');
            }
            
            // Submit form with selected date
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = window.location.href;
            
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'dateSelect';
            input.value = dateStr;
            form.appendChild(input);
            
            document.body.appendChild(form);
            form.submit();
        }

        // Close calendar when clicking outside
        document.addEventListener('click', function(event) {
            const popup = document.getElementById('calendarPopup');
            const icon = document.querySelector('.calendar-icon');
            const dateSelector = document.querySelector('.date-selector');
            
            if (popup && dateSelector && 
                !dateSelector.contains(event.target) && 
                popup.classList.contains('show')) {
                popup.classList.remove('show');
            }
        });

        // Auto-refresh every 30 seconds to get latest attendance data
        setTimeout(function() {
            window.location.reload();
        }, 30000);
    </script>
</asp:Content>