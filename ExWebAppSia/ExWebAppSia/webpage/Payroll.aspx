<%@ Page Title="Payroll Management" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" CodeBehind="Payroll.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm6" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Color Palette */
        :root {
    --primary-burgundy: #A36A66;         /* ✅ Main UI color */
    --dark-brown: #5C4F4E;              /* Slightly warmer dark (harmonizes with #A36A66) */
    --light-pink: #C49A99;              /* Lighter tint of primary */
    --medium-burgundy: #8B5A58;         /* Darker active/completed state */
    --rose-pink: #F8ECEB;               /* Very soft warm neutral (replaces pink) */
    --background-pink: #FFB3BA;         /* Keep original bg gradient start (optional) */
}
        /* Reset and Base Styles - Scoped to avoid conflicts with masterpage */
        .payroll-container * {
            box-sizing: border-box;
        }
        .payroll-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px 20px;
            width: 100%;
            box-sizing: border-box;
            background: transparent;
            min-height: calc(100vh - 80px);
        }
        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: all 0.3s;
        }
        .stat-header {
            font-size: 14px;
            color: var(--primary-burgundy);
            font-weight: 600;
            margin-bottom: 15px;
            text-align: center;
        }
        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #1a1a1a;
            text-align: center;
        }
        .stat-label {
            font-size: 13px;
            color: var(--medium-burgundy);
            text-align: center;
            margin-top: 8px;
        }
        /* Tab Navigation */
        .tab-navigation {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
            justify-content: center;
            align-items: center;
        }
        .tab-btn {
            padding: 18px 40px;
            background: white;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 700;
            color: var(--medium-burgundy);
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            white-space: nowrap;
            min-width: 280px;
            text-align: center;
        }
        .tab-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }
        .tab-btn.active {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            color: white;
        }
        /* Main Content Area - Scoped to payroll container only */
        .payroll-container .main-content {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            min-height: 600px;
            margin: 0 auto;
            max-width: 100%;
            box-sizing: border-box;
        }
        /* Stepper Styles */
        .stepper-container {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        .stepper {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
        }
        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
            position: relative;
        }
        .step-circle {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #E5E7EB;
            color: #9CA3AF;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 20px;
            z-index: 2;
            position: relative;
            border: 4px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .step.active .step-circle {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            color: white;
        }
        .step.completed .step-circle {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            color: white;
        }
        .step-label {
            margin-top: 12px;
            font-size: 14px;
            color: #6B7280;
            font-weight: 600;
        }
        .step.active .step-label {
            color: var(--primary-burgundy);
            font-weight: 700;
        }
        .step-line {
            position: absolute;
            top: 30px;
            left: 50%;
            width: 100%;
            height: 4px;
            background: #E5E7EB;
            z-index: 1;
        }
        .step.completed .step-line {
            background: linear-gradient(90deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
        }
        .step:last-child .step-line {
            display: none;
        }
        /* Content Container */
        .step-content {
            display: none;
        }
        .step-content.active {
            display: block;
        }
        .step-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--dark-brown);
            margin-bottom: 30px;
        }
        /* Form Controls */
        .form-group {
            margin-bottom: 25px;
        }
        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--dark-brown);
            margin-bottom: 8px;
        }
        .form-control {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid var(--rose-pink);
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.3s;
            background: white;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--primary-burgundy);
            box-shadow: 0 0 0 4px rgba(164, 79, 86, 0.1);
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        /* Search Bar */
        .search-filter-container {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }
        .search-box {
            flex: 1;
            position: relative;
            min-width: 250px;
        }
        .search-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--primary-burgundy);
            font-size: 18px;
        }
        .search-input {
            width: 100%;
            padding: 14px 18px 14px 50px;
            border: 2px solid var(--rose-pink);
            border-radius: 12px;
            font-size: 15px;
        }
        .search-input:focus {
            outline: none;
            border-color: var(--primary-burgundy);
        }
        .filter-select {
            padding: 14px 18px;
            border: 2px solid var(--rose-pink);
            border-radius: 12px;
            font-size: 15px;
            background: white;
        }
        /* Employee Selection */
        .select-all-container {
            padding: 18px;
            background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
            color: var(--dark-brown);
            cursor: pointer;
        }
        .checkbox {
            width: 22px;
            height: 22px;
            cursor: pointer;
            accent-color: var(--primary-burgundy);
        }
        /* Employee Cards */
        .employee-card {
            border: 2px solid var(--rose-pink);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
            transition: all 0.3s;
            background: white;
        }
        .employee-card:hover {
            box-shadow: 0 4px 12px rgba(164, 79, 86, 0.2);
            transform: translateY(-2px);
        }
        .employee-card.selected {
            border-color: var(--primary-burgundy);
            background: linear-gradient(135deg, #FFF5F5 0%, #FFE4E6 100%);
            border-width: 3px;
        }
        .employee-info {
            display: grid;
            grid-template-columns: 120px 200px 150px 150px 120px;
            gap: 20px;
            flex: 1;
            align-items: center;
        }
        .info-item {
            display: flex;
            flex-direction: column;
        }
        .info-label {
            font-size: 11px;
            color: var(--primary-burgundy);
            text-transform: uppercase;
            margin-bottom: 4px;
            font-weight: 600;
        }
        .info-value {
            font-size: 15px;
            color: var(--dark-brown);
            font-weight: 600;
        }
        .badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }
        .badge-regular {
            background: #D1FAE5;
            color: #065F46;
        }
        .badge-contractual {
            background: #FEE2E2;
            color: #991B1B;
        }
        /* Computation Display */
        .computation-status {
            padding: 18px 24px;
            background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
            border-left: 5px solid var(--primary-burgundy);
            border-radius: 12px;
            margin-bottom: 30px;
            color: var(--dark-brown);
            font-weight: 600;
        }
        .employee-computation {
            border: 2px solid var(--rose-pink);
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 25px;
            background: white;
        }
        .computation-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--rose-pink);
        }
        .employee-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--dark-brown);
        }
        .status-badge {
            padding: 8px 18px;
            background: #D1FAE5;
            color: #065F46;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
        }
        .computation-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
        }
        .computation-section {
            display: flex;
            flex-direction: column;
        }
        .section-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--primary-burgundy);
            margin-bottom: 18px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .computation-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--rose-pink);
        }
        .computation-item:last-child {
            border-bottom: none;
        }
        .item-label {
            color: var(--dark-brown);
            font-size: 14px;
            font-weight: 500;
        }
        .item-value {
            color: var(--dark-brown);
            font-weight: 700;
            font-size: 15px;
        }
        .total-row {
            margin-top: 15px;
            padding-top: 18px;
            border-top: 3px solid var(--primary-burgundy);
        }
        .total-row .item-label {
            font-weight: 700;
            color: var(--dark-brown);
            font-size: 16px;
        }
        .total-row .item-value {
            font-size: 18px;
            color: #22C55E;
        }
        .pending-status {
            background: #FEF3C7;
            border: 2px solid #FCD34D;
            padding: 16px 20px;
            border-radius: 10px;
            margin-top: 15px;
        }
        .pending-status-text {
            color: #92400E;
            font-size: 13px;
            font-weight: 600;
        }
        .net-salary-box {
            background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
            padding: 18px;
            border-radius: 12px;
            margin-top: 15px;
            border: 2px solid var(--primary-burgundy);
        }
        .net-salary-label {
            font-size: 13px;
            color: var(--dark-brown);
            margin-bottom: 6px;
            font-weight: 600;
        }
        .net-salary-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-burgundy);
        }
        .btn-details {
            padding: 8px 16px;
            background: #E5E7EB;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            cursor: pointer;
            margin-top: 10px;
        }
        .computation-details {
            display: none;
            margin-top: 15px;
            padding: 15px;
            background: #fafafa;
            border-radius: 8px;
            font-size: 14px;
            line-height: 1.5;
        }
        /* Review Table */
        .review-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
            border-radius: 12px;
            overflow: hidden;
        }
        .review-table thead {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
        }
        .review-table th {
            padding: 18px;
            text-align: left;
            font-size: 13px;
            font-weight: 700;
            color: white;
            text-transform: uppercase;
        }
        .review-table td {
            padding: 20px 18px;
            border-bottom: 1px solid var(--rose-pink);
            font-size: 15px;
            color: var(--dark-brown);
        }
        .review-table tbody tr:hover {
            background: linear-gradient(135deg, #FFF5F5 0%, #FFE4E6 100%);
        }
        .amount-green {
            color: #22C55E;
            font-weight: 700;
        }
        .amount-blue {
            color: var(--primary-burgundy);
            font-weight: 700;
        }
        .amount-gray {
            color: #9CA3AF;
        }
        .edit-icon {
            color: var(--primary-burgundy);
            cursor: pointer;
            font-size: 20px;
        }
        .editable-cell input {
            display: none;
            width: 120px;
            font-weight: bold;
            border: 1px solid #ccc;
            padding: 4px 8px;
            border-radius: 4px;
        }
        .remarks-cell {
            color: #888;
            font-style: italic;
            cursor: text;
        }
        .total-row-table {
            font-weight: 700;
            font-size: 16px;
            background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
        }
        /* Success Message */
        .success-container {
            text-align: center;
            padding: 60px 40px;
        }
        .success-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            box-shadow: 0 8px 20px rgba(164, 79, 86, 0.3);
        }
        .checkmark {
            width: 60px;
            height: 60px;
            border: 5px solid var(--primary-burgundy);
            border-radius: 50%;
            position: relative;
        }
        .checkmark::after {
            content: '';
            position: absolute;
            left: 16px;
            top: 8px;
            width: 15px;
            height: 25px;
            border: solid var(--primary-burgundy);
            border-width: 0 5px 5px 0;
            transform: rotate(45deg);
        }
        .success-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--primary-burgundy);
            margin-bottom: 12px;
        }
        .success-message {
            color: var(--dark-brown);
            font-size: 16px;
            margin-bottom: 40px;
        }
        .email-notification {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px;
            background: #F0FDF4;
            border: 2px solid #BBF7D0;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .email-info {
            display: flex;
            align-items: center;
            gap: 18px;
        }
        .file-details {
            display: flex;
            flex-direction: column;
        }
        .file-name {
            font-weight: 700;
            color: var(--dark-brown);
            margin-bottom: 4px;
            font-size: 16px;
        }
        .file-description {
            font-size: 13px;
            color: var(--medium-burgundy);
        }
        .email-icon {
            width: 50px;
            height: 50px;
            background: #22C55E;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
        }
        .sent-badge {
            padding: 8px 16px;
            background: #D1FAE5;
            color: #065F46;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
        }
        .status-info-box {
            background: #FEF3C7;
            border: 2px solid #FCD34D;
            padding: 22px;
            border-radius: 12px;
            margin-bottom: 30px;
        }
        .status-info-title span {
            background: linear-gradient(90deg, #3B82F6, #8B5CF6);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }
        .status-info-text {
            color: #92400E;
            font-size: 14px;
            margin-top: 8px;
        }
        /* Buttons */
        .button-container {
            display: flex;
            gap: 15px;
            margin-top: 35px;
            flex-wrap: wrap;
        }
        .btn {
            padding: 16px 36px;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            color: white;
            flex: 1;
            min-width: 200px;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(164, 79, 86, 0.4);
        }
        .btn-success {
            background: linear-gradient(135deg, #22C55E 0%, #16A34A 100%);
            color: white;
            flex: 1;
            min-width: 200px;
        }
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(34, 197, 94, 0.4);
        }
        .btn-secondary {
            background: white;
            color: var(--medium-burgundy);
            border: 2px solid var(--rose-pink);
            min-width: 200px;
        }
        .btn-secondary:hover {
            background: var(--light-pink);
            border-color: var(--primary-burgundy);
        }
        .btn-icon {
            font-size: 18px;
        }
        /* Tab Content */
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        /* Modals */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: white;
            width: 800px;
            max-width: 95%;
            border-radius: 16px;
            padding: 30px;
            position: relative;
        }
        .close-modal {
            position: absolute;
            top: 15px;
            right: 15px;
            font-size: 28px;
            cursor: pointer;
            background: none;
            border: none;
        }
        /* History Table */
        .history-table {
            width: 100%;
            border-collapse: collapse;
        }
        .history-table th,
        .history-table td {
            padding: 16px;
            border-bottom: 1px solid var(--rose-pink);
        }
        .history-table thead th {
            background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            color: white;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 12px;
        }
        .btn-icon-sm {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #F3F4F6;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            color: var(--medium-burgundy);
        }
        .btn-icon-sm:hover {
            background: #E5E7EB;
        }
        @media (max-width: 1200px) {
            .payroll-container {
                padding: 20px;
            }
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 768px) {
            .payroll-container {
                padding: 15px;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .tab-navigation {
                flex-direction: column;
            }
            .form-row {
                grid-template-columns: 1fr;
            }
            .computation-grid {
                grid-template-columns: 1fr;
            }
            .employee-info {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            .stepper {
                flex-wrap: wrap;
            }
            .button-container {
                flex-direction: column;
            }
            .btn {
                min-width: auto;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="payroll-container">
        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">Current Period</div>
                <div class="stat-value" id="statPeriod">Jan 1–15, 2025</div>
                <div class="stat-label"></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">Employees</div>
                <div class="stat-value" id="statEmployees">2 Employees</div>
                <div class="stat-label"></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">Total Gross</div>
                <div class="stat-value" id="statGross">₱66,000.00</div>
                <div class="stat-label"></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">Status</div>
                <div class="stat-value" id="statStatus">Draft</div>
                <div class="stat-label"></div>
            </div>
        </div>
        <!-- Tab Navigation -->
        <div class="tab-navigation">
            <button type="button" class="tab-btn active" data-tab="payroll-gen" onclick="switchTab('payroll-gen'); return false;">Payroll Generation</button>
            <button type="button" class="tab-btn" data-tab="payslips" onclick="switchTab('payslips'); return false;">Payslips</button>
            <button type="button" class="tab-btn" data-tab="history" onclick="switchTab('history'); return false;">History</button>
        </div>
        <!-- Payroll Generation Tab -->
        <div id="payroll-gen" class="tab-content active">
            <div class="stepper-container">
                <div class="stepper">
                    <div class="step active" id="step1Indicator">
                        <div class="step-circle">1</div>
                        <div class="step-label">Period</div>
                        <div class="step-line"></div>
                    </div>
                    <div class="step" id="step2Indicator">
                        <div class="step-circle">2</div>
                        <div class="step-label">Employee</div>
                        <div class="step-line"></div>
                    </div>
                    <div class="step" id="step3Indicator">
                        <div class="step-circle">3</div>
                        <div class="step-label">Compute</div>
                        <div class="step-line"></div>
                    </div>
                    <div class="step" id="step4Indicator">
                        <div class="step-circle">4</div>
                        <div class="step-label">Review</div>
                        <div class="step-line"></div>
                    </div>
                    <div class="step" id="step5Indicator">
                        <div class="step-circle">5</div>
                        <div class="step-label">Sent to Finance</div>
                    </div>
                </div>
            </div>
            <div class="main-content">
                <!-- Step 1: Period -->
                <div class="step-content active" id="step1">
                    <h2 class="step-title">Step 1: Payroll Period Setup</h2>
                    <div class="form-group">
                        <label class="form-label">Payroll Type</label>
                        <asp:DropDownList ID="ddlPayrollType" runat="server" CssClass="form-control" onchange="updateDates(this.value)">
                            <asp:ListItem Value="semi-monthly" Selected="True">Semi-Monthly</asp:ListItem>
                            <asp:ListItem Value="monthly">Monthly</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Start Date</label>
                            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control" Text="2025-01-01"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">End Date</label>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control" Text="2025-01-15"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Cut-off Date</label>
                        <asp:TextBox ID="txtCutoffDate" runat="server" TextMode="Date" CssClass="form-control" Text="2025-01-15"></asp:TextBox>
                    </div>
                    <div class="button-container">
                        <button type="button" class="btn btn-primary" onclick="nextStep(2)">
                            Next: Select Employees
                            <span class="btn-icon">→</span>
                        </button>
                    </div>
                </div>
                <!-- Step 2: Employee Selection -->
                <div class="step-content" id="step2">
                    <h2 class="step-title">Step 2: Employee Selection</h2>
                    <div class="search-filter-container">
                        <div class="search-box">
                            <span class="search-icon">🔍</span>
                            <input type="text" class="search-input" placeholder="Search employees..." id="searchEmployees">
                        </div>
                        <select id="filterDept" class="filter-select">
                            <option value="">All Departments</option>
                            <option value="IT">IT</option>
                            <option value="HR">HR</option>
                            <option value="Finance">Finance</option>
                        </select>
                        <select id="filterRole" class="filter-select">
                            <option value="">All Roles</option>
                            <option value="Developer">Developer</option>
                            <option value="HR Manager">HR Manager</option>
                            <option value="Accountant">Accountant</option>
                        </select>
                    </div>
                    <div class="select-all-container">
                        <label class="checkbox-label">
                            <input type="checkbox" class="checkbox" id="selectAll" checked onchange="toggleSelectAll()">
                            Select All (<span id="employeeCount">3</span> employees)
                        </label>
                    </div>
                    <div id="employeeList">
                        <div class="employee-card selected">
                            <input type="checkbox" class="checkbox employee-checkbox" checked data-emp="EMP001">
                            <div class="employee-info">
                                <div class="info-item"><span class="info-label">Emp Number</span><span class="info-value">EMP001</span></div>
                                <div class="info-item"><span class="info-label">Name</span><span class="info-value">Juan Dela Cruz</span></div>
                                <div class="info-item"><span class="info-label">Department</span><span class="info-value">IT</span></div>
                                <div class="info-item"><span class="info-label">Role</span><span class="info-value">Developer</span></div>
                                <div class="info-item"><span class="info-label">Type</span><span class="badge badge-regular">Regular</span></div>
                            </div>
                        </div>
                        <div class="employee-card selected">
                            <input type="checkbox" class="checkbox employee-checkbox" checked data-emp="EMP002">
                            <div class="employee-info">
                                <div class="info-item"><span class="info-label">Emp Number</span><span class="info-value">EMP002</span></div>
                                <div class="info-item"><span class="info-label">Name</span><span class="info-value">Maria Santos</span></div>
                                <div class="info-item"><span class="info-label">Department</span><span class="info-value">HR</span></div>
                                <div class="info-item"><span class="info-label">Role</span><span class="info-value">HR Manager</span></div>
                                <div class="info-item"><span class="info-label">Type</span><span class="badge badge-regular">Regular</span></div>
                            </div>
                        </div>
                        <div class="employee-card">
                            <input type="checkbox" class="checkbox employee-checkbox" data-emp="EMP003">
                            <div class="employee-info">
                                <div class="info-item"><span class="info-label">Emp Number</span><span class="info-value">EMP003</span></div>
                                <div class="info-item"><span class="info-label">Name</span><span class="info-value">Pedro Reyes</span></div>
                                <div class="info-item"><span class="info-label">Department</span><span class="info-value">Finance</span></div>
                                <div class="info-item"><span class="info-label">Role</span><span class="info-value">Accountant</span></div>
                                <div class="info-item"><span class="info-label">Type</span><span class="badge badge-contractual">Contractual</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="button-container">
                        <button type="button" class="btn btn-secondary" onclick="prevStep(1)">Back</button>
                        <button type="button" class="btn btn-primary" onclick="nextStep(3)">
                            Generate Payroll
                            <span class="btn-icon">→</span>
                        </button>
                    </div>
                </div>
                <!-- Step 3: Computation -->
                <div class="step-content" id="step3">
                    <h2 class="step-title">Step 3: Automatic Salary Computation</h2>
                    <div class="computation-status">
                        ✅ Computed for <span id="computedCount">2</span> employees. Earnings calculated; deductions to be added by Finance.
                    </div>
                    <div class="employee-computation">
                        <div class="computation-header">
                            <h3 class="employee-name">EMP001 - Juan Dela Cruz</h3>
                            <span class="status-badge">Computed</span>
                        </div>
                        <div class="computation-grid">
                            <div class="computation-section">
                                <h4 class="section-title">Earnings</h4>
                                <div class="computation-item"><span class="item-label">Basic Salary</span><span class="item-value">₱25,000.00</span></div>
                                <div class="computation-item"><span class="item-label">Days Worked (10/12)</span><span class="item-value">₱20,833.33</span></div>
                                <div class="computation-item"><span class="item-label">Overtime (2 hrs)</span><span class="item-value">₱500.00</span></div>
                                <div class="computation-item"><span class="item-label">Holiday Pay (1 day)</span><span class="item-value">₱2,083.33</span></div>
                                <div class="computation-item"><span class="item-label">Night Diff (5 hrs)</span><span class="item-value">₱250.00</span></div>
                                <div class="computation-item"><span class="item-label">Transport Allowance</span><span class="item-value">₱1,000.00</span></div>
                                <div class="computation-item"><span class="item-label">Meal Allowance</span><span class="item-value">₱1,000.00</span></div>
                                <div class="computation-item"><span class="item-label">Performance Bonus</span><span class="item-value">₱2,000.00</span></div>
                                <div class="computation-item total-row">
                                    <span class="item-label">TOTAL GROSS SALARY</span>
                                    <span class="item-value">₱52,666.66</span>
                                </div>
                            </div>
                            <div class="computation-section">
                                <h4 class="section-title">Deductions</h4>
                                <div class="computation-item">
                                    <span class="item-label">To be filled by Finance</span>
                                    <span class="item-value">₱0.00</span>
                                </div>
                                <div class="net-salary-box">
                                    <div class="net-salary-label">NET SALARY (Tentative)</div>
                                    <div class="net-salary-value">₱52,666.66</div>
                                </div>
                                <div class="pending-status">
                                    <div class="pending-status-text">Status: Pending Finance Review</div>
                                </div>
                                <button type="button" class="btn-details" onclick="toggleDetails(this)">📋 View Full Computation Details</button>
                                <div class="computation-details">
                                    <strong>Earnings Breakdown:</strong><br>
                                    • Basic Salary (₱30,000/mo × 10/12 days) = ₱25,000.00<br>
                                    • Overtime: 2 hrs × ₱250/hr = ₱500.00<br>
                                    • Holiday Pay: 1 regular holiday × ₱2,083.33 = ₱2,083.33<br>
                                    • Night Differential: 5 hrs × ₱50/hr = ₱250.00<br>
                                    • Allowances: ₱2,000.00<br>
                                    • Bonus: ₱2,000.00<br>
                                    <strong>→ Gross: ₱52,666.66</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="employee-computation">
                        <div class="computation-header">
                            <h3 class="employee-name">EMP002 - Maria Santos</h3>
                            <span class="status-badge">Computed</span>
                        </div>
                        <div class="computation-grid">
                            <div class="computation-section">
                                <h4 class="section-title">Earnings</h4>
                                <div class="computation-item"><span class="item-label">Basic Salary</span><span class="item-value">₱28,500.00</span></div>
                                <div class="computation-item"><span class="item-label">Days Worked (10/12)</span><span class="item-value">₱23,750.00</span></div>
                                <div class="computation-item"><span class="item-label">Allowances</span><span class="item-value">₱2,500.00</span></div>
                                <div class="computation-item"><span class="item-label">13th Month (advance)</span><span class="item-value">₱1,250.00</span></div>
                                <div class="computation-item total-row">
                                    <span class="item-label">TOTAL GROSS SALARY</span>
                                    <span class="item-value">₱56,000.00</span>
                                </div>
                            </div>
                            <div class="computation-section">
                                <h4 class="section-title">Deductions</h4>
                                <div class="computation-item">
                                    <span class="item-label">To be filled by Finance</span>
                                    <span class="item-value">₱0.00</span>
                                </div>
                                <div class="net-salary-box">
                                    <div class="net-salary-label">NET SALARY (Tentative)</div>
                                    <div class="net-salary-value">₱56,000.00</div>
                                </div>
                                <div class="pending-status">
                                    <div class="pending-status-text">Status: Pending Finance Review</div>
                                </div>
                                <button type="button" class="btn-details" onclick="toggleDetails(this)">📋 View Full Computation Details</button>
                                <div class="computation-details">
                                    <strong>Earnings Breakdown:</strong><br>
                                    • Basic: ₱28,500.00<br>
                                    • Prorated Days: ₱23,750.00<br>
                                    • Allowances: ₱2,500.00<br>
                                    • 13th Month (Jan advance): ₱1,250.00<br>
                                    <strong>→ Gross: ₱56,000.00</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="button-container">
                        <button type="button" class="btn btn-secondary" onclick="prevStep(2)">Back</button>
                        <button type="button" class="btn btn-primary" onclick="nextStep(4)">
                            Review Payroll
                            <span class="btn-icon">→</span>
                        </button>
                    </div>
                </div>
                <!-- Step 4: Review -->
                <div class="step-content" id="step4">
                    <h2 class="step-title">Step 4: Review and Finalize</h2>
                    <table class="review-table">
                        <thead>
                            <tr>
                                <th>Emp No.</th>
                                <th>Name</th>
                                <th>Dept</th>
                                <th>Days</th>
                                <th>Gross</th>
                                <th>Deductions</th>
                                <th>Net</th>
                                <th>Remarks</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>EMP001</td>
                                <td>Juan Dela Cruz</td>
                                <td>IT</td>
                                <td>10</td>
                                <td class="amount-green editable-cell" data-value="52666.66">
                                    ₱52,666.66
                                    <input type="number" step="0.01" value="52666.66" onchange="updateGross(this)" />
                                </td>
                                <td class="amount-gray">₱0.00</td>
                                <td class="amount-blue">₱52,666.66</td>
                                <td class="remarks-cell" contenteditable="true">(Optional)</td>
                                <td><span class="edit-icon">✎</span></td>
                            </tr>
                            <tr>
                                <td>EMP002</td>
                                <td>Maria Santos</td>
                                <td>HR</td>
                                <td>10</td>
                                <td class="amount-green editable-cell" data-value="56000.00">
                                    ₱56,000.00
                                    <input type="number" step="0.01" value="56000.00" onchange="updateGross(this)" />
                                </td>
                                <td class="amount-gray">₱0.00</td>
                                <td class="amount-blue">₱56,000.00</td>
                                <td class="remarks-cell" contenteditable="true">(Optional)</td>
                                <td><span class="edit-icon">✎</span></td>
                            </tr>
                            <tr class="total-row-table">
                                <td colspan="4">TOTAL:</td>
                                <td class="amount-green" id="totalGross">₱108,666.66</td>
                                <td class="amount-gray">₱0.00</td>
                                <td class="amount-blue" id="totalNet">₱108,666.66</td>
                                <td></td>
                                <td></td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="button-container">
                        <button type="button" class="btn btn-secondary" onclick="prevStep(3)">Back</button>
                        <button type="button" class="btn btn-success" onclick="nextStep(5)">
                            <span class="btn-icon">✉️</span>
                            Send to Finance
                        </button>
                    </div>
                </div>
                <!-- Step 5: Sent -->
                <div class="step-content" id="step5">
                    <h2 class="step-title">Step 5: Sent to Finance</h2>
                    <div class="success-container">
                        <div class="success-icon">
                            <div class="checkmark"></div>
                        </div>
                        <h3 class="success-title">Payroll Sent Successfully!</h3>
                        <p class="success-message">The payroll has been exported and sent to the Finance team for deduction processing.</p>
                    </div>
                    <div class="email-notification">
                        <div class="email-info">
                            <div class="email-icon">✉️</div>
                            <div class="file-details">
                                <div class="file-name">Email Notification Sent</div>
                                <div class="file-description">Finance team has been notified</div>
                            </div>
                        </div>
                        <span class="sent-badge">Sent</span>
                    </div>
                    <div class="status-info-box">
                        <div class="status-info-title">
                            <span>📤 Sent to Finance – Awaiting Deductions</span>
                        </div>
                        <div class="status-info-text">
                            The Finance team will now add statutory deductions (SSS, PhilHealth, etc.) and compute final net pay.
                        </div>
                    </div>
                    <div class="button-container">
                        <button type="button" class="btn btn-secondary" onclick="prevStep(4)">Back</button>
                        <button type="button" class="btn btn-primary" onclick="window.location.href='Dashboard.aspx'">
                            Back to Dashboard
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Payslips Tab -->
        <div id="payslips" class="tab-content">
            <div class="main-content">
                <h2 class="step-title">Payslips Generation</h2>
                <div class="computation-status" style="background: linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%); border-left-color: #3B82F6;">
                    ✅ Payroll Approved by Finance — Ready to Generate & Distribute Payslips
                </div>
                <table class="review-table">
                    <thead>
                        <tr>
                            <th>Emp No.</th>
                            <th>Name</th>
                            <th>Gross</th>
                            <th>Deductions</th>
                            <th>Net</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>EMP001</td>
                            <td>Juan Dela Cruz</td>
                            <td class="amount-green">₱52,666.66</td>
                            <td>
                                <span class="badge badge-contractual" style="background:#FEF3C7;color:#92400E;cursor:pointer;" onclick="toggleDeductions('EMP001')">ⓘ ₱5,200.00</span>
                            </td>
                            <td class="amount-blue">₱47,466.66</td>
                            <td><span class="status-badge" style="background:#D1FAE5;color:#065F46;">Approved</span></td>
                            <td><button type="button" class="btn-icon-sm" title="Preview" onclick="openPayslipModal('Juan Dela Cruz', 'Jan 1–15, 2025', '52666.66', '5200', '47466.66')">👁️</button></td>
                        </tr>
                        <tr>
                            <td>EMP002</td>
                            <td>Maria Santos</td>
                            <td class="amount-green">₱56,000.00</td>
                            <td>
                                <span class="badge badge-contractual" style="background:#FEF3C7;color:#92400E;cursor:pointer;" onclick="toggleDeductions('EMP002')">ⓘ ₱5,800.00</span>
                            </td>
                            <td class="amount-blue">₱50,200.00</td>
                            <td><span class="status-badge" style="background:#D1FAE5;color:#065F46;">Approved</span></td>
                            <td><button type="button" class="btn-icon-sm" title="Preview" onclick="openPayslipModal('Maria Santos', 'Jan 1–15, 2025', '56000', '5800', '50200')">👁️</button></td>
                        </tr>
                    </tbody>
                </table>
                <div id="deductions-detail-EMP001" style="display:none; margin:20px 0; padding:15px; background:#f8fafc; border-radius:8px;">
                    <strong>Deductions Breakdown:</strong><br>
                    • SSS: ₱1,960.00<br>• PhilHealth: ₱900.00<br>• Pag-IBIG: ₱100.00<br>• Withholding Tax: ₱2,000.00<br>• Company Loan: ₱240.00<br>
                    <strong>→ Total: ₱5,200.00</strong>
                </div>
                <div id="deductions-detail-EMP002" style="display:none; margin:20px 0; padding:15px; background:#f8fafc; border-radius:8px;">
                    <strong>Deductions Breakdown:</strong><br>
                    • SSS: ₱2,120.00<br>• PhilHealth: ₱1,050.00<br>• Pag-IBIG: ₱100.00<br>• Withholding Tax: ₱2,300.00<br>• SSS Loan: ₱230.00<br>
                    <strong>→ Total: ₱5,800.00</strong>
                </div>
                <div class="button-container">
                    <button type="button" class="btn btn-secondary" onclick="switchTab('payroll-gen'); return false;">← Back</button>
                    <button type="button" class="btn btn-success" onclick="openSummaryModal(); return false;">
                        📊 Summarize Computation (Date Range)
                    </button>
                    <button type="button" class="btn btn-primary">
                        📤 Generate & Email Payslips
                    </button>
                </div>
            </div>
        </div>
        <!-- History Tab -->
        <div id="history" class="tab-content">
            <div class="main-content">
                <h2 class="step-title">Payroll History</h2>
                <div class="search-filter-container">
                    <div class="search-box">
                        <span class="search-icon">🔍</span>
                        <input type="text" class="search-input" placeholder="Search payroll period...">
                    </div>
                    <select class="filter-select">
                        <option>All Status</option>
                        <option>Completed</option>
                        <option>Cancelled</option>
                    </select>
                    <input type="date" class="filter-select" placeholder="Start">
                    <input type="date" class="filter-select" placeholder="End">
                </div>
                <table class="history-table">
                    <thead>
                        <tr>
                            <th>Period</th>
                            <th>Employees</th>
                            <th>Gross</th>
                            <th>Deductions</th>
                            <th>Net</th>
                            <th>Date</th>
                            <th>By</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Jan 1–15, 2025</td>
                            <td>2</td>
                            <td class="amount-green">₱108,666.66</td>
                            <td class="amount-gray">₱11,000.00</td>
                            <td class="amount-blue">₱97,666.66</td>
                            <td>Jan 16, 2025</td>
                            <td>Steven A.</td>
                            <td><span class="status-badge" style="background:#D1FAE5;color:#065F46;">Completed</span></td>
                            <td>
                                <button type="button" class="btn-icon-sm" title="View">👁️</button>
                                <button type="button" class="btn-icon-sm" title="Download">⬇️</button>
                            </td>
                        </tr>
                        <tr>
                            <td>Dec 16–31, 2024</td>
                            <td>3</td>
                            <td class="amount-green">₱154,000.00</td>
                            <td class="amount-gray">₱15,200.00</td>
                            <td class="amount-blue">₱138,800.00</td>
                            <td>Dec 31, 2024</td>
                            <td>Steven A.</td>
                            <td><span class="status-badge" style="background:#FEE2E2;color:#991B1B;">Cancelled</span></td>
                            <td>
                                <button type="button" class="btn-icon-sm" title="View">👁️</button>
                                <button type="button" class="btn-icon-sm" title="Download">⬇️</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <div style="text-align:center; margin-top:20px; color:#666;">
                    Showing 1–2 of 12 entries | <a href="#" style="color:var(--primary-burgundy);">Next →</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Modals -->
    <div id="payslipModal" class="modal">
        <div class="modal-content">
            <button type="button" class="close-modal" onclick="closeModal()">&times;</button>
            <h3 style="text-align:center; color:var(--dark-brown);">PAYSLIP</h3>
            <div style="text-align:center; margin-bottom:20px; color:#666;" id="payslipPeriod">Jan 1–15, 2025</div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px;" id="payslipEmpInfo">
                <div><strong>Employee:</strong> Juan Dela Cruz</div>
                <div><strong>Emp No.:</strong> EMP001</div>
                <div><strong>Department:</strong> IT</div>
                <div><strong>Position:</strong> Developer</div>
            </div>
            <table style="width:100%; border-collapse:collapse; margin-bottom:20px;">
                <thead>
                    <tr style="background:var(--light-pink);">
                        <th style="padding:10px; text-align:left;">Earnings</th>
                        <th style="padding:10px;">Amount</th>
                        <th style="padding:10px; text-align:left;">Deductions</th>
                        <th style="padding:10px;">Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <tr><td>Basic Salary</td><td>₱50,000.00</td><td>SSS</td><td>₱1,960.00</td></tr>
                    <tr><td>Allowances</td><td>₱2,666.66</td><td>PhilHealth</td><td>₱900.00</td></tr>
                    <tr><td>Overtime</td><td>₱500.00</td><td>Pag-IBIG</td><td>₱100.00</td></tr>
                    <tr><td>Bonus</td><td>₱2,000.00</td><td>Tax</td><td>₱2,000.00</td></tr>
                    <tr><td></td><td></td><td>Loan</td><td>₱240.00</td></tr>
                    <tr style="border-top:2px solid var(--primary-burgundy);">
                        <td><strong>Total</strong></td>
                        <td><strong id="modalGross">₱55,166.66</strong></td>
                        <td><strong>Total</strong></td>
                        <td><strong id="modalDeductions">₱5,200.00</strong></td>
                    </tr>
                </tbody>
            </table>
            <div style="text-align:center; font-size:20px; font-weight:bold; color:var(--primary-burgundy);" id="modalNet">
                NET SALARY: ₱50,000.00
            </div>
            <div style="margin-top:30px; text-align:center; font-size:13px; color:#888;">
                Authorized by: HR Manager & Finance Officer | Company Stamp
            </div>
        </div>
    </div>

    <div id="summaryModal" class="modal">
        <div class="modal-content">
            <button type="button" class="close-modal" onclick="closeModal()">&times;</button>
            <h4>📊 Summarize Salary Computation</h4>
            <div style="margin-top:20px;">
                <div class="form-group">
                    <label class="form-label">From</label>
                    <input type="date" class="form-control" value="2025-01-01" />
                </div>
                <div class="form-group">
                    <label class="form-label">To</label>
                    <input type="date" class="form-control" value="2025-01-31" />
                </div>
                <div class="button-container">
                    <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="alert('✅ Summary for selected range generated (mock).')">Show Summary</button>
                </div>
            </div>
        </div>
    </div>

<script>
    // Tab & Step Navigation - FIXED VERSION
    function switchTab(tabName) {
        // Remove active class from all tabs and buttons
        document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));

        // Add active class to selected tab
        const targetTab = document.getElementById(tabName);
        if (targetTab) {
            targetTab.classList.add('active');
        }

        // Find and activate the clicked button by data-tab attribute
        const activeButton = document.querySelector('.tab-btn[data-tab="' + tabName + '"]');
        if (activeButton) {
            activeButton.classList.add('active');
        }

        // Scroll to top smoothly
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
        // Return false to prevent any form submission
        return false;
    }

    function nextStep(stepNumber) {
        document.querySelectorAll('.step-content').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.step').forEach(el => { el.classList.remove('active'); el.classList.remove('completed'); });
        document.getElementById('step' + stepNumber).classList.add('active');
        for (let i = 1; i < stepNumber; i++) document.getElementById('step' + i + 'Indicator').classList.add('completed');
        document.getElementById('step' + stepNumber + 'Indicator').classList.add('active');
        window.scrollTo({ top: 0, behavior: 'smooth' });
        updateDashboard();
    }

    function prevStep(stepNumber) { nextStep(stepNumber); }

    // Select All & Employee Selection
    function toggleSelectAll() {
        const checked = document.getElementById('selectAll').checked;
        const checkboxes = document.querySelectorAll('.employee-checkbox');
        const cards = document.querySelectorAll('.employee-card');
        checkboxes.forEach((cb, i) => {
            cb.checked = checked;
            cards[i].classList.toggle('selected', checked);
        });
        updateDashboard();
    }

    // Search & Filter
    function applyFilters() {
        const searchTerm = document.getElementById('searchEmployees')?.value.toLowerCase() || '';
        const dept = document.getElementById('filterDept')?.value || '';
        const role = document.getElementById('filterRole')?.value || '';
        const cards = document.querySelectorAll('.employee-card');
        cards.forEach(card => {
            const name = card.querySelectorAll('.info-value')[1]?.textContent.toLowerCase() || '';
            const cardDept = card.querySelectorAll('.info-value')[2]?.textContent || '';
            const cardRole = card.querySelectorAll('.info-value')[3]?.textContent || '';
            const match = name.includes(searchTerm) &&
                (!dept || cardDept === dept) &&
                (!role || cardRole === role);
            card.style.display = match ? 'flex' : 'none';
        });
    }

    // Computation Details Toggle
    function toggleDetails(btn) {
        const details = btn.nextElementSibling;
        if (details.style.display === 'none' || details.style.display === '') {
            details.style.display = 'block';
            btn.textContent = '▲ Hide Details';
        } else {
            details.style.display = 'none';
            btn.textContent = '📋 View Full Computation Details';
        }
    }

    // Deductions Toggle (Payslips)
    function toggleDeductions(empId) {
        const el = document.getElementById('deductions-detail-' + empId);
        if (el) el.style.display = el.style.display === 'none' ? 'block' : 'none';
    }

    // Editable Gross Cells
    function updateGross(input) {
        const cell = input.parentElement;
        const val = parseFloat(input.value) || 0;
        const formatted = '₱' + val.toLocaleString('en-PH', { minimumFractionDigits: 2 });
        cell.textContent = formatted;
        cell.setAttribute('data-value', val);
        cell.classList.add('edited');

        // Re-add the input element
        const newInput = document.createElement('input');
        newInput.type = 'number';
        newInput.step = '0.01';
        newInput.value = val;
        newInput.style.display = 'none';
        newInput.onchange = function () { updateGross(this); };
        cell.appendChild(newInput);

        recalculateTotals();
    }

    function recalculateTotals() {
        let total = 0;
        document.querySelectorAll('.editable-cell[data-value]').forEach(cell => {
            total += parseFloat(cell.getAttribute('data-value')) || 0;
        });
        const totalGrossEl = document.getElementById('totalGross');
        const totalNetEl = document.getElementById('totalNet');
        if (totalGrossEl) totalGrossEl.textContent = '₱' + total.toLocaleString('en-PH', { minimumFractionDigits: 2 });
        if (totalNetEl) totalNetEl.textContent = '₱' + total.toLocaleString('en-PH', { minimumFractionDigits: 2 });
    }

    // Modals
    function openPayslipModal(name, period, gross, deductions, net) {
        document.getElementById('payslipEmpInfo').querySelectorAll('div')[0].innerHTML = '<strong>Employee:</strong> ' + name;
        document.getElementById('payslipPeriod').textContent = period;
        document.getElementById('modalGross').textContent = '₱' + parseFloat(gross).toLocaleString('en-PH', { minimumFractionDigits: 2 });
        document.getElementById('modalDeductions').textContent = '₱' + parseFloat(deductions).toLocaleString('en-PH', { minimumFractionDigits: 2 });
        document.getElementById('modalNet').textContent = 'NET SALARY: ₱' + parseFloat(net).toLocaleString('en-PH', { minimumFractionDigits: 2 });
        document.getElementById('payslipModal').style.display = 'flex';
    }

    function openSummaryModal() {
        document.getElementById('summaryModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('payslipModal').style.display = 'none';
        document.getElementById('summaryModal').style.display = 'none';
    }

    // Auto-update dashboard
    function updateDashboard() {
        const selected = document.querySelectorAll('.employee-card.selected').length;
        const grossEl = document.getElementById('totalGross');
        const gross = grossEl ? grossEl.textContent : '₱0.00';

        const startDateEl = document.getElementById('<%= txtStartDate.ClientID %>');
        const endDateEl = document.getElementById('<%= txtEndDate.ClientID %>');
        const startDate = startDateEl ? startDateEl.value : '2025-01-01';
        const endDate = endDateEl ? endDateEl.value : '2025-01-15';

        const period = startDate + ' → ' + endDate;
        const statusStep = document.querySelector('.step.active .step-label')?.textContent;

        const statEmployeesEl = document.getElementById('statEmployees');
        const statGrossEl = document.getElementById('statGross');
        const statPeriodEl = document.getElementById('statPeriod');
        const computedCountEl = document.getElementById('computedCount');
        const statStatusEl = document.getElementById('statStatus');

        if (statEmployeesEl) statEmployeesEl.textContent = selected + ' Employees';
        if (statGrossEl) statGrossEl.textContent = gross;
        if (statPeriodEl) statPeriodEl.textContent = period.replace(/-/g, '/').replace(' → ', '–');
        if (computedCountEl) computedCountEl.textContent = selected;

        let status = 'Draft';
        if (statusStep === 'Sent to Finance') status = 'Sent to Finance';
        if (statusStep === 'Review') status = 'Ready for Review';
        if (statStatusEl) statStatusEl.textContent = status;
    }

    // Auto-set dates by payroll type
    function updateDates(type) {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        let start, end, cutoff;
        if (type === 'semi-monthly') {
            start = year + '-' + month + '-01';
            end = year + '-' + month + '-15';
            cutoff = year + '-' + month + '-15';
        } else { // monthly
            const lastDay = new Date(year, today.getMonth() + 1, 0).getDate();
            start = year + '-' + month + '-01';
            end = year + '-' + month + '-' + String(lastDay).padStart(2, '0');
            cutoff = year + '-' + month + '-' + String(lastDay).padStart(2, '0');
        }

        const startDateEl = document.getElementById('<%= txtStartDate.ClientID %>');
        const endDateEl = document.getElementById('<%= txtEndDate.ClientID %>');
        const cutoffDateEl = document.getElementById('<%= txtCutoffDate.ClientID %>');

        if (startDateEl) startDateEl.value = start;
        if (endDateEl) endDateEl.value = end;
        if (cutoffDateEl) cutoffDateEl.value = cutoff;

        updateDashboard();
    }

    // Initialize
    document.addEventListener('DOMContentLoaded', function () {
        // Tab button event listeners - More reliable than inline onclick
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const tabName = this.getAttribute('data-tab');
                if (tabName) {
                    switchTab(tabName);
                }
                return false;
            });
        });

        // Employee checkbox handlers
        const checkboxes = document.querySelectorAll('.employee-checkbox');
        const cards = document.querySelectorAll('.employee-card');
        checkboxes.forEach((cb, i) => {
            cb.addEventListener('change', function () {
                cards[i].classList.toggle('selected', this.checked);
                const allChecked = Array.from(checkboxes).every(c => c.checked);
                const selectAllEl = document.getElementById('selectAll');
                if (selectAllEl) selectAllEl.checked = allChecked;
                updateDashboard();
            });
        });

        // Search and filter event listeners
        ['searchEmployees', 'filterDept', 'filterRole'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.addEventListener('input', applyFilters);
        });

        // Editable cell click handlers
        document.querySelectorAll('.editable-cell').forEach(cell => {
            cell.addEventListener('click', function () {
                const input = this.querySelector('input');
                if (input && (input.style.display === 'none' || input.style.display === '')) {
                    const currentValue = this.getAttribute('data-value') || input.value;
                    this.textContent = '';
                    input.style.display = 'inline-block';
                    input.value = currentValue;
                    input.focus();
                }
            });
        });

        // Close modals on ESC
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeModal();
        });

        // Initial dashboard update
        updateDashboard();
    });
</script>
</asp:Content>