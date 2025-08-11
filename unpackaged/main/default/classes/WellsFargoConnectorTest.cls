/**
 * WellsFargoConnectorTest class
 * @author CloudMyBiz (r)
 * @date 18/07/2022
 * @description
 * @group 
 */

@IsTest
private class WellsFargoConnectorTest {

    @TestSetup static void setupMethod() {
        Test.startTest();
        Account acc = new Account(Name = 'Test account');
        insert acc;

        cmbls__Repayment__c repayment1 = TestDataFactory.createRepayment(acc.Id);
        repayment1.cmbls__ACH_Processor__c = 'Wells Fargo Account';
        repayment1.Merchant_Number__c = '123456';
        insert repayment1;

        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING);
        dis.cmbls__Repayment__c = repayment1.Id;
        insert dis;

        Test.stopTest();
    }

    @IsTest
    static void webhookPaymentReversal(){
        RestRequest req = new RestRequest();
        req.addHeader('httpMethod', 'POST');
        req.requestURI = '/services/apexrest/wellsFargoPayments/';

        WellsFargo.WebhookReturn webhReturn = new WellsFargo.WebhookReturn();
        webhReturn.data = new WellsFargo.WebhookData();
        webhReturn.data.return_reason_description = 'INSUFFICIENT FUNDS';

        cmbls__Payment__c payment = [SELECT Id, Wells_Fargo_Payment_ID_Formula__c FROM cmbls__Payment__c];
        webhReturn.data.recipient_id = payment.Wells_Fargo_Payment_ID_Formula__c;
        req.requestBody = Blob.valueOf(JSON.serialize(webhReturn));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WellsFargoConnector.POST();
        Test.stopTest();

        System.assert([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_FAILED AND Payment__c = :payment.Id] == 1);
    }

    @IsTest
    static void webhookDisbursementReversal(){
        RestRequest req = new RestRequest();
        req.addHeader('httpMethod', 'POST');
        req.requestURI = '/services/apexrest/wellsFargoPayments/';

        WellsFargo.WebhookReturn webhReturn = new WellsFargo.WebhookReturn();
        webhReturn.data = new WellsFargo.WebhookData();
        webhReturn.data.return_reason_description = 'INSUFFICIENT FUNDS';

        cmbls__Disbursement__c disb = [SELECT Id, Wells_Fargo_Disbursement_ID_Formula__c FROM cmbls__Disbursement__c];
        webhReturn.data.recipient_id = disb.Wells_Fargo_Disbursement_ID_Formula__c;
        req.requestBody = Blob.valueOf(JSON.serialize(webhReturn));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WellsFargoConnector.POST();
        Test.stopTest();

        System.assert([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_FAILED AND Disbursement__c = :disb.Id] == 1);
    }

    @IsTest
    static void webhookNotificationOfChange(){
        RestRequest req = new RestRequest();
        req.addHeader('httpMethod', 'POST');
        req.requestURI = '/services/apexrest/wellsFargoPayments/';

        WellsFargo.WebhookReturn webhReturn = new WellsFargo.WebhookReturn();
        webhReturn.data = new WellsFargo.WebhookData();
        webhReturn.data.return_reason_code = 'C01';
        webhReturn.data.return_reason_description = 'Notification of Change.';

        cmbls__Payment__c payment = [SELECT Id, Wells_Fargo_Payment_ID_Formula__c FROM cmbls__Payment__c];
        webhReturn.data.recipient_id = payment.Wells_Fargo_Payment_ID_Formula__c;
        req.requestBody = Blob.valueOf(JSON.serialize(webhReturn));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WellsFargoConnector.POST();
        Test.stopTest();

        System.assert([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_NOTIFICATION AND Payment__c = :payment.Id] == 1);
    }
    
    @IsTest
    static void webhookPaymentReversalKeySensitive(){
        RestRequest req = new RestRequest();
        req.addHeader('httpMethod', 'POST');
        req.requestURI = '/services/apexrest/wellsFargoPayments/';
        
        WellsFargo.WebhookReturn webhReturn = new WellsFargo.WebhookReturn();
        webhReturn.data = new WellsFargo.WebhookData();
        webhReturn.data.return_reason_description = 'INSUFFICIENT FUNDS';
        
        cmbls__Payment__c payment = [SELECT Id, Wells_Fargo_Payment_ID_Formula__c FROM cmbls__Payment__c];
        payment.Wells_Fargo_Payment_ID_Override__c = 'ABCDEFGH';
        update payment;
        
        insert new cmbls__Payment__c(
            cmbls__Transaction_Amount__c = 200,
            Wells_Fargo_Payment_ID_Override__c = 'ABCDEFGh',
            cmbls__Repayment__c = [SELECT Id FROM cmbls__Repayment__c].Id,
            cmbls__Effective_Date__c = System.today()
        );
        
        webhReturn.data.recipient_id = 'ABCDEFGH';//payment.Wells_Fargo_Payment_ID_Override__c;
        req.requestBody = Blob.valueOf(JSON.serialize(webhReturn));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        WellsFargoConnector.POST();
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_FAILED AND Payment__c = :payment.Id]);
    }

}