@IsTest
private class RepaymentTriggerTest{
    
    @TestSetup static void setupMethod(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
    }
    
    @IsTest
    static void createExpenses(){
        Account acc = [SELECT Id FROM Account];
        
        Test.startTest();
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Total_Broker_Fee__c = 100;
        repayment.cmbls__Origination_Fee__c = 120;
        insert repayment;
        Test.stopTest();
    
        System.assertEquals(1, [
            SELECT COUNT() FROM cmbls__Expense__c WHERE
                cmbls__Repayment__c = :repayment.Id AND
                cmbls__Amount__c =:repayment.Total_Broker_Fee__c AND
                RecordTypeId = :RepaymentUtils.EXPENSE_RECORD_TYPE_EXPENSE AND
                cmbls__Fee_Type__c = :RepaymentUtils.BROKER_FEE
        ]);
    
        System.assertEquals(1, [
            SELECT COUNT() FROM cmbls__Expense__c WHERE
                cmbls__Repayment__c = :repayment.Id AND
                cmbls__Amount__c =:repayment.cmbls__Origination_Fee__c AND
                RecordTypeId = :RepaymentUtils.EXPENSE_RECORD_TYPE_INCOME AND
                cmbls__Fee_Type__c = :RepaymentUtils.ORIGINATION_FEE
        ]);
        
        System.assertEquals(2, [SELECT COUNT() FROM cmbls__Expense__c WHERE cmbls__Repayment__c = :repayment.Id]);
    }
}