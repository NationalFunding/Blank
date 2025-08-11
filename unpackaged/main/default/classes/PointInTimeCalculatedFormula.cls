/**
 * PointInTimeCalculatedFormula class
 * @author CloudMyBiz (r)
 * @date 11/25/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global inherited sharing class PointInTimeCalculatedFormula extends cmbls.PointInTimeCalculatedField{

    public static final String INTEREST_ACCRUAL_TOTAL_ACCRUED_FIELD = 'Interest_Accrual_Total_Accrued';
    public static final String ORIGINATION_EXPENSE_TOTAL_ACCRUED_FIELD = 'Origination_Expense_Total_Accrued';
    public static final String BROKER_EXPENSE_TOTAL_ACCRUED_FIELD = 'Broker_Expense_Total_Accrued';
    public static final String REV_SHARE_EXPENSE_TOTAL_ACCRUED_FIELD = 'RevShare_Expense_Total_Accrued';
    public static final String INTEREST_ACCRUAL_REMAINING_FIELD = 'Interest_Accrual_Remaining';
    public static final String ORIGINATION_EXPENSE_REMAINING_FIELD = 'Origination_Expense_Remaining';
    public static final String BROKER_EXPENSE_REMAINING_FIELD = 'Broker_Expense_Remaining';
    public static final String REV_SHARE_EXPENSE_REMAINING_FIELD = 'RevShare_Expense_Remaining';

    global override Object execute(Map<String, Object> context, SObject record, String fieldApiName){
        if(isRepayment(record)){
            cmbls__Repayment__c repayment = (cmbls__Repayment__c)record;
            if(INTEREST_ACCRUAL_REMAINING_FIELD.equalsIgnoreCase(fieldApiName)){
                return NumberUtils.getDecimal(repayment.cmbls__Interest__c) - NumberUtils.getDecimal((Decimal)context.get(INTEREST_ACCRUAL_TOTAL_ACCRUED_FIELD));
            }else if(ORIGINATION_EXPENSE_REMAINING_FIELD.equalsIgnoreCase(fieldApiName)){
                return NumberUtils.getDecimal(repayment.Total_Origination_Fee_Expense__c) - NumberUtils.getDecimal((Decimal)context.get(ORIGINATION_EXPENSE_TOTAL_ACCRUED_FIELD)).setScale(2);
            }else if(BROKER_EXPENSE_REMAINING_FIELD.equalsIgnoreCase(fieldApiName)){
                return NumberUtils.getDecimal(repayment.Total_Broker_Fee_Expense__c) - NumberUtils.getDecimal((Decimal)context.get(BROKER_EXPENSE_TOTAL_ACCRUED_FIELD)).setScale(2);
            }else if(REV_SHARE_EXPENSE_REMAINING_FIELD.equalsIgnoreCase(fieldApiName)){
                Decimal revShare =  NumberUtils.getDecimal(repayment.Total_Fundera_RevShare__c) +
                        NumberUtils.getDecimal(repayment.Total_LendingTree_RevShare__c) +
                        NumberUtils.getDecimal(repayment.Total_Strategic_Partner_RevShare__c);

                return revShare - NumberUtils.getDecimal((Decimal)context.get(REV_SHARE_EXPENSE_TOTAL_ACCRUED_FIELD)).setScale(2);
            }
        }
        return null;
    }

    global override Boolean filter(SObject record, String fieldApiName){
        Boolean result = false;
        if(!isValidObject(record)) return result;
        if(isInterestAccrual(record)){
            if(INTEREST_ACCRUAL_TOTAL_ACCRUED_FIELD.equalsIgnoreCase(fieldApiName)){
                result = true;
            }
        }else if(isExpenseAccrual(record)){
            cmbls__Expense_Accrual__c expenseAccrual = (cmbls__Expense_Accrual__c)record;
            if(ORIGINATION_EXPENSE_TOTAL_ACCRUED_FIELD.equalsIgnoreCase(fieldApiName)){
                result = expenseAccrual.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.ORIGINATION_FEE;
            }else if(BROKER_EXPENSE_TOTAL_ACCRUED_FIELD.equalsIgnoreCase(fieldApiName)){
                result = expenseAccrual.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.BROKER_FEE;
            }else if(REV_SHARE_EXPENSE_TOTAL_ACCRUED_FIELD.equalsIgnoreCase(fieldApiName)){
                result = expenseAccrual.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.REV_SHARE_FEE;
            }
        }
        return result;
    }

    private static Boolean isValidObject(SObject record){
        return  record != null && (isExpenseAccrual(record) || isInterestAccrual(record));
    }

    private static Boolean isExpenseAccrual(SObject record){
        return record.Id.getSobjectType() == cmbls__Expense_Accrual__c.getSObjectType();
    }

    private static Boolean isInterestAccrual(SObject record){
        return record.Id.getSobjectType() == cmbls__InterestAccrual__c.getSObjectType();
    }

    private static Boolean isRepayment(SObject record){
        return record.Id.getSobjectType() == cmbls__Repayment__c.getSObjectType();
    }
}