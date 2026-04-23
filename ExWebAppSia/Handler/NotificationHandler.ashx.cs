using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;
using System.Threading.Tasks;
using Newtonsoft.Json;
using ExWebAppSia.Models;

namespace ExWebAppSia.Handler
{
    public class NotificationHandler : HttpTaskAsyncHandler, IRequiresSessionState
    {
        private readonly NotificationService _notificationService = new NotificationService();

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.AddHeader("Cache-Control", "no-cache, no-store");

            // Allow CORS for same-origin requests
            context.Response.AddHeader("Access-Control-Allow-Origin", "*");

            // Check login - be permissive about the type
            bool isLoggedIn = false;
            try
            {
                var loginVal = context.Session["IsLoggedIn"];
                if (loginVal != null)
                    isLoggedIn = Convert.ToBoolean(loginVal);
            }
            catch { }

            if (!isLoggedIn)
            {
                System.Diagnostics.Debug.WriteLine("[NotificationHandler] Session not authenticated.");
                context.Response.StatusCode = 401;
                context.Response.Write(JsonConvert.SerializeObject(new { error = "Unauthorized" }));
                return;
            }

            string action = context.Request.QueryString["action"] ?? "get";
            string employeeId = "";
            string role = "Employee";

            // Get employeeId from session
            try
            {
                var employee = context.Session["Employee"] as Employee;
                if (employee != null)
                    employeeId = employee.EmployeeId ?? "";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[NotificationHandler] Error getting Employee from session: " + ex.Message);
            }

            // Get role from session
            try
            {
                var sessionRole = context.Session["Role"];
                if (sessionRole != null)
                    role = sessionRole.ToString();
            }
            catch { }

            System.Diagnostics.Debug.WriteLine($"[NotificationHandler] action={action}, employeeId={employeeId}, role={role}");

            try
            {
                switch (action)
                {
                    case "get":
                        var notifications = await _notificationService.GetUserNotificationsAsync(employeeId, role);
                        var count = await _notificationService.GetUnreadCountAsync(employeeId, role);
                        System.Diagnostics.Debug.WriteLine($"[NotificationHandler] Returning {notifications.Count} notifications, {count} unread");
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = true,
                            notifications = notifications,
                            unreadCount = count
                        }));
                        break;

                    case "read":
                        string id = context.Request.Form["id"];
                        if (!string.IsNullOrEmpty(id))
                        {
                            await _notificationService.MarkAsReadAsync(id);
                            context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                        }
                        else
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new { error = "Missing id" }));
                        }
                        break;

                    case "readAll":
                        await _notificationService.MarkAllAsReadAsync(employeeId, role);
                        context.Response.Write(JsonConvert.SerializeObject(new { success = true }));
                        break;

                    default:
                        context.Response.Write(JsonConvert.SerializeObject(new { error = "Invalid action: " + action }));
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[NotificationHandler] Exception: " + ex.Message);
                context.Response.Write(JsonConvert.SerializeObject(new { error = ex.Message }));
            }
        }
    }
}
