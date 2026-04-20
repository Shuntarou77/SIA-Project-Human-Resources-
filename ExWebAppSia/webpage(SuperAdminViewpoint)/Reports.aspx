<%@ Page Title="Reports & Analytics" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.Reports" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-wrapper { padding: 30px; background: #f8fafc; min-height: calc(100vh - 60px); }
        .page-header { margin-bottom: 30px; }
        .page-title { font-size: 24px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; }
        .page-subtitle { font-size: 14px; color: #64748b; margin: 0; }
        .export-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 24px; }
        .export-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); border: 1px solid #e2e8f0; }
        .export-card h3 { margin: 0 0 10px 0; color: #0f172a; font-size: 18px; display: flex; align-items: center; gap: 8px; }
        .export-card p { color: #64748b; font-size: 14px; margin: 0 0 20px 0; line-height: 1.5; }
        .btn-export { background: #A36A66; color: white; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; width: 100%; transition: background 0.2s; }
        .btn-export:hover { background: #8B4755; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="page-header">
            <h1 class="page-title">Reports & Analytics</h1>
            <p class="page-subtitle">Export system records and analytics reports</p>
        </div>

        <div class="export-grid">
            <div class="export-card">
                <h3>📋 Attendance Report</h3>
                <p>Export all employee attendance records, including time-in, time-out, late, undertime, and overtime.</p>
                <button type="button" class="btn-export" onclick="alert('Exporting attendance data...')">Export CSV</button>
            </div>
            <div class="export-card">
                <h3>📅 Leave Report</h3>
                <p>Export leave history, including approved, pending, and rejected leave requests across all departments.</p>
                <button type="button" class="btn-export" onclick="alert('Exporting leave data...')">Export CSV</button>
            </div>
            <div class="export-card">
                <h3>👥 Employee Directory</h3>
                <p>Export the full list of employees, including contact details, departments, roles, and employment status.</p>
                <button type="button" class="btn-export" onclick="alert('Exporting employee data...')">Export CSV</button>
            </div>
            <div class="export-card">
                <h3>📈 Activity Logs</h3>
                <p>Export the complete system activity log, capturing HR Staff, Admin, and President actions.</p>
                <button type="button" class="btn-export" onclick="alert('Exporting activity logs...')">Export CSV</button>
            </div>
        </div>
    </div>
</asp:Content>
