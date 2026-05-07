using System;
using System.Collections.Generic;
using System.Text;
using SelectPdf;

namespace ExWebAppSia.Models
{
    public class ActivityLogPdfService
    {
        public byte[] GenerateActivityLogPdf(List<ActivityLog> logs)
        {
            try
            {
                string htmlContent = GenerateHtml(logs);
                HtmlToPdf converter = new HtmlToPdf();

                converter.Options.PdfPageSize = PdfPageSize.A4;
                converter.Options.PdfPageOrientation = PdfPageOrientation.Landscape;
                converter.Options.MarginTop = 30;
                converter.Options.MarginBottom = 30;
                converter.Options.MarginLeft = 20;
                converter.Options.MarginRight = 20;
                converter.Options.WebPageWidth = 1024;

                PdfDocument doc = converter.ConvertHtmlString(htmlContent);
                byte[] pdfBytes = doc.Save();
                doc.Close();

                return pdfBytes;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating Activity Log PDF: {ex.Message}");
                return null;
            }
        }

        private string GenerateHtml(List<ActivityLog> logs)
        {
            var sb = new StringBuilder();

            sb.AppendLine("<!DOCTYPE html>");
            sb.AppendLine("<html>");
            sb.AppendLine("<head>");
            sb.AppendLine("<meta charset='UTF-8'>");
            sb.AppendLine("<title>HR Activity Log Report</title>");
            sb.AppendLine("<style>");
            sb.AppendLine(@"
                body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; color: #333; }
                .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #A36A66; padding-bottom: 10px; }
                .header h1 { color: #A36A66; margin: 0; font-size: 24px; }
                .header p { color: #666; margin: 5px 0 0; font-size: 14px; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; table-layout: fixed; }
                th { background-color: #A36A66; color: white; padding: 12px 8px; text-align: left; font-size: 12px; text-transform: uppercase; }
                td { padding: 10px 8px; border-bottom: 1px solid #eee; font-size: 11px; word-wrap: break-word; }
                tr:nth-child(even) { background-color: #fcf9f9; }
                .action-badge { padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 10px; }
                .footer { text-align: right; margin-top: 30px; font-size: 10px; color: #999; border-top: 1px solid #eee; padding-top: 10px; }
                .timestamp { white-space: nowrap; }
            ");
            sb.AppendLine("</style>");
            sb.AppendLine("</head>");
            sb.AppendLine("<body>");

            sb.AppendLine("<div class='header'>");
            sb.AppendLine("<h1>HR ACTIVITY LOG REPORT</h1>");
            sb.AppendLine($"<p>Generated on {DateTime.Now:MMMM dd, yyyy hh:mm tt}</p>");
            sb.AppendLine("</div>");

            sb.AppendLine("<table>");
            sb.AppendLine("<thead>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th style='width: 15%;'>Timestamp</th>");
            sb.AppendLine("<th style='width: 15%;'>Administrator</th>");
            sb.AppendLine("<th style='width: 15%;'>Module</th>");
            sb.AppendLine("<th style='width: 15%;'>Action</th>");
            sb.AppendLine("<th style='width: 40%;'>Details</th>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</thead>");
            sb.AppendLine("<tbody>");

            if (logs == null || logs.Count == 0)
            {
                sb.AppendLine("<tr><td colspan='5' style='text-align:center;'>No activities recorded.</td></tr>");
            }
            else
            {
                foreach (var log in logs)
                {
                    var localTime = log.Timestamp.ToLocalTime();
                    sb.AppendLine("<tr>");
                    sb.AppendLine($"<td class='timestamp'>{localTime:yyyy-MM-dd HH:mm}</td>");
                    sb.AppendLine($"<td>{EscapeHtml(log.HRName)}<br/><small style='color:#888;'>{EscapeHtml(log.HRUsername)}</small></td>");
                    sb.AppendLine($"<td>{EscapeHtml(log.Module)}</td>");
                    sb.AppendLine($"<td>{EscapeHtml(log.Action)}</td>");
                    sb.AppendLine($"<td>{EscapeHtml(log.TargetInfo)}</td>");
                    sb.AppendLine("</tr>");
                }
            }

            sb.AppendLine("</tbody>");
            sb.AppendLine("</table>");

            sb.AppendLine("<div class='footer'>");
            sb.AppendLine($"Total Records: {(logs?.Count ?? 0)} | Confidential HR Report");
            sb.AppendLine("</div>");

            sb.AppendLine("</body>");
            sb.AppendLine("</html>");

            return sb.ToString();
        }

        private string EscapeHtml(string text)
        {
            if (string.IsNullOrEmpty(text)) return "N/A";
            return System.Web.HttpUtility.HtmlEncode(text);
        }
    }
}
