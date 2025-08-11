/**
 * ChartOfAccountServiceTest class
 * @author CloudMyBiz (r)
 * @date 10/27/2022
 */

@IsTest
public class ChartOfAccountServiceTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
    
        cmbls__Fund__c[] fundRecords = new cmbls__Fund__c[]{
            TestDataFactory.createFund(RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME, bankingInformation),
            TestDataFactory.createFund('National Funding', bankingInformation)
        };
        insert fundRecords;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Product_Type__c = 'LOAN';
        repayment.cmbls__Primary_Fund__c = fundRecords[1].Id;
        insert repayment;
    
        insert TestDataFactory.createPayment(repayment.Id,'Credit', 'Scheduled', 100.00, Date.today(), Constant.ACH_PROCESSOR_NF_FUNDING);
        
        cmbls__Loan_Transfer__c loanTransfer = TestDataFactory.createLoanTransfer(fundRecords[1].Id, repayment.Id);
        loanTransfer.cmbls__Previous_Fund__c = fundRecords[0].Id;
        insert loanTransfer;
    
        createChartOfAccountData(fundRecords[0].Id, fundRecords[1].Id);
        
        delete [SELECT Id FROM cmbls__Debug_Log__c];
        Test.stopTest();
    }
    
    @IsTest
    static void errorMissingRepaymentLookup(){
        Account acc = [SELECT Id FROM Account];
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = acc.Id;
        request.saveRecords = true;
        ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
    
        String error = String.format(ChartOfAccountService.ERROR_MISSING_REPAYMENT_LOOKUP, new String[]{Account.getSObjectType().getDescribe().getName()});
        System.assert(errorLogExist(error, acc.Id), 'cmbls__Debug_Log__c should be created with "' + error + '" description.');
    }
    
    @IsTest
    static void errorMissingRepaymentRecord(){
        cmbls__Disbursement__c disbursement = TestDataFactory.createDisbursement('Funding', Constant.STATUS_PENDING, Constant.ACH_PROCESSOR_NF_FUNDING);
        insert disbursement;
        
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = disbursement.Id;
        request.saveRecords = true;
        ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
        
        System.assert(errorLogExist(ChartOfAccountService.ERROR_MISSING_REPAYMENT_RECORD, disbursement.Id), 'cmbls__Debug_Log__c should be created with "' + ChartOfAccountService.ERROR_MISSING_REPAYMENT_RECORD + '" description.');
    }
    
    @IsTest
    static void errorMissingRecordConfiguration(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Disbursement__c disbursement = TestDataFactory.createDisbursement('Funding', Constant.STATUS_PENDING, Constant.ACH_PROCESSOR_NF_FUNDING);
        disbursement.cmbls__Repayment__c = repayment.Id;
        insert disbursement;
    
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = disbursement.Id;
        request.saveRecords = true;
        ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
    
        String error = String.format(ChartOfAccountService.ERROR_MISSING_RECORD_CONFIG, new String[]{cmbls__Disbursement__c.getSObjectType().getDescribe().getName()});
        System.assert(errorLogExist(error, disbursement.Id), 'cmbls__Debug_Log__c should be created with "' + error + '" description.');
    }
    
    @IsTest
    static void errorMissingTypeEntity(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Primary_Fund__r.Name FROM cmbls__Repayment__c];
        repayment.Product_Type__c = 'FRPSA';
        update repayment;
        
        delete [SELECT Id FROM cmbls__Debug_Log__c];
        delete [SELECT Id FROM Chart_of_Account_Key__c WHERE Product_Type__c = 'FRPSA'];
    
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = repayment.Id;
        request.saveRecords = true;
        ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
    
        String error = String.format(ChartOfAccountService.ERROR_MISSING_TYPE_ENTITY, new String[]{
            repayment.Product_Type__c, repayment.cmbls__Primary_Fund__r.Name
        });
        System.assert(errorLogExist(error, repayment.Id), 'cmbls__Debug_Log__c should be created with "' + error + '" description.');
    }
    
    @IsTest
    static void mainInvocableMethod(){
        Chart_of_Account__c[] chartOfAccounts = ChartOfAccountSelector.getChartOfAccounts();
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Set<String> repaymentFields = new Set<String>();
        for(Chart_of_Account__c chartOfAccount :chartOfAccounts){
            if(chartOfAccount.Object_API_Name__c == 'cmbls__Repayment__c'){
                repayment.put(chartOfAccount.GL_Account_Field_API_Name__c, null);
                repaymentFields.add(chartOfAccount.GL_Account_Field_API_Name__c);
            }
        }
        ChartOfAccountService.SKIP_LOGIC_ON_TEST = true;
        update repayment;
        ChartOfAccountService.SKIP_LOGIC_ON_TEST = false;
        
        String query = 'SELECT COUNT() FROM cmbls__Repayment__c WHERE Id = \'' + repayment.Id + '\'';
        for(String field :repaymentFields)query += ' AND ' + field + ' = NULL';
        System.assertEquals(1, Database.countQuery(query));
        
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = repayment.Id;
        request.saveRecords = true;
        String[] result = ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
    
        System.assertEquals(1, result.size());
        System.assertEquals(request.recordId, result.get(0));
        
        repayment = Database.query('SELECT cmbls__Primary_Fund__c, Product_Type__c, ' + String.join(new List<String>(repaymentFields), ', ') + ' FROM cmbls__Repayment__c WHERE Id = \'' + repayment.Id + '\'');
        
        String key;
        for(Chart_of_Account_Key__c chartOfAccountKey :ChartOfAccountSelector.getChartOfAccountKeys()){
            if(chartOfAccountKey.Product_Type__c == repayment.Product_Type__c && chartOfAccountKey.Company__c == repayment.cmbls__Primary_Fund__c){
                key = chartOfAccountKey.Key__c;
            }
        }
        
        for(Chart_of_Account__c chartOfAccount :chartOfAccounts){
            if(chartOfAccount.Object_API_Name__c == 'cmbls__Repayment__c'){
                System.assertEquals(chartOfAccount.get(key), repayment.get(chartOfAccount.GL_Account_Field_API_Name__c), 'Failure on field: ' + chartOfAccount.GL_Account_Field_API_Name__c);
            }
        }
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Debug_Log__c WHERE cmbls__Record_Id__c = :repayment.Id]);
    }
    
    @IsTest
    static void mainInvocableMethodLoanTransfer(){
        Chart_of_Account__c[] chartOfAccounts = ChartOfAccountSelector.getChartOfAccounts();
        cmbls__Loan_Transfer__c loanTransfer = [SELECT Id FROM cmbls__Loan_Transfer__c];
        Set<String> loanTransferFields = new Set<String>();
        for(Chart_of_Account__c chartOfAccount :chartOfAccounts){
            if(chartOfAccount.Object_API_Name__c == 'cmbls__Loan_Transfer__c'){
                loanTransfer.put(chartOfAccount.GL_Account_Field_API_Name__c, null);
                loanTransferFields.add(chartOfAccount.GL_Account_Field_API_Name__c);
            }
        }
        update loanTransfer;
    
        String query = 'SELECT COUNT() FROM cmbls__Loan_Transfer__c WHERE Id = \'' + loanTransfer.Id + '\'';
        for(String field :loanTransferFields)query += ' AND ' + field + ' = NULL';
        System.assertEquals(1, Database.countQuery(query));
    
        ChartOfAccountService.ChartOfAccountRequest request = new ChartOfAccountService.ChartOfAccountRequest();
        request.recordId = loanTransfer.Id;
        request.saveRecords = true;
        ChartOfAccountService.mainInvocableMethod(new ChartOfAccountService.ChartOfAccountRequest[]{request});
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :request.recordId AND cmbls__Date_Processed__c = NULL AND cmbls__Type__c = :ChartOfAccountService.QUEUED_EVENT_TYPE]);
        
        Test.startTest();
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
        Test.stopTest();
    
        loanTransferFields.add('cmbls__Repayment__r.Product_Type__c');
        loanTransferFields.add('cmbls__New_Fund__c');
        loanTransferFields.add('cmbls__Previous_Fund__c');
        loanTransfer = Database.query('SELECT ' + String.join(new List<String>(loanTransferFields), ', ') + ' FROM cmbls__Loan_Transfer__c WHERE Id = \'' + loanTransfer.Id + '\'');
        
        
        System.assertEquals('QBF__c - 666666', loanTransfer.Previous_Entity_Receivable__c);
        System.assertEquals('QBF__c - 666666', loanTransfer.Previous_Entity_Origination_Fee__c);
        System.assertEquals('QBF__c - 666666', loanTransfer.Previous_Entity_Initial_Direct_Cost__c);
        System.assertEquals('QBF__c - 666666', loanTransfer.Previous_Entity_INT_Receivable__c);
    
        System.assertEquals('LOAN__c - 444444', loanTransfer.New_Entity_Receivable__c);
        System.assertEquals('LOAN__c - 444444', loanTransfer.New_Entity_Origination_Fee__c);
        System.assertEquals('LOAN__c - 444444', loanTransfer.New_Entity_Initial_Direct_Cost__c);
        System.assertEquals('LOAN__c - 444444', loanTransfer.New_Entity_INT_Receivable__c);
    
        System.assertEquals('QBtoNF__c - 888888', loanTransfer.Prev_Entity_Intercompany_Transfer__c);
        System.assertEquals('QBtoNF__c - 888888', loanTransfer.New_Entity_Intercompany_Transfer__c);
        
        
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Debug_Log__c WHERE cmbls__Record_Id__c = :loanTransfer.Id]);
    }
    
    @IsTest
    static void validateChartOfAccountRecordCreation(){
        Chart_of_Account__c[] records = ChartOfAccountSelector.getChartOfAccounts();
        records.addAll(new Chart_of_Account__c[]{
            TestDataFactory.createChartOfAccount('Lead', 'LastName', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount(records[0].Object_API_Name__c, records[0].GL_Account_Field_API_Name__c, 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('Lead', 'Custom_Field_Wrong__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('Custom_Object_Wrong__c', 'LastName', 'cmbls__Primary_Fund__c')
        });
        
        Test.startTest();
        Database.UpsertResult[] result = Database.upsert(records, false);
        Test.stopTest();
        
        Integer duplicatedRecord = result.size() - 3;
        Integer invalidFieldRecord = result.size() - 2;
        Integer invalidObjectRecord = result.size() - 1;
    
        for(Integer i = 0; i < result.size(); i++){
            if(i == duplicatedRecord){
                String error = String.format(ChartOfAccountService.ERROR_EXISTING_RECORD, new String[]{
                    Chart_of_Account__c.getSObjectType().getDescribe().getLabel(),
                    records[0].Name
                });
                System.assert(!result[i].isSuccess(), 'Duplicate record, should fail.');
                System.assertEquals(error, result[i].getErrors()[0].getMessage());
            }else if(i == invalidFieldRecord){
                String error = String.format(ChartOfAccountService.ERROR_INVALID_GL_FIELD, new String[]{records[i].Object_API_Name__c});
                System.assert(!result[i].isSuccess(), 'Invalid Field API Name, should fail.');
                System.assertEquals(error, result[i].getErrors()[0].getMessage());
                System.assertEquals('GL_Account_Field_API_Name__c', result[i].getErrors()[0].getFields()[0]);
            }else if(i == invalidObjectRecord){
                String error = String.format(ChartOfAccountService.ERROR_INVALID_OBJECT, new String[]{records[i].Object_API_Name__c});
                System.assert(!result[i].isSuccess(), 'Invalid Object API Name, should fail.');
                System.assertEquals(error, result[i].getErrors()[0].getMessage());
                System.assertEquals('Object_API_Name__c', result[i].getErrors()[0].getFields()[0]);
            }else{
                System.assert(result[i].isSuccess(), 'Valid record, should not fail.');
            }
        }
    }
    
    @IsTest
    static void validateChartOfAccountKeyRecordCreation(){
        cmbls__Banking_Information__c bankingInformation = [SELECT Id FROM cmbls__Banking_Information__c LIMIT 1];
        cmbls__Fund__c fundRecord = TestDataFactory.createFund('NF Test', bankingInformation);
        insert fundRecord;
        
        Chart_of_Account_Key__c[] records = ChartOfAccountSelector.getChartOfAccountKeys();
        records.addAll(new Chart_of_Account_Key__c[]{
            TestDataFactory.createChartOfAccountKey(fundRecord.Id, 'FRPSA', 'FRPSA__c'),
            TestDataFactory.createChartOfAccountKey(records[0].Company__c, records[0].Product_Type__c, 'LOAN__c') //Duplicated
        });
    
        Test.startTest();
        Database.UpsertResult[] result = Database.upsert(records, false);
        Test.stopTest();
    
        String error = String.format(ChartOfAccountService.ERROR_EXISTING_RECORD, new String[]{
            Chart_of_Account_Key__c.getSObjectType().getDescribe().getLabel(),
            records[0].Name
        });
        
        for(Integer i = 0; i < result.size(); i++){
            if(i != (result.size() - 1)){
                System.assert(result[i].isSuccess(), 'Valid record, should not fail.');
            }else{
                System.assert(!result[i].isSuccess(), 'Duplicate record, should fail.');
                System.assertEquals(error, result[i].getErrors()[0].getMessage());
            }
        }
    }
    
    private static Boolean errorLogExist(String error, Id recordId){
        for(cmbls__Debug_Log__c log :[SELECT cmbls__Record_Id__c, cmbls__Description__c, cmbls__Subject__c FROM cmbls__Debug_Log__c]){
            System.debug(log.cmbls__Description__c);
            if(log.cmbls__Description__c.equalsIgnoreCase(error) && log.cmbls__Record_Id__c == recordId && log.cmbls__Subject__c == ChartOfAccountService.ERROR_SUBJECT){
                return true;
            }
        }
        return false;
    }
    
    @TestVisible private static void createChartOfAccountData(Id quickBridgeId, Id nationalFundingId){
        Chart_of_Account__c[] chartOfAccounts = new Chart_of_Account__c[]{
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Cash_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Loan_Receivable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Loan_Int_Receivable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Recoveries_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Other_Income_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'Overpayment_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Payment__c', 'AR_Lessee_fwd_to_Lender_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Capitalized_Broker_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Broker_Fees_Payable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Capitalized_LendingTree_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Lead_Aggregators_LT_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Capitalized_Fundera_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Lead_Aggregators_Other_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense__c', 'Capitalized_Strategic_Partners_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Acc_Amort_Org_Fees_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Amortized_Income_Org_Fees_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Amortized_Exp_Broker_Fees_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Acc_Amort_Broker_Fees_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Amortized_Exp_LendingTree_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Acc_Amort_LendingTree_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Amortized_Exp_Fundera_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Acc_Amort_Fundera_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Expense_Accrual__c', 'Amortized_Exp_Strategic_Partners_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__InterestAccrual__c', 'Loan_Int_Receivable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__InterestAccrual__c', 'Loan_Interest_Income_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Repayment__c', 'Loan_Receivable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Repayment__c', 'Loans_Payable_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Repayment__c', 'Deferred_Income_Org_Fees_GL__c', 'cmbls__Primary_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'Previous_Entity_Receivable__c', 'cmbls__Previous_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'Previous_Entity_Origination_Fee__c', 'cmbls__Previous_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'Previous_Entity_INT_Receivable__c', 'cmbls__Previous_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'Previous_Entity_Initial_Direct_Cost__c', 'cmbls__Previous_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'New_Entity_Receivable__c', 'cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'New_Entity_Origination_Fee__c', 'cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'New_Entity_Initial_Direct_Cost__c', 'cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'New_Entity_INT_Receivable__c', 'cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'Prev_Entity_Intercompany_Transfer__c', 'cmbls__Previous_Fund__c,cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Loan_Transfer__c', 'New_Entity_Intercompany_Transfer__c', 'cmbls__Previous_Fund__c,cmbls__New_Fund__c'),
            TestDataFactory.createChartOfAccount('cmbls__Intercompany_Transaction__c', 'Payee_Intercompany__c', 'cmbls__Payee__c,cmbls__Payer__c'),
            TestDataFactory.createChartOfAccount('cmbls__Intercompany_Transaction__c', 'Payer_Intercompany__c', 'cmbls__Payee__c,cmbls__Payer__c')
        };
        insert chartOfAccounts;
    
    
        Chart_of_Account_Key__c[] keys = new Chart_of_Account_Key__c[]{
            TestDataFactory.createChartOfAccountKey(nationalFundingId, 'LOAN', 'LOAN__c'),
            TestDataFactory.createChartOfAccountKey(nationalFundingId, 'FRPSA', 'FRPSA__c'),
            TestDataFactory.createChartOfAccountKey(quickBridgeId, 'LOAN', 'QBF__c'),
            TestDataFactory.createChartOfAccountKey(quickBridgeId, 'FRPSA', 'QBF_FRPSA__c'),
            TestDataFactory.createChartOfAccountKey(nationalFundingId, '', 'QBtoNF__c')
        };
        keys[4].Previous_Company__c = quickBridgeId;
        insert keys;
    }
}