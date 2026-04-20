using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class President : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check
            if (Session["Role"] == null || Session["Role"].ToString() != "President")
            {
                Response.Redirect("~/LoginFolder/Login.aspx");
            }
        }
    }
}
