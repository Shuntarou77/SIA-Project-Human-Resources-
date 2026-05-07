using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MongoDB.Driver;
using ExWebAppSia.Models;

namespace ExWebAppSia.Models
{
    public class LoanService
    {
        private readonly IMongoCollection<LoanRequest> _loans;

        public LoanService()
        {
            var database = MongoDBHelper.GetDatabase();
            _loans = database.GetCollection<LoanRequest>("LoanRequests");
        }

        public async Task<List<LoanRequest>> GetAllLoansAsync()
        {
            return await _loans.Find(_ => true)
                .SortByDescending(l => l.RequestDate)
                .ToListAsync();
        }

        public async Task<List<LoanRequest>> GetLoansByEmployeeIdAsync(string employeeId)
        {
            return await _loans.Find(l => l.EmployeeId == employeeId)
                .SortByDescending(l => l.RequestDate)
                .ToListAsync();
        }

        public async Task<List<LoanRequest>> GetRecentLoansByEmployeeIdAsync(string employeeId, int limit = 100)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return new List<LoanRequest>();
                employeeId = employeeId.Trim();
                if (limit <= 0) limit = 100;

                // Avoid DB-side sort to prevent slow scans on large collections without indexes.
                return await _loans
                    .Find(l => l.EmployeeId == employeeId)
                    .Limit(limit)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting recent loans by employee ID: {ex.Message}");
                return new List<LoanRequest>();
            }
        }

        public async Task CreateLoanAsync(LoanRequest loan)
        {
            await _loans.InsertOneAsync(loan);
        }

        public async Task<LoanRequest> GetLoanByIdAsync(string id)
        {
            return await _loans.Find(l => l.Id == id).FirstOrDefaultAsync();
        }

        public async Task UpdateLoanStatusAsync(string id, string status)
        {
            var update = Builders<LoanRequest>.Update
                .Set(l => l.Status, status)
                .Set(l => l.LastUpdated, DateTime.Now);

            await _loans.UpdateOneAsync(l => l.Id == id, update);
        }

        public async Task DeleteLoanAsync(string id)
        {
            await _loans.DeleteOneAsync(l => l.Id == id);
        }
    }
}
