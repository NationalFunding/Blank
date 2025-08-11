public without sharing class ActivityAndNotes {
	@AuraEnabled public List<wrapActivity> Activities { get; set; }
    @AuraEnabled public List<wrapNotes> Notes { get; set; }
    @AuraEnabled public Integer TotalActivities {get; set; }

}