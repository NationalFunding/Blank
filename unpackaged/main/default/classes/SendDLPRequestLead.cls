public with sharing class SendDLPRequestLead {

    private Apexpages.StandardController con;
    private Apexpages.StandardController ld;
    public List<LeadWrapper> Leads { get; set; }
    private Map<Id, Lead> contactsWithoutEmail;
    private transient List<Messaging.SingleEmailMessage> emails;
    public Id leadId;
    private Id templateId;
    private Id templateId2;
    public Id pLead;
    public String pName;
    public String nfId;
    public String encId;
    public String data {get;set;}
    
    public SendDLPRequestLead(Apexpages.StandardController con){
        this.con = con;
        leadId = this.con.getId();
        System.debug('Nat_Fund_WebId__c =======> ' + ApexPages.currentPage().getParameters().get('webId'));
        if(ApexPages.currentPage().getParameters().get('webId') == ''){ throw new GenericException('Missing NF Web ID Please Update for LeadId: ' + leadId); }
        Init();
    }

    private void Init(){
        Leads = new List<LeadWrapper>();
        contactsWithoutEmail = new Map<Id, Lead>();

        for(Lead c : [Select Id, Name, Email, Encrypted_Email_String__c, Web_Id_NatFund__c, National_Funding_WebId__c, DLP_Email_Status__c, HasOptedOutOfEmail  From Lead Where Id =: leadId]){
            System.debug('test c.iD ==>' + c.Id);
            pLead = c.Id;
            if(c.Web_Id_NatFund__c != NULL){
                nfId = c.Web_Id_NatFund__c;
                encId = c.Web_Id_NatFund__c;
            }
            else{
                nfId = c.National_Funding_WebId__c;
                encId = c.National_Funding_WebId__c;
            }
            Leads.Add(new LeadWrapper(c, (c.Email != null)));
        }
    }

    public List<SelectOption> getItems() {
        String e = [Select Id, DLP_Email_Status__c From Lead Where Id=: pLead].DLP_Email_Status__c;
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
            emails = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> et = [SELECT id FROM EmailTemplate WHERE developerName IN('Automated_Yodlee_Email', 'Loan_Modification_Request') Order By NAME asc];
            if(et.size() > 0){
                templateId = et[0].Id;
                System.debug('I am supposed to be new application' + templateId);
                templateId2 = et[1].Id;
            }

            integer selectedLeads = 0;
            //list for the contacts that didn't had email previously and user has just provided.
            List<Lead> contactEmailsToUpdate = new List<Lead>();

            string activityDescription = '--- Automated Yodlee Email ---';
            activityDescription += '\nSent to: ';
            for(LeadWrapper c : Leads){
                System.debug('contact y ' + c.Lead.Id);

                if(c.IsSelected == true){
                    if(c.Lead.HasOptedOutOfEmail) { throw new GenericException(c.Lead.Name + ' has opted out of email at this time'); }
                    pLead = c.Lead.Id;
                    pName = c.Lead.Name;

                    if(c.Lead.Email == null){
                        throw new GenericException('Please provide email address for: '+c.Lead.Name);
                        if(nfId == null){
                            throw new GenericException('Missing NF Web ID Please Update for: ' + c.Lead.Name);
                        }
                    } else if(!c.HasEmail) {
                        contactEmailsToUpdate.Add(c.Lead);
                    }
                    selectedLeads++;
                }
            }

            if(selectedLeads == 0){
                throw new GenericException('Please select atleast 1 lead');
            }

            //need to update these contacts, else the send email will not work with template targetId of contactId.
            if(contactEmailsToUpdate.size() > 0){
                update contactEmailsToUpdate;
            }

            List<Bank_Data__c> bankDataToUpdate = new List<Bank_Data__c>();
            integer selectedBanks = 0;
            activityDescription += '\nBank Accounts requested access to: ';

            String tokenCred;
            String qbTokenCred;
            String nfTokenCred;
            String brand;
            String sourceOrg = 'National Funding';
            Boolean userHasBothBrands = false;
            User userInfo = new User();

            Lead leadRec = [SELECT Id, OwnerId, Web_Id_NatFund__c, Originating_Brand__c, Encrypted_Email_String_Refresh_Date__c FROM LEAD WHERE Id =: pLead];
            if(leadRec == null) { throw new GenericException('Lead record cannot be found.'); }

            if(leadRec.ownerId != null) {
                //owned by a user
                if (leadRec.OwnerId.getSObjectType() == Schema.User.SObjectType) {
                    userInfo = [Select Id, Available_Brands__c From User Where Id =:leadRec.OwnerId];
                    if(userInfo?.Available_Brands__c != null) {
                        if(userInfo.Available_Brands__c.contains('Quick Bridge') && userInfo.Available_Brands__c.contains('National Funding')) {
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
                }
                else {
                    //if not owned by a user, we are checking the originating brand field on lead and if that is null, we are defaulting to generating both tokens
                    if(leadRec.Originating_Brand__c != null) {
                         brand = leadRec.Originating_Brand__c;
                    } else {
                        userHasBothBrands = true;
                    }
                }
            }

            if(userHasBothBrands) {
                qbTokenCred = ConsoleApplicationLinkController.getShortenedLink(pLead, nfId, sourceOrg, 'Quick Bridge');
                nfTokenCred = ConsoleApplicationLinkController.getShortenedLink(pLead, nfId, sourceOrg, 'National Funding');
                if(qbTokenCred.startsWith('This service is temporarily unavailable.') || nfTokenCred.startsWith('This service is temporarily unavailable.')){
                    throw new GenericException('This service is temporarily unavailable.');
                }
                HelperClass.upsertDFPToken(pLead, 'Quick Bridge', qbTokenCred);
                HelperClass.upsertDFPToken(pLead, 'National Funding', nfTokenCred);
                return new pageReference('/apex/DLPEmailLinkUpdateSvc?id='+pLead+'&tokencred='+nfTokenCred+'&data='+data+'&ptype=lead');
            }
            else {
                tokencred = ConsoleApplicationLinkController.getShortenedLink(pLead, nfId, sourceOrg, brand); 
                if(tokencred == 'This service is temporarily unavailable.') {
                    throw new GenericException('This service is temporarily unavailable. ');
                }
                HelperClass.upsertDFPToken(pLead, brand, tokencred);
                return new pageReference('/apex/DLPEmailLinkUpdateSvc?id='+pLead+'&tokencred='+tokencred+'&data='+data+'&ptype=lead');
            }
        } catch (Exception ex) {
            Apexpages.addMessages(ex);
            return null;
        }
    }

    //********************************************************************************************
    public class LeadWrapper {
        public boolean IsSelected { get; set; }
        public Lead Lead { get; set; }
        public boolean HasEmail { get; set; }

        public LeadWrapper(Lead c, boolean hasEmail){
            Lead = c;
            IsSelected = true;
            this.HasEmail = hasEmail;
        }
    }
}