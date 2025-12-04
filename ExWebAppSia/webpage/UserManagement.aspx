<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="ExWebAppSia.webpage.UserManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .user-form {
            background-color: #FFC6C5;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .btn {
            padding: 10px 20px;
            background-color: #8B0000;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h1>User Management</h1>
    
    <div class="user-form">
        <h3>Add New User</h3>
        <div class="form-group">
            <label>Username:</label>
            <asp:TextBox ID="txtNewUsername" runat="server" CssClass="form-control" />
        </div>
        <div class="form-group">
            <label>Password:</label>
            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control" />
        </div>
        <div class="form-group">
            <label>Role:</label>
            <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                <asp:ListItem Value="Admin">Admin</asp:ListItem>
                <asp:ListItem Value="Employee">Employee</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="form-group">
            <label>Email:</label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
        </div>
        <asp:Button ID="btnAddUser" runat="server" Text="Add User" CssClass="btn" OnClick="btnAddUser_Click" />
    </div>

    <asp:Label ID="lblMessage" runat="server" />
</asp:Content>