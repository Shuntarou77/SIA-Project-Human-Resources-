<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true" CodeBehind="Employee.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <style type="text/css">
        :root {
            --primary-color: #A36A66;
            --secondary-color: #C49A99;        /* Lighter tint of #A36A66 */
            --accent-color: #F8ECEB;           /* Very soft warm tint */
            --card-shadow: 0 10px 30px rgba(163, 106, 102, 0.15);
            --hover-shadow: 0 15px 40px rgba(163, 106, 102, 0.25);
            --border-radius: 20px;
            --text-primary: #4A3534;           /* Darker warm neutral */
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
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
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
            font-size: 9px;
            color: #888;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
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
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
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

        /* Modal Styles */
        .modal {
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
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
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
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
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
            background: linear-gradient(135deg, #905A57 0%, #A36A66 100%); /* slightly darker → standard */
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
            background: #8B5A58; /* slightly darker */
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
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
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

        <!-- 10 Department Cards (2 rows x 5 columns) -->
        <div class="department-filter">
            <div class="dept-card" data-dept="Research & Development">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litRDCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Research & Development</div>
                        <div class="dept-head">Head: CJ Junio</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Quality Control">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litQCCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Quality Control</div>
                        <div class="dept-head">Head: Mara Santos</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Human Resources">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litHRCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Human Resources</div>
                        <div class="dept-head">Head: Ana Reyes</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Finance">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litFinanceCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Finance</div>
                        <div class="dept-head">Head: Leo Cruz</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Marketing">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litMarketingCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Marketing</div>
                        <div class="dept-head">Head: Tina Gomez</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="IT Support">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litITCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">IT Support</div>
                        <div class="dept-head">Head: Ben Lim</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Operations">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litOperationsCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Operations</div>
                        <div class="dept-head">Head: Dave Tan</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Sales">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litSalesCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Sales</div>
                        <div class="dept-head">Head: Carla Diaz</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Legal">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litLegalCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Legal</div>
                        <div class="dept-head">Head: Paul Ortega</div>
                    </div>
                </div>
                <div class="dept-card" data-dept="Customer Service">
                    <div class="dept-stats">
                        <span class="dept-count"><asp:Literal ID="litCustomerServiceCount" runat="server" Text="0"></asp:Literal></span>
                        <span class="dept-label">EMPLOYEES</span>
                    </div>
                    <div class="dept-info">
                        <div class="dept-name">Customer Service</div>
                        <div class="dept-head">Head: Joy Manalo</div>
                    </div>
                </div>
        </div>

        <!-- Search Bar -->
        <div class="search-container">
            <svg class="search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
            <input type="text" class="search-bar" id="searchInput" placeholder="Search..." />
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
    </div>

    <!-- RIGHT SIDE: Employee Concerns Panel -->
    <div class="concerns-panel">
        <div class="concern-header">Employee Concern</div>
        <% for (int i = 0; i < 5; i++) { %>
        <div class="concern-card">
            <div class="concern-header-row">
                <div class="concern-avatar">
                    <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDQwIDQwIj4KICA8Y2lyY2xlIGN4PSIyMCIgY3k9IjIwIiByPSIyMCIgZmlsbD0iIzk5OTkiLz4KICA8Y2lyY2xlIGN4PSIxNSIgY3k9IjE1IiByPSI3IiBmaWxsPSIjRkZGRkZGIi8+Cjwvc3ZnPg==" alt="Avatar" />
                </div>
                <div>
                    <div class="concern-title">Padilla, Dan Jerciey</div>
                    <div class="concern-role">Employee</div>
                </div>
            </div>
            <div class="concern-text">
                I would like to formally express my concern regarding [employee's name]. Recently, I have observed issues related to [attendance, performance, behavior, attitude, teamwork, or specific incident]. These concerns may affect the overall productivity, work environment, and team dynamics if not addressed promptly.
            </div>
        </div>
        <% } %>
    </div>
    </div>

    <!-- Bottom Section: Leave Requests Table -->
    <div class="bottom-section-container">
        <div class="attendance-table-container">
            <h3 class="table-title"><svg style="width:20px;height:20px;vertical-align:middle;margin-right:8px;fill:var(--primary-color);" viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg> Leave Requests &mdash; Pending Approval</h3>
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

            function resetActive() {
                deptCards.forEach(card => card.classList.remove('active'));
            }

            function applyFilter(selectedDept = null) {
                const searchTerm = (searchInput.value || '').toLowerCase();
                // Get all rows from the table body
                const tableRows = tableBody ? tableBody.querySelectorAll('tr') : [];
                
                tableRows.forEach(row => {
                    const dept = row.getAttribute('data-dept');
                    const text = row.textContent.toLowerCase();
                    const matchesDept = selectedDept ? dept === selectedDept : true;
                    const matchesSearch = text.includes(searchTerm);
                    if (matchesDept && matchesSearch) {
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
                        applyFilter(dept);
                    } else {
                        applyFilter(null);
                    }
                });
            });

            // Fix search input listener
            if (searchInput) {
                searchInput.addEventListener('input', () => {
                    const activeCard = document.querySelector('.dept-card.active');
                    const currentDept = activeCard ? activeCard.getAttribute('data-dept') : null;
                    applyFilter(currentDept);
                });
            }
        });

        // Modal functions
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
            document.getElementById('<%= hdnEmployeeId.ClientID %>').value = employeeId;
            __doPostBack('<%= btnViewLeaveHistory.UniqueID %>', '');
        }

        function closeLeaveHistoryModal() {
            document.getElementById('leaveHistoryModal').style.display = 'none';
        }

        function openConcernHistoryModal(employeeId) {
            document.getElementById('<%= hdnEmployeeId.ClientID %>').value = employeeId;
            __doPostBack('<%= btnViewConcernHistory.UniqueID %>', '');
        }

        function closeConcernHistoryModal() {
            document.getElementById('concernHistoryModal').style.display = 'none';
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            var detailsModal = document.getElementById('viewEmployeeDetailsModal');
            var payslipModal = document.getElementById('payslipModal');
            var leaveHistoryModal = document.getElementById('leaveHistoryModal');
            var concernHistoryModal = document.getElementById('concernHistoryModal');
            
            if (event.target == detailsModal) {
                closeEmployeeDetailsModal();
            } else if (event.target == payslipModal) {
                closePayslipModal();
            } else if (event.target == leaveHistoryModal) {
                closeLeaveHistoryModal();
            } else if (event.target == concernHistoryModal) {
                closeConcernHistoryModal();
            }
        }

        // ========== LEAVE REQUEST FUNCTIONS ==========
        
        // Load pending leave requests on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadPendingLeaveRequests();
        });

        function loadPendingLeaveRequests() {
            PageMethods.GetPendingLeaveRequests(function(response) {
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

                tbody.innerHTML = result.data.map(function(leave) {
                    var initials = getInitials(leave.employeeName);
                    var dateRange = leave.startDate === leave.endDate 
                        ? leave.startDate 
                        : leave.startDate + ' – ' + leave.endDate;
                    
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
            }, function(error) {
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
            if (!confirm('Approve leave for ' + employeeName + '?')) {
                return;
            }

            // Disable buttons while processing
            var row = buttonElement.closest('tr');
            var buttons = row.querySelectorAll('button');
            buttons.forEach(function(btn) { btn.disabled = true; });
            buttonElement.textContent = 'Processing...';

            PageMethods.ApproveLeaveRequest(leaveId, function(response) {
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
                    setTimeout(function() {
                        row.style.opacity = '0.5';
                    }, 1000);
                } else {
                    alert('Failed to approve leave: ' + result.message);
                    // Re-enable buttons
                    buttons.forEach(function(btn) { btn.disabled = false; });
                    buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>Approve';
                }
            }, function(error) {
                console.error('Error approving leave:', error);
                alert('Error approving leave request. Please try again.');
                // Re-enable buttons
                buttons.forEach(function(btn) { btn.disabled = false; });
                buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:#22C55E;margin-right:4px;" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>Approve';
            });
        }

        function declineLeave(leaveId, employeeName, buttonElement) {
            if (!confirm('Decline leave for ' + employeeName + '?')) {
                return;
            }

            // Disable buttons while processing
            var row = buttonElement.closest('tr');
            var buttons = row.querySelectorAll('button');
            buttons.forEach(function(btn) { btn.disabled = true; });
            buttonElement.textContent = 'Processing...';

            PageMethods.DeclineLeaveRequest(leaveId, function(response) {
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
                    setTimeout(function() {
                        row.style.opacity = '0.5';
                    }, 1000);
                } else {
                    alert('Failed to decline leave: ' + result.message);
                    // Re-enable buttons
                    buttons.forEach(function(btn) { btn.disabled = false; });
                    buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:white;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Decline';
                }
            }, function(error) {
                console.error('Error declining leave:', error);
                alert('Error declining leave request. Please try again.');
                // Re-enable buttons
                buttons.forEach(function(btn) { btn.disabled = false; });
                buttonElement.innerHTML = '<svg style="width:14px;height:14px;vertical-align:middle;fill:white;margin-right:4px;" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>Decline';
            });
        }
    </script>

    <!-- Hidden fields and buttons for postback -->
    <asp:HiddenField ID="hdnEmployeeId" runat="server" />
    <asp:Button ID="btnViewEmployeeDetails" runat="server" OnClick="btnViewEmployeeDetails_Click" Style="display:none;" />
    <asp:Button ID="btnViewLeaveHistory" runat="server" OnClick="btnViewLeaveHistory_Click" Style="display:none;" />
    <asp:Button ID="btnViewConcernHistory" runat="server" OnClick="btnViewConcernHistory_Click" Style="display:none;" />

    <!-- View Employee Details Modal -->
    <div id="viewEmployeeDetailsModal" class="modal">
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

    <!-- Payslip Modal -->
    <div id="payslipModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title"><svg style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;" viewBox="0 0 24 24"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/></svg> Payslip Details</h2>
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
    <div id="leaveHistoryModal" class="modal">
        <div class="modal-content" style="max-width: 800px;">
            <div class="modal-header">
                <h2 class="modal-title"><svg style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;" viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg> History Leave of Absence</h2>
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
    <div id="concernHistoryModal" class="modal">
        <div class="modal-content" style="max-width: 800px;">
            <div class="modal-header">
                <h2 class="modal-title"><svg style="width:24px;height:24px;vertical-align:middle;margin-right:8px;fill:white;" viewBox="0 0 24 24"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 12h-2v-2h2v2zm0-4h-2V6h2v4z"/></svg> History of Employee Concern</h2>
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
</asp:Content>