public class viewAllActivityNotesOnAccount {
    String accId;
    String sRetId;
    public List<wrapActivity> lstActivities{get;set;}
    public List<wrapNotes> lstNotes{get;set;}
    List<Note> lstFinalNotes;
    List<ActivityHistory> lstActHistTemp; 
    public String strAccName{get;set;}
    
    public viewAllActivityNotesOnAccount() 
    {
        if(ApexPages.currentPage().getParameters().get('AccId')!=null && ApexPages.currentPage().getParameters().get('AccId')!='')
            accId = ApexPages.currentPage().getParameters().get('AccId');
        if(ApexPages.currentPage().getParameters().get('RetId')!=null && ApexPages.currentPage().getParameters().get('RetId')!='')
            sRetId = ApexPages.currentPage().getParameters().get('RetId');
        loadMe();
    }
    private void loadMe()
    {
        lstFinalNotes = new List<Note>();
        strAccName = '';
        
        if(accId!=null && accId!='')
        {
            lstActivities = new List<wrapActivity>();
            lstNotes = new List<wrapNotes>();
            List<Account> lstAcc = [SELECT Id, Name, (Select WhoId, WhatId, Subject, Status, Response_Channel__c, 
               Reason__c, RPC__c, Priority, OwnerId, Owner.Name, Location, IsTask, IsClosed, Id, DurationInMinutes, Description, 
               CallType, CallObject, CallDurationInSeconds, CallDisposition, ActivityType, ActivityDate,CreatedDate,LastModifiedDate, 
               AccountId, Date_Activity_Logged__c From ActivityHistories  order by Date_Activity_Logged__c desc limit 50), (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
               From Notes n limit 50), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
               From Attachments a limit 50) From Account Where Id =: accId];//0068000000YvbwZ 
            
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
                //lstActHistTemp = lstActHist;
                //listActivitySortDate();
                //lstActHist = lstActHistTemp;
                if(lstNote!=null)
                   lstFinalNotes.addAll(lstNote);
                if(lstActHist!=null)
                    setValuesToWrapper(lstActHist, 'Account'); 
            }  
            
            
            List<Opportunity> lstOpp = [SELECT Id, Name, AccountId, (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
               From Notes n limit 50), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
               From Attachments a limit 50) From Opportunity Where AccountId =: accId];//0068000000YvbwZ 
            
            set<String> setOppIds = new Set<String>();
            lstAtt = null; lstNote = null; lstActHist = null;
            for(Opportunity o : lstOpp)
            {
                lstNote = null;
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                setOppIds.add(o.Id);
                if(lstNote!=null)
                   lstFinalNotes.addAll(lstNote);
            }
            
            List<Contact> lstCont = [SELECT Id, Name, (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate  
               From Notes n limit 50), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate  
               From Attachments a limit 50) From Contact Where AccountId =: accId];
            
            set<String> setConIds = new Set<String>();
            lstAtt = null; lstNote = null; lstActHist = null;
            for(Contact o : lstCont)
            {
                lstNote = null;
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                setConIds.add(o.Id);
                if(lstNote!=null)
                   lstFinalNotes.addAll(lstNote);
            }   

            /*lstNote = null;
            lstNote = [Select n.Title, n.SystemModstamp, n.ParentId, n.OwnerId, n.Owner.Name, n.LastModifiedDate, n.LastModifiedById, n.IsPrivate, n.IsDeleted, 
                n.Id, n.CreatedDate, n.CreatedById, n.Body From Note n Where n.ParentId =: accId];
            if(lstNote!=null)
                lstFinalNotes.addAll(lstNote);
            */
            if(lstFinalNotes!=null && lstFinalNotes.size()>0)
            {
                listSortDate();
                lstNotes = new List<wrapNotes>();
                //Note oNo;
                //for(Integer i = lstFinalNotes.size(); i > 0; i--)
                for(Note oNo : lstFinalNotes)
                {
                    //oNo = lstFinalNotes[i-1];
                    wrapNotes oWNote = new wrapNotes();
                    //date d = Date.newInstance(oNo.CreatedDate.year(),oNo.CreatedDate.month(),oNo.CreatedDate.day());
                    //oWNote.sNoteDate = String.ValueOf(d);
                    //oWNote.sNoteDate = SOQLFormat(oNo.CreatedDate);
                    oWNote.sNoteDate = SOQLFormat(oNo.LastModifiedDate);
                    oWNote.sNoteOwner = oNo.Owner.Name;
                    oWNote.sNoteTitle = oNo.Title;
                    oWNote.sNoteBody = oNo.Body;
                    lstNotes.add(oWNote);  
                }
            }    
        }   
    }
    /*
    private void listActivitySortDate()
    {
        List<ActivityHistory> lstToValid = new List<ActivityHistory>();
        lstToValid = lstActHistTemp;
        List<DateTime> dtDateTime = new List<DateTime>();
        DateTime oDt;
        List<ActivityHistory> lstFinalActivitySorted = null;
        if(lstToValid != null && lstToValid.size() >0) {
            for(ActivityHistory oTmp : lstToValid)
            {
                //oDt = oTmp.CreatedDate;
                oDt = oTmp.LastModifiedDate;
                dtDateTime.add(oDt);
            }
            dtDateTime.sort();
            lstFinalActivitySorted = new List<ActivityHistory>();
            for(Integer i = 0; i < dtDateTime.size() ; i++)
            {
                DateTime dTmpDt = dtDateTime[i];
                for(Integer j = 0; j <  lstToValid.size() ; j++)
                {
                    ActivityHistory oTmp = lstToValid[j];
                    //if(dTmpDt==oTmp.createdDate)
                    if(dTmpDt==oTmp.LastModifiedDate)
                    {
                        lstFinalActivitySorted.add(oTmp);
                        dtDateTime.remove(i);
                        lstToValid.remove(j);
                        break;
                    }
                }
            }
        }
        lstActHistTemp = lstFinalActivitySorted;
    }
    */
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
                //oDt = oTmp.CreatedDate;
                oDt = oTmp.LastModifiedDate;
                dtDateTime.add(oDt);
            }
            dtDateTime.sort();
            system.debug('-------------Sorted DateTime--------------'+dtDateTime);
            lstFinalNotesSorted = new List<Note>();
            for(Integer i = dtDateTime.size(); i >0 ; i--)
            {
                DateTime dTmpDt = dtDateTime[i-1];
                for(Note oTmp : lstToValidate)
                {
                    //if(dTmpDt==oTmp.createdDate)
                    if(dTmpDt==oTmp.LastModifiedDate)
                        lstFinalNotesSorted.add(oTmp);
                }
            }
            system.debug('-------------lstFinalNotesSorted--------------'+lstFinalNotesSorted);
        }
        lstFinalNotes = lstFinalNotesSorted;
    }
    
    public viewAllActivityNotesOnAccount(ApexPages.StandardController controller) 
    {
        accId = controller.getId();
        loadMe();
    }
    
    public String SOQLFormat(DateTime dt) {
        return dt.format('M/d/yyyy h:mm a');
    }
    private void setValuesToWrapper(List<ActivityHistory> tmpLstActHist, string strObject)
    {
        if(tmpLstActHist!=null && tmpLstActHist.size()>0)
        {
            Integer i = 0;
            //for(i = tmpLstActHist.size(); i > 0 ; i--)
            for(ActivityHistory oAH : tmpLstActHist)
            {
                //ActivityHistory oAH =  tmpLstActHist[i-1];
                wrapActivity oAnN = new wrapActivity();
                if(oAH.ActivityDate!=null)
                {
                    date d = Date.newInstance(oAH.ActivityDate.year(),oAH.ActivityDate.month(),oAH.ActivityDate.day());
                    oAnN.sActivityDate = String.ValueOf(d);
                }  
                //oAnN.sActivityCreatedDate = SOQLFormat(oAH.CreatedDate);
                if(oAH.Date_Activity_Logged__c != null)
                {
                     oAnN.sActivityCreatedDate = SOQLFormat(oAH.Date_Activity_Logged__c);
                }
                oAnN.sActivityOwner = oAH.Owner.Name;
                oAnN.sActivityObject = strObject;
                oAnN.sActivitySubject = oAH.Subject;
                oAnN.sActivityComments = oAH.Description;
                lstActivities.add(oAnN);    
            }
        }
        /*if(tmpLstNote!=null && tmpLstNote.size()>0)
        {
            for(Note oNo : tmpLstNote)
            {
                wrapNotes oWNote = new wrapNotes();
                oWNote.sNoteDate = String.ValueOf(oNo.CreatedDate);   
                oWNote.sNoteOwner = oNo.Owner.Name;
                oWNote.sNoteObject = strObject;
                oWNote.sNoteTitle = oNo.Title;
                oWNote.sNoteBody = oNo.Body;
                lstNotes.add(oWNote);  
            }
        }
        else if(tmpLstAtt!=null && tmpLstAtt.size()>0)
        {
            for(Attachment oAtch : tmpLstAtt)
            {
                wrapNotes oWNote = new wrapNotes();
                oWNote.sNoteDate = String.ValueOf(oAtch.CreatedDate);   
                oWNote.sNoteOwner = oAtch.Owner.Name;
                oWNote.sNoteObject = strObject;
                oWNote.sNoteTitle = oAtch.ContentType;
                oWNote.sNoteBody = oAtch.Description;
                lstNotes.add(oWNote);  
            }
        }*/   
    }    
    public PageReference Cancel()
    {
        PageReference p = new PageReference('/'+sRetId);
        p.setRedirect(true);
        return p;   
    }
    public static testMethod void testThisClass() {
        Test.startTest();      
               
        Account a = new Account(Name='Test Account', Phone = '8755465899',Type= 'Customer');
        insert a;
        Opportunity o = new Opportunity(Name='Test Opp', AccountId=a.Id, StageName ='Active', CloseDate = Date.Today()+10);
        insert o;
        
        Task t = new Task(Subject ='Call', Status = 'Completed', WhatId = a.Id);
        insert t;
        
        Note n = new Note(Title = 'TestNote', Body ='TestBody', ParentId = a.Id);
        insert n;
        //ApexPages.StandardController obj = new ApexPages.StandardController(o);                                      
        //viewAllActivityNotesOnAccount controller = new viewAllActivityNotesOnAccount(obj);
        ApexPages.currentPage().getParameters().put('AccId',a.Id);
        ApexPages.currentPage().getParameters().put('RetId',a.Id);
        viewAllActivityNotesOnAccount controller = new viewAllActivityNotesOnAccount();
        controller.Cancel();                                     
        Test.stopTest();
    }
}