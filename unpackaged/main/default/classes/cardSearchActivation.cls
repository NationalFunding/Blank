public with sharing class cardSearchActivation {

    // Modified for National Funding Lightning Transition
    // Original Code: https://nf.lightning.force.com/lightning/setup/ApexClasses/page?address=%2F01p8000000041Ej

    // Lead Activation
    @AuraEnabled
    public static object activateLead(String cmId, String leadId, String userId){

        system.debug('Lead Id: ' + leadId);
        system.debug('CM Id: ' + cmId);
        system.debug('UserId: ' + userId);

        CampaignMember[] cm = [Select Status,Short_Account_Number__c,Account_Number__c,Activation_Code__c,Campaign_Type__c,Campaign.Product_Target__c, Campaign.Brand__c From CampaignMember where id = :cmId];

        system.debug('Campaign Member:');
        system.debug(cm);
        
        if (cm.size() > 0){
            cm[0].Status = 'Responded';
            upsert cm;
        }

        Lead theLead = [Select Id,Last_Campaign_Response_Date__c,Activation_Date__c,Rep_Ownership_Date__c,Initial_Lead_Source__c,Response_Channel__c,LeadSource,Account_Number__c,Status,Status_MCA__c,OwnerId,IsConverted, Brand__c,Initial_Response_Channel__c,Initial_Response_Rep__c, Initial_Response_User__c, Initial_Product_Response__c from Lead where Id = :leadId];
        Boolean ownedByQueue = String.valueOf(theLead.OwnerId).startsWith('00G');
        User leadOwner;
        
        if (!ownedByQueue){
            leadOwner = [SELECT Sales_User__c FROM User WHERE Id = :theLead.OwnerId];
        }

            
        if (theLead != null && theLead.Status != 'Qualified/Converted'){
            
            Boolean hasActivationDate = false;

            if(theLead.Activation_Date__c == null) {
                theLead.Activation_Date__c = System.now();
            } else{
                hasActivationDate = true;
            }

            if(cm.size() > 0){
                theLead.Short_Account_Number__c = cm[0].Short_Account_Number__c;
                theLead.Account_Number__c = cm[0].Account_Number__c;
                theLead.Activation_Code__c = cm[0].Activation_Code__c;            
                theLead.LeadSource = cm[0].Campaign_Type__c;
            }

            theLead.Response_Channel__c = 'Inbound Call';
            theLead.Last_Card_Search_Date__c = Date.today();
            
            if((ownedByQueue || leadOwner.Sales_User__c == false) && (theLead.status != 'House' || !hasActivationDate)){

                system.debug('lead owner is House account or DB Amp, reassigning to current user...');

                theLead.OwnerId = userId;
                User usr = [SELECT Name, Id FROM User WHERE Id = :theLead.ownerId];

                theLead.Rep_Ownership_Date__c = Date.today();
                theLead.Card_Search_Used__c = true;
                theLead.Last_Campaign_Response_Date__c = Date.today();

                if (!hasActivationDate) {
                    if (theLead.Initial_Response_Channel__c == null){
                        theLead.Initial_Response_Channel__c = 'Inbound Call';
                    }
                    if (theLead.Initial_Response_Rep__c == null){
                        theLead.Initial_Response_Rep__c = usr.Name;
                    }
                    if (theLead.Initial_Response_User__c == null){
                        theLead.Initial_Response_User__c = usr.id;
                    }
                    if (theLead.Initial_Lead_Source__c == null){
                        theLead.Initial_Lead_Source__c = theLead.LeadSource;
                    }
                    if (theLead.Initial_Product_Response__c == null && cm.size() > 0){
                        theLead.Initial_Product_Response__c = cm[0].Campaign.Product_Target__c;
                    }
                }
            }
            
           string lst = theLead.Status;
           system.debug('the lead status is... '+lst);

            if((lst == 'House' || lst == 'Open' || lst == 'Pursuing' || lst == 'Contacted') && (lst != 'Prospect' && lst != 'Activator' && lst != 'Remove from List')){ 
                theLead.Status = 'Prospect';
                system.debug('changing the lead status to... '+theLead.Status);

                if(cm.size() > 0){
                    theLead.Brand__c = cm[0].Campaign.Brand__c;
                }
            }
    
            update theLead;
        }
        
        Map<String,String> valueReturn = new Map<String,String>();
        valueReturn.put('RedirectRecord', leadId);
        valueReturn.put('RedirectObject', 'Lead');
               
        return valueReturn;

    }


    // Contact Activation
    @AuraEnabled
    public static object activateContact(String cmId, String contactId, String userId){

        system.debug('cmId: ' + cmId);
        system.debug('ContactId: ' + contactId);
        system.debug('UserId: ' + userId);

        Contact cont = [Select Account.Owner.Sales_User__c, AccountId, LeadSource From Contact WHERE Id = :contactId];
        CampaignMember[] cm = [Select Status,Short_Account_Number__c,Account_Number__c,Activation_Code__c,Campaign_Type__c,Campaign.Product_Target__c From CampaignMember where id = :cmId];
        User currentUser = [SELECT Sales_User__c FROM User WHERE Id = : userId];

        system.debug('Contact:');
        system.debug(cont);

        system.debug('Campaign Member:');
        system.debug(cm);

        system.debug('currentUser:');
        system.debug(currentUser);



        if(cm.size() > 0)
        {
            system.debug('Updaing CM');

            cm[0].Status = 'Responded';
            upsert cm;

            cont.LeadSource = cm[0].Campaign_Type__c;
            upsert cont;
        }
            
        Account acct = new Account(id = cont.accountId);
        acct.Response_Channel__c = 'Inbound Call';
        acct.Last_Card_Search_Date__c = Date.today();
            
        if (cont.Account.Owner.Sales_User__c == false) {
            acct.OwnerId = userId;
            acct.Rep_Ownership_Date__c = Date.today();
            acct.Card_Search_Used__c = true;
            acct.Last_Campaign_Response_Date__c = Date.today();

            if (acct.Initial_Response_Channel__c == null)
                acct.Initial_Response_Channel__c = acct.Response_Channel__c;
            if (acct.Initial_Lead_Source__c == null)
                 acct.Initial_Lead_Source__c = cont.LeadSource;
            if (acct.Initial_Product_Response__c == null && cm.size() > 0)
                acct.Initial_Product_Response__c = cm[0].Campaign.Product_Target__c;
        }

        upsert acct;

        Map<String,String> valueReturn = new Map<String,String>();
        valueReturn.put('RedirectRecord', cont.accountId);
        valueReturn.put('RedirectObject', 'Account');
               
        return valueReturn;

    }

}