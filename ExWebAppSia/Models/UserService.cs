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
                    System.Diagnostics.Debug.WriteLine($"User already exists: {username}");
                    return false; // User already exists
                }

                // Create new user (LOGIN ACCOUNT ONLY - not full employee data)
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
                System.Diagnostics.Debug.WriteLine($"✓ User login account created: {username} (Role: {role})");
                return true;
            }
            catch (Exception ex)
            {
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
                    System.Diagnostics.Debug.WriteLine($"[UserService] Auth failed: Username or password null/empty");
                    return null;
                }

                // Try case-sensitive match first
                var user = await _users.Find(u => u.Username == username && u.IsActive).FirstOrDefaultAsync();
                
                // If not found, try case-insensitive match
                if (user == null)
                {
                    System.Diagnostics.Debug.WriteLine($"[UserService] User not found case-sensitive: {username}. Trying case-insensitive...");
                    var allUsers = await _users.Find(u => u.IsActive).ToListAsync();
                    user = allUsers.FirstOrDefault(u => 
                        string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
                }

                if (user != null)
                {
                    System.Diagnostics.Debug.WriteLine($"[UserService] User record found: {user.Username}, Role: {user.Role}, EmployeeId: {user.EmployeeId ?? "NULL"}, Active: {user.IsActive}");
                    System.Diagnostics.Debug.WriteLine($"[UserService] Stored password length: {user.Password?.Length ?? 0}, Content: {(user.Password?.Length > 3 ? user.Password.Substring(0, 3) : user.Password)}...");
                    System.Diagnostics.Debug.WriteLine($"[UserService] Entered password length: {password?.Length ?? 0}, Content: {(password?.Length > 3 ? password.Substring(0, 3) : password)}...");
                    
                    bool passwordValid = PasswordHelper.VerifyPasswordComplete(password, user.Password);
                    
                    // Plaintext fallback for legacy/unhashed accounts (e.g. random EMP-XXXX or EmployeeId)
                    if (!passwordValid)
                    {
                        // Check if password matches stored plaintext OR if it matches the Employee ID (recovery)
                        if (user.Password == password || (user.Role == "Employee" && !string.IsNullOrEmpty(user.EmployeeId) && password == user.EmployeeId))
                        {
                            System.Diagnostics.Debug.WriteLine($"[UserService] Plaintext/ID match found for {username} (Recovery/Legacy access)");
                            passwordValid = true;
                            
                            // Automatically upgrade to hashed password for future logins
                            var backgroundUpdate = Task.Run(async () => {
                                try {
                                    await UpdatePasswordAsync(user.Username, password);
                                    System.Diagnostics.Debug.WriteLine($"[UserService] Automatically upgraded password to hash for {username}");
                                } catch { }
                            });
                        }
                    }

                    if (passwordValid)
                    {
                        System.Diagnostics.Debug.WriteLine($"[UserService] Auth successful for: {username}");
                        return user;
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"[UserService] Password verification failed for: {username}");
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"[UserService] User record not found in database for: {username}");
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserService] [FATAL ERROR] authenticating user: {ex.Message}");
                if (ex.InnerException != null) System.Diagnostics.Debug.WriteLine($"[UserService] Inner error: {ex.InnerException.Message}");
                return null;
            }
        }

        // Get user by username
        public async Task<User> GetUserByUsernameAsync(string username)
        {
            try
            {
                if (string.IsNullOrEmpty(username)) return null;
                var user = await _users.Find(u => u.Username == username).FirstOrDefaultAsync();
                if (user == null)
                {
                    var allUsers = await _users.Find(u => true).ToListAsync();
                    user = allUsers.FirstOrDefault(u => string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
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

        public async Task<User> GetUserByEmailAsync(string email)
        {
            try
            {
                if (string.IsNullOrEmpty(email)) return null;
                return await _users.Find(u => u.Email == email && u.IsActive).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user by email: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UpdateResetTokenAsync(string email, string token, DateTime expiration)
        {
            try
            {
                var filter = Builders<User>.Filter.Eq(u => u.Email, email);
                var update = Builders<User>.Update
                    .Set(u => u.PasswordResetToken, token)
                    .Set(u => u.PasswordResetTokenExpiration, expiration);
                var result = await _users.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating reset token: {ex.Message}");
                return false;
            }
        }

        public async Task<User> GetUserByResetTokenAsync(string token)
        {
            try
            {
                if (string.IsNullOrEmpty(token)) return null;
                return await _users.Find(u => u.PasswordResetToken == token && u.PasswordResetTokenExpiration > DateTime.UtcNow).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user by reset token: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> ClearResetTokenAsync(string userId)
        {
            try
            {
                var filter = Builders<User>.Filter.Eq(u => u.Id, userId);
                var update = Builders<User>.Update
                    .Set(u => u.PasswordResetToken, (string)null)
                    .Set(u => u.PasswordResetTokenExpiration, (DateTime?)null);
                var result = await _users.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error clearing reset token: {ex.Message}");
                return false;
            }
        }

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

        public async Task EnsureManagerAccountAsync(
            string email,
            string password,
            string firstName,
            string middleName,
            string lastName,
            string department,
            string position,
            string managerId = null)
        {
            if (string.IsNullOrWhiteSpace(email)) throw new ArgumentException("Email is required.");
            var existingUser = await GetUserByUsernameAsync(email);
            var hashedPassword = PasswordHelper.HashPasswordComplete(password);

            if (existingUser == null)
            {
                var user = new User
                {
                    Username = email, Email = email, Password = hashedPassword, Role = "Manager",
                    FirstName = firstName, MiddleName = middleName, LastName = lastName,
                    Department = department, Position = position, ManagerId = managerId,
                    CreatedAt = DateTime.UtcNow, IsActive = true
                };
                await _users.InsertOneAsync(user);
            }
            else
            {
                var filter = Builders<User>.Filter.Eq(u => u.Id, existingUser.Id);
                var updates = Builders<User>.Update
                    .Set(u => u.Role, "Manager")
                    .Set(u => u.FirstName, firstName)
                    .Set(u => u.MiddleName, middleName)
                    .Set(u => u.LastName, lastName)
                    .Set(u => u.Department, department)
                    .Set(u => u.Position, position)
                    .Set(u => u.Email, email)
                    .Set(u => u.IsActive, true);

                if (!string.IsNullOrWhiteSpace(managerId)) updates = updates.Set(u => u.ManagerId, managerId);
                if (!PasswordHelper.VerifyPasswordComplete(password, existingUser.Password)) updates = updates.Set(u => u.Password, hashedPassword);

                await _users.UpdateOneAsync(filter, updates);
            }
        }

        public async Task EnsureAdminAccountAsync(
            string username,
            string password,
            string role,
            string email,
            string firstName = null,
            string lastName = null)
        {
            if (string.IsNullOrWhiteSpace(username)) throw new ArgumentException("Username is required.");
            var existingUser = await GetUserByUsernameAsync(username);
            var hashedPassword = PasswordHelper.HashPasswordComplete(password);

            if (existingUser == null)
            {
                var user = new User
                {
                    Username = username,
                    Email = email,
                    Password = hashedPassword,
                    Role = role,
                    FirstName = firstName,
                    LastName = lastName,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };
                await _users.InsertOneAsync(user);
                System.Diagnostics.Debug.WriteLine($"✓ Admin account created: {username} (Role: {role})");
            }
            else
            {
                var filter = Builders<User>.Filter.Eq(u => u.Id, existingUser.Id);
                var updates = Builders<User>.Update
                    .Set(u => u.Role, role)
                    .Set(u => u.Email, email)
                    .Set(u => u.IsActive, true);

                if (!string.IsNullOrWhiteSpace(firstName)) updates = updates.Set(u => u.FirstName, firstName);
                if (!string.IsNullOrWhiteSpace(lastName)) updates = updates.Set(u => u.LastName, lastName);
                if (!PasswordHelper.VerifyPasswordComplete(password, existingUser.Password)) 
                    updates = updates.Set(u => u.Password, hashedPassword);

                await _users.UpdateOneAsync(filter, updates);
                System.Diagnostics.Debug.WriteLine($"✓ Admin account updated: {username} (Role: {role})");
            }
        }

        public async Task EnsureEmployeeAccountAsync(
            string email,
            string employeeId,
            string firstName,
            string lastName,
            string middleName = null,
            string department = null,
            string position = null,
            bool hasSSS = false,
            bool hasPhilHealth = false,
            bool hasPagIbig = false)
        {
            if (string.IsNullOrWhiteSpace(email)) throw new ArgumentException("Email is required.");
            
            System.Diagnostics.Debug.WriteLine($"[UserService] EnsureEmployeeAccountAsync for: {email} (ID: {employeeId})");
            
            var existingUser = await GetUserByUsernameAsync(email);
            var hashedPassword = PasswordHelper.HashPasswordComplete(employeeId);

            if (existingUser == null)
            {
                var user = new User
                {
                    Username = email, Email = email, Password = hashedPassword, Role = "Employee",
                    FirstName = firstName, MiddleName = middleName, LastName = lastName,
                    Department = department, Position = position, EmployeeId = employeeId,
                    HasSSS = hasSSS, HasPhilHealth = hasPhilHealth, HasPagIbig = hasPagIbig,
                    CreatedAt = DateTime.UtcNow, IsActive = true
                };
                await _users.InsertOneAsync(user);
            }
            else
            {
                var filter = Builders<User>.Filter.Eq(u => u.Id, existingUser.Id);
                var updates = Builders<User>.Update
                    .Set(u => u.Role, "Employee")
                    .Set(u => u.FirstName, firstName)
                    .Set(u => u.LastName, lastName)
                    .Set(u => u.Email, email)
                    .Set(u => u.EmployeeId, employeeId)
                    .Set(u => u.HasSSS, hasSSS)
                    .Set(u => u.HasPhilHealth, hasPhilHealth)
                    .Set(u => u.HasPagIbig, hasPagIbig)
                    .Set(u => u.IsActive, true);

                if (!string.IsNullOrWhiteSpace(middleName)) updates = updates.Set(u => u.MiddleName, middleName);
                if (!string.IsNullOrWhiteSpace(department)) updates = updates.Set(u => u.Department, department);
                if (!string.IsNullOrWhiteSpace(position)) updates = updates.Set(u => u.Position, position);
                if (string.IsNullOrEmpty(existingUser.Password) || !PasswordHelper.VerifyPasswordComplete(employeeId, existingUser.Password)) 
                    updates = updates.Set(u => u.Password, hashedPassword);

                await _users.UpdateOneAsync(filter, updates);
            }
        }
    }
}