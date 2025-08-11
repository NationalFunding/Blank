public class ApplicationCheck {

    @AuraEnabled
    public static list<OpportunityContactRole> getOCR(string opportunityId) {
        return [
            SELECT Id, Role
            FROM OpportunityContactRole
            Where OpportunityId =: opportunityId
        ];
    }
    
    @AuraEnabled
    public static list<Account> getAccountFields(string AccountId){
        return [
            SELECT Id,Fed_Tax_ID__c,Legal_Status__c, Date_Established__c, State_of_Incorporation__c, AnnualRevenue, ShippingAddress, BillingAddress, Legal_Name__c, Phone, BillingPostalCode, BillingState, BillingCity, BillingStreet
            FROM Account
            WHERE Id=:AccountId
        ];
    }

    @AuraEnabled
    public static Application_Setting__mdt getApplicationSettingsCMDT(){
        try {
            Application_Setting__mdt settings = [
                SELECT Id, DeveloperName, Label, MasterLabel, FCRA_Date_Limit__c
                FROM Application_Setting__mdt 
                WHERE DeveloperName = 'settings'
                LIMIT 1
            ];
            System.debug('settings - ' + settings);
            return settings;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getFileAndAttachmentNames(string OpportunityId){

        List<string> fileNames = new List<string>();

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId =:OpportunityId];
        List<ContentDocumentLink> files = [SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =:OpportunityId];

        for(Integer i=0; i<attachments.size(); i++){
            filenames.add(attachments[i].Name);
        }

        for(Integer i=0; i<files.size(); i++){
            filenames.add(files[i].ContentDocument.Title);
        }

        Boolean isPlaidPresent = hasPlaid(OpportunityId);
        if (isPlaidPresent) {
            filenames.add('Plaid_Bank_Data_Present');
        }

        return fileNames;
    }

    public static Boolean hasPlaid (string recordId) {
        try {
            // ensure pdf files relating to bank statements and plaid json files on related opportunity
            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :recordId ORDER BY CreatedDate DESC LIMIT 1];
            List<Bank_Data__c> bankData = [SELECT Id FROM Bank_Data__c WHERE Account__c = :opp.AccountId];
            boolean plaidPresent = bankData.size() > 0;
            return plaidPresent;
        } catch (Exception e) {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<object> getContactInformation(string OpportunityId){
        return [
            SELECT Id,  Contact.Name, Contact.FCRA_Accepted_Date_Time__c, Contact.FirstName, Contact.LastName, Contact.Title, Contact.Email, Contact.MobilePhone, Contact.Birthdate, Contact.SSN_Encrypted__c, Contact.Ownership_Percentage__c, Contact.HomePhone, Contact.MailingState, Contact.OtherAddress, Contact.OtherStreet, Contact.OtherState, Contact.OtherPostalCode, Contact.OtherCity, Contact.OtherCountry, Role
            FROM OpportunityContactRole
            WHERE (OpportunityId =:OpportunityId) AND (Role = 'Signor' OR Role = 'Guarantor 2' OR Role = 'Guarantor 3')
            WITH USER_MODE
        ];
    }
}

// Enforce User Mode for Database Operations
// Added WITH USER_MODE to end of contact query to limit scope to user access
// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm