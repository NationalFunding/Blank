public without sharing class ActivityAndNotesHelper {

    public List<wrapActivity> lstActivities{get;set;}
    public List<wrapNotes> lstNotes{get;set;}
    List<Note> lstFinalNotes;
    List<ActivityHistory> lstActHistTemp; 
    public String strAccName{get;set;}
    public Integer TotalActivities {get;set;}


    public ActivityAndNotes GetActivityAndNotesOnAccount(string accountId)
    {
        GetActivityAndNotesOnAccountInternal(accountId);
        ActivityAndNotes activityAndNotes = new ActivityAndNotes();
        activityAndNotes.Activities = this.lstActivities;
        activityAndNotes.Notes = this.lstNotes;

        return activityAndNotes;
    }

    public ActivityAndNotes GetActivityAndNotesOnAccountAll(string accountId, integer pageNumber, integer pageSize) {

        Activity_SOQL_Duration__mdt mdtAccountDuration = [select Number_of_days__c from Activity_SOQL_Duration__mdt
                                                            where SObject__c = 'Account' Limit 1];

        Date dtToday = Date.today();
        Integer iNumberOfDays = Integer.valueOf(mdtAccountDuration.Number_of_days__c);
        Date dtComparison = Date.today().addDays(-iNumberOfDays);
        GetActivityAndNotesOnAccountInternalAll(accountId, dtComparison, pageNumber, pageSize);
        ActivityAndNotes activityAndNotes = new ActivityAndNotes();
        activityAndNotes.Activities = this.lstActivities;
        activityAndNotes.Notes = this.lstNotes;
        activityAndNotes.TotalActivities = this.TotalActivities;

        return activityAndNotes;
    }

    public void GetActivityAndNotesOnAccountInternal(string accountId)
    {
        lstFinalNotes = new List<Note>();
        strAccName = '';
        
        if(accountId!=null && accountId!='')
        {
            lstActivities = new List<wrapActivity>();
            lstNotes = new List<wrapNotes>();
            List<Account> lstAcc = [SELECT 
                    Id, Name, 
                    ( Select WhoId, WhatId, Subject, Status, Response_Channel__c, 
                    Reason__c, RPC__c, Priority, OwnerId, Owner.Name, Location, IsTask, IsClosed, Id, DurationInMinutes, Description, 
                    CallType, CallObject, CallDurationInSeconds, CallDisposition, ActivityType, ActivityDate,CreatedDate,LastModifiedDate, 
                    AccountId, Date_Activity_Logged__c 
                    From ActivityHistories 
                    order by ActivityDate DESC, LastModifiedDate DESC 
                    limit 50), 
                    ( Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
                    From Notes n limit 50), 
                    ( Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
                    From Attachments a limit 50) 
                From Account Where Id =: accountId];
            
            List<Attachment> lstAtt;
            List<Note> lstNote; 
            List<ActivityHistory> lstActHist;   
            lstAtt = null; lstNote = null; lstActHist = null;
            
            for(Account o : lstAcc)
            {
                strAccName = o.Name;
                lstNote = null;
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                lstActHist = o.ActivityHistories;

                if(lstNote!=null)
                {
                   lstFinalNotes.addAll(lstNote);
                }
                if(lstActHist!=null)
                {
                    setValuesToWrapper(lstActHist, 'Account'); 
                }
            }  
            
            List<Opportunity> lstOpp = [SELECT 
                    Id, Name, AccountId, 
                    ( Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
                    From Notes n limit 50), 
                    ( Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
                    From Attachments a limit 50) 
                From Opportunity Where AccountId =: accountId];
            
            set<String> setOppIds = new Set<String>();
            lstAtt = null; lstNote = null; lstActHist = null;
            for(Opportunity o : lstOpp)
            {
                lstNote = null;
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                setOppIds.add(o.Id);
                if(lstNote!=null)
                {
                   lstFinalNotes.addAll(lstNote);
                }
            }
            
            List<Contact> lstCont = [SELECT 
                    Id, Name, 
                    ( Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
                    From Notes n limit 50), 
                    ( Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
                    From Attachments a limit 50) 
                From Contact Where AccountId =: accountId];
            
            set<String> setConIds = new Set<String>();
            lstAtt = null; lstNote = null; lstActHist = null;
            for(Contact o : lstCont)
            {
                lstNote = null;
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                setConIds.add(o.Id);
                if(lstNote!=null)
                {
                   lstFinalNotes.addAll(lstNote);
                }
            }   

            if(lstFinalNotes!=null && lstFinalNotes.size()>0)
            {
                listSortDate();
                lstNotes = new List<wrapNotes>();
                for(Note oNo : lstFinalNotes)
                {
                    wrapNotes oWNote = new wrapNotes();
                    oWNote.sNoteDate = SOQLFormat(oNo.LastModifiedDate);
                    oWNote.sNoteOwner = oNo.Owner.Name;
                    oWNote.sNoteTitle = oNo.Title;
                    oWNote.sNoteBody = oNo.Body;
                    lstNotes.add(oWNote);  
                }
            }    
        }   
    }

    public void GetActivityAndNotesOnAccountInternalAll(string accountId, date comparisonDate, Integer pageNumber, Integer pageSize) {    
                
        if(!String.isBlank(accountId)) {
            List<Attachment> lstAtt = new List<Attachment>();
            List<Note> lstNote = new List<Note>();
            List<Task> lstTask = new List<Task>();
            List<Event> lstEvent = new List<Event>();
            List<Note> lstFinalNotes = new List<Note>();
            lstActivities = new List<wrapActivity>();
            Date todaysDate = Date.today();
            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = pageNumber*pageSize -1;

            list<Account> lAccountHistoriesTotal = [SELECT ( 
                                                            SELECT id
                                                            FROM ActivityHistories
                                                            WHERE ActivityDate > : comparisonDate
                                                          ) 
                                                FROM Account 
                                                WHERE Id =: accountId LIMIT 1];

            Integer iAHTotal = 0;
            for (Account a: lAccountHistoriesTotal){
                for(ActivityHistory ah : a.ActivityHistories){
                    iAHTotal++;
                }
            }

            this.TotalActivities = iAHTotal;

            list<Account> lAccountHistories = [SELECT ( 
                                                SELECT Id, Subject, Description, ActivityDate, ActivityType, ActivitySubType, OwnerId,Owner.Name,LastModifiedDate, CreatedDate 
                                                FROM ActivityHistories
                                                WHERE ActivityDate > : comparisonDate
                                                ORDER BY ActivityDate DESC 
                                                LIMIT : pageSize 
                                                OFFSET : startIndex) 
                                    FROM Account 
                                    WHERE Id =: accountId LIMIT 1];

            for (Account a: lAccountHistories){
                for(ActivityHistory ah : a.ActivityHistories){
                    wrapActivity wrapList = new wrapActivity();
                    if(ah.ActivityDate != null) {
                        Date d = Date.newInstance(ah.ActivityDate.year(),ah.ActivityDate.month(),ah.ActivityDate.day());
                        wrapList.sActivityDate = String.valueOf(d);
                    } 

                    if(ah.CreatedDate != null) {
                        wrapList.sActivityCreatedDate = String.valueOf(ah.CreatedDate);
                    }

                    wrapList.sId = ah.id;
                    wrapList.sActivityOwner = ah.Owner.Name;
                    wrapList.sActivityObject = ah.ActivityType;
                    wrapList.sActivitySubject = ah.Subject;
                    if (ah.ActivitySubType != 'Email'){
                        wrapList.sActivityComments = ah.Description;
                    }                    
                    wrapList.sActivityType = ah.ActivitySubType;
                    lstActivities.add(wrapList);  
                }
            }
        }   
    }

    private void listSortDate()
    {
        List<Note> lstToValidate = new List<Note>();
        lstToValidate = lstFinalNotes;
        List<DateTime> dtDateTime = new List<DateTime>();
        DateTime oDt;
        List<Note> lstFinalNotesSorted = null;
        if(lstToValidate != null && lstToValidate.size() >0) {
            for(Note oTmp : lstToValidate)
            {
                oDt = oTmp.LastModifiedDate;
                dtDateTime.add(oDt);
            }

            dtDateTime.sort();
            lstFinalNotesSorted = new List<Note>();
            for(Integer i = dtDateTime.size(); i >0 ; i--)
            {
                DateTime dTmpDt = dtDateTime[i-1];
                for(Note oTmp : lstToValidate)
                {
                    if(dTmpDt==oTmp.LastModifiedDate)
                    {
                        lstFinalNotesSorted.add(oTmp);
                    }
                }
            }
        }
        lstFinalNotes = lstFinalNotesSorted;
    }

    private String SOQLFormat(DateTime dt) {
        return dt.format('M/d/yyyy h:mm a');
    }

    private void setValuesToWrapper(List<ActivityHistory> tmpLstActHist, string strObject)
    {
        if(tmpLstActHist!=null && tmpLstActHist.size()>0)
        {
            Integer i = 0;
            for(ActivityHistory oAH : tmpLstActHist)
            {
                wrapActivity oAnN = new wrapActivity();
                if(oAH.ActivityDate!=null)
                {
                    date d = Date.newInstance(oAH.ActivityDate.year(),oAH.ActivityDate.month(),oAH.ActivityDate.day());
                    oAnN.sActivityDate = String.ValueOf(d);
                }  
                if(oAH.Date_Activity_Logged__c != null)
                {
                     oAnN.sActivityCreatedDate = SOQLFormat(oAH.Date_Activity_Logged__c);
                }
                oAnN.sId = oAH.Id;
                oAnN.sActivityOwner = oAH.Owner.Name;
                oAnN.sActivityObject = strObject;
                oAnN.sActivitySubject = oAH.Subject;
                oAnN.sActivityComments = oAH.Description;
                oAnN.sActivityType = oAH.ActivityType;
                lstActivities.add(oAnN);    
            }
        }
    }    
}