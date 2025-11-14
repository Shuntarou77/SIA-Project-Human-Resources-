using System;
using System.Web.UI;

namespace ExWebAppSia.webpage_ManagerViewpoint
{
    public partial class Manager : System.Web.UI.MasterPage
    {
        // ✅ Enable <%= ResolveUrl(...) %> by calling DataBind at init
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Page.DataBind(); // Required for <%# ... %>, but we use <%= — still safe to include
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: Set real username from session
            // Example:
            // if (Session["FullName"] != null)
            //     litUsername.Text = Session["FullName"].ToString();
            // else
            //     litUsername.Text = "Manager";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear session
            Session.Clear();
            Session.Abandon();

            // Redirect safely
            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}