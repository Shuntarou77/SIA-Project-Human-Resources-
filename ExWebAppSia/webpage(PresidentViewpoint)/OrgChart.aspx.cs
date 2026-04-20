using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using ExWebAppSia.Models;
using System.Threading.Tasks;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class PresidentOrgChart : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static object GetOrgData()
        {
            try
            {
                var employeeService = new EmployeeService();
                // PageMethods do not support async Task return types; must return the object directly
                var data = employeeService.GetOrgChartDataAsync().GetAwaiter().GetResult();
                return data;
            }
            catch (Exception ex)
            {
                return new { error = ex.Message };
            }
        }
    }
}
