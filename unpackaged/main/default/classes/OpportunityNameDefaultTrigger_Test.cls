/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OpportunityNameDefaultTrigger_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
       
        List<RecordType> recordTypeDetails = [Select Name, Description From RecordType where SobjectType='Opportunity'];
        Id recordTypeId1 = recordTypeDetails.get(0).id;
        
        List<RecordType> accrecordTypeDetail1s = [Select Name, Description From RecordType where SobjectType='Account'];
        Id recordTypeId2 = accrecordTypeDetail1s.get(0).id;
        
        Account acc = new Account();
        acc.RecordTypeId = recordTypeId2;
        acc.Name = 'Test1';
        acc.Phone ='12345';
        acc.Type ='Customer';
        insert acc;
        system.debug('OP:: acc1:: ' + acc);
          
//        Opportunity opptemp1 = new Opportunity();
//        opptemp1.AccountId = acc.Id;
//        opptemp1.StageName = 'Approved - Lease';
//        opptemp1.CloseDate = system.today();
//        opptemp1.RecordTypeId = recordTypeId1;
//        insert opptemp1;
//        system.debug('OP:: opptemp11:: ' + opptemp1); //this is not being inserted

        List<Opportunity> oOpp = [Select Name,Id,RecordTypeId from Opportunity Where AccountId = :acc.id and RecordTypeId = :recordTypeId1];
        String sCount = '0';
        String strOppName;
        sCount = String.ValueOf(oOpp.size()+1);
        strOppName = acc.Name + ' ' + recordTypeDetails.get(0).Name + ' Deal #' + ' '+sCount ;
        Opportunity opptemp = new Opportunity();
        opptemp.AccountId = acc.Id;
        opptemp.StageName = 'Approved - Lease';
        opptemp.CloseDate = system.today();
        opptemp.RecordTypeId = recordTypeId1;
        opptemp.Loan_Start_Date__c = Date.today();
        insert opptemp;
        system.debug('OP:: opptemp1:: ' + opptemp); //this is not being inserted

        Opportunity theOpp = [Select Name,Id,RecordTypeId from Opportunity Where id=:opptemp.Id];

        System.assertEquals(theOpp.Name,strOppName);
          
    }
    /*
        The following Testmethod for testing code coverage for OpportunityCountOnAccount
    
    */
       
   public static TestMethod void TestOpportunityCountOnAccount(){
        Id leaseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Oppty').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test1';
        acc.Phone ='12345';
        acc.Type ='Customer';
        insert acc;
        System.assertEquals(null , [select LP_Cust_Number__c from Account where id = : acc.id].LP_Cust_Number__c);
        system.debug('OP:: acc:: ' + acc);

        Opportunity opptemp1 = new Opportunity();
        opptemp1.AccountId = acc.Id;
        opptemp1.StageName = 'Funded';
        opptemp1.type = 'New';
        opptemp1.CloseDate = system.today();
        opptemp1.Residual_Assigned_To__c = 'No Residual';
        opptemp1.RecordTypeId = leaseRecordTypeId;
        opptemp1.Lease_Deposit_Check_Received__c = true ;
        insert opptemp1;
        acc = [select LP_Cust_Number__c from Account where id = : acc.id];
        System.assertNotEquals(null , acc.LP_Cust_Number__c);
        system.debug('OP:: opptemp1:: ' + opptemp1);

//        //Test Case2
//        Opportunity opptemp2 = new Opportunity();
//        opptemp2.AccountId = acc.Id;
//        opptemp2.StageName = 'Funded';
//        opptemp2.type = 'New';
//        opptemp2.CloseDate = system.today();
//        opptemp2.RecordTypeId = leaseRecordTypeId;
//        opptemp2.Lease_Deposit_Check_Received__c = true ;
//        insert opptemp2;
//        system.debug('OP:: opptemp2:: ' + opptemp2); //this is not being inserted
        
        System.assertEquals(acc.LP_Cust_Number__c , [select LP_Cust_Number__c from Account where id = : acc.id].LP_Cust_Number__c);
        
    }
}