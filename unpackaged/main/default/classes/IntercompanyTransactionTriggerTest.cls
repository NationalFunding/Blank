/**
 * IntercompanyTransactionTriggerTest class
 * @author CloudMyBiz (r)
 * @date 2/13/2023
 */

@IsTest
private class IntercompanyTransactionTriggerTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        Account lenderAccount = TestDataFactory.createAccount();
        lenderAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Lender_Acct').getRecordTypeId();
        lenderAccount.Name = RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME;
        insert new Account[]{acc, lenderAccount};
    
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        opp.Lender_Account__c = lenderAccount.Id;
        insert opp;
    
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
    
        cmbls__Fund__c[] fundRecords = new cmbls__Fund__c[]{
            TestDataFactory.createFund('Quick Bridge', bankingInformation),
            TestDataFactory.createFund('National Funding - Fund', bankingInformation)
        };
        fundRecords[0].cmbls__Default_Debit_ACH_Processor__c = 'Wells Fargo - NF Collections';
        fundRecords[1].cmbls__Default_Debit_ACH_Processor__c = 'Wells Fargo - NF Collections';
        insert fundRecords;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Opportunity__c = opp.Id;
        repayment.cmbls__Primary_Fund__c = fundRecords[0].Id;
        repayment.cmbls__ACH_Processor__c = 'Wells Fargo - NF Collections';
        repayment.cmbls__Loan_Start_Date__c = System.today().addDays(-1);
        repayment.Migrated__c = false;
        insert repayment;

        System.debug(RepaymentSelector.getQuickBridgeFundedRecords(new Set<Id>{repayment.Id}));


        cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
        settings.National_Funding_Fund_Id__c = fundRecords[1].Id;
        settings.Enable_Automatic_Transfers__c = true;
        upsert settings;
    
        cmbls__Queued_Event__c queuedEvent = new cmbls__Queued_Event__c(
            cmbls__Record_Id__c = repayment.Id,
            cmbls__Type__c = TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION
        );
        insert queuedEvent;
    
        RepaymentService.createTransferRecords(new cmbls__Queued_Event__c[]{queuedEvent});
        
        Test.stopTest();
    }
    
    @IsTest
    static void updateDisableSetting(){
        cmbls__Loan_Servicing_Triggers__c settings = cmbls__Loan_Servicing_Triggers__c.getInstance();
        settings.Disable_Additional_GL_Trans_Trigger__c = true;
        upsert settings;
        
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Intercompany_Transaction__c intercompanyTransaction = getIntercompanyTransaction(repayment.Id);
        
        Test.startTest();
        intercompanyTransaction.cmbls__Status__c = IntercompanyTransactionHandler.PAID_STATUS;
        update intercompanyTransaction;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Additional_GL_Transaction__c]);
    }
    @IsTest
    static void updateExistingRecords(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Intercompany_Transaction__c intercompanyTransaction = getIntercompanyTransaction(repayment.Id);
        Additional_GL_Transaction__c additionalGLTransaction = new Additional_GL_Transaction__c(
            Intercompany_Transaction__c = intercompanyTransaction.Id,
            Type__c = IntercompanyTransactionHandler.PAID_TYPE
        );
        insert additionalGLTransaction;
    
        Test.startTest();
        intercompanyTransaction.cmbls__Status__c = IntercompanyTransactionHandler.PAID_STATUS;
        update intercompanyTransaction;
        Test.stopTest();
    
        System.assertEquals(1, [SELECT COUNT() FROM Additional_GL_Transaction__c WHERE Intercompany_Transaction__c = :intercompanyTransaction.Id AND Type__c = :IntercompanyTransactionHandler.PAID_TYPE]);
    }
    
    @IsTest
    static void updateSuccessful(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Intercompany_Transaction__c intercompanyTransaction = getIntercompanyTransaction(repayment.Id);
    
        Test.startTest();
        intercompanyTransaction.cmbls__Status__c = IntercompanyTransactionHandler.PAID_STATUS;
        update intercompanyTransaction;
        Test.stopTest();
    
        System.assertEquals(1, [SELECT COUNT() FROM Additional_GL_Transaction__c WHERE Intercompany_Transaction__c = :intercompanyTransaction.Id AND Type__c = :IntercompanyTransactionHandler.PAID_TYPE]);
    }
    
    @IsTest
    static void updateStatusNotIncluded(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Intercompany_Transaction__c intercompanyTransaction = getIntercompanyTransaction(repayment.Id);
    
        Test.startTest();
        intercompanyTransaction.cmbls__Status__c = 'Due';
        update intercompanyTransaction;
        Test.stopTest();
    
        System.assertEquals(0, [SELECT COUNT() FROM Additional_GL_Transaction__c]);
    }
    
    @IsTest
    static void insertTrigger(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Loan_Transfer__c loanTransfer = [SELECT Id, cmbls__Loan_Transfer_Summary__c FROM cmbls__Loan_Transfer__c WHERE cmbls__Repayment__c = :repayment.Id];
        cmbls__Intercompany_Transaction__c intercompanyTransaction = new cmbls__Intercompany_Transaction__c(
            cmbls__Loan_Transfer_Summary__c = loanTransfer.cmbls__Loan_Transfer_Summary__c,
            cmbls__Status__c = IntercompanyTransactionHandler.PAID_STATUS
        );
    
        Test.startTest();
        insert intercompanyTransaction;
        Test.stopTest();
    
        System.assertEquals(0, [SELECT COUNT() FROM Additional_GL_Transaction__c]);
    }
    
    private static cmbls__Intercompany_Transaction__c getIntercompanyTransaction(Id repaymentId){
        cmbls__Loan_Transfer__c loanTransfer = [SELECT Id, cmbls__Loan_Transfer_Summary__c FROM cmbls__Loan_Transfer__c WHERE cmbls__Repayment__c = :repaymentId];
        return  [SELECT Id, cmbls__Status__c FROM cmbls__Intercompany_Transaction__c WHERE cmbls__Loan_Transfer_Summary__c = :loanTransfer.cmbls__Loan_Transfer_Summary__c];
    }
}