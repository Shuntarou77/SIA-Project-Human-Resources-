<%@ Page Title="Super Admin Approvals" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Approvals.aspx.cs" Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.Approvals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style type="text/css">
        :root {
            --primary-color: #8B4755;
            --primary-gradient: linear-gradient(135deg, #A36A66, #C49A99);
            --bg-glass: rgba(255, 255, 255, 0.9);
            --border-soft: #F8ECEB;
            --text-deep: #4A3534;
            --text-muted: #9B7D7B;
            --shadow-soft: 0 8px 24px rgba(163, 106, 102, 0.12);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body { 
            background: linear-gradient(135deg, #FCFAF9 0%, #FFFFFF 100%);
            color: var(--text-deep);
            font-family: 'Inter', 'Segoe UI', sans-serif;
        }

        .approvals-wrapper { padding: 30px 20px; max-width: 1400px; margin: 0 auto; animation: fadeIn 0.6s ease-out; }

        /* Premium Header */
        .page-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { 
            font-size: 32px; font-weight: 800; margin-bottom: 8px;
            background: var(--primary-gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .page-header p { color: var(--text-muted); font-size: 15px; font-weight: 500; }
        .role-badge { background: #A36A66; color: white; padding: 4px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; box-shadow: 0 4px 10px rgba(163, 106, 102, 0.2); }

        /* Metrics Grid */
        .metrics-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 20px; margin-bottom: 35px; }
        .metric-card {
            background: white; padding: 20px; border-radius: 20px; border: 1px solid var(--border-soft); box-shadow: var(--shadow-soft);
            display: flex; flex-direction: column; gap: 15px; cursor: pointer; transition: var(--transition);
        }
        .metric-card:hover { transform: translateY(-5px); box-shadow: 0 16px 40px rgba(163, 106, 102, 0.2); border-color: #A36A66; }
        
        .metric-header { display: flex; justify-content: space-between; align-items: center; }
        .metric-icon { 
            width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center;
            font-size: 18px; color: white; transition: var(--transition);
        }
        .metric-card:hover .metric-icon { transform: scale(1.1) rotate(5deg); }
        .metric-value { font-size: 28px; font-weight: 800; color: #A36A66; line-height: 1; }
        .metric-label { font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; }

        /* Portal Container */
        .portal-card { background: white; border-radius: 24px; border: 1px solid var(--border-soft); box-shadow: var(--shadow-soft); overflow: hidden; }

        /* Tab Navigation */
        .tab-nav { display: flex; padding: 10px 20px; background: #fafafa; border-bottom: 2px solid #f0eeee; gap: 10px; }
        .tab-btn {
            padding: 12px 20px; border-radius: 12px; font-weight: 700; font-size: 13px; color: var(--text-muted);
            cursor: pointer; transition: var(--transition); display: flex; align-items: center; gap: 10px; border: 1px solid transparent;
        }
        .tab-btn:hover { background: #fff1f0; color: #A36A66; }
        .tab-btn.active { background: white; color: #A36A66; border-color: var(--border-soft); box-shadow: 0 4px 12px rgba(163, 106, 102, 0.1); }
        .tab-btn i { font-size: 16px; transition: var(--transition); }
        .tab-btn.active i { transform: scale(1.1); }

        .tab-pane { display: none; padding: 25px; animation: slideUp 0.4s ease; }
        .tab-pane.active { display: block; }
        @keyframes slideUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }

        /* Modernized Tables */
        .table-responsive { overflow-x: auto; min-height: 300px; }
        .premium-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
        .premium-table th { padding: 15px 20px; color: var(--text-muted); font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid #f0eeee; }
        .premium-table td { padding: 16px 20px; background: white; border-top: 1px solid #f8f8f8; border-bottom: 1px solid #f8f8f8; font-size: 14px; font-weight: 500; }
        .premium-table tr td:first-child { border-left: 1px solid #f8f8f8; border-top-left-radius: 12px; border-bottom-left-radius: 12px; }
        .premium-table tr td:last-child { border-right: 1px solid #f8f8f8; border-top-right-radius: 12px; border-bottom-right-radius: 12px; }
        .premium-table tr:hover td { background: #fffcfb; border-color: #fceceb; }

        /* Action UI */
        .user-cell { display: flex; align-items: center; gap: 12px; }
        .user-avatar { width: 36px; height: 36px; border-radius: 12px; background: var(--primary-gradient); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px; box-shadow: 0 4px 10px rgba(163, 106, 102, 0.2); }
        .user-name { font-weight: 600; color: var(--text-deep); }

        .status-pill { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; display: inline-flex; align-items: center; gap: 5px; }
        .status-pending { background: #FEF3C7; color: #92400E; }
        .status-crown { background: #FDF2F8; color: #9D174D; border: 1px solid #FBCFE8; }

        .btn-approve {
            background: #10B981; color: white; border: none; padding: 10px 18px; border-radius: 12px; font-weight: 700; font-size: 12px;
            cursor: pointer; transition: var(--transition); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
        }
        .btn-approve:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3); background: #059669; }

        .btn-reject {
            background: #EF4444; color: white; border: none; padding: 10px 18px; border-radius: 12px; font-weight: 700; font-size: 12px;
            cursor: pointer; transition: var(--transition); box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
        }
        .btn-reject:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(239, 68, 68, 0.3); background: #DC2626; }

        /* Animation */
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .empty-visual { padding: 80px 0; text-align: center; color: var(--text-muted); }
        .empty-visual i { font-size: 48px; margin-bottom: 20px; opacity: 0.2; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="approvals-wrapper">
        <!-- Dashboard Header -->
        <div class="page-header">
            <div>
                <h1>Centralized Approvals</h1>
                <p>Monitor and authorize administrative requests across all departments.</p>
            </div>
            <div class="role-badge">
                <i class="fas fa-shield-alt" style="margin-right: 6px;"></i> AUTHORIZED ACCESS
            </div>
        </div>

        <!-- Premium Metrics Grid -->
        <div class="metrics-grid">
            <div class="metric-card" onclick="switchRequestTab('leave')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #F87171, #EF4444);"><i class="fas fa-calendar-times"></i></div>
                    <div class="metric-value"><asp:Literal ID="litLeaveCount" runat="server">0</asp:Literal></div>
                </div>
                <div class="metric-label">Leaves</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('ot')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #FBBF24, #F59E0B);"><i class="fas fa-clock"></i></div>
                    <div class="metric-value"><asp:Literal ID="litOTCount" runat="server">0</asp:Literal></div>
                </div>
                <div class="metric-label">Overtime</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('ut')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #60A5FA, #3B82F6);"><i class="fas fa-hourglass-half"></i></div>
                    <div class="metric-value"><asp:Literal ID="litUTCount" runat="server">0</asp:Literal></div>
                </div>
                <div class="metric-label">Undertime</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('resign')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #94A3B8, #64748B);"><i class="fas fa-user-slash"></i></div>
                    <div class="metric-value"><asp:Literal ID="litResignCount" runat="server">0</asp:Literal></div>
                </div>
                <div class="metric-label">Resignations</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('concern')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #34D399, #10B981);"><i class="fas fa-comment-dots"></i></div>
                    <div class="metric-value"><asp:Literal ID="litConcernCount" runat="server">0</asp:Literal></div>
                </div>
                <div class="metric-label">Concerns</div>
            </div>
        </div>

        <!-- Approval Portal Card -->
        <div class="portal-card">
            <!-- Tabs Menu -->
            <div class="tab-nav">
                <div id="btn-leave" class="tab-btn active" onclick="switchRequestTab('leave')">
                    <i class="fas fa-calendar-alt"></i> Leave Requests
                </div>
                <div id="btn-ot" class="tab-btn" onclick="switchRequestTab('ot')">
                    <i class="fas fa-stopwatch"></i> Overtime
                </div>
                <div id="btn-ut" class="tab-btn" onclick="switchRequestTab('ut')">
                    <i class="fas fa-hourglass-start"></i> Undertime
                </div>
                <div id="btn-resign" class="tab-btn" onclick="switchRequestTab('resign')">
                    <i class="fas fa-signing"></i> Resignations
                </div>
                <div id="btn-concern" class="tab-btn" onclick="switchRequestTab('concern')">
                    <i class="fas fa-headset"></i> Concerns
                </div>
            </div>

            <div class="portal-body">
                <!-- LEAVE TAB -->
                <div id="pane-leave" class="tab-pane active">
                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Type</th>
                                    <th>Date Range</th>
                                    <th>Days</th>
                                    <th>Reason</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="leaveRequestsBody"></tbody>
                        </table>
                    </div>
                </div>

                <!-- OT TAB -->
                <div id="pane-ot" class="tab-pane">
                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Date</th>
                                    <th>Hours</th>
                                    <th>Est. Pay</th>
                                    <th>Reason</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="overtimeRequestsBody">
                                <% foreach (var ot in PendingOvertimeRequests) { %>
                                    <tr>
                                        <td>
                                            <div class="user-cell">
                                                <div class="user-avatar"><%= getInitials(ot.EmployeeName) %></div>
                                                <div class="user-name"><%= ot.EmployeeName %></div>
                                            </div>
                                        </td>
                                        <td><%= ot.Date.ToString("MMM dd, yyyy") %></td>
                                        <td><strong><%= ot.RequestedHours %></strong> hrs</td>
                                        <td><span style="color:#A36A66; font-weight:700;">&#8369;<%= GetEstimatedOTRate(ot) %></span></td>
                                        <td style="font-style:italic; max-width:200px;">"<%= ot.Reason %>"</td>
                                        <td>
                                            <div style="display:flex; gap:10px; justify-content:flex-end;">
                                                <button type="button" class="btn-approve" onclick="approveOvertime('<%= ot.Id %>')">Approve</button>
                                                <button type="button" class="btn-reject" onclick="rejectOvertime('<%= ot.Id %>')">Reject</button>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                                <% if (PendingOvertimeRequests.Count == 0) { %>
                                    <tr><td colspan="6"><div class="empty-visual"><i class="fas fa-check-double"></i><p>Clear skies! No pending Overtime.</p></div></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- UNDERTIME TAB -->
                <div id="pane-ut" class="tab-pane">
                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Date</th>
                                    <th>Reason</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="undertimeRequestsBody">
                                <% foreach (var ut in PendingUndertimeRequests) { %>
                                    <tr>
                                        <td>
                                            <div class="user-cell">
                                                <div class="user-avatar"><%= getInitials(ut.EmployeeName) %></div>
                                                <div class="user-name"><%= ut.EmployeeName %></div>
                                            </div>
                                        </td>
                                        <td><%= ut.Date.ToString("MMM dd, yyyy") %></td>
                                        <td style="font-style:italic;">"<%= ut.Reason %>"</td>
                                        <td>
                                            <div style="display:flex; gap:10px; justify-content:flex-end;">
                                                <button type="button" class="btn-approve" onclick="approveUndertime('<%= ut.Id %>')">Approve</button>
                                                <button type="button" class="btn-reject" onclick="rejectUndertime('<%= ut.Id %>')">Reject</button>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                                <% if (PendingUndertimeRequests.Count == 0) { %>
                                    <tr><td colspan="4"><div class="empty-visual"><i class="fas fa-list-ul"></i><p>No waiting Undertime requests.</p></div></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- RESIGN TAB -->
                <div id="pane-resign" class="tab-pane">
                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Department</th>
                                    <th>Role</th>
                                    <th>Effective Date</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="resignationRequestsBody"></tbody>
                        </table>
                    </div>
                </div>

                <!-- CONCERN TAB -->
                <div id="pane-concern" class="tab-pane">
                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>From</th>
                                    <th>Type</th>
                                    <th>Subject</th>
                                    <th>Submission Date</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="employeeConcernsBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Redesigned Modals -->
    <div id="confirmActionModal" class="page-modal" style="display:none; position:fixed; z-index:10000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); backdrop-filter:blur(8px);">
        <div class="modal-card" style="background:white; margin:15vh auto; max-width:480px; border-radius:24px; overflow:hidden; box-shadow:0 25px 50px -12px rgba(0,0,0,0.3); animation: slideUp 0.3s ease;">
            <div style="padding:30px; text-align:center;">
                <div style="width:70px; height:70px; background:#fef2f2; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 20px; color:#8B4755; font-size:30px;">
                    <i class="fas fa-question-circle"></i>
                </div>
                <h2 id="confirmModalTitle" style="font-size:22px; font-weight:800; color:#A36A66; margin-bottom:10px;">Confirm Action</h2>
                <p id="confirmModalMessage" style="color:#9B7D7B; font-size:15px;"></p>
            </div>
            <div style="padding:20px 30px; background:#fafafa; display:flex; justify-content:flex-end; gap:12px;">
                <button type="button" style="background:#e5e7eb; color:#4b5563; border:none; padding:12px 24px; border-radius:12px; font-weight:700; cursor:pointer;" onclick="closeConfirmModal()">Cancel</button>
                <button type="button" id="btnConfirmAction" class="btn-approve" style="padding:12px 24px;">Confirm</button>
            </div>
        </div>
    </div>

    <div id="genericAlertModal" class="page-modal" style="display:none; position:fixed; z-index:10001; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); backdrop-filter:blur(8px);">
        <div style="background:white; margin:20vh auto; max-width:400px; border-radius:24px; overflow:hidden; text-align:center; padding:40px; box-shadow:0 25px 50px -12px rgba(0,0,0,0.3); animation: slideUp 0.3s ease;">
            <div id="alertModalIcon" style="font-size:60px; margin-bottom:20px;"></div>
            <h3 id="alertModalTitle" style="font-size:24px; font-weight:800; color:#A36A66; margin-bottom:10px;">Success</h3>
            <p id="alertModalMessage" style="color:#9B7D7B; font-size:15px; margin-bottom:30px;"></p>
            <button type="button" class="btn-approve" onclick="closeAlertModal()" style="min-width:160px; padding:14px;">Acknowledged</button>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            loadPendingLeaveRequests();
            loadPendingConcerns();
            loadPendingResignations();
        });

        function switchRequestTab(tabId) {
            document.querySelectorAll('.tab-pane').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(t => t.classList.remove('active'));
            
            document.getElementById('pane-' + tabId).classList.add('active');
            document.getElementById('btn-' + tabId).classList.add('active');
        }

        function loadPendingLeaveRequests() {
            PageMethods.GetPendingLeaveRequests(function (response) {
                var result = typeof response === 'string' ? JSON.parse(response) : response;
                var tbody = document.getElementById('leaveRequestsBody');
                if (!result.success || !result.data || result.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6"><div class="empty-visual"><i class="fas fa-couch"></i><p>Nobody is asking for a break right now.</p></div></td></tr>';
                    return;
                }
                tbody.innerHTML = result.data.map(function (l) {
                    var isPresident = (l.department === 'Executive');
                    var actions = isPresident ? '<span class="status-pill status-crown"><i class="fas fa-crown"></i> PRESIDENT (AUTO)</span>' :
                        '<div style="display:flex; gap:10px; justify-content:flex-end;"><button type="button" class="btn-approve" onclick="approveLeave(\''+l.id+'\', \''+l.employeeName.replace(/'/g,"")+'\')">Approve</button><button type="button" class="btn-reject" onclick="declineLeave(\''+l.id+'\')">Reject</button></div>';
                    
                    return '<tr>' +
                        '<td><div class="user-cell"><div class="user-avatar">'+getInitials(l.employeeName)+'</div><div class="user-name">'+l.employeeName+'</div></div></td>' +
                        '<td><strong>'+l.leaveType+'</strong></td>' +
                        '<td>'+l.startDate+' - '+l.endDate+'</td>' +
                        '<td>'+l.duration+' days</td>' +
                        '<td style="font-style:italic;">"'+l.reason+'"</td>' +
                        '<td>'+actions+'</td>' +
                    '</tr>';
                }).join('');
            });
        }

        function loadPendingResignations() {
            PageMethods.GetPendingResignations(function (r) {
                var res = typeof r === 'string' ? JSON.parse(r) : r;
                var tbody = document.getElementById('resignationRequestsBody');
                if (!res.success || !res.data || res.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5"><div class="empty-visual"><i class="fas fa-sun"></i><p>Everyone is happy to stay!</p></div></td></tr>';
                    return;
                }
                tbody.innerHTML = res.data.map(function (e) {
                    return '<tr>' +
                        '<td><div class="user-cell"><div class="user-avatar">'+getInitials(e.name)+'</div><div class="user-name">'+e.name+'</div></div></td>' +
                        '<td>'+e.department+'</td>' +
                        '<td>'+e.role+'</td>' +
                        '<td>'+e.dateReq+'</td>' +
                        '<td><div style="display:flex; gap:10px; justify-content:flex-end;"><button type="button" class="btn-approve" onclick="approveResign(\''+e.id+'\')">Approve</button><button type="button" class="btn-reject" onclick="declineResign(\''+e.id+'\')">Decline</button></div></td>' +
                    '</tr>';
                }).join('');
            });
        }

        function loadPendingConcerns() {
            PageMethods.GetPendingConcerns(function (r) {
                var res = typeof r === 'string' ? JSON.parse(r) : r;
                var tbody = document.getElementById('employeeConcernsBody');
                if (!res.success || !res.data || res.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="4"><div class="empty-visual"><i class="fas fa-smile-beam"></i><p>Zero active concerns found.</p></div></td></tr>';
                    return;
                }
                tbody.innerHTML = res.data.map(function (c) {
                    return '<tr>' +
                        '<td><div class="user-cell"><div class="user-avatar">'+getInitials(c.employeeName)+'</div><div class="user-name">'+c.employeeName+'</div></div></td>' +
                        '<td><span class="status-pill status-pending">'+c.concernType+'</span></td>' +
                        '<td><strong>'+c.subject+'</strong></td>' +
                        '<td>'+c.submittedDate+'</td>' +
                        '<td style="text-align:right;"><button type="button" class="btn-approve" onclick="resolveConcern(\''+c.id+'\', \''+c.employeeName.replace(/'/g,"")+'\')">Resolve</button></td>' +
                    '</tr>';
                }).join('');
            });
        }

        function approveLeave(id, name) {
            showConfirm("Approve Request", "Authorize leave for " + name + "?", function() {
                PageMethods.ApproveLeaveRequest(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Confirmed", "Leave request has been authorized.", "success"); loadPendingLeaveRequests(); }
                    else showAlert("Failed", res.message, "error");
                });
            });
        }

        function declineLeave(id) {
            showConfirm("Decline Request", "Are you sure you want to reject this leave request?", function() {
                PageMethods.DeclineLeaveRequest(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Leave request has been declined.", "success"); loadPendingLeaveRequests(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function approveOvertime(id) {
            showConfirm("Approve Overtime", "Confirm manual overtime authorization?", function() {
                PageMethods.ApproveOvertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Authorized", "Overtime credit granted.", "success"); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function rejectOvertime(id) {
            showConfirm("Reject Overtime", "Decline this overtime request?", function() {
                PageMethods.RejectOvertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Overtime request declined.", "success"); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function approveUndertime(id) {
            showConfirm("Authorize Undertime", "Confirm early departure authorization?", function() {
                PageMethods.ApproveUndertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Authorized", "Undertime record updated.", "success"); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function rejectUndertime(id) {
            showConfirm("Reject Undertime", "Decline this undertime request?", function() {
                PageMethods.RejectUndertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Undertime request declined.", "success"); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function approveResign(id) {
            showConfirm("Approve Resignation", "This will move the employee to the resigned registry and deactivate their account. Proceed?", function() {
                PageMethods.ApproveResignation(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Processed", "Employee has been successfully resigned.", "success"); loadPendingResignations(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function declineResign(id) {
            showConfirm("Decline Resignation", "Cancel this resignation request and keep the employee active?", function() {
                PageMethods.DeclineResignation(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Cancelled", "Resignation request has been rejected.", "success"); loadPendingResignations(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function resolveConcern(id, name) {
            showConfirm("Resolve Concern", "Mark this concern from " + name + " as resolved?", function() {
                PageMethods.ResolveConcern(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Resolved", "Employee concern has been settled.", "success"); loadPendingConcerns(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function getInitials(name) {
            if (!name) return '??';
            var p = name.split(' ');
            return p.length >= 2 ? (p[0][0] + p[p.length-1][0]).toUpperCase() : name.substring(0,2).toUpperCase();
        }

        function showConfirm(title, message, callback) {
            document.getElementById('confirmModalTitle').textContent = title;
            document.getElementById('confirmModalMessage').textContent = message;
            document.getElementById('btnConfirmAction').onclick = function() { closeConfirmModal(); callback(); };
            document.getElementById('confirmActionModal').style.display = 'block';
        }
        function closeConfirmModal() { document.getElementById('confirmActionModal').style.display = 'none'; }
        
        function showAlert(title, message, type) {
            const m = document.getElementById('genericAlertModal');
            document.getElementById('alertModalTitle').textContent = title;
            document.getElementById('alertModalMessage').textContent = message;
            const icon = document.getElementById('alertModalIcon');
            icon.innerHTML = type === 'success' ? '<i class="fas fa-check-circle" style="color:#10b981;"></i>' : '<i class="fas fa-times-circle" style="color:#ef4444;"></i>';
            m.style.display = 'block';
        }
        function closeAlertModal() { document.getElementById('genericAlertModal').style.display = 'none'; }
    </script>
</asp:Content>
