<%@ Page Title="Activity Log" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true"
    CodeBehind="ActivityLog.aspx.cs" Inherits="ExWebAppSia.webpage.ActivityLog" Async="true" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <link href="css/modern-theme.css" rel="stylesheet" />
        <style>
            .activity-header {
                margin-bottom: 30px;
            }

            .activity-title {
                font-size: 28px;
                font-weight: 700;
                color: #2d3748;
                margin: 0;
                margin-bottom: 8px;
            }

            .activity-subtitle {
                color: #718096;
                margin: 0;
                font-size: 15px;
            }

            .activity-card {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                padding: 24px;
            }

            .activity-table {
                width: 100%;
                border-collapse: collapse;
            }

            .activity-table th {
                text-align: left;
                padding: 12px 16px;
                color: #718096;
                font-weight: 600;
                font-size: 13px;
                text-transform: uppercase;
                border-bottom: 2px solid #edf2f7;
            }

            .activity-table td {
                padding: 16px;
                border-bottom: 1px solid #edf2f7;
                color: #4a5568;
                font-size: 14px;
            }

            .activity-table tr:hover {
                background: #f7fafc;
            }

            .action-badge {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 9999px;
                font-size: 12px;
                font-weight: 600;
                text-transform: capitalize;
            }

            .action-create {
                background: #e6fffa;
                color: #234e52;
            }

            .action-update {
                background: #ebf8ff;
                color: #2a4365;
            }

            .action-delete,
            .action-resign {
                background: #fff5f5;
                color: #742a2a;
            }

            .action-other {
                background: #f0fff4;
                color: #22543d;
            }

            .action-recruit {
                background: #faf5ff;
                color: #44337a;
            }

            .hr-name {
                font-weight: 600;
                color: #1a202c;
            }

            .hr-username {
                font-size: 12px;
                color: #a0aec0;
                display: block;
            }

            .log-time {
                font-weight: 500;
            }

            .log-date {
                font-size: 12px;
                color: #a0aec0;
                display: block;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="content">
            <div class="activity-header">
                <h1 class="activity-title">HR Activity Log</h1>
                <p class="activity-subtitle">Track administrative actions and system modifications made by human
                    resources staff.</p>
            </div>

            <div class="activity-card">
                <table class="activity-table">
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
        </div>
    </asp:Content>