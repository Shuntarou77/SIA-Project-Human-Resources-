using MongoDB.Driver;
using ExWebAppSia.Models;
using System;
using System.Threading.Tasks;

public class LegacyCleanup
{
    public static async Task Run()
    {
        var db = MongoDBHelper.GetDatabase();
        var employees = db.GetCollection<Employee>("Employees");
        var users = db.GetCollection<BsonDocument>("Users");
        
        // Specific legacy IDs from the screenshot
        var targetIds = new[] { "26-2211", "26-2212", "26-2213" };
        
        foreach (var id in targetIds)
        {
            var deleteResult = await employees.DeleteOneAsync(Builders<Employee>.Filter.Eq("employeeId", id));
            Console.WriteLine($"Deleted Employee {id}: {deleteResult.DeletedCount}");
            
            var userResult = await users.DeleteOneAsync(Builders<BsonDocument>.Filter.Eq("username", id));
            Console.WriteLine($"Deleted User {id}: {userResult.DeletedCount}");
        }
    }
}
LegacyCleanup.Run().Wait();
