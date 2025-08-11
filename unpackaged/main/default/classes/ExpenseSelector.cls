/**
 * ExpenseSelector class
 * @author CloudMyBiz (r)
 * @date 9/13/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class ExpenseSelector{

    public static Map<Id, Decimal> getSumOriginationFeeExpensesByRepayment(Set<Id> repaymentIds){
        Map<Id, Decimal> output = new Map<Id, Decimal>();
    
        AggregateResult[] records = [
            SELECT SUM(cmbls__Amount__c) total, cmbls__Repayment__c repayment
            FROM cmbls__Expense__c
            WHERE cmbls__Repayment__c IN :repaymentIds AND
            cmbls__Fee_Type__c = :RepaymentUtils.ORIGINATION_FEE
            GROUP BY cmbls__Repayment__c
        ];
        for(AggregateResult item :records) output.put((Id)item.get('repayment'), (Decimal)item.get('total'));
        
        return output;
    }
    
    public static Map<Id, Decimal> getSumExpenseBrokerFeesByRepayment(Set<Id> repaymentIds){
        Map<Id, Decimal> output = new Map<Id, Decimal>();
    
        AggregateResult[] records = [
            SELECT SUM(cmbls__Amount__c) total, cmbls__Repayment__c repayment
            FROM cmbls__Expense__c
            WHERE cmbls__Repayment__c IN :repaymentIds AND
            cmbls__Fee_Type__c = :RepaymentUtils.BROKER_FEE
            GROUP BY cmbls__Repayment__c
        ];
        for(AggregateResult item :records) output.put((Id)item.get('repayment'), (Decimal)item.get('total'));
    
        return output;
    }
}