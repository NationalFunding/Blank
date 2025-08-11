public class SendDLPText {
    
    //@@ Bring config out??
    
    
    private static boolean testMode = false;
    
    @AuraEnabled
    public static void sendDLPText(String recordId, String userId){
        
        String brand = 'National Funding';
        String sourceOrg = 'National Funding';
        Boolean userHasBothBrands = false;      
        DLPTextConfig__c textConfig = DLPTextConfig__c.getInstance();
        String accountsid = textConfig.Account_SID__c;
        String textSource = textConfig.DLP_Text_Source__c;
        
        Instance_Settings__c instanceSettings = Instance_Settings__c.getInstance();     
        
        User userInfo = [Select Id, TwilioSF__Twilio_Personal_Number__c, Available_Brands__c From User Where Id =:userId];
        if(userInfo.Available_Brands__c != null) {
            String availableBrands = userInfo.Available_Brands__c;
            userHasBothBrands = availableBrands.contains('Quick Bridge') && availableBrands.contains('National Funding');
            brand = availableBrands.contains('Quick Bridge') ? 'Quick Bridge' : 'National Funding';
        } 
        system.debug('####here');
        // SPR-63 (7 Feb 2025): Set DLP URL based on user's Available_Brands__c field. 
        // If the field contains 'Quick Bridge', use the Quick Bridge base URL; otherwise, use the default base URL.
        String dlpURL = brand.contains('Quick Bridge') ? instanceSettings.QB_Base_URL__c : instanceSettings.Base_URL__c;
        String fromNumber = userInfo.TwilioSF__Twilio_Personal_Number__c;
        
        String toNumber;
        String payload;
        //String dlpToken;
        
        if(RecordId.startsWithIgnoreCase('00Q')){
            Lead leadRecord = [Select Id, MobilePhone, Encrypted_Email_String__c, Web_Id_NatFund__c, National_Funding_WebId__c From Lead Where Id =:recordId];
            String nfId = leadRecord.Web_Id_NatFund__c != null ? leadRecord.Web_Id_NatFund__c : leadRecord.National_Funding_WebId__c;
            String tokencred = refreshEmailString(recordId, nfId, sourceOrg, brand, userHasBothBrands);
            toNumber = leadRecord.MobilePhone;
            payload = tokencred;   
        } 
        else if (RecordId.startsWithIgnoreCase('003')) {
         	Contact contactRecord = [Select Id, MobilePhone, Encrypted_Email_String__c, Account.Web_Id_NatFund__c, Account.National_Funding_WebId__c From Contact Where Id =:recordId];
            String nfId = contactRecord.Account.Web_Id_NatFund__c != null ? contactRecord.Account.Web_Id_NatFund__c : contactRecord.Account.National_Funding_WebId__c;
            String tokencred = refreshEmailString(recordId, nfId,  sourceOrg, brand, userHasBothBrands);
            toNumber = contactRecord.MobilePhone;
            payload = tokencred;
            
        } 
        else {
            
            String errorMessage = 'Attempting to Send DLP Email to Unknown Object Type - Submitted Record: ' + recordId;
            System.debug(errorMessage);
            throw new GenericException(errorMessage);
        }
        
        // This is a hack to prevent the future method calloutSendTwilioMessage from being called in a test env
        if(!testMode){
            SendDLPText.calloutSendTwilioMessage(dlpURL, textSource, payload, toNumber, fromNumber, accountsid);
        }
        
        
    }
    
    @InvocableMethod
    public static void invokeSendDLPText(List<String> ids){
        
        for(String id: ids){
            
            Lead lead = [SELECT Id, OwnerId FROM Lead WHERE Id =: id];            
            
            String leadId = lead.Id;
            String ownerId = lead.OwnerId;
            
            SendDLPText.calloutSendDLPText(leadId, ownerId);
            
        }
    }
    
    @future(Callout=True) @AuraEnabled
    public static void calloutSendDLPText(String recordId, String ownerId){
        
        system.debug('leadId: ' + recordId);
        system.debug('ownerId: ' + ownerId);
        
        sendDLPText.sendDLPText(recordId, ownerId);
        
    }
    
    @future(Callout=True)
    public static void calloutSendTwilioMessage(String dlpURL, String textSource, String payload, String toNumber, String fromNumber, String accountsid){
        
        String message = dlpURL + '?source=' + textSource + '&payload=' + payload;
        SendTwilioTextHelper.SendTwilioMessage(toNumber, fromNumber, message, accountsid);
        
    }
    
    public static void SetTestMode(){
        SendDLPText.testMode = true;
    }
	
    /**
     * SPR-108 (20 Feb 2025): Refreshes the encrypted email string for a given record.
     * - If the user has access to both brands, it refreshes for both 'Quick Bridge' and 'National Funding'.
     * - Otherwise, it refreshes only for the specified brand.
     *
     * @param recordId       The ID of the record for which the email string is being refreshed.
     * @param sourceOrg      The source organization from which data is retrieved.
     * @param brand          The brand for which the email string is refreshed (if user has only one brand).
     * @param userHasBothBrands Indicates whether the user has access to both brands.
    */
    private static String refreshEmailString(String recordId, String nfId, String sourceOrg, String brand, Boolean userHasBothBrands){
        String recordIdNfId = recordId + ',' + nfId;
        String brandTokenCred;
        if (userHasBothBrands) {
            String qbTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, 'Quick Bridge');
            String nfTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, 'National Funding');
            if(qbTokenCred.startsWith('This service is temporarily unavailable.') || nfTokenCred.startsWith('This service is temporarily unavailable.')){
                throw new GenericException('This service is temporarily unavailable.');
            }
            HelperClass.upsertDFPToken(recordId, 'National Funding', nfTokenCred);
            HelperClass.upsertDFPToken(recordId, 'Quick Bridge', qbTokenCred);
            brandTokenCred = qbTokenCred;
        } else {
            brandTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, brand);
            if(brandTokenCred.startsWith('This service is temporarily unavailable.')) {
                throw new GenericException('This service is temporarily unavailable. ');
            }
            HelperClass.upsertDFPToken(recordId, brand, brandTokenCred);
        } 
        return brandTokenCred;
    }    
}