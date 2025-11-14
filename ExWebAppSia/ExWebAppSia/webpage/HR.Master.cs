using System;
using System.Web;
using System.Web.UI;

namespace ExWebAppSia.webpage
{
    public partial class HR : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Debug: Show session values
            System.Diagnostics.Debug.WriteLine($"HR.Master Page_Load - IsLoggedIn: {Session["IsLoggedIn"]}, Role: {Session["Role"]}");

            // Check if user is logged in
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                System.Diagnostics.Debug.WriteLine("User not logged in, redirecting to login");
                // Redirect to login if not authenticated
                Response.Redirect("~/LoginFolder/Login.aspx");
                return;
            }

            // Check if user has Admin role
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                System.Diagnostics.Debug.WriteLine($"User role is not Admin. Role: {Session["Role"]}");
                // Redirect to login if not admin
                Response.Redirect("~/LoginFolder/Login.aspx");
                return;
            }

            System.Diagnostics.Debug.WriteLine("User authenticated as Admin, proceeding to dashboard");

            if (!IsPostBack)
            {
                // Display username in the header
                if (Session["Username"] != null)
                {
                    string username = Session["Username"].ToString();
                    litUsername.Text = username;
                    
                    // Set user initials
                    if (username.Length >= 2)
                    {
                        litUserInitials.Text = username.Substring(0, 2).ToUpper();
                    }
                    else if (username.Length == 1)
                    {
                        litUserInitials.Text = username.Substring(0, 1).ToUpper();
                    }
                }
                
                // Display user ID if available
                if (Session["UserId"] != null)
                {
                    litUserId.Text = Session["UserId"].ToString();
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear session
            Session.Clear();
            Session.Abandon();

            // Remove cookies if they exist
            if (Request.Cookies["HRSystemUser"] != null)
            {
                HttpCookie userCookie = new HttpCookie("HRSystemUser");
                userCookie.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(userCookie);
            }

            // Redirect to login page
            Response.Redirect("~/LoginFolder/Login.aspx");
        }
    }
}