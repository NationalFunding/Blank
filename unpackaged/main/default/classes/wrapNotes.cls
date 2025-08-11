public class wrapNotes {
    
	@AuraEnabled public String sId { get; set; }
    @AuraEnabled public String sNoteDate { get; set; }
    @AuraEnabled public String sNoteOwner { get; set; }
    @AuraEnabled public String sNoteObject { get; set; }
    @AuraEnabled public String sNoteTitle { get; set; }
    @AuraEnabled public String sNoteBody { get; set; }

    public wrapNotes(){}
}