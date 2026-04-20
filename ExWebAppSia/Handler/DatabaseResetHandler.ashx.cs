using System;
using System.Web;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using System.Web.Script.Serialization;

namespace ExWebAppSia.Handler
{
    public class DatabaseResetHandler : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            var serializer = new JavaScriptSerializer();

            try
            {
                // Trigger the reset and seed
                await FullDatabaseSeeder.ResetAndSeedDatabaseAsync();

                context.Response.Write(serializer.Serialize(new { 
                    success = true, 
                    message = "Database reset and seeded successfully with new employee registry from PDF.",
                    count = 31,
                    credentials = new[] {
                        new { role = "Super Admin (HR Manager)", username = "princessm.peregrino@gmail.com", password = "SHE-001 (Employee ID)" },
                        new { role = "President", username = "mikyllapodiotan@gmail.com", password = "SHE-031 (Employee ID)" },
                        new { role = "Finance Manager", username = "aparri.liezette@shessentials.com", password = "SHE-021 (Employee ID)" }
                    }
                }));
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write(serializer.Serialize(new { 
                    success = false, 
                    message = "Error: " + ex.Message,
                    stackTrace = ex.StackTrace 
                }));
            }
        }
    }
}
