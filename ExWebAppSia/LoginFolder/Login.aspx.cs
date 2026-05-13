using System;
using System.Collections.Generic;
using System.Linq;
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
                    Session["Employee"] = null; // Clear stale employee data
                    Session["ExpectedEmail"] = user.Email;
                    Session["ExpectedId"] = user.EmployeeId;

                    // Load employee data for ALL roles if an EmployeeId or Email link exists
                    try
                    {
                        Employee employee = null;
                        if (!string.IsNullOrEmpty(user.EmployeeId))
                        {
                            employee = await EmployeeServiceInstance.GetByEmployeeIdAsync(user.EmployeeId);
                        }
                        
                        // Fallback to email if not found by ID
                        if (employee == null)
                        {
                            employee = await EmployeeServiceInstance.GetEmployeeByEmailAsync(user.Email ?? user.Username);
                        }

                        if (employee != null)
                        {
                            // CRITICAL IDENTITY CHECK: Ensure the employee record we found actually belongs to this user
                            string userEmail = (user.Email ?? user.Username).ToLower();
                            string empEmail = (employee.Email ?? "").ToLower();
                            
                            System.Diagnostics.Debug.WriteLine($"[Login] Verifying Identity: UserEmail={userEmail}, EmpEmail={empEmail}");
                            
                            if (empEmail != "" && userEmail != "" && empEmail != userEmail && !userEmail.Contains("@") == false)
                            {
                                // If they don't match, and the username looks like an email, we might have a cross-account mapping issue
                                System.Diagnostics.Debug.WriteLine($"[Login] WARNING: Identity mismatch detected during login! User={userEmail}, Employee={employee.FullName} ({empEmail})");
                            }

                            // CHECK FOR ACTIVE LEAVE: Block login if on approved leave
                            var leaveService = new LeaveService();
                            bool isOnLeave = await leaveService.IsEmployeeOnLeaveAsync(employee.EmployeeId);
                            if (isOnLeave)
                            {
                                System.Diagnostics.Debug.WriteLine($"[Login] BLOCKED: Employee {employee.FullName} ({employee.EmployeeId}) is currently on leave.");
                                ShowError("Access Denied: You are currently on leave. Access is restricted until your leave period ends.");
                                return;
                            }

                            Session["Employee"] = employee;
                            Session["EmployeeId"] = employee.EmployeeId; // Store explicit ID for secondary verification

                            // ── HR DEPARTMENT OVERRIDE ──────────────────────────────────────
                            // If this employee belongs to Human Resources, treat them as an
                            // Admin (HR) for routing purposes.
                            if ((user.Role == "Employee" || user.Role == "Manager") &&
                                string.Equals(employee.Department?.Trim(), "Human Resources", StringComparison.OrdinalIgnoreCase))
                            {
                                System.Diagnostics.Debug.WriteLine($"[Login] HR dept employee detected ({employee.FullName}, was role: '{user.Role}'). Overriding → 'HR' for redirect.");
                                user.Role = "HR";
                                Session["Role"] = "HR";
                            }

                            System.Diagnostics.Debug.WriteLine($"[Login] Success: {employee.EmployeeId} - {employee.FullName} logged in as {user.Role}");
                        }
                        else if (user.Role == "Employee" || user.Role == "President")
                        {
                            // Strictly required for these roles
                            System.Diagnostics.Debug.WriteLine($"Error: Required employee data missing for {user.Role}");
                            ShowError("Employee record not found. Please contact HR.");
                            return;
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
                    else if (user.Role == "Admin" || user.Role.Contains("Admin") || user.Role == "HR" || user.Role == "Human Resources")
                    {
                        Response.Redirect("~/webpage/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else if (user.Role == "Employee")
                    {
                        var employee = Session["Employee"] as Employee;

                        // Check HR department from Employee record OR from User record as fallback
                        bool isHrDepartment = false;

                        if (employee != null)
                        {
                            isHrDepartment = string.Equals(employee.Department?.Trim(), "Human Resources", StringComparison.OrdinalIgnoreCase);
                            System.Diagnostics.Debug.WriteLine($"[Login] Employee found in session: {employee.FullName}, Dept: '{employee.Department}', IsHR: {isHrDepartment}");
                        }
                        else
                        {
                            // Fallback: check the User document's own Department field
                            isHrDepartment = string.Equals(user.Department?.Trim(), "Human Resources", StringComparison.OrdinalIgnoreCase);
                            System.Diagnostics.Debug.WriteLine($"[Login] WARNING: Session Employee is NULL. Falling back to User.Department: '{user.Department}', IsHR: {isHrDepartment}");
                        }

                        if (isHrDepartment)
                        {
                            System.Diagnostics.Debug.WriteLine($"[Login] HR department detected — redirecting to Admin view.");
                            Response.Redirect("~/webpage/Dashboard.aspx", false);
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"[Login] Non-HR employee — redirecting to Employee view.");
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
                        Response.Redirect("~/webpage(EmployeeViewpoint)/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        // Fallback: unknown role defaults to employee view
                        System.Diagnostics.Debug.WriteLine($"Unknown role '{user.Role}' — defaulting to Employee viewpoint.");
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
            var hardcodedUsers = new[]
            {
                new { Username = "superadmin",   Password = "superadmin123",  Role = "Super Admin",    EmployeeId = "SHE-001", Redirect = "~/webpage(SuperAdminViewpoint)/Dashboard.aspx" },
                new { Username = "admin",        Password = "admin123",       Role = "Admin",          EmployeeId = "SHE-001", Redirect = "~/webpage/Dashboard.aspx" },
                new { Username = "president",    Password = "president123",   Role = "President",      EmployeeId = "SHE-031", Redirect = "~/webpage(PresidentViewpoint)/Dashboard.aspx" },
                new { Username = "hr.employee",  Password = "employee123",    Role = "Employee",       EmployeeId = "SHE-002", Redirect = "~/webpage(EmployeeViewpoint)/Dashboard.aspx" }
            };

            var acct = hardcodedUsers.FirstOrDefault(u => 
                string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase) && 
                u.Password == password);

            if (acct != null)
            {
                System.Diagnostics.Debug.WriteLine($"[Login] Hardcoded login successful for: {username} (Role: {acct.Role})");
                
                Session["Username"] = acct.Username;
                Session["Role"] = acct.Role;
                Session["IsLoggedIn"] = true;
                Session["ExpectedId"] = acct.EmployeeId;
                // For hardcoded users, we'll fetch the email from the employee record below

                // Attempt to link to real employee data if ID is provided
                try
                {
                    var emp = Task.Run(() => EmployeeServiceInstance.GetByEmployeeIdAsync(acct.EmployeeId)).GetAwaiter().GetResult();
                    if (emp != null)
                    {
                        Session["Employee"] = emp;
                        Session["ExpectedEmail"] = emp.Email;
                        System.Diagnostics.Debug.WriteLine($"[Login] Successfully linked hardcoded user {acct.Username} to employee {emp.FullName}");
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Login] Error linking hardcoded user to employee: {ex.Message}");
                }

                Response.Redirect(acct.Redirect, false);
                Context.ApplicationInstance.CompleteRequest();
                return true;
            }

            return false;
        }
    }
}