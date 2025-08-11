/**
 * TransferQueuedEventBatchTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class TransferQueuedEventBatchTest{
    
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

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Opportunity__c = opp.Id;
        insert repayment;
    
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
    
        cmbls__Fund__c[] fundRecords = new cmbls__Fund__c[]{
            TestDataFactory.createFund(RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME, bankingInformation),
            TestDataFactory.createFund('National Funding - Fund', bankingInformation)
        };
        insert fundRecords;
    
        cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
        settings.National_Funding_Fund_Id__c = fundRecords[1].Id;
        settings.Enable_Automatic_Transfers__c = true;
        upsert settings;
    
        Test.stopTest();
    }
    
    @IsTest
    static void executeBatch(){
    
    }
    
    @IsTest
    static void executeSchedule(){
        Test.startTest();
        System.schedule('TransferQueuedEventBatch Test', '0 0 23 * * ?', new TransferQueuedEventBatch());
        Test.stopTest();
    }
}