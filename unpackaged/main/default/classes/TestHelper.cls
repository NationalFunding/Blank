public class TestHelper{

    public static void createCustomSettings(){
        List<filegen__Metadata_Segments__c> segments = filegen__Metadata_Segments__c.getAll().values();
        segments.add(new filegen__Metadata_Segments__c(Name='Addenda',filegen__Segment__c='filegen__Addenda_Record__c'));
        segments.add(new filegen__Metadata_Segments__c(Name='Batch Control Record',filegen__Segment__c='filegen__Batch_Control_Record__c'));
        segments.add(new filegen__Metadata_Segments__c(Name='Batch Header Record',filegen__Segment__c='filegen__Batch_Header_Record__c'));
        segments.add(new filegen__Metadata_Segments__c(Name='Entry Detail Record',filegen__Segment__c='filegen__Entry_Detail_Record__c'));
        segments.add(new filegen__Metadata_Segments__c(Name='File Control Record',filegen__Segment__c='filegen__File_Control_Record__c'));
        segments.add(new filegen__Metadata_Segments__c(Name='File Header Record',filegen__Segment__c='filegen__File_Header_Record__c'));
        
        insert segments;
        /*
        NF_ACH_Info__c param = NF_ACH_Info__c.getInstance();
        param.ACH_ID__c = '4TGD2211';
        param.Bank_Account_Number__c = '33333';
        param.Bank_ACH_Code__c = 'BOFACHCD';
        param.Bank_Name__c = 'Bank of America';
        param.Company_Entry_Description__c = 'PAYMENT';
        param.Company_Name__c = 'National Funding';
        param.Fed_Tax_Id__c = '4TGD2211';
        param.Folder_Name__c='Shared Folder for ACH';
        param.Routing_Number__c='823291211';
        param.Standard_Entry_Class__c='PPD';
        
        insert param;*/
    }
    public static Bank_Account__c createBankAccount(){
        RecordType rt = [select id ,Name from RecordType where SObjectType = 'Bank_Account__c' and Name = 'Organization'];
        Bank_Account__c bank = new Bank_Account__c();
        bank.ACH_ID__c = '4TGD2211';
        bank.Bank_Account_Number__c = '33333';
        bank.Bank_ACH_Code__c = 'BOFACHCD';
        bank.Bank_Name__c = 'Bank of America';
        bank.Company_Entry_Description__c = 'PAYMENT';
        bank.Company_Name__c = 'National Funding';
        bank.Fed_Tax_Id__c = '4TGD2211';
        bank.Folder_Name__c='Shared Folder for ACH';
        bank.Routing_Number__c='823291211';
        bank.Standard_Entry_Class__c='PPD';
        bank.recordTypeId = rt.Id;
		bank.Payee_s_Name__c = 'test';
        bank.Receiving_Company_Name__c = 'test';
        bank.Bank_Account_Type__c = 'Checking';
        insert bank;
        return bank;
    }
    
    public static Bank_Account__c createPayeeBankAccount(){
        RecordType rt = [select id ,Name from RecordType where SObjectType = 'Bank_Account__c' and Name = 'Broker'];
        Bank_Account__c bank = new Bank_Account__c();
        bank.ACH_ID__c = '4TGD2211';
        bank.Bank_Account_Number__c = '33333';
        bank.Bank_ACH_Code__c = 'BOFACHCD';
        bank.Bank_Name__c = 'Bank of America';
        bank.Company_Entry_Description__c = 'PAYMENT';
        bank.Company_Name__c = 'National Funding';
        bank.Fed_Tax_Id__c = '4TGD2211';
        bank.Folder_Name__c='Shared Folder for ACH';
        bank.Routing_Number__c='823291211';
        bank.Standard_Entry_Class__c='PPD';
        bank.recordTypeId = rt.Id;
        bank.Payee_s_Name__c = 'test';
        bank.Receiving_Company_Name__c = 'test';
        bank.Bank_Account_Type__c = 'Checking';
        insert bank;
        return bank;
    }
    
    public static Bank_Account__c createNFBankAccount(){
        RecordType rt = [select id ,Name from RecordType where SObjectType = 'Bank_Account__c' and Name = 'Organization'];
        Bank_Account__c bank = new Bank_Account__c();
        bank.ACH_ID__c = '4TGD2211';
        bank.Bank_Account_Number__c = '33333';
        bank.Bank_ACH_Code__c = 'BOFACHCD';
        bank.Bank_Name__c = 'Bank of America';
        bank.Company_Entry_Description__c = 'PAYMENT';
        bank.Company_Name__c = 'National Funding';
        bank.Fed_Tax_Id__c = '4TGD2211';
        bank.Folder_Name__c='Shared Folder for ACH';
        bank.Routing_Number__c='823291211';
        bank.Standard_Entry_Class__c='PPD';
        bank.recordTypeId = rt.Id;
        bank.National_Funding_Account__c = true;
        bank.Payee_s_Name__c = 'test';
        bank.Receiving_Company_Name__c = 'test';
        bank.Bank_Account_Type__c = 'Checking';
        insert bank;
        return bank;
    }
    
    public static ACH_Payment__c createDefaultACHPaymentRecord(){
        RecordType rt = [select id ,Name from RecordType where SObjectType = 'ACH_Payment__c' and Name = 'Default'];
        ACH_Payment__c payment = new ACH_Payment__c();
        payment.Organization_s_Bank_Account__c =  createBankAccount().id;
        payment.NF_Lease_Loan_Number__c = 'Test #1';
        payment.Receiving_Company_Name__c = 'Bill\'s Bobcats';
        payment.Payee_s_Routing_Number__c = '515151155';
        payment.Payee_s_Bank_Account_Number__c = '65465465464654654';
        payment.Payee_s_Bank_Name__c = 'Wells Fargo';
        payment.Payee_s_Account_Type__c = 'Checking';
        payment.Payee_s_Name__c = 'Bill Brasky';
        payment.Amount__c = 1000;
        payment.Pay_On_This_Date__c = Date.Today();
        payment.Create_ACH_File_Date__c = Date.today();
        payment.Payee_Bank_Account__c = createPayeeBankAccount().id;
        payment.Opportunity__c = createOpportunity().Id;
        payment.recordTypeId = rt.Id;
        
        insert payment;
        return payment;
    }
    
    
    public static ACH_Payment__c createBrokerACHPaymentRecord(){
        RecordType rt = [select id ,Name from RecordType where SObjectType = 'ACH_Payment__c' and Name = 'Broker/Internal'];
        ACH_Payment__c payment = new ACH_Payment__c();
        payment.Organization_s_Bank_Account__c =  createNFBankAccount().id;
        payment.NF_Lease_Loan_Number__c = 'Test #1';
        payment.Receiving_Company_Name__c = 'Bill\'s Bobcats';
        payment.Payee_s_Routing_Number__c = '515151155';
        payment.Payee_s_Bank_Account_Number__c = '65465465464654654';
        payment.Payee_s_Bank_Name__c = 'Wells Fargo';
        payment.Payee_s_Account_Type__c = 'Checking';
        payment.Payee_s_Name__c = 'Bill Brasky';
        payment.Amount__c = 1000;
        payment.Pay_On_This_Date__c = Date.Today();
        payment.Create_ACH_File_Date__c = Date.today();
        payment.Payee_Bank_Account__c = createBankAccount().id;
        payment.Opportunity__c = createOpportunity().Id;
        payment.recordTypeId = rt.Id;
        
        insert payment;
        return payment;
    }
    public static Opportunity createOpportunity(){
        Opportunity oppt = new Opportunity();
        oppt.Account = createAccount();
        oppt.Name = 'Ach Testing Account 2 Lease Oppty Deal #4';
        oppt.Type = 'NEW';
        oppt.Amount = 10000;
        oppt.StageName = 'Funded';
        oppt.Probability = 100;
        oppt.CloseDate = Date.Today();
        oppt.Use_of_Funds__c = 'Equipment Purchase';
        oppt.Lender_Doc_Fee_For_Actual__c = 0;
        oppt.Residual_Assigned_To__c = 'No Residual';
        
        insert oppt;
        return oppt;
    }
    
    public static Account createAccount(){
        Account acct = new Account();
        acct.Name='Ach Testing Account 3';
        acct.Type='Customer';
        insert acct;
        return acct;    
    }
    
}