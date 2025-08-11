/**
 * PauseResumeRepaymentScheduleTest class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description
 * @group 
 */

@IsTest
private class PauseResumeRepaymentScheduleTest{
    
    @TestSetup static void setupMethod(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
        
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(7));
        schedules[1].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(7));
        insert schedules;
    }
    
    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id, Pause_Date__c, Resume_Date__c FROM cmbls__Repayment__c];
        System.assertEquals(null, repayment.Pause_Date__c);
        System.assertEquals(null, repayment.Resume_Date__c);
        PauseResumeRepaymentSchedule.PauseResumeRequest mainRequest = new PauseResumeRepaymentSchedule.PauseResumeRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.resumeDate = System.today().addDays(10);
        
        Test.startTest();
        PauseResumeRepaymentSchedule.PauseResumeResult[] mainResponse = PauseResumeRepaymentSchedule.mainInvocableMethod(new PauseResumeRepaymentSchedule.PauseResumeRequest[]{});
        System.assertEquals(1, mainResponse.size());
        System.assert(mainResponse[0].output.startsWith('Unable to Pause the Repayment Schedule'));
        
        repayment = [SELECT Id, Pause_Date__c, Resume_Date__c FROM cmbls__Repayment__c];
        System.assertEquals(null, repayment.Pause_Date__c);
        System.assertEquals(null, repayment.Resume_Date__c);
        
        mainResponse = PauseResumeRepaymentSchedule.mainInvocableMethod(new PauseResumeRepaymentSchedule.PauseResumeRequest[]{mainRequest});
        System.assertEquals(1, mainResponse.size());
        System.assertEquals(String.format(PauseResumeRepaymentSchedule.SUCCESS_MESSAGE, new String[]{System.today().addDays(10).format()}), mainResponse[0].output);
    
        repayment = [SELECT Id, Pause_Date__c, Resume_Date__c FROM cmbls__Repayment__c];
        System.assertEquals(System.today(), repayment.Pause_Date__c);
        System.assertEquals(System.today().addDays(10), repayment.Resume_Date__c);
        Test.stopTest();
    }
}