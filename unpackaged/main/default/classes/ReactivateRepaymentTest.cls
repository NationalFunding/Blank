/**
 * ReactivateRepaymentTest class
 * @author CloudMyBiz (r)
 * @date 3/25/2022
 * @description
 * @group 
 */

@IsTest
private class ReactivateRepaymentTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.cmbls__Allow_Multi_Schedule__c = true;
        insert settings;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_TEMPORARY_PAUSE;
        insert repayment;
        
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10));
        
        schedules[1].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10));
        insert schedules;
    }
    
    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c FROM cmbls__Repayment__c];
        ReactivateRepayment.ReactivateRequest mainRequest = new ReactivateRepayment.ReactivateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        
        Test.startTest();
        ReactivateRepayment.ReactivateResult[] results = ReactivateRepayment.mainInvocableMethod(new ReactivateRepayment.ReactivateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        repayment = [SELECT Id, cmbls__Status__c, Notes__c FROM cmbls__Repayment__c];
        System.assert(repayment.Notes__c.startsWith('Repayment status updated to Active on '));
        System.assertEquals(RepaymentUtils.STATUS_ACTIVE, repayment.cmbls__Status__c);
        
        cmbls__Repayment_Schedule__c[] schedules = [SELECT Id, cmbls__Next_Payment_Date__c, cmbls__Notes__c, cmbls__Active__c FROM cmbls__Repayment_Schedule__c];
        for(cmbls__Repayment_Schedule__c item :schedules){
            if(!item.cmbls__Active__c){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals(cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10)), item.cmbls__Next_Payment_Date__c);
            }else{
                System.assert(item.cmbls__Notes__c.startsWith('"Next Payment Date" reset after Repayment status updating to Active on '));
                System.assertNotEquals(cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10)), item.cmbls__Next_Payment_Date__c);
            }
        }
    }
    
    @IsTest
    static void mainInvocableMethod2(){
        ReactivateRepayment.ReactivateRequest mainRequest = new ReactivateRepayment.ReactivateRequest();
        mainRequest.repaymentId = 'a6x040000004G89';
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        
        Test.startTest();
        ReactivateRepayment.ReactivateResult[] results = ReactivateRepayment.mainInvocableMethod(new ReactivateRepayment.ReactivateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        Test.stopTest();
    
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Status__c, Notes__c FROM cmbls__Repayment__c];
        System.assertEquals(null, repayment.Notes__c);
        System.assertEquals(RepaymentUtils.STATUS_TEMPORARY_PAUSE, repayment.cmbls__Status__c);
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Repayment_Schedule__c WHERE cmbls__Next_Payment_Date__c != :cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10))]);
    }
}