using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExWebAppSia.Models;

namespace ExWebAppSia.Models
{
    public static class FullDatabaseSeeder
    {
        private static readonly Random _random = new Random();

        public static async Task ResetAndSeedDatabaseAsync()
        {
            var db = MongoDBHelper.GetDatabase();

            // Clear collections
            await db.DropCollectionAsync("Employees");
            await db.DropCollectionAsync("Users");
            await db.DropCollectionAsync("Applicants");
            await db.DropCollectionAsync("Managers");
            await db.DropCollectionAsync("ResignedEmployees");

            // Seed Employees and Users
            var employees = GetNewEmployeeData();
            var employeeCollection = MongoDBHelper.GetEmployeesCollection();
            var userCollection = MongoDBHelper.GetUsersCollection();
            var applicantCollection = MongoDBHelper.GetApplicantsCollection();

            foreach (var empData in employees)
            {
                // 1. Create Applicant Record
                var applicant = new Applicant
                {
                    FirstName = empData.FirstName,
                    LastName = empData.LastName,
                    Email = empData.Email,
                    Gender = empData.Gender,
                    CivilStatus = empData.CivilStatus ?? "Single",
                    AppliedPosition = empData.Department,
                    Role = empData.Role,
                    Status = "Hired",
                    StartingSalary = empData.BaseSalary,
                    ContractType = "Regular",
                    ApprovedDate = DateTime.UtcNow.AddMonths(-6), // Hired 6 months ago to be regular
                    AppliedDate = DateTime.UtcNow.AddMonths(-7),
                    IsActive = true
                };

                // Add random experience for seniors/managers
                if (NeedsExperience(empData.Role))
                {
                    applicant.HasPreviousCompany = true;
                    applicant.PreviousCompanyName = GetRandomCompany();
                    applicant.PreviousPosition = "Junior " + empData.Role;
                    applicant.Years = _random.Next(2, 6);
                }

                await applicantCollection.InsertOneAsync(applicant);

                // 2. Create Employee Record
                var employee = new Employee
                {
                    EmployeeId = empData.EmployeeId,
                    FirstName = empData.FirstName,
                    MiddleName = empData.MiddleName,
                    LastName = empData.LastName,
                    Email = empData.Email,
                    Department = empData.Department,
                    Role = empData.Role,
                    Position = empData.Role,
                    ContractType = "Regular",
                    HiredDate = DateTime.UtcNow.AddMonths(-6),
                    BaseSalary = empData.BaseSalary,
                    IsActive = true,
                    ApplicantId = applicant.Id,
                    Gender = empData.Gender,
                    CivilStatus = empData.CivilStatus ?? "Single",
                    BirthDate = TryParseDate(empData.BirthDate),
                    ContactNo = "09" + _random.Next(100000000, 999999999).ToString(),
                    Address = empData.Address ?? "Metro Manila",
                    EducationLevel = empData.EducationLevel,
                    School = empData.School,
                    Degree = empData.Degree,
                    GuardianName = empData.GuardianName,
                    GuardianRelationship = empData.GuardianRelationship,
                    GuardianContactNo = empData.GuardianContactNo,
                    GuardianEmail = empData.GuardianEmail,
                    GuardianHomeAddress = empData.GuardianHomeAddress,
                    PreviousCompanyName = empData.PreviousCompanyName,
                    PreviousPosition = empData.PreviousPosition,
                    YearsOfExperience = empData.YearsOfExperience
                };
                await employeeCollection.InsertOneAsync(employee);

                // 3. Create User Record
                string userRole = (empData.Role == "President" || empData.Role == "Chief Executive Officer") ? "President" : 
                                 (empData.EmployeeId == "SHE-001" ? "Super Admin" : 
                                 (empData.Role.Contains("Manager") || empData.Role.Contains("Lead") ? "Manager" : "Employee"));

                var user = new User
                {
                    Username = empData.Email,
                    Password = PasswordHelper.HashPasswordComplete(empData.EmployeeId),
                    Role = userRole,
                    Email = empData.Email,
                    EmployeeId = empData.EmployeeId,
                    FirstName = empData.FirstName,
                    LastName = empData.LastName,
                    IsActive = true,
                    Department = empData.Department,
                    Position = empData.Role,
                    ContractType = "Regular"
                };
                await userCollection.InsertOneAsync(user);
            }

            // Seed Vacancies
            await applicantCollection.InsertOneAsync(new Applicant
            {
                AppliedPosition = "Operations",
                Role = "Fulfillment & Logistics Coordinator",
                Status = "Pooling",
                IsActive = true,
                RecruitmentType = "New Applicant"
            });

            await applicantCollection.InsertOneAsync(new Applicant
            {
                AppliedPosition = "Operations", // QC is under Operations based on user prompt
                Role = "Product Quality Inspector",
                Status = "Pooling",
                IsActive = true,
                RecruitmentType = "New Applicant"
            });
        }

