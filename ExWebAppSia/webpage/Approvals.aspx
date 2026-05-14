<%@ Page Title="Approvals" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Approvals.aspx.cs" Inherits="ExWebAppSia.webpage.Approvals" %>

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
        .metrics-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 20px; margin-bottom: 35px; }
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

        /* Report Buttons Style */
        .report-controls {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            padding: 15px;
            background: #fffcfb;
            border-radius: 16px;
            border: 1px solid var(--border-soft);
        }
        
        .btn-report {
            padding: 10px 18px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            box-shadow: 0 4px 10px rgba(163, 106, 102, 0.1);
        }
        
        .btn-report-primary { background: #A36A66; color: white; }
        .btn-report-primary:hover { background: #8B4755; transform: translateY(-2px); box-shadow: 0 6px 15px rgba(163, 106, 102, 0.2); }
        
        .btn-report-secondary { background: white; color: #A36A66; border: 1px solid #fceceb; }
        .btn-report-secondary:hover { background: #fff1f0; transform: translateY(-2px); }

        /* Termination Modal Enhancements */
        .term-type-label {
            flex: 1; border: 2px solid #e2e8f0; padding: 15px; border-radius: 12px; 
            cursor: pointer; display: flex; align-items: center; gap: 12px; 
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            background: white;
            text-align: left;
        }
        .term-type-label:hover { border-color: #cbd5e1; transform: translateY(-2px); }
        .term-type-label input[type="radio"] { width: 18px; height: 18px; accent-color: #ef4444; }
        
        .upload-dropzone {
            position: relative; border: 2px dashed #cbd5e1; border-radius: 16px; 
            padding: 30px 20px; text-align: center; background: #f8fafc; 
            transition: all 0.3s ease;
        }
        .upload-dropzone:hover { border-color: #ef4444; background: #fff1f2; }
        .upload-dropzone.active { border-color: #10b981; background: #f0fdf4; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField ID="hdnConcernsJson" runat="server" />
    <asp:HiddenField ID="hdnCurrentAdminId" runat="server" ClientIDMode="Static" />
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
                    <div class="metric-value"><span id="cnt-leave"><asp:Literal ID="litLeaveCount" runat="server">0</asp:Literal></span></div>
                </div>
                <div class="metric-label">Leaves</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('ot')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #FBBF24, #F59E0B);"><i class="fas fa-clock"></i></div>
                    <div class="metric-value"><span id="cnt-ot"><asp:Literal ID="litOTCount" runat="server">0</asp:Literal></span></div>
                </div>
                <div class="metric-label">Overtime</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('ut')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #60A5FA, #3B82F6);"><i class="fas fa-hourglass-half"></i></div>
                    <div class="metric-value"><span id="cnt-ut"><asp:Literal ID="litUTCount" runat="server">0</asp:Literal></span></div>
                </div>
                <div class="metric-label">Undertime</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('resign')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #94A3B8, #64748B);"><i class="fas fa-user-slash"></i></div>
                    <div class="metric-value"><span id="cnt-resign"><asp:Literal ID="litResignCount" runat="server">0</asp:Literal></span></div>
                </div>
                <div class="metric-label">Resignations</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('concern')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #34D399, #10B981);"><i class="fas fa-comment-dots"></i></div>
                    <div class="metric-value"><span id="cnt-concern"><asp:Literal ID="litConcernCount" runat="server">0</asp:Literal></span></div>
                </div>
                <div class="metric-label">Concerns</div>
            </div>
            <div class="metric-card" onclick="switchRequestTab('loan')">
                <div class="metric-header">
                    <div class="metric-icon" style="background: linear-gradient(135deg, #10B981, #059669);"><i class="fas fa-hand-holding-usd"></i></div>
                    <div class="metric-value"><span id="cnt-loan">0</span></div>
                </div>
                <div class="metric-label">Loans</div>
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
                <div id="btn-loan" class="tab-btn" onclick="switchRequestTab('loan')">
                    <i class="fas fa-hand-holding-usd"></i> Loan Requests
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
                                    <th>OT Date</th>
                                    <th>Shift Time</th>
                                    <th>Requested Hours</th>
                                    <th>Est. Pay</th>
                                    <th>Justification</th>
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
                                        <td><span style="color:#A36A66; font-weight:700;"><%= ot.StartTime %> - <%= ot.EndTime %></span></td>
                                        <td><strong><%= ot.RequestedHours %></strong> hrs</td>
                                        <td><span style="color:#A36A66; font-weight:700;">&#8369;<%= GetEstimatedOTRate(ot) %></span></td>
                                        <td style="font-style:italic; max-width:250px;">"<%= ot.Reason %>"</td>
                                        <td>
                                            <div style="display:flex; gap:10px; justify-content:flex-end;">
                                                <% if (string.Equals(ot.EmployeeId, CurrentAdminId, StringComparison.OrdinalIgnoreCase)) { %>
                                                    <span class="status-pill status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>
                                                <% } else { %>
                                                    <button type="button" class="btn-approve" onclick="approveOvertime('<%= ot.Id %>')">Approve</button>
                                                    <button type="button" class="btn-reject" onclick="rejectOvertime('<%= ot.Id %>')">Reject</button>
                                                <% } %>
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
                                    <th>Requested Departure</th>
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
                                        <td><span style="color:#A36A66; font-weight:700;"><%= !string.IsNullOrEmpty(ut.RequestedDepartureTime) ? ut.RequestedDepartureTime : "Unspecified" %></span></td>
                                        <td style="font-style:italic;">"<%= ut.Reason %>"</td>
                                        <td>
                                            <div style="display:flex; gap:10px; justify-content:flex-end;">
                                                <% if (string.Equals(ut.EmployeeId, CurrentAdminId, StringComparison.OrdinalIgnoreCase)) { %>
                                                    <span class="status-pill status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>
                                                <% } else { %>
                                                    <button type="button" class="btn-approve" onclick="approveUndertime('<%= ut.Id %>')">Approve</button>
                                                    <button type="button" class="btn-reject" onclick="rejectUndertime('<%= ut.Id %>')">Reject</button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                                <% if (PendingUndertimeRequests.Count == 0) { %>
                                    <tr><td colspan="5"><div class="empty-visual"><i class="fas fa-list-ul"></i><p>No waiting Undertime requests.</p></div></td></tr>
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

                <!-- LOAN TAB -->
                <div id="pane-loan" class="tab-pane">
                    <!-- Reports Section -->
                    <div class="report-controls">
                        <asp:LinkButton ID="btnLoanReport" runat="server" OnClick="btnLoanReport_Click" CssClass="btn-report btn-report-primary">
                            <i class="fas fa-file-pdf"></i> Export Loan Details Report (PDF)
                        </asp:LinkButton>
                    </div>

                    <div class="table-responsive">
                        <table class="premium-table">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Type</th>
                                    <th>Agency</th>
                                    <th>Requested</th>
                                    <th>Status</th>
                                    <th style="text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="loanRequestsBody"></tbody>
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

    <!-- Termination Modal -->
    <div id="terminationModal" class="page-modal" style="display:none; position:fixed; z-index:10002; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.6); backdrop-filter:blur(10px);">
        <div class="modal-card" style="background:white; margin:10vh auto; max-width:550px; border-radius:28px; overflow:hidden; box-shadow:0 25px 50px -12px rgba(0,0,0,0.4); animation: slideUp 0.3s ease;">
            <div style="background: #ef4444; padding: 20px 30px; color: white; display: flex; align-items: center; gap: 12px;">
                <i class="fas fa-user-times" style="font-size: 20px;"></i>
                <h2 style="margin: 0; font-size: 20px; font-weight: 800;">Finalize Termination</h2>
            </div>
            <div style="padding: 30px;">
                <div style="background: #fff1f2; border-left: 4px solid #ef4444; padding: 15px; border-radius: 12px; margin-bottom: 25px;">
                    <p style="margin: 0; font-size: 13px; color: #991b1b; font-weight: 600; line-height: 1.5;">
                        <i class="fas fa-exclamation-triangle" style="margin-right: 5px;"></i>
                        Critical: This action will permanently deactivate the employee's account and revoke all system access tokens immediately.
                    </p>
                </div>

                <div style="margin-bottom: 25px;">
                    <label style="display: block; font-weight: 700; margin-bottom: 12px; color: #475569; font-size: 14px;">Termination Type</label>
                    <div style="display: flex; gap: 15px;">
                        <label class="term-type-label">
                            <input type="radio" name="termType" value="Standard" checked onchange="toggleTermFields()">
                            <div>
                                <div style="font-weight: 700; font-size: 14px; color: #1e293b;">Standard</div>
                                <div style="font-size: 11px; color: #64748b;">Requires Clearance</div>
                            </div>
                        </label>
                        <label class="term-type-label">
                            <input type="radio" name="termType" value="Forced" onchange="toggleTermFields()">
                            <div>
                                <div style="font-weight: 700; font-size: 14px; color: #1e293b;">Forced / Immediate</div>
                                <div style="font-size: 11px; color: #64748b;">AWOL / Disciplinary</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Option 1: Clearance Upload -->
                <div id="clearanceField" style="margin-bottom: 25px;">
                    <label style="display: block; font-weight: 700; margin-bottom: 12px; color: #475569; font-size: 14px;">Upload Signed Clearance Form *</label>
                    <div class="upload-dropzone" id="dropZone">
                        <i class="fas fa-file-upload" style="font-size: 28px; color: #94a3b8; margin-bottom: 10px;"></i>
                        <div id="fileName" style="font-size: 13px; color: #64748b; font-weight: 600;">Click to select signed clearance (PDF)</div>
                        <input type="file" id="clearanceUpload" accept=".pdf" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer;" onchange="handleFileSelect(this)">
                    </div>
                </div>

                <!-- Option 2: Forced Reason -->
                <div id="forcedField" style="margin-bottom: 25px; display: none;">
                    <label style="display: block; font-weight: 700; margin-bottom: 12px; color: #475569; font-size: 14px;">Immediate Termination Reason *</label>
                    <textarea id="forcedReason" style="width: 100%; padding: 15px; border: 1.5px solid #e2e8f0; border-radius: 12px; font-size: 14px; min-height: 120px; resize: vertical; background: #f8fafc;" placeholder="Type the reason (e.g., AWOL, policy violation)..." oninput="validateTermForm()"></textarea>
                </div>
            </div>
            <div style="padding: 20px 30px; background: #f8fafc; border-top: 1px solid #f1f5f9; display: flex; justify-content: flex-end; gap: 12px;">
                <button type="button" onclick="closeTermModal()" style="background:#e2e8f0; border:none; padding:12px 24px; border-radius:12px; cursor:pointer; font-weight:700; color: #475569; transition: all 0.2s;">Cancel</button>
                <button type="button" id="btnConfirmTermination" disabled style="background:#ef4444; color:white; border:none; padding:12px 28px; border-radius:12px; cursor:pointer; font-weight:800; opacity: 0.5; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2); transition: all 0.2s;">Confirm Termination</button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            loadPendingLeaveRequests();
            loadPendingConcerns();
            loadPendingResignations();
            loadLoanRequests();
        });

        function switchRequestTab(tabId) {
            document.querySelectorAll('.tab-pane').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(t => t.classList.remove('active'));
            
            document.getElementById('pane-' + tabId).classList.add('active');
            document.getElementById('btn-' + tabId).classList.add('active');
        }

        function refreshCounts() {
            PageMethods.GetUpdatedCounts(function(r) {
                if(r && r.success) {
                    document.getElementById('cnt-leave').textContent = r.leaveCount;
                    document.getElementById('cnt-ot').textContent = r.otCount;
                    document.getElementById('cnt-ut').textContent = r.utCount;
                    document.getElementById('cnt-resign').textContent = r.resignCount;
                    document.getElementById('cnt-concern').textContent = r.concernCount;
                }
            });
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
                    var isSelf = (l.empId && result.currentAdminId && l.empId.toString().toLowerCase() === result.currentAdminId.toString().toLowerCase());
                    
                    var actions = isPresident ? '<span class="status-pill status-crown"><i class="fas fa-crown"></i> PRESIDENT (AUTO)</span>' :
                                  isSelf ? '<span class="status-pill status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
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
                    var isSelf = (e.empId && res.currentAdminId && e.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    var actions = isSelf ? '<span class="status-pill status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                        '<div style="display:flex; gap:10px; justify-content:flex-end;"><button type="button" class="btn-approve" onclick="approveResign(\''+e.id+'\')">Approve</button><button type="button" class="btn-reject" onclick="declineResign(\''+e.id+'\')">Decline</button></div>';
                    
                    return '<tr>' +
                        '<td><div class="user-cell"><div class="user-avatar">'+getInitials(e.name)+'</div><div class="user-name">'+e.name+'</div></div></td>' +
                        '<td>'+e.department+'</td>' +
                        '<td>'+e.role+'</td>' +
                        '<td>'+e.dateReq+'</td>' +
                        '<td>'+actions+'</td>' +
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
                    var isSelf = (c.empId && res.currentAdminId && c.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    var actions = isSelf ? '<span class="status-pill status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                  '<button type="button" class="btn-approve" onclick="resolveConcern(\''+c.id+'\', \''+c.employeeName.replace(/'/g,"")+'\')">Resolve</button>';

                    return '<tr>' +
                        '<td><div class="user-cell"><div class="user-avatar">'+getInitials(c.employeeName)+'</div><div class="user-name">'+c.employeeName+'</div></div></td>' +
                        '<td><span class="status-pill status-pending">'+c.concernType+'</span></td>' +
                        '<td><strong>'+c.subject+'</strong></td>' +
                        '<td>'+c.submittedDate+'</td>' +
                        '<td style="text-align:right;">'+actions+'</td>' +
                    '</tr>';
                }).join('');
            });
        }

        function approveLeave(id, name) {
            showConfirm("Approve Request", "Authorize leave for " + name + "?", function() {
                PageMethods.ApproveLeaveRequest(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Confirmed", "Leave request has been authorized.", "success"); loadPendingLeaveRequests(); refreshCounts(); }
                    else showAlert("Failed", res.message, "error");
                });
            });
        }

        function declineLeave(id) {
            showConfirm("Decline Request", "Are you sure you want to reject this leave request?", function() {
                PageMethods.DeclineLeaveRequest(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Leave request has been declined.", "success"); loadPendingLeaveRequests(); refreshCounts(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function approveOvertime(id) {
            showConfirm("Approve Overtime", "Confirm manual overtime authorization?", function() {
                PageMethods.ApproveOvertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Authorized", "Overtime credit granted.", "success"); refreshCounts(); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function rejectOvertime(id) {
            showConfirm("Reject Overtime", "Decline this overtime request?", function() {
                PageMethods.RejectOvertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Overtime request declined.", "success"); refreshCounts(); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function approveUndertime(id) {
            showConfirm("Authorize Undertime", "Confirm early departure authorization?", function() {
                PageMethods.ApproveUndertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Authorized", "Undertime record updated.", "success"); refreshCounts(); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function rejectUndertime(id) {
            showConfirm("Reject Undertime", "Decline this undertime request?", function() {
                PageMethods.RejectUndertime(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Rejected", "Undertime request declined.", "success"); refreshCounts(); setTimeout(() => window.location.reload(), 1000); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        let currentResignId = null;
        let clearanceBase64 = null;

        function approveResign(id) {
            currentResignId = id;
            clearanceBase64 = null;
            document.getElementById('clearanceUpload').value = '';
            document.getElementById('fileName').textContent = 'Click to select signed clearance (PDF)';
            document.getElementById('forcedReason').value = '';
            document.getElementById('dropZone').classList.remove('active');
            
            const modal = document.getElementById('terminationModal');
            modal.style.display = 'block';
            toggleTermFields();
        }

        function closeTermModal() {
            document.getElementById('terminationModal').style.display = 'none';
        }

        function toggleTermFields() {
            const type = document.querySelector('input[name="termType"]:checked').value;
            const labels = document.querySelectorAll('.term-type-label');
            
            labels.forEach(l => {
                const radio = l.querySelector('input');
                if (radio.checked) {
                    l.style.borderColor = '#ef4444';
                    l.style.background = '#fff1f2';
                    l.style.boxShadow = '0 4px 12px rgba(239, 68, 68, 0.1)';
                } else {
                    l.style.borderColor = '#e2e8f0';
                    l.style.background = 'white';
                    l.style.boxShadow = 'none';
                }
            });

            if (type === 'Standard') {
                document.getElementById('clearanceField').style.display = 'block';
                document.getElementById('forcedField').style.display = 'none';
            } else {
                document.getElementById('clearanceField').style.display = 'none';
                document.getElementById('forcedField').style.display = 'block';
            }
            validateTermForm();
        }

        function handleFileSelect(input) {
            const file = input.files[0];
            const dropZone = document.getElementById('dropZone');
            if (!file) return;
            
            if (file.type !== 'application/pdf') {
                showAlert('Invalid File', 'Please upload a PDF clearance form.', 'error');
                input.value = '';
                return;
            }

            document.getElementById('fileName').textContent = file.name;
            dropZone.classList.add('active');

            const reader = new FileReader();
            reader.onload = function(e) {
                clearanceBase64 = e.target.result.split(',')[1];
                validateTermForm();
            };
            reader.readAsDataURL(file);
        }

        function validateTermForm() {
            const type = document.querySelector('input[name="termType"]:checked').value;
            const btn = document.getElementById('btnConfirmTermination');
            let isValid = false;

            if (type === 'Standard') {
                isValid = clearanceBase64 !== null;
            } else {
                isValid = document.getElementById('forcedReason').value.trim().length > 0;
            }

            btn.disabled = !isValid;
            btn.style.opacity = isValid ? '1' : '0.5';
        }

        document.getElementById('btnConfirmTermination').onclick = function() {
            const type = document.querySelector('input[name="termType"]:checked').value;
            const reason = document.getElementById('forcedReason').value;
            const btn = this;
            
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';

            PageMethods.FinalizeResignation(currentResignId, type, reason, clearanceBase64, function(r) {
                const res = typeof r === 'string' ? JSON.parse(r) : r;
                if (res.success) {
                    closeTermModal();
                    showAlert("Employee Terminated", "Account deactivated and status updated immediately.", "success");
                    loadPendingResignations();
                    refreshCounts();
                } else {
                    showAlert("Termination Failed", res.message, "error");
                }
                btn.disabled = false;
                btn.textContent = 'Confirm Termination';
            });
        };

        function declineResign(id) {
            showConfirm("Decline Resignation", "Cancel this resignation request and keep the employee active?", function() {
                PageMethods.DeclineResignation(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Cancelled", "Resignation request has been rejected.", "success"); loadPendingResignations(); refreshCounts(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        function resolveConcern(id, name) {
            showConfirm("Resolve Concern", "Mark this concern from " + name + " as resolved?", function() {
                PageMethods.ResolveConcern(id, function(r) {
                    var res = typeof r === 'string' ? JSON.parse(r) : r;
                    if(res.success) { showAlert("Resolved", "Employee concern has been settled.", "success"); loadPendingConcerns(); refreshCounts(); }
                    else showAlert("Error", res.message, "error");
                });
            });
        }

        // Loan Management
        function loadLoanRequests() {
            const currentUserId = document.getElementById('hdnCurrentAdminId')?.value || "";
            const handler = '<%= ResolveUrl("~/Handler/LoanHandler.ashx") %>?action=getall';
            fetch(handler)
                .then(r => r.json())
                .then(res => {
                    const tbody = document.getElementById('loanRequestsBody');
                    const cntLoan = document.getElementById('cnt-loan');
                    
                    if (!res.success || !res.data || res.data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="6"><div class="empty-visual"><i class="fas fa-hand-holding-usd"></i><p>No active loan requests found.</p></div></td></tr>';
                        cntLoan.textContent = '0';
                        return;
                    }
                    
                    const pendingCount = res.data.filter(l => l.Status === 'PENDING').length;
                    cntLoan.textContent = pendingCount;

                    tbody.innerHTML = res.data.map(l => {
                        const statusClass = l.Status === 'PENDING' ? 'status-pending' : (l.Status === 'APPROVED' ? 'status-active-emp' : 'status-declined');
                        const dateReq = new Date(l.RequestDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
                        
                        let actions = '';
                        if (l.Status === 'PENDING') {
                            if (l.EmployeeId === currentUserId) {
                                actions = `<div style="text-align:right;"><span class="status-badge" style="background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; font-size: 10px; padding: 4px 8px; border-radius: 4px; display: inline-block;">SELF-REQUEST</span></div>`;
                            } else {
                                actions = `
                                    <div style="display:flex; gap:10px; justify-content:flex-end;">
                                        <button type="button" class="btn-approve" onclick="updateLoanStatus('${l.Id}', 'APPROVED', '${l.EmployeeName}')">Approve</button>
                                        <button type="button" class="btn-reject" onclick="updateLoanStatus('${l.Id}', 'DECLINED', '${l.EmployeeName}')">Decline</button>
                                    </div>`;
                            }
                        } else {
                            actions = `<div style="text-align:right;"><span class="status-pill status-crown"><i class="fas fa-check-circle"></i> PROCESSED</span></div>`;
                        }

                        return `<tr>
                            <td>
                                <div class="user-cell">
                                    <div class="user-avatar">${getInitials(l.EmployeeName)}</div>
                                    <div class="user-name">${l.EmployeeName}</div>
                                </div>
                            </td>
                            <td><strong>${l.LoanType}</strong></td>
                            <td><span class="status-pill" style="background:#f1f5f9; color:#475569;">${l.Agency}</span></td>
                            <td>${dateReq}</td>
                            <td><span class="status-pill ${statusClass}">${l.Status}</span></td>
                            <td>${actions}</td>
                        </tr>`;
                    }).join('');
                });
        }

        function updateLoanStatus(id, status, name) {
            const actionText = status === 'APPROVED' ? 'Approve' : 'Decline';
            showConfirm(actionText + " Loan", "Confirm " + actionText.toLowerCase() + " for " + name + "'s loan?", function() {
                const formData = new FormData();
                formData.append('id', id);
                formData.append('status', status);

                fetch('<%= ResolveUrl("~/Handler/LoanHandler.ashx") %>?action=updatestatus', {
                    method: 'POST',
                    body: formData
                })
                .then(r => r.json())
                .then(res => {
                    if (res.success) {
                        showAlert("Success", "Loan status updated successfully.", "success");
                        loadLoanRequests();
                    } else {
                        showAlert("Error", res.message, "error");
                    }
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
