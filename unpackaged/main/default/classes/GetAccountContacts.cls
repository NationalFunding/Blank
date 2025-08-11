public class GetAccountContacts {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(string accountId) {
        Map<Id, String> contactPhoneMap = new Map<Id, String>();
        Map<String, Boolean> twilioMap = new Map<String, Boolean>();
        List<Contact> accountContacts = [SELECT Id, Name, Phone, Email, MobilePhone, Title, Ownership_Percentage__c, HasOptedOutOfEmail, SMS_Opt_Out__c, SMS_Opt_In__c, MailingAddress, MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode, DLP_Email_Status__c, OtherAddress, OtherCity, OtherCountry, OtherState, OtherStreet, OtherPostalCode, SSN_Encrypted__c, Nickname__c
                                        FROM Contact 
                                        WHERE AccountId = :accountId 
                                        ORDER BY Ownership_Percentage__c DESC Nulls Last, LastName ASC];   


        
        for(Contact c : accountContacts){
            if(c.MobilePhone != null){
                String unformattedPhone = c.MobilePhone.replaceAll('\\D','');
                contactPhoneMap.put(c.Id, unformattedPhone);

            }
        }


        for(TwilioSF__Opt_In__c twil : [SELECT Id, TwilioSF__Opt_In_Phone_Number_Unformatted__c, TwilioSF__Lead__c, TwilioSF__Opt_In_Date_Time__c, TwilioSF__Opt_Out_Date_Time__c
                                        FROM TwilioSF__Opt_In__c 
                                        WHERE TwilioSF__Opt_In_Date_Time__c != NULL
                                        AND TwilioSF__Opt_In_Phone_Number_Unformatted__c IN :contactPhoneMap.values() ]) {
            if((twil.TwilioSF__Opt_In_Date_Time__c != null && twil.TwilioSF__Opt_Out_Date_Time__c == null) 
            || (twil.TwilioSF__Opt_Out_Date_Time__c != null && twil.TwilioSF__Opt_In_Date_Time__c != null 
            && twil.TwilioSF__Opt_In_Date_Time__c > twil.TwilioSF__Opt_Out_Date_Time__c)){
                twilioMap.put(twil.TwilioSF__Opt_In_Phone_Number_Unformatted__c, true);
            }
        }

        if(!twilioMap.isEmpty()){
            for(Contact c : accountContacts){
                if(c.MobilePhone != null){
                    String unformattedPhone = c.MobilePhone.replaceAll('\\D','');
                    Boolean isOptedIn = twilioMap.get(unformattedPhone);
                    if(isOptedIn != null && isOptedIn){
                        c.SMS_Opt_In__c = true; 
                    } else {
                        c.SMS_Opt_In__c = false;
                    }
                }
            }
        }

        return accountContacts;
    }
    
    @AuraEnabled
    public static List<contact> getContactInfo(string contactId){
        return [
        	Select Id, Name, SMS_Opt_In__c, SMS_Opt_Out__c, SMS_Requested__c, Last_Opt_In_Message_Sent__c, SMS_Opt_In_Date_Time__c, SMS_Requested_Date_Time__c
        	FROM Contact
            WHERE Id =:contactId
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<object> getContactMarketingStatus(string accountId){
        return [
            SELECT Id, CampaignId, FirstRespondedDate, HasResponded, Status, ContactId, Campaign.Name, Contact.Name, Account_Number__c 
            FROM CampaignMember 
            Where Contact.AccountId =: accountId
        ];
    }
}