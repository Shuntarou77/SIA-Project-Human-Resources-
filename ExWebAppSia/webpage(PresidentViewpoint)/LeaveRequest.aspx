<%@ Page Title="Leave Request" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="LeaveRequest.aspx.cs"
    Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentLeaveRequest" %>

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
            <h2 style="margin: 0 0 30px; color: #333;"><i class="fas fa-calendar-plus"></i> File Leave of Absence</h2>
            
            <asp:Panel ID="pnlMessage" runat="server" CssClass="status-message">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Leave Type *</label>
                <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="form-control">
                    <asp:ListItem Value="" Text="Select leave type"></asp:ListItem>
                    <asp:ListItem Value="sick" Text="Sick Leave"></asp:ListItem>
                    <asp:ListItem Value="vacation" Text="Vacation Leave"></asp:ListItem>
                    <asp:ListItem Value="personal" Text="Personal Leave"></asp:ListItem>
                    <asp:ListItem Value="emergency" Text="Emergency Leave"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div class="form-group">
                    <label class="form-label">Start Date *</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">End Date *</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Reason for Leave *</label>
                <asp:TextBox ID="txtLeaveReason" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Provide details about your leave request..."></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">Attachment (Optional)</label>
                <asp:FileUpload ID="fileLeaveAttachment" runat="server" CssClass="form-control" />
            </div>

            <asp:Button ID="btnSubmitLeave" runat="server" CssClass="btn-submit" Text="Submit Leave Request" OnClick="btnSubmitLeave_Click" />
        </div>
    </div>
</asp:Content>

