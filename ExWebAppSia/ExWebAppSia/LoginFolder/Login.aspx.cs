using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using ExWebAppSia.Models;

namespace ExWebAppSia.LoginFolder
{
    public partial class Login : System.Web.UI.Page
    {
        private readonly UserService _userService = new UserService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Clear any existing sessions
                Session.Clear();

                // Hide error message on initial load
                errorMessage.Visible = false;

                // Only initialize default users if not already done (check application variable)
                // This prevents running on every page load
                if (Application["DefaultUsersInitialized"] == null)
                {
                    RegisterAsyncTask(new PageAsyncTask(async () =>
                    {
                        await InitializeDefaultUsers();
                        Application["DefaultUsersInitialized"] = true;
                    }));
                }
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

            try
            {
                // Debug logging
                System.Diagnostics.Debug.WriteLine($"=== Login Attempt ===");
                System.Diagnostics.Debug.WriteLine($"Username: '{username}'");
                System.Diagnostics.Debug.WriteLine($"Password Length: {password?.Length ?? 0}");

                // Authenticate user with MongoDB
                var user = await _userService.AuthenticateUserAsync(username, password);

                if (user != null)
                {
                    // Debug: Show what we're storing in session
                    System.Diagnostics.Debug.WriteLine($"User authenticated: {user.Username}, Role: {user.Role}");

                    // Create session
                    Session["Username"] = user.Username;
                    Session["Role"] = user.Role;
                    Session["UserId"] = user.Id;
                    Session["IsLoggedIn"] = true;

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
                        Response.Redirect("~/webpage/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Manager")
                    {
                        // Load manager data during login to avoid blocking in Master Page
                        try
                        {
                            var managerService = new ManagerService();
                            var manager = await managerService.GetManagerByEmailAsync(user.Username);
                            if (manager != null)
                            {
                                Session["ManagerId"] = manager.Id;
                                Session["Manager"] = manager;
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error loading manager data during login: {ex.Message}");
                        }
                        
                        Response.Redirect("~/webpage(ManagerViewpoint/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Employee")
                    {
                        // Load employee data during login to avoid blocking in Master Page
                        try
                        {
                            var employeeService = new EmployeeService();
                            var employee = await employeeService.GetEmployeeByEmailAsync(user.Username);
                            if (employee != null)
                            {
                                Session["EmployeeId"] = employee.Id;
                                Session["Employee"] = employee;
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error loading employee data during login: {ex.Message}");
                        }
                        
                        Response.Redirect("~/webpage(EmployeeViewpoint)/Dashboard.aspx", false);
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
                var adminUser = await _userService.GetUserByUsernameAsync("admin");
                if (adminUser == null)
                {
                    // Create default admin user
                    bool adminCreated = await _userService.CreateUserAsync("admin", "admin123", "Admin", "admin@company.com");
                    System.Diagnostics.Debug.WriteLine($"Admin user created: {adminCreated}");
                }

                // Check if employee user exists
                var employeeUser = await _userService.GetUserByUsernameAsync("employee");
                if (employeeUser == null)
                {
                    // Create default employee user
                    bool employeeCreated = await _userService.CreateUserAsync("employee", "emp123", "Employee", "employee@company.com");
                    System.Diagnostics.Debug.WriteLine($"Employee user created: {employeeCreated}");
                }
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
    }
}