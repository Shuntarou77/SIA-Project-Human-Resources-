using System;
using System.Web;
using System.Web.UI;

namespace ExWebAppSia.webpage_SuperAdminViewpoint_
{
    public partial class SuperAdmin : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Inalis ko muna toh, dapat nasa controller to eh. Kaso naka webforms kayo. :(

            //    // Debug: Show session values
            //    System.Diagnostics.Debug.WriteLine($"HR.Master Page_Load - IsLoggedIn: {Session["IsLoggedIn"]}, Role: {Session["Role"]}");

            //    // Check if user is logged in
            //    if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            //    {
            //        System.Diagnostics.Debug.WriteLine("User not logged in, redirecting to login");
            //        // Redirect to login if not authenticated
            //        Response.Redirect("~/LoginFolder/Login.aspx");
            //        return;
            //    }

            //    // Check if user has Admin role
            //    if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            //    {
            //        System.Diagnostics.Debug.WriteLine($"User role is not Admin. Role: {Session["Role"]}");
            //        // Redirect to login if not admin
            //        Response.Redirect("~/LoginFolder/Login.aspx");
            //        return;
            //    }

            //    System.Diagnostics.Debug.WriteLine("User authenticated as Admin, proceeding to dashboard");

            //    if (!IsPostBack)
            //    {
            //        // Display username in the header
            //        if (Session["Username"] != null)
            //        {
            //            litUsername.Text = Session["Username"].ToString();
            //        }
            //    }
            //}

            //protected void btnLogout_Click(object sender, EventArgs e)
            //{
            //    // Clear session
            //    Session.Clear();
            //    Session.Abandon();

            //    // Remove cookies if they exist
            //    if (Request.Cookies["HRSystemUser"] != null)
            //    {
            //        HttpCookie userCookie = new HttpCookie("HRSystemUser");
            //        userCookie.Expires = DateTime.Now.AddDays(-1);
            //        Response.Cookies.Add(userCookie);
            //    }

            // Hide search bar for pages that don't need it
            string currentPage = Request.Url.AbsolutePath.ToLower();
            bool needsSearch = currentPage.Contains("employee.aspx") || 
                              currentPage.Contains("attendance.aspx") || 
                              currentPage.Contains("recruitment.aspx") || 
                              currentPage.Contains("approvals.aspx") ||
                              currentPage.Contains("activitylog.aspx");
            
            if (searchContainer != null)
                searchContainer.Visible = needsSearch;
        }
    }
}
