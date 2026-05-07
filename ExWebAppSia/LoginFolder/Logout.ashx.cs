using System;
using System.Web;
using System.Web.SessionState;

namespace ExWebAppSia.LoginFolder
{
    /// <summary>
    /// Summary description for Logout
    /// </summary>
    public class Logout : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            // 1. Clear and Abandon Session
            context.Session.Clear();
            context.Session.Abandon();

            // 2. Clear Auth Cookies
            if (context.Request.Cookies["HRSystemUser"] != null)
            {
                HttpCookie userCookie = new HttpCookie("HRSystemUser");
                userCookie.Expires = DateTime.Now.AddDays(-1);
                context.Response.Cookies.Add(userCookie);
            }

            // 3. Clear ASP.NET Session Cookie
            if (context.Request.Cookies["ASP.NET_SessionId"] != null)
            {
                HttpCookie sessionCookie = new HttpCookie("ASP.NET_SessionId");
                sessionCookie.Value = string.Empty;
                sessionCookie.Expires = DateTime.Now.AddDays(-1);
                context.Response.Cookies.Add(sessionCookie);
            }

            // 4. Redirect to Login Page
            context.Response.Redirect("~/LoginFolder/Login.aspx");
        }

        public bool IsReusable => false;
    }
}
