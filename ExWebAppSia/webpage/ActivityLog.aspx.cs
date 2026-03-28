using ExWebAppSia.Models;
using System;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;

namespace ExWebAppSia.webpage
{
    public partial class ActivityLog : System.Web.UI.Page
    {
        private readonly ActivityLogService _activityLogService = new ActivityLogService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/LoginFolder/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadActivityLogsAsync));
            }
        }

        private async Task LoadActivityLogsAsync()
        {
            var logs = await _activityLogService.GetAllLogsAsync();
            var sb = new StringBuilder();

            if (logs == null || logs.Count == 0)
            {
                sb.Append("<tr><td colspan='5' style='text-align:center; padding: 40px; color:#a0aec0;'>No activities recorded yet.</td></tr>");
            }
            else
            {
                foreach (var log in logs)
                {
                    string actionLower = (log.Action ?? "").ToLower();
                    string actionClass = actionLower.Contains("create") || actionLower.Contains("hire") || actionLower.Contains("accept") ? "action-create" :
                                         actionLower.Contains("update") || actionLower.Contains("edit") ? "action-update" :
                                         actionLower.Contains("delete") || actionLower.Contains("remove") || actionLower.Contains("resign") ? "action-delete" :
                                         "action-other";

                    string localTime = log.Timestamp.ToLocalTime().ToString("hh:mm tt");
                    string localDate = log.Timestamp.ToLocalTime().ToString("MMM dd, yyyy");

                    sb.Append($@"
                    <tr>
                        <td>
                            <span class='hr-name'>{Server.HtmlEncode(log.HRName ?? "Admin")}</span>
                            <span class='hr-username'>{Server.HtmlEncode(log.HRUsername ?? "N/A")}</span>
                        </td>
                        <td style='font-weight: 500;'>{Server.HtmlEncode(log.Module ?? "System")}</td>
                        <td>
                            <span class='action-badge {actionClass}'>
                                {Server.HtmlEncode(log.Action ?? "Action")}
                            </span>
                        </td>
                        <td style='color:#4a5568;'>{Server.HtmlEncode(log.TargetInfo ?? "N/A")}</td>
                        <td>
                            <span class='log-time'>{localTime}</span>
                            <span class='log-date'>{localDate}</span>
                        </td>
                    </tr>");
                }
            }

            if (phActivityLogs != null)
            {
                phActivityLogs.Controls.Clear();
                phActivityLogs.Controls.Add(new LiteralControl(sb.ToString()));
            }
        }
    }
}
