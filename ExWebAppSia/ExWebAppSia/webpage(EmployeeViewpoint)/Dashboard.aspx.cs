using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExWebAppSia.Models;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected Employee CurrentEmployee
        {
            get
            {
                return Session["Employee"] as Employee;
            }
        }

        protected string GetEmployeeInitials()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "??";
            
            string initials = "";
            if (!string.IsNullOrEmpty(employee.FirstName))
                initials += employee.FirstName[0].ToString().ToUpper();
            if (!string.IsNullOrEmpty(employee.LastName))
                initials += employee.LastName[0].ToString().ToUpper();
            
            return string.IsNullOrEmpty(initials) ? "??" : initials;
        }

        protected string GetEmployeeName()
        {
            var employee = CurrentEmployee;
            if (employee == null) return "N/A";
            
            return employee.FullName ?? "N/A";
        }

        protected string GetEmployeeId()
        {
            var employee = CurrentEmployee;
            return employee?.EmployeeId ?? "N/A";
        }

        protected string GetEmployeeRole()
        {
            var employee = CurrentEmployee;
            return employee?.Role ?? "N/A";
        }

        protected string GetEmployeeAddress()
        {
            var employee = CurrentEmployee;
            return employee?.Address ?? "N/A";
        }

        protected string GetEmployeeEmail()
        {
            var employee = CurrentEmployee;
            return employee?.Email ?? "N/A";
        }

        protected string GetEmployeeContact()
        {
            var employee = CurrentEmployee;
            return employee?.ContactNo ?? "N/A";
        }

        protected string GetEmployeeDepartment()
        {
            var employee = CurrentEmployee;
            return employee?.Department ?? "N/A";
        }
    }
}