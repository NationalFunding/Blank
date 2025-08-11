/**
 * PointInTimeCalculatedFormulaTest class
 * @author CloudMyBiz (r)
 * @date 12/19/2022
 */

@IsTest
private class PointInTimeCalculatedFormulaTest{

    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Total_Broker_Fee__c = 300;
        repayment.cmbls__Payment_Amount__c = 100;
        repayment.cmbls__Intial_Repayment_Amount__c = 120;
        repayment.cmbls__Funding_Amount__c = 3400;
        repayment.cmbls__Origination_Fee__c = 340;
        repayment.Total_Rev_Share__c = 187;
        insert repayment;

        cmbls__InterestAccrual__c[] accruals = new cmbls__InterestAccrual__c[]{
                TestDataFactory.createInterestAccrual(repayment.Id, 1500, Date.newInstance(2022,1,1), Date.newInstance(2022,1,31))
        };
        insert accruals;

        cmbls__Expense__c[] expenses = new cmbls__Expense__c[]{
                TestDataFactory.createExpense(repayment.Id, RepaymentUtils.ORIGINATION_FEE, 123),
                TestDataFactory.createExpense(repayment.Id, RepaymentUtils.BROKER_FEE, 184),
                TestDataFactory.createExpense(repayment.Id, RepaymentUtils.REV_SHARE_FEE, 354)
        };
        expenses[2].Lead_Provider__c = 'LendingTree';
        insert expenses;

        cmbls__Expense_Accrual__c[] expenseAccruals = new cmbls__Expense_Accrual__c[]{
                TestDataFactory.createExpenseAccrual(repayment.Id, expenses[0].Id, 123),
                TestDataFactory.createExpenseAccrual(repayment.Id, expenses[1].Id, 184),
                TestDataFactory.createExpenseAccrual(repayment.Id, expenses[2].Id, 354)
        };
        insert expenseAccruals;
        Test.stopTest();
    }

    @IsTest
    static void execute(){
        cmbls__Repayment__c repayment = [SELECT Id, Total_Origination_Fee_Expense__c, Total_Broker_Fee_Expense__c, Total_Fundera_RevShare__c,Total_LendingTree_RevShare__c,Total_Strategic_Partner_RevShare__c, cmbls__Interest__c FROM cmbls__Repayment__c];
        Map<String, Object> context = new Map<String, Object>{
                PointInTimeCalculatedFormula.INTEREST_ACCRUAL_TOTAL_ACCRUED_FIELD => 50,
                PointInTimeCalculatedFormula.ORIGINATION_EXPENSE_TOTAL_ACCRUED_FIELD => 50,
                PointInTimeCalculatedFormula.BROKER_EXPENSE_TOTAL_ACCRUED_FIELD => 50,
                PointInTimeCalculatedFormula.REV_SHARE_EXPENSE_TOTAL_ACCRUED_FIELD => 50
        };

        Decimal revShare =  NumberUtils.getDecimal(repayment.Total_Fundera_RevShare__c) +
                NumberUtils.getDecimal(repayment.Total_LendingTree_RevShare__c) +
                NumberUtils.getDecimal(repayment.Total_Strategic_Partner_RevShare__c);

        Test.startTest();
        System.assertEquals(repayment.cmbls__Interest__c - 50, new PointInTimeCalculatedFormula().execute(context, repayment, PointInTimeCalculatedFormula.INTEREST_ACCRUAL_REMAINING_FIELD));
        System.assertEquals(repayment.Total_Origination_Fee_Expense__c - 50, new PointInTimeCalculatedFormula().execute(context, repayment, PointInTimeCalculatedFormula.ORIGINATION_EXPENSE_REMAINING_FIELD));
        System.assertEquals(repayment.Total_Broker_Fee_Expense__c - 50, new PointInTimeCalculatedFormula().execute(context, repayment, PointInTimeCalculatedFormula.BROKER_EXPENSE_REMAINING_FIELD));
        System.assertEquals(revShare - 50, new PointInTimeCalculatedFormula().execute(context, repayment, PointInTimeCalculatedFormula.REV_SHARE_EXPENSE_REMAINING_FIELD));
        Test.stopTest();
    }

    @IsTest
    static void filter(){
        cmbls__InterestAccrual__c interestAccrual = [SELECT Id FROM cmbls__InterestAccrual__c];
        Test.startTest();
        System.assertEquals(true, new PointInTimeCalculatedFormula().filter(interestAccrual, PointInTimeCalculatedFormula.INTEREST_ACCRUAL_TOTAL_ACCRUED_FIELD));
        for(cmbls__Expense_Accrual__c item :[SELECT Id, cmbls__Expense__r.cmbls__Fee_Type__c FROM cmbls__Expense_Accrual__c]){
            String field;
            if(item.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.ORIGINATION_FEE) field = PointInTimeCalculatedFormula.ORIGINATION_EXPENSE_TOTAL_ACCRUED_FIELD;
            if(item.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.BROKER_FEE) field = PointInTimeCalculatedFormula.BROKER_EXPENSE_TOTAL_ACCRUED_FIELD;
            if(item.cmbls__Expense__r.cmbls__Fee_Type__c == RepaymentUtils.REV_SHARE_FEE) field = PointInTimeCalculatedFormula.REV_SHARE_EXPENSE_TOTAL_ACCRUED_FIELD;
            System.assertEquals(true, new PointInTimeCalculatedFormula().filter(item, field));
        }
        Test.stopTest();
    }
}