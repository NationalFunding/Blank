/**
 * RepaymentSelector class
 * @author CloudMyBiz (r)
 * @date 8/11/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class RepaymentSelector{
    
    public static cmbls__Repayment__c getRepaymentAndSchedulesById(Id repaymentId){
        return [
            SELECT
                Id, cmbls__Status__c, Notes__c, (SELECT Id, cmbls__Notes__c FROM cmbls__Repayment_Schedules__r WHERE cmbls__Active__c = TRUE)
            FROM cmbls__Repayment__c
            WHERE Id = :repaymentId
        ];
    }
    
    public static cmbls__Repayment__c getRepaymentById(Id repaymentId){
        cmbls__Repayment__c[] output = getRepaymentsById(new Set<Id>{repaymentId});
        return output.isEmpty() ? null : output[0];
    }
    
    public static cmbls__Repayment__c[] getRepaymentsById(Set<Id> repaymentIds){
        return [
            SELECT
                Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Bank_Name__c,
                cmbls__Type_of_Account__c, Notes__c, cmbls__ACH_Processor__c, cmbls__Primary_Fund__c,
                Product_Type__c, cmbls__Primary_Fund__r.Name, cmbls__Status__c
            FROM cmbls__Repayment__c WHERE Id IN :repaymentIds
        ];
    }
    
    public static cmbls__Repayment__c[] getRepaymentsByIdWithScheduledPayments(Set<Id> repaymentIds){
        return [
            SELECT
                Id, Product_Type__c, cmbls__Primary_Fund__r.Name,
                (SELECT Id FROM cmbls__Payments__r WHERE cmbls__Status__c = :Constant.STATUS_SCHEDULED)
            FROM cmbls__Repayment__c WHERE Id IN :repaymentIds
        ];
    }
    
    public static cmbls__Repayment__c[] getRepaymentsAndDebitPaymentsByRepaymentIds(Set<Id> repaymentIds){
        return [
            SELECT
                Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Bank_Name__c,
                cmbls__Type_of_Account__c, Notes__c, cmbls__ACH_Processor__c, cmbls__Primary_Fund__c,
                cmbls__Principal_Balance_Amount__c, cmbls__Accrued_Interest__c, (
                    SELECT Id, cmbls__Transaction_Amount__c, cmbls__Interest_Payment_Amt__c
                    FROM cmbls__Payments__r
                    WHERE
                        RecordTypeId = :PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID AND
                        cmbls__Status__c IN :new Set<String>{PaymentUtils.PAYMENT_STATUS_SETTLED, PaymentUtils.PAYMENT_STATUS_PENDING}
                )
            FROM cmbls__Repayment__c WHERE Id IN :repaymentIds
        ];
    }
    
    public static cmbls__Repayment__c[] getQuickBridgeFundedRecords(Set<Id> repaymentIds){
        return [
            SELECT  Id, cmbls__Funded_Date__c, Opportunity__r.Lender_Account__c, cmbls__Principal_Balance_Amount__c,
                    Total_Broker_Fee__c, cmbls__Primary_Fund__c, cmbls__Loan_Start_Date__c, cmbls__Accrued_Interest__c,
                    cmbls__Interest_Paid__c, cmbls__Interest_Credited__c, cmbls__Status__c, cmbls__Funding_Amount__c,
                    (SELECT Id FROM cmbls__Loan_Transfers__r LIMIT 1)
            FROM cmbls__Repayment__c
            WHERE
                Opportunity__r.Lender_Account__r.Name = :RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME AND
                Migrated__c = FALSE AND
                cmbls__Primary_Fund__r.Name = 'Quick Bridge' AND
                Id IN :repaymentIds
        ];
    }
    
    public static cmbls__Fund__c getTransferFundRecord(Id recordId){
        cmbls__Fund__c[] records = [
            SELECT Id, cmbls__Default_Debit_ACH_Processor__c, cmbls__Default_Credit_ACH_Processor__c FROM cmbls__Fund__c WHERE Id = :recordId
        ];
        return records.isEmpty() ? null : records[0];
    }
}