using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.LoginFolder
{
    public partial class Login : System.Web.UI.Page
    {
        // Change from field initialization to properties with lazy loading
        private UserService _userService;
        private UserService UserServiceInstance
        {
            get
            {
                if (_userService == null)
                {
                    try
                    {
                        _userService = new UserService();
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Failed to initialize UserService: {ex.Message}");
                        ShowError("Database connection error. Please contact your administrator.");
                        throw;
                    }
                }
                return _userService;
            }
        }

        private EmployeeService _employeeService;
        private EmployeeService EmployeeServiceInstance
        {
            get
            {
                if (_employeeService == null)
                {
                    _employeeService = new EmployeeService();
                }
                return _employeeService;
            }
        }

        private ManagerService _managerService;
        private ManagerService ManagerServiceInstance
        {
            get
            {
                if (_managerService == null)
                {
                    _managerService = new ManagerService();
                }
                return _managerService;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Clear any existing sessions
                Session.Clear();

                // Hide error message on initial load
                errorMessage.Visible = false;

                // Handle Remember Me - Load from cookie if exists
                if (Request.Cookies["HRSystemUser"] != null)
                {
                    txtUsername.Text = Request.Cookies["HRSystemUser"]["Username"];
                    chkRememberMe.Checked = true;
                }

                // Initialize database with default users (only run once)
                RegisterAsyncTask(new PageAsyncTask(InitializeDefaultUsers));
            }
        }

        protected async void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Validate input
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter both username and password.");
                return;
            }

            // Quick path for default test accounts (no DB call)
            if (TryHandleDefaultLogin(username, password))
            {
                return;
            }

            try
            {
                // Debug logging
                System.Diagnostics.Debug.WriteLine($"=== Login Attempt ===");
                System.Diagnostics.Debug.WriteLine($"Username: '{username}'");
                System.Diagnostics.Debug.WriteLine($"Password Length: {password?.Length ?? 0}");

                // Authenticate user with MongoDB
                var user = await UserServiceInstance.AuthenticateUserAsync(username, password);

                if (user != null)
                {
                    // Debug: Show what we're storing in session
                    System.Diagnostics.Debug.WriteLine($"User authenticated: {user.Username}, Role: {user.Role}");

                    // Create session
                    Session["Username"] = user.Username;
                    Session["Role"] = user.Role;
                    Session["UserId"] = user.Id;
                    Session["IsLoggedIn"] = true;

                    // Load employee data for ALL roles if an EmployeeId or Email link exists
                    try
                    {
                        Employee employee = null;
                        if (!string.IsNullOrEmpty(user.EmployeeId))
                        {
                            employee = await EmployeeServiceInstance.GetEmployeeByIdAsync(user.EmployeeId);
                        }
                        
                        // Fallback to email if not found by ID
                        if (employee == null)
                        {
                            employee = await EmployeeServiceInstance.GetEmployeeByEmailAsync(user.Username);
                        }

                        if (employee != null)
                        {
                            Session["Employee"] = employee;
                        }

                        if (employee != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"Employee data loaded into session: {employee.EmployeeId} - {employee.FullName}");
                        }
                        else if (user.Role == "Employee" || user.Role == "President")
                        {
                            // Strictly required for these roles
                            System.Diagnostics.Debug.WriteLine($"Error: Required employee data missing for {user.Role}");
                            ShowError("Employee record not found. Please contact HR.");
                            return;
                        }

                        // Load specialized Manager data if applicable
                        if (user.Role == "Manager")
                        {
                            var managerService = new ManagerService();
                            Manager manager = null;

                            // 1. Try finding by ManagerId if it exists in the User record
                            if (!string.IsNullOrEmpty(user.ManagerId))
                            {
                                manager = await managerService.GetManagerByManagerIdAsync(user.ManagerId);
                            }

                            // 2. Fallback to Email search (most common)
                            if (manager == null && !string.IsNullOrEmpty(user.Email))
                            {
                                manager = await managerService.GetManagerByEmailAsync(user.Email);
                            }

                            // 3. Last resort: try searching by Username (if username is an email)
                            if (manager == null && user.Username.Contains("@"))
                            {
                                manager = await managerService.GetManagerByEmailAsync(user.Username);
                            }

                            if (manager != null)
                            {
                                Session["Manager"] = manager;
                                System.Diagnostics.Debug.WriteLine($"Manager session initialized for: {manager.FullName} (Dept: {manager.Department})");
                                
                                // Also ensure they have an Employee session object if they don't yet
                                if (Session["Employee"] == null)
                                {
                                    // Try to load as employee using their email
                                    var employeeData = await EmployeeServiceInstance.GetEmployeeByEmailAsync(manager.Email);
                                    if (employeeData != null)
                                    {
                                        Session["Employee"] = employeeData;
                                    }
                                    else
                                    {
                                        // Fallback: Create a temporary Employee object from Manager data
                                        // so the EmployeeViewpoint pages don't crash and show their info correctly
                                        Session["Employee"] = new Employee
                                        {
                                            EmployeeId = manager.ManagerId,
                                            FirstName = manager.FirstName,
                                            LastName = manager.LastName,
                                            MiddleName = manager.MiddleName,
                                            Email = manager.Email,
                                            Department = manager.Department,
                                            Role = manager.Role,
                                            ContactNo = manager.ContactNo,
                                            Address = manager.Address,
                                            HiredDate = manager.HiredDate,
                                            ContractType = manager.ContractType,
                                            IsActive = manager.IsActive
                                        };
                                        System.Diagnostics.Debug.WriteLine($"Created temporary Employee session for Manager: {manager.ManagerId}");
                                    }
                                }
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine($"Warning: User has role 'Manager' but no record found in Manager collection for {user.Username}");
                            }
                        }
                    }
                    catch (Exception empEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error loading employee data: {empEx.Message}");
                        if (user.Role == "Employee" || user.Role == "President")
                        {
                            ShowError("Error loading employee information. Please try again.");
                            return;
                        }
                    }

                    // Debug: Verify session values
                    System.Diagnostics.Debug.WriteLine($"Session stored - Username: {Session["Username"]}, Role: {Session["Role"]}, IsLoggedIn: {Session["IsLoggedIn"]}");

                    // Handle Remember Me
                    if (chkRememberMe.Checked)
                    {
                        HttpCookie userCookie = new HttpCookie("HRSystemUser");
                        userCookie["Username"] = user.Username;
                        userCookie["Role"] = user.Role;
                        userCookie.Expires = DateTime.Now.AddDays(30);
                        Response.Cookies.Add(userCookie);
                    }
                    else
                    {
                        // Clear cookie if unchecked
                        if (Request.Cookies["HRSystemUser"] != null)
                        {
                            HttpCookie userCookie = new HttpCookie("HRSystemUser");
                            userCookie.Expires = DateTime.Now.AddDays(-1);
                            Response.Cookies.Add(userCookie);
                        }
                    }

                    // Redirect based on role
                    if (user.Role == "Super Admin")
                    {
                        Response.Redirect("~/webpage(SuperAdminViewpoint)/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Admin" || user.Role.Contains("Admin") || user.Role == "HR")
                    {
                        Response.Redirect("~/webpage/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Employee")
                    {
                        var employee = Session["Employee"] as Employee;
                        if (employee != null && employee.Department == "Human Resources")
                        {
                            Response.Redirect("~/webpage/Dashboard.aspx", false);
                        }
                        else
                        {
                            Response.Redirect("~/webpage(EmployeeViewpoint)/Dashboard.aspx", false);
                        }
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "President")
                    {
                        Response.Redirect("~/webpage(PresidentViewpoint)/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Manager")
                    {
                        var manager = Session["Manager"] as Manager;
                        var employee = Session["Employee"] as Employee;
                        
                        // Check if they belong to Human Resources (e.g., Payroll Manager)
                        bool isHRManager = (manager != null && manager.Department == "Human Resources") || 
                                           (employee != null && employee.Department == "Human Resources");
                                           
                        if (isHRManager)
                        {
                            // HR Managers (including Payroll Manager) get the HR Staff / Admin interface
                            Response.Redirect("~/webpage/Dashboard.aspx", false);
                        }
                        else
                        {
                            // Other Managers use the same interface as employees
                            Response.Redirect("~/webpage(EmployeeViewpoint)/Dashboard.aspx", false);
                        }
                        Context.ApplicationInstance.CompleteRequest();
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"Authentication failed for username: '{username}'");
                    ShowError("Invalid username or password. Please try again.");
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred during login. Please try again.");
                System.Diagnostics.Debug.WriteLine($"Login error: {ex.Message}");
            }
        }

        private async Task InitializeDefaultUsers()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("✅ System users and employees already seeded.");
                System.Diagnostics.Debug.WriteLine("ℹ️  New accounts will be created via Recruitment page (Hire workflow)");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error initializing default users: {ex.Message}");
            }
        }

        private void ShowError(string message)
        {
            litError.Text = message;
            errorMessage.Visible = true;
            errorMessage.Attributes["class"] = "error-message show";
        }

        private bool TryHandleDefaultLogin(string username, string password)
        {
            var testAccounts = new[]
            {
                new { Username = "admin2",   Password = "admin234",  Role = "Admin",    Redirect = "~/webpage/Dashboard.aspx" },
                new { Username = "employee",   Password = "emp123",  Role = "Employee",    Redirect = "~/webpage(EmployeeViewpoint)/Dashboard.aspx" },
                new { Username = "superadmin",   Password = "superadmin123",  Role = "Super Admin",    Redirect = "~/webpage(SuperAdminViewpoint)/Dashboard.aspx" }
            };

            foreach (var acct in testAccounts)
          {
if (string.Equals(username, acct.Username, StringComparison.OrdinalIgnoreCase) &&
    string.Equals(password, acct.Password, StringComparison.Ordinal))
   {
       Session["Username"] = acct.Username;
   Session["Role"] = acct.Role;
              Session["IsLoggedIn"] = true;

          Response.Redirect(acct.Redirect, false);
     Context.ApplicationInstance.CompleteRequest();
           return true;
      }
            }

   return false;
        }
    }
}