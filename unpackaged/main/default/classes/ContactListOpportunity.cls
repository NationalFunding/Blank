public class ContactListOpportunity {

    @AuraEnabled(cacheable=true)
    public static List<String> getMainOppContactRole() {
        Opportunity_Contact_Roles__mdt oppContactRoles = Opportunity_Contact_Roles__mdt.getInstance('Unique_Roles');
        List<String> uniqueRoles = oppContactRoles.Role_Name__c.split(',');
        system.debug('###contactRoles' + uniqueRoles);
        return uniqueRoles;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getOpportunityContacts(string accountId, string opportunityId) {
        Map<Id, String> contactPhoneMap = new Map<Id, String>();
        Map<String, Boolean> twilioMap = new Map<String, Boolean>();

        List<Contact> accountContacts = [SELECT Id, Name, Title, Email, Mobilephone, HasOptedOutOfEmail, OtherAddress, Ownership_Percentage__c, SMS_Opt_In__c, SMS_Opt_Out__c, OtherCity, OtherCountry, OtherState, OtherStreet, OtherPostalCode, MailingPostalCode, SSN_Encrypted__c,Nickname__c,
                                            (SELECT Id, Role, IsPrimary 
                                            FROM OpportunityContactRoles 
                                            WHERE OpportunityId =:opportunityId)
                                        FROM Contact
                                        WHERE AccountId = :accountId]; 

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
}