@IsTest
public with sharing class  AutomatedMaturityFeesScheduleTest {
    
    @TestSetup static void setupMethod(){
        Account acc = new Account(Name = 'Test account');
        insert acc;
        
        cmbls__Repayment__c[] repayments = new cmbls__Repayment__c[]{
            TestDataFactory.createRepayment(acc.Id),
            TestDataFactory.createRepayment(acc.Id),
            TestDataFactory.createRepayment(acc.Id),
            TestDataFactory.createRepayment(acc.Id),
            TestDataFactory.createRepayment(acc.Id)
        };
        
        //Should create Maturity fees due to Enable_Maturity_Default_Fees__c = true
        repayments[0].Enable_Maturity_Default_Fees__c = true;
        repayments[0].cmbls__Maturity_Date__c = System.today().addDays(-3);
        repayments[0].Merchant_Number__c = 'NF-TEST01';
        
        //Should NOT create Maturity fees due to Status is NOT 'Active'
        repayments[1].cmbls__Status__c = RepaymentUtils.STATUS_COMPLETE;
        repayments[1].Enable_Maturity_Default_Fees__c = true;
        repayments[1].cmbls__Maturity_Date__c = System.today().addDays(-3);
        repayments[1].Merchant_Number__c = 'NF-TEST02';
        
        //Should NOT create Maturity fees due to Enable_Maturity_Default_Fees__c = false
        repayments[2].Enable_Maturity_Default_Fees__c = false;
        repayments[2].cmbls__Maturity_Date__c = System.today().addDays(-3);
        repayments[2].Merchant_Number__c = 'NF-TEST03';
        
        //Should NOT create Maturity fees due to cmbls__Maturity_Date__c > TODAY
        repayments[4].Enable_Maturity_Default_Fees__c = true;
        repayments[4].cmbls__Maturity_Date__c = System.today().addDays(1);
        repayments[4].Merchant_Number__c = 'NF-TEST04';
        
        insert repayments;
        
        Test.startTest();
        
        National_Funding_Settings__c settings = National_Funding_Settings__c.getOrgDefaults();
        settings.Maturity_Default_Fee_Amount__c = 10;
        upsert settings;
        Test.stopTest();
    }

    @IsTest
    static void automatedMaturityFeesScheduleTest(){
        for(cmbls__Repayment__c item :[SELECT Id, Merchant_Number__c, cmbls__Status__c, Enable_Maturity_Default_Fees__c, Permanent_Mod__c FROM cmbls__Repayment__c]){
            switch on item.Merchant_Number__c {
                when 'NF-TEST01' {
                    Assert.areEqual(RepaymentUtils.STATUS_ACTIVE, item.cmbls__Status__c);
                    Assert.isTrue(item.Enable_Maturity_Default_Fees__c);
                    Assert.isFalse(item.Permanent_Mod__c);
                }
                when 'NF-TEST02' {
                    Assert.areEqual(RepaymentUtils.STATUS_COMPLETE, item.cmbls__Status__c);
                    Assert.isTrue(item.Enable_Maturity_Default_Fees__c);
                    Assert.isFalse(item.Permanent_Mod__c);
                }
                when 'NF-TEST03' {
                    Assert.areEqual(RepaymentUtils.STATUS_ACTIVE, item.cmbls__Status__c);
                    Assert.isFalse(item.Enable_Maturity_Default_Fees__c);
                    Assert.isFalse(item.Permanent_Mod__c);
                }
                when 'NF-TEST04' {
                    Assert.areEqual(RepaymentUtils.STATUS_ACTIVE, item.cmbls__Status__c);
                    Assert.isTrue(item.Enable_Maturity_Default_Fees__c);
                }
            }
        }
        
        Test.startTest();
        new AutomatedMaturityFeesSchedule().execute(null);
        Test.stopTest();
        
        cmbls__Repayment__c[] repayments = [
            SELECT Id, Merchant_Number__c, (SELECT Id FROM cmbls__Payments__r WHERE RecordTypeId = :PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID AND
                                                                                    cmbls__Effective_Date__c = TODAY AND
                                                                                    cmbls__Transaction_Type__c = :PaymentUtils.PAYMENT_TRANSACTION_TYPE_FEE AND
                                                                                    cmbls__Sub_Type__c = :PaymentUtils.PAYMENT_SUBTYPE_MATURITY AND
                                                                                    cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FEE_APPLIED AND
                                                                                    cmbls__Transaction_Amount__c = 10)
            FROM cmbls__Repayment__c
        ];
        for(cmbls__Repayment__c item :repayments){
            switch on item.Merchant_Number__c {
                when 'NF-TEST01' {
                    Assert.areEqual(1, item.cmbls__Payments__r.size());
                }
                when 'NF-TEST02' {
                    Assert.areEqual(0, item.cmbls__Payments__r.size());
                }
                when 'NF-TEST03' {
                    Assert.areEqual(0, item.cmbls__Payments__r.size());
                }
                when 'NF-TEST04' {
                    Assert.areEqual(0, item.cmbls__Payments__r.size());
                }
            }
        }
        
    }
}