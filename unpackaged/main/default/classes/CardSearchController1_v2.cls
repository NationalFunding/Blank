public with sharing class CardSearchController1_v2
{
    /*
    * SEARCH FIELDS
    */
    public String Card { get; set; }
    public String Street { get; set; }
    public String Zip { get; set; }
    public String Phone { get; set; }
    public String Name { get; set; }  
    public String Fax  {get; set;}
    public String BillingAddress {get; set;} 
    public List<Contact> lstContact = new list<Contact>();
    
    public String fake02String {get;set;} //card
	public String fake03String {get;set;} //name
    public String fake04String {get;set;} //phone
    public String fake05String {get;set;} //cardString
    public string varA { get { return fake04Submit(); } }
/** 4/4/12 walter - going to owner model so this is no longer needed.
     Profile prof1 = [Select Id, Name from Profile where Name = 'FPC - Lease - Sales User'];
    Profile prof2 = [Select Id, Name from Profile where Name = 'FPC - MCA - Sales User'];   
 */
    
    /*
    * DYNAMIC SOSL LIST
    */
    public List<List<SObject>> dynamicSearchList;
     
    //SUBMIT LIST FOR CONSOLE
    public PageReference fake03Submit() {
        PageReference prToNavigate = null;

        prToNavigate = Page.ConsoleCardSearch;
	    prToNavigate.getParameters().put('name', fake03String );
        prToNavigate.getParameters().put('phone', fake04String);
        prToNavigate.getParameters().put('card', fake02String);
        prToNavigate.setRedirect(false);

        return prToNavigate;
    }  
    
    public String fake04Submit(){
        PageReference k = fake03Submit();
       Map<String,String> y = new Map<String,String>();
          y.putAll(k.getParameters());
        string n = y.get('name');
       String s = k.getUrl();
		string p = s + '?name=' + n;
        return p;
    }
    
    public String fake05Submit(){
        string cpReference = ApexPages.currentPage().getParameters().get('name');
        fake02String = cpReference;
        Search1();
        return null;
    }
    /*
    * SEARCH COMMAND
    */   
    public PageReference Search() {
        
        // clear the lists before each search
        leads = null;
        lead_list = null;
        contacts = null;
        contact_list = null;
        campaignmembers = null;
        accounts = null;
        dynamicSearchList = null;
        account_list=null;
        
        
        String allPhone = '';
        String allFax = '';
        String allName = '';
        String companyName = '';
        String allCard = '';
        String aStreet = '';
        String cStreet = '';
        String lStreet = '';
        String leadIds = '';
        String ContactIds = '';
        boolean condition = false;
        //should this be AND or OR 
        
        String searchString = 'FIND ';
        

        if(Name != null && Name != '')
        {            
            condition = true;            
            searchString += '\'' + Name + '*';
      
        }
        
        if(Phone != null && Phone != '' && Phone.length() >= 10)
        {
            Phone = Phone.replaceAll('-', '');          
            Phone = Phone.replaceAll(' ', '');          
            Phone = Phone.replaceAll('\\(', '');            
            Phone = Phone.replaceAll('\\)', '');       
            string thePhone = Phone;            
            Phone = '(' + thePhone.substring(0, 3) + ') ';          
            Phone += thePhone.substring(3, 6) + '-';            
            Phone += thePhone.substring(6, 10);         
            
            if(condition )
            {                 
                searchString += ' OR ';        
            } 
            else
            {
                searchString += '\'';
            } 
                                
            searchString += Phone + '*';
            condition = true;
      
        } 
    
    if(Fax != null && Fax != '' && Fax.length() >= 10)
        {
            Fax = Fax.replaceAll('-', '');          
            Fax = Fax.replaceAll(' ', '');          
            Fax = Fax.replaceAll('\\(', '');            
            Fax = Fax.replaceAll('\\)', '');       
            string theFax = Fax;            
            Fax = '(' + theFax.substring(0, 3) + ') ';          
            Fax += theFax.substring(3, 6) + '-';            
            Fax += theFax.substring(6, 10);         
            
            if(condition )
            {                 
                searchString += ' OR ';        
            } 
            else
            {
                searchString += '\'';
            } 
                                
            searchString += Fax + '*';
            condition = true;
      
        } 
      // the cards search is based on campaign members
        if(Card != null && Card != '')
        {
            if(condition )
            {                 
                searchString += ' OR ';  
                          
            }  
            else
            {
                searchString += '\'';
            }   
                                
            searchString += Card + '*';
            condition = true;
            // TR - Added Campaign.Brand__c
            string CampaignMemberQuery = 'Select LeadId, Lead.Name, Lead.Phone, Lead.fax, Lead.Company, ContactId, Contact.Phone, Contact.Name, Short_Account_Number__c, Account_Number__c,CampaignId, Campaign.Name, Campaign.StartDate, Campaign_Type__c, Campaign.Brand__c from CampaignMember where Short_Account_Number__c like \'' + Card+ '%\' or Account_Number__c like \'' + Card+ '%\' order by Campaign.StartDate desc';
        
            CampaignMembers = Database.query(CampaignMemberQuery);
        }
         // always search for accounts, contacts, and leads that match any of the fields in the card search form                     
        if(searchString != 'FIND ')
        {
            searchString += '\' IN ALL FIELDS RETURNING Account (Id, Name, Account_Number__c,Phone, Fax), Contact(Id, Name, Account.Name, AccountId, Phone, Fax), Lead(Id, Name, Company, Account_Number__c, Phone, Fax)';
            dynamicSearchList = search.query(searchString);
        }
        
        // create lists for results
        postSearchProcessing();
        
        return null;
    }
        
    /* 
    * POST SEARCH PROCESSING
    *
    * create lists for results the wrapper list of leads/contacts returned by the search and include campaign members 
    *
    */ 
    void postSearchProcessing()
    {
        // if the search found accounts
        if(dynamicSearchList != null && (List<Account>)dynamicSearchList[0] != null)
        {
            accounts = (List<Account>)dynamicSearchList[0];
            
            list<Id> account_ids = new List<Id>();
            list<Id> contact_ids = new List<Id>();
           
            Map<Id,Account> mapAccountForId = new Map<Id,Account>();
             
            for(Account a : accounts){
                account_ids.add(a.Id);
                mapAccountForId.put(a.id,a);
            }
            System.debug('account_ids : '+account_ids);
            if(account_ids.size()>0){
                lstContact = [select id,name,phone,AccountId,account.name from contact where Accountid in :account_ids];
                map<string,list<contact>> MapContactsForAccountId = new map<string,list<contact>>();
                list<contact> lstTempContact = new list<contact>();
                for(Contact c: lstContact){
                    contact_ids.add(c.Id);
                    if(MapContactsForAccountId.get(c.Accountid)==null){
                        lstTempContact = new list<contact>();
                        lstTempContact.add(c);
                        MapContactsForAccountId.put(c.Accountid,lstTempContact);                         
                    }else{
                        lstTempContact = MapContactsForAccountId.get(c.Accountid);
                        lstTempContact.add(c);
                        MapContactsForAccountId.put(c.Accountid,lstTempContact);
                    }
                } // end loop
                map<id,CampaignMember[]> contactid_to_campaignMemberList_map = new map<id,CampaignMember[]>();
                // TR - Added Campaign.Brand__c
                for(list<CampaignMember> campaign_members : [select Id, LeadId, Lead.Name,CampaignId,Campaign.Name,Campaign.StartDate, ContactId, Contact.Name, Status, 
                HasResponded, Account_Number__c, Short_Account_Number__c, Activation_Code__c, Campaign_Type__c, Campaign.Brand__c from CampaignMember where contactid in :contact_ids order by Campaign.StartDate desc]){
                    for(CampaignMember cm : campaign_members){              
                        if(contactid_to_campaignMemberList_map.get(cm.contactid)==null){
                            CampaignMember[] cms = new list<CampaignMember>();
                            cms.add(cm);
                            contactid_to_campaignMemberList_map.put(cm.contactid,cms);
                        }else{
                            CampaignMember[] cms = contactid_to_campaignMemberList_map.get(cm.contactid);
                            cms.add(cm);
                            contactid_to_campaignMemberList_map.put(cm.contactid,cms);
                        }
                    
                    }
                } // end loop
                generic_wrapper w = new generic_wrapper();
                generic_wrapper w1 = new generic_wrapper();
                list<generic_wrapper> lstinnerWrapperlst = new list<generic_wrapper>(); 
                for(id AccId : mapAccountForId.keyset()){
                    w = new generic_wrapper();
                    lstinnerWrapperlst = new list<generic_wrapper>();
                    w.account = mapAccountForId.get(AccId);
                    if(MapContactsForAccountId.get(AccId) != null)
                    {
                        for(Contact objCont : MapContactsForAccountId.get(AccId)){                      
                            w1 = new generic_wrapper();
                            w1.contact = objCont;
                            w1.campaign_members = contactid_to_campaignMemberList_map.get(objCont.id);
                            lstinnerWrapperlst.add(w1); 
                            System.debug('lstinnerWrapperlst :' +lstinnerWrapperlst);
                            
// 7/13 walter - check for campaignMembers                          
                            if(w1.campaign_members != null && w1.campaign_members.size() != 0)
                                w.hasCampaignMembers=true;
                        }
                        
                        w.lstGenWrapper = lstinnerWrapperlst;
                    }
                    
                    // 7/13 walter - this is Contacts not Campaign Members
                    // 6/27 walter - does this account have campaign members
                    //if(w.lstGenWrapper != null && w.lstGenWrapper.size() != 0)
                        //w.hasCampaignMembers=true;                   
                    
                    if(account_list==null){account_list=new list<generic_wrapper>();}
                    account_list.add(w);
                }
                               
            }
                
            
        }  
        
        // if contacts were found by the search
        if(dynamicSearchList != null && (List<Contact>)dynamicSearchList[1] != null)
        {
            //lead ids
            id[] contact_ids = new list<id>();
            
            contacts = (List<Contact>)dynamicSearchList[1];
          
            for(Contact c : contacts){
                contact_ids.add(c.id);
            }
            
            map<id,CampaignMember[]> contactid_to_campaignMemberList_map = new map<id,CampaignMember[]>();
            // TR - Added Campaign.Brand__c
            for(list<CampaignMember> campaign_members : [select Id, LeadId, Lead.Name,CampaignId,Campaign.Name,Campaign.StartDate, ContactId, Contact.Name, Status, 
            HasResponded, Account_Number__c, Short_Account_Number__c, Activation_Code__c, Campaign_Type__c, Campaign.Brand__c from CampaignMember where contactid in :contact_ids order by Campaign.StartDate desc]){
                for(CampaignMember cm : campaign_members){              
                    if(contactid_to_campaignMemberList_map.get(cm.contactid)==null){
                        CampaignMember[] cms = new list<CampaignMember>();
                        cms.add(cm);
                        contactid_to_campaignMemberList_map.put(cm.contactid,cms);
                    }else{
                        CampaignMember[] cms = contactid_to_campaignMemberList_map.get(cm.contactid);
                        cms.add(cm);
                        contactid_to_campaignMemberList_map.put(cm.contactid,cms);
                    }
                
                }
            }
            
            // loop through leads and create a wrapper with the list of campaign members
            for(Contact c : contacts){
                // create a wrapper object
                generic_wrapper w = new generic_wrapper();
                w.contact=c;
                w.campaign_members=contactid_to_campaignMemberList_map.get(c.id);
                
// 7/19 - check for campaign members
                if(w.campaign_members != null && w.campaign_members.size()!=0)
                    w.hasCampaignMembers=true;             
                
                if(contact_list==null){contact_list=new list<generic_wrapper>();}
                contact_list.add(w);
            }
        }
        
        // if the search found leads
        if(dynamicSearchList != null && (List<Lead>)dynamicSearchList[2] != null)
        {
            //lead ids
            id[] lead_ids = new list<id>();
            
            leads = (List<Lead>)dynamicSearchList[2];
          
            for(Lead l : leads){
                lead_ids.add(l.id);
            }
            
            map<id,CampaignMember[]> leadid_to_campaignMemberList_map = new map<id,CampaignMember[]>();
            // TR - Added Campaign.Brand__c
            for(list<CampaignMember> campaign_members : [select Id, LeadId, Lead.Name,CampaignId,Campaign.StartDate,Campaign.Name, ContactId, Status, 
            HasResponded, Account_Number__c, Short_Account_Number__c, Activation_Code__c, Campaign_Type__c, Campaign.Brand__c from CampaignMember where leadid in :lead_ids order by Campaign.StartDate desc]){
                for(CampaignMember cm : campaign_members){              
                    if(leadid_to_campaignMemberList_map.get(cm.leadid)==null){
                        CampaignMember[] cms = new list<CampaignMember>();
                        cms.add(cm);
                        leadid_to_campaignMemberList_map.put(cm.leadid,cms);
                    }else{
                        CampaignMember[] cms = leadid_to_campaignMemberList_map.get(cm.leadid);
                        cms.add(cm);
                        leadid_to_campaignMemberList_map.put(cm.leadid,cms);
                    }
                
                }
            }
            
            // loop through leads and create a wrapper with the list of campaign members
            for(Lead l : leads){
                // create a wrapper object
                generic_wrapper w = new generic_wrapper();
                w.lead=l;
                w.campaign_members=leadid_to_campaignMemberList_map.get(l.id);
                
 // 7/19 - check for campaign members
                if(w.campaign_members != null && w.campaign_members.size()!=0)
                    w.hasCampaignMembers=true;                
                
                if(lead_list==null){lead_list=new list<generic_wrapper>();}
                lead_list.add(w);
            }
        }      
    }

    /*
    * INNER CLASS
    * we need a wrapper object to show campaign members with leads/contacts
    */
    public class generic_wrapper {
        public Lead lead {get; set;} {lead = new Lead();}
        public Contact contact {get; set;} {contact = new Contact();}
        
        public Account account {get; set;} {account = new Account();}
        public  List<Contact> contactList {get; set;} {contactList = new List<Contact>();}
        // the list of campaign members
        public list<CampaignMember> campaign_members {get; set;} {campaign_members = new list<CampaignMember>();}
        public list<generic_wrapper> lstGenWrapper {get;set;}
        
        // used to display account as a hyperlink when there are no campaign members
        public boolean hasCampaignMembers {get; set;} {hasCampaignMembers=false;}
    }

    /*
    * ACCOUNTS LIST
    */
    public List<Account> Accounts {get; set;}
    
    // this is the list of accounts shown in the page
    public list<generic_wrapper> account_list {get; set;}
    
    /*
    * CONTACTS LIST
    */   
    // this is the list of contacts shown in the page
    public list<generic_wrapper> contact_list {get; set;}
    // this is the list populated by the search
    public List<Contact> Contacts {get; set;}
    
    /*
    * LEADS LIST
    */    
    // this is the list of leads shown in the page
    public list<generic_wrapper> lead_list {get; set;}
    // this is the list populated by the search
    public List<Lead> Leads {get; set;}  
     
    /*
    * CAMPAIGN MEMBERS LIST
    */   
    public List<CampaignMember> CampaignMembers {get; set;}  
  
    /*
    * SELECT LEAD COMMAND
    */
    public PageReference openCampaignMember() {
        String cmId = System.currentPageReference().getParameters().get('CampaignMemberId');
        String leadId = System.currentPageReference().getParameters().get('leadId');
        // TR - Added Campaign.Brand__c
        CampaignMember cm = [Select Status,Short_Account_Number__c,Account_Number__c,Activation_Code__c,Campaign_Type__c,Campaign.Product_Target__c, Campaign.Brand__c From CampaignMember where id = :cmId];
        
        if(cm!=null) {
            cm.Status = 'Responded';
            upsert cm;
        }
        // TR - Added Brand__c
        Lead theLead = [Select Id,Last_Campaign_Response_Date__c,Activation_Date__c,Rep_Ownership_Date__c,Initial_Lead_Source__c,Response_Channel__c,LeadSource,Account_Number__c,Status,Status_MCA__c,OwnerId,IsConverted, Brand__c from Lead where Id = :leadId];
        Boolean ownedByQueue = String.valueOf(theLead.OwnerId).startsWith('OOG');
        User leadOwner;
        
        if (!ownedByQueue)
        	leadOwner = [SELECT Sales_User__c FROM User WHERE Id = :theLead.OwnerId];
            
        if (theLead != null && theLead.Status != 'Qualified/Converted'){
            Boolean hasActivationDate = false;
            if(theLead.Activation_Date__c == null)
                theLead.Activation_Date__c = System.now();
            else
                hasActivationDate = true;
            
            theLead.Short_Account_Number__c = cm.Short_Account_Number__c;
            theLead.Account_Number__c = cm.Account_Number__c;
            theLead.Activation_Code__c = cm.Activation_Code__c;
          
            //string lid = string.valueOf(theLead.ownerId);
            //system.debug('the lead 6owner id... ' +lid);
            
            theLead.LeadSource = cm.Campaign_Type__c;
            theLead.Response_Channel__c = 'Inbound Call';
            theLead.Last_Card_Search_Date__c = Date.today();
            
            // using startsWith because SF can tend to append three extra characters to Ids
            if((ownedByQueue || leadOwner.Sales_User__c == false) && (theLead.status != 'House' || !hasActivationDate)){
                system.debug('lead owner is House account or DB Amp, reassigning to current user...');
                theLead.OwnerId = UserInfo.getUserId();
                User usr = [SELECT Name, Id FROM User WHERE Id = :theLead.ownerId];
                theLead.Rep_Ownership_Date__c = Date.today();
                theLead.Card_Search_Used__c = true;
                theLead.Last_Campaign_Response_Date__c = Date.today();
                if (!hasActivationDate) {
                    if (theLead.Initial_Response_Channel__c == null)
                        theLead.Initial_Response_Channel__c = 'Inbound Call';
					if (theLead.Initial_Response_Rep__c == null)
                        theLead.Initial_Response_Rep__c = usr.Name;
					if (theLead.Initial_Response_User__c == null)
                        theLead.Initial_Response_User__c = usr.id;
                    if (theLead.Initial_Lead_Source__c == null)
                        theLead.Initial_Lead_Source__c = theLead.LeadSource;
	                if (theLead.Initial_Product_Response__c == null)
	                	theLead.Initial_Product_Response__c = cm.Campaign.Product_Target__c;
                }
            }
            
            //  4/5/12 walter - Lead Status
            // IF the Lead Status is equal to "House", or "Open", or "Pursuing", or "Contacted" 
            // AND IF the Lead Status is not equal "Prospect", and "Activator", and "Remove from list"
            // change the value to "Prospect"
            // TR - if the value is changed to prospect, insert brand value from Campaign
           string lst = theLead.Status;
           system.debug('the lead status is... '+lst);
            if((lst == 'House' || lst == 'Open' || lst == 'Pursuing' || lst == 'Contacted') && (lst != 'Prospect' && lst != 'Activator' && lst != 'Remove from List')){ 
                theLead.Status = 'Prospect';
                theLead.Brand__c = cm.Campaign.Brand__c;
                system.debug('changing the lead status to... '+theLead.Status);
            }
    
            update theLead;
        }
        
        return new PageReference('/' + leadId);     
    }    
    
        
    /*
    * SELECT Campaign Members from Contacts COMMAND
    */
    public PageReference openCampaignMemberContacts()
    {
        String cmId = System.currentPageReference().getParameters().get('CampaignMemberId');
        String contactId = System.currentPageReference().getParameters().get('contactId');
        Contact cont = [Select Account.Owner.Sales_User__c, AccountId, LeadSource From Contact WHERE Id = :contactId];
        CampaignMember cm = [Select Status,Short_Account_Number__c,Account_Number__c,Activation_Code__c,Campaign_Type__c,Campaign.Product_Target__c From CampaignMember where id = :cmId];
        User currentUser = [SELECT Sales_User__c FROM User WHERE Id = :UserInfo.getUserId()];

        if(cm!=null)
        {
            cm.Status = 'Responded';
            upsert cm;
            
            cont.LeadSource = cm.Campaign_Type__c;
            upsert cont;

            Account acct = new Account(id = cont.accountId);
            acct.Response_Channel__c = 'Inbound Call';
            acct.Last_Card_Search_Date__c = Date.today();
            
            if (cont.Account.Owner.Sales_User__c == false) {
                acct.OwnerId = UserInfo.getUserId();
                acct.Rep_Ownership_Date__c = Date.today();
                acct.Card_Search_Used__c = true;
                acct.Last_Campaign_Response_Date__c = Date.today();

                if (acct.Initial_Response_Channel__c == null)
                    acct.Initial_Response_Channel__c = acct.Response_Channel__c;
                if (acct.Initial_Lead_Source__c == null)
                    acct.Initial_Lead_Source__c = cont.LeadSource;
                if (acct.Initial_Product_Response__c == null)
                	acct.Initial_Product_Response__c = cm.Campaign.Product_Target__c;
            }

            upsert acct;
        }
        
        
       
       return new PageReference('/' +cont.accountId); 
        
    }
//CONSOLE SEARCH ACTIVATED
//TEST TEST TEST
//

    public PageReference Search1() {
        name = fake03String;
        card = fake02String;
        // clear the lists before each search
        leads = null;
        lead_list = null;
        contacts = null;
        contact_list = null;
        campaignmembers = null;
        accounts = null;
        dynamicSearchList = null;
        account_list=null;
        
        
        String allPhone = fake04String;
        String allFax = '';
        String allName = fake03String;
        String companyName = '';
        String allCard = fake02String;
        String aStreet = '';
        String cStreet = '';
        String lStreet = '';
        String leadIds = '';
        String ContactIds = '';
        boolean condition = false;
        //should this be AND or OR 
        
        String searchString = 'FIND ';
        

        if(fake03String != null && fake03String != '')
        {            
            condition = true;            
            searchString += '\'' + fake03String + '*';
      
        }
        
        if(Phone != null && Phone != '' && Phone.length() >= 10)
        {
            Phone = Phone.replaceAll('-', '');          
            Phone = Phone.replaceAll(' ', '');          
            Phone = Phone.replaceAll('\\(', '');            
            Phone = Phone.replaceAll('\\)', '');       
            string thePhone = Phone;            
            Phone = '(' + thePhone.substring(0, 3) + ') ';          
            Phone += thePhone.substring(3, 6) + '-';            
            Phone += thePhone.substring(6, 10);         
            
            if(condition )
            {                 
                searchString += ' OR ';        
            } 
            else
            {
                searchString += '\'';
            } 
                                
            searchString += Phone + '*';
            condition = true;
      
        } 
    
      // the cards search is based on campaign members
        if(Card != null && Card != '')
        {
            if(condition )
            {                 
                searchString += ' OR ';  
                          
            }  
            else
            {
                searchString += '\'';
            }   
                                
            searchString += Card + '*';
            condition = true;
            
            string CampaignMemberQuery = 'Select LeadId, Lead.Name, Lead.Phone, Lead.fax, Lead.Company, ContactId, Contact.Phone, Contact.Name, Short_Account_Number__c, Account_Number__c,CampaignId, Campaign.Name, Campaign.StartDate, Campaign_Type__c from CampaignMember where Short_Account_Number__c like \'' + Card+ '%\' or Account_Number__c like \'' + Card+ '%\' order by Campaign.StartDate desc';
        
            CampaignMembers = Database.query(CampaignMemberQuery);
        }
         // always search for accounts, contacts, and leads that match any of the fields in the card search form                     
        if(searchString != 'FIND ')
        {
            searchString += '\' IN ALL FIELDS RETURNING Account (Id, Name, Account_Number__c,Phone, Fax), Contact(Id, Name, Account.Name, AccountId, Phone, Fax), Lead(Id, Name, Company, Account_Number__c, Phone, Fax)';
            dynamicSearchList = search.query(searchString);
        }
        
        // create lists for results
        postSearchProcessing();
        
        return new pagereference('/apex/cardSearchV2');
    }    
    
    
}