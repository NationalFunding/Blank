public with sharing class viewAllActivityAndNotes {
    String oppId;
    public List<wrapActivity> lstActivities{get;set;}
    public List<wrapNotes> lstNotes{get;set;}
    
    public viewAllActivityAndNotes(ApexPages.StandardController controller) 
    {
    	oppId = controller.getId();
    	if(oppId!=null && oppId!='')
    	{
    		lstActivities = new List<wrapActivity>();
    		lstNotes = new List<wrapNotes>();
	    	List<Opportunity> lstOpp = [SELECT Id, Name, (Select WhoId, WhatId, Subject, Status, Response_Channel__c, 
	    	   Reason__c, RPC__c, Priority, OwnerId, Owner.Name, Location, IsTask, IsClosed, Id, DurationInMinutes, Description, 
	    	   CallType, CallObject, CallDurationInSeconds, CallDisposition, ActivityType, ActivityDate,CreatedDate, 
	    	   AccountId From ActivityHistories), (Select n.Title, n.ParentId, n.OwnerId,  n.Owner.Name, n.Id, n.CreatedById, n.CreatedDate, n.Body 
	    	   From Notes n), (Select a.ParentId, a.OwnerId, a.Owner.Name, a.Name, a.Id, a.Description, a.ContentType, a.CreatedDate, a.CreatedById 
	    	   From Attachments a) From Opportunity Where Id =: oppId];//0068000000YvbwZ 
	    	
	    	List<Attachment> lstAtt;
	        List<Note> lstNote;
	        List<ActivityHistory> lstActHist;   
	    	for(Opportunity o : lstOpp)
	    	{
	    		lstAtt = o.Attachments;
	    		lstNote = o.Notes;
	    		lstActHist = o.ActivityHistories;
	    	}   
	    	for(ActivityHistory oAH : lstActHist)
	    	{
		    	wrapActivity oAnN = new wrapActivity();
		        oAnN.sActivityDate = String.ValueOf(oAH.ActivityDate);   
		        oAnN.sActivityOwner = oAH.Owner.Name;
		        oAnN.sActivityObject = 'Opportunity';
		        oAnN.sActivitySubject = oAH.Subject;
		        oAnN.sActivityComments = oAH.Description;
		        lstActivities.add(oAnN);	
	    	}
	    	if(lstNote!=null && lstNote.size()>0)
	    	{
		    	for(Note oNo : lstNote)
		        {
		            wrapNotes oWNote = new wrapNotes();
		            oWNote.sNoteDate = String.ValueOf(oNo.CreatedDate);   
		            oWNote.sNoteOwner = oNo.Owner.Name;
		            oWNote.sNoteObject = 'Opportunity';
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
	                oWNote.sNoteDate = String.ValueOf(oAtch.CreatedDate);   
	                oWNote.sNoteOwner = oAtch.Owner.Name;
	                oWNote.sNoteObject = 'Opportunity';
	                oWNote.sNoteTitle = oAtch.ContentType;
	                oWNote.sNoteBody = oAtch.Description;
	                lstNotes.add(oWNote);  
	            }
	    	}
    	}
    }
    
    public class wrapActivity
    {
    	public String sActivityDate{get;set;}
    	public String sActivityOwner{get;set;}
    	public String sActivityObject{get;set;}
    	public String sActivitySubject{get;set;}
    	public String sActivityComments{get;set;}
    	public wrapActivity(){}
    }
    public class wrapNotes
    {
        public String sNoteDate{get;set;}
        public String sNoteOwner{get;set;}
        public String sNoteObject{get;set;}
        public String sNoteTitle{get;set;}
        public String sNoteBody{get;set;}
        public wrapNotes(){}
    }
    
    public static testMethod void testThisClass() {
        Test.startTest();      
        //Opportunity o = [Select Id from Opportunity Where Id = '0068000000YvbwZ'];
        Account a = new Account(Name='Test Account', Phone = '8755465899',Type= 'Customer');
        insert a;
        Opportunity o = new Opportunity(Name='Test Opp', AccountId=a.Id, StageName ='Active', CloseDate = Date.Today()+10);
        insert o;
        
        Task t = new Task(Subject ='Call', Status = 'Completed', WhatId = o.Id);
        insert t;
        
        Note n = new Note(Title = 'TestNote', Body ='TestBody', ParentId = o.Id);
        insert n;
        
        ApexPages.StandardController obj = new ApexPages.StandardController(o);                                      
        viewAllActivityAndNotes controller = new viewAllActivityAndNotes(obj);                             
        Test.stopTest();
    }
}