using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class Announcement : System.Web.UI.Page
    {
        public string UserDepartment { get; set; } = "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            // President sees all announcements
            UserDepartment = "all";
        }
    }
}
