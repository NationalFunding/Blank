public class SendDLPEmail {
    
    @AuraEnabled
    public static void sendDLPEmail(String recordId){  
        system.debug('###FWO do we even get in here???' + recordId);
        
        // Determine Object Type
        
        // Lead
        if(recordId.startsWithIgnoreCase('00Q')){
            
            SendDLPtoLead(recordId);
            
            // Contact
        } else if (recordId.startsWithIgnoreCase('003')) {
            
            SendDLPtoContact(recordId);
            
            // Unknown Object Type
        } else {
            
            string errorMessage = 'Attempting to Send DLP Email to Unknown Object Type - Submitted Record: ' + recordId;
            
            System.debug(errorMessage);
            throw new GenericException(errorMessage);
            
        }
        
    }
    
    private static void SendDLPtoLead(String leadId){
        system.debug('do we get in here??');
        Lead lead = [SELECT Id, OwnerId, Owner.Type, Web_Id_NatFund__c, National_Funding_WebId__c FROM Lead WHERE Id =: leadId];
        String nfId = lead.Web_Id_NatFund__c != null ? lead.Web_Id_NatFund__c : lead.National_Funding_WebId__c;
        Map<String, Id> emailTemplates = new Map<String, Id>();
        for (EmailTemplate et : [SELECT Id, Name FROM EmailTemplate WHERE Name IN ('Lead - DLP Email (QB)', 'Lead - DLP Email')]) {
            emailTemplates.put(et.Name, et.Id);
        }
        
        String emailTemplateId = '';
        String sourceOrg = 'National Funding';
        Boolean userHasBothBrands = false;
        String brand = 'National Funding';
        // SPR-61 (7 Feb 2025): Determine email template based on the owner's Available_Brands__c field
        // If the field contains 'Quick Bridge', select the 'Lead - DLP Email (QB)' template; 
        // otherwise, use the default 'Lead - DLP Email' template.
        if (lead.OwnerId != null && lead.Owner.Type == 'User') {
            User userInfo = [SELECT Id, Available_Brands__c FROM User WHERE Id = :lead.OwnerId LIMIT 1];
            if(userInfo.Available_Brands__c != null) {
                String availableBrands = userInfo.Available_Brands__c;
                userHasBothBrands = availableBrands.contains('Quick Bridge') && availableBrands.contains('National Funding');
                brand = availableBrands.contains('Quick Bridge') ? 'Quick Bridge' : 'National Funding';
            }
        }
        
        emailTemplateId = brand.contains('Quick Bridge') ? emailTemplates.get('Lead - DLP Email (QB)') : emailTemplates.get('Lead - DLP Email');      
        system.debug('hello?');
        refreshEmailString(leadId, nfId, sourceOrg, brand, userHasBothBrands);
        SendEmailHelper.sendEmail(leadId, emailTemplateId);
        
    }
    
    private static void SendDLPtoContact(String contactId){
        String emailTemplateId = '';
        String brand = 'National Funding';
        String sourceOrg = 'National Funding';
        Boolean userHasBothBrands = false;
        Contact contact = [select id,AccountId, Account.NF_Renewal_Rep__r.Available_Brands__c, Account.Owner.Available_Brands__c, Account.Web_Id_NatFund__c, Account.National_Funding_WebId__c from contact where id =: contactId];
        Map<String, Id> emailTemplates = new Map<String, Id>();
        String nfId = contact.Account.Web_Id_NatFund__c != null ? contact.Account.Web_Id_NatFund__c : contact.Account.National_Funding_WebId__c;
        for (EmailTemplate et : [SELECT Id, Name FROM EmailTemplate WHERE Name IN ('Account - DLP Request (QB)', 'Account - DLP Request')]) {
            emailTemplates.put(et.Name, et.Id);
        }
        // SPR-61 (7 Feb 2025): Determine the email template based on the Account's Available_Brands__c field.
        // First, check if the Account has a Renewal Rep with 'Quick Bridge' in Available_Brands__c.
        // If the Renewal Rep exists and has 'Quick Bridge', use the 'Account - DLP Request (QB)' template.
        // If the Renewal Rep is NULL, then check the Account Owner's Available_Brands__c field.
        // If neither has 'Quick Bridge', use the default 'Account - DLP Request' template..
        if (contact.AccountId != null) {   
            if(contact.Account.NF_Renewal_Rep__r != null){
                if(contact.Account.NF_Renewal_Rep__r.Available_Brands__c != null){
                    String availableBrands = contact.Account.NF_Renewal_Rep__r.Available_Brands__c;
                    userHasBothBrands = availableBrands.contains('Quick Bridge') && availableBrands.contains('National Funding');
                    brand = availableBrands.contains('Quick Bridge') ?  'Quick Bridge' : 'National Funding';
                }
            }else if(contact.Account.Owner != null){
                if(contact.Account.Owner.Available_Brands__c != null){
                    string availableBrands = contact.Account.Owner.Available_Brands__c;
                    userHasBothBrands = availableBrands.contains('Quick Bridge') && availableBrands.contains('National Funding');
                    brand = availableBrands.contains('Quick Bridge') ?  'Quick Bridge' : 'National Funding';
                }
            }
        }
        
        emailTemplateId = brand.contains('Quick Bridge') ? emailTemplates.get('Account - DLP Request (QB)') : emailTemplates.get('Account - DLP Request');
        refreshEmailString(contactId, nfId, sourceOrg, brand, userHasBothBrands);
        
        SendEmailHelper.sendEmail(contactId, emailTemplateId);
    }
    
    /**
* SPR-107 (20 Feb 2025): Refreshes the encrypted email string for a given record.
* - If the user has access to both brands, it refreshes for both 'Quick Bridge' and 'National Funding'.
* - Otherwise, it refreshes only for the specified brand.
*
* @param recordId       The ID of the record for which the email string is being refreshed.
* @param sourceOrg      The source organization from which data is retrieved.
* @param brand          The brand for which the email string is refreshed (if user has only one brand).
* @param userHasBothBrands Indicates whether the user has access to both brands.
*/
    private static void refreshEmailString(String recordId, String nfId, String sourceOrg, String brand, Boolean userHasBothBrands){
        String recordIdNfId = recordId + ',' + nfId;
        if (userHasBothBrands) {
            String qbTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, 'Quick Bridge');
            String nfTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, 'National Funding');
            
            if(qbTokenCred.startsWith('This service is temporarily unavailable.') || nfTokenCred.startsWith('This service is temporarily unavailable.')){
                throw new GenericException('This service is temporarily unavailable.');
            }
            
            
            HelperClass.upsertDFPToken(recordId, 'National Funding', nfTokenCred);
            HelperClass.upsertDFPToken(recordId, 'Quick Bridge', qbTokenCred);
            
        } else {
            string brandTokenCred = ConsoleApplicationLinkController.getShortenedLinkLoanMod(recordIdNfId, sourceOrg, brand);
            
            if(brandTokenCred.startsWith('This service is temporarily unavailable.')) {
                throw new GenericException('This service is temporarily unavailable. ');
            }
            HelperClass.upsertDFPToken(recordId, brand, brandTokenCred);
        }   
    }
    
}