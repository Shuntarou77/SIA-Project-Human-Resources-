<%@ WebHandler Language="C#" Class="UpdateRoleSalariesInline" %>

using System;
using System.Web;
using ExWebAppSia.Models;
using System.Threading.Tasks;
using MongoDB.Driver;
using MongoDB.Bson;

public class UpdateRoleSalariesInline : HttpTaskAsyncHandler
{
    public override async Task ProcessRequestAsync(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            var roleSalaryService = new RoleSalaryService();
            
            // Force a re-seed by clearing the collections
            var db = MongoDBHelper.GetDatabase();
            await db.DropCollectionAsync("RoleSalaries");
            await db.DropCollectionAsync("ResignedEmployees");
            
            // Re-seed using the updated list in RoleSalaryService.js
            await roleSalaryService.SeedRoleSalariesAsync();
            
            context.Response.Write("{\"success\": true, \"message\": \"Role salaries updated successfully based on the official registry (31 employees + 2 hiring roles).\"}");
        }
        catch (Exception ex)
        {
            context.Response.Write("{\"success\": false, \"message\": \"" + ex.Message.Replace("\"", "\\\"") + "\"}");
        }
    }
}
