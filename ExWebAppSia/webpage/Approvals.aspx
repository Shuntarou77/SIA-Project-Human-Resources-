<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        // Redirect to the actual Approvals page in the SuperAdmin viewpoint
        Response.Redirect("~/webpage(SuperAdminViewpoint)/Approvals.aspx");
    }
</script>
<!DOCTYPE html>
<html>
<head>
    <title>Redirecting...</title>
</head>
<body>
    Redirecting to Approvals... If you are not redirected, <a href="<%= ResolveUrl("~/webpage(SuperAdminViewpoint)/Approvals.aspx") %>">click here</a>.
</body>
</html>
