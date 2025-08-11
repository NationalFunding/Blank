/**
 * BatchGenerateFunasAmortizationTest class
 * @author CloudMyBiz (r)
 * @date 17/06/2022
 * @description
 * @group 
 */

@IsTest
private class BatchGenerateFunasAmortizationTest {

    @TestSetup static void setupMethod() {
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__Current_Interest_Rate__c = 10;
        repayment.cmbls__Initial_Payment_Amount__c = 1000;
        repayment.cmbls__Interest_Accrual_Frequency__c = Constant.INTEREST_ACCRUAL_FREQUENCY_MONTHLY;
        repayment.Generate_FUNAS_Amortization_Schedule__c = true;
        repayment.cmbls__First_Payment_Date__c = Date.today().addMonths(-2);
        repayment.cmbls__Funded_Date__c = Date.today().addMonths(-3);
        repayment.cmbls__Payment_Amount__c = 1000;
        repayment.cmbls__Funding_Amount__c = 10000;
        repayment.Opportunity__c = opp.Id;
        insert repayment;

        cmbls__Invoice__c invoice = TestDataFactory.createInvoice(repayment.Id, Date.today());
        insert invoice;

        cmbls__Invoice_Line_Item__c invoiceLineItem = TestDataFactory.createInvoiceLineItem(1000, Date.today(), invoice.Id);
        insert invoiceLineItem;

        Test.stopTest();
    }

    @IsTest static void monthlyAmortization() {
        Test.startTest();
        Database.executeBatch(new BatchGenerateFunasAmortization());
        Test.stopTest();

        cmbls__Repayment__c repayment = [SELECT Id, Generate_FUNAS_Amortization_Schedule__c, FUNAS_Execution_Result__c, cmbls__Maturity_Date__c FROM cmbls__Repayment__c];
        System.assertEquals(false, repayment.Generate_FUNAS_Amortization_Schedule__c);
        System.assertNotEquals(null, repayment.FUNAS_Execution_Result__c);
        System.assert(repayment.FUNAS_Execution_Result__c.contains('successfully'));
        System.assertNotEquals(null, repayment.cmbls__Maturity_Date__c);
        System.assert([SELECT COUNT() FROM cmbls__Amortization_Schedule__c WHERE cmbls__Repayment__c =: repayment.Id] > 0);
    }

    @IsTest static void weeklyAmortization() {
        cmbls__Repayment__c repayment = [SELECT Id, Generate_FUNAS_Amortization_Schedule__c, FUNAS_Execution_Result__c, cmbls__Maturity_Date__c FROM cmbls__Repayment__c];
        repayment.cmbls__Interest_Accrual_Frequency__c = Constant.INTEREST_ACCRUAL_FREQUENCY_MONTHLY;
        update repayment;

        Test.startTest();
        new BatchGenerateFunasAmortization().execute(null);
        Test.stopTest();

        repayment = [SELECT Generate_FUNAS_Amortization_Schedule__c, FUNAS_Execution_Result__c, cmbls__Maturity_Date__c FROM cmbls__Repayment__c WHERE Id = :repayment.Id];
        System.assertEquals(false, repayment.Generate_FUNAS_Amortization_Schedule__c);
        System.assertNotEquals(null, repayment.FUNAS_Execution_Result__c);
        System.assert(repayment.FUNAS_Execution_Result__c.contains('successfully'));
        System.assertNotEquals(null, repayment.cmbls__Maturity_Date__c);
        System.assert([SELECT COUNT() FROM cmbls__Amortization_Schedule__c WHERE cmbls__Repayment__c =: repayment.Id] > 0);
    }
    
    @IsTest static void omittedInvoice() {
        cmbls__Repayment__c repayment = [SELECT Id, Generate_FUNAS_Amortization_Schedule__c, FUNAS_Execution_Result__c, cmbls__Maturity_Date__c FROM cmbls__Repayment__c];
        cmbls__Invoice_Line_Item__c lineItem = [SELECT Id, cmbls__Invoice__c FROM cmbls__Invoice_Line_Item__c WHERE cmbls__Invoice__r.cmbls__Repayment__c = :repayment.Id];
        lineItem.cmbls__Type__c = 'Fee';
        update lineItem;
        
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Invoice__c WHERE Omit_From_FUNAS_Auto_Generation__c = TRUE AND Id = :lineItem.cmbls__Invoice__c]);
    }
    
    @IsTest static void dtos() {
        FunasDTO.FunasLineItem funasLineItem = new FunasDTO.FunasLineItem();
        funasLineItem.amount = 10;
        funasLineItem.balance   = 10;
        funasLineItem.asDate = 10;
        funasLineItem.interest = 10;
        funasLineItem.lineNumber = 10;
        funasLineItem.lineType = 10;
        funasLineItem.paymentAmount = 10;
        funasLineItem.principal = 10;
        funasLineItem.rate = 10;
        funasLineItem.settled = 10;

        FunasCallableAdapter fca = FunasCallableAdapter.getController();
        fca.call('calculate', new Map<String, Object>{});
        fca.call('calculate', new Account());
    }
}