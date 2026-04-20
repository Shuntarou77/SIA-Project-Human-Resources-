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
                
                <div id="divNoData" runat="server" visible="false" style="text-align: center; padding: 40px; color: #9B7D7B;">
                    <i class="fas fa-clipboard-list fa-3x mb-3" style="opacity: 0.2;"></i>
                    <p>No attendance records found for this date.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

