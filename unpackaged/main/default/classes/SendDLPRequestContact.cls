public with sharing class SendDLPRequestContact {

    private Apexpages.StandardController con;
    public List<ContactWrapper> Contacts { get; set; }
    private Map<Id, Contact> contactsWithoutEmail;
    private transient List<Messaging.SingleEmailMessage> emails;
    public Id accountId;
    public string type;
    private Id templateId;
    private Id templateId2;
    public Id contactID;
    public String pName;
    public String nfID;
    public Boolean flag = false;
    public String statusOptions { get; set; }
    public String data {get;set;}
    public String emailValue {get; set;}

    public SendDLPRequestContact(Apexpages.StandardController con){
        this.con = con;
        accountId = this.con.getId();

        Init();
    }

    private void Init(){
        Contacts = new List<ContactWrapper>();
        contactsWithoutEmail = new Map<Id, Contact>();
        for(Contact c : [Select Id, Name, Email, DLP_Email_Status__c, AccountId, Account.Web_Id_NatFund__c, Account.National_Funding_WebId__c, HasOptedOutOfEmail From Contact Where AccountId =: accountId ]){
            contactID = c.Id;
            pName = c.Name;
            //      counter ++;
            if(c.Account.Web_Id_NatFund__c != NULL && c.Account.Web_Id_NatFund__c != '' ){
                nfId = c.Account.Web_Id_NatFund__c;
            }
            else{
                System.debug('Account Web Id::::::::> ' + c.Account.National_Funding_WebId__c);
                nfId = c.Account.National_Funding_WebId__c;
                flag = true;
            }
            Contacts.Add(new ContactWrapper(c, (c.Email != null)));
        }
    }
    
    public static List<SelectOption> getItems(String e) {
        if(e == NULL  || e == 'DLP Email Sent' ){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('DLP Email Sent','Not Active'));
            options.add(new SelectOption('DLP Drip Activated','Start'));
            return options;
        }
        if(e == 'DLP Drip Activated'){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('DLP Drip Activated','Activated'));
            options.add(new SelectOption('DLP Drip Deactivated','Stop'));
            return options;
        }
        else{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('DLP Drip Deactivated','Deactivated'));
            options.add(new SelectOption('DLP Drip Activated','Start'));
            return options;
        }
    }

    public pageReference SendEmail(){
        try {            
            Integer selectedContacts = 0;
            for(ContactWrapper c : Contacts){
                if(c.IsSelected == true){
                    if(c.Contact.HasOptedOutOfEmail){
                        throw new GenericException(c.Contact.Name + ' has opted out of email at this time');
                    }
                    contactID = c.Contact.Id;
                    data = c.picklistdata;
                    emailValue = c.Contact.Email;
                    if(c.Contact.Email == null){
                        throw new GenericException('Please provide email address for: '+c.Contact.Name);
                        if(nfId == null){
                            throw new GenericException('Missing NF Web ID Please Update for: ' + c.Contact.Name);
                        }
                    } 
                    selectedContacts++;
                }
            }

            if(selectedContacts == 0){
                throw new GenericException('Please select atleast 1 contact');
            }

            String tokenCred;
            String qbTokenCred;
            String nfTokenCred;
            String brand;
            String sourceOrg = 'National Funding';
            Boolean userHasBothBrands = false;
            User userInfo = new User();

            Contact contactRec = [SELECT Id, Account.NF_Renewal_Rep__c, Account.OwnerId, Account.Web_Id_NatFund__c, Encrypted_Email_String_Refresh_Date__c 
                                FROM CONTACT WHERE Id =: contactId];
            if(contactRec == null) {
                throw new GenericException('Contact record cannot be found.');
            }

            if(contactRec.Account?.NF_Renewal_Rep__c != null) {
                userInfo = [Select Id, Available_Brands__c From User Where Id =:contactRec.Account.NF_Renewal_Rep__c];
            } else if(contactRec.Account?.OwnerId != null) {
                //owned by a user
                if(contactRec.Account?.OwnerId.getsobjecttype() == Schema.User.SObjectType){
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
                return new pageReference('/apex/DLPEmailLinkUpdateSvc?id='+contactID+'&tokencred='+nfTokenCred+'&data='+data+'&ptype=contact'+'&email='+emailValue);
            }
            else {
                tokencred = ConsoleApplicationLinkController.getShortenedLink(contactRec.Id, nfID, sourceOrg, brand); 
                if(tokencred.startsWith('This service is temporarily unavailable.')){
                    throw new GenericException('This service is temporarily unavailable.');
                }
                HelperClass.upsertDFPToken(contactRec.Id, brand, tokenCred);
                return new pageReference('/apex/DLPEmailLinkUpdateSvc?id='+contactID+'&tokencred='+tokencred+'&data='+data+'&ptype=contact'+'&email='+emailValue);

            }
        
        } catch (Exception ex) {
            Apexpages.addMessages(ex);
            return null;
        }
    }

    public class ContactWrapper {
        public boolean IsSelected { get; set; }
        public Contact Contact { get; set; }
        public boolean HasEmail { get; set; }
        public List<SelectOption> picklistFields {get; set;}
        public String picklistdata {get; set;}

        public ContactWrapper(Contact c, boolean hasEmail){
            Contact = c;
            IsSelected = false ;
            this.HasEmail = hasEmail;
            picklistFields = SendDLPRequestContact.getItems(c.DLP_Email_Status__c);
            this.picklistData = picklistdata;
        }
    }
}