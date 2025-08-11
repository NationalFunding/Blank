@IsTest
public with sharing class ACHPaymentTriggerHandlerTest {
    
    @TestSetup static void setupMethod(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Bank_Account__c bankAccount = TestDataFactory.createBankAccount();
        insert bankAccount;
    
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        opp.Loan_Start_Date__c = System.today();
        insert opp;
    }
    
    @IsTest
    static void testCreateDisbursements(){
        Account acc = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Bank_Account__c bankAccount = [SELECT Id FROM Bank_Account__c];
        
        Test.startTest();
        ACH_Payment__c pay = TestDataFactory.createDefaultACHPaymentRecord(acc.Id, opp.Id, bankAccount.Id);
        insert pay;
        Test.stopTest();

        cmbls__Disbursement__c dis = [
            SELECT  Id, cmbls__Effective_Date__c, cmbls__Addenda__c, Opportunity__c,cmbls__Transaction_Amount__c,
                    cmbls__Bank_Account_Number__c,cmbls__Bank_Routing_Number__c,cmbls__Bank_Account_Type__c
            FROM cmbls__Disbursement__c ORDER BY CreatedDate DESC LIMIT 1];
       
        System.assertEquals(dis.cmbls__Effective_Date__c , pay.Pay_On_This_Date__c);
        System.assertEquals(dis.cmbls__Effective_Date__c,pay.Pay_On_This_Date__c);
        System.assertEquals(dis.cmbls__Addenda__c,pay.Opportunity__r.Account.Company_DBA__c);
        System.assertEquals( dis.Opportunity__c,pay.Opportunity__c);
        System.assertEquals(dis.cmbls__Transaction_Amount__c,pay.Amount__c);
        System.assertEquals(dis.cmbls__Bank_Account_Number__c,pay.Payee_s_Bank_Account_Number__c);
        System.assertEquals(dis.cmbls__Bank_Routing_Number__c,pay.Payee_s_Routing_Number__c);
        System.assertEquals( dis.cmbls__Bank_Account_Type__c,pay.Payee_s_Account_Type__c);
    }

    @IsTest
    static void testRelateDisbursements(){
        Account acc = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Bank_Account__c bankAccount = [SELECT Id FROM Bank_Account__c];
    
        ACH_Payment__c pay = TestDataFactory.createDefaultACHPaymentRecord(acc.Id, opp.Id, bankAccount.Id);
        insert pay;

        Test.startTest();
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Opportunity__c = opp.Id;
        insert repayment;
        Test.stopTest();

        cmbls__Disbursement__c dis = [SELECT Id,cmbls__Status__c,cmbls__Repayment__c FROM cmbls__Disbursement__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(dis.cmbls__Repayment__c , repayment.Id);
        System.assertEquals(dis.cmbls__Status__c , DisbursementUtils.DISBURSEMENT_STATUS_SCHEDULED);
    }

    @IsTest
    static void testNotCreateExpenses(){
        Account acc = [SELECT Id FROM Account];

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;

        List<cmbls__Expense__c> exps = [SELECT Id FROM cmbls__Expense__c WHERE cmbls__Repayment__c =: repayment.Id];
        System.assertEquals(exps.size() , 0);
        
    }

    @IsTest
    static void testCreateExpenses(){
        Account acc = [SELECT Id FROM Account];
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__Origination_Fee__c = 100;
        insert repayment;
        
        List<cmbls__Expense__c> exps = [SELECT Id FROM cmbls__Expense__c WHERE cmbls__Repayment__c =: repayment.Id];
        System.assertEquals(exps.size() , 1);
    }
}