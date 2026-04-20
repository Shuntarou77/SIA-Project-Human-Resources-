<%@ Page Title="Personal Payslips" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Payslips.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentPayslips" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .payslip-container { padding: 40px; max-width: 1000px; margin: 0 auto; }
        .payslip-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 40px;
            border: 1px solid #f0f0f0;
        }
        .payslip-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #fcebeb;
        }
        .payslip-item {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #f9f9f9;
        }
        .summary-box {
            background: #8B4755;
            color: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            margin-top: 30px;
        }
        .btn-download {
            background: #A44F56;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
        }
        .btn-download:hover { transform: scale(1.05); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="payslip-container">
        <div class="payslip-card">
            <div class="payslip-header">
                <h2 style="margin: 0; color: #333;"><i class="fas fa-money-check-alt"></i> My Payslip</h2>
                <a href="#" class="btn-download" onclick="alert('PDF generation logic would go here, similar to employee view.')">
                    <i class="fas fa-file-pdf"></i> Download PDF
                </a>
            </div>

            <div style="background: #fff8f8; padding: 15px; border-radius: 8px; margin-bottom: 30px; text-align: center;">
                <span style="color: #777; font-size: 13px;">PAY PERIOD</span><br/>
                <span style="font-weight: 700; color: #A44F56;"><%= GetPayPeriod() %></span>
            </div>

            <h4 style="color: #A44F56; text-transform: uppercase; font-size: 13px; letter-spacing: 1px; margin-bottom: 20px;">Earnings Breakdown</h4>
            <div class="payslip-item"><span>Basic Salary</span><strong><%= GetBasicSalary() %></strong></div>
            <div class="payslip-item"><span>Allowances</span><strong><%= GetAllowances() %></strong></div>
            <div class="payslip-item"><span>Overtime Pay</span><strong><%= GetOvertimePay() %></strong></div>
            <div class="payslip-item" style="border-bottom: 2px solid #eee;"><span>Gross Pay</span><strong style="color: #A44F56;"><%= GetGrossSalary() %></strong></div>

            <h4 style="color: #dc2626; text-transform: uppercase; font-size: 13px; letter-spacing: 1px; margin: 30px 0 20px;">Deductions</h4>
            <div class="payslip-item"><span>SSS / PhilHealth / Pag-IBIG</span><strong style="color: #dc2626;"><%= GetSSSDeduction() %> / <%= GetPhilHealthDeduction() %> / <%= GetPagIbigDeduction() %></strong></div>
            <div class="payslip-item"><span>Withholding Tax</span><strong style="color: #dc2626;"><%= GetWithholdingTax() %></strong></div>
            <div class="payslip-item"><span>Absences & Lates</span><strong style="color: #dc2626;"><%= GetAbsenceDeduction() %></strong></div>
            <div class="payslip-item" style="border-bottom: 2px solid #eee;"><span>Total Deductions</span><strong style="color: #dc2626;"><%= GetTotalDeductions() %></strong></div>

            <div class="summary-box">
                <div style="font-size: 14px; opacity: 0.9; text-transform: uppercase; letter-spacing: 1px;">Net Take-Home Pay</div>
                <div style="font-size: 36px; font-weight: 800; margin-top: 5px;"><%= GetNetSalary() %></div>
            </div>
        </div>
    </div>
</asp:Content>

