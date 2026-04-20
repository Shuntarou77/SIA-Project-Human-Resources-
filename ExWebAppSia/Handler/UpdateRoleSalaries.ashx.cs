using System;
using System.Web;
using ExWebAppSia.Models;
using System.Threading.Tasks;

namespace ExWebAppSia.Handler
{
    public class UpdateRoleSalaries : HttpTaskAsyncHandler
    {
        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            try
            {
                var roleSalaryService = new RoleSalaryService();
                
                // Force a re-seed by clearing and inserting the latest definitions
                var db = MongoDBHelper.GetDatabase();
                await db.DropCollectionAsync("RoleSalaries");
                
                await roleSalaryService.SeedRoleSalariesAsync();
                
                context.Response.Write("{\"success\": true, \"message\": \"Role salaries updated successfully based on the official registry.\"}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\": false, \"message\": \"" + ex.Message + "\"}");
            }
        }
    }
}
