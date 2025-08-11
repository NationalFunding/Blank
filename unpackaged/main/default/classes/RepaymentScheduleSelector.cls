/**
 * RepaymentScheduleSelector class
 * @author CloudMyBiz (r)
 * @date 8/17/2023
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class RepaymentScheduleSelector{
    public static cmbls__Repayment_Schedule__c[] getRepaymentSchedulesByRepaymentIds(Set<Id> repaymentIds){
        return [
            SELECT
                Id, cmbls__Next_Payment_Date__c, cmbls__Active__c, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c,
                cmbls__Notes__c
            FROM cmbls__Repayment_Schedule__c
            WHERE cmbls__Repayment__c IN :repaymentIds
        ];
    }
    
    public static Map<Id, cmbls__Repayment_Schedule__c[]> getActiveRepaymentSchedulesByRepaymentIds(Set<Id> repaymentIds){
        Map<Id, cmbls__Repayment_Schedule__c[]> output = new Map<Id, cmbls__Repayment_Schedule__c[]>();
        for(cmbls__Repayment_Schedule__c item :[SELECT Id, cmbls__Repayment__c, cmbls__ACH_Processor__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c IN :repaymentIds AND cmbls__Active__c = TRUE]){
            if(!output.containsKey(item.cmbls__Repayment__c)) output.put(item.cmbls__Repayment__c, new cmbls__Repayment_Schedule__c[]{});
            output.get(item.cmbls__Repayment__c).add(item);
        }
        return output;
    }
}