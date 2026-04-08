using ExWebAppSia.Models;
using System;
using System.Linq;
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
            var employeeService = new EmployeeService();
            var nameCache = new System.Collections.Generic.Dictionary<string, string>();
            var sb = new StringBuilder();

            if (logs == null || logs.Count == 0)
            {
                sb.Append("<tr><td colspan='5' style='text-align:center; padding: 60px; color:#94a3b8;'>No activities recorded yet.</td></tr>");
            }
            else
            {
                foreach (var log in logs)
                {
                    string actionLower = (log.Action ?? "").ToLower();
                    string moduleLower = (log.Module ?? "").ToLower();

                    // Resolve Name if it looks like an ID (e.g., 26-2271)
                    string displayName = log.HRName ?? "Admin";
                    string displayUser = log.HRUsername ?? "N/A";

                    bool isAttendance = moduleLower.Contains("attendance");

                    // If it's attendance or the name looks like an ID, try to get actual name
                    if (isAttendance || (displayName.Any(char.IsDigit) && displayName.Contains("-")))
                    {
                        string idToLookup = isAttendance ? log.HRUsername : displayName;
                        if (!string.IsNullOrEmpty(idToLookup))
                        {
                            if (nameCache.ContainsKey(idToLookup))
                            {
                                displayName = nameCache[idToLookup];
                            }
                            else
                            {
                                var emp = await employeeService.GetByEmployeeIdAsync(idToLookup);
                                if (emp != null)
                                {
                                    displayName = emp.FullName;
                                    nameCache[idToLookup] = emp.FullName;
                                }
                            }
                        }
                    }

                    string actionClass = actionLower.Contains("hr notice") || isAttendance ? "action-attendance" :
                                         actionLower.Contains("create") || actionLower.Contains("hire") || actionLower.Contains("accept") || actionLower.Contains("approve") ? "action-create" :
                                         actionLower.Contains("update") || actionLower.Contains("edit") ? "action-update" :
                                         actionLower.Contains("delete") || actionLower.Contains("remove") || actionLower.Contains("resign") || actionLower.Contains("decline") ? "action-delete" :
                                         "action-other";

                    string localTime = log.Timestamp.ToLocalTime().ToString("hh:mm tt");
                    string localDate = log.Timestamp.ToLocalTime().ToString("MMM dd, yyyy");

                    sb.Append($@"
                    <tr>
                        <td>
                            <div class='hr-info'>
                                <span class='hr-name'>{Server.HtmlEncode(displayName)}</span>
                                <span class='hr-email'>{Server.HtmlEncode(displayUser)}</span>
                            </div>
                        </td>
                        <td><span class='log-module'>{Server.HtmlEncode(log.Module ?? "System")}</span></td>
                        <td>
                            <span class='action-badge {actionClass}'>
                                {Server.HtmlEncode(log.Action ?? "Action")}
                            </span>
                        </td>
                        <td><div class='target-detail'>{Server.HtmlEncode(log.TargetInfo ?? "N/A")}</div></td>
                        <td>
                            <div class='time-info'>
                                <span class='time-val'>{localTime}</span>
                                <span class='date-val'>{localDate}</span>
                            </div>
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
