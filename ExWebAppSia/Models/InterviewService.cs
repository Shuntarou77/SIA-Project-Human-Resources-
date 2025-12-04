using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ExWebAppSia.Models
{
    public class InterviewService
    {
        private readonly IMongoCollection<Interview> _interviews;

        public InterviewService()
        {
            _interviews = MongoDBHelper.GetInterviewsCollection();
        }

        // Create a new interview
        public async Task<bool> CreateInterviewAsync(string applicantId, string applicantName, DateTime interviewDate, 
            string interviewTime, string interviewLocation, string interviewerName, string interviewNotes, string scheduledBy)
        {
            try
            {
                var interview = new Interview
                {
                    ApplicantId = applicantId,
                    ApplicantName = applicantName,
                    InterviewDate = interviewDate,
                    InterviewTime = interviewTime,
                    InterviewLocation = interviewLocation,
                    InterviewerName = interviewerName,
                    InterviewNotes = interviewNotes,
                    ScheduledBy = scheduledBy,
                    ScheduledDate = DateTime.UtcNow,
                    Status = "Scheduled",
                    IsActive = true
                };

                await _interviews.InsertOneAsync(interview);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating interview: {ex.Message}");
                return false;
            }
        }

        // Get all interviews
        public async Task<List<Interview>> GetAllInterviewsAsync()
        {
            try
            {
                return await _interviews.Find(i => i.IsActive)
                    .SortByDescending(i => i.InterviewDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting all interviews: {ex.Message}");
                return new List<Interview>();
            }
        }

        // Get interviews by applicant ID
        public async Task<List<Interview>> GetInterviewsByApplicantIdAsync(string applicantId)
        {
            try
            {
                var filter = Builders<Interview>.Filter.And(
                    Builders<Interview>.Filter.Eq(i => i.IsActive, true),
                    Builders<Interview>.Filter.Eq(i => i.ApplicantId, applicantId)
                );
                return await _interviews.Find(filter)
                    .SortByDescending(i => i.InterviewDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting interviews by applicant ID: {ex.Message}");
                return new List<Interview>();
            }
        }
    }
}

