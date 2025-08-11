/**
 * RepaymentScheduleTriggerTest class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 */

@IsTest
private class RepaymentScheduleTriggerTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.RSNextPaymentDateBatch_Size__c = 100;
        settings.cmbls__Allow_Multi_Schedule__c = true;
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
    static void insertOneRecord(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_WRITE_OFF;
        update repayment;
        cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
        record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
        record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
        record.cmbls__Payment_Amount_Method__c = 'Fixed Amount';

        Test.startTest();
        Database.insert(record);
        Test.stopTest();
        
        record = [SELECT Id, cmbls__Next_Payment_Date__c, cmbls__Payment_Amount_Method__c FROM cmbls__Repayment_Schedule__c WHERE Id = :record.Id];
        Assert.areEqual(Date.newInstance(2023,8,7), record.cmbls__Next_Payment_Date__c);
        Assert.areEqual(RepaymentUtils.PAYMENT_AMOUNT_METHOD_REMAINING, record.cmbls__Payment_Amount_Method__c);

        repayment = [SELECT Id, cmbls__Status__c FROM cmbls__Repayment__c WHERE Id = :repayment.Id];
        Assert.areEqual(RepaymentUtils.STATUS_RECOVERY, repayment.cmbls__Status__c);
    }
    
    @IsTest
    static void insertMultipleRecords(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c[] records = new cmbls__Repayment_Schedule__c[]{};
        for(Integer i = 0; i < 100;i++){
            cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
            record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
            record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
            records.add(record);
        }
        
        Test.startTest();
        Database.insert(records);
        Test.stopTest();
        
        for(cmbls__Repayment_Schedule__c record :[SELECT cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c]){
            Assert.areEqual(Date.newInstance(2023,8,7), record.cmbls__Next_Payment_Date__c);
        }
    }
    
    @IsTest
    static void updateOneRecord(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
        record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
        record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,4); //Friday
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
        Database.insert(record);
        
        Test.startTest();
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = true;
        record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
        update record;
        Test.stopTest();
        
        record = [SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c WHERE Id = :record.Id];
        Assert.areEqual(Date.newInstance(2023,8,7), record.cmbls__Next_Payment_Date__c);
    }
    
    @IsTest
    static void updateMultipleRecords(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c[] records = new cmbls__Repayment_Schedule__c[]{};
        for(Integer i = 0; i < 100;i++){
            cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
            record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
            record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,4); //Friday
            records.add(record);
        }
        Database.insert(records);
        
        Test.startTest();
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = true;
        for(cmbls__Repayment_Schedule__c record :records){
            record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
        }
        Database.update(records);
        Test.stopTest();
        
        for(cmbls__Repayment_Schedule__c record :[SELECT cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c]){
            Assert.areEqual(Date.newInstance(2023,8,7), record.cmbls__Next_Payment_Date__c);
        }
    }
    
    @IsTest
    static void flagOnFalse(){
        cmbls__Repayment__c repayment = [SELECT Id, RecordType.Name FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c record = TestDataFactory.createRepaymentSchedule(repayment.Id);
        record.cmbls__Start_Date__c = Date.newInstance(2023,1,1);
        record.cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5); //Saturday
        
        Test.startTest();
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
        Database.insert(record);
        Test.stopTest();
        
        record = [SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c WHERE Id = :record.Id];
        Assert.areEqual(Date.newInstance(2023,8,5), record.cmbls__Next_Payment_Date__c);
    }
}