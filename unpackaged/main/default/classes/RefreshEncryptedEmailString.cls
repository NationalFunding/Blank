//FTC 2/27/2025
//This class can now be decomissioned after the release of SR-59
public class RefreshEncryptedEmailString {

    private void refreshLead(String recordId, String sourceOrg, String brand) {

        lead l = [SELECT Id, Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c FROM LEAD WHERE Id =: recordId];

        String tokencred = ConsoleApplicationLinkController.getShortenedLink(recordId, l.Web_Id_NatFund__c, sourceOrg, brand);
        l.Encrypted_Email_String__c = tokencred;
        l.Encrypted_Email_String_Refresh_Date__c = date.parse(system.today().format());
        update l; 
    }

    private void refreshContact(String recordId, String sourceOrg, String brand){

        contact c = [SELECT Id, Account.Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c FROM CONTACT WHERE Id =: recordId];

        String tokencred = ConsoleApplicationLinkController.getShortenedLink(recordId, c.Account.Web_Id_NatFund__c, sourceOrg, brand);
        c.Encrypted_Email_String__c = tokencred;
        c.Encrypted_Email_String_Refresh_Date__c = date.parse(system.today().format());
        update c;
    }

    public void refresh(String recordId, String sourceOrg, String brand){
        RefreshEncryptedEmailString refreshEES = new RefreshEncryptedEmailString();

        if(recordId.startsWithIgnoreCase('00Q')){
            try {
                refreshEES.refreshLead(recordId, sourceOrg, brand);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

        } else if(recordId.startsWithIgnoreCase('003')){
            try{
                refreshEES.refreshContact(recordId, sourceOrg, brand);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}