/**
 * RSNextPaymentDateBatchTest class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 */

@IsTest
private class RSNextPaymentDateBatchTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.cmbls__Allow_Multi_Schedule__c = true;
        settings.RSNextPaymentDateBatch_Size__c = 100;
        insert settings;
        
        cmbls__Loan_Servicing_Triggers__c triggerSettings = cmbls__Loan_Servicing_Triggers__c.getOrgDefaults();
        triggerSettings.cmbls__Disable_Repayment_Schedule_Trigger__c = true;
        upsert triggerSettings;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
        
        delete [SELECT Id FROM cmbls__Repayment_Schedule__c];
    }
    
    @IsTest
    static void behavior(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c[] records = new cmbls__Repayment_Schedule__c[]{};
        for(Integer i = 0; i < 100;i++){
            cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
            record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
            record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
            records.add(record);
        }
        
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
        Database.insert(records);
        Set<Id> recordIds = new Set<Id>();
        for(cmbls__Repayment_Schedule__c record :[SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c]){
            recordIds.add(record.Id);
            Assert.areEqual(Date.newInstance(2023,8,5), record.cmbls__Next_Payment_Date__c);
        }
        
        Test.startTest();
        Database.executeBatch(new RSNextPaymentDateBatch(recordIds), RSNextPaymentDateBatch.getBatchSize());
        Test.stopTest();
        
        for(cmbls__Repayment_Schedule__c record :[SELECT cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c]){
            Assert.areEqual(Date.newInstance(2023,8,7), record.cmbls__Next_Payment_Date__c);
        }
    }
}