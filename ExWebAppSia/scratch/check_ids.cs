using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ExWebAppSia.Models;
using MongoDB.Driver;

public class Program 
{
    public static async Task Main() 
    {
        var helper = new EmployeeService();
        var all = await helper.GetAllEmployeesAsync();
        var bad = all.Where(e => !e.EmployeeId.StartsWith("SHE-")).ToList();
        
        Console.WriteLine($"Found {bad.Count} employees with non-SHE format.");
        foreach (var b in bad) 
        {
            Console.WriteLine($"ID: {b.EmployeeId}, Name: {b.FullName}");
        }
    }
}
