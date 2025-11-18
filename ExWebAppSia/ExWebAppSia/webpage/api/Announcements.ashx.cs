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
			string body;
			using (var r = new StreamReader(ctx.Request.InputStream)) body = r.ReadToEnd();

			var payload = _json.Deserialize<Dictionary<string, object>>(body ?? "{}");
			var content = (payload.ContainsKey("content") ? (payload["content"] ?? "").ToString() : "").Trim();
			if (string.IsNullOrEmpty(content))
			{
				ctx.Response.StatusCode = 400;
				ctx.Response.Write("{\"error\":\"Content is required\"}");
				return;
			}

			var postedBy = (ctx.Session["Username"] != null ? ctx.Session["Username"].ToString()
			              : (payload.ContainsKey("postedBy") ? (payload["postedBy"] ?? "").ToString() : "Unknown"));
			var role = (ctx.Session["Role"] != null ? ctx.Session["Role"].ToString() : "");
			var department = !string.IsNullOrEmpty(role) && role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ? "HR Department" : "General";

			var doc = new Announcement
			{
				Content = content,
				PostedBy = postedBy,
				Department = department,
				PostedDate = DateTime.UtcNow,
				IsActive = true
			};

			_col.InsertOne(doc);

			ctx.Response.StatusCode = 201;
			ctx.Response.Write(_json.Serialize(doc));
		}

		public bool IsReusable { get { return false; } }
	}
}