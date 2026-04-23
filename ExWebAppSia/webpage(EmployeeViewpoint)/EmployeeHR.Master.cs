using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class EmployeeHR : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Hide search bar by default for regular employee pages
            string currentPage = Request.Url.AbsolutePath.ToLower();
            bool needsSearch = false; // Add page names here if needed
            
            if (searchContainer != null)
                searchContainer.Visible = needsSearch;
        }
    }
}