        private static bool NeedsExperience(string role)
        {
            role = role.ToLower();
            return role.Contains("manager") || role.Contains("lead") || role.Contains("senior") || role.Contains("administrator") || role.Contains("president");
        }

        private static DateTime? TryParseDate(string dateStr)
        {
            if (string.IsNullOrEmpty(dateStr)) return null;
            if (DateTime.TryParse(dateStr, out DateTime dt)) return dt;
            return null;
        }

        private static string GetRandomCompany()
        {
            string[] companies = { "Apex Corp", "Zenith Solutions", "Global Tech", "Innovate Inc", "Summit Industries" };
            return companies[_random.Next(companies.Length)];
        }

        private static List<EmployeeData> GetNewEmployeeData()
        {
            return new List<EmployeeData>
            {
                new EmployeeData { 
                    EmployeeId = "SHE-001", 
                    LastName = "Peregrino", 
                    FirstName = "Princess Mae", 
                    MiddleName = "Salimbo", 
                    Role = "HR Manager", 
                    Department = "Human Resources", 
                    Email = "princessm.peregrino@gmail.com", 
                    BaseSalary = 31000, 
                    Gender = "Female", 
                    BirthDate = "05/01/2005", 
                    Address = "35 Villareal Street, Brgy. Gulod, Novaliches, Quezon City", 
                    CivilStatus = "Single",
                    EducationLevel = "College Undergraduate",
                    School = "Quezon City University",
                    Degree = "Bachelor of Science in Information Technology",
                    GuardianName = "Desiree S. Peregrino",
                    GuardianRelationship = "Mother",
                    GuardianContactNo = "9777647094",
                    GuardianHomeAddress = "35 Villareal Street, Brgy. Gulod, Novaliches, Quezon City"
                },
                new EmployeeData { EmployeeId = "SHE-002", LastName = "Baliong", FirstName = "Baliong", MiddleName = "Onod", Role = "HR Generalist", Department = "Human Resources", Email = "baliong.baliong@shessentials.com", BaseSalary = 21000, Gender = "Male", BirthDate = "03/25/2002", Address = "38 Antique Street, Bago Bantay", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-003", LastName = "Loreno", FirstName = "Jhonrey", Role = "Recruitment Specialist", Department = "Human Resources", Email = "jhonrey.loreno77@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "01/01/2000", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-004", LastName = "Paraiso", FirstName = "Mary Faye", MiddleName = "Carag", Role = "Payroll Manager", Department = "Human Resources", Email = "paraiso.maryfaye.carag@gmail.com", BaseSalary = 31000, Gender = "Female", BirthDate = "12/04/2005", Address = "155 Nenita Ext. Gulod Novaliches", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-005", LastName = "Torio", FirstName = "Lord Vincent", MiddleName = "Robosa", Role = "Payroll Specialist", Department = "Human Resources", Email = "vincenttorio262@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "09/10/2002", Address = "#35 Iriga st Bai Comp Vasra Qc", CivilStatus = "Single" },
                
                new EmployeeData { EmployeeId = "SHE-006", LastName = "Domer", FirstName = "Ryan", MiddleName = "Cepeda", Role = "Operations Manager", Department = "Operations", Email = "ryandomer566@gmail.com", BaseSalary = 40000, Gender = "Male", BirthDate = "05/31/2005", Address = "Blk 2 Lot 8 Narra St. Bagbag Bemarty", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-008", LastName = "Salangsang", FirstName = "Andrew Jeremiah", MiddleName = "Castro", Role = "Order Processing Specialist", Department = "Operations", Email = "salangsang.andrewjeremiah.castro@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "10/10/2004", Address = "Jaguar St. West Fairview, Q.C.", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-009", LastName = "Gepollo", FirstName = "Ashley Kate", MiddleName = "Reyes", Role = "Supply Chain Coordinator", Department = "Operations", Email = "gepollo.ashleykate.reyes@gmail.com", BaseSalary = 20000, Gender = "Female", BirthDate = "11/12/2004", Address = "L1 BLK2 Castro St. Pamana Ville Sta. Rosa", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-010", LastName = "Oracion", FirstName = "Dan Jerciey", MiddleName = "Sto Tomas", Role = "Quality Control Manager", Department = "Operations", Email = "oracion.danjerciey.stotomas@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "11/15/2004", Address = "335 General Francisco Street Bagong", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-012", LastName = "Reyes", FirstName = "Jundill Mhar", MiddleName = "Calagahan", Role = "IT Systems Administrator", Department = "Operations", Email = "jundillmharreyes@gmail.com", BaseSalary = 29000, Gender = "Male", BirthDate = "11/30/2004", Address = "Project 8, Bahay Toro, Quezon City", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-013", LastName = "Quimiguing", FirstName = "Emilou", MiddleName = "Paclibar", Role = "E-Commerce Tech Support Specialist", Department = "Operations", Email = "emilouemilou88@gmail.com", BaseSalary = 21000, Gender = "Female", BirthDate = "09/04/2005", Address = "5 rainbow st., Odelco Subd., San Bart.", CivilStatus = "Single" },
                
                new EmployeeData { EmployeeId = "SHE-014", LastName = "Malenab", FirstName = "Sherwin", MiddleName = "Gumiran", Role = "Digital Marketing Manager", Department = "Marketing", Email = "sherwinmalenab04@gmail.com", BaseSalary = 34000, Gender = "Male", BirthDate = "03/04/2004", Address = "L15 B42 Unit 6 Opel St. Fairview Quezon", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-015", LastName = "Yulo", FirstName = "Lairene", MiddleName = "Benosa", Role = "Social Media & Content Specialist", Department = "Marketing", Email = "yulo.lairene@shessentials.com", BaseSalary = 20000, Gender = "Female", BirthDate = "08/06/2004", Address = "70 sta.isabel st. Gulod Novaliches Quezon", CivilStatus = "Married" },
                new EmployeeData { EmployeeId = "SHE-016", LastName = "Aguinaldo", FirstName = "Patricia", MiddleName = "Armamento", Role = "Sales Manager", Department = "Marketing", Email = "ptrcgnld@gmail.com", BaseSalary = 34000, Gender = "Female", BirthDate = "11/07/2002", Address = "Blk 2 Lot 20 Gilian Hills Subd., Llano", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-017", LastName = "Mantal", FirstName = "Rea Mary", MiddleName = "Tumadlas", Role = "Online Sales Specialist", Department = "Marketing", Email = "mantal.reamary.tumadlas@gmail.com", BaseSalary = 20000, Gender = "Female", BirthDate = "02/14/2005", Address = "Payatas B, Lupang Pangako, Quezon", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-018", LastName = "Gadon", FirstName = "Ermalyn", MiddleName = "Ramoya", Role = "Beauty Brand Partnership Associate", Department = "Marketing", Email = "gadon.ermalyn.ramoya@gmail.com", BaseSalary = 20000, Gender = "Female", BirthDate = "01/04/2005", Address = "19 East Don Enrique, Nagkaisang Nay", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-019", LastName = "Tan", FirstName = "Maria", MiddleName = "Raye", Role = "Customer Service Team Lead", Department = "Marketing", Email = "tan.mariaraye@shessentials.com", BaseSalary = 25000, Gender = "Female", BirthDate = "09/07/2004", Address = "210 Interior 2 Fatima II Pook dagohoy", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-020", LastName = "Escandor", FirstName = "Crezel Ann", MiddleName = "Marmol", Role = "Customer Support Representative", Department = "Marketing", Email = "escandorcrezelann@gmail.com", BaseSalary = 19000, Gender = "Female", BirthDate = "08/17/2005", Address = "9 Sagittarius St., Solville Subd., Talipapa", CivilStatus = "Single" },
                
                new EmployeeData { EmployeeId = "SHE-021", LastName = "Aparri", FirstName = "Liezette", Role = "Finance Manager", Department = "Finance/Accounting", Email = "aparri.liezette@shessentials.com", BaseSalary = 38000, Gender = "Female", BirthDate = "01/01/1990", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-022", LastName = "Cabral", FirstName = "Leonard", MiddleName = "Santua", Role = "Senior Accountant", Department = "Finance/Accounting", Email = "cabsleo889@gmail.com", BaseSalary = 29000, Gender = "Male", BirthDate = "01/01/1995", Address = "blk 43 lot 16 sorrento village, Barangay", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-023", LastName = "Canale", FirstName = "Avan Haile", MiddleName = "Sol Cruz", Role = "Accounts Payable Specialist", Department = "Finance/Accounting", Email = "ayancanale@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "10/29/2002", Address = "168 Ross st Area9B Brgy Pasong Tamo", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-024", LastName = "Algeria", FirstName = "Rheyven", Role = "Accounts Receivable Specialist", Department = "Finance/Accounting", Email = "algeria.rheyven.delarosa@gmail.com", BaseSalary = 20000, Gender = "Male", BirthDate = "01/01/1998", Address = "Metro Manila", CivilStatus = "Single" },
                
                new EmployeeData { EmployeeId = "SHE-025", LastName = "Dela Cruz", FirstName = "Onesimus", Role = "Inventory Manager", Department = "Inventory", Email = "delacruzonesimuspalles@gmail.com", BaseSalary = 29000, Gender = "Male", BirthDate = "01/01/1992", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-026", LastName = "Seriosa", FirstName = "Willowby Rinoa", Role = "Inventory Control Specialist", Department = "Inventory", Email = "seriosa.willowbyrinoa.delosreyes@gmail.com", BaseSalary = 20000, Gender = "Female", BirthDate = "01/01/1999", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-027", LastName = "Dapon", FirstName = "John Mark", Role = "Warehouse & Stock Associate", Department = "Inventory", Email = "daponjohnmarklaunio@gmail.com", BaseSalary = 19000, Gender = "Male", BirthDate = "01/01/2001", Address = "Metro Manila", CivilStatus = "Single" },
                
                new EmployeeData { EmployeeId = "SHE-028", LastName = "Cablayan", FirstName = "Coleen", Role = "R&D Manager", Department = "R&D", Email = "cablayan.coleen.fababeir@gmail.com", BaseSalary = 38000, Gender = "Female", BirthDate = "01/01/1990", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-029", LastName = "Villacrucis", FirstName = "Danna", Role = "Cosmetic Formulation Specialist", Department = "R&D", Email = "villacrucis.danna@shessentials.com", BaseSalary = 25000, Gender = "Female", BirthDate = "01/01/1998", Address = "Metro Manila", CivilStatus = "Single" },
                new EmployeeData { EmployeeId = "SHE-030", LastName = "Alcaide", FirstName = "Franc Sant", Role = "Product Development & Testing Associate", Department = "R&D", Email = "alcaide.franc@shessentials.com", BaseSalary = 20000, Gender = "Male", BirthDate = "01/01/2000", Address = "Metro Manila", CivilStatus = "Single" },
                
                new EmployeeData { 
                    EmployeeId = "SHE-031", 
                    LastName = "Tulba", 
                    FirstName = "MIkylla", 
                    Role = "President", 
                    Department = "Executive", 
                    Email = "mikyllapodiotan@gmail.com", 
                    BaseSalary = 45000, 
                    Gender = "Female", 
                    BirthDate = "04/10/2005", 
                    Address = "D-1-3 Bistekville 12 Pasacola, Nagkaisang Nayon, Novaliches, Quezon City", 
                    CivilStatus = "Single",
                    EducationLevel = "College Undergraduate",
                    School = "Quezon City University",
                    Degree = "BSIT",
                    GuardianName = "Arlene Podiotan",
                    GuardianRelationship = "Mother",
                    GuardianContactNo = "9777632356",
                    GuardianHomeAddress = "D-1-3 Bistekville 12 Pasacola, Nagkaisang Nayon, Novaliches, Quezon City"
                }
            };
        }

        private class EmployeeData
        {
            public string EmployeeId { get; set; }
            public string FirstName { get; set; }
            public string MiddleName { get; set; }
            public string LastName { get; set; }
            public string Role { get; set; }
            public string Department { get; set; }
            public string Email { get; set; }
            public decimal BaseSalary { get; set; }
            public string Gender { get; set; }
            public string BirthDate { get; set; }
            public string Address { get; set; }
            public string CivilStatus { get; set; }
            public string EducationLevel { get; set; }
            public string School { get; set; }
            public string Degree { get; set; }
            public string GuardianName { get; set; }
            public string GuardianRelationship { get; set; }
            public string GuardianContactNo { get; set; }
            public string GuardianEmail { get; set; }
            public string GuardianHomeAddress { get; set; }
            public string PreviousCompanyName { get; set; }
            public string PreviousPosition { get; set; }
            public int YearsOfExperience { get; set; }
        }
    }
}
