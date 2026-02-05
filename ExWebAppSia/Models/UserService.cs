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
                    return null;
                }

                // Try case-sensitive match first
                var user = await _users.Find(u => u.Username == username && u.IsActive).FirstOrDefaultAsync();
                
                // If not found, try case-insensitive match
                if (user == null)
                {
                    var allUsers = await _users.Find(u => u.IsActive).ToListAsync();
                    user = allUsers.FirstOrDefault(u => 
                        string.Equals(u.Username, username, StringComparison.OrdinalIgnoreCase));
                }

                if (user != null)
                {
                    bool passwordValid = PasswordHelper.VerifyPasswordComplete(password, user.Password);
                    if (passwordValid)
                    {
                        return user;
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error authenticating user: {ex.Message}");
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

        public async Task EnsureEmployeeAccountAsync(
            string email,
            string employeeId,
            string firstName,
            string lastName,
            string middleName = null,
            string department = null,
            string position = null)
        {
            if (string.IsNullOrWhiteSpace(email)) throw new ArgumentException("Email is required.");
            var existingUser = await GetUserByUsernameAsync(email);
            var hashedPassword = PasswordHelper.HashPasswordComplete(employeeId);

            if (existingUser == null)
            {
                var user = new User
                {
                    Username = email, Email = email, Password = hashedPassword, Role = "Employee",
                    FirstName = firstName, MiddleName = middleName, LastName = lastName,
                    Department = department, Position = position, EmployeeId = employeeId,
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
                    .Set(u => u.IsActive, true);

                if (!string.IsNullOrWhiteSpace(middleName)) updates = updates.Set(u => u.MiddleName, middleName);
                if (!string.IsNullOrWhiteSpace(department)) updates = updates.Set(u => u.Department, department);
                if (!string.IsNullOrWhiteSpace(position)) updates = updates.Set(u => u.Position, position);
                if (string.IsNullOrEmpty(existingUser.Password)) updates = updates.Set(u => u.Password, hashedPassword);

                await _users.UpdateOneAsync(filter, updates);
            }
        }
    }
}