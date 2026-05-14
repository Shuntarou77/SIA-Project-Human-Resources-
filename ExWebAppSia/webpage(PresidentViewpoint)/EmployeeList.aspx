<%@ Page Title="Employee Directory" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="EmployeeList.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.EmployeeList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .directory-container {
            padding: 24px;
            background: #fdfaf9;
        }

        /* ── Header Box ── */
        .header-box {
            background: white;
            border-radius: 20px;
            padding: 24px 28px;
            margin-bottom: 20px;
            box-shadow: 0 4px 20px rgba(164, 79, 86, 0.06);
        }

        .header-top-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .header-title h1 {
            font-size: 24px;
            font-weight: 800;
            color: #4A3534;
            margin: 0;
        }

        .header-title p {
            font-size: 13px;
            color: #6B4545;
            margin: 4px 0 0;
        }

        .total-badge {
            text-align: right;
        }

        .total-badge .num {
            font-size: 32px;
            font-weight: 900;
            color: #A44F56;
        }

        .total-badge .lbl {
            font-size: 12px;
            color: #6B4545;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* ── Status Counter Pills ── */
        .status-counters {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .status-pill {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #fdfaf9;
            border: 1.5px solid #eee;
            border-radius: 14px;
            padding: 10px 18px;
            min-width: 120px;
            transition: transform 0.2s;
        }

        .status-pill:hover { transform: translateY(-2px); }

        .status-pill .pill-num {
            font-size: 24px;
            font-weight: 900;
            line-height: 1;
        }

        .status-pill .pill-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: #9B7D7B;
            line-height: 1.3;
        }

        .pill-regular   { border-color: #10b981; }
        .pill-regular   .pill-num { color: #10b981; }
        .pill-probation { border-color: #f59e0b; }
        .pill-probation .pill-num { color: #f59e0b; }
        .pill-contract  { border-color: #3b82f6; }
        .pill-contract  .pill-num { color: #3b82f6; }
        .pill-active    { border-color: #10b981; }
        .pill-active    .pill-num { color: #10b981; }
        .pill-inactive  { border-color: #6b7280; }
        .pill-inactive  .pill-num { color: #6b7280; }
        .pill-resigned  { border-color: #ef4444; }
        .pill-resigned  .pill-num { color: #ef4444; }
        .pill-pending   { border-color: #f59e0b; }
        .pill-pending   .pill-num { color: #f59e0b; }
        .pill-on-leave  { border-color: #f59e0b; }
        .pill-on-leave  .pill-num { color: #f59e0b; }

        .pill-divider {
            width: 1px;
            height: 40px;
            background: #eee;
            margin: 0 6px;
        }

        /* ── Search / Filter Bar ── */
        .search-filter-box {
            display: flex;
            gap: 12px;
            background: white;
            border-radius: 16px;
            padding: 16px;
            margin-bottom: 24px;
            box-shadow: 0 4px 20px rgba(164, 79, 86, 0.05);
        }

        .search-input {
            flex: 1;
            border: 1px solid #EEE;
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }

        .search-input:focus { border-color: #A44F56; }

        .filter-select {
            border: 1px solid #EEE;
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 14px;
            background: white;
            color: #4A3534;
            outline: none;
        }

        /* ── Employee Grid ── */
        .employee-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .employee-card {
            background: white;
            border-radius: 20px;
            padding: 20px 24px;
            box-shadow: 0 4px 20px rgba(164, 79, 86, 0.05);
            transition: all 0.3s ease;
            cursor: pointer;
            border: 1.5px solid transparent;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .employee-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(164, 79, 86, 0.12);
            border-color: rgba(164, 79, 86, 0.25);
        }

        .emp-avatar {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: rgba(164, 79, 86, 0.1);
            color: #A44F56;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            font-weight: 800;
            flex-shrink: 0;
        }

        .emp-info { flex: 1; min-width: 0; }

        .emp-name {
            font-size: 15px;
            font-weight: 700;
            color: #4A3534;
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .emp-role {
            font-size: 12px;
            color: #A44F56;
            font-weight: 600;
            margin: 2px 0;
        }

        .emp-dept {
            font-size: 12px;
            color: #9B7D7B;
        }

        .emp-meta {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 6px;
            flex-wrap: wrap;
        }

        .emp-badge {
            font-size: 10px;
            padding: 2px 8px;
            border-radius: 6px;
            background: #fdfaf9;
            color: #6B4545;
            border: 1px solid #EEE;
            font-weight: 600;
        }

        .emp-status-badge {
            font-size: 10px;
            padding: 2px 8px;
            border-radius: 6px;
            font-weight: 700;
        }

        .badge-regular   { background: #d1fae5; color: #065f46; }
        .badge-probation { background: #fef3c7; color: #92400e; }
        .badge-contract  { background: #dbeafe; color: #1e40af; }
        .badge-active    { background: #d1fae5; color: #065f46; }
        .badge-inactive  { background: #f3f4f6; color: #374151; }
        .badge-resigned  { background: #fee2e2; color: #991b1b; }
        .badge-pending   { background: #fef3c7; color: #92400e; }
        .badge-on-leave   { background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; }

        /* ── Modal ── */
        .modal-body-custom {
            padding: 28px 32px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 11px 0;
            border-bottom: 1px solid #F5F5F5;
        }

        .detail-row:last-child { border-bottom: none; }

        .detail-label {
            font-weight: 600;
            color: #9B7D7B;
            font-size: 13px;
        }

        .detail-value {
            color: #4A3534;
            font-weight: 700;
            font-size: 14px;
            text-align: right;
        }

        .modal-status-badges {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            flex-wrap: wrap;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="directory-container">

        <!-- Header with total + status counters -->
        <div class="header-box">
            <div class="header-top-row">
                <div class="header-title">
                    <h1>Employee List</h1>
                    <p>Overview of all company personnel (Read-only)</p>
                </div>
                <div class="total-badge">
                    <div class="num"><asp:Literal ID="litTotalCount" runat="server" Text="0" /></div>
                    <div class="lbl">Total Employees</div>
                </div>
            </div>

            <div class="status-counters">
                <!-- Employment type -->
                <div class="status-pill pill-regular">
                    <div class="pill-num"><asp:Literal ID="litRegular" runat="server" Text="0" /></div>
                    <div class="pill-label">Regular</div>
                </div>
                <div class="status-pill pill-probation">
                    <div class="pill-num"><asp:Literal ID="litProbationary" runat="server" Text="0" /></div>
                    <div class="pill-label">Probationary</div>
                </div>
                <div class="status-pill pill-contract">
                    <div class="pill-num"><asp:Literal ID="litContractual" runat="server" Text="0" /></div>
                    <div class="pill-label">Contractual</div>
                </div>

                <div class="pill-divider"></div>

                <!-- Account status -->
                <div class="status-pill pill-active">
                    <div class="pill-num"><asp:Literal ID="litActive" runat="server" Text="0" /></div>
                    <div class="pill-label">Active</div>
                </div>
                <div class="status-pill pill-inactive">
                    <div class="pill-num"><asp:Literal ID="litInactive" runat="server" Text="0" /></div>
                    <div class="pill-label">Inactive</div>
                </div>
                <!-- Leave status -->
                <div class="status-pill pill-on-leave">
                    <div class="pill-num"><asp:Literal ID="litOnLeave" runat="server" Text="0" /></div>
                    <div class="pill-label">On Leave</div>
                </div>
                <div class="status-pill pill-resigned">
                    <div class="pill-num"><asp:Literal ID="litResigned" runat="server" Text="0" /></div>
                    <div class="pill-label">Resigned</div>
                </div>
                <div class="status-pill pill-pending">
                    <div class="pill-num"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
                    <div class="pill-label">Resign Pending</div>
                </div>
            </div>
        </div>

        <!-- Search / Filter -->
        <div class="search-filter-box">
            <i class="fas fa-search" style="align-self: center; color: #BBB; margin-left: 8px;"></i>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input"
                placeholder="Search by name, role or ID..."
                AutoPostBack="true" OnTextChanged="btnFilter_Click" />
            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="filter-select"
                AutoPostBack="true" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Text="All Departments" Value="" />
                <asp:ListItem Text="Human Resources" Value="Human Resources" />
                <asp:ListItem Text="Finance/Accounting" Value="Finance/Accounting" />
                <asp:ListItem Text="Marketing" Value="Marketing" />
                <asp:ListItem Text="Operations" Value="Operations" />
                <asp:ListItem Text="R&D" Value="R&D" />
                <asp:ListItem Text="Inventory" Value="Inventory" />
            </asp:DropDownList>
            <button type="button" class="btn-export-pdf" onclick="exportDepartmentReport()" style="background: #A36A66; color: white; border: none; padding: 12px 20px; border-radius: 12px; font-weight: 600; cursor: pointer; white-space: nowrap; transition: all 0.2s;">
                <i class="fas fa-file-pdf" style="margin-right: 6px;"></i> Export Report
            </button>
        </div>

        <!-- Employee Grid -->
        <div class="employee-grid">
            <asp:Repeater ID="rptEmployees" runat="server">
                <ItemTemplate>
                    <div class="employee-card" onclick="showEmployeeDetails(
                        '<%# Eval("EmployeeId") %>',
                        '<%# Eval("FullName") %>',
                        '<%# Eval("Position") %>',
                        '<%# Eval("Department") %>',
                        '<%# Eval("Email") %>',
                        '<%# Eval("ContactNo") %>',
                        '<%# Eval("HiredDate", "{0:MMM dd, yyyy}") %>',
                        '<%# Eval("EmploymentStatus") %>',
                        '<%# Eval("ContractType") %>',
                        '<%# Eval("IsActive") %>',
                        '<%# Eval("ResignationStatus") %>',
                        '<%# Eval("IsOnLeave") %>'
                    )">
                        <div class="emp-avatar">
                            <%# Eval("FirstName").ToString().Length > 0 ? Eval("FirstName").ToString().Substring(0,1) : "?" %><%# Eval("LastName").ToString().Length > 0 ? Eval("LastName").ToString().Substring(0,1) : "?" %>
                        </div>
                        <div class="emp-info">
                            <p class="emp-name"><%# Eval("FullName") %></p>
                            <p class="emp-role"><%# Eval("Position") %></p>
                            <p class="emp-dept"><%# Eval("Department") %></p>
                            <div class="emp-meta">
                                <span class="emp-badge"><%# Eval("EmployeeId") %></span>
                                <span class="emp-status-badge <%# Eval("EmploymentStatus").ToString() == "Regular" ? "badge-regular" : "badge-probation" %>">
                                    <%# Eval("EmploymentStatus") %>
                                </span>
                                <span class="emp-status-badge <%# (bool)Eval("IsActive") ? "badge-active" : "badge-inactive" %>">
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                                <%# (bool)Eval("IsOnLeave") ? "<span class=\"emp-status-badge badge-on-leave\">On Leave</span>" : "" %>
                                <%# Eval("ResignationStatus").ToString() == "Pending" ? "<span class=\"emp-status-badge badge-pending\">Resign Pending</span>" : "" %>
                                <%# Eval("ResignationStatus").ToString() == "Approved" ? "<span class=\"emp-status-badge badge-resigned\">Resigned</span>" : "" %>
                            </div>
                        </div>
                        <i class="fas fa-chevron-right" style="color: #DDD;"></i>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Employee Detail Modal -->
        <div class="modal fade" id="employeeDetailModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content" style="border-radius: 24px; border: none; overflow: hidden;">
                    <div class="modal-header" style="background: #A44F56; color: white; padding: 22px 32px; border: none;">
                        <h5 class="modal-title" id="modalEmpName" style="font-weight: 800; font-size: 18px;">Employee Details</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body-custom">
                        <div class="detail-row">
                            <span class="detail-label">Employee ID</span>
                            <span class="detail-value" id="modalEmpId">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Position</span>
                            <span class="detail-value" id="modalEmpTitle">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Department</span>
                            <span class="detail-value" id="modalEmpDept">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Email Address</span>
                            <span class="detail-value" id="modalEmpEmail">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Contact No</span>
                            <span class="detail-value" id="modalEmpPhone">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Hired Date</span>
                            <span class="detail-value" id="modalEmpDate">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Employment Status</span>
                            <span class="detail-value">
                                <span id="modalEmpStatus" class="emp-status-badge">--</span>
                            </span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Contract Type</span>
                            <span class="detail-value" id="modalEmpContractType">--</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Account Status</span>
                            <div class="modal-status-badges">
                                <span id="modalEmpActiveStatus" class="emp-status-badge">--</span>
                                <span id="modalEmpResignStatus" class="emp-status-badge" style="display:none;">--</span>
                            </div>
                        </div>

                        <div style="margin-top: 24px; padding: 14px; background: #fafafa; border-radius: 12px; font-size: 13px; color: #6B4545; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-info-circle" style="color: #A44F56; font-size: 16px;"></i>
                            <span>President View: This record is read-only. To update, contact HR.</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showEmployeeDetails(id, name, title, dept, email, phone, date, empStatus, contractType, isActive, resignStatus, isOnLeave) {
            document.getElementById('modalEmpName').innerText = name;
            document.getElementById('modalEmpId').innerText = id;
            document.getElementById('modalEmpTitle').innerText = title || '—';
            document.getElementById('modalEmpDept').innerText = dept || '—';
            document.getElementById('modalEmpEmail').innerText = email || '—';
            document.getElementById('modalEmpPhone').innerText = phone || '—';
            document.getElementById('modalEmpDate').innerText = date || '—';
            document.getElementById('modalEmpContractType').innerText = contractType || '—';

            // Employment Status badge
            var statusBadge = document.getElementById('modalEmpStatus');
            statusBadge.innerText = empStatus || '—';
            statusBadge.className = 'emp-status-badge';
            if (empStatus === 'Regular') statusBadge.classList.add('badge-regular');
            else if (empStatus === 'Probationary') statusBadge.classList.add('badge-probation');
            else statusBadge.classList.add('badge-contract');

            // Active/On Leave/Inactive badge
            var activeBadge = document.getElementById('modalEmpActiveStatus');
            var active = (isActive === 'True' || isActive === 'true' || isActive === true);
            var onLeave = (isOnLeave === 'True' || isOnLeave === 'true' || isOnLeave === true);
            
            if (onLeave) {
                activeBadge.innerText = 'On Leave';
                activeBadge.className = 'emp-status-badge badge-on-leave';
            } else {
                activeBadge.innerText = active ? 'Active' : 'Inactive';
                activeBadge.className = 'emp-status-badge ' + (active ? 'badge-active' : 'badge-inactive');
            }

            // Resignation badge
            var resignBadge = document.getElementById('modalEmpResignStatus');
            if (resignStatus && resignStatus !== 'None' && resignStatus !== '') {
                resignBadge.style.display = 'inline-block';
                resignBadge.innerText = resignStatus === 'Approved' ? 'Resigned' : 'Resign Pending';
                resignBadge.className = 'emp-status-badge ' + (resignStatus === 'Approved' ? 'badge-resigned' : 'badge-pending');
            } else {
                resignBadge.style.display = 'none';
            }

            var myModal = new bootstrap.Modal(document.getElementById('employeeDetailModal'));
            myModal.show();
        }

        function exportDepartmentReport() {
            var dept = document.getElementById('<%= ddlDepartment.ClientID %>').value;
            if (!dept || dept === '') {
                dept = 'All';
            }
            const encoded = encodeURIComponent(dept);
            const url = '<%= ResolveUrl("~/Handler/ExportDepartmentReport.ashx") %>?department=' + encoded + '&format=html';
            window.open(url, '_blank');
        }
    </script>
</asp:Content>

