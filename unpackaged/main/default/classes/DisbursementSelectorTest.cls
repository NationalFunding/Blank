/**
 * DisbursementSelectorTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class DisbursementSelectorTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;
    
        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_PAYOFF, DisbursementUtils.DISBURSEMENT_STATUS_STAGING, Constant.ACH_PROCESSOR_NF_FUNDING);
        dis.Opportunity__c = opp.Id;
        insert dis;
        
        Test.stopTest();
    }
    
    @IsTest
    static void getStagingDisbursementsForGivenOpportunities(){
        Opportunity opp = [SELECT Id FROM Opportunity];
        Test.startTest();
        cmbls__Disbursement__c[] records = DisbursementSelector.getStagingDisbursementsForGivenOpportunities(new Set<Id>{opp.Id});
        System.assertEquals(1, records.size());
        System.assert(DisbursementUtils.isDisbursement(records[0]));
        Test.stopTest();
    }
}