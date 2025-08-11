/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: lead_isSSNBlankHelper
* DESCRIPTION: checking if the lead's ssn is blank. this is a helper and is called in the AllLeadTriggers.trigger
*                this class is a part of a larger effort to merge all Lead triggers into one
* @author         
* @version        1.0
* @created        
* @mofidied       olivia.k.porter@gmail.com - pulled over from old lead trigger. this class is a direct copy and paste
* ────────────────────────────────────────────────────────────────────────────────────────────────
* Technical Debt Notes:
*   - naming convention should be updated
*/     
public with sharing class lead_isSSNBlankHelper {

    public void isLeadSSNBlank(List<Lead> newLeadList){
        for (Lead lead : newLeadList){
            lead.SSN_Is_Blank__c = ((lead.SSN_Encrypted__c == '') || (lead.SSN_Encrypted__c == null));        
        }
    }
}