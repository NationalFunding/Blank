/**
 * RepaymentStatusBatchTest class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description
 * @group 
 */

@IsTest
private class RepaymentStatusBatchTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.cmbls__Allow_Multi_Schedule__c = true;
        insert settings;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
    }
    
    @IsTest
    static void executeResume(){
        Account acc = [SELECT Id FROM Account];
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_TEMPORARY_PAUSE;
        repayment.Resume_Date__c = System.today();
        insert repayment;
    
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(1));
        schedules[1].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(1));
        insert schedules;
        
        Test.startTest();
        Database.executeBatch(new RepaymentStatusBatch());
        Test.stopTest();
        
        repayment = [SELECT Id, Resume_Date__c, cmbls__Status__c, (SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedules__r) FROM cmbls__Repayment__c];
        System.assertEquals(RepaymentUtils.STATUS_ACTIVE, repayment.cmbls__Status__c);
        for(cmbls__Repayment_Schedule__c item :repayment.cmbls__Repayment_Schedules__r){
            System.assert(item.cmbls__Next_Payment_Date__c >= System.today());
        }
    
        String CRON_EXP = '0 0 23 * * ?';
        System.schedule('RepaymentStatusBatch TEST', CRON_EXP, new RepaymentStatusBatch());
    }
    
    @IsTest
    static void executePause(){
        Account acc = [SELECT Id FROM Account];
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_ACTIVE;
        repayment.Pause_Date__c = System.today();
        insert repayment;
        
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(1));
        schedules[1].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(1));
        insert schedules;
        
        Test.startTest();
        Database.executeBatch(new RepaymentStatusBatch());
        Test.stopTest();
        
        repayment = [SELECT Id, Pause_Date__c, cmbls__Status__c, (SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedules__r) FROM cmbls__Repayment__c];
        System.assertEquals(RepaymentUtils.STATUS_TEMPORARY_PAUSE, repayment.cmbls__Status__c);
        for(cmbls__Repayment_Schedule__c item :repayment.cmbls__Repayment_Schedules__r){
            System.assertEquals(cmbls.DatetimeUtils.getNextValidDate(repayment.Pause_Date__c.addDays(1)), item.cmbls__Next_Payment_Date__c);
        }
    }
}