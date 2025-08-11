/**
 * Created by oporter on 8/17/2018.
 */

public with sharing class SendFundingOptionsController {

    private Apexpages.StandardController con;
    public List<ContactWrapper> contactList { get; set; }
    public Id opportunityID;
    private Id contactID;
    private String nfID;

    public SendFundingOptionsController(Apexpages.StandardController con){
        this.con = con; //con is the Opportunity ID
        opportunityID = this.con.getId();

        Init();
    }

    private void Init(){
        String contactName;
        Boolean flag;
        contactList = new List<ContactWrapper>(); //contact wrapper is the contact and a boolean if they have an email or not
        List<Opportunity> associatedAccountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityID LIMIT 1];

        for(Contact c : [Select Id, Name, Email, DLP_Email_Status__c, AccountId, Account.Web_Id_NatFund__c, Account.National_Funding_WebId__c, HasOptedOutOfEmail From Contact Where AccountId = :associatedAccountId[0].AccountId]){
            contactID = c.Id;
            contactName = c.Name;
            if(c.Account.Web_Id_NatFund__c != NULL && c.Account.Web_Id_NatFund__c != '' ){
                nfId = c.Account.Web_Id_NatFund__c;
            }
            else{
                System.debug('Account Web Id::::::::> ' + c.Account.National_Funding_WebId__c);
                nfId = c.Account.National_Funding_WebId__c;
            }
            contactList.Add(new ContactWrapper(c, (c.Email != null)));
            system.debug('contactList:: ' + contactList);
        }
    }

    public pageReference SendEmail(){
        String emailValue;
        Opportunity oppty = [SELECT StageName FROM Opportunity WHERE Id = :opportunityID];
        if(oppty.StageName == 'Approved - MCA' || oppty.StageName == 'Offer Out - MCA') {
            try {
                Integer selectedcontactList = 0;
                for (ContactWrapper c : contactList) {
                    if (c.IsSelected == true) {
                        if (c.theContact.HasOptedOutOfEmail) {
                            throw new GenericException(c.theContact.Name + ' has opted out of email at this time');
                        }
                        contactID = c.theContact.Id;
                        emailValue = c.theContact.Email;
                        if (c.theContact.Email == null) {
                            throw new GenericException('Please provide email address for: ' + c.theContact.Name);
                        }

                        if (nfId == null) {
                            throw new GenericException('Missing NF Web ID Please Update for: ' + c.theContact.Name);
                        } 
                        selectedcontactList++;
                    }
                }

                if (selectedcontactList == 0) {
                    throw new GenericException('Please select at least 1 contact');
                }

                String tokenCred;
                String qbTokenCred;
                String nfTokenCred;
                String brand;
                String sourceOrg = 'National Funding';
                Boolean userHasBothBrands = false;
                User userInfo = new User();
    
                Contact contactRec = [SELECT Id, Account.NF_Renewal_Rep__c, Account.OwnerId, Account.Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c 
                                    FROM CONTACT WHERE Id =: contactID];

                if(contactRec == null) {
                    throw new GenericException('Contact record cannot be found.');
                }
    
                if(contactRec.Account?.NF_Renewal_Rep__c != null) {
                    userInfo = [Select Id, Available_Brands__c From User Where Id =:contactRec.Account.NF_Renewal_Rep__c];
                } else if(contactRec.Account?.OwnerId != null) {
                    //owned by a user
                    if(contactRec.Account?.OwnerId.getsobjecttype() == User.sobjecttype){
                        userInfo = [Select Id, Available_Brands__c From User Where Id =:contactRec.Account.OwnerId];
                    } else {
                        //if not owned by a user, we are defaulting to generating both tokens
                        userHasBothBrands = true;
                    }
                }
            
                if(userInfo?.Available_Brands__c != null) {
                    if(userInfo?.Available_Brands__c.contains('Quick Bridge') && userInfo?.Available_Brands__c.contains('National Funding')) {
                        userHasBothBrands = true;
                    }
                    else if(userInfo.Available_Brands__c.contains('Quick Bridge')) {
                        brand = 'Quick Bridge';
                    }
                    else if(userInfo.Available_Brands__c.contains('National Funding')) {
                        brand = 'National Funding';
                    }
                } else {
                    brand = 'National Funding';
                }
        
                if(userHasBothBrands) {
                    qbTokenCred = ConsoleApplicationLinkController.getShortenedLink(contactRec.Id, nfID, sourceOrg, 'Quick Bridge');
                    nfTokenCred = ConsoleApplicationLinkController.getShortenedLink(contactRec.Id, nfId, sourceOrg, 'National Funding');
                    if(qbTokenCred.startsWith('This service is temporarily unavailable.') || nfTokenCred.startsWith('This service is temporarily unavailable.')){
                        throw new GenericException('This service is temporarily unavailable.');
                    }
                    HelperClass.upsertDFPToken(contactRec.Id, 'Quick Bridge', qbTokenCred);
                    HelperClass.upsertDFPToken(contactRec.Id, 'National Funding', nfTokenCred);
                    return new pageReference('/apex/DLPEmailLinkUpdateSvc?id=' + contactID + '&opportunityID=' + opportunityID + '&tokencred=' + nfTokenCred + '&data=Funding Email Sent&ptype=contact' + '&email=' + emailValue);
                }
                else {
                    tokencred = ConsoleApplicationLinkController.getShortenedLink(contactRec.Id, nfID, sourceOrg, brand); 
                    if(tokencred.startsWith('This service is temporarily unavailable.')){
                        throw new GenericException('This service is temporarily unavailable.');
                    }
                    HelperClass.upsertDFPToken(contactRec.Id, brand, tokencred);
                    return new pageReference('/apex/DLPEmailLinkUpdateSvc?id=' + contactID + '&opportunityID=' + opportunityID + '&tokencred=' + tokencred + '&data=Funding Email Sent&ptype=contact' + '&email=' + emailValue);
                }
            } catch (Exception ex) {
                Apexpages.addMessages(ex);
                return null;
            }
        }
        else {
            ApexPages.Message newMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity Stage is not Approved - MCA or Offer Out - MCA. Please go back and update before proceeding.');
            ApexPages.addMessage(newMsg);
            return null;
        }
    }

    public class ContactWrapper {
        public boolean isSelected { get; set; }
        public Contact theContact { get; set; }
        public boolean hasEmail { get; set; }

        public ContactWrapper(Contact c, boolean hasEmail){
            theContact = c;
            isSelected = false ;
            this.hasEmail = hasEmail;
        }
    }
}