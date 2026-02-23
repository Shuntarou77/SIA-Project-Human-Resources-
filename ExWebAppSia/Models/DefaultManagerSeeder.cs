using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    /// <summary>
    /// Creates default manager profiles (one per department) together with matching login accounts.
    /// This is intended to make the Manager dashboard immediately accessible in demo environments.
    /// </summary>
    public static class DefaultManagerSeeder
    {
        private class ManagerSeedInfo
        {
            public string Department { get; set; }
            public string FirstName { get; set; }
            public string MiddleName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
            public string Role { get; set; }
            public string ContactNo { get; set; }
            public string Address { get; set; }
            public string Password { get; set; }
        }

        private static readonly IList<ManagerSeedInfo> DefaultManagers = new List<ManagerSeedInfo>
        {
            new ManagerSeedInfo
            {
                Department = "Research & Development",
                FirstName = "CJ",
                MiddleName = "",
                LastName = "Junio",
                Email = "cj.junio@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0001",
                Address = "HQ - Innovation Wing",
                Password = "RNDManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Quality Control",
                FirstName = "Mara",
                MiddleName = "",
                LastName = "Santos",
                Email = "mara.santos@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0002",
                Address = "HQ - QC Lab",
                Password = "QCManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Human Resources",
                FirstName = "Ana",
                MiddleName = "",
                LastName = "Reyes",
                Email = "ana.reyes@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0003",
                Address = "HQ - HR Suite",
                Password = "HRManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Finance",
                FirstName = "Leo",
                MiddleName = "",
                LastName = "Cruz",
                Email = "leo.cruz@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0004",
                Address = "HQ - Finance Floor",
                Password = "FinanceManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Marketing",
                FirstName = "Tina",
                MiddleName = "",
                LastName = "Gomez",
                Email = "tina.gomez@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0005",
                Address = "HQ - Marketing Hub",
                Password = "MarketingManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "IT Support",
                FirstName = "Ben",
                MiddleName = "",
                LastName = "Lim",
                Email = "ben.lim@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0006",
                Address = "HQ - IT Ops",
                Password = "ITManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Operations",
                FirstName = "Dave",
                MiddleName = "",
                LastName = "Tan",
                Email = "dave.tan@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0007",
                Address = "HQ - Ops Center",
                Password = "OpsManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Sales",
                FirstName = "Carla",
                MiddleName = "",
                LastName = "Diaz",
                Email = "carla.diaz@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0008",
                Address = "HQ - Sales Suite",
                Password = "SalesManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Legal",
                FirstName = "Paul",
                MiddleName = "",
                LastName = "Ortega",
                Email = "paul.ortega@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0009",
                Address = "HQ - Legal Office",
                Password = "LegalManager@2025"
            },
            new ManagerSeedInfo
            {
                Department = "Customer Service",
                FirstName = "Joy",
                MiddleName = "",
                LastName = "Manalo",
                Email = "joy.manalo@shessentials.com",
                Role = "Department Manager",
                ContactNo = "+63 900 000 0010",
                Address = "HQ - Customer Care",
                Password = "CSManager@2025"
            }
        };

        public static async Task EnsureDefaultManagersAsync()
        {
            try
            {
                var managerService = new ManagerService();
                var userService = new UserService();

                foreach (var info in DefaultManagers)
                {
                    var manager = await managerService.GetManagerByEmailAsync(info.Email);
                    if (manager == null)
                    {
                        manager = await managerService.CreateManagerAndReturnAsync(new Manager
                        {
                            FirstName = info.FirstName,
                            MiddleName = info.MiddleName,
                            LastName = info.LastName,
                            Email = info.Email,
                            ContactNo = info.ContactNo,
                            Address = info.Address,
                            Department = info.Department,
                            Role = info.Role,
                            ContractType = "Regular",
                            IsActive = true
                        });
                        System.Diagnostics.Debug.WriteLine($"[ManagerSeeder] Created manager for {info.Department}: {info.Email}");
                    }
                    else
                    {
                        bool requiresUpdate =
                            !string.Equals(manager.Department ?? string.Empty, info.Department, StringComparison.OrdinalIgnoreCase) ||
                            !string.Equals(manager.Role ?? string.Empty, info.Role, StringComparison.OrdinalIgnoreCase);

                        if (requiresUpdate)
                        {
                            manager.Department = info.Department;
                            manager.Role = info.Role;
                            await managerService.UpdateManagerAsync(manager.Id, manager);
                            System.Diagnostics.Debug.WriteLine($"[ManagerSeeder] Updated manager record for {info.Email}");
                        }
                    }

                    await userService.EnsureAdminAccountAsync(
                        username: info.Email,
                        password: info.Password,
                        role: info.Department + " Admin",
                        email: info.Email,
                        firstName: info.FirstName,
                        lastName: info.LastName);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ManagerSeeder] Error ensuring managers: {ex.Message}");
            }
        }
    }
}

