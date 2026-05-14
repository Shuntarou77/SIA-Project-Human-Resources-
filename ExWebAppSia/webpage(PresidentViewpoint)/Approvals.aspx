<%@ Page Title="President Approvals" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Approvals.aspx.cs" Inherits="ExWebAppSia.webpage_PresidentViewpoint_.Approvals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style type="text/css">
        :root {
            --primary-color: #A44F56;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --bg-light: #f8fafc;
            --card-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body { background-color: var(--bg-light); color: #334155; }
        .approvals-container { padding: 30px; max-width: 1600px; margin: 0 auto; }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 20px;
            margin-bottom: 35px;
        }

        .metric-card {
            background: white;
            padding: 24px;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: var(--transition);
            border-left: 4px solid var(--primary-color);
            cursor: pointer;
        }

        .metric-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }

        .metric-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }

        .metric-info .count { font-size: 28px; font-weight: 800; color: #1e293b; line-height: 1; margin-bottom: 5px; }
        .metric-info .label { font-size: 13px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }

        .dashboard-content { background: white; border-radius: 20px; box-shadow: var(--card-shadow); overflow: hidden; }

        .tabs-header {
            display: flex;
            background: #fff;
            padding: 0 20px;
            border-bottom: 1px solid #f1f5f9;
        }

        .tab-trigger {
            padding: 20px 25px;
            font-weight: 700;
            font-size: 14px;
            color: #64748b;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .tab-trigger:hover { color: var(--primary-color); background: #fff5f5; }
        .tab-trigger.active { color: var(--primary-color); border-bottom-color: var(--primary-color); background: #fff5f5; }

        .tab-content { display: none; width: 100%; }
        .tab-content.active { display: block; animation: fadeIn 0.4s ease; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .table-responsive { overflow-x: auto; min-height: 400px; padding: 10px; }
        .modern-table { width: 100%; border-collapse: collapse; text-align: left; }
        .modern-table th { padding: 16px 20px; background: #f8fafc; font-weight: 700; color: #475569; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #f1f5f9; }
        .modern-table td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #1e293b; vertical-align: middle; }

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }
        .status-pending { background: #fff7ed; color: #c2410c; }
        .status-auto { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }

        .btn-action-approve { background: var(--success-color); color: white; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: var(--transition); }
        .btn-action-approve:hover { background: #059669; transform: scale(1.05); }

        .btn-action-reject { background: var(--danger-color); color: white; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: var(--transition); }
        .btn-action-reject:hover { background: #dc2626; transform: scale(1.05); }

        .page-modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.4); backdrop-filter: blur(4px); }
        .modal-content { background: white; margin: 15vh auto; width: 90%; max-width: 500px; border-radius: 20px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); }
        .modal-header { padding: 20px 25px; border-bottom: 1px solid #f1f5f9; background: var(--primary-color); color: white; }
        .modal-body { padding: 25px; }
        .modal-footer { padding: 15px 25px; background: #f8fafc; display: flex; justify-content: flex-end; gap: 10px; }

        .empty-state { padding: 80px 20px; text-align: center; color: #94a3b8; }
        .auto-approve-notice { background: #fffbeb; border: 1px solid #fef3c7; color: #92400e; padding: 12px 20px; border-radius: 12px; margin-bottom: 25px; font-size: 14px; display: flex; align-items: center; gap: 12px; }

        /* Report Buttons Style */
        .report-controls {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            padding: 15px;
            background: #fffcfb;
            border-radius: 16px;
            border: 1px solid #f1f5f9;
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
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        
        .btn-report-primary { background: var(--primary-color); color: white; }
        .btn-report-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(164, 79, 86, 0.2); }

        /* Termination Modal Enhancements */
        .term-type-label {
            flex: 1; border: 2px solid #e2e8f0; padding: 15px; border-radius: 12px; 
            cursor: pointer; display: flex; align-items: center; gap: 12px; 
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            background: white;
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
    <div class="approvals-container">
        <div style="margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <h1 style="font-size: 28px; font-weight: 800; color: #1e293b; margin-bottom: 5px;">Executive Approvals</h1>
                <p style="color: #64748b; font-weight: 500;">Review and finalize all pending personnel requests.</p>
            </div>
            <div style="background: white; padding: 10px 20px; border-radius: 12px; border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 10px;">
                <span style="font-size: 14px; font-weight: 600; color: #475569;">Presidential Guard</span>
                <i class="fas fa-crown" style="color: gold;"></i>
            </div>
        </div>


        <div class="metrics-grid">
            <div class="metric-card" onclick="switchTab('leave-tab')">
                <div class="metric-icon" style="background: #A44F56;"><i class="fas fa-calendar-alt"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-leave"><asp:Literal ID="litLeaveCount" runat="server">0</asp:Literal></span></div>
                    <div class="label">Pending Leaves</div>
                </div>
            </div>
            <div class="metric-card" onclick="switchTab('ot-tab')">
                <div class="metric-icon" style="background: #f59e0b;"><i class="fas fa-clock"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-ot"><asp:Literal ID="litOTCount" runat="server">0</asp:Literal></span></div>
                    <div class="label">Overtime</div>
                </div>
            </div>
            <div class="metric-card" onclick="switchTab('ut-tab')">
                <div class="metric-icon" style="background: #3b82f6;"><i class="fas fa-hourglass-start"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-ut"><asp:Literal ID="litUTCount" runat="server">0</asp:Literal></span></div>
                    <div class="label">Undertime</div>
                </div>
            </div>
            <div class="metric-card" onclick="switchTab('resign-tab')">
                <div class="metric-icon" style="background: #64748b;"><i class="fas fa-user-slash"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-resign"><asp:Literal ID="litResignCount" runat="server">0</asp:Literal></span></div>
                    <div class="label">Resignations</div>
                </div>
            </div>
            <div class="metric-card" onclick="switchTab('concern-tab')">
                <div class="metric-icon" style="background: #10b981;"><i class="fas fa-exclamation-triangle"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-concern"><asp:Literal ID="litConcernCount" runat="server">0</asp:Literal></span></div>
                    <div class="label">Concerns</div>
                </div>
            </div>
            <div class="metric-card" onclick="switchTab('loan-tab')">
                <div class="metric-icon" style="background: #059669;"><i class="fas fa-hand-holding-usd"></i></div>
                <div class="metric-info">
                    <div class="count"><span id="cnt-loan">0</span></div>
                    <div class="label">Loans</div>
                </div>
            </div>
        </div>

        <div class="dashboard-content">
            <div class="tabs-header">
                <div id="btn-leave" class="tab-trigger active" onclick="switchTab('leave-tab')">Leaves</div>
                <div id="btn-ot" class="tab-trigger" onclick="switchTab('ot-tab')">Overtime</div>
                <div id="btn-ut" class="tab-trigger" onclick="switchTab('ut-tab')">Undertime</div>
                <div id="btn-resign" class="tab-trigger" onclick="switchTab('resign-tab')">Resignations</div>
                <div id="btn-concern" class="tab-trigger" onclick="switchTab('concern-tab')">Concerns</div>
                <div id="btn-loan" class="tab-trigger" onclick="switchTab('loan-tab')">Loans</div>
            </div>

            <div class="tab-body">
                <!-- Tab contents with same table structure as Super Admin -->
                <div id="leave-tab" class="tab-content active">
                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>Admin Name</th><th>Type</th><th>Dates</th><th>Reason</th><th>Status</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="leaveBody"></tbody>
                        </table>
                    </div>
                </div>
                <!-- Other tabs similarly structured... -->
                <div id="ot-tab" class="tab-content">
                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>Admin Name</th><th>OT Date</th><th>Shift Time</th><th>Hours</th><th>Justification</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="otBody"></tbody>
                        </table>
                    </div>
                </div>
                <div id="ut-tab" class="tab-content">
                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>Admin Name</th><th>Date</th><th>Requested Departure</th><th>Reason</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="utBody"></tbody>
                        </table>
                    </div>
                </div>
                <div id="resign-tab" class="tab-content">
                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>Admin Name</th><th>Hired Date</th><th>Effectivity</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="resignBody"></tbody>
                        </table>
                    </div>
                </div>
                <div id="concern-tab" class="tab-content">
                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>From</th><th>Subject</th><th>Type</th><th>Submitted</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="concernBody"></tbody>
                        </table>
                    </div>
                </div>
                <div id="loan-tab" class="tab-content">
                    <!-- Reports Section -->
                    <div class="report-controls">
                        <asp:LinkButton ID="btnLoanReport" runat="server" OnClick="btnLoanReport_Click" CssClass="btn-report btn-report-primary">
                            <i class="fas fa-file-pdf"></i> Export Loan Details Report (PDF)
                        </asp:LinkButton>
                    </div>

                    <div class="table-responsive">
                        <table class="modern-table">
                            <thead>
                                <tr><th>Employee</th><th>Type</th><th>Agency</th><th>Requested</th><th>Status</th><th>Actions</th></tr>
                            </thead>
                            <tbody id="loanBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Termination Modal -->
    <div id="terminationModal" class="page-modal">
        <div class="modal-content" style="max-width: 550px;">
            <div class="modal-header" style="background: #ef4444;">
                <i class="fas fa-user-times" style="margin-right: 10px;"></i> Finalize Termination
            </div>
            <div class="modal-body">
                <div style="background: #fff1f2; border-left: 4px solid #ef4444; padding: 12px; border-radius: 4px; margin-bottom: 20px;">
                    <p style="margin: 0; font-size: 13px; color: #991b1b; font-weight: 600;">
                        Warning: This action will permanently deactivate the employee's account and terminate all system access immediately.
                    </p>
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-weight: 700; margin-bottom: 8px; color: #475569;">Termination Type</label>
                    <div style="display: flex; gap: 15px;">
                        <label class="term-type-label">
                            <input type="radio" name="termType" value="Standard" checked onchange="toggleTermFields()">
                            <div>
                                <div style="font-weight: 700; font-size: 14px;">Standard</div>
                                <div style="font-size: 11px; color: #64748b;">Requires Clearance</div>
                            </div>
                        </label>
                        <label class="term-type-label">
                            <input type="radio" name="termType" value="Forced" onchange="toggleTermFields()">
                            <div>
                                <div style="font-weight: 700; font-size: 14px;">Forced / Immediate</div>
                                <div style="font-size: 11px; color: #64748b;">AWOL / Disciplinary</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Option 1: Clearance Upload -->
                <div id="clearanceField" style="margin-bottom: 20px;">
                    <label style="display: block; font-weight: 700; margin-bottom: 8px; color: #475569;">Upload Signed Clearance Form *</label>
                    <div class="upload-dropzone" id="dropZone">
                        <i class="fas fa-file-upload" style="font-size: 24px; color: #94a3b8; margin-bottom: 8px;"></i>
                        <div id="fileName" style="font-size: 13px; color: #64748b; font-weight: 600;">Click to select signed clearance (PDF)</div>
                        <input type="file" id="clearanceUpload" accept=".pdf" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer;" onchange="handleFileSelect(this)">
                    </div>
                </div>

                <!-- Option 2: Forced Reason -->
                <div id="forcedField" style="margin-bottom: 20px; display: none;">
                    <label style="display: block; font-weight: 700; margin-bottom: 8px; color: #475569;">Immediate Termination Reason *</label>
                    <textarea id="forcedReason" style="width: 100%; padding: 12px; border: 1.5px solid #eee; border-radius: 10px; font-size: 14px; min-height: 100px; resize: vertical;" placeholder="Type the reason (e.g., AWOL, policy violation)..." oninput="validateTermForm()"></textarea>
                </div>
            </div>
            <div class="modal-footer" style="background: #f8fafc;">
                <button type="button" onclick="closeTermModal()" style="background:#e2e8f0; border:none; padding:10px 20px; border-radius:8px; cursor:pointer; font-weight:600; color: #475569;">Cancel</button>
                <button type="button" id="btnConfirmTermination" disabled style="background:#ef4444; color:white; border:none; padding:10px 25px; border-radius:8px; cursor:pointer; font-weight:700; opacity: 0.5;">Confirm Termination</button>
            </div>
        </div>
    </div>

    <!-- Modals and Alerts -->
    <div id="confirmModal" class="page-modal">
        <div class="modal-content">
            <div class="modal-header">Confirm Action</div>
            <div class="modal-body"><p id="confirmMsg"></p></div>
            <div class="modal-footer">
                <button type="button" class="btn-action-approve" id="btnConfirm">Confirm</button>
                <button type="button" onclick="closeModal()" style="background:#e2e8f0; border:none; padding:8px 16px; border-radius:8px; cursor:pointer;">Cancel</button>
            </div>
        </div>
    </div>

    <div id="alertModal" class="page-modal">
        <div class="modal-content" style="max-width:420px;">
            <div class="modal-header" id="alertHeader">Success</div>
            <div class="modal-body" style="text-align:center;">
                <div id="alertIcon" style="font-size:56px; margin-bottom:12px;"></div>
                <p id="alertMsg" style="margin:0; font-weight:600; color:#334155;"></p>
            </div>
            <div class="modal-footer" style="justify-content:center;">
                <button type="button" class="btn-action-approve" onclick="closeAlert()">OK</button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadRequests();
        });

        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab-trigger').forEach(t => t.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            document.getElementById('btn-' + tabId.replace('-tab', '')).classList.add('active');
        }

        function loadRequests() {
            PageMethods.GetSuperAdminRequests(function(r) {
                const res = typeof r === 'string' ? JSON.parse(r) : r;
                if(!res.success) return;

                // Update counts
                if (document.getElementById('cnt-leave')) document.getElementById('cnt-leave').textContent = res.leaves.length;
                if (document.getElementById('cnt-ot')) document.getElementById('cnt-ot').textContent = res.ot.length;
                if (document.getElementById('cnt-ut')) document.getElementById('cnt-ut').textContent = res.ut.length;
                if (document.getElementById('cnt-resign')) document.getElementById('cnt-resign').textContent = res.resign.length;
                if (document.getElementById('cnt-concern')) document.getElementById('cnt-concern').textContent = res.concerns.length;
                if (document.getElementById('cnt-loan')) document.getElementById('cnt-loan').textContent = res.loans ? res.loans.length : 0;
                
                // Build Leaves
                document.getElementById('leaveBody').innerHTML = res.leaves.length ? res.leaves.map(l => {
                    const isSelf = (l.empId && res.currentAdminId && l.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                  `<div style="display:flex; gap:8px;">
                                      <button type="button" class="btn-action-approve" onclick="approve('Leave', '${l.id}')">Approve</button>
                                      <button type="button" class="btn-action-reject" onclick="reject('Leave', '${l.id}')">Reject</button>
                                  </div>`;
                    return `
                    <tr>
                        <td style="font-weight:700;">${l.name}</td>
                        <td>${l.type}</td>
                        <td>${l.range}</td>
                        <td style="font-style:italic;">"${l.reason}"</td>
                        <td><span class="status-badge status-pending">Pending</span></td>
                        <td>${actions}</td>
                    </tr>
                `}).join('') : '<tr><td colspan="6" class="empty-state">No pending leave requests.</td></tr>';

                // Build OT
                document.getElementById('otBody').innerHTML = res.ot.length ? res.ot.map(o => {
                    const isSelf = (o.empId && res.currentAdminId && o.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                   `<div style="display:flex; gap:8px;">
                                       <button type="button" class="btn-action-approve" onclick="approve('OT', '${o.id}')">Approve</button>
                                       <button type="button" class="btn-action-reject" onclick="reject('OT', '${o.id}')">Reject</button>
                                   </div>`;
                    return `
                    <tr>
                        <td style="font-weight:700;">${o.name}</td>
                        <td>${o.date}</td>
                        <td><span style="color:#A44F56; font-weight:700;">${o.startTime} - ${o.endTime}</span></td>
                        <td><strong>${o.hours}</strong> hrs</td>
                        <td style="font-style:italic;">"${o.reason}"</td>
                        <td>${actions}</td>
                    </tr>
                `}).join('') : '<tr><td colspan="6" class="empty-state">No pending overtime requests.</td></tr>';

                // Build UT
                document.getElementById('utBody').innerHTML = res.ut.length ? res.ut.map(u => {
                    const isSelf = (u.empId && res.currentAdminId && u.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                  `<div style="display:flex; gap:8px;">
                                      <button type="button" class="btn-action-approve" onclick="approve('UT', '${u.id}')">Approve</button>
                                      <button type="button" class="btn-action-reject" onclick="reject('UT', '${u.id}')">Reject</button>
                                  </div>`;
                    return `
                    <tr>
                        <td style="font-weight:700;">${u.name}</td>
                        <td>${u.date}</td>
                        <td><span style="color:#A44F56; font-weight:700;">${u.departureTime}</span></td>
                        <td style="font-style:italic;">"${u.reason}"</td>
                        <td>${actions}</td>
                    </tr>
                `}).join('') : '<tr><td colspan="5" class="empty-state">No pending undertime requests.</td></tr>';

                // Build Resign
                document.getElementById('resignBody').innerHTML = res.resign.length ? res.resign.map(e => {
                    const isSelf = (e.empId && res.currentAdminId && e.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                  `<div style="display:flex; gap:8px;">
                                      <button type="button" class="btn-action-approve" onclick="approve('Resign', '${e.id}')">Approve</button>
                                      <button type="button" class="btn-action-reject" onclick="reject('Resign', '${e.id}')">Reject</button>
                                  </div>`;
                    return `
                    <tr>
                        <td style="font-weight:700;">${e.name}</td>
                        <td>${e.hired}</td>
                        <td>${e.effective}</td>
                        <td>${actions}</td>
                    </tr>
                `}).join('') : '<tr><td colspan="4" class="empty-state">No pending resignation requests.</td></tr>';

                // Build Concern
                document.getElementById('concernBody').innerHTML = res.concerns.length ? res.concerns.map(c => {
                    const isSelf = (c.empId && res.currentAdminId && c.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                    const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                  `<button type="button" class="btn-action-approve" onclick="approve('Concern', '${c.id}')">Resolve</button>`;
                    return `
                    <tr>
                        <td style="font-weight:700;">${c.name}</td>
                        <td>${c.subject}</td>
                        <td>${c.type}</td>
                        <td>${c.date}</td>
                        <td>${actions}</td>
                    </tr>
                `}).join('') : '<tr><td colspan="4" class="empty-state">No recent concerns.</td></tr>';

                // Build Loan
                if (res.loans) {
                    document.getElementById('loanBody').innerHTML = res.loans.length ? res.loans.map(l => {
                        const isSelf = (l.empId && res.currentAdminId && l.empId.toString().toLowerCase() === res.currentAdminId.toString().toLowerCase());
                        const actions = isSelf ? '<span class="status-badge status-pending"><i class="fas fa-user-lock"></i> SELF-REQUEST</span>' :
                                       `<div style="display:flex; gap:8px;">
                                           <button type="button" class="btn-action-approve" onclick="approve('Loan', '${l.id}')">Approve</button>
                                           <button type="button" class="btn-action-reject" onclick="reject('Loan', '${l.id}')">Reject</button>
                                       </div>`;
                        return `
                        <tr>
                            <td style="font-weight:700;">${l.name}</td>
                            <td>${l.type}</td>
                            <td>${l.agency}</td>
                            <td>${l.date}</td>
                            <td><span class="status-badge status-pending">Pending</span></td>
                            <td>${actions}</td>
                        </tr>
                    `}).join('') : '<tr><td colspan="6" class="empty-state">No pending loan requests.</td></tr>';
                }
            });
        }

        function approve(type, id) {
            if (type === 'Resign') {
                showTerminationModal(id);
                return;
            }
            document.getElementById('confirmMsg').textContent = `Are you sure you want to approve this ${type} request?`;
            document.getElementById('btnConfirm').onclick = function() {
                PageMethods.ProcessApproval(type, id, true, function(r) {
                    closeModal();
                    const res = typeof r === 'string' ? JSON.parse(r) : r;
                    if (res && res.success) {
                        loadRequests();
                        const verb = (type === 'Concern') ? 'resolved' : 'approved';
                        showAlert('Success', `Request ${verb} successfully.`, 'success');
                    } else {
                        showAlert('Error', (res && res.message) ? res.message : 'Action failed. Please try again.', 'error');
                    }
                });
            };
            document.getElementById('confirmModal').style.display = 'block';
        }

        // --- Termination Modal Logic ---
        let currentResignId = null;
        let clearanceBase64 = null;

        function showTerminationModal(id) {
            currentResignId = id;
            document.getElementById('terminationModal').style.display = 'block';
            resetTermForm();
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
                isValid = !!clearanceBase64;
            } else {
                isValid = document.getElementById('forcedReason').value.trim().length > 0;
            }

            btn.disabled = !isValid;
            btn.style.opacity = isValid ? '1' : '0.5';
            btn.onclick = isValid ? finalizeTermination : null;
        }

        function resetTermForm() {
            document.querySelector('input[name="termType"][value="Standard"]').checked = true;
            document.getElementById('forcedReason').value = '';
            document.getElementById('clearanceUpload').value = '';
            document.getElementById('fileName').textContent = 'Click to select signed clearance (PDF)';
            document.getElementById('dropZone').style.borderColor = '#cbd5e1';
            document.getElementById('dropZone').style.background = '#f8fafc';
            clearanceBase64 = null;
            toggleTermFields();
        }

        function finalizeTermination() {
            const type = document.querySelector('input[name="termType"]:checked').value;
            const reason = document.getElementById('forcedReason').value.trim();
            
            const btn = document.getElementById('btnConfirmTermination');
            btn.disabled = true;
            btn.textContent = 'Processing...';

            PageMethods.FinalizeResignation(currentResignId, type, reason, clearanceBase64, function(r) {
                const res = typeof r === 'string' ? JSON.parse(r) : r;
                closeTermModal();
                if (res && res.success) {
                    loadRequests();
                    showAlert('Termination Confirmed', 'Employee status updated to Inactive. All access revoked.', 'success');
                } else {
                    showAlert('Error', (res && res.message) ? res.message : 'Failed to finalize termination.', 'error');
                }
                btn.disabled = false;
                btn.textContent = 'Confirm Termination';
            });
        }

        function reject(type, id) {
            document.getElementById('confirmMsg').textContent = `Are you sure you want to REJECT this ${type} request?`;
            document.getElementById('btnConfirm').onclick = function() {
                PageMethods.ProcessApproval(type, id, false, function(r) {
                    closeModal();
                    const res = typeof r === 'string' ? JSON.parse(r) : r;
                    if (res && res.success) {
                        loadRequests();
                        showAlert('Success', 'Request declined successfully.', 'success');
                    } else {
                        showAlert('Error', (res && res.message) ? res.message : 'Action failed. Please try again.', 'error');
                    }
                });
            };
            document.getElementById('confirmModal').style.display = 'block';
        }

        function closeModal() { document.getElementById('confirmModal').style.display = 'none'; }

        function showAlert(title, message, type) {
            const modal = document.getElementById('alertModal');
            const header = document.getElementById('alertHeader');
            const icon = document.getElementById('alertIcon');
            const msg = document.getElementById('alertMsg');

            header.textContent = title || (type === 'error' ? 'Error' : 'Success');
            header.style.background = (type === 'error') ? '#ef4444' : '#10b981';

            icon.innerHTML = (type === 'error')
                ? '<i class="fas fa-times-circle" style="color:#ef4444;"></i>'
                : '<i class="fas fa-check-circle" style="color:#10b981;"></i>';
            msg.textContent = message || '';

            modal.style.display = 'block';
        }

        function closeAlert() { document.getElementById('alertModal').style.display = 'none'; }
    </script>
</asp:Content>

