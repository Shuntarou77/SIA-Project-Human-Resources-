using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.Models
{
    public static class EmployeeSeeder
    {
        private static readonly Dictionary<string, string[]> DeptRoles = new Dictionary<string, string[]>
        {
            { "Research & Development", new[] { "Research Scientist", "Lab Technician", "Product Developer", "R&D Manager" } },
            { "Quality Control", new[] { "QC Analyst", "QC Inspector", "QC Manager", "Laboratory Supervisor" } },
            { "Human Resources", new[] { "HR Generalist", "Recruitment Specialist", "HR Manager", "Training Coordinator" } },
            { "Finance", new[] { "Accountant", "Financial Analyst", "Finance Manager", "Payroll Specialist" } },
            { "Marketing", new[] { "Marketing Coordinator", "Brand Manager", "Digital Marketing Specialist", "Content Creator" } },
            { "IT Support", new[] { "IT Support Specialist", "Network Administrator", "System Administrator", "IT Manager" } },
            { "Operations", new[] { "Operations Coordinator", "Operations Manager", "Supply Chain Specialist", "Logistics Coordinator" } },
            { "Sales", new[] { "Sales Representative", "Sales Manager", "Account Executive", "Business Development Manager" } },
            { "Legal", new[] { "Legal Counsel", "Compliance Officer", "Legal Assistant", "Contract Specialist" } },
            { "Customer Service", new[] { "Customer Service Representative", "Customer Support Specialist", "Call Center Agent", "Customer Service Manager" } }
        };

        private static readonly Dictionary<string, decimal> RegularSalaries = new Dictionary<string, decimal>
        {
            { "Research Scientist", 48000 }, { "Lab Technician", 25000 }, { "Product Developer", 42000 }, { "R&D Manager", 85000 },
            { "QC Analyst", 30000 }, { "QC Inspector", 24000 }, { "QC Manager", 75000 }, { "Laboratory Supervisor", 55000 },
            { "HR Generalist", 32500 }, { "Recruitment Specialist", 28000 }, { "HR Manager", 75000 }, { "Training Coordinator", 35000 },
            { "Accountant", 40000 }, { "Financial Analyst", 45000 }, { "Finance Manager", 85000 }, { "Payroll Specialist", 32000 },
            { "Marketing Coordinator", 28000 }, { "Brand Manager", 70000 }, { "Digital Marketing Specialist", 35000 }, { "Content Creator", 26000 },
            { "IT Support Specialist", 32000 }, { "Network Administrator", 55000 }, { "System Administrator", 58000 }, { "IT Manager", 95000 },
            { "Operations Coordinator", 30000 }, { "Operations Manager", 80000 }, { "Supply Chain Specialist", 42000 }, { "Logistics Coordinator", 28000 },
            { "Sales Representative", 25000 }, { "Sales Manager", 70000 }, { "Account Executive", 45000 }, { "Business Development Manager", 80000 },
            { "Legal Counsel", 100000 }, { "Compliance Officer", 60000 }, { "Legal Assistant", 30000 }, { "Contract Specialist", 48000 },
            { "Customer Service Representative", 22000 }, { "Customer Support Specialist", 28000 }, { "Call Center Agent", 24000 }, { "Customer Service Manager", 70000 }
        };

        private static readonly string[] FirstNames = { "James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda", "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa", "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Donald", "Ashley", "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle", "Kenneth", "Dorothy", "Kevin", "Carol", "Brian", "Amanda", "George", "Melissa", "Edward", "Deborah" };
        private static readonly string[] LastNames = { "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts" };

        public static async Task SeedEmployeesAsync()
        {
            var employeeService = new EmployeeService();
            var allEmployees = await employeeService.GetAllEmployeesAsync();
            int nameIndex = 0;

            foreach (var dept in DeptRoles)
            {
                string departmentName = dept.Key;
                string[] roles = dept.Value;

                // Check how many employees this department currently has
                int currentCount = allEmployees.Count(e => e.Department == departmentName);
                int needed = 5 - currentCount;

                if (needed <= 0) continue;

                for (int i = 0; i < needed; i++)
                {
                    // Ensure unique names/emails by using a global index
                    string firstName = FirstNames[(nameIndex + nameIndex / 5) % FirstNames.Length];
                    string lastName = LastNames[(nameIndex + nameIndex / 10) % LastNames.Length];
                    string email = $"emp.{firstName.ToLower()}.{lastName.ToLower()}{Guid.NewGuid().ToString().Substring(0, 4)}@shessentials.com";
                    string role = roles[i % roles.Length];
                    
                    // Mix of Regular and Probationary
                    bool isRegular = (i % 2 == 0); 
                    string contractType = isRegular ? "Regular" : "Probationary";
                    
                    // Regular hired 1 year ago, Probationary hired 2 months ago
                    DateTime hiredDate = isRegular ? DateTime.UtcNow.AddYears(-1).AddDays(nameIndex * 2) : DateTime.UtcNow.AddMonths(-2).AddDays(nameIndex);
                    
                    decimal baseSalary = isRegular ? 
                        (RegularSalaries.ContainsKey(role) ? RegularSalaries[role] : 18000) : 
                        18000;

                    var employee = new Employee
                    {
                        FirstName = firstName,
                        LastName = lastName,
                        Email = email,
                        Department = departmentName,
                        Role = role,
                        ContractType = contractType,
                        HiredDate = hiredDate,
                        BaseSalary = baseSalary,
                        IsActive = true,
                        ContactNo = $"0917{new Random().Next(1000000, 9999999)}",
                        Address = $"{120 + nameIndex} Innovation St., Metro Manila"
                    };

                    await employeeService.CreateEmployeeAsync(employee);
                    nameIndex++;
                }
            }
        }
        public static async Task SeedSpecificHREmployeesAsync()
        {
            var employeeService = new EmployeeService();
            var hREmployees = new[]
            {
                new { Email = "princessm.peregrino@gmail.com", FirstName = "Princess M.", LastName = "Peregrino", Role = "HR Generalist" },
                new { Email = "santos.francisniel.bitoon@gmail.com", FirstName = "Francis Niel", LastName = "Bitoon", Role = "Recruitment Specialist" },
                new { Email = "steven.andrei.baliong@gmail.com", FirstName = "Steven Andrei", LastName = "Baliong", Role = "HR Manager" },
                new { Email = "tan.mariaraye.tante@gmail.com", FirstName = "Maria Raye", LastName = "Tante", Role = "Training Coordinator" },
                new { Email = "jhonrey.loreno77@gmail.com", FirstName = "Jhonrey", LastName = "Loreno", Role = "Payroll Specialist" }
            };

            foreach (var data in hREmployees)
            {
                var existingEmployees = await employeeService.GetAllEmployeesAsync();
                if (existingEmployees.Exists(e => e.Email.Equals(data.Email, StringComparison.OrdinalIgnoreCase)))
                {
                    continue;
                }

                var employee = new Employee
                {
                    FirstName = data.FirstName,
                    LastName = data.LastName,
                    Email = data.Email,
                    Department = "Human Resources",
                    Role = data.Role,
                    ContractType = "Regular",
                    HiredDate = DateTime.UtcNow.AddMonths(-1),
                    BaseSalary = 32500,
                    IsActive = true,
                    ContactNo = "09170000000",
                    Address = "Metro Manila"
                };

                await employeeService.CreateEmployeeAndReturnAsync(employee);
            }
        }
    }
}
