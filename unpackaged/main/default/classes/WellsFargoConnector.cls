/**
 * Created on 22/02/2022.
 *  * Class that contains logic for Payments integration with Wells Fargo System
  *     
 */
@RestResource(UrlMapping='/wellsFargoPayments/*')
global without sharing class WellsFargoConnector {

    @HttpPost
    global static void POST(){
        RestContext.response.statusCode = 200;
        if(WellsFargoAPI.WF_Settings.Disable_Webhook__c) return;
        RestRequest req = RestContext.request;
        WellsFargo.WebhookReturn webhookReturn = (WellsFargo.WebhookReturn)JSON.deserialize(req.requestBody?.toString(), WellsFargo.WebhookReturn.class);

        ACHTransactionLog achLog = new ACHTransactionLog();
        achLog.log.Response__c = req.requestBody?.toString();
        achLog.log.Log_Date__c = Datetime.now();
        achLog.log.Description__c = webhookReturn.getReturnReasonDescription();
        achLog.log.Response_Code__c = webhookReturn.getReturnReasonCode();

        SObject recordReturn = getRecordByKey(webhookReturn.getRecipientId());
        if(recordReturn != null) achLog.setLookupField(recordReturn.Id);
        
        achLog.log.Status__c =  isNotificationOfChange(webhookReturn.getReturnReasonCode()) ?
                                Constant.ACH_TRANSACTION_LOG_STATUS_NOTIFICATION :
                                Constant.STATUS_FAILED;

        insert achLog.log;
    }

    private static SObject getRecordByKey(String externalId){
        if(String.isBlank(externalId)) return null;
        
        SObject output;
        for(cmbls__Payment__c item :[SELECT Id, Wells_Fargo_Payment_ID_Formula__c FROM cmbls__Payment__c WHERE Wells_Fargo_Payment_ID_Formula__c = :externalId.trim()]){
            if(externalId.trim().equals(item.Wells_Fargo_Payment_ID_Formula__c)){
                output = item;
                break;
            }
        }
        
        if(output == null){
            for(cmbls__Disbursement__c item :[SELECT Id, Wells_Fargo_Disbursement_ID_Formula__c FROM cmbls__Disbursement__c WHERE Wells_Fargo_Disbursement_ID_Formula__c = :externalId.trim()]){
                if(externalId.trim().equals(item.Wells_Fargo_Disbursement_ID_Formula__c)){
                    output = item;
                    break;
                }
            }
        }
        return output;
    }
    
    private static Boolean isNotificationOfChange(String returnCode){
        return String.isNotBlank(returnCode) && returnCode.trim().startsWith('C') && returnCode.trim().length() == 3;
    }

}