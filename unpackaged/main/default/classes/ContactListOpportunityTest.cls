@isTest
public class ContactListOpportunityTest {

  @isTest
  static void getCMDTSignorRole(){
        Test.startTest();
            // Call the method that retrieves the CMDT role
            List<String> cmdtRole = ContactListOpportunity.getMainOppContactRole();
       	Test.stopTest();

        system.assertNotEquals(null, cmdtRole);
  }
    
  @isTest
  static void getOpportunityContactsTest(){
      
      // Create Account
      Account a = new Account(Name = 'CompanyName');
      insert a;
      system.debug('Account Id: ' + a.id);
      
      // Create Opportunity
      Opportunity o = new Opportunity(Name = 'OpportunityName', StageName = 'Stage1', CloseDate = date.today(), AccountId = a.id);
      insert o;
      system.debug('Opportunity Id: ' + o.id);

      // Create Contact
      Contact c = new Contact(lastname = '11', AccountId = a.id, MobilePhone = '9999999999');
      insert c;
      system.debug('Contact Id: ' + c.id);
      
      // Create OpportunityContactRole
      OpportunityContactRole ocr = new OpportunityContactRole(ContactId = c.id, OpportunityId = o.id, Role = 'Role', IsPrimary = True);
      insert ocr;
      system.debug('OpportunityContactRole Id: ' + ocr.id);

      TwilioSF__Opt_In_Keyword__c keyword = new TwilioSF__Opt_In_Keyword__c(Name = 'Start');
      insert keyword;

      DateTime todaysDate = Datetime.now();
      TwilioSF__Opt_In__c optIn = new TwilioSF__Opt_In__c(TwilioSF__Opt_In_Keyword__c = keyword.Id, TwilioSF__Phone_Number__c= '9999999999',  TwilioSF__Active__c = true, TwilioSF__Contact__c = c.Id, TwilioSF__Opt_In_Date_Time__c = todaysDate, TwilioSF__Opt_In_Phone_Number_Unformatted__c = '9999999999'  );
      insert optIn;
      
      // Confirm Opportunity Contact Roles are Returned
      list <Object> opportunityContactRoles = ContactListOpportunity.getOpportunityContacts(a.id, o.id);
      
      system.assertNotEquals(null, opportunityContactRoles);
  } 
}