<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PasswordHashGenerator.aspx.cs" Inherits="ExWebAppSia.PasswordHashGenerator" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Password Hash Generator</title>
</head>
<body>
    <form id="form1" runat="server">
        <h1>Password Hash Generator</h1>
        <p>Enter a password to generate its hash:</p>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
        <asp:Button ID="btnGenerate" runat="server" Text="Generate Hash" OnClick="btnGenerate_Click" />
        <br /><br />
        <asp:Label ID="lblHash" runat="server" />
    </form>
</body>
</html>