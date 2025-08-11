@IsTest
public class TestDataFactory {

    //Account creation
    public static List<Account> createAccounts( Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        for ( Integer i = 1 ; i <= numberOfAccounts ; i++ ) {
            
            Account account = new Account( Name='Test Acc'+i);
            accounts.add( account);

        }
        return accounts;
    }
    
    public static Account createAccount() {
        return createAccounts(1)[0];
    }
    
    //Contact creation
    public static List<Contact> createContacts( Integer numberOfContacts, Id accId) {
        List<Contact> contacts = new List<Contact>();
        for ( Integer i = 1 ; i <= numberOfContacts ; i++ ) {
            
            Contact con = new Contact( FirstName='Test', LastName='Con'+i, AccountId=accId);
            contacts.add(con);

        }
        return contacts;
    }
    
    public static Contact createContact(String lastName, Id accId) {
        return createContacts(1, accId)[0];
    }
    
    //Opportunity creation
    public static List<Opportunity> createOpportunities(Integer numberOfOpps, Id accId, Id recType, Date closeDt) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for ( Integer i = 1 ; i <= numberOfOpps ; i++ ) {
            opportunities.add(new Opportunity(
                Name = 'Test Opp'+i,
                AccountId = accId,
                RecordTypeId =  recType,
                Type = 'NEW',
                Amount = 100,
                StageName = 'Identified',
                Use_of_Funds__c = 'Other',
                CloseDate = closeDt,
                Merchant_Number__c = '00' + i
            ));
        }
        return opportunities;
    }
    
    public static Opportunity createOpportunity(Id accId){
        Id recordTypeId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfos().get(1).getRecordTypeId();
        return createOpportunities(1, accId, recordTypeId, System.today())[0];
    }
    
    //OpportunityContactRole creation
    public static List<OpportunityContactRole> createOpportunityContactRoles( Integer numberOfRoles, Id oppId, Id conId, String role) {
        List<OpportunityContactRole> oppConRoles = new List<OpportunityContactRole>();
        for ( Integer i = 1 ; i <= numberOfRoles ; i++ ) {
            
            OpportunityContactRole oppConRole = new OpportunityContactRole( OpportunityId=oppId, ContactId=conId, Role=role);
            oppConRoles.add(oppConRole);

        }
        return oppConRoles;
    }
    
    //Case creation
    public static List<Case> createCases( Integer numberOfCases, Id accId, Id conId, Id oppId, Id recType){
        List<Case> cases = new List<Case>();
        for ( Integer i = 1 ; i <= numberOfCases ; i++ ) {
            
            Case c = new Case();
            c.AccountId = accId;
            c.ContactId = conId;
            c.Opportunity__c = oppId;
            c.Priority = 'Medium';
            c.Origin = 'Internal';
            c.Status = 'Unassigned'; 
            c.RecordTypeId = recType;

            cases.add(c);

        }
        return cases;

    }
    
    //advpm__Matter__c creation
    public static List<advpm__Matter__c> createMatters( Integer numberOfMatters, Id accId, Id conId, Id caseId, Id recType){
        List<advpm__Matter__c> matterList = new List<advpm__Matter__c>();
        for ( Integer i = 1 ; i <= numberOfMatters ; i++ ) {
            
            advpm__Matter__c matter = new advpm__Matter__c(
                                            Name = 'Test Signor-Problem',
                                            Case__c = caseId,
                                            advpm__Primary_Account__c = accId,
                                            advpm__Primary_Contact__c = conId,
                                            RecordTypeId = recType
            );

            matterList.add(matter);

        }
        return matterList;
    }
    
    public static cmbls__Repayment__c createRepayment(Id accId){
        return new cmbls__Repayment__c(
            cmbls__Status__c = 'Active',
            cmbls__Payee_Account__c = accId,
            cmbls__Funding_Amount__c = 10204.08,
            cmbls__Intial_Repayment_Amount__c = 10204.08,
            cmbls__Current_Interest_Rate__c = 0.0710,
            cmbls__Original_Interest_Rate__c = 0.0710,
            cmbls__Payments_Updated__c = true,
            cmbls__Payment_Amount__c = NumberUtils.getDecimal(10204.08),
            cmbls__Payment_Frequency__c = 'Monthly',
            cmbls__Funded_Date__c = Date.today().addDays(-120),
            cmbls__Term_Days_Default__c = 120,
            cmbls__Bank_Name__c = '123123',
            cmbls__ACH_Processor__c = 'Texas Capital Bank',
            cmbls__Bank_Account_Number__c = '123123',
            cmbls__Type_of_Account__c = 'Savings',
            cmbls__Bank_Routing_Number__c = '123123123',
            cmbls__Is_Interest_Based_Loan__c = true,
            cmbls__Interest_Accrual_Method__c = '365/360',
            cmbls__Fee_Group__c = 'Default',
            Merchant_Number__c = '878787'
        );
    }
    
    public static cmbls__Repayment_Schedule__c createRepaymentSchedule(Id repaymentId){
        return new cmbls__Repayment_Schedule__c(
            cmbls__Repayment__c = repaymentId,
            cmbls__Start_Date__c = System.today()
        );
    }

    public static cmbls__Amortization_Schedule__c createAmortizationSchedule(Id repaymentId, Decimal amount){
        return new cmbls__Amortization_Schedule__c(
            cmbls__Repayment__c = repaymentId,
            cmbls__Payment_Amount__c = amount,
            cmbls__Date__c = System.today()
        );
    }
    
    public static Bank_Account__c createBankAccount(){
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Bank_Account__c' AND Name = 'Organization'];
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
        bank.RecordTypeId = rt.Id;
        bank.Payee_s_Name__c = 'test';
        bank.Receiving_Company_Name__c = 'test';
        bank.Bank_Account_Type__c = 'Checking';
        return bank;
    }
    
    public static ACH_Payment__c createDefaultACHPaymentRecord(Id accId, Id oppId, Id bankAccountId){
        RecordType rt = [SELECT Id ,Name FROM RecordType WHERE SobjectType = 'ACH_Payment__c' AND Name = 'Default'];
        ACH_Payment__c payment = new ACH_Payment__c();
        payment.Organization_s_Bank_Account__c =  bankAccountId;
        payment.NF_Lease_Loan_Number__c = 'Test #1';
        payment.Receiving_Company_Name__c = 'Bill\'s Bobcats';
        payment.Payee_s_Routing_Number__c = '515151155';
        payment.Payee_s_Bank_Account_Number__c = '65465465464654654';
        payment.Payee_s_Bank_Name__c = 'Wells Fargo';
        payment.Payee_s_Account_Type__c = 'Checking';
        payment.Payee_s_Name__c = 'Bill Brasky';
        payment.Amount__c = 1000;
        payment.Payment_Type__c = 'Axos - Lender Payoff';
        payment.Pay_On_This_Date__c = Date.today();
        payment.Create_ACH_File_Date__c = Date.today();
        payment.Payee_Bank_Account__c = bankAccountId;
        payment.Opportunity__c = oppId;
        payment.RecordTypeId = rt.Id;
        return payment;
    }

    public static cmbls__Invoice__c createInvoice(Id repId, Date invoiceDate){
        cmbls__Invoice__c invoice = new cmbls__Invoice__c(
            cmbls__Invoice_Date__c = invoiceDate,
            cmbls__Repayment__c = repId
        );
        return invoice;
    }

    public static cmbls__Invoice_Line_Item__c createInvoiceLineItem(Decimal amount, Date paidDate, Id invoiceId){
        cmbls__Invoice_Line_Item__c invoiceLineItem = new cmbls__Invoice_Line_Item__c(
            cmbls__Effective_Date__c = paidDate,
            cmbls__Amount_Paid__c = amount,
            cmbls__Invoice__c = invoiceId
        );
        return invoiceLineItem;
    }

    public static WF_Api_Settings__c wfSettings(){
        return new WF_Api_Settings__c(
                WF_CONSUMER_KEY__c = '123',
                WF_COMPANY_ID__c =  '2213547186',
                WF_CONSUMER_SECRET__c = '123',
                WF_PAYMENTS_CREATE_URL__c = 'url',
                WF_TOKEN_URL__c = 'url',
                Save_Communication_Logs__c = true,
                Error_Codes_To_Resubmit_Request__c = '*500;400-001',
                Max_Number_of_attempts__c = 10,
                WF_CHECK_NOTIFICATIONS_URL__c = 'https://test.com',
                Gateway_Entity_Id__c = '2213547186'
        );
    }

    public static cmbls__Payment__c createPayment(Id repaymentId, String recordTypeName, String status, Decimal amount, Date effectiveDate, String processor){
        String recordTypeId = Schema.SObjectType.cmbls__Payment__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return new cmbls__Payment__c(
                cmbls__Repayment__c = repaymentId,
                RecordTypeId = recordTypeId,
                cmbls__Status__c = status,
                cmbls__Transaction_Amount__c = amount,
                cmbls__Effective_Date__c = effectiveDate,
                cmbls__ACH_Processor__c = processor
        );
    }

    public static cmbls__Disbursement__c createDisbursement(String recordTypeName, String status, String processor){
        String recordTypeId = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return new cmbls__Disbursement__c(
                RecordTypeId = recordTypeId,
                cmbls__Status__c = status,
                cmbls__Effective_Date__c = Date.today(),
                cmbls__Transaction_Amount__c = 100,
                cmbls__ACH_Processor__c = processor
        );
    }

    public static cmbls__ACH_Batch__c createACHBatch(String providerName, String status, Date effectiveDate) {
        cmbls__ACH_Batch__c batch = new cmbls__ACH_Batch__c();
        batch.cmbls__ACH_Provider_Name__c = providerName;
        batch.cmbls__Status__c = status;
        batch.cmbls__Effective_Date__c = effectiveDate;
        return batch;
    }

    public static cmbls__Disbursement_Batch__c createDisBatch(String providerName, String status, Date effectiveDate) {
        cmbls__Disbursement_Batch__c batch = new cmbls__Disbursement_Batch__c();
        batch.cmbls__ACH_Provider_Name__c = providerName;
        batch.cmbls__Status__c = status;
        batch.cmbls__Effective_Date__c = effectiveDate;
        return batch;
    }

    public static ACH_Transaction_Log__c createACHTransactionLog(Id parentRecord, String status){
        ACH_Transaction_Log__c achLog = new ACH_Transaction_Log__c(
            Status__c = status
        );
        if(parentRecord.getSobjectType().getDescribe().getName() == cmbls__Disbursement__c.getSObjectType().getDescribe().getName()){
            achLog.Disbursement__c = parentRecord;
        }else if(parentRecord.getSobjectType().getDescribe().getName() == cmbls__Payment__c.getSObjectType().getDescribe().getName()){
            achLog.Payment__c = parentRecord;
        }
        return achLog;
    }
    
    public static cmbls__InterestAccrual__c createInterestAccrual(Id repaymentId, Decimal amount, Date startDate, Date endDate){
        return new cmbls__InterestAccrual__c(
            cmbls__Repayment__c = repaymentId,
            cmbls__Interest_Amount_for_Principal_for_Period__c = amount,
            cmbls__Start_Date__c = startDate,
            cmbls__End_Date__c = endDate,
            cmbls__Effective_Interest_Days__c = startDate.daysBetween(endDate)
        );
    }
    
    public static cmbls__Fund__c createFund(String recordName, cmbls__Banking_Information__c bankingInformation){
        return new cmbls__Fund__c(
            Name = recordName,
            cmbls__Default_Credit_ACH_Processor__c = Constant.ACH_PROCESSOR_NF_FUNDING,
            cmbls__Default_Debit_ACH_Processor__c = Constant.ACH_PROCESSOR_NF_FUNDING,
            cmbls__Bank_Account_for_Loan_Transfers__c = bankingInformation.Id
        );
    }
    
    public static cmbls__Banking_Information__c createBankingInformation(Id accountId){
        return new cmbls__Banking_Information__c(
            cmbls__Bank_Account_Number__c = '1212',
            cmbls__Bank_Routing__c = '999999963',
            cmbls__Account__c = accountId,
            cmbls__Bank_Account_Type__c = 'Checking'
        );
    }

    public static Chart_of_Account__c createChartOfAccount(String objectAPIName, String fieldAPIName, String fundLookup){
        return new Chart_of_Account__c(
            Object_API_Name__c = objectAPIName,
            GL_Account_Field_API_Name__c = fieldAPIName,
            FRPS2__c = 'FRPS2__c - 222222',
            FRPSA__c = 'FRPSA__c - 333333',
            LOAN__c = 'LOAN__c - 444444',
            NFAS2__c = 'NFAS2__c - 555555',
            QBF__c = 'QBF__c - 666666',
            QBF_FRPSA__c = 'QBF_FRPSA__c - 777777',
            QBtoNF__c = 'QBtoNF__c - 888888',
            NFtoNFAS2__c = 'NFtoNFAS2__c - 999999',
            Fund_Lookup__c = fundLookup
        );
    }
    
    public static Chart_of_Account_Key__c createChartOfAccountKey(Id fundId, String productType, String key){
        return new Chart_of_Account_Key__c(
            Key__c = key,
            Product_Type__c = productType,
            Company__c = fundId
        );
    }
    
    public static cmbls__Expense__c createExpense(Id repaymentId, String type, Decimal amount){
        return new cmbls__Expense__c(
            cmbls__Repayment__c = repaymentId,
            cmbls__Fee_Type__c = type,
            cmbls__Amount__c = amount,
            RecordTypeId = RepaymentUtils.EXPENSE_RECORD_TYPE_EXPENSE
        );
    }
    
    public static cmbls__Expense_Accrual__c createExpenseAccrual(Id repaymentId, Id expenseId, Decimal amount){
        return new cmbls__Expense_Accrual__c(
            cmbls__Repayment__c = repaymentId,
            cmbls__Amount__c = amount,
            cmbls__Expense__c = expenseId
        );
    }
    
    public static cmbls__Loan_Transfer__c createLoanTransfer(Id newFundId, Id repaymentId){
        return new cmbls__Loan_Transfer__c(
            cmbls__Loan_Transfer_Date__c = System.today(),
            cmbls__New_Fund__c = newFundId,
            Principal_Balance__c = 2500,
            Interest_Balance__c = 0,
            Origination_Fee_Balance__c = 200,
            Broker_Fee_Balance__c = 300,
            cmbls__Amount__c = (2500 + 300) - 200,
            cmbls__Type__c = RepaymentUtils.TRANSFER_TYPE_INTERNAL,
            cmbls__Repayment__c = repaymentId
        );
    }
}