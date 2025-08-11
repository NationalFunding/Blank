trigger TaskAfterInsertUpdate on Task (after insert, after update, before Update) 
{
    if(Trigger.isInsert && Trigger.isAfter)
    {
        Five9PS_TaskTriggerHandler triggerHandler = new Five9PS_TaskTriggerHandler();
        triggerHandler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        Five9PS_TaskTriggerHandler triggerHandler = new Five9PS_TaskTriggerHandler();
        triggerHandler.OnBeforeUpdate(Trigger.new);
    }
	/*
    Set<Id> accounts = new Set<Id>();
    Set<Id> leads = new Set<Id>();
    Set<Id> opps = new Set<Id>();
    Map<Id,String> leadDispMap = new Map<Id,String>();
    Map<Id,String> oppDispMap = new Map<Id,String>();
    for(Task t:Trigger.new) {
        if(Trigger.isInsert || (Trigger.isUpdate && t.Status == 'Completed' && Trigger.oldmap.get(t.Id).Status != 'Completed')) {
            if(t.AccountId != null)
                {accounts.add(t.AccountId);}
            if(t.WhoId != null)
                {leads.add(t.WhoId);}
            if(t.WhatId != null)
                {opps.add(t.WhatId);}
            
            if(t.Call_Disposition__c != null) {
                if(t.WhoId != null && leadDispMap.get(t.WhoId) == null)
                    leadDispMap.put(t.WhoId, t.Call_Disposition__c);
                
                if(t.WhatId != null && oppDispMap.get(t.WhatId) == null)
                    oppDispMap.put(t.WhatId, t.Call_Disposition__c);
            }
        }
    }


    Map<Id,Integer> accountMap = new Map<Id,Integer>(); 
    Map<Id,Integer> leadMap = new Map<Id,Integer>();
        
    //get counts for account
    for(AggregateResult ar : [SELECT AccountId, Count(Id)  ac
        FROM Task 
        WHERE AccountId in : accounts  
        AND Status = 'Completed'               
        Group by AccountId
        limit 1000])
        accountMap.put(String.valueOf(ar.get('AccountId')),Integer.valueOf(ar.get('ac')));   
    
    //get counts for leads/contacts
    for(AggregateResult ar : [SELECT WhoId, Count(Id)  ac
        FROM Task 
        WHERE WhoId in : leads 
        AND Status = 'Completed'           
        Group by WhoId
        limit 1000])
    {
        leadMap.put(String.valueOf(ar.get('WhoId')),Integer.valueOf(ar.get('ac')));
    }
            
    //update the Account call count
    Account[] updateAccounts = new Account[0];
    for(Account a:[select id, Call_Count__c from Account where id in :accounts limit 1000])
    {
        if(accountMap.get(a.Id) != null)
        {
            a.Call_Count__c = accountMap.get(a.Id);
            updateAccounts.add(a);
        }
    } 
    update updateAccounts;
    
    //update the Contact call count
    Contact[] updateContacts = new Contact[0];
    for(Contact c:[select id, Call_Count__c from Contact where id in :leads limit 1000])
    {
        if(leadMap.get(c.Id) != null)
        {
            c.Call_Count__c = leadMap.get(c.Id);
            if(leadDispMap.get(c.Id) != null)
            {
                c.Last_Call_Disposition__c = leadDispMap.get(c.Id);
            }
            
            updateContacts.add(c);
        }
    } 
    update updateContacts;  
    
    //update the Lead call count and last Call Disposition
    Lead[] updateLeads = new Lead[0];
    for(Lead l:[select id, Call_Count__c, Last_Call_Disposition__c  from Lead where id in :leads limit 1000])
    {
        if(leadMap.get(l.Id) != null)
        {
            l.Call_Count__c = leadMap.get(l.Id);
            
            if(leadDispMap.get(l.Id) != null)
            {
                l.Last_Call_Disposition__c = leadDispMap.get(l.Id);
            }
            updateLeads.add(l);
        }
    } 
    update updateLeads; 
    
    
    //update the Opp last Call Disposition
    Opportunity[] updateOpps = new Opportunity[0];
    for(Opportunity o:[select id, Last_Call_Disposition__c  from Opportunity where id in :opps limit 1000])
    {
            
        if(oppDispMap.get(o.Id) != null)
        {
            o.Last_Call_Disposition__c = oppDispMap.get(o.Id);
        }
        updateOpps.add(o);

    } 
    update updateOpps;
    */
}