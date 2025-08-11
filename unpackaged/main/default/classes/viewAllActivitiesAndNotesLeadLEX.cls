public class viewAllActivitiesAndNotesLeadLEX {
	@AuraEnabled(cacheable=true)
    public static ActivityAndNotes getActivityAndNotes(string leadId) {
        
        ActivityAndNotesLeadHelper activityAndNotesLeadHelper = new ActivityAndNotesLeadHelper();
        ActivityAndNotes activityAndNotes = activityAndNotesLeadHelper.GetActivityAndNotesOnLead(leadId);
        
        return activityAndNotes;
    }
}