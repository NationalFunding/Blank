/**
 * RepaymentSelectorTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class RepaymentSelectorTest{
    
    @TestSetup static void setupMethod(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    }
    
    @IsTest
    static void queries(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Test.startTest();
        System.assertEquals(repayment.Id, RepaymentSelector.getRepaymentById(repayment.Id).Id);
        System.assertEquals(repayment.Id, RepaymentSelector.getRepaymentAndSchedulesById(repayment.Id).Id);
        System.assertEquals(1, RepaymentSelector.getRepaymentsAndDebitPaymentsByRepaymentIds(new Set<Id>{repayment.Id}).size());
        System.assertEquals(0, RepaymentSelector.getQuickBridgeFundedRecords(new Set<Id>{repayment.Id}).size());
        System.assertEquals(null, RepaymentSelector.getTransferFundRecord(repayment.Id));
        Test.stopTest();
    }
}