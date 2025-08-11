public class HelperClass {
  public static boolean firstRun = true;

  public static void upsertDFPToken(String recordId, String brand, String token) {
    
    String contactId = recordId != null && recordId.startsWithIgnoreCase('003') ? recordId : null;
    String leadId = recordId != null && recordId.startsWithIgnoreCase('00Q') ? recordId : null;

    if(contactId != null) {
      //update the contact record's encrypted_email_string__c field first.
      //per client, it is ok for this field to be overwritten if the owner has two brands
      contact c = [SELECT Id, Account.Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c 
                    FROM Contact 
                    WHERE Id =: recordId];
      c.Encrypted_Email_String__c = token;
      c.Encrypted_Email_String_Refresh_Date__c = date.parse(system.today().format());
      update c;
      
      //update or create a DFP_Toekn__c record for the contact record
      List<DFP_Token__c> dfpContactTokens = [SELECT Token__c, Contact__c, Brand_Experience__c 
                                              FROM DFP_Token__c 
                                              WHERE Contact__c = :contactId AND Brand_Experience__c = :brand AND Token__c <> NULL];
      if(dfpContactTokens.size() > 0) {
        for(DFP_Token__c dfpToken : dfpContactTokens) {
          dfpToken.Token__c = token;
        }
        update dfpContactTokens;
      } else {
        DFP_Token__c dfpContactToken = new DFP_Token__c(
          Token__c = token,
          Brand_Experience__c = brand,
          Contact__c = contactId
        );
        insert dfpContactToken;
      }      
    }

    if(leadId != null) {
      //update the lead record's encrypted_email_string__c field first.
      //per client, it is ok for this field to be overwritten if the owner has two brands
      lead l = [SELECT Id, Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c 
                FROM Lead 
                WHERE Id =: leadId];
      l.Encrypted_Email_String__c = token;
      l.Encrypted_Email_String_Refresh_Date__c = date.parse(system.today().format());
      update l; 
      
      //update or create a DFP_Toekn__c record for the lead record
      List<DFP_Token__c> dfpLeadTokens = [SELECT Token__c, Lead__c, Brand_Experience__c 
                                              FROM DFP_Token__c 
                                              WHERE Lead__c = :leadId and Brand_Experience__c = :brand AND Token__c <> NULL];
      if(dfpLeadTokens.size() > 0) {
        for(DFP_Token__c dfpToken : dfpLeadTokens) {
          dfpToken.Token__c = token;
        }
        update dfpLeadTokens;
      } else {
        DFP_Token__c dfpLeadToken = new DFP_Token__c(
          Token__c = token,
          Brand_Experience__c = brand,
          Lead__c = leadId
        );
        insert dfpLeadToken;
      }      
    }
  }
}