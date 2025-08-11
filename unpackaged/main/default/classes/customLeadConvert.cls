public with sharing class customLeadConvert {
    
    public Lead objLead{get;set;}
    public Boolean createOppty {get;set;}
    public String strId {get;set;}
    public List<RecordType> lstOppRecType{get;set;}
    public Opportunity objOpp{get;set;} 
    public String objRecType{get;set;} 
    private map<String,String> mapRecordType;
    public ID strConID { get; set; }
    public ID strAccID { get; set; }
    public ID strOppId { get; set; }
    
    public customLeadConvert(ApexPages.StandardController controller)
    { 
        strId = controller.getId();
        if(strId != null && strId!='')
        {
            objLead = [Select l.SSN_Encrypted__c, l.Yrs_in_Business__c, l.Year_Started__c, l.Website, l.UCC_Indicator__c, l.Trans_Value_per_Month__c,
            l.Title__c, l.Title, l.Time_Zone__c, l.SystemModstamp, l.Street, l.Status_MCA__c, 
            l.Status_Lease__c, l.Status_EPP__c, l.Status, l.State, l.Short_Account_Number__c,   l.Salutation, l.Sales_Volume__c, l.SLX_Lead_ID__c, l.SLX_AccountID__c, l.SIC_Name__c,SICName__c, 
            l.SICCODE__c,  l.Rersponse_Date__c, l.RecordTypeId, l.Rating,  
             l.Qty_Trans_per_Month__c, l.PostalCode, l.Phone, l.Paydex_Score__c, 
            l.Owns_Rents1__c, l.OwnerId, l.NumberOfEmployees, l.Name, l.MasterRecordId, l.MSA_Name__c, l.MSA_Code__c, l.City__c,
            l.Home_Address__c, l.State__c, l.Zip_Code__c,
            l.List_Reference__c, l.Ownership__c, l.LeadSource,  
            l.LastName, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.Key_Code__c, l.IsUnreadByOwner, l.IsDeleted, 
            l.IsConverted, l.Industry, l.Import_Date__c, l.Id, l.FirstName, l.FPC_Rep_ML__c, l.FPC_Rep_MCA__c, l.FPC_Rep_Lease__c, 
            l.FPC_Rep_EPP__c, l.FICO__c, l.Experian_BIN__c, l.EmailBouncedReason, l.EmailBouncedDate, l.Email, l.Dias_Code__c, l.Description, 
            l.Date_Established__c, l.DUNS_Number__c, l.DQ_Reasons__c, l.DQ_Details__c, l.DPBC__c, l.DPBC_Date__c, l.CreatedDate, l.CreatedById, 
            l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.Company, l.City, l.CC_Processor__c, 
            l.AnnualRevenue, l.Additional_Name_2__c, l.Additional_Name_1__c, l.Activation_Date__c, l.Activation_Code__c, l.Account_Number__c,
            l.How_did_you_hear_about_us__c, l.Agency_ID__c, l.Agency_Rep_ID__c, l.Best_Time_to_Reach__c, l.Est_Credit_Score__c, l.Call_Count__c, l.Invalid_FAX__c,
            l.Invalid_Email__c, l.Marketing_Pilot_Results__c, l.Response_Channel__c, l.Use_of_Funds__c,  l.MobilePhone, l.Home_Phone__c, l.Birth_Date__c
            // 4/19/12 Walter - sub query for tasks and events so we can move them to the account from the converted lead
            , (Select Id, RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, RPC__c, Call_Disposition__c, Reason__c, Response_Channel__c, Date_Activity_Logged__c From Tasks), (Select Id, WhoId, WhatId, Subject, Location, IsAllDayEvent, ActivityDateTime, ActivityDate, DurationInMinutes, StartDateTime, EndDateTime, Description, AccountId, OwnerId, IsPrivate, ShowAs, IsDeleted, IsChild, IsGroupEvent, GroupEventType, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, ReminderDateTime, IsReminderSet, RPC__c, Call_Disposition__c, Reason__c, Response_Channel__c, Date_Activity_Logged__c From Events)
            From Lead l WHERE l.Id =:strId];
            lstOppRecType = [Select Name, Id From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName IN ('Lease_Oppty_Record_Type','MCA_Oppty') ORDER BY Name DESC];
        }
        
        // 4/18/12 Walter - collect the activityHistory
        moveLeadHistory(objLead);
    }
    
    transient list<Attachment> leadAttachments = new list<Attachment>();
    list<Note> leadNotes = new list<Note>();
    list<Task> leadTasks = new list<Task>();
    list<Event> leadEvents = new list<Event>();
    
    private void moveLeadHistory(Lead le){
        if(le != null && le.id != null){
            // store a copy of tasks for the lead
            if(le.Tasks!=null && le.Tasks.size()!=0){
                for(Task t :le.Tasks){
                    leadTasks.add(t);
                }
            }
            // store a copy of events for the lead
            if(le.Events!=null && le.Events.size()!=0){
                for(Event t :le.Events){
                    leadEvents.add(t);
                }
            }
        }
    }
    
    private void saveLeadActivityHistory(id Id){
        system.debug('got into save lead activity: ' + leadTasks);
        if(leadTasks.size()!=0){
            // if we pass in the account id.
            //if(accountId!=null){
                // loop through the converted lead history from the  lead
                for(Task t :leadTasks){
                    // relate to the account from the converted lead
                    t.whatId = Id;
                    // remove from the lead. Cannot specify a non null value for whatId and a whatId
                    t.whoId=null;
                }
            //}
            system.debug(leadTasks);
            update leadTasks;
            leadTasks.clear();
        }
        
        if(leadEvents.size()!=0){
            for(Event e :leadEvents){
                e.whatId=Id;
                e.whoId=null;
            }
            update leadEvents;
            leadEvents.clear();
        }
    }
       
    /**
    * Convert the Lead
    */
    public PageReference doConvert()
    {
//Start Shree ===========================================================   
        transient list<Attachment> leadAttachments = new list<Attachment>();
        transient list<Note> leadNotes = new list<Note>();
        objLead.Ready_To_Convert__c= true;
        update objLead;

        Lead le = objLead;
        if(le!= null && le.id != null){
            // query for all notes and attachments for the lead
            for(Attachment atmt : [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a Where a.ParentId = :le.id]){
                leadAttachments.add(atmt);
            }
            // query for all notes for the lead
            for(Note n : [Select n.Title, n.SystemModstamp, n.ParentId, n.OwnerId, n.LastModifiedDate, n.LastModifiedById, n.IsPrivate, n.IsDeleted, n.Id, n.CreatedDate, n.CreatedById, n.Body From Note n Where n.ParentId = :le.id]){
                leadNotes.add(n);
            }
        }
//End Shree ==============================================================      
        if(objRecType != null)
        {
            User tmpUser = [SELECT Id, Username FROM USER WHERE Username like 'haccount@fivepointcapital.com%' limit 1];
            //house account
            if(tmpUser != null)
            {
                try
                {
                    Account objAcc = new Account();
                    objAcc.Name = objLead.Company;
                    objAcc.Type = 'Customer';
                    //objAcc.Account_Number__c = objLead.Account_Number__c;
                    objAcc.Account_Number1__c  = objLead.Account_Number__c;//add by Link
                    //objAcc.OwnerId = tmpUser.Id;//Account owner Id should be House User (right now called DBAmp user)

                  system.debug('The lead owner is... ' +objLead.name);
                  
                   // 4/4/12 walter - changing to make the owner of the account match the owner of the lead
                    objAcc.OwnerId = objLead.OwnerId;
                    
                    system.debug('Setting account owners... ' +objAcc.OwnerId);

                    objAcc.How_did_you_hear_about_us__c = objLead.How_did_you_hear_about_us__c;
                    objAcc.Agency_ID__c = objLead.Agency_ID__c;
                    objAcc.Agency_Rep_ID__c = objLead.Agency_Rep_ID__c; 
                    objAcc.Mktg_Pilot_Results__c = objLead.Marketing_Pilot_Results__c;
                    objAcc.Response_Channel__c = objLead.Response_Channel__c;
                    objAcc.Est_Credit_Scot__c = objLead.Est_Credit_Score__c;
                    objAcc.Convert_Call_Count__c = objLead.Call_Count__c;
                    objAcc.Use_of_Funds__c = objLead.Use_of_Funds__c;   
                    objAcc.Description = objLead.Description;     
                    //add by Link
                    objAcc.Status__c = 'Active';                 
                    if(objLead.Activation_Date__c != null){
                        DateTime ad = objLead.Activation_Date__c;
                        objAcc.Activation_Date__c = Date.newInstance(ad.year(),ad.month(),ad.day());  
                    }
                    objAcc.SIC_Name__c = objLead.SICName__c;
                    objAcc.Sic = objLead.SICCODE__c;
                    //end
                                      
                    insert objAcc;

                    system.debug('The account was created, here is the ownerId... ' +objAcc.OwnerId);
                                           
                    Database.Leadconvert convert = new Database.Leadconvert();
                    convert.setLeadId(objLead.Id);
                    convert.setAccountId(objAcc.Id);
                    convert.setConvertedStatus('Qualified/Converted');
                    convert.setOpportunityName(objLead.Name);
                   
                   // 4/4/12 changing to make the owner of the account match the owner of the lead
                   // convert.setOwnerId(Userinfo.getUserId());
                   convert.setOwnerId(objLead.OwnerId);
                   
                   system.debug('The converted lead owners set to... ' +convert.getOwnerId());
                    
                    String strRec = String.ValueOf(objRecType);
                    String strRecName = mapRecordType.get(strRec);
                    String strMobile;
                    if(objLead.MobilePhone!=null)
                        strMobile = objLead.MobilePhone;

                    Database.LeadConvertResult convertResult = Database.convertLead(convert); 
                    this.strOppId = convertResult.getOpportunityId();
                    this.strAccId = convertResult.getAccountId();
                    this.strConId = convertResult.getContactId();
                    
                    // 2014-06-09 Jody - added custom copy over code
                    update new Contact(Id = strConId, SSN_Encrypted__c = objLead.SSN_Encrypted__c, HomePhone = objLead.Home_Phone__c, Birthdate = objLead.Birth_Date__c, MailingStreet = objLead.Home_Address__c, MailingCity = objLead.City__c, IsPrimary__c = true, MailingState = objLead.State__c, MailingPostalCode = objLead.Zip_Code__c);
                    
                     // 4/19/12 Walter - save the Tasks and Events from the Lead to the account from the converted lead
                    saveLeadActivityHistory(strAccId);

//Start Shree==============================================================
        if(strOppId != null){
            if(leadAttachments.size()!=0){
                transient list<Attachment> aList = new list<Attachment>();            
                // loop through the  attachments from the lead
                for(Attachment att :leadAttachments){
                     // create a copy of the attachment
                     transient Attachment a = new Attachment();
                     a.Name = att.Name;
                     a.Body = att.Body;
                     a.Description = att.Description;
                     a.IsPrivate = att.IsPrivate;
                     // relate to the opportunity from the converted lead
                     a.parentId = strOppId;
                     // add to list we insert
                     aList.add(a);
                }
                
                insert aList;
                // clear the list, no reason to maintain the data at this point
                aList.clear();
                // delete the old records, no reason to take up space on the server
                delete leadAttachments;
            }
            if(leadNotes.size()!=0){
                list<Note> nList = new list<Note>();
                // loop through the notes from the lead
                for(Note no :leadNotes){
                    // create a copy of the note
                    Note n = new Note();
                    n.Title = no.Title;
                    n.Body = no.Body;
                    n.IsPrivate = no.IsPrivate;
                    // relate to the opportunity from the converted lead
                    n.parentId = strOppId;
                    // add to the list
                    nList.add(n);
                }
                
                insert nList;
                nList.clear();
                delete leadNotes;
            }
        }
//End Shree==============================================================
                    //add by Link           
                    //modify by Ajay
                    if(objLead != null && objAcc != null){
                        if(objLead.City != null && objLead.Street != null){
                            FPC_Address__c add = new FPC_Address__c();
                            add.City__c = objLead.City;
                            add.State__c = objLead.State;
                            add.County__c = objLead.Country;
                            add.Zip_Code__c = objLead.PostalCode;
                            add.Address_1__c = objLead.Street;
                            add.Location_Type__c = 'Physical Address';
                            add.Account__c = objAcc.Id;
                            add.Isprimary__c = true;
                            insert add;
                            
                            if (objLead.City__c != null) {
                                FPC_Address__c add2 = new FPC_Address__c();
                                add2.City__c = objLead.City__c;
                                add2.State__c = objLead.State__c;
                                add2.Zip_Code__c = objLead.Zip_Code__c;
                                add2.Address_1__c = objLead.Home_Address__c;
								add2.Address_Number__c = objLead.Street_Number__c;
                           		add2.Street_Type__c = objLead.Street_Type__c;
                            	add2.Street_Name__c = objLead.Street_Name__c;                                
                                add2.Account__c = objAcc.Id;
                                add2.Location_Type__c = 'Home Address';
                                add2.Contact__c = strConId;
                                //add2.Isprimary__c = true;
                                insert add2;
                            }
                        }
                    }
                    //end
                                        
                    AccountTeamMember[] atmInsert = new AccountTeamMember[0];   
                    AccountShare[] newShare = new AccountShare[]{};  //list of new shares to add                
                    AccountTeamMember objATM;
                    objATM = new AccountTeamMember();
                    objATM.UserId = Userinfo.getUserId();
                    objATM.AccountId = strAccId;
                    objATM.TeamMemberRole = 'FPC Opener';                                     
                    atmInsert.add(objATM);
                    
                    if(objLead.FPC_Rep_EPP__c!=null || objLead.FPC_Rep_Lease__c != null || objLead.FPC_Rep_MCA__c != null || objLead.FPC_Rep_ML__c != null)
                    {           
                        if(objLead.FPC_Rep_EPP__c!=null)
                        {
                            objATM = new AccountTeamMember();
                            objATM.UserId = objLead.FPC_Rep_EPP__c;
                            objATM.AccountId = strAccId;
                            objATM.TeamMemberRole = 'EPP Sales Rep';                            
                            atmInsert.add(objATM);
                            if(Userinfo.getUserId() != objLead.FPC_Rep_EPP__c)
                            {
                                newShare.add(new AccountShare(UserOrGroupId=objLead.FPC_Rep_EPP__c, AccountId=strAccId, AccountAccessLevel='Edit',OpportunityAccessLevel='Read'));
                            }                                                                       
                        }
                        if(objLead.FPC_Rep_Lease__c != null)
                        {
                            objATM = new AccountTeamMember();
                            objATM.UserId = objLead.FPC_Rep_Lease__c;
                            objATM.AccountId = strAccId;
                            objATM.TeamMemberRole = 'Lease Sales Rep';
                            atmInsert.add(objATM);   
                            if(Userinfo.getUserId() != objLead.FPC_Rep_Lease__c)
                            {
                                newShare.add(new AccountShare(UserOrGroupId=objLead.FPC_Rep_Lease__c, AccountId=strAccId, AccountAccessLevel='Edit',OpportunityAccessLevel='Read'));
                            }                                                                       
                        }
                        if(objLead.FPC_Rep_MCA__c != null)
                        {
                            objATM = new AccountTeamMember();
                            objATM.UserId = objLead.FPC_Rep_MCA__c;
                            objATM.AccountId = strAccId;
                            objATM.TeamMemberRole = 'MCA Sales Rep';
                            atmInsert.add(objATM);
                            if(Userinfo.getUserId() != objLead.FPC_Rep_MCA__c)
                            {   
                                newShare.add(new AccountShare(UserOrGroupId=objLead.FPC_Rep_MCA__c, AccountId=strAccId, AccountAccessLevel='Edit',OpportunityAccessLevel='Read'));
                            }                               
                        }
                        if(objLead.FPC_Rep_ML__c != null)
                        {
                            objATM = new AccountTeamMember();
                            objATM.UserId = objLead.FPC_Rep_ML__c;
                            objATM.AccountId = strAccId;
                            objATM.TeamMemberRole = 'ML Sales Rep';
                            atmInsert.add(objATM);  
                            if(Userinfo.getUserId() != objLead.FPC_Rep_ML__c)
                            {   
                                newShare.add(new AccountShare(UserOrGroupId=objLead.FPC_Rep_ML__c, AccountId=strAccId, AccountAccessLevel='Edit',OpportunityAccessLevel='Read'));
                            }                                           
                        }                                               
                    
                     /* 4/4/12 walter - the contact is no longer needed as the credit score functionality takes care of it now.
                           just delete the contact that was created by the lead convert. */
                        if(strConId != null)
                        {
                            system.debug('A CONTACT WAS CREATED. String strConId = convertResult.getContactId() : strConId = ' +strConId +'.');
                            system.debug('Query for contact... ');
                            Contact c = [select Id, Best_Time_to_Reach__c, Invalid_FAX__c, Invalid_Email__c from Contact where Id = :strConId];
                            c.Best_Time_to_Reach__c = objLead.Best_Time_to_Reach__c;
                            c.Invalid_Fax__c = objLead.Invalid_FAX__c;
                            c.Invalid_email__c = objLead.Invalid_Email__c;
                            c.Isprimary__c = true;
                            c.MobilePhone = strMobile;
                           update c;
                        }
                    }
                    
                    insert newShare;
                    insert atmInsert;
                    
                    try{
                        List<Opportunity> oOpp = [Select Id from Opportunity Where AccountId = : strAccId and RecordTypeId =: strRec];
                        String sCount = '0';
                        if(oOpp.size() == 1)
                           sCount = String.ValueOf(1);
                        else
                           sCount = String.ValueOf(oOpp.size()+1);
                        String strOppName = objLead.Company + ' ' + strRecName + ' Deal#' + ' '+sCount ;
                        Opportunity objOpp = [Select RecordTypeId, Name from Opportunity WHERE Id = :strOppId];
                        objOpp.RecordTypeId = strRec;
                        objOpp.Name = strOppName;

                         // 4/4/12 changing to make the owner of the account match the owner of the lead
                        objOpp.OwnerId = objLead.OwnerId;
                        
                        update objOpp;
                        
                         system.debug('Opportunity was updated, the owner id... ' +objOpp.OwnerId );
                        
                        PageReference p = new PageReference('/'+strOppId);
                        p.setRedirect(true);
                        return p;
                    }
                    catch(exception ex)
                    {
                        ApexPages.addMessages(ex);
                    } 
                }
                catch(Exception e)
                {
                    ApexPages.addMessages(e);
                }
            }
        }
        return null;
    }

    public List<SelectOption> getOpportunityRecordType()
    {
        List<SelectOption> options = null;
        Integer i = 0;
        for( RecordType objOppRecType : lstOppRecType)
        {
            if(i==0)
            {
                options = new List<SelectOption>();
                mapRecordType = new map<String,String>();
            }
            options.add(new SelectOption(objOppRecType.Id,objOppRecType.Name));
            if(!mapRecordType.ContainsKey(objOppRecType.Id))
            {
                mapRecordType.put(objOppRecType.Id,objOppRecType.Name);
            }
            i++;
        }
        return options;   
    }
    
    /**
    * TEST NOTES & ATTACHMENTS
    */
    static testMethod void testNotsAndAttachments(){
        // create a lead to convert
        Lead l = new Lead();
        l.firstName = 'test';
        l.LastName = 'user 1';
        l.company = 'test company 1';
        l.City = 'test';
        l.Street = 'test';
        l.City__c = 'test';
        l.Home_Address__c = 'test';
        insert l;
        
        // need to add notes & attachments to the lead
        Attachment a = new Attachment();
        a.ParentId=l.id;
        a.Name = 'test';
        a.Body=blob.valueOf('0010101010010101010');
        insert a;
        
        Note n = new Note();
        n.ParentId=l.id;
        n.Title='test';
        n.Body='test';
        insert n;

        // create an object instance of the customLeadConvert class
        customLeadConvert clc = new customLeadConvert(new apexPages.Standardcontroller(l));
        
        // pass the lead to the custom convert process
        string url = '/apex/LeadConvert?retURL='+ l.id +'&id='+l.id;
        pageReference p = new pageReference(url);
        test.setCurrentPage(p);
        
        // select the record type for the opporutnity
        clc.objRecType = clc.getOpportunityRecordType()[0].getValue();
        system.debug('selected record type... ' +clc.objRecType);
        
        clc.doConvert();
        
    }

    //    ------------------------------------------------------------------ //

    public Account createAccount(){
        system.debug('objLead id:: ' + objLead.Id + ' owner id:: ' + objLead.OwnerId);
        Account objAcc = new Account();
        objAcc.Name = objLead.Company;
        objAcc.Type = 'Customer';
        objAcc.Account_Number1__c  = objLead.Account_Number__c;//add by Link
        system.debug('The lead owner is... ' +objLead.name);
        objAcc.OwnerId = objLead.OwnerId;

        system.debug('Setting account owners... ' +objAcc.OwnerId);

        objAcc.How_did_you_hear_about_us__c = objLead.How_did_you_hear_about_us__c;
        objAcc.Agency_ID__c = objLead.Agency_ID__c;
        objAcc.Agency_Rep_ID__c = objLead.Agency_Rep_ID__c;
        objAcc.Mktg_Pilot_Results__c = objLead.Marketing_Pilot_Results__c;
        objAcc.Response_Channel__c = objLead.Response_Channel__c;
        objAcc.Est_Credit_Scot__c = objLead.Est_Credit_Score__c;
        objAcc.Convert_Call_Count__c = objLead.Call_Count__c;
        objAcc.Use_of_Funds__c = objLead.Use_of_Funds__c;
        objAcc.Description = objLead.Description;
        objAcc.Status__c = 'Active';
        if(objLead.Activation_Date__c != null){
            DateTime ad = objLead.Activation_Date__c;
            objAcc.Activation_Date__c = Date.newInstance(ad.year(),ad.month(),ad.day());
        }
        objAcc.SIC_Name__c = objLead.SICName__c;
        objAcc.Sic = objLead.SICCODE__c;

        insert objAcc;
        return objAcc;
    }

    public Id convertTheLead(Account objAcc){
        Database.Leadconvert convert = new Database.Leadconvert();
        convert.setLeadId(objLead.Id);
        convert.setAccountId(objAcc.Id);
        convert.setConvertedStatus('Qualified/Converted');
        convert.setOwnerId(objLead.OwnerId);

        //this allows us to decide if a user wants to create an opportunity or not
        if(!createOppty){ //meaning it is not checked, I do not want to create an Opportunity
            convert.setDoNotCreateOpportunity(true);
        } else{
            convert.setOpportunityName(objLead.Name);
        }

        Database.LeadConvertResult convertResult = Database.convertLead(convert);
        if(createOppty) {
            this.strOppId = convertResult.getOpportunityId();
        }
        this.strAccId = convertResult.getAccountId();
        this.strConId = convertResult.getContactId();

        // 2014-06-09 Jody - added custom copy over code
        update new Contact(Id = strConId, SSN_Encrypted__c = objLead.SSN_Encrypted__c, HomePhone = objLead.Home_Phone__c, Birthdate = objLead.Birth_Date__c, MailingStreet = objLead.Home_Address__c, MailingCity = objLead.City__c, IsPrimary__c = true, MailingState = objLead.State__c, MailingPostalCode = objLead.Zip_Code__c);
        return this.strConID;
    }

    public void createOpptyIfRequested(Id strOppId, list<Attachment> leadAttachments){
        system.debug('got into create oppty if requested:: ' + strOppId + ', leadAttachments:: ' + leadAttachments);
        if(strOppId != null){
            system.debug(strOppId);
            if(leadAttachments.size()!=0){
                system.debug('leadattachments are not equal to 0');
                transient list<Attachment> aList = new list<Attachment>();
                // loop through the  attachments from the lead
                for(Attachment att :leadAttachments){
                    // create a copy of the attachment
                    transient Attachment a = new Attachment();
                    a.Name = att.Name;
                    a.Body = att.Body;
                    a.Description = att.Description;
                    a.IsPrivate = att.IsPrivate;
                    // relate to the opportunity from the converted lead
                    a.parentId = strOppId;
                    // add to list we insert
                    aList.add(a);
                }

                insert aList;
                // clear the list, no reason to maintain the data at this point
                aList.clear();
                // delete the old records, no reason to take up space on the server
                delete leadAttachments;
            }
            if(leadNotes.size()!=0){
                list<Note> nList = new list<Note>();
                // loop through the notes from the lead
                for(Note no :leadNotes){
                    // create a copy of the note
                    Note n = new Note();
                    n.Title = no.Title;
                    n.Body = no.Body;
                    n.IsPrivate = no.IsPrivate;
                    // relate to the opportunity from the converted lead
                    n.parentId = strOppId;
                    // add to the list
                    nList.add(n);
                }

                insert nList;
                nList.clear();
                delete leadNotes;
            }
        }
    }

    public void creatingAddresses(Account objAcc){
        system.debug('got into creating address:: ' + objLead + ', ' + objAcc);
        if(objLead != null && objAcc != null){
            system.debug(objLead.City);
            if(objLead.City != null && objLead.Street != null){
                FPC_Address__c add = new FPC_Address__c();
                add.City__c = objLead.City;
                add.State__c = objLead.State;
                add.County__c = objLead.Country;
                add.Zip_Code__c = objLead.PostalCode;
                add.Address_1__c = objLead.Street;
                add.Location_Type__c = 'Physical Address';
                add.Account__c = objAcc.Id;
                add.Isprimary__c = true;
                insert add;

//                system.debug(objLead.City__c);
//                if (objLead.City__c != null) {
//                    FPC_Address__c add2 = new FPC_Address__c();
//                    add2.City__c = objLead.City__c;
//                    add2.State__c = objLead.State__c;
//                    add2.Zip_Code__c = objLead.Zip_Code__c;
//                    add2.Address_1__c = objLead.Home_Address__c;
//                    add2.Address_Number__c = objLead.Street_Number__c;
//                    add2.Street_Type__c = objLead.Street_Type__c;
//                    add2.Street_Name__c = objLead.Street_Name__c;
//                    add2.Account__c = objAcc.Id;
//                    add2.Location_Type__c = 'Home Address';
//                    add2.Contact__c = strConId;
//                    insert add2;
//                }
            }
        }
    }

    public void setUpAccountTeamMembers() {
        system.debug('strAccId in accountteammembers:: ' + strAccId);
        AccountTeamMember[] atmInsert = new AccountTeamMember[0];
        AccountShare[] newShare = new AccountShare[]{};  //list of new shares to add
        AccountTeamMember objATM;
        objATM = new AccountTeamMember();
        objATM.UserId = Userinfo.getUserId();
        objATM.AccountId = strAccId;
        objATM.TeamMemberRole = 'FPC Opener';
        atmInsert.add(objATM);

        if (objLead.FPC_Rep_EPP__c != null || objLead.FPC_Rep_Lease__c != null || objLead.FPC_Rep_MCA__c != null || objLead.FPC_Rep_ML__c != null) {
            if (objLead.FPC_Rep_EPP__c != null) {
                objATM = new AccountTeamMember();
                objATM.UserId = objLead.FPC_Rep_EPP__c;
                objATM.AccountId = strAccId;
                objATM.TeamMemberRole = 'EPP Sales Rep';
                atmInsert.add(objATM);
                if (Userinfo.getUserId() != objLead.FPC_Rep_EPP__c) {
                    newShare.add(new AccountShare(UserOrGroupId = objLead.FPC_Rep_EPP__c, AccountId = strAccId, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read'));
                }
            }
            if (objLead.FPC_Rep_Lease__c != null) {
                objATM = new AccountTeamMember();
                objATM.UserId = objLead.FPC_Rep_Lease__c;
                objATM.AccountId = strAccId;
                objATM.TeamMemberRole = 'Lease Sales Rep';
                atmInsert.add(objATM);
                if (Userinfo.getUserId() != objLead.FPC_Rep_Lease__c) {
                    newShare.add(new AccountShare(UserOrGroupId = objLead.FPC_Rep_Lease__c, AccountId = strAccId, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read'));
                }
            }
            if (objLead.FPC_Rep_MCA__c != null) {
                objATM = new AccountTeamMember();
                objATM.UserId = objLead.FPC_Rep_MCA__c;
                objATM.AccountId = strAccId;
                objATM.TeamMemberRole = 'MCA Sales Rep';
                atmInsert.add(objATM);
                if (Userinfo.getUserId() != objLead.FPC_Rep_MCA__c) {
                    newShare.add(new AccountShare(UserOrGroupId = objLead.FPC_Rep_MCA__c, AccountId = strAccId, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read'));
                }
            }
            if (objLead.FPC_Rep_ML__c != null) {
                objATM = new AccountTeamMember();
                objATM.UserId = objLead.FPC_Rep_ML__c;
                objATM.AccountId = strAccId;
                objATM.TeamMemberRole = 'ML Sales Rep';
                atmInsert.add(objATM);
                if (Userinfo.getUserId() != objLead.FPC_Rep_ML__c) {
                    newShare.add(new AccountShare(UserOrGroupId = objLead.FPC_Rep_ML__c, AccountId = strAccId, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read'));
                }
            }
        }
        insert newShare;
        insert atmInsert;
    }

    public void updatingNewContact(Id strConId) {
        system.debug('strContId ' + strConId);
        if(strConId != null)
        {
            system.debug('A CONTACT WAS CREATED. String strConId = convertResult.getContactId() : strConId = ' +strConId +'.');
            system.debug('Query for contact... ');
            Contact c = [select Id, Best_Time_to_Reach__c, Invalid_FAX__c, Invalid_Email__c from Contact where Id = :strConId];
            c.Best_Time_to_Reach__c = objLead.Best_Time_to_Reach__c;
            c.Invalid_Fax__c = objLead.Invalid_FAX__c;
            c.Invalid_email__c = objLead.Invalid_Email__c;
            c.Isprimary__c = true;
            c.MobilePhone = objLead.MobilePhone;

            update c;
        }
    }

    public PageReference updateTheOpportunity(Account objAcc){
        //at this point we have converted the Lead to an Account, Contact, and (optionally) an Opportunity
        //here we update the Opportunity and redirect the user back to the created object page
        String strRec = String.ValueOf(objRecType);
        String strRecName = mapRecordType.get(strRec);
        PageReference p;
        if(createOppty) {
            List<Opportunity> oOpp = [Select Id from Opportunity Where AccountId = : strAccId and RecordTypeId =: strRec];
            system.debug('size:: ' + oOpp.size());
            String sCount = '0';
            //this should only ever be the size of 0 or 1....
            if(oOpp.size() == 1) {
                sCount = String.ValueOf(1);
            }
            else {
                sCount = String.ValueOf(oOpp.size() + 1);
            }
            String strOppName = objLead.Company + ' ' + strRecName + ' Deal#' + ' '+sCount ;
            Opportunity objOpp = [Select RecordTypeId, Name from Opportunity WHERE Id = :strOppId];
            objOpp.RecordTypeId = strRec;
            objOpp.Name = strOppName;

            // 4/4/12 changing to make the owner of the account match the owner of the lead
            objOpp.OwnerId = objLead.OwnerId;

            update objOpp;

            p = new PageReference('/' + strOppId);
        }
        else {
            p = new PageReference('/' + objAcc.Id);
        }
        system.debug('p in the method:: ' + p);
        return p;
    }

    public PageReference convertLeadToAcctContOppty()
    {
        system.debug('createOppty:: ' + createOppty);
        transient list<Attachment> leadAttachments = new list<Attachment>();
        transient list<Note> leadNotes = new list<Note>();
        objLead.Ready_To_Convert__c= true;
        update objLead;

        Lead le = objLead;

        if(le!= null && le.id != null){
            // query for all notes and attachments for the lead
            for(Attachment atmt : [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a Where a.ParentId = :le.id]){
                leadAttachments.add(atmt);
            }
            // query for all notes for the lead
            for(Note n : [Select n.Title, n.SystemModstamp, n.ParentId, n.OwnerId, n.LastModifiedDate, n.LastModifiedById, n.IsPrivate, n.IsDeleted, n.Id, n.CreatedDate, n.CreatedById, n.Body From Note n Where n.ParentId = :le.id]){
                leadNotes.add(n);
            }
        }
        if(objRecType != null)
        {
            system.debug('objrectype:: ' + objRecType);
            User tmpUser = [SELECT Id, Username FROM USER WHERE Username like 'haccount@fivepointcapital.com%' limit 1];
            //house account
            if(tmpUser != null)
            {
                try
                {
                    Account objAcc = createAccount();
                    Id strConId = convertTheLead(objAcc);
                    saveLeadActivityHistory(strAccId);
                    createOpptyIfRequested(strOppId, leadAttachments);
                    creatingAddresses(objAcc);
                    setUpAccountTeamMembers();
                    updatingNewContact(strConId);
                    PageReference p = updateTheOpportunity(objAcc);
                    system.debug('strAccId:: ' + strAccID + ', objAcc:: ' + objAcc);
                    //redirecting user to either Account or Opportunity page
                    p.setRedirect(true);
                    return p;
                }
                catch(Exception e)
                {
                    system.debug('catch statement');
                    ApexPages.addMessages(e);
                }
            }
        }
        return null;
    }
}