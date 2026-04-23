<%@ Page Title="Attendance Overview" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="AttendanceOverview.aspx.cs" Inherits="ExWebAppSia.webpage_PresidentViewpoint_.AttendanceOverview" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .attendance-overview {
            padding: 24px;
            background: #fdfaf9;
        }

        .exec-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(164, 79, 86, 0.05);
            margin-bottom: 24px;
        }

        .header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .title-group h1 {
            font-size: 24px;
            font-weight: 800;
            color: #4A3534;
            margin: 0;
        }

        .title-group p {
            font-size: 14px;
            color: #6B4545;
            margin: 4px 0 0 0;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 16px;
        }

        .mini-stat {
            background: #fafafa;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
            border: 1px solid #F0EEEE;
            transition: all 0.3s;
        }

        .mini-stat:hover {
            background: white;
            border-color: #A44F56;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(164, 79, 86, 0.1);
        }

        .mini-val {
            font-size: 24px;
            font-weight: 800;
            color: #4A3534;
            display: block;
        }

        .mini-label {
            font-size: 11px;
            font-weight: 700;
            color: #A44F56;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            font-family: 'Poppins', sans-serif;
        }

        .attendance-table th {
            padding: 16px;
            text-align: left;
            font-size: 13px;
            font-weight: 700;
            color: #9B7D7B;
            border-bottom: 2px solid #F0EEEE;
            text-transform: uppercase;
        }

        .attendance-table td {
            padding: 16px;
            font-size: 14px;
            color: #4A3534;
            border-bottom: 1px solid #F5F5F5;
        }

        .attendance-table tr:hover {
            background: rgba(164, 79, 86, 0.02);
        }

        .time-chip {
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 12px;
            display: inline-block;
        }

        .chip-in { background: #E8F5E9; color: #2E7D32; }
        .chip-out { background: #F5F5F5; color: #616161; }
        .chip-late { background: #FFF3E0; color: #E65100; }

        .date-control {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #fdfaf9;
            padding: 8px 16px;
            border-radius: 12px;
            border: 1px solid #EEE;
        }

        .date-picker-input {
            border: none;
            background: transparent;
            font-family: inherit;
            font-weight: 700;
            color: #4A3534;
            outline: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="attendance-overview">
        <div class="exec-card">
            <div class="header-row">
                <div class="title-group">
                    <h1>Company Attendance</h1>
                    <p>Executive Monitoring Dashboard</p>
                </div>
                <div class="date-control">
                    <i class="fas fa-calendar-day" style="color: #A44F56;"></i>
                    <asp:TextBox ID="txtSelectedDate" runat="server" TextMode="Date" CssClass="date-picker-input" AutoPostBack="true" OnTextChanged="DateChanged" />
                </div>
            </div>

            <div class="stats-row">
                <div class="mini-stat">
                    <span class="mini-val"><asp:Literal ID="litPresent" runat="server" /></span>
                    <span class="mini-label">Present</span>
                </div>
                <div class="mini-stat">
                    <span class="mini-val"><asp:Literal ID="litLate" runat="server" /></span>
                    <span class="mini-label">Late</span>
                </div>
                <div class="mini-stat">
                    <span class="mini-val"><asp:Literal ID="litAbsent" runat="server" /></span>
                    <span class="mini-label">Absent</span>
                </div>
                <div class="mini-stat">
                    <span class="mini-val"><asp:Literal ID="litOT" runat="server" /></span>
                    <span class="mini-label">Overtime</span>
                </div>
                <div class="mini-stat">
                    <span class="mini-val"><asp:Literal ID="litUT" runat="server" /></span>
                    <span class="mini-label">Undertime</span>
                </div>
            </div>

            <!-- NEW: Working Format Row -->
            <div class="stats-row mt-3" style="border-top: 1px solid #EEE; padding-top: 20px;">
                <div class="mini-stat" style="background: #F5F7FA;">
                    <span class="mini-val"><asp:Literal ID="litRegular" runat="server" /></span>
                    <span class="mini-label">Regular Personnel</span>
                </div>
                <div class="mini-stat" style="background: #F5F7FA;">
                    <span class="mini-val"><asp:Literal ID="litProbationary" runat="server" /></span>
                    <span class="mini-label">Probationary</span>
                </div>
                <div class="mini-stat" style="background: #F5F7FA;">
                    <span class="mini-val"><asp:Literal ID="litOnLeave" runat="server" /></span>
                    <span class="mini-label">Currently On Leave</span>
                </div>
            </div>
        </div>

        <div class="exec-card">
            <div class="header-row">
                <h2 style="font-size: 18px; font-weight: 700; color: #4A3534; margin: 0;">Daily Logs</h2>
                <asp:DropDownList ID="ddlDeptFilter" runat="server" CssClass="form-select w-auto" AutoPostBack="true" OnSelectedIndexChanged="DateChanged">
                    <asp:ListItem Text="All Departments" Value="" />
                    <asp:ListItem Text="Human Resources" Value="Human Resources" />
                    <asp:ListItem Text="Finance" Value="Finance" />
                    <asp:ListItem Text="Marketing" Value="Marketing" />
                    <asp:ListItem Text="Operations" Value="Operations" />
                    <asp:ListItem Text="IT Department" Value="IT Department" />
                </asp:DropDownList>
            </div>

            <!-- Tabs for President Monitoring -->
            <div style="display: flex; gap: 15px; margin-bottom: 20px; border-bottom: 2px solid #F0EEEE;">
                <button type="button" onclick="switchTab('logs-tab')" class="tab-btn active" id="tab-logs" 
                    style="background:none; border:none; padding:10px 15px; font-weight:700; color:#A36A66; cursor:pointer; border-bottom: 3px solid #A36A66;">Daily Logs</button>
                <button type="button" onclick="switchTab('overtime-tab')" class="tab-btn" id="tab-overtime"
                    style="background:none; border:none; padding:10px 15px; font-weight:700; color:#9B7D7B; cursor:pointer; border-bottom: 3px solid transparent;">Overtime Requests</button>
                <button type="button" onclick="switchTab('undertime-tab')" class="tab-btn" id="tab-undertime"
                    style="background:none; border:none; padding:10px 15px; font-weight:700; color:#9B7D7B; cursor:pointer; border-bottom: 3px solid transparent;">Undertime Requests</button>
            </div>

            <div id="logs-tab" class="tab-content-pres">
                <div class="table-responsive">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Department</th>
                                <th>Time-In</th>
                                <th>Time-Out</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptAttendance" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div style="font-weight: 700;"><%# Eval("EmployeeName") %></div>
                                            <div style="font-size: 11px; color: #9B7D7B;"><%# Eval("EmployeeId") %></div>
                                        </td>
                                        <td><%# Eval("Department") %></td>
                                        <td>
                                            <span class="time-chip chip-in"><%# Eval("TimeIn") != null ? Eval("TimeIn", "{0:h:mm tt}") : "--:--" %></span>
                                        </td>
                                        <td>
                                            <span class="time-chip chip-out"><%# Eval("TimeOut") != null ? Eval("TimeOut", "{0:h:mm tt}") : "--:--" %></span>
                                        </td>
                                        <td>
                                            <%# GetStatusMarkup(Eval("TimeIn"), Eval("LateTime")) %>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="overtime-tab" class="tab-content-pres" style="display:none;">
                <div class="table-responsive">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Reason</th>
                                <th>OT Rate</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (PendingOvertimeRequests != null && PendingOvertimeRequests.Any()) { %>
                                <% foreach (var req in PendingOvertimeRequests) { %>
                                    <tr>
                                        <td>
                                            <div style="font-weight: 700;"><%= req.EmployeeName %></div>
                                            <div style="font-size: 11px; color: #9B7D7B;"><%= req.EmployeeId %></div>
                                        </td>
                                        <td style="font-style: italic; color: #6b7280;">"<%= req.Reason %>"</td>
                                        <td style="font-weight: 700; color: #2E7D32;">₱<%= GetEstimatedOTRate(req) %>/hr</td>
                                        <td>
                                            <% if (req.EmployeeId != CurrentAdminId) { %>
                                                <div style="display: flex; gap: 8px;">
                                                    <button type="button" onclick="approveOvertime('<%= req.Id %>')" style="background:#A44F56; color:white; border:none; padding:6px 12px; border-radius:6px; font-weight:700; cursor:pointer;">Approve</button>
                                                    <button type="button" onclick="rejectOvertime('<%= req.Id %>')" style="background:#F5F5F5; color:#4A3534; border:1px solid #DDD; padding:6px 12px; border-radius:6px; font-weight:700; cursor:pointer;">Reject</button>
                                                </div>
                                            <% } else { %>
                                                <span style="font-size: 12px; font-weight: 600; color: #9ca3af; font-style: italic;">Your Request</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr><td colspan="4" style="text-align:center; padding:40px; color:#9B7D7B;">No pending overtime requests found.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="undertime-tab" class="tab-content-pres" style="display:none;">
                <div class="table-responsive">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Reason</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (PendingUndertimeRequests != null && PendingUndertimeRequests.Any()) { %>
                                <% foreach (var req in PendingUndertimeRequests) { %>
                                    <tr>
                                        <td>
                                            <div style="font-weight: 700;"><%= req.EmployeeName %></div>
                                            <div style="font-size: 11px; color: #9B7D7B;"><%= req.EmployeeId %></div>
                                        </td>
                                        <td style="font-style: italic; color: #6b7280;">"<%= req.Reason %>"</td>
                                        <td>
                                            <% if (req.EmployeeId != CurrentAdminId) { %>
                                                <div style="display: flex; gap: 8px;">
                                                    <button type="button" onclick="approveUndertime('<%= req.Id %>')" style="background:#A44F56; color:white; border:none; padding:6px 12px; border-radius:6px; font-weight:700; cursor:pointer;">Approve</button>
                                                    <button type="button" onclick="rejectUndertime('<%= req.Id %>')" style="background:#F5F5F5; color:#4A3534; border:1px solid #DDD; padding:6px 12px; border-radius:6px; font-weight:700; cursor:pointer;">Reject</button>
                                                </div>
                                            <% } else { %>
                                                <span style="font-size: 12px; font-weight: 600; color: #9ca3af; font-style: italic;">Your Request</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr><td colspan="3" style="text-align:center; padding:40px; color:#9B7D7B;">No pending undertime requests found.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Processed Undertime Records Section -->
                <% if (UndertimeRecords != null && UndertimeRecords.Any()) { %>
                    <div style="margin-top: 30px; border-top: 2px dashed #F0EEEE; padding-top: 20px;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #4A3534; margin-bottom: 15px;">Finalized Undertime Records</h4>
                        <div class="table-responsive">
                            <table class="attendance-table">
                                <thead>
                                    <tr>
                                        <th>Employee</th>
                                        <th>Hours</th>
                                        <th>Deduction</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% foreach (var record in UndertimeRecords) { %>
                                        <tr>
                                            <td>
                                                <div style="font-weight: 700;"><%= record.EmployeeName %></div>
                                                <div style="font-size: 11px; color: #9B7D7B;"><%= record.EmployeeId %></div>
                                            </td>
                                            <td><span style="color: #ef4444; font-weight: 700;">-<%= record.HoursUndertime.ToString("N1") %>h</span></td>
                                            <td style="font-weight: 700;">₱<%= record.DeductionAmount.ToString("N2") %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } %>
            </div>

            <script>
                function switchTab(tabId) {
                    document.querySelectorAll('.tab-content-pres').forEach(t => t.style.display = 'none');
                    document.querySelectorAll('.tab-btn').forEach(b => {
                        b.style.color = '#9B7D7B';
                        b.style.borderBottomColor = 'transparent';
                    });

                    document.getElementById(tabId).style.display = 'block';
                    const activeBtn = document.getElementById('tab-' + tabId.replace('-tab', ''));
                    activeBtn.style.color = '#A36A66';
                    activeBtn.style.borderBottomColor = '#A36A66';
                }

                const handlerUrl = '<%= ResolveUrl("~/webpage/api/AttendanceHandler.ashx") %>';

                async function approveOvertime(id) {
                    if(!confirm('Approve this overtime request?')) return;
                    await callHandler('approveovertime', id);
                }
                async function rejectOvertime(id) {
                    if(!confirm('Reject this overtime request?')) return;
                    await callHandler('rejectovertime', id);
                }
                async function approveUndertime(id) {
                    if(!confirm('Approve this undertime request?')) return;
                    await callHandler('approveundertime', id);
                }
                async function rejectUndertime(id) {
                    if(!confirm('Reject this undertime request?')) return;
                    await callHandler('rejectundertime', id);
                }

                async function callHandler(action, id) {
                    try {
                        const resp = await fetch(`${handlerUrl}?action=${action}&attendanceId=${id}`);
                        const res = await resp.json();
                        if(res.success) {
                            alert(res.message || 'Success!');
                            location.reload();
                        } else {
                            alert(res.message || 'Action failed.');
                        }
                    } catch(e) {
                        alert('Error connecting to server.');
                    }
                }
            </script>

            <div class="table-responsive" style="display:none;"> <!-- Hidden original table since we replaced it with tabs -->
                <table class="attendance-table" style="display:none;">
                
                <div id="divNoData" runat="server" visible="false" style="text-align: center; padding: 40px; color: #9B7D7B;">
                    <i class="fas fa-clipboard-list fa-3x mb-3" style="opacity: 0.2;"></i>
                    <p>No attendance records found for this date.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

