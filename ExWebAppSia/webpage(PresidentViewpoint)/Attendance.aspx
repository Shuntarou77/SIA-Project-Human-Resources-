<%@ Page Title="Personal Attendance" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Attendance.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentAttendance" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #A44F56, #DE9D9D);
            --secondary-gradient: linear-gradient(135deg, #ffffff, #f9f9f9);
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --border-radius: 16px;
        }

        .attendance-container {
            padding: 30px;
            max-width: 1000px;
            margin: 0 auto;
        }

        .attendance-card {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            overflow: hidden;
            border: 1px solid #f0f0f0;
        }

        .attendance-header {
            background: var(--primary-gradient);
            padding: 40px;
            text-align: center;
            color: white;
        }

        .initials-circle {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            font-size: 32px;
            font-weight: 700;
            border: 2px solid rgba(255, 255, 255, 0.5);
        }

        .attendance-body {
            padding: 40px;
        }

        .time-display {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 40px;
        }

        .time-box {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            min-width: 200px;
            border: 1px solid #eee;
        }

        .time-label {
            font-size: 13px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
            display: block;
        }

        .time-value {
            font-size: 24px;
            font-weight: 700;
            color: #333;
            font-family: 'Courier New', monospace;
        }

        .attendance-actions {
            display: flex;
            gap: 20px;
            justify-content: center;
        }

        .btn-time {
            padding: 15px 40px;
            border-radius: 12px;
            font-weight: 700;
            cursor: pointer;
            border: none;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
        }

        .btn-in {
            background: #10b981;
            color: white;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
        }

        .btn-in:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
        }

        .btn-out {
            background: #f59e0b;
            color: white;
            box-shadow: 0 4px 15px rgba(245, 158, 11, 0.3);
        }

        .btn-out:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(245, 158, 11, 0.4);
        }

        .btn-time:disabled {
            background: #e5e7eb;
            color: #9ca3af;
            box-shadow: none;
            cursor: not-allowed;
            transform: none !important;
        }

        .status-badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            margin-top: 20px;
        }

        .status-none { background: #f3f4f6; color: #6b7280; }
        .status-present { background: #d1fae5; color: #065f46; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="attendance-container">
        <div class="attendance-card">
            <div class="attendance-header">
                <div class="initials-circle">
                    <%= GetEmployeeInitials() %>
                </div>
                <h1 style="margin: 0; font-size: 28px;">My Attendance Log</h1>
                <p style="opacity: 0.9; margin-top: 5px;"><%= DateTime.Now.ToString("dddd, MMMM dd, yyyy") %></p>
            </div>

            <div class="attendance-body">
                <div class="time-display">
                    <div class="time-box">
                        <span class="time-label">Current Date</span>
                        <span id="displayDate" class="time-value">--/--/----</span>
                    </div>
                    <div class="time-box">
                        <span class="time-label">Current Time</span>
                        <span id="displayTime" class="time-value">--:--:--</span>
                    </div>
                </div>

                <div style="text-align: center; margin-bottom: 40px;">
                    <div id="attendanceStatusLabel" class="status-badge status-none">Not timed in yet</div>
                </div>

                <div class="attendance-actions">
                    <button id="timeInBtn" type="button" class="btn-time btn-in" onclick="timeIn()">
                        <i class="fas fa-sign-in-alt"></i> TIME IN
                    </button>
                    <button id="timeOutBtn" type="button" class="btn-time btn-out" onclick="timeOut()" disabled>
                        <i class="fas fa-sign-out-alt"></i> TIME OUT
                    </button>
                </div>

                <div style="margin-top: 50px; border-top: 1px solid #eee; padding-top: 30px;">
                    <h3 style="color: #333; margin-bottom: 20px;">Personal Reminder</h3>
                    <p style="color: #666; line-height: 1.6;">
                        President, your attendance logs are recorded for company transparency. 
                        Please ensure you time in and out daily to maintain consistent records.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <script>
        const employeeId = '<%= GetEmployeeId() %>';
        const employeeName = '<%= GetEmployeeName() %>';
        const department = '<%= GetEmployeeDepartment() %>';
        const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';
        const attendanceStatus = <%= GetAttendanceStatusJson() %>;

        function updateClock() {
            const now = new Date();
            document.getElementById('displayDate').textContent = now.toLocaleDateString();
            document.getElementById('displayTime').textContent = now.toLocaleTimeString();
        }

        setInterval(updateClock, 1000);
        updateClock();

        function syncUI() {
            const statusLabel = document.getElementById('attendanceStatusLabel');
            const inBtn = document.getElementById('timeInBtn');
            const outBtn = document.getElementById('timeOutBtn');

            if (attendanceStatus.hasTimedIn) {
                inBtn.disabled = true;
                outBtn.disabled = false;
                statusLabel.textContent = `Timed In at ${attendanceStatus.timeIn}`;
                statusLabel.className = 'status-badge status-present';

                if (attendanceStatus.hasTimedOut) {
                    outBtn.disabled = true;
                    statusLabel.textContent = `Timed Out at ${attendanceStatus.timeOut}`;
                }
            }
        }

        syncUI();

        async function timeIn() {
            if (!confirm('Perform Time In?')) return;
            
            try {
                const params = new URLSearchParams({
                    action: 'timein',
                    employeeId: employeeId,
                    employeeName: employeeName,
                    department: department
                });

                const response = await fetch(handlerUrl + '?' + params.toString());
                const result = await response.json();

                if (result.success) {
                    location.reload();
                } else {
                    alert('Error: ' + result.message);
                }
            } catch (err) {
                alert('Connection error');
            }
        }

        async function timeOut() {
            if (!confirm('Perform Time Out?')) return;

            try {
                const params = new URLSearchParams({
                    action: 'timeout',
                    employeeId: employeeId,
                    employeeName: employeeName,
                    department: department
                });

                const response = await fetch(handlerUrl + '?' + params.toString());
                const result = await response.json();

                if (result.success) {
                    location.reload();
                } else {
                    alert('Error: ' + result.message);
                }
            } catch (err) {
                alert('Connection error');
            }
        }
    </script>
</asp:Content>

