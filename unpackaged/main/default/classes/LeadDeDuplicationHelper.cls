/**
* TITLE: LeadDeDuplicationHelper
* DESCRIPTION:  This class will check for duplicate Leads before inserting a new one. 
                If existing record is found, we merge the new Lead data into old Lead record 
                    & delete the new Lead 
                    & update associated CampaignMembers. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @modifiedBy     Olivia Porter       olivia.k.porter@gmail.com
* @version        1.0
* @created        2022-08-25
*/
public with sharing class LeadDeDuplicationHelper {

    public void handleDuplicates(List<Lead> newLeadList){
        String[] fieldsToSync = new String[]{'Company', 'Phone', 'Fax', 'MobilePhone', 'FirstName', 'LastName', 'Salutation', 'Title',
            'Ownership_Percentage__c', 'Email', 'Web_Id_NatFund__c', 'Accepts_CC__c', 'Amount__c', 'AnnualRevenue', 'Street','City','State','Country',
            'CC_Processor__c', 'Trans_Value_per_Month__c', 'Date_Established__c', 'Date_Funds_Needed__c', 'Initial_Product_Response__c',
            'Equipment_Cost__c', 'Equipment_Condition__c', 'Equipment_Time_Frame__c', 'Initial_Product_Interest__c',
            'Internet_Response_Date__c', 'Landing_Page__c', 'LeadSource', 'Newsletter_Requested__c','Response_Channel__c',
            'Type_of_Equipment__c', 'Use_of_Funds__c', 'SSN_Encrypted__c', 'SSN_Capture_by_Web2Lead__c', 'Vendor_Contact__c', 
            'Vendor_Name__c', 'Vendor_Phone__c', 'Web_to_Lead_Use_of_Funds__c','Initial_Lead_Source__c', 'Initial_Response_Channel__c',
            'DaddyAnalytics__DA_Visitor_Landing_Page__c', 'DaddyAnalytics__DA_Web_to_Lead_URL__c',
            'DaddyAnalytics__DA_Visitor_Organisation__c', 'DaddyAnalytics__DA_Referrer_Search__c',
            'DaddyAnalytics__DA_Referrer_Website__c', 'DaddyAnalytics__DA_Token__c', 'DaddyAnalytics__DA_Visitor_Geolocation__Latitude__s',
            'DaddyAnalytics__DA_Visitor_Geolocation__Longitude__s', 'DaddyAnalytics__DA_Campaign_Name__c', 'DaddyAnalytics__DA_Campaign_Source__c',
            'DaddyAnalytics__DA_Campaign_Medium__c', 'DaddyAnalytics__DA_Campaign_Content__c', 'DaddyAnalytics__DA_Campaign_Term__c',
            'DaddyAnalytics__DA_Session_ID__c', 'DaddyAnalytics__DA_User_ID__c', 'DaddyAnalytics__DA_Visit_Time__c','SSN_Captured_On_Activation_Date__c',
            'Account_Number__c', 'Short_Account_Number__c', 'DLP_Email_Status__c', 'Annual_Sales__c', 'Brand__c', 'Marketo_Cookie_Id__c','gclid_ID__c', 'gclsrc_ID__c', 'Privacy_Policy_Accepted__c'};
        
        Lead srcLead;
        Lead[] leadsToWork = new Lead[]{};
        String[] acctNumbers = new String[]{};
        String[] zipCodes = new String[]{};
        Map<String,Map<String,Lead>> leadShortAcctNumMap = new Map<String,Map<String,Lead>>();
        Map<String,Map<String,Lead>> leadAcctNumMap = new Map<String,Map<String,Lead>>();
        Map<String,Lead> mapLeadToLead = new Map<String,Lead>();
        List<String> leadIds = new List<String>();
        String val;

        for (Lead ld : newLeadList) {
            if (ld.Web_Lead__c == true) {
                ld.Web_Lead__c = false;
                ld.Internet_Workflows__c = 'To Be Processed - New';

                if (ld.PostalCode == null || ld.Account_Number__c == null) {
                    continue;
                }
                
                if (ld.Short_Account_Number__c != null) {
                    acctNumbers.add(ld.Short_Account_Number__c);
                    if (!leadShortAcctNumMap.containsKey(ld.Short_Account_Number__c)) {
                        leadShortAcctNumMap.put(ld.Short_Account_Number__c,new Map<String,Lead>());
                    }
                    leadShortAcctNumMap.get(ld.Short_Account_Number__c).put(ld.PostalCode,ld);
                }
                    
                if (ld.Account_Number__c != null) {
                    acctNumbers.add(ld.Account_Number__c);
                    if (!leadAcctNumMap.containsKey(ld.Account_Number__c)) {
                        leadAcctNumMap.put(ld.Account_Number__c,new Map<String,Lead>());
                    }
                    leadAcctNumMap.get(ld.Account_Number__c).put(ld.PostalCode,ld);
                }

                leadsToWork.add(ld);
                zipCodes.add(ld.PostalCode);
            }
        }

        if (leadsToWork.size() == 0) {
            return;
        }
        
        // check for all the related campaign members
        List<CampaignMember> CMs = [SELECT Id, LeadId, Account_Number__c, Short_Account_Number__c, Lead_Postalcode__c 
                                    FROM CampaignMember
                                    WHERE LeadId != NULL
                                    AND LeadId NOT IN :newLeadList // not sure this would ever happen
                                    AND Lead_Account_Status__c = 'House'
                                    AND (Account_Number__c in :acctNumbers OR Short_Account_Number__c in :acctNumbers)
                                    AND Lead_Postalcode__c in :zipCodes];
        
        if (CMs.size() == 0) {   
            return; 
        }
        
        for (CampaignMember cm : CMs) {
            srcLead = null;
            if ((cm.Account_Number__c != null) && leadShortAcctNumMap.containsKey(cm.Account_Number__c) && leadShortAcctNumMap.get(cm.Account_Number__c).containsKey(cm.Lead_Postalcode__c)){ 
                srcLead = leadShortAcctNumMap.get(cm.Account_Number__c).get(cm.Lead_Postalcode__c);
            } else if ((cm.Short_Account_Number__c != null) && leadShortAcctNumMap.containsKey(cm.Short_Account_Number__c) && leadShortAcctNumMap.get(cm.Short_Account_Number__c).containsKey(cm.Lead_Postalcode__c)) {
                srcLead = leadShortAcctNumMap.get(cm.Short_Account_Number__c).get(cm.Lead_Postalcode__c);
            } else if ((cm.Account_Number__c != null) && leadAcctNumMap.containsKey(cm.Account_Number__c) && leadAcctNumMap.get(cm.Account_Number__c).containsKey(cm.Lead_Postalcode__c)) {
                srcLead = leadAcctNumMap.get(cm.Account_Number__c).get(cm.Lead_Postalcode__c);
            } else if ((cm.Short_Account_Number__c != null) && leadAcctNumMap.containsKey(cm.Short_Account_Number__c) && leadAcctNumMap.get(cm.Short_Account_Number__c).containsKey(cm.Lead_Postalcode__c)) {
                srcLead = leadAcctNumMap.get(cm.Short_Account_Number__c).get(cm.Lead_Postalcode__c);
            }

            if (srcLead == null) {
                continue;
            }

            // at this point we've found a match.  Update CM.
            cm.Status = 'Responded';
            cm.Response_Channel__c = srcLead.Response_Channel__c;
            mapLeadToLead.put(cm.LeadId,srcLead); //old lead, new lead
        }
        
        if (mapLeadToLead.keySet().size() == 0) {
            return; // no leads perfectly match
        }
        
        String fields = String.join(fieldsToSync, ', ');
        for (String ldStr : mapLeadToLead.keySet()){
            leadIds.add('\'' + ldStr + '\'');
        }
        
        List<Lead> leads = Database.query('SELECT Internet_Workflows__c, Id,' + fields + ' FROM Lead WHERE Id IN (' + String.join(leadIds,', ') + ')'); //all of the old leads
    
        
        for (Lead l : leads) {
            //srcLead = new lead //l = old lead
            srcLead = mapLeadToLead.get(l.id); //getting the new leadid

            for (String field : fieldsToSync){
                if (srcLead.get(field) != null){
                    l.put(field,srcLead.get(field)); //putting new lead values into old lead fields
                }
            }

            l.Internet_Workflows__c = 'To Be Processed - Merged';
            
            srcLead.Delete_Me__c = true; //deleting the new lead after we merge all of the new data into the old lead record
            srcLead.Status = 'Internet Hold'; 
            srcLead.Internet_Workflows__c = null; // prevent processing
            srcLead.Web_Id_NatFund__c = null;
            srcLead.DaddyAnalytics__DA_Token__c = null;
        }
        update CMs;
        update leads;
    }
}