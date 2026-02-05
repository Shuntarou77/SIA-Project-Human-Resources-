using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm4 : System.Web.UI.Page
    {
        public string UserDepartment { get; set; } = "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Employee"] is Models.Employee emp)
            {
                UserDepartment = emp.Department;
            }
            else if (Session["Role"]?.ToString() == "Admin")
            {
                UserDepartment = "all";
            }
        }
    }
}