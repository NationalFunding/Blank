/**
 * ChartOfAccountBatchTest class
 * @author CloudMyBiz (r)
 * @date 5/27/2023
 */

@IsTest
private class ChartOfAccountBatchTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
        
        cmbls__Fund__c[] fundRecords = new cmbls__Fund__c[]{
            TestDataFactory.createFund(RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME, bankingInformation),
            TestDataFactory.createFund('National Funding', bankingInformation)
        };
        insert fundRecords;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Product_Type__c = 'LOAN';
        repayment.cmbls__Primary_Fund__c = fundRecords[1].Id;
        insert repayment;
        
        cmbls__Payment__c payment = TestDataFactory.createPayment(repayment.Id,'Credit', 'Settled', 100.00, Date.today(), Constant.ACH_PROCESSOR_NF_FUNDING);
        insert payment;
        
        cmbls__Loan_Transfer__c loanTransfer = TestDataFactory.createLoanTransfer(fundRecords[1].Id, repayment.Id);
        loanTransfer.cmbls__Previous_Fund__c = fundRecords[0].Id;
        insert loanTransfer;
        
        ChartOfAccountServiceTest.createChartOfAccountData(fundRecords[0].Id, fundRecords[1].Id);
        
        delete [SELECT Id FROM cmbls__Queued_Event__c];
        delete [SELECT Id FROM cmbls__Debug_Log__c];
        Test.stopTest();
    }
    
    @IsTest
    static void executeBatchNoErrors(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c LIMIT 1];
        insert new cmbls__Queued_Event__c[]{
            new cmbls__Queued_Event__c(cmbls__Number_of_Attempts__c = 1, cmbls__Record_Id__c = payment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE),
            new cmbls__Queued_Event__c(cmbls__Number_of_Attempts__c = 1, cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE)
        };
        Assert.areEqual(2, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
        cmbls__Queued_Event__c[] queuedEvents = [
            SELECT Id, cmbls__Date_Processed__c, Deleted_Record_Id__c, cmbls__Last_Attempt__c, cmbls__Number_of_Attempts__c, cmbls__Record_Id__c
            FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE
        ];
        Assert.areEqual(2, queuedEvents.size());
        for(cmbls__Queued_Event__c item :queuedEvents){
            Assert.areNotEqual(null, item.cmbls__Date_Processed__c);
            Assert.areNotEqual(null, item.cmbls__Last_Attempt__c);
            Assert.isFalse(item.Deleted_Record_Id__c);
            Assert.areEqual(2, item.cmbls__Number_of_Attempts__c);
        }
    }
    
    @IsTest
    static void executeBatchDeletedRecord(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c LIMIT 1];
        insert new cmbls__Queued_Event__c[]{
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = payment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE),
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE)
        };
        Assert.areEqual(2, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        delete payment;
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
        cmbls__Queued_Event__c[] queuedEvents = [
            SELECT Id, cmbls__Date_Processed__c, Deleted_Record_Id__c, cmbls__Last_Attempt__c, cmbls__Number_of_Attempts__c, cmbls__Record_Id__c
            FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE
        ];
        Assert.areEqual(2, queuedEvents.size());
        for(cmbls__Queued_Event__c item :queuedEvents){
            Id recordId = (Id)item.cmbls__Record_Id__c;
            System.debug(JSON.serializePretty(item));
            if(recordId.getSobjectType() == cmbls__Payment__c.getSObjectType()){
                Assert.isTrue(item.Deleted_Record_Id__c);
                Assert.areEqual(null, item.cmbls__Date_Processed__c);
            }else{
                Assert.isFalse(item.Deleted_Record_Id__c);
                Assert.areNotEqual(null, item.cmbls__Date_Processed__c);
            }
            Assert.areNotEqual(null, item.cmbls__Last_Attempt__c);
            Assert.areEqual(1, item.cmbls__Number_of_Attempts__c);
        }
    }
    
    @IsTest
    static void executeBatchWithErrors(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c LIMIT 1];
        insert new cmbls__Queued_Event__c[]{
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = payment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE),
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE)
        };
        Assert.areEqual(2, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        ChartOfAccountService.testPaymentRecordFailureId = payment.Id;
        
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        cmbls__Debug_Log__c[] debugLogs = [SELECT Id, cmbls__Log__c, cmbls__Subject__c, cmbls__Description__c, cmbls__Record_Id__c FROM cmbls__Debug_Log__c];
        Assert.areEqual(1, debugLogs.size());
        Assert.areEqual(ChartOfAccountService.DEBUG_LOG_SOBJECT_UPDATE_FAILURE_SUBJECT, debugLogs[0].cmbls__Subject__c);
        Assert.areEqual(String.format(ChartOfAccountService.DEBUG_LOG_SOBJECT_UPDATE_FAILURE_DESCRIPTION, new String[]{payment.getSObjectType().getDescribe().getLabel()}), debugLogs[0].cmbls__Description__c);
        Assert.areEqual(payment.Id, debugLogs[0].cmbls__Record_Id__c);
        Assert.isTrue(debugLogs[0].cmbls__Log__c.containsIgnoreCase('Code: REQUIRED_FIELD_MISSING'));
        Assert.isTrue(debugLogs[0].cmbls__Log__c.containsIgnoreCase('Message: Required fields are missing: [cmbls__Transaction_Amount__c]'));
        Assert.isTrue(debugLogs[0].cmbls__Log__c.containsIgnoreCase('Fields: (cmbls__Transaction_Amount__c)'));
        
        cmbls__Queued_Event__c[] queuedEvents = [
            SELECT Id, cmbls__Date_Processed__c, Deleted_Record_Id__c, cmbls__Last_Attempt__c, cmbls__Number_of_Attempts__c, cmbls__Record_Id__c
            FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE
        ];
        Assert.areEqual(2, queuedEvents.size());
        for(cmbls__Queued_Event__c item :queuedEvents){
            if(item.cmbls__Record_Id__c == payment.Id){
                Assert.areEqual(null, item.cmbls__Date_Processed__c);
            }else{
                Assert.areNotEqual(null, item.cmbls__Date_Processed__c);
            }
            
            Assert.areNotEqual(null, item.cmbls__Last_Attempt__c);
            Assert.isFalse(item.Deleted_Record_Id__c);
            Assert.areEqual(1, item.cmbls__Number_of_Attempts__c);
        }
    }
    
    @IsTest
    static void executeBatchWithException(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c LIMIT 1];
        insert new cmbls__Queued_Event__c[]{
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = payment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE),
            new cmbls__Queued_Event__c(cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE)
        };
        Assert.areEqual(2, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        ChartOfAccountService.THROW_EXCEPTION_ON_TEST = true;
        
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        cmbls__Debug_Log__c[] debugLogs = [SELECT Id, cmbls__Subject__c, cmbls__Description__c FROM cmbls__Debug_Log__c];
        Assert.areEqual(1, debugLogs.size());
        Assert.areEqual(ChartOfAccountService.ERROR_SUBJECT, debugLogs[0].cmbls__Subject__c);
        Assert.areEqual('TEST EXCEPTION', debugLogs[0].cmbls__Description__c);
        
        cmbls__Queued_Event__c[] queuedEvents = [
            SELECT Id, cmbls__Date_Processed__c, Deleted_Record_Id__c, cmbls__Last_Attempt__c, cmbls__Number_of_Attempts__c, cmbls__Record_Id__c
            FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE
        ];
        Assert.areEqual(2, queuedEvents.size());
        for(cmbls__Queued_Event__c item :queuedEvents){
            Assert.areEqual(null, item.cmbls__Date_Processed__c);
            Assert.areEqual(null, item.cmbls__Last_Attempt__c);
            Assert.isFalse(item.Deleted_Record_Id__c);
            Assert.areEqual(null, item.cmbls__Number_of_Attempts__c);
        }
    }
    
    @IsTest
    static void executeBatchMaxAttempts(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c LIMIT 1];
        insert new cmbls__Queued_Event__c[]{
            new cmbls__Queued_Event__c(cmbls__Number_of_Attempts__c = 2, cmbls__Record_Id__c = payment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE),
            new cmbls__Queued_Event__c(cmbls__Number_of_Attempts__c = 2, cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = ChartOfAccountService.QUEUED_EVENT_TYPE)
        };
        Assert.areEqual(2, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
        cmbls__Queued_Event__c[] queuedEvents = [
            SELECT Id, cmbls__Date_Processed__c, Deleted_Record_Id__c, cmbls__Last_Attempt__c, cmbls__Number_of_Attempts__c, cmbls__Record_Id__c
            FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE
        ];
        Assert.areEqual(2, queuedEvents.size());
        for(cmbls__Queued_Event__c item :queuedEvents){
            Assert.areEqual(null, item.cmbls__Date_Processed__c);
            Assert.areEqual(null, item.cmbls__Last_Attempt__c);
            Assert.isFalse(item.Deleted_Record_Id__c);
            Assert.areEqual(2, item.cmbls__Number_of_Attempts__c);
        }
    }
    
    @IsTest
    static void schedule(){
        Test.startTest();
        String CRON_EXP = '0 0 23 * * ?';
        System.schedule('ChartOfAccountBatch TEST', CRON_EXP, new ChartOfAccountBatch());
        Test.stopTest();
    }
}