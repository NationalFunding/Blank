public class ActivityAndNotesLeadHelper {
    
    private List<wrapActivity> lstActivities{get;set;}
    private List<wrapNotes> lstNotes{get;set;} 

    public ActivityAndNotes GetActivityAndNotesOnLead(string leadId)
    {
        GetActivityAndNotesOnLeadInternal(leadId);
        ActivityAndNotes activityAndNotes = new ActivityAndNotes();

        activityAndNotes.Activities = this.lstActivities;
        activityAndNotes.Notes = this.lstNotes;

        return activityAndNotes;
    }
    
    private void GetActivityAndNotesOnLeadInternal(string leadId)
    { 
        if(leadId!=null && leadId!='')
        {
            lstActivities = new List<wrapActivity>();
            lstNotes = new List<wrapNotes>();
            List<Lead> lstLead = [SELECT Id, Name, (Select WhoId, WhatId, Subject, Status, Response_Channel__c, 
               Reason__c, RPC__c, Priority, OwnerId, Owner.Name, Location, IsTask, IsClosed, Id, DurationInMinutes, Description, 
               CallType, CallObject, CallDurationInSeconds, CallDisposition, ActivityType, ActivityDate,CreatedDate, LastModifiedDate,
               AccountId,Date_Activity_Logged__c 
               From ActivityHistories order by ActivityDate DESC, LastModifiedDate DESC limit 50), (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body, LastModifiedDate 
               From Notes n order by n.LastModifiedDate desc limit 50), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById, LastModifiedDate 
               From Attachments a order by a.LastModifiedDate desc limit 50) From Lead Where Id =: leadId ];//0068000000YvbwZ 
            
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
                    oAnN.sId = oAH.Id;
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
                    oAnN.sActivityType = oAh.ActivityType;
                    lstActivities.add(oAnN);    
                }
            }
            if(lstNote!=null && lstNote.size()>0)
            {
                for(Note oNo : lstNote)
                {
                    wrapNotes oWNote = new wrapNotes();
                    oWNote.sId = oNo.Id;
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
                    oWNote.sId = oAtch.Id;
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
    
    private String SOQLFormat(DateTime dt) {
        return dt.format('M/d/yyyy h:mm a');
    }
    
}