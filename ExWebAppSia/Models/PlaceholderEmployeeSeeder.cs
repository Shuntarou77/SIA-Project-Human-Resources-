using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public static class PlaceholderEmployeeSeeder
    {
        private static readonly string[] Departments = new[]
        {
            "Research & Development",
            "Quality Control",
            "Human Resources",
            "Finance",
            "Marketing",
            "IT Support",
            "Operations",
            "Sales",
            "Legal",
            "Customer Service"
        };

        private static readonly Dictionary<string, string> DepartmentRoles = new Dictionary<string, string>
        {
            { "Research & Development", "Research Scientist" },
            { "Quality Control", "QA Analyst" },
            { "Human Resources", "HR Generalist" },
            { "Finance", "Accountant" },
            { "Marketing", "Marketing Associate" },
            { "IT Support", "IT Specialist" },
            { "Operations", "Operations Coordinator" },
            { "Sales", "Sales Representative" },
            { "Legal", "Legal Assistant" },
            { "Customer Service", "Support Representative" }
        };

        private static readonly string[] FirstNames = new[]
        {
            "James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda", "David", "Elizabeth",
            "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen",
            "Christopher", "Nancy", "Daniel", "Lisa", "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra",
            "Donald", "Ashley", "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle",
            "Kenneth", "Dorothy", "Kevin", "Carol", "Brian", "Amanda", "George", "Melissa", "Timothy", "Deborah",
            "Ronald", "Stephanie", "Edward", "Rebecca", "Jason", "Sharon", "Jeffrey", "Laura", "Ryan", "Cynthia",
            "Jacob", "Kathleen", "Gary", "Amy", "Nicholas", "Shirley", "Eric", "Angela", "Jonathan", "Helen",
            "Stephen", "Anna", "Larry", "Brenda", "Justin", "Pamela", "Scott", "Nicole", "Brandon", "Emma",
            "Benjamin", "Samantha", "Samuel", "Katherine", "Gregory", "Christine", "Alexander", "Debra", "Frank", "Rachel",
            "Patrick", "Carolyn", "Raymond", "Janet", "Jack", "Catherine", "Dennis", "Maria", "Jerry", "Heather"
        };

        private static readonly string[] LastNames = new[]
        {
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
            "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
            "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
            "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
            "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts",
            "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes",
            "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper",
            "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson",
            "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza", "Ruiz", "Hughes",
            "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers", "Long", "Ross", "Foster", "Jimenez"
        };

        public static async Task SeedPlaceholderEmployeesAsync()
        {
            try
            {
                var employeeService = new EmployeeService();
                var userService = new UserService();
                
                // Get all existing employees to avoid duplicates (by email)
                var existingEmployees = await employeeService.GetAllEmployeesAsync();
                var existingEmails = new HashSet<string>(existingEmployees.Select(e => e.Email.ToLower()), StringComparer.OrdinalIgnoreCase);

                int employeesAdded = 0;
                int nameIndex = 0;

                foreach (var dept in Departments)
                {
                    int countForDept = 0;
                    
                    // Check how many we already have for this dept
                    int currentCount = existingEmployees.Count(e => e.Department == dept);
                    
                    while (countForDept < 10)
                    {
                        string firstName = FirstNames[nameIndex % FirstNames.Length];
                        string lastName = LastNames[nameIndex % LastNames.Length];
                        string email = $"{firstName.ToLower()}.{lastName.ToLower()}.{countForDept}@{dept.Replace("&", "and").Replace(" ", "").ToLower()}.shessentials.com";
                        
                        if (!existingEmails.Contains(email))
                        {
                            var emp = new Employee
                            {
                                FirstName = firstName,
                                LastName = lastName,
                                Email = email,
                                Department = dept,
                                Role = DepartmentRoles[dept],
                                ContactNo = $"+63 9{100000000 + nameIndex}",
                                Address = $"Placeholder St, {dept} District",
                                Age = 20 + (nameIndex % 40),
                                BirthDate = DateTime.UtcNow.AddYears(-(20 + (nameIndex % 40))),
                                Gender = (nameIndex % 2 == 0) ? "Male" : "Female",
                                ContractType = "Regular",
                                IsActive = true,
                                HiredDate = DateTime.UtcNow.AddMonths(-(nameIndex % 24))
                            };

                            var createdEmp = await employeeService.CreateEmployeeAndReturnAsync(emp);
                            if (createdEmp != null)
                            {
                                // Ensure user account is created
                                await userService.EnsureEmployeeAccountAsync(
                                    createdEmp.Email,
                                    createdEmp.EmployeeId,
                                    createdEmp.FirstName,
                                    createdEmp.LastName,
                                    null,
                                    createdEmp.Department,
                                    createdEmp.Role);
                                
                                existingEmails.Add(email);
                                employeesAdded++;
                                countForDept++;
                            }
                        }
                        
                        nameIndex++;
                        if (nameIndex > 1000) break; // Safety break
                    }
                }

                System.Diagnostics.Debug.WriteLine($"✅ Seeded {employeesAdded} placeholder employees.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error seeding placeholder employees: {ex.Message}");
            }
        }
    }
}
