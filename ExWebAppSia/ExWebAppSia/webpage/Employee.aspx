<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true" CodeBehind="Employee.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <style type="text/css">
    .employee-container {
        display: flex;
        gap: 20px;
        padding: 20px;
        width: 100%;
        height: calc(100vh - 120px); /* Adjust based on your master page header/footer */
        box-sizing: border-box;
    }

    .main-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 20px;
        /* 🛑 CRITICAL: Prevent overflow into concerns panel */
        max-width: calc(100% - 380px); /* 350px panel + 30px gap */
        min-width: 700px;
    }

    .dept-header {
        color: white;
        font-size: 36px;
        font-weight: 300;
        text-align: left; /* 🔁 Force LEFT alignment */
        padding: 0;
        margin: 0 0 10px 0;
        letter-spacing: 1px;
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
        background: linear-gradient(135deg, #E8E8E8 0%, #F5F5F5 100%);
        border-radius: 32px; /* slightly smaller */
        padding: 6px 14px 6px 8px; /* 🔽 reduced padding */
        box-shadow: 0 4px 12px rgba(0,0,0,0.18);
        cursor: pointer;
        transition: all 0.25s ease;
        min-height: 56px; /* 🔽 shorter */
        position: relative;
    }

    .dept-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.22);
    }

    .dept-card:active {
        transform: translateY(0);
    }

    .dept-card.active {
        box-shadow: 0 0 0 3px #8B4755, 0 6px 16px rgba(139, 71, 85, 0.3);
    }

    .dept-stats {
        background: linear-gradient(135deg, #9B5B65 0%, #7D4850 100%);
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
        color: #8B4755;
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

    .print-report-btn {
        display: flex;
        align-items: center;
        padding: 14px 24px;
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
        color: white;
        border: none;
        border-radius: 32px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
        white-space: nowrap;
    }

    .print-report-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(139, 71, 85, 0.3);
    }

    .print-report-btn:active {
        transform: translateY(0);
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
        border-radius: 20px;
        box-shadow: 0 3px 12px rgba(0,0,0,0.1);
        overflow: hidden;
        flex: 1;
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
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
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
        box-shadow: 0 6px 16px rgba(139, 71, 85, 0.2);
        border-color: #8B4755;
    }

    .action-icon {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
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
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
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
        box-shadow: 0 4px 12px rgba(139, 71, 85, 0.3);
    }

    /* Form Styles for Action Modals */
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
        border-color: #8B4755;
        box-shadow: 0 0 0 3px rgba(139, 71, 85, 0.1);
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
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
        color: white;
    }

    .btn-submit:hover {
        transform: scale(1.05);
    }

    .btn-cancel {
        background: #E5E7EB;
        color: #333;
    }

    .btn-cancel:hover {
        background: #D1D5DB;
    }

    /* Payslip Styles */
    .payslip-item {
        padding: 12px 16px;
        background: #FFE8E8;
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
        background: linear-gradient(135deg, #8B4755 0%, #9B5B65 100%);
        color: white;
        padding: 16px;
        border-radius: 10px;
        margin-top: 16px;
    }

    .payslip-total .payslip-value {
        color: white;
        font-size: 24px;
    }

    /* Employee Concerns Panel - RIGHT */
    .concerns-panel {
        width: 350px;
        background: white;
        border-radius: 20px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.12);
        overflow-y: auto;
        padding: 22px;
        max-height: 100%;
        flex-shrink: 0;
        box-sizing: border-box;
    }

    .concern-header {
        font-size: 19px;
        font-weight: 600;
        color: #8B4755;
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

    /* Responsive: Stack on small screens */
    @media (max-width: 1199px) {
        .employee-container {
            flex-direction: column;
            height: auto;
        }
        .main-content {
            max-width: 100% !important;
            min-width: auto;
        }
        .concerns-panel {
            width: 100%;
            max-height: 450px;
        }
    }

    @media (max-width: 992px) {
        .department-filter {
            grid-template-columns: repeat(3, 1fr);
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
    <div class="employee-container">
        <!-- LEFT SIDE: Main Content -->
        <div class="main-content">
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

            <!-- Search Bar and Print Report Button -->
            <div style="display: flex; gap: 15px; align-items: center; margin-bottom: 15px;">
                <div class="search-container" style="flex: 1; margin-bottom: 0;">
                    <svg class="search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                    <input type="text" class="search-bar" id="searchInput" placeholder="Search by Employee ID, Name, Department, or Role..." />
                </div>
                <button id="btnPrintReport" class="print-report-btn" onclick="generateReport()">
                    <svg style="width: 18px; height: 18px; margin-right: 8px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    Print Report
                </button>
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

    <!-- JavaScript for Filtering -->
    <script>
        (function() {
            const deptCards = document.querySelectorAll('.dept-card');
            const searchInput = document.getElementById('searchInput');

            if (!searchInput) return;

            function resetActive() {
                deptCards.forEach(card => card.classList.remove('active'));
            }

            function applyFilter(selectedDept = null) {
                const searchTerm = (searchInput.value || '').toLowerCase().trim();
                // Re-query rows each time to ensure we get all current rows
                const tableBody = document.getElementById('<%= employeeTableBody.ClientID %>');
                if (!tableBody) return;
                
                const tableRows = tableBody.querySelectorAll('tr');
                let visibleCount = 0;
                
                tableRows.forEach(row => {
                    // Skip the "No employees found" row
                    const hasColspan = row.querySelector('td[colspan]');
                    if (hasColspan) {
                        // Hide the "No employees found" row if we have search/filter active
                        if (searchTerm || selectedDept) {
                            row.style.display = 'none';
                        } else {
                            row.style.display = '';
                        }
                        return;
                    }
                    
                    const dept = (row.getAttribute('data-dept') || '').toLowerCase();
                    const cells = row.querySelectorAll('td');
                    let rowText = '';
                    cells.forEach(cell => {
                        rowText += (cell.textContent || '').toLowerCase() + ' ';
                    });
                    
                    const matchesDept = !selectedDept || dept === selectedDept.toLowerCase();
                    const matchesSearch = !searchTerm || rowText.includes(searchTerm);
                    
                    if (matchesDept && matchesSearch) {
                        row.classList.remove('filtered-out');
                        row.style.display = '';
                        visibleCount++;
                    } else {
                        row.classList.add('filtered-out');
                        row.style.display = 'none';
                    }
                });

                // Show "No employees found" message if no rows are visible
                const noDataRow = tableBody.querySelector('tr td[colspan]');
                if (noDataRow) {
                    const parentRow = noDataRow.closest('tr');
                    if (visibleCount === 0 && (searchTerm || selectedDept)) {
                        parentRow.style.display = '';
                        parentRow.querySelector('td').textContent = 'No employees match your search criteria.';
                    } else if (visibleCount === 0 && !searchTerm && !selectedDept) {
                        parentRow.style.display = '';
                        parentRow.querySelector('td').textContent = 'No employees found.';
                    } else {
                        parentRow.style.display = 'none';
                    }
                }
            }

            // Department card click handlers
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

            // Search input handlers
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    const activeCard = document.querySelector('.dept-card.active');
                    const currentDept = activeCard ? activeCard.getAttribute('data-dept') : null;
                    applyFilter(currentDept);
                });

                // Prevent form submission when pressing Enter in search bar
                searchInput.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        const activeCard = document.querySelector('.dept-card.active');
                        const currentDept = activeCard ? activeCard.getAttribute('data-dept') : null;
                        applyFilter(currentDept);
                    }
                });
            }

            // Initial filter application - wait a bit to ensure DOM is ready
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function() {
                    setTimeout(applyFilter, 100);
                });
            } else {
                setTimeout(applyFilter, 100);
            }
        })();

        function generateReport() {
            window.open('EmployeeReport.aspx', '_blank');
        }

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
                <h2 class="modal-title">💰 Payslip Details</h2>
                <span class="close" onclick="closePayslipModal()">&times;</span>
            </div>
            <div class="modal-body">
                <h3 style="margin-bottom: 16px; color: #333;">Gross Salary</h3>
                <div class="payslip-item">
                    <span class="payslip-label">Basic Salary</span>
                    <span class="payslip-value">₱35,000.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Allowances</span>
                    <span class="payslip-value">₱5,000.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Overtime Pay</span>
                    <span class="payslip-value">₱2,500.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label"><strong>Total Gross</strong></span>
                    <span class="payslip-value"><strong>₱42,500.00</strong></span>
                </div>

                <h3 style="margin: 24px 0 16px; color: #333;">Deductions</h3>
                <div class="payslip-item">
                    <span class="payslip-label">SSS</span>
                    <span class="payslip-value" style="color: #f59e0b;">- ₱1,350.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">PhilHealth</span>
                    <span class="payslip-value" style="color: #f59e0b;">- ₱850.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Pag-IBIG</span>
                    <span class="payslip-value" style="color: #f59e0b;">- ₱200.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label">Withholding Tax</span>
                    <span class="payslip-value" style="color: #f59e0b;">- ₱3,200.00</span>
                </div>
                <div class="payslip-item">
                    <span class="payslip-label"><strong>Total Deductions</strong></span>
                    <span class="payslip-value" style="color: #f59e0b;"><strong>- ₱5,600.00</strong></span>
                </div>

                <div class="payslip-total">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span class="payslip-label" style="color: white; font-size: 18px;">Net Salary</span>
                        <span class="payslip-value">₱36,900.00</span>
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
                <h2 class="modal-title">📝 History Leave of Absence</h2>
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
                <h2 class="modal-title">💬 History of Employee Concern</h2>
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