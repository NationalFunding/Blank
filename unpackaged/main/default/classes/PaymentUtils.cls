/**
 * PaymentUtils class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public with sharing class PaymentUtils{
    
    public static final String PAYMENT_STATUS_SCHEDULED = 'Scheduled';
    public static final String PAYMENT_STATUS_CANCELED = 'Canceled';
    public static final String PAYMENT_STATUS_PENDING = 'Pending';
    public static final String PAYMENT_STATUS_FAILED = 'Failed';
    public static final String PAYMENT_STATUS_SETTLED = 'Settled';
    public static final String PAYMENT_STATUS_FEE_APPLIED = 'Fees Applied';
    public static final String PAYMENT_STATUS_PRE_PENDING = 'Pre-Pending';
    
    public static final String PAYMENT_METHOD_ACH = 'ACH';
    
    public static final String PAYMENT_SUBTYPE_REVERSAL = 'Reversal';
    public static final String PAYMENT_SUBTYPE_MATURITY = 'Maturity Default';
    
    public static final String PAYMENT_TRANSACTION_TYPE_FEE = 'Fee';
    public static final String PAYMENT_TRANSACTION_TYPE_ADJUSTMENT = 'Adjustment';
    public static final String PAYMENT_TRANSACTION_TYPE_PAYMENT = 'Payment';
    
    public static final String PAYMENT_RECORD_TYPE_CREDIT = 'Credit';
    public static final String PAYMENT_RECORD_TYPE_DEBIT = 'Debit';
    public static final String PAYMENT_RECORD_TYPE_CREDIT_ID = Schema.SObjectType.cmbls__Payment__c.getRecordTypeInfosByDeveloperName().get(PAYMENT_RECORD_TYPE_CREDIT).getRecordTypeId();
    public static final String PAYMENT_RECORD_TYPE_DEBIT_ID = Schema.SObjectType.cmbls__Payment__c.getRecordTypeInfosByDeveloperName().get(PAYMENT_RECORD_TYPE_DEBIT).getRecordTypeId();

    public static Boolean isPayment(SObject record){
        return record.getSObjectType() == cmbls__Payment__c.getSObjectType();
    }
}