/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: External Custom lead conversion
* DESCRIPTION: This class triggers from a lead event where an external source triggers activation
* 
*.  .    ,           ..___        .       
*|\ | _.-+-* _ ._  _.|[__ . .._  _|*._  _ 
*| \|(_] | |(_)[ )(_]||   (_|[ )(_]|[ )(_]
*                                      ._|
*          __
*    w  c(..)o   (          _CodeMonkey
*     \__(-)    __)
*         /\   (
*        /(_)___)
*        w /|
*         | \
*         m  m
*
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         BRANDON KRAVITZ     <bkravitz@nationalfunding.com>
* @modifiedBy     BRANDON KRAVITZ     <bkravitz@nationalfunding.com>

* @version        1.0
* @created        2017-07-15
* @modified       2017-07-15
* @systemLayer    Service
* @see            incLead
* @see            doConvert()
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v            bkravitz@nationalfunding.com
* 2017-07-15      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v            bkravitz@nationalfunding.com
* 2017-07-15      Each change to this file should be documented by incrementing the version number,
*                 and adding a new entry to this @changes list. Note that there is a single blank
*                 line between each @changes entry.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/  


public without sharing class externalCustomLeadConvert{
    
    public Lead objLead{get;set;}
    public Id incLead {get;set;}
    public Opportunity objOpp{get;set;} 
    public String objRecType{get;set;} 
    public ID strConID { get; set; }
    public ID strAccID { get; set; }
    public ID strOppId { get; set; }
    
    public externalCustomLeadConvert(Id incLead){
        
        objLead = [Select l.SSN_Encrypted__c, l.Yrs_in_Business__c, l.Year_Started__c, l.Website, l.UCC_Indicator__c, l.Trans_Value_per_Month__c, 
                   l.Title__c, l.Title, l.Time_Zone__c, l.SystemModstamp, l.Street, l.Status_MCA__c, 
                   l.Status_Lease__c, l.Status_EPP__c, l.Status, l.State, l.Short_Account_Number__c,   l.Salutation, l.Sales_Volume__c, l.SLX_Lead_ID__c, l.SLX_AccountID__c, l.SIC_Name__c,SICName__c, 
                   l.SICCODE__c,  l.Rersponse_Date__c, l.RecordTypeId, l.Rating,  
                   l.Qty_Trans_per_Month__c, l.PostalCode, l.Phone, l.Paydex_Score__c, 
                   l.Owns_Rents1__c, l.OwnerId, l.NumberOfEmployees, l.Name, l.MasterRecordId, l.MSA_Name__c, l.MSA_Code__c, l.City__c,
                   l.Home_Address__c, l.State__c, l.Zip_Code__c, l.Street_Number__c, l.Street_Type__c, l.Street_Name__c,
                   l.List_Reference__c, l.Ownership__c, l.LeadSource,  l.Owner.Name, l.Owner.Id,
                   l.LastName, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.Key_Code__c, l.IsUnreadByOwner, l.IsDeleted, 
                   l.IsConverted, l.Industry, l.Import_Date__c, l.Id, l.FirstName, l.FPC_Rep_ML__c, l.FPC_Rep_MCA__c, l.FPC_Rep_Lease__c, 
                   l.FPC_Rep_EPP__c, l.FICO__c, l.Experian_BIN__c, l.EmailBouncedReason, l.EmailBouncedDate, l.Email, l.Dias_Code__c, l.Description, 
                   l.Date_Established__c, l.DUNS_Number__c, l.DQ_Reasons__c, l.DQ_Details__c, l.DPBC__c, l.DPBC_Date__c, l.CreatedDate, l.CreatedById, 
                   l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.Company, l.City, l.CC_Processor__c, 
                   l.AnnualRevenue, l.Additional_Name_2__c, l.Additional_Name_1__c, l.Activation_Date__c, l.Activation_Code__c, l.Account_Number__c,
                   l.How_did_you_hear_about_us__c, l.Agency_ID__c, l.Agency_Rep_ID__c, l.Best_Time_to_Reach__c, l.Est_Credit_Score__c, l.Call_Count__c, l.Invalid_FAX__c,
                   l.Invalid_Email__c, l.Marketing_Pilot_Results__c, l.Response_Channel__c, l.Use_of_Funds__c,  l.MobilePhone, l.Home_Phone__c, l.Birth_Date__c
                   , (Select Id, RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, RPC__c, Call_Disposition__c, Reason__c, Response_Channel__c, Date_Activity_Logged__c From Tasks), (Select Id, WhoId, WhatId, Subject, Location, IsAllDayEvent, ActivityDateTime, ActivityDate, DurationInMinutes, StartDateTime, EndDateTime, Description, AccountId, OwnerId, IsPrivate, ShowAs, IsDeleted, IsChild, IsGroupEvent, GroupEventType, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, ReminderDateTime, IsReminderSet, RPC__c, Call_Disposition__c, Reason__c, Response_Channel__c, Date_Activity_Logged__c From Events)
                   From Lead l WHERE l.Id =:incLead];
        
        
        String objRecType = [Select Name, Id From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'MCA_Oppty'].Id;
        
        list<Attachment> leadAttachments = new list<Attachment>();
        list<Note> leadNotes = new list<Note>();
        // objLead.Ready_To_Convert__c= true;
        // update objLead;
        
        DateTime myDateTime = DateTime.now();
        Long l1 = myDateTime.getTime();
        
        system.debug('Start Time:::: ' + l1);
        Lead le = objLead;
        if(le!= null && le.id != null){
            
            for(Attachment atmt : [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a Where a.ParentId = :le.id]){
                leadAttachments.add(atmt);
            }
            
            for(Note n : [Select n.Title, n.SystemModstamp, n.ParentId, n.OwnerId, n.LastModifiedDate, n.LastModifiedById, n.IsPrivate, n.IsDeleted, n.Id, n.CreatedDate, n.CreatedById, n.Body From Note n Where n.ParentId = :le.id]){
                leadNotes.add(n);
            }
            
            if(le != null)
            {
                User tmpUser = [SELECT Id, Username FROM USER WHERE Username like 'haccount@fivepointcapital.com%' limit 1];
                
                if(tmpUser != null)
                {
                    try
                    {
                        Account objAcc = new Account();
                        objAcc.Name = objLead.Company;
                        objAcc.Type = 'Customer';
                        objAcc.Account_Number1__c  = objLead.Account_Number__c;
                        
                        system.debug('The lead owner is... ' +objLead.OwnerId);
                        String strCheck = objLead.OwnerId;
                        if(strCheck.startsWith('00G')){
                            update new Lead(Id=incLead, convertedLeadInitialStatus__c  = 'error');
                            return;
                        }
                        
                        
                        //  objAcc.Owner.Id = objLead.Owner.Id;
                        
                        //   system.debug('Setting account owners... ' +objLead.OwnerId);
                        
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
                        String str = objLead.OwnerId;
                        String strNew = str.subString(0,15);
                        objAcc.OwnerId = strNew;
                        System.debug('this is the set owner id:::: '  + strNew);
                        
                        insert objAcc;
                        Lead ld = new Lead(Id=objLead.Id, convertedLeadInitialStatus__c = 'Account Created' );
                        update ld;
                        
                        system.debug('The account was created, here is the ownerId... ' +objAcc.OwnerId);
                        
                        Database.Leadconvert convert = new Database.Leadconvert();
                        convert.setLeadId(objLead.Id);
                        convert.setAccountId(objAcc.Id);
                        convert.setConvertedStatus('Qualified/Converted');
                        convert.setOpportunityName(objLead.Name);
                        
                        
                        
                        convert.setOwnerId(objLead.Owner.Id);
                        
                        system.debug('The converted lead owners set to... ' +convert.getOwnerId());
                        
                        String strRec = objRecType;
                        //           String strRecName = mapRecordType.get(strRec);
                        //           String strMobile;
                        //           if(objLead.MobilePhone!=null)
                        //               strMobile = objLead.MobilePhone;
                        
                        Database.LeadConvertResult convertResult = Database.convertLead(convert); 
                        this.strOppId = convertResult.getOpportunityId();
                        this.strAccId = convertResult.getAccountId();
                        this.strConId = convertResult.getContactId();
                        
                        update new Contact(Id = strConId, SSN_Encrypted__c = objLead.SSN_Encrypted__c, HomePhone = objLead.Home_Phone__c, Birthdate = objLead.Birth_Date__c, MailingStreet = objLead.Home_Address__c, MailingCity = objLead.City__c, IsPrimary__c = true, MailingState = objLead.State__c, MailingPostalCode = objLead.Zip_Code__c);
                        
                        if(strOppId != null){
                            if(leadAttachments.size()!=0){
                                list<Attachment> aList = new list<Attachment>();            
                                
                                for(Attachment att :leadAttachments){
                                    
                                    transient Attachment a = new Attachment();
                                    a.Name = att.Name;
                                    a.Body = att.Body;
                                    a.Description = att.Description;
                                    a.IsPrivate = att.IsPrivate;
                                    
                                    a.parentId = strOppId;
                                    
                                    aList.add(a);
                                }
                                
                                insert aList;
                                
                                aList.clear();
                                
                                delete leadAttachments;
                            }
                            if(leadNotes.size()!=0){
                                list<Note> nList = new list<Note>();
                                
                                for(Note no :leadNotes){
                                    
                                    Note n = new Note();
                                    n.Title = no.Title;
                                    n.Body = no.Body;
                                    n.IsPrivate = no.IsPrivate;
                                    
                                    n.parentId = strOppId;
                                    
                                    nList.add(n);
                                }
                                
                                insert nList;
                                nList.clear();
                                delete leadNotes;
                            }
                        }
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
                                System.debug('City__c test' + objLead.City__c );
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
                                    
                                    insert add2;
                                }
                            }
                        }
                        
                        
                        
                        
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
                        
                        
                        insert newShare;
                        insert atmInsert;
                        
                        try{
                            List<Opportunity> oOpp = [Select Id from Opportunity Where AccountId = : strAccId and RecordTypeId =: objRecType];
                            System.debug('Account Id::::: ' + strAccId);
                            String sCount = '0';
                            if(oOpp.size() == 1)
                                sCount = String.ValueOf(1);
                            else
                                sCount = String.ValueOf(oOpp.size()+1);
                            String strOppName = objLead.Company + 'Working Capital Oppty' +  + ' Deal#' + ' '+sCount ;
                            Opportunity objOpp = [Select RecordTypeId, Name from Opportunity WHERE Id = :strOppId];
                            objOpp.RecordTypeId = strRec;
                            objOpp.Name = strOppName;
                            
                            
                            
                            
                            
                            
                            objOpp.OwnerId = objLead.OwnerId;
                            
                            update objOpp;
                            
                            system.debug('Opportunity was updated, the owner id... ' +objOpp.OwnerId );
                            
                            update new Account(Id=objAcc.Id, convertedLeadStatus__c = 'Completed');
                            System.debug('Send Email Description');
                            //Send Email Alert
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                            mail.setSenderDisplayName(objLead.Owner.Name);
                            mail.setSubject('New Converted Lead: ' + objLead.Company );
                            
                            DateTime myDateTime2 = DateTime.now();
                            Long l = myDateTime2.getTime();
                            
                            system.debug('End Time:::: ' + l);
                            
                            
                            mail.setHtmlBody('<html><body><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:12px" COLOR="#000000" LETTERSPACING="0" KERNING="0">Hi - <br/><br/></FONT></DIV><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:14px" COLOR="#000000" LETTERSPACING="0" KERNING="0"></FONT></DIV><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:14px" COLOR="#000000" LETTERSPACING="0" KERNING="0">Your lead ' + objLead.Company + ' has been converted by Salesforce.com automation.  To view the Account, please click on the link below. </FONT><br/><br/></DIV><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:14px" COLOR="#000000" LETTERSPACING="0" KERNING="0"></FONT></DIV><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:14px" COLOR="#000000" LETTERSPACING="0" KERNING="0"><A HREF="https://na29.salesforce.com/' + strAccId +'">View Account</A><br/></FONT></DIV><DIV ALIGN="LEFT"><FONT FACE="Arial" STYLE="font-size:6px" COLOR="#000000" LETTERSPACING="0" KERNING="0">TimeCompletion:' + (l1 - l) + '</FONT></DIV></body></html>'); 
                            mail.setSaveAsActivity(false);
                            mail.setTargetObjectId(objLead.OwnerId);
                            
                            lstMsgs.Add(mail);
                            Messaging.sendEmail(lstMsgs);
                            

                            
                        }
                        catch(Exception ex)
                        {
                            update new Account(Id=objAcc.Id, convertedLeadStatus__c = 'Error');
                            
                            System.debug('Error Handled::::: ' + ex.getMessage());
                        } 
                    }
                    catch(Exception e)
                    {
                        System.debug('Completion Occured but Error Handled::::: ' + e.getMessage());                    }
                }
            }
        }
    }
}