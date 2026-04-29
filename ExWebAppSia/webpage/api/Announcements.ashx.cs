using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using ExWebAppSia.Models;
using MongoDB.Driver;

namespace ExWebAppSia.webpage.api
{
	public class Announcements : IHttpHandler, System.Web.SessionState.IRequiresSessionState
	{
		private static readonly JavaScriptSerializer _json = new JavaScriptSerializer();
		private static readonly IMongoCollection<Announcement> _col = MongoDBHelper.GetAnnouncementsCollection();

		public void ProcessRequest(HttpContext ctx)
		{
			ctx.Response.ContentType = "application/json";
			try
			{
				var method = ctx.Request.HttpMethod?.ToUpperInvariant();
				if (method == "GET") { HandleGet(ctx); return; }
				if (method == "POST") { HandlePost(ctx); return; }

				ctx.Response.StatusCode = 405;
				ctx.Response.Write("{\"error\":\"Method not allowed\"}");
			}
			catch (Exception ex)
			{
				ctx.Response.StatusCode = 500;
				ctx.Response.Write(_json.Serialize(new { error = ex.Message }));
			}
		}

		private void HandleGet(HttpContext ctx)
		{
	var filter = MongoDB.Driver.Builders<Announcement>.Filter.Eq(x => x.IsActive, true);
	var list = _col.Find(filter).SortByDescending(x => x.PostedDate).Limit(200).ToList();
	ctx.Response.ContentType = "application/json";
	ctx.Response.Write(_json.Serialize(list)); // returns [] if empty
}

		private void HandlePost(HttpContext ctx)
		{
			string content = "";
			string imagePath = null;
			string videoPath = null;

			bool isPinned = false;
			string targetDepartment = null;

			// Check if this is a multipart form data (file upload)
			if (ctx.Request.ContentType != null && ctx.Request.ContentType.Contains("multipart/form-data"))
			{
				content = ctx.Request.Form["content"];
				bool.TryParse(ctx.Request.Form["isPinned"], out isPinned);
				if (!string.IsNullOrEmpty(ctx.Request.Form["department"]))
				{
					targetDepartment = ctx.Request.Form["department"];
				}
				
				// Handle image upload
				if (ctx.Request.Files["image"] != null && ctx.Request.Files["image"].ContentLength > 0)
				{
					var imageFile = ctx.Request.Files["image"];
					var uploadDir = ctx.Server.MapPath("~/Uploads/Announcements/Images");
					if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
					
					var fileName = Guid.NewGuid().ToString() + Path.GetExtension(imageFile.FileName);
					var filePath = Path.Combine(uploadDir, fileName);
					imageFile.SaveAs(filePath);
					imagePath = "/Uploads/Announcements/Images/" + fileName;
				}
				
				// Handle video upload
				if (ctx.Request.Files["video"] != null && ctx.Request.Files["video"].ContentLength > 0)
				{
					var videoFile = ctx.Request.Files["video"];
					var uploadDir = ctx.Server.MapPath("~/Uploads/Announcements/Videos");
					if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
					
					var fileName = Guid.NewGuid().ToString() + Path.GetExtension(videoFile.FileName);
					var filePath = Path.Combine(uploadDir, fileName);
					videoFile.SaveAs(filePath);
					videoPath = "/Uploads/Announcements/Videos/" + fileName;
				}
			}
			else
			{
				// JSON request (old format)
				string body;
				using (var r = new StreamReader(ctx.Request.InputStream)) body = r.ReadToEnd();

				var payload = _json.Deserialize<Dictionary<string, object>>(body ?? "{}");
				content = (payload.ContainsKey("content") ? (payload["content"] ?? "").ToString() : "").Trim();
				if (payload.ContainsKey("isPinned")) bool.TryParse(payload["isPinned"].ToString(), out isPinned);
				if (payload.ContainsKey("department")) targetDepartment = payload["department"].ToString();
			}

			if (string.IsNullOrEmpty(content))
			{
				ctx.Response.StatusCode = 400;
				ctx.Response.Write("{\"error\":\"Content is required\"}");
				return;
			}

			var postedBy = (ctx.Session["Username"] != null ? ctx.Session["Username"].ToString() : "HR Admin");
			var role = (ctx.Session["Role"] != null ? ctx.Session["Role"].ToString() : "Admin");

			if (string.IsNullOrEmpty(targetDepartment) || targetDepartment == "General")
			{
				targetDepartment = "General";
			}

			var doc = new Announcement
			{
				Content = content,
				PostedBy = postedBy,
				Department = targetDepartment,
				PostedDate = DateTime.UtcNow,
				IsActive = true,
				IsPinned = isPinned,
				HasImage = !string.IsNullOrEmpty(imagePath),
				ImagePath = imagePath,
				HasVideo = !string.IsNullOrEmpty(videoPath),
				VideoPath = videoPath
			};

			_col.InsertOne(doc);

            // Create notification for ALL users
            try
            {
                var notifService = new NotificationService();
                string notifMsg = content.Length > 60 ? content.Substring(0, 57) + "..." : content;
                System.Threading.Tasks.Task.Run(async () =>
                {
                    await notifService.CreateNotificationAsync(new Notification
                    {
                        RecipientId = "ALL",
                        Title = "New Announcement",
                        Message = notifMsg,
                        Type = "Announcement",
                        Link = "~/webpage(EmployeeViewpoint)/Announcement.aspx"
                    });
                });
            }
            catch (Exception notifEx)
            {
                System.Diagnostics.Debug.WriteLine("[Announcements] Notification error: " + notifEx.Message);
            }

            try
            {
                var username = ctx.Session["Username"] as string ?? "Unknown HR";
                var hrName = "Admin";
                var emp = ctx.Session["Employee"] as Employee;
                if (emp != null) hrName = emp.FullName;
                string titleSnippet = content.Length > 30 ? content.Substring(0, 30) + "..." : content;
                
                var logService = new ActivityLogService();
                System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct => 
                    System.Threading.Tasks.Task.Run(() => logService.LogActionAsync(username, hrName, "Created Announcement", "Announcements", $"Posted: {titleSnippet} ({targetDepartment})"))
                );

            }
            catch { /* Ignore log errors */ }

			ctx.Response.StatusCode = 201;
			ctx.Response.Write(_json.Serialize(doc));
		}

		public bool IsReusable { get { return false; } }
	}
}