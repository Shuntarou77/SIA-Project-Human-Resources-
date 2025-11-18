<%@ Page Title="Attendance" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master" AutoEventWireup="true" Async="true" CodeBehind="Attendance.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm3" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #ff6b6b, #ff8e8e);
            --secondary-gradient: linear-gradient(135deg, #ffebee, #f8bbd0);
            --card-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
            --hover-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
            --border-radius: 24px;
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
        }

        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; 
        }

        html, body { 
            height: 100%; 
            background: linear-gradient(180deg, #F5DDD8 0%, #D4999C 50%, #A85B5B 100%);
        }

        .page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .attendance-card {
            width: 95%;
            max-width: 1000px;
            border-radius: var(--border-radius);
            overflow: hidden;
            background: white;
            box-shadow: var(--card-shadow);
            border: 1px solid rgba(229, 231, 235, 0.8);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .attendance-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }

        .attendance-header-section {
            background: var(--primary-gradient);
            padding: 32px 24px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .attendance-header-section::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .header-logo {
            width: 72px;
            height: 72px;
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(10px);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .header-logo span {
            font-size: 28px;
            font-weight: 800;
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .header-title {
            color: white;
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 8px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .header-subtitle {
            color: rgba(255, 255, 255, 0.9);
            font-size: 16px;
            font-weight: 500;
        }

        .attendance-main {
            padding: 32px;
            background: var(--secondary-gradient);
        }

        .date-time-container {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 32px;
            justify-content: space-between;
        }

        .current-date {
            background: white;
            padding: 12px 20px;
            border-radius: 16px;
            font-weight: 700;
            color: var(--text-primary);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .current-time {
            background: white;
            padding: 12px 20px;
            border-radius: 16px;
            font-weight: 700;
            color: var(--text-primary);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            gap: 8px;
            font-family: 'Courier New', monospace;
        }

        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 28px;
        }

        @media (max-width: 768px) {
            .content-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }
            .date-time-container {
                flex-direction: column;
            }
        }

        .info-section {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .info-card {
            background: white;
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(229, 231, 235, 0.6);
            transition: transform 0.2s ease;
        }

        .info-card:hover {
            transform: translateY(-2px);
        }

        .info-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }

        .info-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 18px;
        }

        .employee-icon {
            background: rgba(59, 130, 246, 0.15);
            color: #3b82f6;
        }

        .status-icon {
            background: rgba(16, 185, 129, 0.15);
            color: #10b981;
        }

        .location-icon {
            background: rgba(245, 158, 11, 0.15);
            color: #f59e0b;
        }

        .info-label {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            font-size: 24px;
            font-weight: 800;
            color: var(--text-primary);
            line-height: 1.2;
        }

        .info-note {
            background: rgba(59, 130, 246, 0.08);
            border-left: 4px solid #3b82f6;
            padding: 16px;
            border-radius: 0 12px 12px 0;
            margin-top: 16px;
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        .actions-section {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .action-btn {
            padding: 16px 20px;
            border-radius: 16px;
            font-weight: 700;
            font-size: 16px;
            cursor: pointer;
            border: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-align: center;
        }

        .btn-time-in {
            background: linear-gradient(135deg, #10b981, #34d399);
            color: white;
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }

        .btn-time-in:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(16, 185, 129, 0.4);
        }

        .btn-time-out {
            background: linear-gradient(135deg, #f59e0b, #fbbf24);
            color: white;
            box-shadow: 0 8px 20px rgba(245, 158, 11, 0.3);
        }

        .btn-time-out:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(245, 158, 11, 0.4);
        }

        .btn-status {
            background: white;
            color: var(--text-primary);
            border: 2px solid #e5e7eb;
            font-weight: 700;
        }

        .btn-status:hover {
            border-color: #d1d5db;
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        }

        .action-btn:disabled {
            opacity: 0.65;
            cursor: not-allowed;
            transform: none;
        }

        .stats-card {
            background: white;
            border-radius: 18px;
            padding: 20px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
            margin-top: 16px;
        }

        .stats-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 16px;
            text-align: center;
        }

        .stats-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(229, 231, 235, 0.6);
        }

        .stats-item:last-child {
            border-bottom: none;
        }

        .stats-label {
            color: var(--text-secondary);
            font-size: 14px;
        }

        .stats-value {
            font-weight: 700;
            color: var(--text-primary);
        }

        .success-value {
            color: var(--success-color);
        }

        .warning-value {
            color: var(--warning-color);
        }

        /* Icons using Unicode characters */
        .icon::before {
            font-weight: bold;
        }

        .user-icon::before {
            content: "👤";
        }

        .check-icon::before {
            content: "✓";
        }

        .location-icon::before {
            content: "📍";
        }

        .clock-icon::before {
            content: "🕒";
        }

        .calendar-icon::before {
            content: "📅";
        }

        .time-in-icon::before {
            content: "🔽";
        }

        .time-out-icon::before {
            content: "🔼";
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page">
        <div class="attendance-card" role="region" aria-label="Attendance card">
            <div class="attendance-header-section">
                <div class="header-logo">
                    <span><%= GetEmployeeInitials() %></span>
                </div>
                <h1 class="header-title">Today's Attendance</h1>
                <p class="header-subtitle">Log your time in and out</p>
            </div>

            <div class="attendance-main">
                <div class="date-time-container">
                    <div id="currentDate" class="current-date">
                        <span class="calendar-icon icon"></span>
                        <span>--</span>
                    </div>
                    <div id="currentTime" class="current-time">
                        <span class="clock-icon icon"></span>
                        <span>--:--:--</span>
                    </div>
                </div>

                <div class="content-grid">
                    <div class="info-section">
                        <div class="info-card">
                            <div class="info-header">
                                <div class="info-icon employee-icon">
                                    <span class="user-icon icon"></span>
                                </div>
                                <div class="info-label">Employee</div>
                            </div>
                            <div class="info-value"><%= GetEmployeeName() %></div>
                            <div style="font-size: 14px; color: var(--text-secondary); margin-top: 8px;">ID: <%= GetEmployeeId() %></div>
                        </div>

                        <div class="info-card">
                            <div class="info-header">
                                <div class="info-icon status-icon">
                                    <span class="check-icon icon"></span>
                                </div>
                                <div class="info-label">Attendance Status</div>
                            </div>
                            <div class="info-value" id="attendanceStatus">Not timed in yet</div>
                        </div>

                        <div class="info-note">
                            Press <strong>Time In</strong> when you start your shift and <strong>Time Out</strong> when you leave. Both are required for a complete attendance record.
                        </div>
                    </div>

                    <div class="actions-section">
                        <button id="timeInBtn" class="action-btn btn-time-in" onclick="timeIn()">
                            <span class="time-in-icon icon"></span>
                            TIME IN
                        </button>
                        <button id="timeOutBtn" class="action-btn btn-time-out" onclick="timeOut()" disabled>
                            <span class="time-out-icon icon"></span>
                            TIME OUT
                        </button>
                        <button class="action-btn btn-status" onclick="showStatus()">
                            <span class="user-icon icon"></span>
                            SHOW STATUS
                        </button>

                        <div class="stats-card">
                            <div class="stats-title">This Week</div>
                            <div class="stats-item">
                                <span class="stats-label">Days Present</span>
                                <span class="stats-value">4/5</span>
                            </div>
                            <div class="stats-item">
                                <span class="stats-label">On Time</span>
                                <span class="stats-value success-value">100%</span>
                            </div>
                            <div class="stats-item">
                                <span class="stats-label">Streak</span>
                                <span class="stats-value warning-value">12 days</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Employee data from server
        const employeeId = '<%= GetEmployeeId() %>';
        const employeeName = '<%= GetEmployeeName() %>';
        const employeeDepartment = '<%= GetEmployeeDepartment() %>';
        const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
        
        // Load attendance status from server
        const attendanceStatus = <%= GetAttendanceStatusJson() %>;
        console.log('Attendance Status:', attendanceStatus);
        console.log('Handler URL:', handlerUrl);
        console.log('Employee ID:', employeeId);
        console.log('Employee Name:', employeeName);
        console.log('Department:', employeeDepartment);

        // State flags - initialize from server data
        let hasTimedIn = attendanceStatus.hasTimedIn || false;
        let hasTimedOut = attendanceStatus.hasTimedOut || false;

        // Update date and time in real-time
        function updateDateTime() {
            const now = new Date();
            const dateOpts = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' };
            const timeOpts = { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true };

            document.getElementById('currentDate').innerHTML =
                '<span class="calendar-icon icon"></span> ' + now.toLocaleDateString(undefined, dateOpts);
            document.getElementById('currentTime').innerHTML =
                '<span class="clock-icon icon"></span> ' + now.toLocaleTimeString(undefined, timeOpts);
        }

        // Initialize and update every second
        updateDateTime();
        setInterval(updateDateTime, 1000);

        // Load today's attendance status on page load
        function loadTodayStatus() {
            try {
                const statusEl = document.getElementById('attendanceStatus');
                const timeInBtn = document.getElementById('timeInBtn');
                const timeOutBtn = document.getElementById('timeOutBtn');

                // Update UI based on server-side status
                if (attendanceStatus.hasTimedIn) {
                    hasTimedIn = true;
                    const timeInStr = attendanceStatus.timeIn || 'earlier today';
                    statusEl.textContent = `Timed In at ${timeInStr}`;
                    statusEl.style.color = '#10b981';
                    timeInBtn.disabled = true;
                    
                    if (attendanceStatus.hasTimedOut) {
                        hasTimedOut = true;
                        const timeOutStr = attendanceStatus.timeOut || 'earlier today';
                        statusEl.textContent = `Timed Out at ${timeOutStr}`;
                        statusEl.style.color = '#f59e0b';
                        timeOutBtn.disabled = true;
                    } else {
                        timeOutBtn.disabled = false;
                    }
                } else {
                    statusEl.textContent = 'Not timed in yet';
                    statusEl.style.color = '';
                    timeInBtn.disabled = false;
                    timeOutBtn.disabled = true;
                }
                
                console.log('Status loaded - hasTimedIn:', hasTimedIn, 'hasTimedOut:', hasTimedOut);
            } catch (error) {
                console.error('Error loading attendance status:', error);
            }
        }

        async function timeIn() {
            if (hasTimedIn) {
                alert('You have already timed in today.');
                return;
            }

            if (!employeeId || employeeId === 'N/A') {
                alert('Employee ID not found. Please contact HR.');
                return;
            }

            const timeInBtn = document.getElementById('timeInBtn');
            const timeOutBtn = document.getElementById('timeOutBtn');
            const statusEl = document.getElementById('attendanceStatus');

            // Disable button during request
            timeInBtn.disabled = true;
            timeInBtn.textContent = 'Processing...';

            try {
                const params = new URLSearchParams({
                    action: 'timein',
                    employeeId: employeeId,
                    employeeName: employeeName,
                    department: employeeDepartment
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
                console.log('Response headers:', [...response.headers.entries()]);
                
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
                    const timeStr = now.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
                    
                    hasTimedIn = true;
                    statusEl.textContent = `Timed In at ${timeStr}`;
                    statusEl.style.color = '#10b981';
                    timeInBtn.disabled = true;
                    timeOutBtn.disabled = false;
                    
                    alert('Time in recorded successfully!');
                } else {
                    alert(result.message || 'Failed to record time in. You may have already timed in today.');
                    timeInBtn.disabled = false;
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while recording time in: ' + error.message + '\n\nPlease check the browser console for details.');
                timeInBtn.disabled = false;
            } finally {
                if (!hasTimedIn) {
                    timeInBtn.textContent = 'TIME IN';
                }
            }
        }

        async function timeOut() {
            if (hasTimedOut) {
                alert('You have already timed out today.');
                return;
            }

            if (!hasTimedIn) {
                alert('Please time in first before timing out.');
                return;
            }

            if (!employeeId || employeeId === 'N/A') {
                alert('Employee ID not found. Please contact HR.');
                return;
            }

            const timeOutBtn = document.getElementById('timeOutBtn');
            const statusEl = document.getElementById('attendanceStatus');

            // Disable button during request
            timeOutBtn.disabled = true;
            timeOutBtn.textContent = 'Processing...';

            try {
                const params = new URLSearchParams({
                    action: 'timeout',
                    employeeId: employeeId
                });

                const response = await fetch(handlerUrl + '?' + params.toString(), {
                    method: 'GET'
                });

                const result = await response.json();

                if (result.success) {
                    const now = new Date();
                    const timeStr = now.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
                    
                    hasTimedOut = true;
                    statusEl.textContent = `Timed Out at ${timeStr}`;
                    statusEl.style.color = '#f59e0b';
                    timeOutBtn.disabled = true;
                    
                    alert('Time out recorded successfully!');
                } else {
                    alert(result.message || 'Failed to record time out. Please make sure you have timed in first.');
                    timeOutBtn.disabled = false;
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while recording time out. Please try again.');
                timeOutBtn.disabled = false;
            } finally {
                timeOutBtn.textContent = 'TIME OUT';
            }
        }

        function showStatus() {
            const status = document.getElementById('attendanceStatus').textContent;
            alert('Current attendance status:\n' + status);
        }

        // Initialize page on load
        // Call immediately (page might already be loaded) and also on DOMContentLoaded
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                loadTodayStatus();
            });
        } else {
            // DOM already loaded, call immediately
            loadTodayStatus();
        }
    </script>
</asp:Content>