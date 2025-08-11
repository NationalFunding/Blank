/**
 * RepaymentUtils class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class RepaymentUtils{
    public static final String STATUS_TEMPORARY_PAUSE = 'Temporary Pause';
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_COMPLETE = 'Complete';
    public static final String STATUS_RECOVERY = 'Recovery';
    public static final String STATUS_WRITE_OFF = 'Write Off';
    public static final String STATUS_UNWIND = 'Unwind';

    public static final String INCOME = 'Income';
    public static final String EXPENSE = 'Expense';
    public static final String ORIGINATION_FEE = 'Origination Fee';
    public static final String BROKER_FEE = 'Broker Fee';
    public static final String REV_SHARE_FEE = 'RevShare';
    
    public static final String QUICK_BRIDGE_FUND_RECORD_NAME = 'Quick Bridge Funding';

    public static final String EXPENSE_RECORD_TYPE_INCOME = Schema.SObjectType.cmbls__Expense__c.getRecordTypeInfosByDeveloperName().get(INCOME).getRecordTypeId();
    public static final String EXPENSE_RECORD_TYPE_EXPENSE = Schema.SObjectType.cmbls__Expense__c.getRecordTypeInfosByDeveloperName().get(EXPENSE).getRecordTypeId();
    
    public static final String TRANSFER_TYPE_INTERNAL = 'Internal Transaction';
    
    public static final String AUTOMATIC_TRANSFER_ERROR_SUBJECT = 'Automatic Loan Transfer Failure for Repayment - {0}';
    public static final String AUTOMATIC_TRANSFER_ERROR_DESCRIPTION = 'Loan Transfer record could not be created';

    public static final String PAYMENT_AMOUNT_METHOD_REMAINING = 'Remaining Settlement Balance';
}