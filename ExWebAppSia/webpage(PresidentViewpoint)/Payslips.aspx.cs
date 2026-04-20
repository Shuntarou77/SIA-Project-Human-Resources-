using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using MongoDB.Driver;
using System.Configuration;
using MongoDB.Bson;

namespace ExWebAppSia.webpage_PresidentViewpoint_
{
    public partial class PresidentPayslips : System.Web.UI.Page
    {
        private PayrollSnapshot _latestPayroll = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadLatestPayrollAsync));
        }

        protected Employee CurrentEmployee => Session["Employee"] as Employee;

        private async Task LoadLatestPayrollAsync()
        {
            try 
            {
                var employee = CurrentEmployee;
                if (employee == null || string.IsNullOrEmpty(employee.EmployeeId)) return;

                var client = new MongoClient(ConfigurationManager.ConnectionStrings["MongoDBConnection"].ConnectionString);
                var database = client.GetDatabase("sia_payroll_db");
                var collection = database.GetCollection<PayrollSnapshot>("PayrollSnapshots");

                var idFilter = Builders<PayrollSnapshot>.Filter.Regex("employee_number", new BsonRegularExpression(employee.EmployeeId, "i"));
                var nameFilter = Builders<PayrollSnapshot>.Filter.Regex("full_name", new BsonRegularExpression(employee.FullName, "i"));
                var combinedFilter = Builders<PayrollSnapshot>.Filter.Or(idFilter, nameFilter);

                _latestPayroll = await collection.Find(combinedFilter)
                    .SortByDescending(p => p.PayPeriodEnd)
                    .FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading payroll: {ex.Message}");
            }
        }

        protected string GetBasicSalary() => _latestPayroll?.BasicSalary.ToString("N2") ?? "0.00";
        protected string GetAllowances() => (_latestPayroll != null ? (_latestPayroll.HousingAllowance + _latestPayroll.TransportAllowance + _latestPayroll.MealAllowance + _latestPayroll.OtherAllowances) : 0).ToString("N2");
        protected string GetOvertimePay() => _latestPayroll?.TotalOvertime.ToString("N2") ?? "0.00";
        protected string GetGrossSalary() => _latestPayroll?.GrossPay.ToString("N2") ?? "0.00";
        protected string GetSSSDeduction() => _latestPayroll?.SSSDeduction.ToString("N2") ?? "0.00";
        protected string GetPhilHealthDeduction() => _latestPayroll?.PhilHealthDeduction.ToString("N2") ?? "0.00";
        protected string GetPagIbigDeduction() => _latestPayroll?.PagIbigDeduction.ToString("N2") ?? "0.00";
        protected string GetWithholdingTax() => _latestPayroll?.WithholdingTax.ToString("N2") ?? "0.00";
        protected string GetAbsenceDeduction() => _latestPayroll?.AbsenceDeduction.ToString("N2") ?? "0.00";
        protected string GetTotalDeductions() => _latestPayroll?.TotalDeductions.ToString("N2") ?? "0.00";
        protected string GetNetSalary() => _latestPayroll?.NetPay.ToString("N2") ?? "0.00";
        protected string GetPayPeriod() => _latestPayroll != null ? (_latestPayroll.PayPeriodStart.ToString("MMMM dd, yyyy") + " - " + _latestPayroll.PayPeriodEnd.ToString("MMMM dd, yyyy")) : "N/A";
    }
}
