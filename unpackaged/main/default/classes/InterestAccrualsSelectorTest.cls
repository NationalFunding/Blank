/**
 * InterestAccrualsSelectorTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class InterestAccrualsSelectorTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        Bank_Account__c bankAccount = TestDataFactory.createBankAccount();
        insert bankAccount;
    
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
        
        cmbls__InterestAccrual__c[] accruals = new cmbls__InterestAccrual__c[]{
            TestDataFactory.createInterestAccrual(repayment.Id, 1500, Date.newInstance(2022,1,1), Date.newInstance(2022,1,31)),
            TestDataFactory.createInterestAccrual(repayment.Id, 1000, Date.newInstance(2022,2,1), Date.newInstance(2022,2,28))
        };
        insert accruals;
        Test.stopTest();
    }
    
    @IsTest
    static void getSumInterestAccrualsByRepayment(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Test.startTest();
        Map<Id, Decimal> records = InterestAccrualsSelector.getSumInterestAccrualsByRepayment(new Set<Id>{repayment.Id});
        System.assertEquals(2500, records.get(repayment.Id));
        Test.stopTest();
    }
}