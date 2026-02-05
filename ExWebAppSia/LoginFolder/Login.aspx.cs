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

                    // Load employee data if role is Employee
                    if (user.Role == "Employee")
                    {
                        try
                        {
                            // Load employee data by email (username is the email)
                            var employee = await EmployeeServiceInstance.GetEmployeeByEmailAsync(user.Username);
                            if (employee != null)
                            {
                                Session["Employee"] = employee;
                                System.Diagnostics.Debug.WriteLine($"Employee data loaded: {employee.EmployeeId} - {employee.FullName}");
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine($"Error: No employee data in session, redirecting to login");
                                System.Diagnostics.Debug.WriteLine($"Could not find employee with email: {user.Username}");
                                ShowError("Employee record not found. Please contact HR.");
                                return;
                            }
                        }
                        catch (Exception empEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error loading employee data: {empEx.Message}");
                            ShowError("Error loading employee information. Please try again.");
                            return;
                        }
                    }
                    // Load manager data if role is Manager
                    else if (user.Role == "Manager")
                    {
                        try
                        {
                            // Load manager data by email (username is the email)
                            var manager = await ManagerServiceInstance.GetManagerByEmailAsync(user.Username);
                            if (manager != null)
                            {
                                Session["Manager"] = manager;
                                System.Diagnostics.Debug.WriteLine($"Manager data loaded: {manager.ManagerId} - {manager.FirstName} {manager.LastName}");
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine($"Warning: Could not find manager with email: {user.Username}");
                                // Don't block login, but log the warning
                            }
                        }
                        catch (Exception mgrEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error loading manager data: {mgrEx.Message}");
                            // Don't block login, but log the error
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

                    // Redirect based on role
                    if (user.Role == "Admin")
                    {
                        // was: Server.Transfer("~/webpage/Dashboard.aspx");
                        Response.Redirect("~/webpage/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Employee")
                    {
                        // was: Server.Transfer("~/webpage(EmployeeViewpoint)/Dashboard.aspx");
                        Response.Redirect("~/webpage(EmployeeViewpoint)/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Manager")
                    {
                        string managerDashboardPath = ResolveUrl("~/webpage(ManagerViewpoint/Dashboard.aspx");
                        Response.Redirect(managerDashboardPath, false);
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
                // Check if admin user exists
                var adminUser = await UserServiceInstance.GetUserByUsernameAsync("admin");
                if (adminUser == null)
                {
                    // Create default admin user (Admin role only - not Employee)
                    bool adminCreated = await UserServiceInstance.CreateUserAsync("admin", "admin123", "Admin", "admin@company.com");
                    System.Diagnostics.Debug.WriteLine($"Admin user created: {adminCreated}");
                }


                await DefaultManagerSeeder.EnsureDefaultManagersAsync();

                System.Diagnostics.Debug.WriteLine("✅ Default admin user initialized");
                System.Diagnostics.Debug.WriteLine("✅ Default managers ensured for every department");
                System.Diagnostics.Debug.WriteLine("ℹ️  Employee accounts should be created via Recruitment page (Hire workflow)");
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
      new { Username = "manager2", Password = "manager234", Role = "Manager", Redirect = "~/webpage(ManagerViewpoint)/Dashboard.aspx" }
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