/**
 * SetStartDateRepaymentScheduleTest class
 * @author CloudMyBiz (r)
 * @date 5/10/2023
 */

@IsTest
private class SetStartDateRepaymentScheduleTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        Account lenderAccount = TestDataFactory.createAccount();
        lenderAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Lender_Acct').getRecordTypeId();
        lenderAccount.Name = RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME;
        insert new Account[]{acc, lenderAccount};
        
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        opp.Lender_Account__c = lenderAccount.Id;
        opp.Loan_Start_Date__c = Date.newInstance(2023,1,6);
        insert opp;
        
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
        
        cmbls__Fund__c fundRecord = TestDataFactory.createFund('National Funding - Fund', bankingInformation);
        fundRecord.cmbls__Default_Debit_ACH_Processor__c = 'Wells Fargo - NF Collections';
        insert fundRecord;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Opportunity__c = opp.Id;
        repayment.cmbls__Primary_Fund__c = fundRecord.Id;
        repayment.cmbls__ACH_Processor__c = 'Wells Fargo - NF Collections';
        repayment.cmbls__Funded_Date__c = Date.newInstance(2023,5,8);//Monday
        repayment.cmbls__Enable_AS_Fixed_Payback_Loan__c = true;
        repayment.cmbls__Loan_Start_Date__c = opp.Loan_Start_Date__c;
        insert repayment;
        
        repayment = [SELECT Id, cmbls__Loan_Start_Date__c FROM cmbls__Repayment__c WHERE Id = :repayment.Id];
        Assert.areEqual(Date.newInstance(2023,1,6), repayment.cmbls__Loan_Start_Date__c);
        
        Test.stopTest();
    }
    
    @IsTest
    static void flowNonFixedPaybackLoan(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Funded_Date__c FROM cmbls__Repayment__c LIMIT 1];
        repayment.cmbls__Enable_AS_Fixed_Payback_Loan__c = false;
        update repayment;
        
        
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Bank_Account_Number__c = '1212';
        schedules[0].cmbls__Bank_Routing_Number__c = '999999963';
        schedules[0].cmbls__Preset__c = 'Weekly';
        schedules[0].cmbls__Start_Date__c = repayment.cmbls__Funded_Date__c;
        schedules[0].cmbls__Days__c = 'Monday';
        
        schedules[1].cmbls__Active__c = false;
        schedules[1].cmbls__Bank_Account_Number__c = '1212';
        schedules[1].cmbls__Bank_Routing_Number__c = '999999963';
        schedules[1].cmbls__Preset__c = 'Weekly';
        schedules[1].cmbls__Start_Date__c = repayment.cmbls__Funded_Date__c;
        schedules[1].cmbls__Days__c = 'Monday';
        insert schedules;
        
        SetStartDateRepaymentSchedule.SetStartDateRequest[] requests = new SetStartDateRepaymentSchedule.SetStartDateRequest[]{};
        for(cmbls__Repayment_Schedule__c item :schedules){
            SetStartDateRepaymentSchedule.SetStartDateRequest req = new SetStartDateRepaymentSchedule.SetStartDateRequest();
            req.recordId = item.Id;
            req.frequency = item.cmbls__Preset__c;
            req.startDate = item.cmbls__Start_Date__c;
            requests.add(req);
        }
        Test.startTest();
        SetStartDateRepaymentSchedule.mainInvocableMethod(requests);
        Test.stopTest();
        
        schedules = [SELECT Id, cmbls__Days__c, cmbls__Start_Date__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c =:repayment.Id];
        Assert.areEqual('Monday', schedules[0].cmbls__Days__c);
        Assert.areEqual(repayment.cmbls__Funded_Date__c, schedules[0].cmbls__Start_Date__c);
        Assert.areEqual('Monday', schedules[1].cmbls__Days__c);
        Assert.areEqual(repayment.cmbls__Funded_Date__c, schedules[1].cmbls__Start_Date__c);
    }
    
    @IsTest
    static void flowFixedPaybackLoan(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Funded_Date__c, cmbls__Loan_Start_Date__c FROM cmbls__Repayment__c LIMIT 1];
        
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Bank_Account_Number__c = '1212';
        schedules[0].cmbls__Bank_Routing_Number__c = '999999963';
        schedules[0].cmbls__Preset__c = 'Weekly';
        schedules[0].cmbls__Start_Date__c = repayment.cmbls__Funded_Date__c;
        schedules[0].cmbls__Days__c = 'Monday';
        
        schedules[1].cmbls__Active__c = false;
        schedules[1].cmbls__Bank_Account_Number__c = '1212';
        schedules[1].cmbls__Bank_Routing_Number__c = '999999963';
        schedules[1].cmbls__Preset__c = 'Weekly';
        schedules[1].cmbls__Start_Date__c = repayment.cmbls__Funded_Date__c;
        schedules[1].cmbls__Days__c = 'Monday';
        insert schedules;
        
        SetStartDateRepaymentSchedule.SetStartDateRequest[] requests = new SetStartDateRepaymentSchedule.SetStartDateRequest[]{};
        for(cmbls__Repayment_Schedule__c item :schedules){
            SetStartDateRepaymentSchedule.SetStartDateRequest req = new SetStartDateRepaymentSchedule.SetStartDateRequest();
            req.recordId = item.Id;
            req.frequency = item.cmbls__Preset__c;
            req.startDate = repayment.cmbls__Loan_Start_Date__c;
            requests.add(req);
        }
        Test.startTest();
        SetStartDateRepaymentSchedule.mainInvocableMethod(requests);
        Test.stopTest();
        
        schedules = [SELECT Id, cmbls__Days__c, cmbls__Start_Date__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c =:repayment.Id];
        
        Assert.areEqual('Friday', schedules[0].cmbls__Days__c);
        Assert.areEqual(repayment.cmbls__Loan_Start_Date__c, schedules[0].cmbls__Start_Date__c);
        Assert.areEqual('Friday', schedules[1].cmbls__Days__c);
        Assert.areEqual(repayment.cmbls__Loan_Start_Date__c, schedules[1].cmbls__Start_Date__c);
    }
}