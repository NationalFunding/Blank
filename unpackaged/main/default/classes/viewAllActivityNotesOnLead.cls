public class viewAllActivityNotesOnLead {
     
    String leadId;
    public List<wrapActivity> lstActivities{get;set;}
    public List<wrapNotes> lstNotes{get;set;} 
    List<ActivityHistory> lstActHistTemp; 
    
    public String SOQLFormat(DateTime dt) {
        return dt.format('M/d/yyyy h:mm a');
    }
    
    public viewAllActivityNotesOnLead(ApexPages.StandardController controller)
    { 
        leadId = controller.getId();
        if(leadId!=null && leadId!='')
        {
            lstActivities = new List<wrapActivity>();
            lstNotes = new List<wrapNotes>();
            List<Lead> lstLead = [SELECT Id, Name, (Select WhoId, WhatId, Subject, Status, Response_Channel__c, 
               Reason__c, RPC__c, Priority, OwnerId, Owner.Name, Location, IsTask, IsClosed, Id, DurationInMinutes, Description, 
               CallType, CallObject, CallDurationInSeconds, CallDisposition, ActivityType, ActivityDate,CreatedDate, LastModifiedDate,
               AccountId,Date_Activity_Logged__c From ActivityHistories order by Date_Activity_Logged__c desc limit 50), (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate 
               From Notes n order by n.LastModifiedDate desc limit 50), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate 
               From Attachments a order by a.LastModifiedDate desc limit 50) From Lead Where Id =: leadId];//0068000000YvbwZ 
            
            List<Attachment> lstAtt;
            List<Note> lstNote;
            List<ActivityHistory> lstActHist;   
            for(Lead o : lstLead)
            {
                lstAtt = o.Attachments;
                lstNote = o.Notes;
                lstActHist = o.ActivityHistories;
                //listActivitySortDate();
                //if(lstActHistTemp!=null && lstActHistTemp.size()>0)
                //    lstActHist = lstActHistTemp;            
            }   
            if(lstActHist!=null && lstActHist.size()>0)
            {
                for(ActivityHistory oAH : lstActHist)
                {
                    wrapActivity oAnN = new wrapActivity();
                    if(oAH.ActivityDate!=null)
                    {
                        date d = Date.newInstance(oAH.ActivityDate.year(),oAH.ActivityDate.month(),oAH.ActivityDate.day());
                        oAnN.sActivityDate = String.ValueOf(d);
                    }      
                    //oAnN.sActivityCreatedDate = SOQLFormat(oAH.CreatedDate);
                    if(oAH.Date_Activity_Logged__c != null)
                    {  oAnN.sActivityCreatedDate = SOQLFormat(oAH.Date_Activity_Logged__c); }
                   // oAnN.sActivityCreatedDate = SOQLFormat(oAH.Date_Activity_Logged__c);
                    oAnN.sActivityOwner = oAH.Owner.Name;
                    oAnN.sActivityObject = 'Lead';
                    oAnN.sActivitySubject = oAH.Subject;
                    oAnN.sActivityComments = oAH.Description;
                    lstActivities.add(oAnN);    
                }
            }
            if(lstNote!=null && lstNote.size()>0)
            {
                for(Note oNo : lstNote)
                {
                    wrapNotes oWNote = new wrapNotes();
                    //oWNote.sNoteDate = SOQLFormat(oNo.CreatedDate);
                    oWNote.sNoteDate = SOQLFormat(oNo.LastModifiedDate);  
                    oWNote.sNoteOwner = oNo.Owner.Name;
                    oWNote.sNoteObject = 'Lead';
                    oWNote.sNoteTitle = oNo.Title;
                    oWNote.sNoteBody = oNo.Body;
                    lstNotes.add(oWNote);  
                }
            }
            else
            {
                for(Attachment oAtch : lstAtt)
                {
                    wrapNotes oWNote = new wrapNotes();
                    //oWNote.sNoteDate = SOQLFormat(oAtch.CreatedDate);
                    oWNote.sNoteDate = SOQLFormat(oAtch.LastModifiedDate);   
                    oWNote.sNoteOwner = oAtch.Owner.Name;
                    oWNote.sNoteObject = 'Lead';
                    oWNote.sNoteTitle = oAtch.ContentType;
                    oWNote.sNoteBody = oAtch.Description;
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
                oDt = oTmp.LastModifiedDate;
                dtDateTime.add(oDt);
            }
            dtDateTime.sort();
            lstFinalActivitySorted = new List<ActivityHistory>();
            for(Integer i = 0; i < dtDateTime.size() ; i++)
            {
                DateTime dTmpDt = dtDateTime[i];
                for(ActivityHistory oTmp : lstToValid)
                {
                    if(dTmpDt==oTmp.LastModifiedDate)
                        lstFinalActivitySorted.add(oTmp);
                }
            }
        }
        lstActHistTemp = lstFinalActivitySorted;
    }*/
    
    public static testMethod void testThisClass() {
        Test.startTest();      
         Lead l = new Lead(Company ='Test Comp', Status = 'Active', LastName ='Test Lead');
        insert l;
       
        Task t = new Task(Subject ='Call', Status = 'Completed', WhoId = l.Id);
        insert t;
        
        Note n = new Note(Title = 'TestNote', Body ='TestBody', ParentId = l.Id);
        insert n;
        
        ApexPages.StandardController obj = new ApexPages.StandardController(l);                                      
        viewAllActivityNotesOnLead controller = new viewAllActivityNotesOnLead(obj);
        Test.stopTest();
    }

}