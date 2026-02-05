using System.Linq;
using System.Web.Services;
using System.Web.Script.Serialization;
using ExWebAppSia.Models;
using System.Collections.Generic;

namespace ExWebAppSia.Handler
{
    public static class EmployeeHandler
    {
        /// <summary>
        /// Returns all active employees from the Employees collection as JSON.
        /// </summary>
        [WebMethod]
        public static string GetAllEmployees()
        {
            var employeeService = new EmployeeService();
            var employees = employeeService.GetAllEmployeesAsync().ConfigureAwait(false).GetAwaiter().GetResult();

            var result = employees
                .Where(e => e != null && e.IsActive)
                .Select(e => new
                {
                    id = e.Id,
                    employeeId = e.EmployeeId,
                    firstName = e.FirstName,
                    middleName = e.MiddleName,
                    lastName = e.LastName,
                    email = e.Email,
                    contactNo = e.ContactNo,
                    address = e.Address,
                    age = e.Age,
                    birthDate = e.BirthDate,
                    gender = e.Gender,
                    department = e.Department,
                    role = e.Role,
                    hiredDate = e.HiredDate,
                    applicantId = e.ApplicantId,
                    contractType = e.ContractType,
                    isActive = e.IsActive
                }).ToList();

            var serializer = new JavaScriptSerializer();
            return serializer.Serialize(result);
        }
    }
}
