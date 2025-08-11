public class wrapActivity {
    
   	@AuraEnabled public String sId { get; set; }
   	@AuraEnabled public String sActivityDate { get; set; }
   	@AuraEnabled public String sActivityCreatedDate { get; set; }
   	@AuraEnabled public String sActivityOwner { get; set; }
   	@AuraEnabled public String sActivityObject { get; set; }
   	@AuraEnabled public String sActivitySubject { get; set; }
   	@AuraEnabled public String sActivityComments { get; set; }
    @AuraEnabled public String sActivityType {get; set; }

   	public wrapActivity(){}
}