/*************************************************************************************************************************
Trigger Name : Opportunity count on Account.
Created Date : 10/15/2011
Created By   : Srikanth Pothuraj
Description  : When the Opprtunity Record type = Lease, Type = New, Stage = Funded then its Account would get updated. The
               Field which gets updates is Lease Plus No. This trigger would query on all the Accounts and updates the field
               in a Incrementing order. 
 Updates    :  10/28/24 - updated by FTC - added check to see if oppty is funded or Up for Funding before proceeding with logic
            :  11/18/24 - updated by FTC - removed check for Actuals_Audit_Complete__c
**************************************************************************************************************************/

trigger OpportunityCountOnAccount on Opportunity (before insert, before update) {
    List<Opportunity> fundedOpportunities = new List<Opportunity>();

    for ( Opportunity opp : Trigger.new ) {
        if (opp.StageName == 'Funded' || opp.StageName == 'Up for Funding') {
            if (Trigger.isInsert) {
                fundedOpportunities.add(opp);
            } else if (Trigger.isUpdate) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (oldOpp.StageName != 'Funded' ) {
                    fundedOpportunities.add(opp);
                }
            }
        }
    }

    if(fundedOpportunities.size() > 0){     

        Id leaseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Oppty').getRecordTypeId();
        Id MCARecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Working Capital Oppty').getRecordTypeId();
        Id EPPRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EPP Oppty').getRecordTypeId();
        Id BrokerWCRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Broker WC Oppty').getRecordTypeId();    
        ID ExternalCollectionsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('External Collections').getRecordTypeId();
        Id FRPSARecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FRPSA').getRecordTypeId();
        Id FRPSABrokerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Broker FRPSA').getRecordTypeId();
        Id MLPRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Direct MLP').getRecordTypeId();

        
        Map<String,Id> acctNameToId = new Map<String,Id>();
        List<Account> acctTemp = [SELECT Name, Id FROM Account WHERE Name = 'National Funding - Platinum WC Funding' OR Name = 'National Funding - Gold WC Funding'OR Name = 'National Funding - Diamond WC Funding' OR Name = 'National Funding - Commercial WC Funding' OR Name = 'Quick Bridge Funding'];
        for (Account a : acctTemp)
            acctNameToId.put(a.name,a.id);
            
        Account dummyAcc;
        Set<Id> accIdSet = new Set<Id>();
        Set<String> oppStages = new Set<String>{'Docs In','Up for Funding','Pre-Fund','Funded'};
        List<Account> acctsToUpdate = new List<Account>();

        for (Opportunity opp : fundedOpportunities) {
            if (opp.RecordTypeId == leaseRecordTypeId && (opp.Type == 'NEW' || opp.Type == 'SP NEW')  && oppStages.contains(opp.StageName) && (opp.Lease_Deposit_Check_Received__c || (opp.ACH_Debit__c=TRUE && opp.Total_ACH_Debits__c >= 1)))
                accIdSet.add(opp.AccountId);
            if ((opp.RecordTypeId == MCARecordTypeId || opp.RecordTypeId == FRPSARecordTypeId || opp.RecordTypeId == MLPRecordTypeId ) && (opp.Type == 'NEW' || opp.Type== 'SP NEW') && opp.StageName == 'Funded' && (opp.Lender_Account__c == acctNameToId.get('National Funding - Platinum WC Funding') || opp.Lender_Account__c == acctNameToId.get('National Funding - Gold WC Funding') || opp.Lender_Account__c == acctNameToId.get('National Funding - Commercial WC Funding') || opp.Lender_Account__c == acctNameToId.get('National Funding - Diamond WC Funding'))  )
                accIdSet.add(opp.AccountId);
            if ((opp.RecordTypeId == MCARecordTypeId || opp.RecordTypeId == FRPSARecordTypeId || opp.RecordTypeId == MLPRecordTypeId ) && opp.StageName == 'Funded' && opp.Lender_Account__c == acctNameToId.get('Quick Bridge Funding')  )
                accIdSet.add(opp.AccountId);
            if (opp.RecordTypeId == EPPRecordTypeId && opp.EPP_Equip_LP__c == true && opp.EPP_Equip_PO_to_Accounting__c == true)
                accIdSet.add(opp.AccountId);
            if ((opp.RecordTypeId == BrokerWCRecordTypeId || opp.RecordTypeId == FRPSABrokerRecordTypeId ) && opp.Type == 'NEW' && opp.StageName == 'Funded' && (opp.Lender_Account__c == acctNameToId.get('National Funding - Platinum WC Funding') || opp.Lender_Account__c == acctNameToId.get('National Funding - Gold WC Funding')|| opp.Lender_Account__c == acctNameToId.get('National Funding - Commercial WC Funding') || opp.Lender_Account__c == acctNameToId.get('National Funding - Diamond WC Funding')) )
                accIdSet.add(opp.AccountId); 
            if (opp.RecordTypeId == ExternalCollectionsRecordTypeId && opp.StageName == 'Funded' && opp.Lender_Account__c == acctNameToId.get('Quick Bridge Funding') )
                accIdSet.add(opp.AccountId);
        }
        
        if(accIdSet != null && accIdSet.size() > 0){
            Bean_Counter__c bc = Bean_Counter__c.getOrgDefaults();
            
            if (bc.Lease_Plus_Number__c == null){
                bc.Lease_Plus_Number__c = 0;
            }

            acctsToUpdate = [SELECT LP_Cust_Number__c, Id FROM Account WHERE Id IN :accIdSet AND LP_Cust_Number__c = null];
            Integer maxValue = Integer.valueOf(bc.Lease_Plus_Number__c);
            
            // Added 2015-02-02 jleblanc@thrive:  Prevent duplicate customer numbers (up to 100 in advance)
            List<String> custNumbers = new List<String>();
            for (Integer i = maxValue; i != maxValue + 100; i++)
                custNumbers.add(String.valueOf(i));
            
            List<Account> accts = [SELECT LP_Cust_Number__c FROM Account WHERE LP_Cust_Number__c IN :custNumbers];
            for (Account acct : accts) if (maxValue < Integer.valueOf(acct.LP_Cust_Number__c) + 1) maxValue = Integer.valueOf(acct.LP_Cust_Number__c);
            // End 2015-02-02 changes.
            
            for (Account acc : acctsToUpdate){
                if (acc.LP_Cust_Number__c == null || acc.LP_Cust_Number__c == ''){
                    acc.LP_Cust_Number__c = String.valueOf(++maxValue);
                }
            }
            update acctsToUpdate;

            bc.Lease_Plus_Number__c = maxValue;
            
            if (!Test.isRunningTest()){
                update bc;
            }
        }
    }
}