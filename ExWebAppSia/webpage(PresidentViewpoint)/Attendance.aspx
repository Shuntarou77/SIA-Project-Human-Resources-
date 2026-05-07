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

    <!-- Undertime Modal -->
    <div id="undertimeModal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(5px);">
        <div style="background: white; margin: 100px auto; border-radius: 20px; width: 90%; max-width: 450px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); overflow: hidden; font-family: 'Poppins', sans-serif;">
            <div style="background: #f59e0b; padding: 20px; color: white; text-align: center; position: relative;">
                <span onclick="closeModal('undertimeModal')" style="position: absolute; left: 20px; top: 15px; font-size: 24px; cursor: pointer;">&times;</span>
                <h3 style="margin: 0; font-size: 18px; font-weight: 700;">⚠️ Early Time Out</h3>
            </div>
            
            <div id="undertimeSelection" style="padding: 30px; text-align: center;">
                <div style="font-size: 50px; margin-bottom: 15px;">🕒</div>
                <h3 style="color: #333; margin-bottom: 10px;">It's not yet 5:00 PM</h3>
                <p style="color: #666; line-height: 1.6; margin-bottom: 25px;">
                    Timing out now will be recorded as <strong>Undertime</strong>. Please select the type of undertime:
                </p>

                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <button type="button" onclick="showEmergencyForm()" 
                        style="display: flex; align-items: center; gap: 15px; padding: 15px; border: 2px solid #fee2e2; border-radius: 12px; background: #fff1f2; cursor: pointer; text-align: left; transition: all 0.2s;">
                        <div style="font-size: 24px;">🚨</div>
                        <div>
                            <div style="font-weight: 700; color: #991b1b; margin-bottom: 2px; font-size: 14px;">Emergency Quick Notify</div>
                            <div style="font-size: 11px; color: #b91c1c; opacity: 0.8;">Medical or urgent matters.</div>
                        </div>
                    </button>

                    <button type="button" onclick="showRegularUTForm()" 
                        style="display: flex; align-items: center; gap: 15px; padding: 15px; border: 2px solid #fef3c7; border-radius: 12px; background: #fffbeb; cursor: pointer; text-align: left; transition: all 0.2s;">
                        <div style="font-size: 24px;">📄</div>
                        <div>
                            <div style="font-weight: 700; color: #92400e; margin-bottom: 2px; font-size: 14px;">Regular Undertime</div>
                            <div style="font-size: 11px; color: #a16207; opacity: 0.8;">Personal errands or non-emergency.</div>
                        </div>
                    </button>
                </div>
                <div style="margin-top: 15px; font-size: 12px; color: #6b7280;">
                    Already have an approved request? <a href="javascript:void(0)" onclick="checkUndertimeStatus()" style="color: #3b82f6; font-weight: 600; text-decoration: none;">Check status</a>
                </div>
            </div>

            <!-- Emergency Form -->
            <div id="emergencyForm" style="display: none; padding: 30px;">
                <div style="background: #fff1f2; border-left: 4px solid #ef4444; padding: 12px; border-radius: 8px; margin-bottom: 15px;">
                    <h4 style="color: #991b1b; margin: 0 0 5px 0; font-size: 14px;">🚨 Emergency Notification</h4>
                    <p style="color: #b91c1c; font-size: 11px; margin: 0;">This will immediately notify HR and allow you to time out.</p>
                </div>
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Emergency Reason *</label>
                    <textarea id="emergencyReason" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; min-height: 80px; resize: none;" placeholder="Briefly describe the emergency..."></textarea>
                </div>
                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" style="padding: 8px 16px; border: none; border-radius: 8px; background: #f3f4f6; cursor: pointer;" onclick="backToSelection()">Back</button>
                    <button type="button" style="padding: 8px 16px; border: none; border-radius: 8px; background: #ef4444; color: white; cursor: pointer;" onclick="submitEmergencyUndertime()">Send & Time Out</button>
                </div>
            </div>

            <!-- Regular Form -->
            <div id="regularUTForm" style="display: none; padding: 30px;">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                    <div>
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Departure Date *</label>
                        <input type="date" id="utDate" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Departure Time *</label>
                        <input type="time" id="utTime" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;" />
                    </div>
                </div>
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px;">Reason for Undertime *</label>
                    <textarea id="utReason" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; min-height: 80px; resize: none;" placeholder="Please provide a reason..."></textarea>
                </div>
                <div style="background: #fffbeb; border-left: 4px solid #f59e0b; padding: 12px; border-radius: 8px; margin-bottom: 15px;">
                    <p style="color: #92400e; font-size: 11px; margin: 0;"><strong>Note:</strong> Requires HR/Admin approval.</p>
                </div>
                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" style="padding: 8px 16px; border: none; border-radius: 8px; background: #f3f4f6; cursor: pointer;" onclick="backToSelection()">Back</button>
                    <button type="button" style="padding: 8px 16px; border: none; border-radius: 8px; background: #f59e0b; color: white; cursor: pointer;" onclick="submitRegularUndertime()">Submit Request</button>
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

        function timeOut() {
            if (attendanceStatus.hasTimedOut) {
                alert('You have already timed out today.');
                return;
            }

            const now = new Date();
            if (now.getHours() < 17) {
                openModal('undertimeModal');
            } else {
                proceedWithTimeOut();
            }
        }

        async function proceedWithTimeOut() {
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

        function openModal(id) {
            document.getElementById(id).style.display = 'block';
            if (id === 'undertimeModal') {
                backToSelection();
                // Set defaults and min date
                const now = new Date();
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
        }

        function closeModal(id) {
            document.getElementById(id).style.display = 'none';
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
                alert('Please provide a reason.');
                return;
            }

            try {
                const params = new URLSearchParams({
                    action: 'emergencyundertime',
                    employeeId: employeeId,
                    reason: reason,
                    employeeName: employeeName,
                    department: department
                });

                const response = await fetch(handlerUrl + '?' + params.toString());
                const result = await response.json();

                if (result.success) {
                    alert('Emergency notification sent! You have been timed out.');
                    location.reload();
                } else {
                    alert('Error: ' + result.message);
                }
            } catch (err) {
                alert('Connection error');
            }
        }

        async function submitRegularUndertime() {
            const reason = document.getElementById('utReason').value.trim();
            const utDate = document.getElementById('utDate').value;
            const utTime = document.getElementById('utTime').value;

            if (!reason) {
                alert('Please provide a reason.');
                return;
            }
            if (!utDate || !utTime) {
                alert('Please provide both date and time.');
                return;
            }

            // Date Validation: Current or Future
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const selectedDate = new Date(utDate);
            if (selectedDate < today) {
                alert('Undertime date cannot be in the past. Please select today or a future date.');
                return;
            }

            // Time Validation: Must be before 5:00 PM (17:00)
            const depHour = parseInt(utTime.split(':')[0]);
            if (depHour >= 17) {
                alert('Undertime means leaving early. Your departure must be before the shift ends (5:00 PM).');
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
                    employeeName: employeeName,
                    department: department,
                    type: 'Regular',
                    departureTime: departureTime
                });

                const response = await fetch(handlerUrl + '?' + params.toString());
                const result = await response.json();

                if (result.success) {
                    alert('Undertime request submitted successfully!');
                    closeModal('undertimeModal');
                } else {
                    alert('Error: ' + result.message);
                }
            } catch (err) {
                alert('Connection error');
            }
        }

        async function checkUndertimeStatus() {
            try {
                const response = await fetch(`${handlerUrl}?action=getstatus&employeeId=${employeeId}`);
                const status = await response.json();

                if (status.undertimeStatus === 'Approved') {
                    alert('Your undertime request has been approved! Proceeding to time out.');
                    proceedWithTimeOut();
                } else if (status.undertimeStatus === 'Pending') {
                    alert('Your undertime request is still pending approval.');
                } else {
                    alert('No approved request found.');
                }
            } catch (err) {
                alert('Connection error');
            }
        }
    </script>
</asp:Content>

