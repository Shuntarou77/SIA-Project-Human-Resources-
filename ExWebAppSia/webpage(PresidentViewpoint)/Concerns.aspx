<%@ Page Title="Employee Concern" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Concerns.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentConcerns" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .request-container { padding: 40px; max-width: 800px; margin: 0 auto; }
        .request-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 40px;
            border: 1px solid #f0f0f0;
        }
        .form-group { margin-bottom: 25px; }
        .form-label { display: block; font-weight: 700; color: #555; margin-bottom: 8px; font-size: 14px; }
        .form-control { width: 100%; padding: 12px 15px; border: 1.5px solid #eee; border-radius: 10px; font-weight: 600; }
        .btn-submit {
            background: #A44F56;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s ease;
        }
        .btn-submit:hover { opacity: 0.9; transform: translateY(-2px); }
        .status-message {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: none;
            font-weight: 600;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="request-container">
        <div class="request-card">
            <h2 style="margin: 0 0 30px; color: #333;"><i class="fas fa-exclamation-circle"></i> Submit Employee Concern</h2>
            
            <asp:Panel ID="pnlMessage" runat="server" CssClass="status-message">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Concern Type *</label>
                <asp:DropDownList ID="ddlConcernType" runat="server" CssClass="form-control">
                    <asp:ListItem Value="" Text="Select concern type"></asp:ListItem>
                    <asp:ListItem Value="workplace" Text="Workplace Issue"></asp:ListItem>
                    <asp:ListItem Value="safety" Text="Safety Concern"></asp:ListItem>
                    <asp:ListItem Value="payroll" Text="Payroll Issue"></asp:ListItem>
                    <asp:ListItem Value="suggestion" Text="Suggestion/Feedback"></asp:ListItem>
                    <asp:ListItem Value="other" Text="Other"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label class="form-label">Subject *</label>
                <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Brief subject of your concern"></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">Description *</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" placeholder="Provide detailed information about your concern..."></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">Supporting Documents (Optional)</label>
                <asp:FileUpload ID="fileAttachment" runat="server" CssClass="form-control" />
            </div>

            <asp:Button ID="btnSubmit" runat="server" CssClass="btn-submit" Text="Submit Concern" OnClick="btnSubmit_Click" />
        </div>
    </div>
</asp:Content>

