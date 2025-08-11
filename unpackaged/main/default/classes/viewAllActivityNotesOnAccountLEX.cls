public without sharing class viewAllActivityNotesOnAccountLEX {
    @AuraEnabled(cacheable=true)
    public static ActivityAndNotes getActivityAndNotes(string accountId) {
        
        ActivityAndNotesHelper activityAndNotesHelper = new ActivityAndNotesHelper();
        ActivityAndNotes activityAndNotes = activityAndNotesHelper.GetActivityAndNotesOnAccount(accountId);
        
        return activityAndNotes;
    }


    @AuraEnabled(cacheable=true)
    public static ActivityAndNotes getActivityAndNotesAll(string accountId, integer pageNumber, integer pageSize) {
        
        ActivityAndNotesHelper activityAndNotesHelper = new ActivityAndNotesHelper();
        ActivityAndNotes activityAndNotes = activityAndNotesHelper.GetActivityAndNotesOnAccountAll(accountId, pageNumber, pageSize);
        
        return activityAndNotes; 
    }
}