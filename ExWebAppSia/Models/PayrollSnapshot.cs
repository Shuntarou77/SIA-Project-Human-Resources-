using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace ExWebAppSia.Models
{
    [BsonIgnoreExtraElements]
    public class PayrollSnapshot
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("employee_id")]
        public string EmployeeId { get; set; }

        [BsonElement("employee_number")]
        public string EmployeeNumber { get; set; }

        [BsonElement("full_name")]
        public string FullName { get; set; }

        [BsonElement("department")]
        public string Department { get; set; }

        [BsonElement("basic_salary")]
        public decimal BasicSalary { get; set; }

        [BsonElement("gross_pay")]
        public decimal GrossPay { get; set; }

        [BsonElement("net_pay")]
        public decimal NetPay { get; set; }

        [BsonElement("housing_allowance")]
        public decimal HousingAllowance { get; set; }

        [BsonElement("transport_allowance")]
        public decimal TransportAllowance { get; set; }

        [BsonElement("meal_allowance")]
        public decimal MealAllowance { get; set; }

        [BsonElement("other_allowances")]
        public decimal OtherAllowances { get; set; }

        [BsonElement("total_overtime")]
        public decimal TotalOvertime { get; set; }

        [BsonElement("sss_deduction")]
        public decimal SSSDeduction { get; set; }

        [BsonElement("philhealth_deduction")]
        public decimal PhilHealthDeduction { get; set; }

        [BsonElement("pagibig_deduction")]
        public decimal PagIbigDeduction { get; set; }

        [BsonElement("withholding_tax")]
        public decimal WithholdingTax { get; set; }

        [BsonElement("total_deductions")]
        public decimal TotalDeductions { get; set; }

        [BsonElement("absence_deduction")]
        public decimal AbsenceDeduction { get; set; }

        [BsonElement("total_penalties")]
        public decimal TotalPenalties { get; set; }

        [BsonElement("total_late_hours")]
        public decimal TotalLateHours { get; set; }

        [BsonElement("late_penalty_rate")]
        public decimal LatePenaltyRate { get; set; }

        [BsonElement("days_worked")]
        public int DaysWorked { get; set; }

        [BsonElement("days_present")]
        public int DaysPresent { get; set; }

        [BsonElement("days_absent")]
        public int DaysAbsent { get; set; }

        [BsonElement("pay_period_start")]
        public DateTime PayPeriodStart { get; set; }

        [BsonElement("pay_period_end")]
        public DateTime PayPeriodEnd { get; set; }
    }
}
