using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class UserService
    {
        private readonly IMongoCollection<User> _users;

        public UserService()
        {
            _users = MongoDBHelper.GetUsersCollection();
        }

        // Create a new user
        public async Task<bool> CreateUserAsync(string username, string password, string role, string email = "")
        {
            try
            {
                // Check if user already exists
                var existingUser = await _users.Find(u => u.Username == username).FirstOrDefaultAsync();
                if (existingUser != null)
                {
                    return false; // User already exists
                }

                // Create new user
                var user = new User
                {
                    Username = username,
                    Password = PasswordHelper.HashPasswordComplete(password),
                    Role = role,
                    Email = email,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                await _users.InsertOneAsync(user);
                return true;
            }
            catch (Exception ex)
            {
                // Log the exception (you can add logging here)
                System.Diagnostics.Debug.WriteLine($"Error creating user: {ex.Message}");
                return false;
            }
        }

        // Authenticate user
        public async Task<User> AuthenticateUserAsync(string username, string password)
        {
            try
            {
                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    System.Diagnostics.Debug.WriteLine("AuthenticateUserAsync: Username or password is empty");
                    return null;
                }

                // Try case-sensitive match first
                var user = await _users.Find(u => u.Username == username && u.IsActive).FirstOrDefaultAsync();
                
                // If not found, try case-insensitive match (for email addresses)
                if (user == null)
                {
                    var allUsers = await _users.Find(u => u.IsActive).ToListAsync();
                    user = allUsers.FirstOrDefault(u => 
                        string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
                }

                if (user != null)
                {
                    System.Diagnostics.Debug.WriteLine($"User found: {user.Username}, Role: {user.Role}");
                    System.Diagnostics.Debug.WriteLine($"Stored password hash length: {user.Password?.Length ?? 0}");
                    System.Diagnostics.Debug.WriteLine($"Attempting to verify password: '{password}'");
                    
                    bool passwordValid = PasswordHelper.VerifyPasswordComplete(password, user.Password);
                    System.Diagnostics.Debug.WriteLine($"Password valid: {passwordValid}");
                    
                    if (passwordValid)
                    {
                        return user;
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Password verification failed");
                        // For Employee role, check if password matches current EmployeeId and update if needed
                        if (user.Role == "Employee")
                        {
                            try
                            {
                                var employeeService = new EmployeeService();
                                var employee = await employeeService.GetEmployeeByEmailAsync(user.Username);
                                if (employee != null)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Employee found - EmployeeId: '{employee.EmployeeId}'");
                                    System.Diagnostics.Debug.WriteLine($"Expected password (EmployeeId): '{employee.EmployeeId}'");
                                    System.Diagnostics.Debug.WriteLine($"Entered password: '{password}'");
                                    
                                    // If the entered password matches the EmployeeId, update the stored password
                                    if (string.Equals(password.Trim(), employee.EmployeeId?.Trim(), StringComparison.OrdinalIgnoreCase))
                                    {
                                        System.Diagnostics.Debug.WriteLine("Entered password matches EmployeeId - updating stored password hash");
                                        bool updated = await UpdatePasswordAsync(user.Username, employee.EmployeeId);
                                        if (updated)
                                        {
                                            System.Diagnostics.Debug.WriteLine("Password updated successfully - retrying authentication");
                                            // Get updated user with new password hash
                                            var updatedUser = await GetUserByUsernameAsync(username);
                                            if (updatedUser != null)
                                            {
                                                // Verify with the updated password hash
                                                passwordValid = PasswordHelper.VerifyPasswordComplete(employee.EmployeeId, updatedUser.Password);
                                                if (passwordValid)
                                                {
                                                    System.Diagnostics.Debug.WriteLine("Authentication successful after password update");
                                                    return updatedUser;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error getting employee info: {ex.Message}");
                            }
                        }
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"No user found with username: '{username}'");
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error authenticating user: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return null;
            }
        }

        // Get user by username
        public async Task<User> GetUserByUsernameAsync(string username)
        {
            try
            {
                if (string.IsNullOrEmpty(username))
                    return null;

                // Try case-sensitive match first
                var user = await _users.Find(u => u.Username == username).FirstOrDefaultAsync();
                
                // If not found, try case-insensitive match
                if (user == null)
                {
                    var allUsers = await _users.Find(u => true).ToListAsync();
                    user = allUsers.FirstOrDefault(u => 
                        string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
                }
                
                return user;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user: {ex.Message}");
                return null;
            }
        }

        // Update user password
        public async Task<bool> UpdatePasswordAsync(string username, string newPassword)
        {
            try
            {
                var filter = Builders<User>.Filter.Eq(u => u.Username, username);
                var update = Builders<User>.Update.Set(u => u.Password, PasswordHelper.HashPasswordComplete(newPassword));

                var result = await _users.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating password: {ex.Message}");
                return false;
            }
        }

        // Get all users (for admin purposes)
        public async Task<List<User>> GetAllUsersAsync()
        {
            try
            {
                return await _users.Find(u => u.IsActive).ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all users: {ex.Message}");
                return new List<User>();
            }
        }
    }
}