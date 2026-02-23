using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExWebAppSia.webpage_EmployeeViewpoint_
{
    public partial class Recruitment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPositions();
            }
        }

        private void LoadPositions()
        {
            var positions = GetMockPositions();
            string selectedDept = ddlDepartment.SelectedValue;

            if (selectedDept != "All")
            {
                positions = positions.Where(p => p.Department == selectedDept).ToList();
            }

            rptPositions.DataSource = positions;
            rptPositions.DataBind();

            phEmpty.Visible = !positions.Any();
        }

        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPositions();
        }

        private List<PositionData> GetMockPositions()
        {
            return new List<PositionData>
            {
                new PositionData { Department = "Research & Development", Role = "Research Scientist", Slots = 2 },
                new PositionData { Department = "Quality Control", Role = "QC Analyst", Slots = 1 },
                new PositionData { Department = "Human Resources", Role = "HR Generalist", Slots = 1 },
                new PositionData { Department = "Finance", Role = "Accountant", Slots = 3 },
                new PositionData { Department = "IT Support", Role = "Network Administrator", Slots = 1 },
                new PositionData { Department = "Operations", Role = "Operations Coordinator", Slots = 2 },
                new PositionData { Department = "Sales", Role = "Account Executive", Slots = 5 },
                new PositionData { Department = "Customer Service", Role = "Customer Support Specialist", Slots = 4 }
            };
        }

        public class PositionData
        {
            public string Department { get; set; }
            public string Role { get; set; }
            public int Slots { get; set; }
        }
    }
}
