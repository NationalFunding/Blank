@isTest
public class OpportunityCountOnAccountTest {
    
    @isTest
    static void testInsertOpportunityWithOtherStage() {
        Account testAccount = TestDataFactory.createAccount();
        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        testOpportunity.StageName = 'Prospecting';
        insert testOpportunity;
        
        List<Opportunity> relatedOpportunities = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :testAccount.Id];
        //this stagename should not allow the trigger logic to run
        System.assertEquals(null, testAccount.LP_Cust_Number__c, 'This value should not have been updated.');
    }

    @isTest
    public static void testInsertOpportunityToFundedStage(){
        Id EPPRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EPP Oppty').getRecordTypeId();

        Id recordType = schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Broker WC Oppty').getRecordTypeId();
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE Id =:EPPRecordTypeId];
        Contact c = new Contact(LastName = 'TestLn');
        insert c;
        
        List<RecordType> accountReportType = [Select SobjectType, Name, Id From RecordType  where SobjectType ='Account' and Name ='Lender Acct'];
        Id LenderAccRecordTypeID = accountReportType.get(0).id;
        Account theAccountRelatedWithFunding = new Account();
        theAccountRelatedWithFunding.RecordTypeId = LenderAccRecordTypeID;
        theAccountRelatedWithFunding.Name ='Ted\' test for actual funding'; 
        theAccountRelatedWithFunding.Phone = '654321';
        theAccountRelatedWithFunding.Type = 'Customer';
        theAccountRelatedWithFunding.Type = 'Lender - MCA';
        insert theAccountRelatedWithFunding;
        
        Account acc = new Account(SICCODE__c = '123', AnnualRevenue = 100.0, Name='Testing Account', Legal_Name__c = 'Test', Legal_Status__c = 'Corporation');
        insert acc;
        
        FPC_Address__c address = new FPC_Address__c(Account__c = acc.Id, Contact__c = c.Id, State__c = 'CA', City__c = 'San Diego', Zip_Code__c = '92109', Address_1__c = '123 test');
        insert address;
        
        Opportunity oppty = new Opportunity(
            Addr_Bill1__c = address.Id,
            name='wendy test',
            Lender_Account__c = theAccountRelatedWithFunding.Id,
            StageName = 'Identified',
            CloseDate=System.today(),
            Type = 'NEW',
            RecordTypeId = EPPRecordTypeId,
            AccountId=acc.id,
            EPP_Equip_LP__c = true,
            EPP_Equip_PO_to_Accounting__c = true,
            BofI_Deal__c = 'Yes',
            Residual_Assigned_To__c = 'Lender '
        );
        insert oppty;
        
        FPC_Funding_del__c fd = new FPC_Funding_del__c(Opportunity__c = oppty.Id, CalculatorLink__c = 'test');
        insert fd;
        Credit_Review__c cr = new Credit_Review__c(Related_Funding_Record__c = fd.Id, SIC_Code__c = '123', Annual_Revenue__c = 132, Status__c = 'In Progress', Opportunity__c = oppty.Id, Broker_Preferred_Email__c = 'oporter@nationalfunding.com', Paydex__c= 999 );
        insert cr;
        Credit_Review__c cc = new Credit_Review__c(Id=cr.Id, Status__c = 'Approved');
        update cc;
        
        oppty.StageName = 'Funded';
        update oppty;
        
        acc = [select LP_Cust_Number__c from Account where id = : acc.id];
        System.assertNotEquals(null , acc.LP_Cust_Number__c);
        System.assertEquals(acc.LP_Cust_Number__c , [select LP_Cust_Number__c from Account where id = : acc.id].LP_Cust_Number__c);
    }

}