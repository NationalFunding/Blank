/**
 * RepaymentScheduleServiceTest class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 */

@IsTest
private class RepaymentScheduleServiceTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.cmbls__Allow_Multi_Schedule__c = true;
        insert settings;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    }
    
    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        delete [SELECT Id FROM cmbls__Repayment_Schedule__c];
        CreateRepaymentSchedule.CreateRequest mainRequest = new CreateRepaymentSchedule.CreateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.expectedFirstPaymentDate = System.today().addDays(15);
        mainRequest.paymentAmount = 2000;
        mainRequest.endDate = System.today().addMonths(2);
        mainRequest.paymentFrequency = 'Monthly';
        mainRequest.day = '1';
        mainRequest.isDefault = false;
        mainRequest.bankAccountNumber = '1212';
        mainRequest.bankRoutingNumber = '999999963';
        mainRequest.notes = 'Test Notes';
        
        Test.startTest();
        CreateRepaymentSchedule.CreateResult[] results = CreateRepaymentSchedule.mainInvocableMethod(new CreateRepaymentSchedule.CreateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        cmbls__Repayment_Schedule__c record = [SELECT Id, cmbls__Notes__c, cmbls__Installment_Amount__c, cmbls__Start_Date__c, cmbls__Next_Payment_Date__c, cmbls__End_Date__c, cmbls__Preset__c, cmbls__Days__c, cmbls__Active__c, cmbls__Default__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c = :repayment.Id];
        System.assertEquals(record.Id, results[0].output);
        System.assertEquals(cmbls.DatetimeUtils.getNextValidDate(mainRequest.expectedFirstPaymentDate), record.cmbls__Next_Payment_Date__c);
        System.assertEquals(mainRequest.paymentAmount, record.cmbls__Installment_Amount__c);
        System.assertEquals(mainRequest.paymentFrequency, record.cmbls__Preset__c);
        System.assertEquals(mainRequest.day, record.cmbls__Days__c);
        System.assertEquals(true, record.cmbls__Active__c);
        System.assertEquals(mainRequest.isDefault, record.cmbls__Default__c);
        System.assertEquals(mainRequest.notes, record.cmbls__Notes__c);
        
        Set<Date> holidays = cmbls.DatetimeUtils.getAllHolidays();
        Date startDate = RepaymentScheduleService.getPreviousValidDate(mainRequest.expectedFirstPaymentDate, holidays);
        System.assertEquals(startDate, record.cmbls__Start_Date__c);
    }
    
    @IsTest
    static void getRepaymentSchedulesByRepaymentIds(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Test.startTest();
        cmbls__Repayment_Schedule__c[] result = RepaymentScheduleSelector.getRepaymentSchedulesByRepaymentIds(new Set<Id>{repayment.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void getPreviousValidDate(){
        Set<Date> holidays = cmbls.DatetimeUtils.getAllHolidays();
        RepaymentScheduleService.getPreviousValidDate(System.today().addDays(15), holidays);
    }
    
    @IsTest
    static void validateNextPaymentDate(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__ACH_Processor__c FROM cmbls__Repayment__c];
        cmbls__Repayment_Schedule__c schedule = new cmbls__Repayment_Schedule__c(
            cmbls__Repayment__c = repayment.Id,
            cmbls__Next_Payment_Date__c = Date.newInstance(2023,8,5) //Saturday
        );
        
        RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
        Test.startTest();
        cmbls__Repayment_Schedule__c newSchedule = RepaymentScheduleService.validateNextPaymentDate(schedule);
        Test.stopTest();
        
        Assert.areEqual(Date.newInstance(2023,8,7), newSchedule.cmbls__Next_Payment_Date__c);
    }
}