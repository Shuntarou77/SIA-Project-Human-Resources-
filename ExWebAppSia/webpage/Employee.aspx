<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true"
    CodeBehind="Employee.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm2" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style type="text/css">
            :root {
                --primary-color: #A36A66;
                --secondary-color: #C49A99;
                /* Lighter tint of #A36A66 */
                --accent-color: #F8ECEB;
                /* Very soft warm tint */
                --card-shadow: 0 10px 30px rgba(163, 106, 102, 0.15);
                --hover-shadow: 0 15px 40px rgba(163, 106, 102, 0.25);
                --border-radius: 20px;
                --text-primary: #4A3534;
                /* Darker warm neutral */
                --text-secondary: #6B4F4E;
                --text-muted: #9B7D7B;
                --border-color: #D8BFBF;
            }

            .page-wrapper {
                display: flex;
                gap: 20px;
                padding: 20px;
                width: 100%;
                min-height: calc(100vh - 120px);
                box-sizing: border-box;
            }

            .employee-container {
                display: flex;
                flex-direction: column;
                gap: 20px;
                padding: 20px;
                flex: 1;
                min-height: calc(100vh - 160px);
                box-sizing: border-box;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                border-radius: var(--border-radius);
            }

            .dept-header {
                color: white;
                font-size: 36px;
                font-weight: 300;
                text-align: left;
                padding: 0;
                margin: 0 0 10px 0;
                letter-spacing: 1px;
            }

            .content-wrapper {
                display: flex;
                flex-direction: column;
                gap: 20px;
                flex: 1;
            }

            .department-filter {
                display: grid;
                grid-template-columns: repeat(5, 1fr);
                gap: 12px;
                margin-bottom: 20px;
                justify-content: start;
            }

            .dept-card {
                display: flex;
                align-items: center;
                background: linear-gradient(135deg, var(--accent-color) 0%, #FEF4F3 100%);
                border-radius: 32px;
                padding: 6px 14px 6px 8px;
                box-shadow: var(--card-shadow);
                cursor: pointer;
                transition: all 0.25s ease;
                min-height: 56px;
                position: relative;
            }

            .dept-card:hover {
                transform: translateY(-2px);
                box-shadow: var(--hover-shadow);
            }

            .dept-card:active {
                transform: translateY(0);
            }

            .dept-card.active {
                box-shadow: 0 0 0 3px var(--primary-color), 0 6px 16px rgba(163, 106, 102, 0.3);
            }

            .dept-stats {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                border-radius: 50%;
                width: 44px;
                height: 44px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                margin-right: 12px;
                flex-shrink: 0;
                transition: transform 0.2s ease;
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
            }

            .dept-card:hover .dept-stats {
                transform: scale(1.05);
            }

            .dept-count {
                font-size: 15px;
                font-weight: bold;
            }

            .dept-label {
                font-size: 6px;
                text-transform: uppercase;
                letter-spacing: 0.3px;
                margin-top: 1px;
                opacity: 0.95;
            }

            .dept-info {
                flex: 1;
                min-width: 0;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .dept-name {
                font-weight: 700;
                color: var(--primary-color);
                font-size: 11px;
                line-height: 1.2;
                margin-bottom: 2px;
                word-wrap: break-word;
            }

            .dept-head {
                display: none;
            }

            .search-container {
                position: relative;
                margin-bottom: 15px;
            }

            .search-bar {
                width: 100%;
                padding: 14px 20px 14px 50px;
                border: none;
                border-radius: 32px;
                background-color: white;
                font-size: 14px;
                color: #333;
                box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
                box-sizing: border-box;
            }

            .search-bar::placeholder {
                color: #aaa;
            }

            .search-icon {
                position: absolute;
                left: 18px;
                top: 50%;
                transform: translateY(-50%);
                width: 18px;
                height: 18px;
                color: #999;
            }

            .employee-table-container {
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                overflow: hidden;
                flex: 1;
                min-width: 0;
            }

            .employee-table {
                width: 100%;
                border-collapse: collapse;
            }

            .employee-table th {
                background-color: white;
                padding: 16px 24px;
                text-align: left;
                font-weight: 600;
                color: #555;
                border-bottom: 2px solid #f0f0f0;
                font-size: 14px;
            }

            .employee-table td {
                padding: 16px 24px;
                border-bottom: 1px solid #f5f5f5;
                color: #444;
                font-size: 13px;
            }

            .employee-table tbody tr.filtered-out {
                display: none;
            }

            .employee-table tbody tr:hover {
                background-color: #fafafa;
            }

            .employee-table tbody tr:last-child td {
                border-bottom: none;
            }

            /* Page-specific Modal Styles */
            .page-modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                overflow: auto;
            }

            .modal-content {
                background-color: #fefefe;
                margin: 5% auto;
                padding: 0;
                border-radius: 12px;
                width: 90%;
                max-width: 700px;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
                animation: slideDown 0.3s ease;
            }

            @keyframes slideDown {
                from {
                    transform: translateY(-50px);
                    opacity: 0;
                }

                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 24px 30px;
                border-bottom: 2px solid #f0f0f0;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                border-radius: 12px 12px 0 0;
            }

            .modal-title {
                color: white;
                font-size: 22px;
                font-weight: 600;
                margin: 0;
            }

            .close {
                color: white;
                font-size: 32px;
                font-weight: bold;
                cursor: pointer;
                transition: color 0.2s;
                line-height: 1;
            }

            .close:hover,
            .close:focus {
                color: #f0f0f0;
            }

            /* Action Cards in Modal */
            .actions-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 16px;
                margin: 20px;
            }

            .action-card {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                padding: 20px;
                transition: all 0.3s ease;
                cursor: pointer;
                border: 2px solid transparent;
            }

            .action-card:hover {
                transform: translateY(-3px);
                box-shadow: var(--hover-shadow);
                border-color: var(--primary-color);
            }

            .action-icon {
                width: 50px;
                height: 50px;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 24px;
                margin-bottom: 12px;
                color: white;
            }

            .action-title {
                font-size: 16px;
                font-weight: 700;
                color: #333;
                margin-bottom: 8px;
            }

            .action-description {
                font-size: 13px;
                color: #666;
                line-height: 1.5;
                margin-bottom: 12px;
            }

            .action-button {
                width: 100%;
                padding: 10px 20px;
                background: linear-gradient(135deg, #905A57 0%, #A36A66 100%);
                /* slightly darker ? standard */
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            .action-button:hover {
                transform: scale(1.03);
                box-shadow: 0 4px 12px rgba(163, 106, 102, 0.3);
            }

            /* Form Styles */
            .modal-body {
                padding: 24px;
                max-height: 70vh;
                overflow-y: auto;
            }

            .form-group {
                margin-bottom: 18px;
            }

            .form-label {
                display: block;
                font-weight: 600;
                color: #333;
                margin-bottom: 6px;
                font-size: 14px;
            }

            .form-input,
            .form-select,
            .form-textarea {
                width: 100%;
                padding: 10px 14px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-size: 14px;
                transition: all 0.3s ease;
            }

            .form-input:focus,
            .form-select:focus,
            .form-textarea:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(163, 106, 102, 0.1);
            }

            .form-textarea {
                resize: vertical;
                min-height: 100px;
            }

            .modal-footer {
                padding: 16px 24px;
                display: flex;
                gap: 10px;
                justify-content: flex-end;
                border-top: 2px solid #f0f0f0;
            }

            .btn-submit,
            .btn-cancel {
                padding: 10px 24px;
                border: none;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                font-size: 14px;
            }

            .btn-submit {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
            }

            .btn-submit:hover {
                transform: scale(1.05);
                box-shadow: 0 5px 15px rgba(163, 106, 102, 0.3);
            }

            .btn-cancel {
                background: #E5E7EB;
                color: #333;
            }

            .btn-cancel:hover {
                background: #D1D5DB;
            }

            /* Leave Status Badges */
            .leave-status {
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block;
            }

            .status-pending {
                background: #fff3cd;
                color: #856404;
            }

            .status-approved {
                background: #d4edda;
                color: #155724;
            }

            .status-declined {
                background: #f8d7da;
                color: #721c24;
            }

            /* Bottom Section Container */
            .bottom-section-container {
                width: 100%;
                padding: 0 20px 20px 20px;
                box-sizing: border-box;
                margin-top: 0;
            }

            .attendance-table-container {
                background: white;
                border-radius: 12px;
                padding: 25px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                margin-bottom: 0;
                width: 100%;
                box-sizing: border-box;
            }

            .table-title {
                font-size: 18px;
                font-weight: 600;
                color: #333;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .attendance-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 13px;
            }

            .attendance-table thead {
                background: linear-gradient(135deg, var(--secondary-color), var(--primary-color));
            }

            .attendance-table th {
                padding: 14px 12px;
                text-align: left;
                font-weight: 600;
                color: white;
                font-size: 12px;
                text-transform: uppercase;
            }

            .attendance-table td {
                padding: 14px 12px;
                border-bottom: 1px solid #f0f0f0;
            }

            .attendance-table tbody tr:hover {
                background: #f9f9f9;
            }

            .table-scroll {
                overflow-x: auto;
                overflow-y: auto;
            }

            .table-scroll::-webkit-scrollbar {
                height: 8px;
                width: 8px;
            }

            .table-scroll::-webkit-scrollbar-track {
                background: #f1f1f1;
                border-radius: 4px;
            }

            .table-scroll::-webkit-scrollbar-thumb {
                background: var(--primary-color);
                border-radius: 4px;
            }

            .table-scroll::-webkit-scrollbar-thumb:hover {
                background: #8B5A58;
                /* slightly darker */
            }

            .avatar-initial {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background: linear-gradient(135deg, var(--secondary-color), var(--accent-color));
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                font-weight: bold;
                color: var(--primary-color);
                margin-right: 10px;
            }

            /* Payslip Styles */
            .payslip-item {
                padding: 12px 16px;
                background: var(--accent-color);
                border-radius: 8px;
                margin-bottom: 10px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .payslip-label {
                font-weight: 600;
                color: #666;
            }

            .payslip-value {
                font-weight: 700;
                color: #333;
                font-size: 16px;
            }

            .payslip-total {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                padding: 16px;
                border-radius: 10px;
                margin-top: 16px;
            }

            .payslip-total .payslip-value {
                color: white;
                font-size: 24px;
            }

            /* Employee Concerns Panel */
            .concerns-panel {
                width: 350px;
                background: white;
                border-radius: var(--border-radius);
                box-shadow: var(--card-shadow);
                overflow-y: auto;
                padding: 22px;
                max-height: calc(100vh - 160px);
                flex-shrink: 0;
                box-sizing: border-box;
            }

            .concern-header {
                font-size: 19px;
                font-weight: 600;
                color: var(--primary-color);
                margin-bottom: 18px;
                padding-bottom: 10px;
                border-bottom: 2px solid #f0f0f0;
            }

            .concern-card {
                background: white;
                padding: 14px;
                border-radius: 10px;
                border: 1px solid #eaeaea;
                margin-bottom: 14px;
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .concern-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(163, 106, 102, 0.15);
                border-color: var(--primary-color);
            }

            .concern-header-row {
                display: flex;
                align-items: center;
                margin-bottom: 10px;
            }

            .concern-avatar {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                overflow: hidden;
                margin-right: 10px;
                background: #ddd;
                flex-shrink: 0;
            }

            .concern-avatar.concern-initials {
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 12px;
                color: var(--primary-color);
                background: linear-gradient(135deg, var(--secondary-color), var(--accent-color));
            }

            .concern-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .concern-title {
                font-weight: 600;
                color: #333;
                font-size: 12.5px;
            }

            .concern-role {
                font-size: 10px;
                color: #999;
                margin-top: 1px;
            }

            .concern-text {
                font-size: 11.5px;
                line-height: 1.45;
                color: #666;
            }

            .dept-actions {
                display: flex;
                justify-content: flex-end;
                margin-bottom: 10px;
                gap: 8px;
            }

            .btn-export-pdf {
                padding: 8px 14px;
                border-radius: 999px;
                border: none;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: #fff;
                font-size: 12px;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            }

            .btn-export-pdf:hover {
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2);
            }

            /* Responsive */
            @media (max-width: 1199px) {
                .page-wrapper {
                    flex-direction: column;
                }

                .concerns-panel {
                    width: 100%;
                    max-height: 450px;
                }
            }

            @media (max-width: 768px) {
                .department-filter {
                    grid-template-columns: repeat(2, 1fr);
                }

                .dept-header {
                    font-size: 28px;
                    text-align: center;
                }
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="page-wrapper">
            <div class="employee-container">
                <!-- Department Header -->
                <div class="dept-header">Department</div>

                <asp:UpdatePanel ID="upMain" runat="server">
                    <ContentTemplate>

                        <div class="dept-actions">
                            <button type="button" class="btn-export-pdf" onclick="exportSelectedDepartmentReport()">
                                Export Department Report (PDF)
                            </button>
                        </div>

                        <!-- 10 Department Cards (2 rows x 5 columns) -->
                        <div class="department-filter">
                            <div class="dept-card" data-dept="Research & Development">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litRDCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Research & Development</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Quality Control">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litQCCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Quality Control</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Human Resources">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litHRCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Human Resources</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Finance">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litFinanceCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Finance</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Marketing">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litMarketingCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Marketing</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="IT Support">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litITCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">IT Support</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Operations">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litOperationsCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Operations</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Sales">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litSalesCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Sales</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Inventory">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litInventoryCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Inventory</div>
                                </div>
                            </div>
                            <div class="dept-card" data-dept="Customer Service">
                                <div class="dept-stats">
                                    <span class="dept-count">
                                        <asp:Literal ID="litCustomerServiceCount" runat="server" Text="0"></asp:Literal>
                                    </span>
                                    <span class="dept-label">EMPLOYEES</span>
                                </div>
                                <div class="dept-info">
                                    <div class="dept-name">Customer Service</div>
                                </div>
                            </div>
                        </div>

                        <!-- Search Bar & Filter -->
                        <div style="display: flex; gap: 16px; margin-bottom: 24px; align-items: center;">
                            <div class="search-container" style="margin-bottom: 0; flex: 1;">
                                <svg class="search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                                <input type="text" class="search-bar" id="searchInput" placeholder="Search..." />
                            </div>
                            <div class="filter-group">
                                <select id="statusFilter" class="form-control"
                                    style="height: 48px; border-radius: 12px; border: 1.5px solid #e5e7eb; min-width: 150px; font-size: 14px; padding: 0 16px; background: #fff; cursor: pointer;"
                                    onchange="applyFilter(currentSelectedDept)">
                                    <option value="Active">Active Employees</option>
                                    <option value="Inactive">Resigned/Inactive</option>
                                    <option value="all">All Status</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <select id="govtFilter" class="form-control"
                                    style="height: 48px; border-radius: 12px; border: 1.5px solid #e5e7eb; min-width: 220px; font-size: 14px; padding: 0 16px; background: #fff; cursor: pointer;"
                                    onchange="applyFilter(currentSelectedDept)">
                                    <option value="all">All Contributions</option>
                                    <option value="complete">Complete (SSS, PH, PagIbig)</option>
                                    <option value="incomplete">Incomplete</option>
                                    <option value="sss">With SSS</option>
                                    <option value="philhealth">With PhilHealth</option>
                                    <option value="pagibig">With Pag-IBIG</option>
                                </select>
                            </div>
                        </div>

                        <!-- Employee Table -->
                        <div class="employee-table-container">
                            <table class="employee-table">
                                <thead>
                                    <tr>
                                        <th>Employee ID</th>
                                        <th>Name</th>
                                        <th>Department</th>
                                        <th>Role</th>
                                    </tr>
                                </thead>
                                <tbody id="employeeTableBody" runat="server">
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 40px; color: #999;">
                                            No employees found.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <!-- RIGHT SIDE: Employee Concerns Panel -->
            <div class="concerns-panel">
                <div class="concern-header">Employee Concern</div>
                <asp:Literal ID="litConcerns" runat="server"></asp:Literal>
            </div>
        </div>

        <!-- Bottom Section: Leave Requests Table -->
        <div class="bottom-section-container">
            <div class="attendance-table-container">
                <h3 class="table-title"><svg
                        style="width:20px;height:20px;vertical-align:middle;margin-right:8px;fill:var(--primary-color);"
                        viewBox="0 0 24 24">
                        <path
                            d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z" />
                    </svg> Leave Requests &mdash; Pending Approval</h3>
                <div class="table-scroll" style="max-height: 350px;">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>ID</th>
                                <th>Leave Type</th>
                                <th>Date(s) Requested</th>
                                <th>Duration</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="leaveRequestsBody">
                            <tr>
                                <td colspan="8" style="text-align: center; padding: 40px; color: #999;">
                                    Loading leave requests...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- JavaScript for Filtering -->
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const deptCards = document.querySelectorAll('.dept-card');
                // Get the actual table body element using the server-side ID
                const tableBody = document.getElementById('<%= employeeTableBody.ClientID %>');
                const searchInput = document.getElementById('searchInput');
                let currentSelectedDept = null;

                function resetActive() {
                    deptCards.forEach(card => card.classList.remove('active'));
                }

                function applyFilter(selectedDept = null) {
                    const searchTerm = (searchInput.value || '').toLowerCase();
                    const govtFilter = document.getElementById('govtFilter').value;
                    // Get all rows from the table body
                    const tableRows = tableBody ? tableBody.querySelectorAll('tr') : [];

                    tableRows.forEach(row => {
                        const dept = row.getAttribute('data-dept');
                        const text = row.textContent.toLowerCase();
                        const sss = row.getAttribute('data-sss') === 'true';
                        const ph = row.getAttribute('data-ph') === 'true';
                        const pagibig = row.getAttribute('data-pi') === 'true';

                        const matchesDept = selectedDept ? dept === selectedDept : true;
                        const matchesSearch = text.includes(searchTerm);

                        let matchesGovt = true;
                        if (govtFilter === 'complete') {
                            matchesGovt = sss && ph && pagibig;
                        } else if (govtFilter === 'incomplete') {
                            matchesGovt = !(sss && ph && pagibig);
                        } else if (govtFilter === 'sss') {
                            matchesGovt = sss;
                        } else if (govtFilter === 'philhealth') {
                            matchesGovt = ph;
                        } else if (govtFilter === 'pagibig') {
                            matchesGovt = pagibig;
                        }

                        const statusFilter = document.getElementById('statusFilter').value;
                        const rowStatus = row.getAttribute('data-active');
                        const matchesStatus = statusFilter === 'all' ? true : rowStatus === statusFilter;

                        if (matchesDept && matchesSearch && matchesGovt && matchesStatus) {
                            row.classList.remove('filtered-out');
                        } else {
                            row.classList.add('filtered-out');
                        }
                    });
                }

                deptCards.forEach(card => {
                    card.addEventListener('click', function () {
                        const wasActive = this.classList.contains('active');
                        resetActive();
                        if (!wasActive) {
                            this.classList.add('active');
                            const dept = this.getAttribute('data-dept');
                            currentSelectedDept = dept;
                            applyFilter(dept);
                        } else {
                            currentSelectedDept = null;
                            applyFilter(null);
                        }
                    });
                });

                // Fix search input listener
                if (searchInput) {
                    searchInput.addEventListener('input', () => {
                        const activeCard = document.querySelector('.dept-card.active');
                        const selectedDept = activeCard ? activeCard.getAttribute('data-dept') : null;
                        currentSelectedDept = selectedDept;
                        applyFilter(selectedDept);
                    });
                }

                window.exportSelectedDepartmentReport = function () {
                    const activeCard = document.querySelector('.dept-card.active');
                    const dept = activeCard ? activeCard.getAttribute('data-dept') : null;
                    if (!dept) {
                        showAlert('Required', 'Please select a department first.', 'info');
                        return;
                    }

                    const encoded = encodeURIComponent(dept);
                    const url = '<%= ResolveUrl("~/Handler/ExportDepartmentReport.ashx") %>?department=' + encoded + '&format=html';
                    window.open(url, '_blank');
                };

                window.downloadReportPdf = function () {
                    const activeCard = document.querySelector('.dept-card.active');
                    const dept = activeCard ? activeCard.getAttribute('data-dept') : null;
                    if (dept) {
                        const encoded = encodeURIComponent(dept);
                        window.open('<%= ResolveUrl("~/Handler/ExportDepartmentReport.ashx") %>?department=' + encoded + '&format=pdf', '_blank');
                    }
                };
            });

            // Modal functions
            function viewEmployeeDetails(row) {
                const modal = document.getElementById('viewEmployeeDetailsModal');
                const content = document.getElementById('<%= employeeDetailsContent.ClientID %>');

                // Extract all data from data-attributes
                const id = row.getAttribute('data-id');
                const empId = row.getAttribute('data-emp-id');
                const fname = row.getAttribute('data-fname');
                const mname = row.getAttribute('data-mname');
                const lname = row.getAttribute('data-lname');
                const email = row.getAttribute('data-email');
                const contact = row.getAttribute('data-contact');
                const address = row.getAttribute('data-address');
                const dept = row.getAttribute('data-dept');
                const role = row.getAttribute('data-role');
                const hired = row.getAttribute('data-hired');
                const active = row.getAttribute('data-active');
                const sss = row.getAttribute('data-sss') === 'true';
                const ph = row.getAttribute('data-ph') === 'true';
                const pi = row.getAttribute('data-pi') === 'true';
                const salary = row.getAttribute('data-salary');
                const contract = row.getAttribute('data-contract');
                const sssNum = row.getAttribute('data-sss-num') || "Not Set";
                const phNum = row.getAttribute('data-ph-num') || "Not Set";
                const piNum = row.getAttribute('data-pi-num') || "Not Set";

                const formatGov = (num, type) => {
                    if (!num || num === "Not Set") return "Not Set";
                    const clean = num.replace(/\D/g, '');
                    try {
                        if (type === 'SSS' && clean.length === 10) return `${clean.substr(0, 2)}-${clean.substr(2, 7)}-${clean.substr(9, 1)}`;
                        if (type === 'PH' && clean.length === 12) return `${clean.substr(0, 2)}-${clean.substr(2, 9)}-${clean.substr(11, 1)}`;
                        if (type === 'PI' && clean.length === 12) return `${clean.substr(0, 4)}-${clean.substr(4, 4)}-${clean.substr(8, 4)}`;
                    } catch (e) { }
                    return num;
                };

                // Build HTML instantly on the client side
                let html = `<div style='padding: 20px;'>`;

                // Personal Info Table
                html += `<h3 style='color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Personal Information</h3>`;
                html += `<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>`;
                html += `<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Employee ID:</td><td style='padding: 8px;'>${empId}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>First Name:</td><td style='padding: 8px;'>${fname}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Middle Name:</td><td style='padding: 8px;'>${mname}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Last Name:</td><td style='padding: 8px;'>${lname}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Email Address:</td><td style='padding: 8px;'>${email}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Contact No.:</td><td style='padding: 8px;'>${contact}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Address:</td><td style='padding: 8px;'>${address}</td></tr>`;
                html += `</table>`;

                // Employment Info Table
                html += `<h3 style='color: #8B4755; margin: 20px 0 15px 0; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;'>Employment Information</h3>`;
                html += `<table style='width: 100%; border-collapse: collapse; margin-bottom: 20px;'>`;
                html += `<tr><td style='padding: 8px; font-weight: bold; width: 40%;'>Department:</td><td style='padding: 8px;'>${dept}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Role:</td><td style='padding: 8px;'>${role}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Contract Type:</td><td style='padding: 8px;'><span style='color: ${contract === "Regular" ? "green" : "orange"}; font-weight: bold;'>${contract}</span></td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Base Salary:</td><td style='padding: 8px; font-weight: bold; color: #8B4755;'>₱${salary}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Hired Date:</td><td style='padding: 8px;'>${hired}</td></tr>`;
                html += `<tr><td style='padding: 8px; font-weight: bold;'>Status:</td><td style='padding: 8px;'>${active}</td></tr>`;

                // Gov Contributions
                const checkIcon = '<i class="fas fa-check-circle" style="color: #22c55e; margin-right: 4px;"></i>';
                const xIcon = '<i class="fas fa-times-circle" style="color: #94a3b8; margin-right: 4px;"></i>';

                html += `<tr><td style='padding: 8px; font-weight: bold;'>Govt. Contributions:</td><td style='padding: 8px;'>`;
                html += `<div style='margin-bottom: 8px;'><span style='margin-right: 15px;'>${sss ? checkIcon : xIcon} SSS</span> <span style='color: #64748b; font-size: 13px;'>${formatGov(sssNum, 'SSS')}</span></div>`;
                html += `<div style='margin-bottom: 8px;'><span style='margin-right: 15px;'>${ph ? checkIcon : xIcon} PhilHealth</span> <span style='color: #64748b; font-size: 13px;'>${formatGov(phNum, 'PH')}</span></div>`;
                html += `<div><span>${pi ? checkIcon : xIcon} Pag-IBIG</span> <span style='color: #64748b; font-size: 13px;'>${formatGov(piNum, 'PI')}</span></div>`;
                html += `</td></tr>`;
                html += `</table></div>`;

                // Action Cards (View Payslip, Leave, Concern)
                html += `<div class='actions-grid'>`;

                // Card 1: Payslip
                html += `<div class='action-card' onclick='openPayslipModal()'>
                    <div class='action-icon'><i class='fas fa-file-invoice-dollar'></i></div>
                    <h3 class='action-title'>View Payslip</h3>
                    <p class='action-description'>View salary breakdown including gross salary, deductions, and net pay.</p>
                    <button type="button" class="action-button">View Details</button>
                </div>`;

                // Card 2: Leave History (Still needs AJAX when clicked)
                html += `<div class='action-card' onclick='openLeaveHistoryModal("${id}")'>
                    <div class='action-icon'><i class='fas fa-calendar-alt'></i></div>
                    <h3 class='action-title'>History Leave of Absence</h3>
                    <p class='action-description'>View leave history including sick leave, vacation, and personal matters.</p>
                    <button type="button" class="action-button">View History</button>
                </div>`;

                // Card 3: Concern History (Still needs AJAX when clicked)
                html += `<div class='action-card' onclick='openConcernHistoryModal("${id}")'>
                    <div class='action-icon'><i class='fas fa-exclamation-triangle'></i></div>
                    <h3 class='action-title'>History of Employee Concern</h3>
                    <p class='action-description'>View all workplace concerns, complaints, or suggestions submitted to HR.</p>
                    <button type="button" class="action-button">View History</button>
                </div>`;

                // Add Resign/Rehire/Deploy Cards
                if (active === "Active") {
                    html += `<div class='action-card' onclick='resignEmployee("${id}")'>
                        <div class='action-icon'><i class='fas fa-user-slash'></i></div>
                        <h3 class='action-title'>Resigned</h3>
                        <p class='action-description'>Mark this employee as resigned and deactivate their account.</p>
                        <button type="button" class="action-button" style='background: #ef4444;'>Process Resignation</button>
                    </div>`;

                    html += `<div class='action-card' onclick='openDeployModal("${id}", "${dept}")'>
                        <div class='action-icon'><i class='fas fa-exchange-alt'></i></div>
                        <h3 class='action-title'>Deploy to Department</h3>
                        <p class='action-description'>Transfer this employee to a different department or team.</p>
                        <button type="button" class="action-button" style='background: #3b82f6;'>Redeploy</button>
                    </div>`;
                } else {
                    html += `<div class='action-card' onclick='rehireEmployee("${id}")'>
                        <div class='action-icon'><i class='fas fa-user-plus'></i></div>
                        <h3 class='action-title'>Rehired</h3>
                        <p class='action-description'>Reactivate this employee's account for active duty.</p>
                        <button type="button" class="action-button" style='background: #10b981;'>Process Rehire</button>
                    </div>`;
                }

                html += `</div>`;

                content.innerHTML = html;
                modal.style.display = 'block';
            }

            function closeEmployeeDetailsModal() {
                document.getElementById('viewEmployeeDetailsModal').style.display = 'none';
            }

            function openPayslipModal() {
                document.getElementById('payslipModal').style.display = 'block';
            }

            function closePayslipModal() {
                document.getElementById('payslipModal').style.display = 'none';
            }

            function openLeaveHistoryModal(employeeId) {
                const modal = document.getElementById('leaveHistoryModal');
                const content = document.getElementById('<%= leaveHistoryContent.ClientID %>');

                content.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="fas fa-spinner fa-spin" style="font-size: 24px; color: #A36A66;"></i><p style="margin-top: 10px;">Loading leave history...</p></div>';
                modal.style.display = 'block';

                PageMethods.GetLeaveHistory(employeeId, function (response) {
                    content.innerHTML = response;
                }, function (error) {
                    content.innerHTML = '<div style="padding: 20px; color: #dc3545;">Error loading leave history.</div>';
                });
            }

            function closeLeaveHistoryModal() {
                document.getElementById('leaveHistoryModal').style.display = 'none';
            }

            function openConcernHistoryModal(employeeId) {
                const modal = document.getElementById('concernHistoryModal');
                const content = document.getElementById('<%= concernHistoryContent.ClientID %>');

                // Speed optimization: Show modal instantly
                modal.style.display = 'block';

                // 1. Try to find the human-readable Employee ID (e.g., "26-2214") from the table row data
                const row = document.querySelector(`.employee-row[data-id="${employeeId}"]`);
                const humanId = row ? row.getAttribute('data-emp-id') : null;

                // 2. See if we have the data already in our local cache
                const json = document.getElementById('<%= hdnConcernsJson.ClientID %>').value;
                if (json && humanId) {
                    try {
                        const allConcerns = JSON.parse(json);
                        const filtered = allConcerns.filter(c => c.employeeId === humanId || c.EmployeeId === humanId);

                        if (filtered.length > 0) {
                            renderConcernsLocally(filtered, content);
                            return; // Success! No server call needed.
                        }
                    } catch (e) {
                        console.warn("Local concern lookup failed:", e);
                    }
                }

                // Fallback: If local lookup fails, use the server (PageMethod)
                content.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="fas fa-spinner fa-spin" style="font-size: 24px; color: #A36A66;"></i><p style="margin-top: 10px;">Loading concern history...</p></div>';

                PageMethods.GetConcernHistory(employeeId, function (response) {
                    content.innerHTML = response;
                }, function (error) {
                    content.innerHTML = '<div style="padding: 20px; color: #dc3545;">Error loading concern history.</div>';
                });
            }

            // Helper to render concerns instantly on the client side
            function renderConcernsLocally(concerns, container) {
                let html = '<div style="padding: 20px;">';
                html += '<h3 style="color: #8B4755; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 8px;">Concern History</h3>';

                // Sort by date descending
                concerns.sort((a, b) => new Date(b.submittedDate || b.SubmittedDate) - new Date(a.submittedDate || b.SubmittedDate));

                concerns.forEach(c => {
                    const priority = c.priorityLevel || c.PriorityLevel || "Medium";
                    const status = c.status || c.Status || "Pending";
                    const subject = c.subject || c.Subject || "No Subject";
                    const desc = c.description || c.Description || "";
                    const type = c.concernType || c.ConcernType || "Employee";
                    const dateRaw = c.submittedDate || c.SubmittedDate;
                    const dateStr = dateRaw ? new Date(dateRaw).toLocaleString('en-US', { month: 'short', day: '2-digit', year: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true }) : "";

                    const priorityColor = priority === "Urgent" ? "#ef4444" : priority === "High" ? "#f59e0b" : priority === "Medium" ? "#3b82f6" : "#10b981";
                    const statusColor = status === "Resolved" ? "#10b981" : status === "Closed" ? "#6b7280" : status === "In Progress" ? "#3b82f6" : "#f59e0b";

                    html += `<div style="background: #f9f9f9; border-radius: 10px; padding: 16px; margin-bottom: 16px; border-left: 4px solid ${priorityColor};">`;
                    html += `  <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">`;
                    html += `    <div><strong style="color: #333; font-size: 16px;">${subject}</strong></div>`;
                    html += `    <div style="display: flex; gap: 8px; flex-wrap: wrap;">`;
                    html += `      <span style="background: ${priorityColor}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;">${priority}</span>`;
                    html += `      <span style="background: ${statusColor}; color: white; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600;">${status}</span>`;
                    html += `    </div></div>`;
                    html += `  <div style="margin-bottom: 8px; color: #666;"><strong>Type:</strong> ${type}</div>`;
                    html += `  <div style="margin-bottom: 8px; color: #666;"><strong>Description:</strong> ${desc}</div>`;
                    html += `  <div style="color: #999; font-size: 12px;"><strong>Submitted:</strong> ${dateStr}</div>`;
                    html += `</div>`;
                });

                html += '</div>';
                container.innerHTML = html;
            }

            function closeConcernHistoryModal() {
                document.getElementById('concernHistoryModal').style.display = 'none';
            }

            // New Employee Action Functions
            function resignEmployee(id) {
                console.log("Resignation initiated for ID:", id);
                showConfirm("Confirm Resignation", "Are you sure you want to mark this employee as Resigned? This will deactivate their account and notify them via email.", function () {
                    console.log("Resignation confirmed, calling server...");
                    PageMethods.ResignEmployee(id, function (r) {
                        console.log("Server raw response:", r);
                        try {
                            var result = (typeof r === 'string') ? JSON.parse(r) : r;
                            closeEmployeeDetailsModal(); // Close details modal first
                            if (result.success) {
                                showAlert("Success", result.message, "success");
                                setTimeout(function () { window.location.reload(); }, 700);
                            } else {
                                showAlert("Process Failed", result.message, "error");
                            }
                        } catch (pe) {
                            console.error("Parse error:", pe);
                            showAlert("Error", "Unexpected response from server.", "error");
                        }
                    }, function (e) {
                        console.error("Server error:", e);
                        showAlert("Error", e.get_message ? e.get_message() : "Server error.", "error");
                    });
                });
            }

            function rehireEmployee(id) {
                console.log("Rehire initiated for ID:", id);
                showConfirm("Confirm Rehire", "Rehire this employee? This will reactivate their account.", function () {
                    console.log("Rehire confirmed, calling server...");
                    PageMethods.RehireEmployee(id, function (r) {
                        console.log("Server raw response:", r);
                        try {
                            var result = (typeof r === 'string') ? JSON.parse(r) : r;
                            closeEmployeeDetailsModal(); // Close details modal first
                            if (result.success) {
                                showAlert("Success", result.message, "success");
                                setTimeout(function () { window.location.reload(); }, 700);
                            } else {
                                showAlert("Process Failed", result.message, "error");
                            }
                        } catch (pe) {
                            console.error("Parse error:", pe);
                            showAlert("Error", "Unexpected response from server.", "error");
                        }
                    }, function (e) {
                        console.error("Server error:", e);
                        showAlert("Error", e.get_message ? e.get_message() : "Server error.", "error");
                    });
                });
            }

            function openDeployModal(id, currentDept) {
                document.getElementById('hdnDeployId').value = id;
                document.getElementById('ddlNewDept').value = currentDept;
                document.getElementById('deployModal').style.display = 'block';
            }

            function closeDeployModal() {
                document.getElementById('deployModal').style.display = 'none';
            }

            function submitDeployment() {
                const id = document.getElementById('hdnDeployId').value;
                const dept = document.getElementById('ddlNewDept').value;

                if (!dept) {
                    showAlert("Required", "Please select a department.", "info");
                    return;
                }

                PageMethods.DeployEmployee(id, dept, function (r) {
                    try {
                        var result = (typeof r === 'string') ? JSON.parse(r) : r;
                        closeEmployeeDetailsModal(); // Close details modal first
                        closeDeployModal(); // Close deploy modal
                        if (result.success) {
                            showAlert("Success", result.message, "success");
                            setTimeout(function () { window.location.reload(); }, 700);
                        } else {
                            showAlert("Process Failed", result.message, "error");
                        }
                    } catch (pe) {
                        showAlert("Error", "Unexpected response from server.", "error");
                    }
                }, function (e) { showAlert("Error", e.get_message ? e.get_message() : "Server error.", "error"); });
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                var detailsModal = document.getElementById('viewEmployeeDetailsModal');
                var payslipModal = document.getElementById('payslipModal');
                var leaveHistoryModal = document.getElementById('leaveHistoryModal');
                var concernHistoryModal = document.getElementById('concernHistoryModal');
                var deployModal = document.getElementById('deployModal');
                var confirmModal = document.getElementById('confirmActionModal');
                var alertModal = document.getElementById('genericAlertModal');

                if (event.target == detailsModal) {
                    closeEmployeeDetailsModal();
                } else if (event.target == payslipModal) {
                    closePayslipModal();
                } else if (event.target == leaveHistoryModal) {
                    closeLeaveHistoryModal();
                } else if (event.target == concernHistoryModal) {
                    closeConcernHistoryModal();
                } else if (event.target == deployModal) {
                    closeDeployModal();
                } else if (event.target == confirmModal) {
                    closeConfirmModal();
                } else if (event.target == alertModal) {
                    closeAlertModal();
                }
            }

            // Custom Dialog Helpers
            function showConfirm(title, message, onConfirm) {
                const modal = document.getElementById('confirmActionModal');
                document.getElementById('confirmModalTitle').textContent = title;
                document.getElementById('confirmModalMessage').textContent = message;
                const confirmBtn = document.getElementById('btnConfirmAction');

                // Simply assign the new handler (this automatically clears previous handler)
                confirmBtn.onclick = function () {
                    modal.style.display = 'none';
                    if (onConfirm) onConfirm();
                };

                modal.style.display = 'block';
            }

            function closeConfirmModal() {
                document.getElementById('confirmActionModal').style.display = 'none';
            }

            function showAlert(title, message, type = 'info') {
                // Force close other modals so alert is visible at the very top
                try { closeEmployeeDetailsModal(); } catch (e) { }
                try { closeConfirmModal(); } catch (e) { }
                try { closeDeployModal(); } catch (e) { }

                const modal = document.getElementById('genericAlertModal');
                document.getElementById('alertModalTitle').textContent = title;
                document.getElementById('alertModalMessage').textContent = message;

                const icon = document.getElementById('alertModalIcon');
                const status = document.getElementById('alertModalStatus');

                if (type === 'success') {
                    icon.innerHTML = '<i class="fas fa-check-circle" style="color: #10b981;"></i>';
                    status.textContent = 'Success!';
                    status.style.color = '#10b981';
                } else if (type === 'error') {
                    icon.innerHTML = '<i class="fas fa-times-circle" style="color: #ef4444;"></i>';
                    status.textContent = 'Error';
                    status.style.color = '#ef4444';
                } else {
                    icon.innerHTML = '<i class="fas fa-info-circle" style="color: #3b82f6;"></i>';
                    status.textContent = 'Information';
                    status.style.color = '#3b82f6';
                }

                // Force high z-index to break through any frozen overlay issues
                modal.style.zIndex = "9999";
                modal.style.display = 'block';
            }

            function closeAlertModal() {
                document.getElementById('genericAlertModal').style.display = 'none';
            }

            // ========== LEAVE REQUEST FUNCTIONS ==========

            // Load pending leave requests on page load
            document.addEventListener('DOMContentLoaded', function () {
                loadPendingLeaveRequests();
            });

            function loadPendingLeaveRequests() {
                PageMethods.GetPendingLeaveRequests(function (response) {
                    var result = typeof response === 'string' ? JSON.parse(response) : response;
                    var tbody = document.getElementById('leaveRequestsBody');

                    if (!result.success) {
                        tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px; color: #999;">Error loading leave requests: ' + result.message + '</td></tr>';
                        return;
                    }

                    if (!result.data || result.data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px; color: #999;">No pending leave requests.</td></tr>';
                        return;
                    }

                    tbody.innerHTML = result.data.map(function (leave) {
                        var initials = getInitials(leave.employeeName);
                        var dateRange = leave.startDate === leave.endDate
                            ? leave.startDate
                            : leave.startDate + ' - ' + leave.endDate;

                        return '<tr data-leave-id="' + leave.id + '">' +
                            '<td><span class="avatar-initial">' + initials + '</span>' + leave.employeeName + '</td>' +
                            '<td>' + (leave.employeeId || 'N/A') + '</td>' +
                            '<td>' + leave.leaveType + '</td>' +
                            '<td>' + dateRange + '</td>' +
                            '<td>' + leave.duration + '</td>' +
                            '<td>' + leave.reason + '</td>' +
                            '<td><span class="leave-status status-pending">Pending</span></td>' +
                            '<td>' +
                            '<button class="btn-outline" style="margin-right: 6px;" onclick="approveLeave(\'' + leave.id + '\', \'' + leave.employeeName.replace(/'/g, "\\'") + '\', this)"><svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>Approve</button>' +
                            '<button class="btn-outline" style="background: #dc3545; border-color: #dc3545; color: white;" onclick="declineLeave(\'' + leave.id + '\', \'' + leave.employeeName.replace(/'/g, "\\'") + '\', this)"><svg style="width:14px;height:14px;vertical-align:middle;fill:white;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Decline</button>' +
                            '</td>' +
                            '</tr>';
                    }).join('');
                }, function (error) {
                    console.error('Error loading leave requests:', error);
                    var tbody = document.getElementById('leaveRequestsBody');
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px; color: #999;">Error loading leave requests.</td></tr>';
                });
            }

            function getInitials(name) {
                if (!name) return '??';
                var parts = name.split(' ');
                if (parts.length >= 2) {
                    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
                }
                return name.substring(0, 2).toUpperCase();
            }

            function approveLeave(leaveId, employeeName, buttonElement) {
                showConfirm("Approve Leave", "Are you sure you want to approve the leave request for " + employeeName + "?", function () {
                    // Disable buttons while processing
                    var row = buttonElement.closest('tr');
                    var buttons = row.querySelectorAll('button');
                    buttons.forEach(function (btn) { btn.disabled = true; });
                    buttonElement.textContent = 'Processing...';

                    PageMethods.ApproveLeaveRequest(leaveId, function (response) {
                        var result = typeof response === 'string' ? JSON.parse(response) : response;

                        if (result.success) {
                            // Update the row to show approved status
                            var actionCell = buttonElement.parentNode;
                            actionCell.innerHTML = '<span class="leave-status status-approved"><svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>Approved</span>';

                            // Update the status cell
                            var statusCell = row.querySelector('td:nth-child(7)');
                            if (statusCell) {
                                statusCell.innerHTML = '<span class="leave-status status-approved">Approved</span>';
                            }

                            // Optionally remove the row after a delay
                            setTimeout(function () {
                                row.style.opacity = '0.5';
                            }, 1000);
                        } else {
                            showAlert("Error", "Failed to approve leave: " + result.message, "error");
                            // Re-enable buttons
                            buttons.forEach(function (btn) { btn.disabled = false; });
                            buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>Approve';
                        }
                    }, function (error) {
                        console.error('Error approving leave:', error);
                        showAlert("Error", "Error approving leave request. Please try again.", "error");
                        // Re-enable buttons
                        buttons.forEach(function (btn) { btn.disabled = false; });
                        buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.41-1.41z"/></svg>Approve';
                    });
                });
            }

            function declineLeave(leaveId, employeeName, buttonElement) {
                showConfirm("Decline Leave", "Are you sure you want to decline the leave request for " + employeeName + "?", function () {
                    // Disable buttons while processing
                    var row = buttonElement.closest('tr');
                    var buttons = row.querySelectorAll('button');
                    buttons.forEach(function (btn) { btn.disabled = true; });
                    buttonElement.textContent = 'Processing...';

                    PageMethods.DeclineLeaveRequest(leaveId, function (response) {
                        var result = typeof response === 'string' ? JSON.parse(response) : response;

                        if (result.success) {
                            // Update the row to show declined status
                            var actionCell = buttonElement.parentNode;
                            actionCell.innerHTML = '<span class="leave-status status-declined"><svg style="width:14px;height:14px;vertical-align:middle;fill:#DC3545;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Declined</span>';

                            // Update the status cell
                            var statusCell = row.querySelector('td:nth-child(7)');
                            if (statusCell) {
                                statusCell.innerHTML = '<span class="leave-status status-declined">Declined</span>';
                            }

                            // Optionally remove the row after a delay
                            setTimeout(function () {
                                row.style.opacity = '0.5';
                            }, 1000);
                        } else {
                            showAlert("Error", "Failed to decline leave: " + result.message, "error");
                            // Re-enable buttons
                            buttons.forEach(function (btn) { btn.disabled = false; });
                            buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:white;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Decline';
                        }
                    }, function (error) {
                        console.error('Error declining leave:', error);
                        showAlert("Error", "Error declining leave request. Please try again.", "error");
                        // Re-enable buttons
                        buttons.forEach(function (btn) { btn.disabled = false; });
                        buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:white;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Decline';
                    });
                });
            }
        </script>

        <!-- Hidden fields and buttons for postback -->
        <asp:HiddenField ID="hdnEmployeeId" runat="server" />
        <asp:HiddenField ID="hdnConcernsJson" runat="server" />
        <input type="hidden" id="hdnDeployId" />
        <asp:Button ID="btnViewEmployeeDetails" runat="server" OnClick="btnViewEmployeeDetails_Click"
            Style="display:none;" />
        <asp:Button ID="btnViewLeaveHistory" runat="server" OnClick="btnViewLeaveHistory_Click" Style="display:none;" />
        <asp:Button ID="btnViewConcernHistory" runat="server" OnClick="btnViewConcernHistory_Click"
            Style="display:none;" />

        <!-- View Employee Details Modal -->
        <asp:UpdatePanel ID="upDetails" runat="server">
            <ContentTemplate>
                <div id="viewEmployeeDetailsModal" class="page-modal">
                    <div class="modal-content" style="max-width: 900px;">
                        <div class="modal-header">
                            <h2 class="modal-title">Employee Details</h2>
                            <span class="close" onclick="closeEmployeeDetailsModal()">&times;</span>
                        </div>
                        <div id="employeeDetailsContent" runat="server" style="max-height: 80vh; overflow-y: auto;">
                            <!-- Content will be populated by server-side code -->
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Deploy to Department Modal -->
        <div id="deployModal" class="page-modal">
            <div class="modal-content" style="max-width: 500px;">
                <div class="modal-header">
                    <h2 class="modal-title">Deploy to Department</h2>
                    <span class="close" onclick="closeDeployModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label">Select Department</label>
                        <select id="ddlNewDept" class="form-select">
                            <option value="Research & Development">Research & Development</option>
                            <option value="Quality Control">Quality Control</option>
                            <option value="Human Resources">Human Resources</option>
                            <option value="Finance">Finance</option>
                            <option value="Marketing">Marketing</option>
                            <option value="IT Support">IT Support</option>
                            <option value="Operations">Operations</option>
                            <option value="Sales">Sales</option>
                            <option value="Inventory">Inventory</option>
                            <option value="Customer Service">Customer Service</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeDeployModal()">Cancel</button>
                    <button type="button" class="btn-submit" onclick="submitDeployment()">Confirm Deployment</button>
                </div>
            </div>
        </div>

        <!-- Payslip Modal -->
        <div id="payslipModal" class="page-modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title"><svg
                            style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;"
                            viewBox="0 0 24 24">
                            <path
                                d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z" />
                        </svg> Payslip Details</h2>
                    <span class="close" onclick="closePayslipModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <h3 style="margin-bottom: 16px; color: #333;">Gross Salary</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">Basic Salary</span>
                        <span class="payslip-value">&#8369;35,000.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Allowances</span>
                        <span class="payslip-value">&#8369;5,000.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Overtime Pay</span>
                        <span class="payslip-value">&#8369;2,500.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label"><strong>Total Gross</strong></span>
                        <span class="payslip-value"><strong>&#8369;42,500.00</strong></span>
                    </div>

                    <h3 style="margin: 24px 0 16px; color: #333;">Deductions</h3>
                    <div class="payslip-item">
                        <span class="payslip-label">SSS</span>
                        <span class="payslip-value" style="color: #f59e0b;">- &#8369;1,350.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">PhilHealth</span>
                        <span class="payslip-value" style="color: #f59e0b;">- &#8369;850.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Pag-IBIG</span>
                        <span class="payslip-value" style="color: #f59e0b;">- &#8369;200.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label">Withholding Tax</span>
                        <span class="payslip-value" style="color: #f59e0b;">- &#8369;3,200.00</span>
                    </div>
                    <div class="payslip-item">
                        <span class="payslip-label"><strong>Total Deductions</strong></span>
                        <span class="payslip-value" style="color: #f59e0b;"><strong>- &#8369;5,600.00</strong></span>
                    </div>

                    <div class="payslip-total">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="payslip-label" style="color: white; font-size: 18px;">Net Salary</span>
                            <span class="payslip-value">&#8369;36,900.00</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-cancel" onclick="closePayslipModal()">Close</button>
                    <button class="btn-submit">Download PDF</button>
                </div>
            </div>
        </div>

        <!-- Leave History Modal -->
        <div id="leaveHistoryModal" class="page-modal">
            <div class="modal-content" style="max-width: 800px;">
                <div class="modal-header">
                    <h2 class="modal-title"><svg
                            style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;"
                            viewBox="0 0 24 24">
                            <path
                                d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z" />
                        </svg> History Leave of Absence</h2>
                    <span class="close" onclick="closeLeaveHistoryModal()">&times;</span>
                </div>
                <div id="leaveHistoryContent" runat="server" style="max-height: 80vh; overflow-y: auto;">
                    <!-- Content will be populated by server-side code -->
                </div>
                <div class="modal-footer">
                    <button class="btn-cancel" onclick="closeLeaveHistoryModal()">Close</button>
                </div>
            </div>
        </div>

        <!-- Concern History Modal -->
        <div id="concernHistoryModal" class="page-modal">
            <div class="modal-content" style="max-width: 800px;">
                <div class="modal-header">
                    <h2 class="modal-title"><svg
                            style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;"
                            viewBox="0 0 24 24">
                            <path
                                d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 12h-2v-2h2v2zm0-4h-2V6h2v4z" />
                        </svg> History of Employee Concern</h2>
                    <span class="close" onclick="closeConcernHistoryModal()">&times;</span>
                </div>
                <div id="concernHistoryContent" runat="server" style="max-height: 80vh; overflow-y: auto;">
                    <!-- Content will be populated by server-side code -->
                </div>
                <div class="modal-footer">
                    <button class="btn-cancel" onclick="closeConcernHistoryModal()">Close</button>
                </div>
            </div>
        </div>

        <!-- Confirmation Modal -->
        <div id="confirmActionModal" class="page-modal" style="z-index: 5000;">
            <div class="modal-content" style="max-width: 450px; margin-top: 15vh;">
                <div class="modal-header" style="background: #8B4755; color: white;">
                    <h2 id="confirmModalTitle" class="modal-title">Confirm Action</h2>
                    <span class="close" onclick="closeConfirmModal()" style="color: white;">&times;</span>
                </div>
                <div class="modal-body" style="padding: 25px;">
                    <p id="confirmModalMessage" style="font-size: 16px; color: #4b5563; line-height: 1.5;"></p>
                </div>
                <div class="modal-footer"
                    style="padding: 15px 25px; background: #f9fafb; border-top: 1px solid #e5e7eb; display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="btn-cancel" onclick="closeConfirmModal()"
                        style="margin: 0; min-width: 100px;">Cancel</button>
                    <button type="button" id="btnConfirmAction" class="btn-submit"
                        style="margin: 0; background: #8B4755; min-width: 100px;">Confirm</button>
                </div>
            </div>
        </div>

        <!-- Generic Alert Modal -->
        <div id="genericAlertModal" class="page-modal" style="z-index: 5001;">
            <div class="modal-content" style="max-width: 450px; margin-top: 15vh;">
                <div class="modal-header" style="background: #8B4755; color: white;">
                    <h2 id="alertModalTitle" class="modal-title">Notification</h2>
                    <span class="close" onclick="closeAlertModal()" style="color: white;">&times;</span>
                </div>
                <div class="modal-body" style="text-align: center; padding: 40px 25px;">
                    <div id="alertModalIcon" style="font-size: 64px; margin-bottom: 20px;"></div>
                    <h3 id="alertModalStatus" style="font-size: 20px; color: #111827; margin-bottom: 10px;"></h3>
                    <p id="alertModalMessage" style="font-size: 15px; color: #6b7280; line-height: 1.6;"></p>
                </div>
                <div class="modal-footer"
                    style="padding: 15px 25px; background: #f9fafb; border-top: 1px solid #e5e7eb; display: flex; justify-content: center;">
                    <button type="button" class="btn-submit" onclick="closeAlertModal()"
                        style="min-width: 140px; margin: 0; background: #8B4755;">Got it</button>
                </div>
            </div>
        </div>
    </asp:Content>