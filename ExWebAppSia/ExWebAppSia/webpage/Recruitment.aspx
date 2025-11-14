<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true" EnableEventValidation="false" CodeBehind="Recruitment.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm5" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --bg-color: #f9e6eb;
            --panel-bg: #ffffff;
            --accent: #b85c6a;
            --text-dark: #333333;
            --border-color: #e0e0e0;
            --hover-bg: #fafafa;
        }

        html, body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            height: 100%;
            width: 100%;
            box-sizing: border-box;
        }

        .recruitment-container {
            width: 100%;
            min-height: 100vh;
            padding: 20px;
            background-color: var(--bg-color);
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* Stat Cards */
        .stat-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-card {
            background-color: var(--accent);
            color: white;
            border-radius: 12px;
            padding: 16px 24px;
            text-align: center;
            min-width: 150px;
        }

        .stat-number {
            font-size: 24px;
            font-weight: bold;
            margin: 0;
            line-height: 1;
        }

        .stat-label {
            font-size: 12px;
            margin: 4px 0 0;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Main Panels */
        .main-panels {
            display: flex;
            gap: 20px;
            flex: 1;
        }

        .panel {
            background-color: var(--panel-bg);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .panel-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
            padding: 8px 12px;
            background-color: var(--accent);
            color: white;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14px;
        }

        .panel-title {
            font-size: 20px;
            font-weight: 600;
            color: var(--accent);
            margin: 0;
            text-align: center;
        }

        /* Table Styles */
        .applicant-table {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
        }

        .applicant-table th {
            padding: 10px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 13px;
            border-bottom: 2px solid var(--border-color);
        }

        .applicant-table td {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-dark);
            font-size: 13px;
        }

        .applicant-table tr:hover {
            background-color: var(--hover-bg);
        }

        .checkbox-cell {
            width: 40px;
        }

        .status-link {
            color: var(--accent);
            text-decoration: none;
            font-weight: 500;
        }

        .status-link:hover {
            text-decoration: underline;
        }

        .btn-hire, .btn-not-hire {
            padding: 6px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-hire {
            background-color: #4CAF50;
            color: white;
        }

        .btn-hire:hover {
            background-color: #45a049;
        }

        .btn-not-hire {
            background-color: #f44336;
            color: white;
        }

        .btn-not-hire:hover {
            background-color: #da190b;
        }

        /* Select All Checkbox */
        .select-all {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            padding: 8px 0;
            border-bottom: 1px solid var(--border-color);
        }

        .select-all input[type="checkbox"] {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        /* Schedule Interview Button */
        .schedule-button {
            background-color: var(--accent);
            color: white;
            border: none;
            border-radius: 24px;
            padding: 8px 24px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
            align-self: center;
            transition: background 0.2s;
        }

        .schedule-button:hover {
            background-color: #a00000;
        }

        /* Add Applicant Button */
        .add-applicant-button {
            background-color: var(--accent);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            margin-bottom: 20px;
            transition: background 0.2s;
            align-self: flex-start;
        }

        .add-applicant-button:hover {
            background-color: #a04a56;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 30px;
            border: none;
            border-radius: 12px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }

        .modal-title {
            font-size: 24px;
            font-weight: 600;
            color: var(--accent);
            margin: 0;
        }

        .close {
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            line-height: 20px;
        }

        .close:hover,
        .close:focus {
            color: var(--accent);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 14px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
            font-family: inherit;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--accent);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 24px;
        }

        .btn {
            padding: 10px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-primary {
            background-color: var(--accent);
            color: white;
        }

        .btn-primary:hover {
            background-color: #a04a56;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
        }

        .message {
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: none;
        }

        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .recruitment-container {
                padding: 12px;
            }

            .stat-cards {
                flex-direction: column;
                gap: 12px;
            }

            .main-panels {
                flex-direction: column;
                gap: 12px;
            }

            .panel {
                padding: 16px;
            }

            .applicant-table th,
            .applicant-table td {
                padding: 8px 10px;
                font-size: 12px;
            }

            .modal-content {
                width: 95%;
                margin: 10% auto;
                padding: 20px;
            }
        }
    </style>
    <script type="text/javascript">
        function openModal() {
            document.getElementById('addApplicantModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('addApplicantModal').style.display = 'none';
            document.getElementById('messageDiv').style.display = 'none';
        }

        function openDetailsModal(applicantId) {
            // Load applicant details via AJAX or server-side
            __doPostBack('btnViewDetails', applicantId);
        }

        function togglePreviousCompany() {
            var checkbox = document.getElementById('<%= chkPreviousCompany.ClientID %>');
            var div = document.getElementById('previousCompanySection');
            if (checkbox.checked) {
                div.style.display = 'block';
            } else {
                div.style.display = 'none';
            }
        }

        function toggleReferralName() {
            var dropdown = document.getElementById('<%= ddlHowDidYouHearUs.ClientID %>');
            var div = document.getElementById('referralNameSection');
            if (dropdown.value === 'Referral') {
                div.style.display = 'block';
            } else {
                div.style.display = 'none';
            }
        }

        function updateRoleHiddenField() {
            var roleDropdown = document.getElementById('ddlRoleClient');
            var hiddenField = document.getElementById('<%= hdnSelectedRole.ClientID %>');
            hiddenField.value = roleDropdown.value;
        }

        function updateRoleOptions() {
            var deptDropdown = document.getElementById('<%= ddlAppliedPosition.ClientID %>');
            var roleDropdown = document.getElementById('ddlRoleClient');
            var hiddenField = document.getElementById('<%= hdnSelectedRole.ClientID %>');
            var department = deptDropdown.value;

            // Clear existing options and hidden field
            roleDropdown.innerHTML = '<option value="">-- Select Role --</option>';
            hiddenField.value = '';

            // Role options based on department
            var roles = {
                'Research & Development': [
                    'R&D Director/Manager',
                    'Senior Formulation Chemist',
                    'Formulation Chemist',
                    'Lab Technician',
                    'Product Development Manager',
                    'Technical Project Coordinator'
                ],
                'Quality Control': [
                    'QA Manager/Director',
                    'QA Specialist/Officer',
                    'Compliance Officer',
                    'Document Control Specialist',
                    'Batch Release Coordinator'
                ],
                'Human Resources': [
                    'HR Manager/Director',
                    'HR Generalist',
                    'Recruiter/Talent Acquisition Specialist',
                    'Training & Development Coordinator',
                    'HR Coordinator',
                    'Safety Officer/EHS Coordinator',
                    'Compensation & Benefits Specialist'
                ],
                'Finance': [
                    'Finance Director/CFO',
                    'Financial Analyst',
                    'Cost Accountant',
                    'Pricing Analyst',
                    'Accountant',
                    'Bookkeeper',
                    'Payroll Specialist'
                ],
                'Marketing': [
                    'Marketing Director/Manager',
                    'Brand Manager',
                    'Product Marketing Manager',
                    'Social Media Manager',
                    'Content Creator/Copywriter',
                    'Graphic Designer',
                    'Digital Marketing Specialist',
                    'Influencer/PR Coordinator'
                ],
                'IT Support': [
                    'IT Manager/Director',
                    'Systems Administrator',
                    'Network Administrator',
                    'IT Support Specialist/Help Desk',
                    'Database Administrator',
                    'Cybersecurity Specialist',
                    'Manufacturing Systems Analyst',
                    'Business Analyst'
                ],
                'Operations': [
                    'Production Manager/Plant Manager',
                    'Production Supervisor/Shift Supervisor',
                    'Manufacturing Engineer/Process Engineer',
                    'Batch Maker/Mixing Operator',
                    'Filling/Packaging Operator',
                    'Production Scheduler/Planner',
                    'Maintenance Technician',
                    'Procurement Manager/Director',
                    'Supply Chain Manager',
                    'Buyer/Purchasing Officer',
                    'Sourcing Specialist',
                    'Packaging Buyer',
                    'Procurement Coordinator',
                    'Inventory Planner/Demand Planner',
                    'Warehouse Manager',
                    'Warehouse Supervisor',
                    'Logistics Coordinator',
                    'Inventory Control Specialist',
                    'Warehouse Associate/Material Handler',
                    'E-commerce Manager/Director',
                    'E-commerce Coordinator',
                    'Marketplace Specialist',
                    'E-commerce Analyst',
                    'Digital Content Manager',
                    'CRM/Email Marketing Specialist'
                ],
                'Sales': [
                    'Sales Director/VP of Sales',
                    'Key Account Manager',
                    'Sales Manager/Regional Sales Manager',
                    'Trade Marketing Manager',
                    'Sales Representative/Account Executive',
                    'Distributor Manager',
                    'Sales Coordinator'
                ],
                'Legal': [
                    'Legal Counsel/Director',
                    'Corporate Lawyer',
                    'Compliance Legal Specialist',
                    'Contract Specialist',
                    'Legal Assistant'
                ],
                'Customer Service': [
                    'Customer Service Manager',
                    'Customer Service Representative',
                    'Technical Support Specialist',
                    'Consumer Care Coordinator',
                    'Returns/Warranty Specialist'
                ]
            };

            // Populate role dropdown based on selected department
            if (department && roles[department]) {
                roles[department].forEach(function(role) {
                    var option = document.createElement('option');
                    option.value = role;
                    option.text = role;
                    roleDropdown.appendChild(option);
                });
            }
        }

        function closeDetailsModal() {
            document.getElementById('viewDetailsModal').style.display = 'none';
        }

        function openScheduleInterviewModal() {
            // Get selected applicant IDs - try multiple selectors to find checkboxes
            var tableBody = document.getElementById('<%= newApplicantsTableBody.ClientID %>');
            if (!tableBody) {
                alert('Unable to find applicants table. Please refresh the page.');
                return;
            }

            // Find all checkboxes in the table body
            var checkboxes = tableBody.querySelectorAll('input[type="checkbox"]');
            var checkedBoxes = [];
            
            checkboxes.forEach(function(checkbox) {
                if (checkbox.checked && checkbox.value) {
                    checkedBoxes.push(checkbox);
                }
            });

            if (checkedBoxes.length === 0) {
                alert('Please select at least one applicant to schedule an interview.');
                return;
            }

            var selectedIds = [];
            var selectedNames = [];

            checkedBoxes.forEach(function(checkbox) {
                if (checkbox.value) {
                    selectedIds.push(checkbox.value);
                    
                    // Get applicant name from the row
                    var row = checkbox.closest('tr');
                    if (row) {
                        var cells = row.getElementsByTagName('td');
                        if (cells.length > 1) {
                            var nameCell = cells[1]; // Name is in the second cell (index 1)
                            if (nameCell) {
                                selectedNames.push(nameCell.textContent.trim());
                            }
                        }
                    }
                }
            });

            if (selectedIds.length === 0) {
                alert('Please select at least one applicant to schedule an interview.');
                return;
            }

            // Store selected IDs in hidden field
            document.getElementById('<%= hdnSelectedApplicantIds.ClientID %>').value = selectedIds.join(',');

            // Show selected applicants in modal
            var listElement = document.getElementById('selectedApplicantsList');
            if (listElement) {
                listElement.innerHTML = selectedNames.map(function(name) {
                    return '<li>' + name + '</li>';
                }).join('');
            }

            // Show modal
            var modal = document.getElementById('scheduleInterviewModal');
            if (modal) {
                modal.style.display = 'block';
            }
        }

        function closeScheduleInterviewModal() {
            document.getElementById('scheduleInterviewModal').style.display = 'none';
        }

        function validateAddApplicantForm() {
            // Validate only the add applicant form fields
            var firstName = document.getElementById('<%= txtFirstName.ClientID %>');
            var lastName = document.getElementById('<%= txtLastName.ClientID %>');
            var appliedPosition = document.getElementById('<%= ddlAppliedPosition.ClientID %>');
            var roleHidden = document.getElementById('<%= hdnSelectedRole.ClientID %>');
            var roleDropdown = document.getElementById('ddlRoleClient');
            var howDidYouHearUs = document.getElementById('<%= ddlHowDidYouHearUs.ClientID %>');

            if (!firstName || !firstName.value.trim()) {
                alert('Please enter a first name.');
                if (firstName) firstName.focus();
                return false;
            }

            if (!lastName || !lastName.value.trim()) {
                alert('Please enter a last name.');
                if (lastName) lastName.focus();
                return false;
            }

            if (!appliedPosition || !appliedPosition.value) {
                alert('Please select a department (Applied Position).');
                if (appliedPosition) appliedPosition.focus();
                return false;
            }

            // Update hidden field before validation
            if (roleDropdown && roleHidden) {
                roleHidden.value = roleDropdown.value;
            }

            if (!roleHidden || !roleHidden.value) {
                alert('Please select a role (Job Title).');
                if (roleDropdown) roleDropdown.focus();
                return false;
            }

            if (!howDidYouHearUs || !howDidYouHearUs.value) {
                alert('Please select how you heard about us.');
                if (howDidYouHearUs) howDidYouHearUs.focus();
                return false;
            }

            return true;
        }

        function validateScheduleInterviewForm() {
            // Validate only the schedule interview form fields
            var date = document.getElementById('<%= txtInterviewDate.ClientID %>');
            var time = document.getElementById('<%= txtInterviewTime.ClientID %>');
            var location = document.getElementById('<%= txtInterviewLocation.ClientID %>');
            var interviewer = document.getElementById('<%= txtInterviewerName.ClientID %>');

            if (!date || !date.value) {
                alert('Please enter an interview date.');
                if (date) date.focus();
                return false;
            }

            if (!time || !time.value) {
                alert('Please enter an interview time.');
                if (time) time.focus();
                return false;
            }

            if (!location || !location.value.trim()) {
                alert('Please enter an interview location.');
                if (location) location.focus();
                return false;
            }

            if (!interviewer || !interviewer.value.trim()) {
                alert('Please enter an interviewer name.');
                if (interviewer) interviewer.focus();
                return false;
            }

            return true;
        }

        // Select All functionality
        function initializeSelectAll() {
            var selectAllCheckbox = document.getElementById('selectAll');
            if (selectAllCheckbox) {
                selectAllCheckbox.addEventListener('change', function() {
                    var tableBody = document.getElementById('<%= newApplicantsTableBody.ClientID %>');
                    if (tableBody) {
                        var checkboxes = tableBody.querySelectorAll('input[type="checkbox"].applicant-checkbox');
                        checkboxes.forEach(function(checkbox) {
                            checkbox.checked = selectAllCheckbox.checked;
                        });
                    }
                });
            }
        }

        // Initialize on page load
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializeSelectAll);
        } else {
            initializeSelectAll();
        }

        window.onclick = function(event) {
            var modal = document.getElementById('addApplicantModal');
            var detailsModal = document.getElementById('viewDetailsModal');
            var scheduleModal = document.getElementById('scheduleInterviewModal');
            if (event.target == modal) {
                closeModal();
            }
            if (event.target == detailsModal) {
                closeDetailsModal();
            }
            if (event.target == scheduleModal) {
                closeScheduleInterviewModal();
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="recruitment-container">
        <!-- Add Applicant Button -->
        <button type="button" class="add-applicant-button" onclick="openModal()">+ Add Applicant (Test)</button>

        <!-- Stat Cards -->
        <div class="stat-cards">
            <div class="stat-card">
                <div class="stat-number"><asp:Literal ID="litNewCount" runat="server" Text="0" /></div>
                <div class="stat-label">New Applicant</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><asp:Literal ID="litInProgressCount" runat="server" Text="0" /></div>
                <div class="stat-label">In-Progress Applicant</div>
            </div>
        </div>

        <!-- Main Panels -->
        <div class="main-panels">
            <!-- Left Panel: New Applicants -->
            <div class="panel">
                <div class="panel-header">New Applicants</div>
                <div class="panel-title">Approved Applicant</div>

                <div class="select-all">
                    <input type="checkbox" id="selectAll" />
                    <label for="selectAll">Select All</label>
                </div>

                <table class="applicant-table">
                    <thead>
                        <tr>
                            <th></th>
                            <th>Name</th>
                            <th>Applied Position</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="newApplicantsTableBody" runat="server">
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px; color: #999;">
                                No new applicants found.
                            </td>
                        </tr>
                    </tbody>
                </table>

                <button type="button" class="schedule-button" onclick="openScheduleInterviewModal();">Schedule Interview</button>
            </div>

            <!-- Right Panel: In-Progress Applicants -->
            <div class="panel">

                <div class="panel-title">In - Progress Applicants</div>

                <table class="applicant-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Applied Position</th>
                            <th style="text-align: center;">Details</th>
                            <th style="text-align: center;">Status</th>
                        </tr>
                    </thead>
                    <tbody id="inProgressApplicantsTableBody" runat="server">
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px; color: #999;">
                                No in-progress applicants found.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add Applicant Modal -->
    <div id="addApplicantModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Add New Applicant (Test)</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div id="messageDiv" class="message" runat="server"></div>
            <div id="addApplicantForm" style="max-height: 80vh; overflow-y: auto;">
                <h3 style="color: var(--accent); margin-bottom: 20px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">Recruitment Information</h3>
                
                <h4 style="color: var(--accent); margin: 20px 0 15px 0;">Personal Info</h4>
                <div class="form-group">
                    <label for="<%= txtFirstName.ClientID %>">First Name *</label>
                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtMiddleName.ClientID %>">Middle Name</label>
                    <asp:TextBox ID="txtMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtLastName.ClientID %>">Last Name *</label>
                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtAge.ClientID %>">Age</label>
                    <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtBirthDate.ClientID %>">Birthdate</label>
                    <asp:TextBox ID="txtBirthDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= ddlGender.ClientID %>">Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                        <asp:ListItem Value="">-- Select Gender --</asp:ListItem>
                        <asp:ListItem Value="Male">Male</asp:ListItem>
                        <asp:ListItem Value="Female">Female</asp:ListItem>
                        <asp:ListItem Value="Other">Other</asp:ListItem>
                        <asp:ListItem Value="Prefer not to say">Prefer not to say</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label for="<%= txtEmail.ClientID %>">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtContactNo.ClientID %>">Contact No.</label>
                    <asp:TextBox ID="txtContactNo" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtAddress.ClientID %>">Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtEducation.ClientID %>">Education</label>
                    <asp:TextBox ID="txtEducation" runat="server" CssClass="form-control"></asp:TextBox>
                </div>

                <h4 style="color: var(--accent); margin: 20px 0 15px 0;">Previous Company</h4>
                <div class="form-group">
                    <asp:CheckBox ID="chkPreviousCompany" runat="server" Text="Has Previous Company" onclick="togglePreviousCompany();" />
                </div>
                <div id="previousCompanySection" style="display: none;">
                    <div class="form-group">
                        <label for="<%= txtCompanyName.ClientID %>">Company Name</label>
                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtJobIndustry.ClientID %>">Job Industry</label>
                        <asp:TextBox ID="txtJobIndustry" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div style="display: flex; gap: 15px;">
                        <div class="form-group" style="flex: 1;">
                            <label for="<%= txtYears.ClientID %>">Years</label>
                            <asp:TextBox ID="txtYears" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="<%= txtMonths.ClientID %>">Months</label>
                            <asp:TextBox ID="txtMonths" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtPreviousPosition.ClientID %>">Position</label>
                        <asp:TextBox ID="txtPreviousPosition" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>

                <h4 style="color: var(--accent); margin: 20px 0 15px 0;">Guardian Information</h4>
                <div class="form-group">
                    <label for="<%= txtGuardianName.ClientID %>">Guardian Name</label>
                    <asp:TextBox ID="txtGuardianName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtGuardianContactNo.ClientID %>">Contact No.</label>
                    <asp:TextBox ID="txtGuardianContactNo" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtGuardianEmail.ClientID %>">Email Address</label>
                    <asp:TextBox ID="txtGuardianEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtGuardianHomeAddress.ClientID %>">Home Address</label>
                    <asp:TextBox ID="txtGuardianHomeAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>

                <h4 style="color: var(--accent); margin: 20px 0 15px 0;">Application Information</h4>
                <div class="form-group">
                    <label for="<%= ddlAppliedPosition.ClientID %>">Applied Position (Department) *</label>
                    <asp:DropDownList ID="ddlAppliedPosition" runat="server" CssClass="form-control" onchange="updateRoleOptions();">
                        <asp:ListItem Value="">-- Select Department --</asp:ListItem>
                        <asp:ListItem Value="Research & Development">Research & Development</asp:ListItem>
                        <asp:ListItem Value="Quality Control">Quality Control</asp:ListItem>
                        <asp:ListItem Value="Human Resources">Human Resources</asp:ListItem>
                        <asp:ListItem Value="Finance">Finance</asp:ListItem>
                        <asp:ListItem Value="Marketing">Marketing</asp:ListItem>
                        <asp:ListItem Value="IT Support">IT Support</asp:ListItem>
                        <asp:ListItem Value="Operations">Operations</asp:ListItem>
                        <asp:ListItem Value="Sales">Sales</asp:ListItem>
                        <asp:ListItem Value="Legal">Legal</asp:ListItem>
                        <asp:ListItem Value="Customer Service">Customer Service</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label for="ddlRoleClient">Role (Job Title) *</label>
                    <select id="ddlRoleClient" class="form-control" onchange="updateRoleHiddenField();">
                        <option value="">-- Select Department First --</option>
                    </select>
                    <asp:HiddenField ID="hdnSelectedRole" runat="server" />
                </div>
                <div class="form-group">
                    <label for="<%= ddlHowDidYouHearUs.ClientID %>">How did you hear us? *</label>
                    <asp:DropDownList ID="ddlHowDidYouHearUs" runat="server" CssClass="form-control" onchange="toggleReferralName();">
                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                        <asp:ListItem Value="Job Caravan">Job Caravan</asp:ListItem>
                        <asp:ListItem Value="Social Media">Social Media</asp:ListItem>
                        <asp:ListItem Value="Referral">Referral</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div id="referralNameSection" style="display: none;">
                    <div class="form-group">
                        <label for="<%= txtReferralName.ClientID %>">Referral Name</label>
                        <asp:TextBox ID="txtReferralName" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label>Contract Type *</label>
                    <div style="display: flex; gap: 20px; margin-top: 8px;">
                        <label style="display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer;">
                            <asp:RadioButton ID="rbRegular" runat="server" GroupName="ContractType" Checked="true" />
                            <span>Regular</span>
                        </label>
                        <label style="display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer;">
                            <asp:RadioButton ID="rbContractual" runat="server" GroupName="ContractType" />
                            <span>Contractual</span>
                        </label>
                    </div>
                </div>
                <div class="form-group">
                    <label for="<%= ddlHiringType.ClientID %>">Hiring Type *</label>
                    <asp:DropDownList ID="ddlHiringType" runat="server" CssClass="form-control">
                        <asp:ListItem Value="">-- Select Hiring Type --</asp:ListItem>
                        <asp:ListItem Value="Employee" Selected="True">Employee</asp:ListItem>
                        <asp:ListItem Value="Manager">Manager</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-actions" style="margin-top: 30px;">
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClientClick="closeModal(); return false;" />
                    <asp:Button ID="btnAddApplicant" runat="server" Text="Submit" CssClass="btn btn-primary" OnClick="btnAddApplicant_Click" OnClientClick="return validateAddApplicantForm();" />
                </div>
            </div>
        </div>
    </div>

    <!-- View Details Modal -->
    <div id="viewDetailsModal" class="modal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h2 class="modal-title">Applicant Details</h2>
                <span class="close" onclick="closeDetailsModal()">&times;</span>
            </div>
            <div id="applicantDetailsContent" runat="server" style="max-height: 80vh; overflow-y: auto;">
                <!-- Content will be populated by server-side code -->
            </div>
        </div>
    </div>

    <!-- Schedule Interview Modal -->
    <div id="scheduleInterviewModal" class="modal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h2 class="modal-title">Schedule Interview</h2>
                <span class="close" onclick="closeScheduleInterviewModal()">&times;</span>
            </div>
            <div id="scheduleMessageDiv" class="message" runat="server"></div>
            <div style="max-height: 80vh; overflow-y: auto;">
                <div style="margin-bottom: 20px; padding: 15px; background-color: #f5f5f5; border-radius: 6px;">
                    <strong>Selected Applicants:</strong>
                    <ul id="selectedApplicantsList" style="margin: 10px 0 0 20px; padding: 0;"></ul>
                </div>

                <div class="form-group">
                    <label for="<%= txtInterviewDate.ClientID %>">Interview Date *</label>
                    <asp:TextBox ID="txtInterviewDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtInterviewTime.ClientID %>">Interview Time *</label>
                    <asp:TextBox ID="txtInterviewTime" runat="server" CssClass="form-control" TextMode="Time"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtInterviewLocation.ClientID %>">Interview Location *</label>
                    <asp:TextBox ID="txtInterviewLocation" runat="server" CssClass="form-control" placeholder="e.g., Conference Room A, Online, etc."></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtInterviewerName.ClientID %>">Interviewer Name *</label>
                    <asp:TextBox ID="txtInterviewerName" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="<%= txtInterviewNotes.ClientID %>">Interview Notes</label>
                    <asp:TextBox ID="txtInterviewNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Additional notes or instructions for the interview..."></asp:TextBox>
                </div>

                <div class="form-actions" style="margin-top: 24px;">
                    <asp:Button ID="btnCancelSchedule" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClientClick="closeScheduleInterviewModal(); return false;" />
                    <asp:Button ID="btnScheduleInterview" runat="server" Text="Schedule Interview" CssClass="btn btn-primary" OnClick="btnScheduleInterview_Click" OnClientClick="return validateScheduleInterviewForm();" />
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden buttons for postback -->
    <asp:Button ID="btnViewDetails" runat="server" Style="display: none;" OnClick="btnViewDetails_Click" />
    <asp:Button ID="btnHireApplicant" runat="server" Style="display: none;" OnClick="btnHireApplicant_Click" />
    <asp:Button ID="btnNotHireApplicant" runat="server" Style="display: none;" OnClick="btnNotHireApplicant_Click" />
    <asp:HiddenField ID="hdnApplicantId" runat="server" />
    <asp:HiddenField ID="hdnSelectedApplicantIds" runat="server" />
</asp:Content>