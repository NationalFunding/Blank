/**
 * DisbursementUtils class
 * @author CloudMyBiz (r)
 * @date 4/5/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class DisbursementUtils{
    
    public static final String DISBURSEMENT_PROCESSOR_WIRE = 'Wire';
    public static final String DISBURSEMENT_PROCESSOR_REJECTED = 'Rejected';
    public static final String DISBURSEMENT_STATUS_STAGING = 'Staging';
    public static final String DISBURSEMENT_STATUS_SCHEDULED = 'Scheduled';
    
    public static final String DISBURSEMENT_REASON_CANCELED = 'Cancelled - Customer Needs Wire';

    public static final String DISBURSEMENT_PAYMENT_TYPE_FUNDING = 'Funding';
    public static final String DISBURSEMENT_PAYMENT_TYPE_COMMISSION = 'Commission';
    public static final String DISBURSEMENT_PAYMENT_TYPE_PAYOFF = 'Payoff';
    public static final String DISBURSEMENT_PAYMENT_TYPE_TRANSFER = 'Transfer';
    public static final String DISBURSEMENT_PAYMENT_TYPE_REFUND = 'Refund';
    
    public static final String PAYMENT_RECORD_TYPE_FUNDING = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(DISBURSEMENT_PAYMENT_TYPE_FUNDING).getRecordTypeId();
    public static final String PAYMENT_RECORD_TYPE_COMMISSION = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(DISBURSEMENT_PAYMENT_TYPE_COMMISSION).getRecordTypeId();
    public static final String PAYMENT_RECORD_TYPE_PAYOFF = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(DISBURSEMENT_PAYMENT_TYPE_PAYOFF).getRecordTypeId();
    public static final String PAYMENT_RECORD_TYPE_TRANSFER = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(DISBURSEMENT_PAYMENT_TYPE_TRANSFER).getRecordTypeId();
    public static final String PAYMENT_RECORD_TYPE_REFUND = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(DISBURSEMENT_PAYMENT_TYPE_REFUND).getRecordTypeId();

    public static Boolean isDisbursement(SObject record){
        return record.getSObjectType() == cmbls__Disbursement__c.getSObjectType();
    }

}