using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class ApplicantService
    {
        private readonly IMongoCollection<Applicant> _applicants;

        public ApplicantService()
        {
            _applicants = MongoDBHelper.GetApplicantsCollection();
        }

        // Create a new applicant
        public async Task<bool> CreateApplicantAsync(Applicant applicant)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== ApplicantService.CreateApplicantAsync ===");
                System.Diagnostics.Debug.WriteLine($"Name: {applicant.FirstName} {applicant.LastName}");
                System.Diagnostics.Debug.WriteLine($"Department: {applicant.AppliedPosition}");
                System.Diagnostics.Debug.WriteLine($"Role: {applicant.Role}");
                
                applicant.Status = "New";
                applicant.AppliedDate = DateTime.UtcNow;
                applicant.IsActive = true;

                await _applicants.InsertOneAsync(applicant);
                System.Diagnostics.Debug.WriteLine("Successfully inserted applicant into MongoDB");
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating applicant: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return false;
            }
        }

        // Get all applicants
        public async Task<List<Applicant>> GetAllApplicantsAsync()
        {
            try
            {
                return await _applicants.Find(a => a.IsActive)
                    .SortByDescending(a => a.AppliedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all applicants: {ex.Message}");
                return new List<Applicant>();
            }
        }

        // Get applicants by status
        public async Task<List<Applicant>> GetApplicantsByStatusAsync(string status)
        {
            try
            {
                var filter = Builders<Applicant>.Filter.And(
                    Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                    Builders<Applicant>.Filter.Eq(a => a.Status, status)
                );
                return await _applicants.Find(filter)
                    .SortByDescending(a => a.AppliedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting applicants by status: {ex.Message}");
                return new List<Applicant>();
            }
        }

        // Get new applicants (status = "New")
        public async Task<List<Applicant>> GetNewApplicantsAsync()
        {
            return await GetApplicantsByStatusAsync("New");
        }

        // Get in-progress applicants (status = "In-Progress")
        public async Task<List<Applicant>> GetInProgressApplicantsAsync()
        {
            return await GetApplicantsByStatusAsync("In-Progress");
        }

        // Update applicant status
        public async Task<bool> UpdateApplicantStatusAsync(string applicantId, string newStatus)
        {
            try
            {
                if (string.IsNullOrEmpty(applicantId))
                {
                    System.Diagnostics.Debug.WriteLine("UpdateApplicantStatusAsync: applicantId is null or empty");
                    return false;
                }

                // First check if applicant exists
                var applicant = await GetApplicantByIdAsync(applicantId);
                if (applicant == null)
                {
                    System.Diagnostics.Debug.WriteLine($"UpdateApplicantStatusAsync: Applicant with ID {applicantId} not found");
                    return false;
                }

                // Check if status is already the target status
                if (applicant.Status == newStatus)
                {
                    System.Diagnostics.Debug.WriteLine($"UpdateApplicantStatusAsync: Applicant status is already {newStatus}");
                    return true; // Already in the desired state
                }

                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update.Set(a => a.Status, newStatus);
                var result = await _applicants.UpdateOneAsync(filter, update);
                
                bool success = result.ModifiedCount > 0 || result.MatchedCount > 0;
                System.Diagnostics.Debug.WriteLine($"UpdateApplicantStatusAsync: Matched={result.MatchedCount}, Modified={result.ModifiedCount}, Success={success}");
                
                return success;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating applicant status: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return false;
            }
        }

        // Get applicant by ID
        public async Task<Applicant> GetApplicantByIdAsync(string applicantId)
        {
            try
            {
                return await _applicants.Find(a => a.Id == applicantId && a.IsActive).FirstOrDefaultAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting applicant by ID: {ex.Message}");
                return null;
            }
        }

        // Get count by status
        public async Task<int> GetCountByStatusAsync(string status)
        {
            try
            {
                var filter = Builders<Applicant>.Filter.And(
                    Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                    Builders<Applicant>.Filter.Eq(a => a.Status, status)
                );
                return (int)await _applicants.CountDocumentsAsync(filter);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting count by status: {ex.Message}");
                return 0;
            }
        }

        // Schedule interview for applicant
        public async Task<bool> ScheduleInterviewAsync(string applicantId, DateTime interviewDate, string interviewTime, 
            string interviewLocation, string interviewerName, string interviewNotes, string scheduledBy)
        {
            try
            {
                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update
                    .Set(a => a.Status, "In-Progress")
                    .Set(a => a.InterviewDate, interviewDate)
                    .Set(a => a.InterviewTime, interviewTime)
                    .Set(a => a.InterviewLocation, interviewLocation)
                    .Set(a => a.InterviewerName, interviewerName)
                    .Set(a => a.InterviewNotes, interviewNotes)
                    .Set(a => a.ScheduledBy, scheduledBy)
                    .Set(a => a.ScheduledDate, DateTime.UtcNow);

                var result = await _applicants.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error scheduling interview: {ex.Message}");
                return false;
            }
        }
    }
}

