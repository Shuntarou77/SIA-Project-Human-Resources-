using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Linq;
using ExWebAppSia.Models;
using MongoDB.Driver;
using MongoDB.Bson;

namespace ExWebAppSia.webpage.api
{
	public class Announcements : IHttpHandler, System.Web.SessionState.IRequiresSessionState
	{
		private static readonly JavaScriptSerializer _json = new JavaScriptSerializer();
		private static readonly IMongoCollection<Announcement> _col = MongoDBHelper.GetAnnouncementsCollection();
		private static readonly IMongoCollection<Employee> _employees = MongoDBHelper.GetEmployeesCollection();

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
			var filter = Builders<Announcement>.Filter.Eq(x => x.IsActive, true);
			var list = _col.Find(filter)
				.SortByDescending(x => x.IsPinned)
				.ThenByDescending(x => x.PostedDate)
				.Limit(200)
				.ToList();

			var response = list.Select(a => new
			{
				a.Id,
				a.Content,
				PostedBy = ResolveDisplayName(a.PostedBy),
				PostedByRaw = a.PostedBy,
				a.Department,
				a.PostedDate,
				a.IsActive,
				a.IsPinned,
				a.HasImage,
				a.ImagePath,
				a.HasVideo,
				a.VideoPath,
				a.MediaUrls
			}).ToList();

			ctx.Response.ContentType = "application/json";
			ctx.Response.Write(_json.Serialize(response));
		}

		private void HandlePost(HttpContext ctx)
		{
			var action = (ctx.Request["action"] ?? "").Trim().ToLowerInvariant();
			if (action == "delete")
			{
				HandleDelete(ctx);
				return;
			}
			if (action == "update")
			{
				HandleUpdate(ctx);
				return;
			}
			if (action == "pin")
			{
				HandlePin(ctx);
				return;
			}

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

			var postedBy = "HR Admin";
			var sessionEmp = ctx.Session["Employee"] as Employee;
			if (sessionEmp != null && !string.IsNullOrWhiteSpace(sessionEmp.FullName))
			{
				postedBy = sessionEmp.FullName;
			}
			else if (ctx.Session["Username"] != null)
			{
				postedBy = ctx.Session["Username"].ToString();
			}
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

		private void HandleDelete(HttpContext ctx)
		{
			var id = (ctx.Request["id"] ?? "").Trim();
			if (string.IsNullOrEmpty(id))
			{
				ctx.Response.StatusCode = 400;
				ctx.Response.Write("{\"error\":\"id is required\"}");
				return;
			}

			var filter = Builders<Announcement>.Filter.And(
				Builders<Announcement>.Filter.Eq(x => x.Id, id),
				Builders<Announcement>.Filter.Eq(x => x.IsActive, true)
			);
			var update = Builders<Announcement>.Update.Set(x => x.IsActive, false);
			var result = _col.UpdateOne(filter, update);

			if (result.ModifiedCount == 0)
			{
				ctx.Response.StatusCode = 404;
				ctx.Response.Write("{\"error\":\"Announcement not found\"}");
				return;
			}
			ctx.Response.Write("{\"success\":true}");
		}

		private void HandleUpdate(HttpContext ctx)
		{
			var id = (ctx.Request["id"] ?? "").Trim();
			var content = (ctx.Request["content"] ?? "").Trim();
			var department = (ctx.Request["department"] ?? "").Trim();

			if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(content))
			{
				ctx.Response.StatusCode = 400;
				ctx.Response.Write("{\"error\":\"id and content are required\"}");
				return;
			}

			var updates = new List<UpdateDefinition<Announcement>>
			{
				Builders<Announcement>.Update.Set(x => x.Content, content)
			};
			if (!string.IsNullOrEmpty(department))
			{
				updates.Add(Builders<Announcement>.Update.Set(x => x.Department, department));
			}

			var result = _col.UpdateOne(
				Builders<Announcement>.Filter.And(
					Builders<Announcement>.Filter.Eq(x => x.Id, id),
					Builders<Announcement>.Filter.Eq(x => x.IsActive, true)),
				Builders<Announcement>.Update.Combine(updates));

			if (result.ModifiedCount == 0)
			{
				ctx.Response.StatusCode = 404;
				ctx.Response.Write("{\"error\":\"Announcement not found or unchanged\"}");
				return;
			}
			ctx.Response.Write("{\"success\":true}");
		}

		private void HandlePin(HttpContext ctx)
		{
			var id = (ctx.Request["id"] ?? "").Trim();
			var isPinnedRaw = (ctx.Request["isPinned"] ?? "false").Trim();
			bool isPinned;
			bool.TryParse(isPinnedRaw, out isPinned);

			if (string.IsNullOrEmpty(id))
			{
				ctx.Response.StatusCode = 400;
				ctx.Response.Write("{\"error\":\"id is required\"}");
				return;
			}

			var result = _col.UpdateOne(
				Builders<Announcement>.Filter.And(
					Builders<Announcement>.Filter.Eq(x => x.Id, id),
					Builders<Announcement>.Filter.Eq(x => x.IsActive, true)),
				Builders<Announcement>.Update.Set(x => x.IsPinned, isPinned));

			if (result.ModifiedCount == 0)
			{
				ctx.Response.StatusCode = 404;
				ctx.Response.Write("{\"error\":\"Announcement not found or unchanged\"}");
				return;
			}
			ctx.Response.Write(_json.Serialize(new { success = true, isPinned }));
		}

		private static string ResolveDisplayName(string postedBy)
		{
			if (string.IsNullOrWhiteSpace(postedBy)) return "Admin";
			var value = postedBy.Trim();

			if (!value.Contains("@")) return value;

			try
			{
				var escaped = RegexEscape(value);
				var emailFilter = Builders<Employee>.Filter.Regex(
					x => x.Email,
					new BsonRegularExpression("^" + escaped + "$", "i"));
				var emp = _employees.Find(emailFilter).FirstOrDefault();
				if (emp != null && !string.IsNullOrWhiteSpace(emp.FullName))
				{
					return emp.FullName;
				}
			}
			catch { }

			return value;
		}

		private static string RegexEscape(string value)
		{
			return System.Text.RegularExpressions.Regex.Escape(value ?? "");
		}
	}
}