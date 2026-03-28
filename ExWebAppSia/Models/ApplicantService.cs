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

        public async Task<bool> IsNameDuplicateAsync(string firstName, string lastName)
        {
            try
            {
                var filter = Builders<Applicant>.Filter.And(
                    Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                    Builders<Applicant>.Filter.Regex(a => a.FirstName, new MongoDB.Bson.BsonRegularExpression($"^{firstName}$", "i")),
                    Builders<Applicant>.Filter.Regex(a => a.LastName, new MongoDB.Bson.BsonRegularExpression($"^{lastName}$", "i"))
                );
                return await _applicants.Find(filter).AnyAsync();
            }
            catch { return false; }
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
                
                if (string.IsNullOrEmpty(applicant.Status))
                {
                    applicant.Status = "Pending Review";
                }
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
            try
            {
                var filter = Builders<Applicant>.Filter.And(
                    Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                    Builders<Applicant>.Filter.Or(
                        Builders<Applicant>.Filter.Eq(a => a.Status, "New"),
                        Builders<Applicant>.Filter.Eq(a => a.Status, "Pending Review")
                    )
                );
                return await _applicants.Find(filter)
                    .SortByDescending(a => a.AppliedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting new applicants: {ex.Message}");
                return new List<Applicant>();
            }
        }

        // Get approved applicants (status = "Approved")
        public async Task<List<Applicant>> GetApprovedApplicantsAsync()
        {
            return await GetApplicantsByStatusAsync("Approved");
        }

        // Get declined applicants (status = "Declined")
        public async Task<List<Applicant>> GetDeclinedApplicantsAsync()
        {
            return await GetApplicantsByStatusAsync("Declined");
        }

        public async Task<List<Applicant>> GetInProgressApplicantsAsync()
        {
            try
            {
                var filter = Builders<Applicant>.Filter.And(
                    Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                    Builders<Applicant>.Filter.Or(
                        Builders<Applicant>.Filter.Eq(a => a.Status, "In-Progress"),
                        Builders<Applicant>.Filter.Eq(a => a.Status, "Onboarding")
                    )
                );
                return await _applicants.Find(filter)
                    .SortByDescending(a => a.AppliedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting in-progress applicants: {ex.Message}");
                return new List<Applicant>();
            }
        }

        // Get for-viewing applicants (status = "For Viewing")
        public async Task<List<Applicant>> GetForViewingApplicantsAsync()
        {
            return await GetApplicantsByStatusAsync("For Viewing");
        }

        // Update applicant status
        public async Task<bool> UpdateApplicantStatusAsync(string applicantId, string newStatus)
        {
            try
            {
                if (string.IsNullOrEmpty(applicantId)) return false;

                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update.Set(a => a.Status, newStatus);
                
                if (newStatus == "Approved")
                {
                    update = update.Set(a => a.ApprovedDate, DateTime.UtcNow);
                }

                var result = await _applicants.UpdateOneAsync(filter, update);
                
                return result.ModifiedCount > 0 || result.MatchedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating applicant status: {ex.Message}");
                return false;
            }
        }

        // Update applicant status to declined with a reason
        public async Task<bool> UpdateDeclinedStatusAsync(string applicantId, string reason)
        {
            try
            {
                if (string.IsNullOrEmpty(applicantId)) return false;

                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update
                    .Set(a => a.Status, "Declined")
                    .Set(a => a.DeclineReason, reason);
                
                var result = await _applicants.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0 || result.MatchedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error declining applicant: {ex.Message}");
                return false;
            }
        }

        // Update requirements status
        public async Task<bool> UpdateRequirementsStatusAsync(string applicantId, bool isComplete)
        {
            try
            {
                if (string.IsNullOrEmpty(applicantId)) return false;

                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update.Set(a => a.IsRequirementsComplete, isComplete);
                
                var result = await _applicants.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0 || result.MatchedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating requirements status: {ex.Message}");
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
                if (status == "New")
                {
                    var filter = Builders<Applicant>.Filter.And(
                        Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                        Builders<Applicant>.Filter.Or(
                            Builders<Applicant>.Filter.Eq(a => a.Status, "New"),
                            Builders<Applicant>.Filter.Eq(a => a.Status, "Pending Review")
                        )
                    );
                    return (int)await _applicants.CountDocumentsAsync(filter);
                }
                else
                {
                    var filter = Builders<Applicant>.Filter.And(
                        Builders<Applicant>.Filter.Eq(a => a.IsActive, true),
                        Builders<Applicant>.Filter.Eq(a => a.Status, status)
                    );
                    return (int)await _applicants.CountDocumentsAsync(filter);
                }
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
        public async Task<bool> UpdateGovtDetailsAsync(string applicantId, string sss, string philhealth, string pagibig)
        {
            try
            {
                var filter = Builders<Applicant>.Filter.Eq(a => a.Id, applicantId);
                var update = Builders<Applicant>.Update
                    .Set(a => a.SSSNumber, sss)
                    .Set(a => a.PhilHealthNumber, philhealth)
                    .Set(a => a.PagIbigNumber, pagibig)
                    .Set(a => a.HasSSS, !string.IsNullOrEmpty(sss))
                    .Set(a => a.HasPhilHealth, !string.IsNullOrEmpty(philhealth))
                    .Set(a => a.HasPagIbig, !string.IsNullOrEmpty(pagibig));

                var result = await _applicants.UpdateOneAsync(filter, update);
                return result.ModifiedCount > 0 || result.MatchedCount > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating govt details: {ex.Message}");
                return false;
            }
        }
    }
}

