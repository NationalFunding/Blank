/**
 * UpdateBankingInformationTest class
 * @author CloudMyBiz (r)
 * @date 3/25/2022
 * @description
 * @group 
 */

@IsTest
private class UpdateBankingInformationTest{
    
    @TestSetup static void setupMethod(){
        cmbls__Loan_Servicing_Settings__c settings = new cmbls__Loan_Servicing_Settings__c();
        settings.cmbls__Allow_Multi_Schedule__c = true;
        insert settings;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
        delete [SELECT Id FROM cmbls__Payment__c];
    
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Bank_Account_Number__c = '1212';
        schedules[0].cmbls__Bank_Routing_Number__c = '999999963';

        schedules[1].cmbls__Bank_Account_Number__c = '1212';
        schedules[1].cmbls__Bank_Routing_Number__c = '999999963';
        insert schedules;
        
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            new cmbls__Payment__c(
                cmbls__Repayment__c = repayment.Id,
                RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
                cmbls__Effective_Date__c = System.today().addDays(1),
                cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
                cmbls__Transaction_Amount__c = 4000,
                cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED
            ),
            new cmbls__Payment__c(
                cmbls__Repayment__c = repayment.Id,
                RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
                cmbls__Effective_Date__c = System.today().addDays(1),
                cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
                cmbls__Transaction_Amount__c = 4000,
                cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_CANCELED
            )
        };
        insert payments;
    }
    
    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c FROM cmbls__Repayment__c];
        UpdateBankingInformation.UpdateRequest mainRequest = new UpdateBankingInformation.UpdateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        mainRequest.bankName = 'WELLS FARGO';
        mainRequest.bankAccountType = 'Checking';
        mainRequest.bankAccountNumber = '456456456';
        mainRequest.bankRoutingNumber = '999999763';
        mainRequest.updateRepaymentSchedules = true;
        mainRequest.updateScheduledPayments = true;
    
        String notes = String.format(UpdateBankingInformation.NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : ''),
            repayment.cmbls__Bank_Name__c, repayment.cmbls__Bank_Routing_Number__c, repayment.cmbls__Bank_Account_Number__c,
            mainRequest.bankName, mainRequest.bankRoutingNumber, mainRequest.bankAccountNumber
        }) + mainRequest.notes;
    
        Test.startTest();
        UpdateBankingInformation.UpdateResult[] results = UpdateBankingInformation.mainInvocableMethod(new UpdateBankingInformation.UpdateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c, Notes__c, cmbls__Type_of_Account__c FROM cmbls__Repayment__c];
        System.assertEquals(notes, repayment.Notes__c);
        System.assertEquals(mainRequest.bankAccountNumber, repayment.cmbls__Bank_Account_Number__c);
        System.assertEquals(mainRequest.bankRoutingNumber, repayment.cmbls__Bank_Routing_Number__c);
        System.assertEquals(mainRequest.bankAccountType, repayment.cmbls__Type_of_Account__c);
        
        cmbls__Payment__c[] payments = [SELECT Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Status__c, cmbls__Notes__c, cmbls__Type_of_Account__c FROM cmbls__Payment__c];
        for(cmbls__Payment__c item :payments){
            if(item.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_CANCELED){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals(null, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(null, item.cmbls__Bank_Routing_Number__c);
                System.assertEquals(null, item.cmbls__Type_of_Account__c);
            }else if(item.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_SCHEDULED){
                System.assertEquals(notes, item.cmbls__Notes__c);
                System.assertEquals(mainRequest.bankAccountNumber, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(mainRequest.bankRoutingNumber, item.cmbls__Bank_Routing_Number__c);
                System.assertEquals(mainRequest.bankAccountType, item.cmbls__Type_of_Account__c);
            }
        }
        
        cmbls__Repayment_Schedule__c[] schedules = [SELECT Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Active__c, cmbls__Notes__c FROM cmbls__Repayment_Schedule__c];
        for(cmbls__Repayment_Schedule__c item :schedules){
            if(!item.cmbls__Active__c){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals('1212', item.cmbls__Bank_Account_Number__c);
                System.assertEquals('999999963', item.cmbls__Bank_Routing_Number__c);
            }else{
                System.assertEquals(mainRequest.bankAccountNumber, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(mainRequest.bankRoutingNumber, item.cmbls__Bank_Routing_Number__c);
            }
        }
    }
    
    @IsTest
    static void mainInvocableMethod2(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c FROM cmbls__Repayment__c];
        UpdateBankingInformation.UpdateRequest mainRequest = new UpdateBankingInformation.UpdateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        mainRequest.bankName = 'WELLS FARGO';
        mainRequest.bankAccountType = 'Checking';
        mainRequest.bankAccountNumber = '456456456';
        mainRequest.bankRoutingNumber = '999999763';
        mainRequest.updateRepaymentSchedules = false;
        mainRequest.updateScheduledPayments = false;
    
        String notes = String.format(UpdateBankingInformation.NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : ''),
            repayment.cmbls__Bank_Name__c, repayment.cmbls__Bank_Routing_Number__c, repayment.cmbls__Bank_Account_Number__c,
            mainRequest.bankName, mainRequest.bankRoutingNumber, mainRequest.bankAccountNumber
        }) + mainRequest.notes;
    
        Test.startTest();
        UpdateBankingInformation.UpdateResult[] results = UpdateBankingInformation.mainInvocableMethod(new UpdateBankingInformation.UpdateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
    
        repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c, Notes__c, cmbls__Type_of_Account__c FROM cmbls__Repayment__c];
        System.assertEquals(notes, repayment.Notes__c);
        System.assertEquals(mainRequest.bankAccountNumber, repayment.cmbls__Bank_Account_Number__c);
        System.assertEquals(mainRequest.bankRoutingNumber, repayment.cmbls__Bank_Routing_Number__c);
        System.assertEquals(mainRequest.bankAccountType, repayment.cmbls__Type_of_Account__c);
        
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Bank_Account_Number__c = :mainRequest.bankAccountNumber OR cmbls__Bank_Routing_Number__c = :mainRequest.bankRoutingNumber]);
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Repayment_Schedule__c WHERE cmbls__Bank_Account_Number__c = :mainRequest.bankAccountNumber OR cmbls__Bank_Routing_Number__c = :mainRequest.bankRoutingNumber]);
    }
    
    @IsTest
    static void mainInvocableMethod3(){
        UpdateBankingInformation.UpdateRequest mainRequest = new UpdateBankingInformation.UpdateRequest();
        mainRequest.repaymentId = 'a6x040000004G89';
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        mainRequest.bankName = 'WELLS FARGO';
        mainRequest.bankAccountType = 'Checking';
        mainRequest.bankAccountNumber = '456456456';
        mainRequest.bankRoutingNumber = '999999763';
        mainRequest.updateRepaymentSchedules = true;
        mainRequest.updateScheduledPayments = true;
        
        Test.startTest();
        UpdateBankingInformation.UpdateResult[] results = UpdateBankingInformation.mainInvocableMethod(new UpdateBankingInformation.UpdateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        Test.stopTest();
    
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c, Notes__c, cmbls__Type_of_Account__c FROM cmbls__Repayment__c];
        System.assertEquals(null, repayment.Notes__c);
        System.assertNotEquals(mainRequest.bankAccountNumber, repayment.cmbls__Bank_Account_Number__c);
        System.assertNotEquals(mainRequest.bankRoutingNumber, repayment.cmbls__Bank_Routing_Number__c);
        System.assertNotEquals(mainRequest.bankAccountType, repayment.cmbls__Type_of_Account__c);
        
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Bank_Account_Number__c = :mainRequest.bankAccountNumber OR cmbls__Bank_Routing_Number__c = :mainRequest.bankRoutingNumber]);
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Repayment_Schedule__c WHERE cmbls__Bank_Account_Number__c = :mainRequest.bankAccountNumber OR cmbls__Bank_Routing_Number__c = :mainRequest.bankRoutingNumber]);
    }
}