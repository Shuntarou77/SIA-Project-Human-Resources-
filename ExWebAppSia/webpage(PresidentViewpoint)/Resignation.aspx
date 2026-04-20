<%@ Page Title="Resignation Request" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="Resignation.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentResignation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .request-container { padding: 40px; max-width: 600px; margin: 0 auto; }
        .request-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 40px;
            border: 1px solid #f0f0f0;
            text-align: center;
        }
        .form-group { margin-bottom: 25px; text-align: left; }
        .form-label { display: block; font-weight: 700; color: #555; margin-bottom: 8px; font-size: 14px; }
        .form-control { width: 100%; padding: 12px 15px; border: 1.5px solid #eee; border-radius: 10px; font-weight: 600; }
        .btn-submit {
            background: #ef4444;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s ease;
            margin-top: 10px;
        }
        .btn-submit:hover { opacity: 0.9; transform: translateY(-2px); }
        .danger-box {
            background: #fff1f2;
            border-left: 4px solid #ef4444;
            padding: 15px;
            border-radius: 0 8px 8px 0;
            text-align: left;
            margin-bottom: 25px;
            font-size: 13px;
            color: #991b1b;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="request-container">
        <div class="request-card">
            <div style="font-size: 40px; margin-bottom: 20px;">👋</div>
            <h2 style="margin: 0 0 10px; color: #333;">Request Resignation</h2>
            <p style="color: #666; font-size: 14px; margin-bottom: 30px;">Officially submit your intent to resign.</p>
            
            <div class="danger-box">
                <strong>Warning:</strong> This request will be sent to HR for approval. 
                Full company-wide offboarding processes will begin upon approval.
            </div>

            <div class="form-group">
                <label class="form-label">Effective Date *</label>
                <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">Reason for Resignation *</label>
                <asp:TextBox ID="txtReason" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Please provide your reason for leaving..."></asp:TextBox>
            </div>

            <asp:Button ID="btnSubmit" runat="server" CssClass="btn-submit" Text="Submit Resignation Request" OnClick="btnSubmit_Click" OnClientClick="return confirm('Are you sure you want to submit your resignation? This action is serious.');" />
        </div>
    </div>
</asp:Content>

