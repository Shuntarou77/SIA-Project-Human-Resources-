<%@ Page Title="Activity Log" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true"
    CodeBehind="ActivityLog.aspx.cs" Inherits="ExWebAppSia.webpage.ActivityLog" Async="true" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <link href="css/modern-theme.css" rel="stylesheet" />
        <style>
            :root {
                --bg-color: #f8fafc;
                --panel-bg: #ffffff;
                --text-dark: #202d41;
                /* Unified Brand Color */
                --accent: #A36A66;
                --accent-light: #C49A99;
                --accent-dark: #8B5A58;
                --border-color: #e8e8e8;
            }

            .activity-container {
                padding: 10px 20px 40px;
                background-color: transparent;
            }

            /* Enhanced Header Style */
            .page-header {
                display: flex;
                align-items: center;
                gap: 20px;
                margin-bottom: 35px;
                padding: 24px 30px;
                background: linear-gradient(to right, #ffffff, #fdfbfb);
                border-radius: 16px;
                border: 1px solid var(--border-color);
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            }

            .header-icon {
                width: 56px;
                height: 56px;
                background: var(--accent);
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 24px;
                box-shadow: 0 4px 10px rgba(163, 106, 102, 0.3);
            }

            .header-content {
                flex: 1;
            }

            .activity-title {
                font-size: 28px;
                font-weight: 800;
                color: var(--text-dark);
                margin: 0;
                letter-spacing: -0.5px;
                line-height: 1.2;
            }

            .activity-subtitle {
                color: #64748b;
                margin: 4px 0 0;
                font-size: 14px;
                font-weight: 500;
            }

            /* Filter Bar */
            .filter-section {
                display: flex;
                gap: 15px;
                margin-bottom: 25px;
                background: white;
                padding: 20px;
                border-radius: 12px;
                border: 1px solid var(--border-color);
                box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            }

            .search-box {
                position: relative;
                flex: 1;
            }

            .search-box i {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #a0aec0;
            }

            .search-input {
                width: 100%;
                padding: 10px 14px 10px 40px;
                border: 1px solid var(--border-color);
                border-radius: 8px;
                font-size: 14px;
                transition: border-color 0.2s;
            }

            .search-input:focus {
                outline: none;
                border-color: var(--accent);
            }

            .module-select {
                padding: 10px 15px;
                border: 1px solid var(--border-color);
                border-radius: 8px;
                font-size: 14px;
                min-width: 160px;
                background: #fff;
            }

            /* Main Card */
            .activity-card {
                background: white;
                border-radius: 12px;
                border: 1px solid var(--border-color);
                box-shadow: 0 4px 12px rgba(0,0,0,0.03);
                overflow: hidden;
            }

            .activity-table {
                width: 100%;
                border-collapse: collapse;
            }

            .activity-table th {
                text-align: left;
                padding: 15px 20px;
                background: #fafafa;
                color: #8898aa;
                font-weight: 600;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 1px;
                border-bottom: 1px solid var(--border-color);
            }

            .activity-table td {
                padding: 16px 20px;
                border-bottom: 1px solid #f8f9fa;
                vertical-align: middle;
                font-size: 14px;
            }

            .activity-table tr:hover {
                background-color: #fbfcff;
            }

            /* HR Admin Badge */
            .hr-info {
                display: flex;
                flex-direction: column;
            }

            .hr-name {
                font-weight: 600;
                color: #32325d;
                font-size: 14px;
            }

            .hr-email {
                font-size: 12px;
                color: #8898aa;
            }

            .log-module {
                font-weight: 500;
                color: #525f7f;
            }

            /* Modern Badges  */
            .action-badge {
                display: inline-flex;
                align-items: center;
                padding: 5px 12px;
                border-radius: 15px;
                font-size: 12px;
                font-weight: 600;
            }

            .action-create { background: #e3f9eb; color: #1fb141; }
            .action-update { background: #e5f2ff; color: #007bff; }
            .action-delete { background: #fee2e2; color: #ef4444; }
            .action-attendance { background: #fff7ed; color: #f97316; }
            .action-other { background: #f3f4f6; color: #6b7280; }

            .target-detail {
                color: #525f7f;
                max-width: 450px;
                line-height: 1.4;
            }

            .time-info {
                display: flex;
                flex-direction: column;
                white-space: nowrap;
            }

            .time-val {
                font-weight: 600;
                color: #32325d;
            }

            .date-val {
                font-size: 12px;
                color: #8898aa;
            }

            .export-btn {
                background: #10b981;
                color: white !important;
                padding: 10px 20px;
                border-radius: 8px;
                font-size: 14px;
                font-weight: 700;
                text-decoration: none !important;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.2s;
                border: none;
                cursor: pointer;
                box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);
            }

            .export-btn:hover {
                background: #059669;
                transform: translateY(-1px);
                box-shadow: 0 6px 12px rgba(16, 185, 129, 0.3);
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="activity-container">
            <div class="page-header">
                <div class="header-icon">
                    <i class="fas fa-list-ul"></i>
                </div>
                <div class="header-content">
                    <h1 class="activity-title">HR Activity Log</h1>
                    <p class="activity-subtitle">Review administrative actions and system modifications performed by HR staff and automated processes.</p>
                </div>
            </div>

            <div class="filter-section">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="logSearch" class="search-input" placeholder="Search by Administrator or Detail..." 
                        onkeyup="filterLogs()"/>
                </div>
                <select id="moduleFilter" class="module-select" onchange="filterLogs()">
                    <option value="All">All Modules</option>
                    <option value="Attendance">Attendance</option>
                    <option value="Announcements">Announcements</option>
                    <option value="Recruitment">Recruitment</option>
                    <option value="Employee">Employee Management</option>
                    <option value="Leave">Leave Management</option>
                </select>
                <asp:LinkButton ID="btnExport" runat="server" OnClick="btnExport_Click" CssClass="export-btn">
                    <i class="fas fa-file-pdf"></i> Export to PDF
                </asp:LinkButton>
            </div>

            <div class="activity-card">
                <div style="overflow-x: auto;">
                    <table class="activity-table" id="activityTable">
                        <thead>
                            <tr>
                                <th>Administrator</th>
                                <th>Module</th>
                                <th>Action Performed</th>
                                <th>Target Detail</th>
                                <th>Date & Time</th>
                            </tr>
                        </thead>
                    <tbody>
                        <asp:PlaceHolder ID="phActivityLogs" runat="server"></asp:PlaceHolder>
                    </tbody>
                </table>
            </div>
            <script>
                function filterLogs() {
                    const search = (document.getElementById('logSearch')?.value || '').toLowerCase();
                    const module = (document.getElementById('moduleFilter')?.value || 'all').toLowerCase();
                    const table = document.getElementById('activityTable');
                    const rows = table?.getElementsByTagName('tbody')[0]?.rows;
                    if (!rows) return;

                    for (let i = 0; i < rows.length; i++) {
                        const row = rows[i];
                        if (row.cells.length < 4) continue; 
                        const text = row.innerText.toLowerCase();
                        const modVal = row.cells[1].innerText.toLowerCase();
                        const matchesSearch = text.includes(search);
                        const matchesModule = module === 'all' || modVal.includes(module);
                        row.style.display = (matchesSearch && matchesModule) ? '' : 'none';
                    }
                }
            </script>
        </div>
    </asp:Content>