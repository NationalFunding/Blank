/**
 * PaymentSelector class
 * @author CloudMyBiz (r)
 * @date 9/6/2022
 * @description
 * @group 
 */

public inherited sharing class PaymentSelector{
    
    public static cmbls__Payment__c getPaymentById(Id paymentId){
        cmbls__Payment__c[] records = getPaymentByIds(new Set<Id>{paymentId});
        return records.isEmpty() ? null : records[0];
    }
    
    public static cmbls__Payment__c[] getPaymentByIds(Set<Id> paymentIds){
        return [
            SELECT Id, Name, cmbls__Repayment__c, cmbls__Sub_Type__c, cmbls__Transaction_Amount__c, cmbls__ACH_Processor__c, cmbls__Status__c, cmbls__Notes__c
            FROM cmbls__Payment__c
            WHERE Id IN :paymentIds
        ];
    }
    
    public static Map<Id, cmbls__Payment__c[]> getScheduledCreditPaymentsByRepaymentIds(Set<Id> repaymentIds){
        Map<Id, cmbls__Payment__c[]> output = new Map<Id, cmbls__Payment__c[]>();
        cmbls__Payment__c[] records = [
            SELECT Id, cmbls__Notes__c, cmbls__Repayment__c
            FROM cmbls__Payment__c
            WHERE
                RecordTypeId = :PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID AND
                cmbls__Transaction_Type__c = :PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT AND
                cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SCHEDULED AND
                cmbls__Repayment__c IN :repaymentIds
        ];
        for(cmbls__Payment__c item :records){
            if(output.containsKey(item.cmbls__Repayment__c)){
                output.get(item.cmbls__Repayment__c).add(item);
            }else{
                output.put(item.cmbls__Repayment__c, new cmbls__Payment__c[]{item});
            }
        }
        return output;
    }
    
    public static Map<Id, Decimal> getSumPendingDebitPaymentsByRepayment(Set<Id> repaymentIds){
        Map<Id, Decimal> output = new Map<Id, Decimal>();
        AggregateResult[] records = [
            SELECT SUM(cmbls__Transaction_Amount__c) total, cmbls__Repayment__c repayment
            FROM cmbls__Payment__c
            WHERE cmbls__Repayment__c IN :repaymentIds AND
                  cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PENDING AND
                  RecordTypeId = :PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID
            GROUP BY cmbls__Repayment__c
        ];
        for(AggregateResult item :records) output.put((Id)item.get('repayment'), (Decimal)item.get('total'));
        return output;
    }
    
    public static Map<Id, Decimal> getSumPendingSettledDebitPaymentsByRepayment(Set<Id> repaymentIds){
        Map<Id, Decimal> output = new Map<Id, Decimal>();
        AggregateResult[] records =  [
            SELECT SUM(cmbls__Interest_Payment_Amt__c) total, cmbls__Repayment__c repayment
            FROM cmbls__Payment__c
            WHERE cmbls__Repayment__c IN :repaymentIds AND
                  cmbls__Status__c IN :new Set<String>{PaymentUtils.PAYMENT_STATUS_PENDING, PaymentUtils.PAYMENT_STATUS_SETTLED} AND
                  RecordTypeId = :PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID
            GROUP BY cmbls__Repayment__c
        ];
        for(AggregateResult item :records) output.put((Id)item.get('repayment'), (Decimal)item.get('total'));
        return output;
    }
	
	public static Map<Id, Set<Id>> getScheduledPaymentsByBatchIds(Set<Id> achBatches){
        Map<Id, Set<Id>> output = new Map<Id, Set<Id>>();
        for(cmbls__Payment__c item :[SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c WHERE cmbls__Status__c =:PaymentUtils.PAYMENT_STATUS_SCHEDULED AND cmbls__ACH_Batch__c IN :achBatches]){
            if(!output.containsKey(item.cmbls__ACH_Batch__c)) output.put(item.cmbls__ACH_Batch__c, new Set<Id>());
            output.get(item.cmbls__ACH_Batch__c).add(item.Id);
        }
        return output;
    }
}