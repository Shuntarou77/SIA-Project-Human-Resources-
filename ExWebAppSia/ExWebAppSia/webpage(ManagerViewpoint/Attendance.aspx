<%@ Page Title="Time Tracking" Language="C#" MasterPageFile="~/webpage(ManagerViewpoint/ManagerHR.Master" AutoEventWireup="true" Async="true" CodeBehind="WebForm3.aspx.cs" Inherits="ExWebAppSia.webpage_ManagerViewpoint.WebForm3" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
       :root {
    --primary-color: #A36A66;          /* ✅ Main brand */
    --secondary-color: #C49A99;        /* Lighter tint */
    --accent-color: #F8ECEB;           /* Soft warm neutral */
    --card-shadow: 0 10px 30px rgba(163, 106, 102, 0.15);
    --hover-shadow: 0 15px 40px rgba(163, 106, 102, 0.25);
    --border-radius: 20px;
    --text-primary: #4A3534;           /* Warmer dark */
    --text-secondary: #6B4F4E;
    --text-muted: #9B7D7B;
    --success-color: #10b981;
    --warning-color: #f59e0b;
    --danger-color: #ef4444;
    --border-color: #D8BFBF;           /* Harmonious neutral */
}

        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
        }

        .time-tracking-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .main-grid {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }

        /* Employee Profile Card */
        .profile-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .profile-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }

        .profile-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            padding: 20px 16px;
            text-align: center;
            color: white;
        }

        .profile-avatar {
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

        .profile-name {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .profile-position {
            font-size: 14px;
            opacity: 0.9;
        }

        .profile-body {
            padding: 16px;
        }

        .info-row {
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .info-value {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            text-align: right;
        }

        /* Current Status Card */
        .status-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            padding: 24px;
            margin-bottom: 24px;
        }

        .status-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .card-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-badge.clocked-in {
            background: #d1fae5;
            color: var(--success-color);
        }

        .status-badge.clocked-out {
            background: #fee2e2;
            color: var(--danger-color);
        }

        .status-badge.on-break {
            background: #fef3c7;
            color: var(--warning-color);
        }

        .time-display {
            text-align: center;
            padding: 30px;
            background: linear-gradient(135deg, var(--accent-color), #FFF5F5);
            border-radius: 16px;
            margin-bottom: 24px;
        }

        .current-time {
            font-size: 48px;
            font-weight: 800;
            color: var(--primary-color);
            margin-bottom: 8px;
            font-family: 'Courier New', monospace;
        }

        .current-date {
            font-size: 16px;
            color: var(--text-secondary);
            font-weight: 600;
        }

        .time-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .time-info-box {
            background: var(--accent-color);
            padding: 20px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }

        .time-info-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .time-info-value {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary-color);
        }

        /* Action Buttons */
        .action-buttons {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .btn-clock {
            padding: 16px 24px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-clock-in {
            background: linear-gradient(135deg, var(--success-color), #059669);
            color: white;
        }

        .btn-clock-out {
            background: linear-gradient(135deg, var(--danger-color), #dc2626);
            color: white;
        }

        .btn-break {
            background: linear-gradient(135deg, var(--warning-color), #d97706);
            color: white;
        }

        .btn-clock:hover:not(:disabled) {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .btn-clock:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Today's Activity */
        .activity-section {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            padding: 24px;
            margin-bottom: 24px;
        }

        .activity-timeline {
            position: relative;
            padding-left: 40px;
            margin-top: 20px;
        }

        .activity-timeline::before {
            content: '';
            position: absolute;
            left: 15px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--border-color);
        }

        .activity-item {
            position: relative;
            padding: 16px 20px;
            background: var(--accent-color);
            border-radius: 12px;
            margin-bottom: 16px;
            border-left: 4px solid var(--primary-color);
        }

        .activity-item::before {
            content: '';
            position: absolute;
            left: -29px;
            top: 20px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--primary-color);
            border: 3px solid white;
        }

        .activity-time {
            font-size: 14px;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 4px;
        }

        .activity-type {
            font-size: 13px;
            color: var(--text-secondary);
            font-weight: 600;
        }

        /* Weekly Summary */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .summary-box {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            padding: 24px;
            text-align: center;
            transition: all 0.3s ease;
        }

        .summary-box:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }

        .summary-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            font-size: 24px;
            color: white;
        }

        .summary-value {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary-color);
            margin-bottom: 8px;
        }

        .summary-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
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

        .form-textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s ease;
            resize: vertical;
            min-height: 100px;
        }

        .form-textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(164, 79, 86, 0.1);
        }

        /* History Table */
        .history-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .history-table th {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
        }

        .history-table th:first-child {
            border-radius: 10px 0 0 0;
        }

        .history-table th:last-child {
            border-radius: 0 10px 0 0;
        }

        .history-table td {
            padding: 12px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
            color: var(--text-primary);
        }

        .history-table tr:hover {
            background: var(--accent-color);
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .main-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .time-info-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                grid-template-columns: 1fr;
            }

            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="time-tracking-container">
        <div class="main-grid">
            <!-- Left: Manager Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar"><%= GetManagerInitials() %></div>
                    <div class="profile-name"><%= GetManagerName() %></div>
                    <div class="profile-position"><%= GetManagerRole() %></div>
                </div>
                <div class="profile-body">
                    <div class="info-row">
                        <span class="info-label">🆔 Manager ID</span>
                        <span class="info-value"><%= GetManagerId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">🏢 Department</span>
                        <span class="info-value"><%= GetManagerDepartment() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">⏰ Shift</span>
                        <span class="info-value">8:00 AM - 5:00 PM</span>
                    </div>
                </div>
            </div>

            <!-- Right: Current Status Card -->
            <div class="status-card">
                <div class="status-header">
                   <h2 class="card-title">⏱️ Time In / Time Out</h2>
                   <span class="status-badge clocked-out" id="statusBadge">Not Clocked In</span>
                </div>

                <div class="time-display">
                    <div class="current-time" id="currentTime">00:00:00</div>
                    <div class="current-date" id="currentDate">Wednesday, November 12, 2025</div>
                </div>

                <div class="time-info-grid">
                    <div class="time-info-box">
                        <div class="time-info-label">Time In</div>
                        <div class="time-info-value" id="timeIn">08:05 AM</div>
                    </div>
                    <div class="time-info-box">
                        <div class="time-info-label">Time Out</div>
                        <div class="time-info-value" id="timeOut">--:-- --</div>
                    </div>
                    <div class="time-info-box">
                        <div class="time-info-label">Hours Worked</div>
                        <div class="time-info-value" id="hoursWorked">3:42</div>
                    </div>
                    <div class="time-info-box">
                        <div class="time-info-label">Break Time</div>
                        <div class="time-info-value" id="breakTime">0:30</div>
                    </div>
                </div>

                <div class="action-buttons">
                   <button class="btn-clock btn-clock-in" id="btnClockIn" onclick="clockIn()">
    ▶️ Time In
</button>
<button class="btn-clock btn-clock-out" id="btnClockOut" onclick="clockOut()" disabled>
    ⏹️ Time Out
</button>
                </div>
            </div>
        </div>

        <!-- Weekly Summary -->
        <div class="summary-section">
            <h2 class="card-title" style="margin-bottom: 20px;">📊 Weekly Summary</h2>
            <div class="summary-grid">
                <div class="summary-box">
                    <div class="summary-icon">⏰</div>
                    <div class="summary-value"><%= GetWeeklyHoursWorked() %></div>
                    <div class="summary-label">Hours Worked</div>
                </div>
                <div class="summary-box">
                    <div class="summary-icon">✅</div>
                    <div class="summary-value"><%= GetWeeklyDaysPresent() %></div>
                    <div class="summary-label">Days Present</div>
                </div>
                <div class="summary-box">
                    <div class="summary-icon">⏱️</div>
                    <div class="summary-value"><%= GetWeeklyTimesLate() %></div>
                    <div class="summary-label">Times Late</div>
                </div>
                <div class="summary-box">
                    <div class="summary-icon">☕</div>
                    <div class="summary-value"><%= GetWeeklyBreakHours() %></div>
                    <div class="summary-label">Break Hours</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Break Modal -->
    <div id="breakModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('breakModal')">&times;</span>
                <h2 class="modal-title">☕ Start Break</h2>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Break Reason (Optional)</label>
                    <textarea class="form-textarea" placeholder="Lunch break, coffee break, etc..." id="breakReason"></textarea>
                </div>
                <p style="color: var(--text-secondary); font-size: 14px;">
                    ⚠️ Remember to end your break when you return to work.
                </p>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" onclick="closeModal('breakModal')">Cancel</button>
                <button class="btn-submit" onclick="startBreak()">Start Break</button>
            </div>
        </div>
    </div>

    <!-- History Modal -->
    <div id="historyModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeModal('historyModal')">&times;</span>
                <h2 class="modal-title">📊 Attendance History</h2>
            </div>
            <div class="modal-body">
                <table class="history-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Time In</th>
                            <th>Time Out</th>
                            <th>Hours</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Nov 11, 2025</td>
                            <td>08:02 AM</td>
                            <td>05:15 PM</td>
                            <td>8.2 hrs</td>
                            <td style="color: var(--success-color); font-weight: 600;">✓ On Time</td>
                        </tr>
                        <tr>
                            <td>Nov 08, 2025</td>
                            <td>08:15 AM</td>
                            <td>05:05 PM</td>
                            <td>7.8 hrs</td>
                            <td style="color: var(--warning-color); font-weight: 600;">⚠ Late</td>
                        </tr>
                        <tr>
                            <td>Nov 07, 2025</td>
                            <td>07:58 AM</td>
                            <td>05:10 PM</td>
                            <td>8.2 hrs</td>
                            <td style="color: var(--success-color); font-weight: 600;">✓ On Time</td>
                        </tr>
                        <tr>
                            <td>Nov 06, 2025</td>
                            <td>08:00 AM</td>
                            <td>05:00 PM</td>
                            <td>8.0 hrs</td>
                            <td style="color: var(--success-color); font-weight: 600;">✓ On Time</td>
                        </tr>
                        <tr>
                            <td>Nov 05, 2025</td>
                            <td>08:20 AM</td>
                            <td>05:12 PM</td>
                            <td>7.9 hrs</td>
                            <td style="color: var(--warning-color); font-weight: 600;">⚠ Late</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" onclick="closeModal('historyModal')">Close</button>
                <button class="btn-submit">Export to PDF</button>
            </div>
        </div>
    </div>

    <script>
        // Manager data from server
        const managerId = '<%= GetManagerId() %>';
        const managerName = '<%= GetManagerName() %>';
        const managerDepartment = '<%= GetManagerDepartment() %>';
        const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
        
        // Load attendance status from server
        const attendanceStatus = <%= AttendanceStatusJson %>;
        console.log('Attendance Status:', attendanceStatus);
        console.log('Handler URL:', handlerUrl);
        console.log('Manager ID:', managerId);
        console.log('Manager Name:', managerName);
        console.log('Department:', managerDepartment);

        // State flags - initialize from server data
        let hasTimedIn = attendanceStatus.hasTimedIn || false;
        let hasTimedOut = attendanceStatus.hasTimedOut || false;

        // Update current time and date
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('en-US', { hour12: false });
            document.getElementById('currentTime').textContent = timeString;
            
            const dateOptions = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            document.getElementById('currentDate').textContent = now.toLocaleDateString('en-US', dateOptions);
        }

        setInterval(updateTime, 1000);
        updateTime();

        // Load today's attendance status on page load
        function loadTodayStatus() {
            try {
                const statusBadge = document.getElementById('statusBadge');
                const btnClockIn = document.getElementById('btnClockIn');
                const btnClockOut = document.getElementById('btnClockOut');
                const timeInEl = document.getElementById('timeIn');
                const timeOutEl = document.getElementById('timeOut');

                // Update UI based on server-side status
                if (attendanceStatus.hasTimedIn) {
                    hasTimedIn = true;
                    const timeInStr = attendanceStatus.timeIn || 'earlier today';
                    timeInEl.textContent = timeInStr;
                    statusBadge.textContent = 'Time In';
                    statusBadge.className = 'status-badge clocked-in';
                    btnClockIn.disabled = true;
                    
                    if (attendanceStatus.hasTimedOut) {
                        hasTimedOut = true;
                        const timeOutStr = attendanceStatus.timeOut || 'earlier today';
                        timeOutEl.textContent = timeOutStr;
                        statusBadge.textContent = 'Time Out';
                        statusBadge.className = 'status-badge clocked-out';
                        btnClockOut.disabled = true;
                    } else {
                        btnClockOut.disabled = false;
                    }
                } else {
                    timeInEl.textContent = '--:-- --';
                    timeOutEl.textContent = '--:-- --';
                    statusBadge.textContent = 'Not Clocked In';
                    statusBadge.className = 'status-badge clocked-out';
                    btnClockIn.disabled = false;
                    btnClockOut.disabled = true;
                }
                
                console.log('Status loaded - hasTimedIn:', hasTimedIn, 'hasTimedOut:', hasTimedOut);
            } catch (error) {
                console.error('Error loading attendance status:', error);
            }
        }

        // Initialize on page load
        window.addEventListener('DOMContentLoaded', function() {
            loadTodayStatus();
        });

        // Time In Function
        async function clockIn() {
            if (hasTimedIn) {
                alert('You have already timed in today.');
                return;
            }

            if (!managerId || managerId === 'N/A') {
                alert('Manager ID not found. Please contact HR.');
                return;
            }

            const btnClockIn = document.getElementById('btnClockIn');
            const btnClockOut = document.getElementById('btnClockOut');
            const statusBadge = document.getElementById('statusBadge');
            const timeInEl = document.getElementById('timeIn');

            // Disable button during request
            btnClockIn.disabled = true;
            btnClockIn.textContent = 'Processing...';

            try {
                const params = new URLSearchParams({
                    action: 'timein',
                    employeeId: managerId,
                    employeeName: managerName,
                    department: managerDepartment
                });

                const fullUrl = handlerUrl + '?' + params.toString();
                console.log('Calling handler:', fullUrl);

                // Add timeout to prevent hanging
                const controller = new AbortController();
                const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

                let response;
                try {
                    response = await fetch(fullUrl, {
                        method: 'GET',
                        headers: {
                            'Accept': 'application/json'
                        },
                        signal: controller.signal
                    });
                    clearTimeout(timeoutId);
                } catch (fetchError) {
                    clearTimeout(timeoutId);
                    if (fetchError.name === 'AbortError') {
                        throw new Error('Request timed out. Please check if the server is running and the handler is accessible.');
                    }
                    throw fetchError;
                }

                console.log('Response status:', response.status);
                
                if (!response.ok) {
                    const text = await response.text();
                    console.error('Response error:', text);
                    throw new Error('Server returned error: ' + response.status + ' - ' + text);
                }

                const responseText = await response.text();
                console.log('Response text:', responseText);
                
                let result;
                try {
                    result = JSON.parse(responseText);
                } catch (parseError) {
                    console.error('JSON parse error:', parseError, 'Response:', responseText);
                    throw new Error('Invalid response from server: ' + responseText);
                }

                console.log('Parsed result:', result);

                if (result.success) {
                    const now = new Date();
                    const timeStr = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
                    
                    hasTimedIn = true;
                    timeInEl.textContent = timeStr;
                    statusBadge.textContent = 'Time In';
                    statusBadge.className = 'status-badge clocked-in';
                    btnClockIn.disabled = true;
                    btnClockOut.disabled = false;
                    
                    alert('✅ Time in recorded successfully at ' + timeStr);
                } else {
                    alert(result.message || 'Failed to record time in. You may have already timed in today.');
                    btnClockIn.disabled = false;
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while recording time in: ' + error.message + '\n\nPlease check the browser console for details.');
                btnClockIn.disabled = false;
            } finally {
                if (!hasTimedIn) {
                    btnClockIn.textContent = '▶️ Time In';
                }
            }
        }

        // Time Out Function
        async function clockOut() {
            if (hasTimedOut) {
                alert('You have already timed out today.');
                return;
            }

            if (!hasTimedIn) {
                alert('Please time in first before timing out.');
                return;
            }

            if (!managerId || managerId === 'N/A') {
                alert('Manager ID not found. Please contact HR.');
                return;
            }

            const btnClockOut = document.getElementById('btnClockOut');
            const statusBadge = document.getElementById('statusBadge');
            const timeOutEl = document.getElementById('timeOut');

            // Disable button during request
            btnClockOut.disabled = true;
            btnClockOut.textContent = 'Processing...';

            try {
                const params = new URLSearchParams({
                    action: 'timeout',
                    employeeId: managerId
                });

                const response = await fetch(handlerUrl + '?' + params.toString(), {
                    method: 'GET'
                });

                const result = await response.json();

                if (result.success) {
                    const now = new Date();
                    const timeStr = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
                    
                    hasTimedOut = true;
                    timeOutEl.textContent = timeStr;
                    statusBadge.textContent = 'Time Out';
                    statusBadge.className = 'status-badge clocked-out';
                    btnClockOut.disabled = true;
                    
                    alert('✅ Time out recorded successfully at ' + timeStr);
                } else {
                    alert(result.message || 'Failed to record time out. Please make sure you have timed in first.');
                    btnClockOut.disabled = false;
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while recording time out: ' + error.message);
                btnClockOut.disabled = false;
            } finally {
                if (!hasTimedOut) {
                    btnClockOut.textContent = '⏹️ Time Out';
                }
            }
        }

        // Break Functions
        function openBreakModal() {
            document.getElementById('breakModal').style.display = 'block';
        }

        function startBreak() {
            const reason = document.getElementById('breakReason').value || 'Break';
            document.getElementById('statusBadge').textContent = 'On Break';
            document.getElementById('statusBadge').className = 'status-badge on-break';
            closeModal('breakModal');
            alert('☕ Break started. Remember to end your break!');
        }


        // Close Modal Function
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }

        // Close modal when clicking outside
        window.onclick = function (event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
    </script>
</asp:Content>