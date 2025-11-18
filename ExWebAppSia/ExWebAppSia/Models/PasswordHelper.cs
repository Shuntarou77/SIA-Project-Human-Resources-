using System;
using System.Security.Cryptography;
using System.Text;

namespace ExWebAppSia.Models
{
    public static class PasswordHelper
    {
        // Generate a random salt
        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        // Hash password with salt
        public static string HashPassword(string password, string salt)
        {
            using (var sha256 = SHA256.Create())
            {
                // Combine password and salt
                string combined = password + salt;
                byte[] hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(combined));
                return Convert.ToBase64String(hashedBytes);
            }
        }

        // Verify password
        public static bool VerifyPassword(string password, string hashedPassword, string salt)
        {
            string hashToCheck = HashPassword(password, salt);
            return hashToCheck == hashedPassword;
        }

        // Complete password hashing (includes salt in the result)
        public static string HashPasswordComplete(string password)
        {
            string salt = GenerateSalt();
            string hash = HashPassword(password, salt);
            // Store salt and hash together, separated by a delimiter
            return $"{salt}:{hash}";
        }

        // Verify password from stored hash
        public static bool VerifyPasswordComplete(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash) || !storedHash.Contains(":"))
                return false;

            string[] parts = storedHash.Split(':');
            if (parts.Length != 2)
                return false;

            string salt = parts[0];
            string hash = parts[1];
            return VerifyPassword(password, hash, salt);
        }
    }
}