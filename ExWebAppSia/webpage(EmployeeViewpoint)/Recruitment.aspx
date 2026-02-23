<%@ Page Title="Available Positions" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Recruitment.aspx.cs"
    Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.Recruitment" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            :root {
                --primary-color: #A44F56;
                --secondary-color: #DE9D9D;
                --accent-color: #FFE8E8;
                --text-primary: #4A2E2E;
                --text-secondary: #6B4545;
                --border-color: #E8C4C4;
            }

            .recruitment-container {
                padding: 24px;
                max-width: 1200px;
                margin: 0 auto;
            }

            .header-section {
                margin-bottom: 32px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .page-title {
                font-size: 28px;
                font-weight: 700;
                color: var(--primary-color);
            }

            .filter-section {
                background: white;
                padding: 20px;
                border-radius: 16px;
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.1);
                margin-bottom: 24px;
                display: flex;
                gap: 16px;
                align-items: center;
                border: 1px solid var(--border-color);
            }

            .filter-label {
                font-weight: 600;
                color: var(--text-secondary);
            }

            .form-control {
                padding: 10px 16px;
                border-radius: 8px;
                border: 1px solid var(--border-color);
                outline: none;
                min-width: 200px;
            }

            .positions-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 20px;
            }

            .position-card {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.08);
                border: 1px solid var(--border-color);
                transition: transform 0.2s ease;
                position: relative;
                overflow: hidden;
            }

            .position-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 8px 24px rgba(164, 79, 86, 0.15);
            }

            .position-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 4px;
                height: 100%;
                background: var(--primary-color);
            }

            .position-dept {
                font-size: 12px;
                font-weight: 700;
                color: var(--primary-color);
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 8px;
            }

            .position-title {
                font-size: 20px;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 12px;
            }

            .position-info {
                display: flex;
                align-items: center;
                gap: 8px;
                color: var(--text-secondary);
                font-size: 14px;
                margin-bottom: 8px;
            }

            .position-count {
                background: var(--accent-color);
                color: var(--primary-color);
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                margin-top: 12px;
                display: inline-block;
            }

            .empty-state {
                text-align: center;
                padding: 48px;
                color: var(--text-muted);
                grid-column: 1 / -1;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="recruitment-container">
            <div class="header-section">
                <h1 class="page-title">Company Openings</h1>
            </div>

            <div class="filter-section">
                <label class="filter-label">Filter by Department:</label>
                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control" AutoPostBack="true"
                    OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged">
                    <asp:ListItem Value="All">All Departments</asp:ListItem>
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

            <div class="positions-grid">
                <asp:Repeater ID="rptPositions" runat="server">
                    <ItemTemplate>
                        <div class="position-card">
                            <div class="position-dept">
                                <%# Eval("Department") %>
                            </div>
                            <h3 class="position-title">
                                <%# Eval("Role") %>
                            </h3>
                            <div class="position-info">
                                <i class="fas fa-map-marker-alt"></i> HQ Office
                            </div>
                            <div class="position-info">
                                <i class="fas fa-clock"></i> Full-time
                            </div>
                            <div class="position-count">
                                <%# Eval("Slots") %> Slots Available
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                    <div class="empty-state">
                        <i class="fas fa-search fa-3x" style="margin-bottom: 16px; opacity: 0.3;"></i>
                        <p>No open positions found for the selected department.</p>
                    </div>
                </asp:PlaceHolder>
            </div>
        </div>
    </asp:Content>