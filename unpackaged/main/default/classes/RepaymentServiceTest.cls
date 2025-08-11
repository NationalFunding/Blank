/**
 * RepaymentServiceTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class RepaymentServiceTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        Account lenderAccount = TestDataFactory.createAccount();
        lenderAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Lender_Acct').getRecordTypeId();
        lenderAccount.Name = RepaymentUtils.QUICK_BRIDGE_FUND_RECORD_NAME;
        insert new Account[]{acc, lenderAccount};
        
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        opp.Lender_Account__c = lenderAccount.Id;
        insert opp;
    
        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_PAYOFF, DisbursementUtils.DISBURSEMENT_STATUS_STAGING, Constant.ACH_PROCESSOR_NF_FUNDING);
        dis.Opportunity__c = opp.Id;
        insert dis;
    
        cmbls__Banking_Information__c bankingInformation = TestDataFactory.createBankingInformation(acc.Id);
        insert bankingInformation;
    
        cmbls__Fund__c[] fundRecords = new cmbls__Fund__c[]{
            TestDataFactory.createFund('Quick Bridge', bankingInformation),
            TestDataFactory.createFund('National Funding - Fund', bankingInformation)
        };
        fundRecords[0].cmbls__Default_Debit_ACH_Processor__c = 'Wells Fargo - NF Collections';
        fundRecords[1].cmbls__Default_Debit_ACH_Processor__c = 'Wells Fargo - NF Collections';
        insert fundRecords;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Opportunity__c = opp.Id;
        repayment.cmbls__Primary_Fund__c = fundRecords[0].Id;
        repayment.cmbls__ACH_Processor__c = 'Wells Fargo - NF Collections';
        insert repayment;
    
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10));
        schedules[0].cmbls__Bank_Account_Number__c = '1212';
        schedules[0].cmbls__Bank_Routing_Number__c = '999999963';
    
        schedules[1].cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10));
        schedules[1].cmbls__Bank_Account_Number__c = '1212';
        schedules[1].cmbls__Bank_Routing_Number__c = '999999963';
    
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            new cmbls__Payment__c(
                cmbls__Repayment__c = repayment.Id,
                RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
                cmbls__Effective_Date__c = System.today().addDays(1),
                cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
                cmbls__Transaction_Amount__c = 4000,
                cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED
            ),
            new cmbls__Payment__c(
                cmbls__Repayment__c = repayment.Id,
                RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
                cmbls__Effective_Date__c = System.today().addDays(1),
                cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
                cmbls__Transaction_Amount__c = 4000,
                cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_CANCELED
            )
        };
        insert payments;
        insert schedules;
        
        cmbls__Expense__c expense = new cmbls__Expense__c(
            cmbls__Amount__c = 300,
            RecordTypeId = RepaymentUtils.EXPENSE_RECORD_TYPE_INCOME,
            cmbls__Repayment__c = repayment.Id,
            cmbls__Fee_Type__c = RepaymentUtils.ORIGINATION_FEE
        );
        insert expense;
        
        cmbls__Expense_Accrual__c expenseAccrual = new cmbls__Expense_Accrual__c(
            cmbls__Amount__c = 200,
            cmbls__Date__c = System.today(),
            cmbls__Expense__c = expense.Id,
            cmbls__Repayment__c = repayment.Id
        );
        insert expenseAccrual;
        
        cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
        settings.National_Funding_Fund_Id__c = fundRecords[1].Id;
        settings.Enable_Automatic_Transfers__c = true;
        upsert settings;
        
        Test.stopTest();
    }
    
    @IsTest
    static void pauseAndResumeRepayment(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Test.startTest();
        RepaymentService.pauseAndResumeRepayment(repayment.Id, System.today().addDays(10));
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Repayment__c WHERE Id = :repayment.Id AND Pause_Date__c = :System.today() AND Resume_Date__c = :System.today().addDays(10)]);
    }
    
    @IsTest
    static void reactivateRepaymentFromInvocable(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        ReactivateRepayment.ReactivateRequest mainRequest = new ReactivateRepayment.ReactivateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
    
        Test.startTest();
        RepaymentService.reactivateRepaymentFromInvocable(mainRequest);
        Test.stopTest();
    
        repayment = [SELECT Id, cmbls__Status__c, Notes__c FROM cmbls__Repayment__c];
        System.assert(repayment.Notes__c.startsWith('Repayment status updated to Active on '));
        System.assertEquals(RepaymentUtils.STATUS_ACTIVE, repayment.cmbls__Status__c);
    
        cmbls__Repayment_Schedule__c[] schedules = [SELECT Id, cmbls__Next_Payment_Date__c, cmbls__Notes__c, cmbls__Active__c FROM cmbls__Repayment_Schedule__c];
        for(cmbls__Repayment_Schedule__c item :schedules){
            if(!item.cmbls__Active__c){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals(cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10)), item.cmbls__Next_Payment_Date__c);
            }else{
                System.assert(item.cmbls__Notes__c.startsWith('"Next Payment Date" reset after Repayment status updating to Active on '));
                System.assertNotEquals(cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10)), item.cmbls__Next_Payment_Date__c);
            }
        }
    }
    
    @IsTest
    static void updateBankingInformationFromInvocable(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c FROM cmbls__Repayment__c];
        UpdateBankingInformation.UpdateRequest mainRequest = new UpdateBankingInformation.UpdateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.fromRecord = 'Case: #000987';
        mainRequest.notes = 'TEST NOTES';
        mainRequest.bankName = 'WELLS FARGO';
        mainRequest.bankAccountType = 'Checking';
        mainRequest.bankAccountNumber = '456456456';
        mainRequest.bankRoutingNumber = '999999763';
        mainRequest.updateRepaymentSchedules = true;
        mainRequest.updateScheduledPayments = true;
    
        String notes = String.format(UpdateBankingInformation.NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : ''),
            repayment.cmbls__Bank_Name__c, repayment.cmbls__Bank_Routing_Number__c, repayment.cmbls__Bank_Account_Number__c,
            mainRequest.bankName, mainRequest.bankRoutingNumber, mainRequest.bankAccountNumber
        }) + mainRequest.notes;
    
        Test.startTest();
        RepaymentService.updateBankingInformationFromInvocable(mainRequest);
        Test.stopTest();
    
        repayment = [SELECT Id, cmbls__Bank_Routing_Number__c, cmbls__Bank_Account_Number__c, cmbls__Bank_Name__c, Notes__c, cmbls__Type_of_Account__c FROM cmbls__Repayment__c];
        System.assertEquals(notes, repayment.Notes__c);
        System.assertEquals(mainRequest.bankAccountNumber, repayment.cmbls__Bank_Account_Number__c);
        System.assertEquals(mainRequest.bankRoutingNumber, repayment.cmbls__Bank_Routing_Number__c);
        System.assertEquals(mainRequest.bankAccountType, repayment.cmbls__Type_of_Account__c);
    
        cmbls__Payment__c[] payments = [SELECT Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Status__c, cmbls__Notes__c, cmbls__Type_of_Account__c FROM cmbls__Payment__c];
        for(cmbls__Payment__c item :payments){
            if(item.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_CANCELED){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals(null, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(null, item.cmbls__Bank_Routing_Number__c);
                System.assertEquals(null, item.cmbls__Type_of_Account__c);
            }else if(item.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_SCHEDULED){
                System.assertEquals(notes, item.cmbls__Notes__c);
                System.assertEquals(mainRequest.bankAccountNumber, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(mainRequest.bankRoutingNumber, item.cmbls__Bank_Routing_Number__c);
                System.assertEquals(mainRequest.bankAccountType, item.cmbls__Type_of_Account__c);
            }
        }
    
        cmbls__Repayment_Schedule__c[] schedules = [SELECT Id, cmbls__Bank_Account_Number__c, cmbls__Bank_Routing_Number__c, cmbls__Active__c, cmbls__Notes__c FROM cmbls__Repayment_Schedule__c];
        for(cmbls__Repayment_Schedule__c item :schedules){
            if(!item.cmbls__Active__c){
                System.assertEquals(null, item.cmbls__Notes__c);
                System.assertEquals('1212', item.cmbls__Bank_Account_Number__c);
                System.assertEquals('999999963', item.cmbls__Bank_Routing_Number__c);
            }else{
                System.assertEquals(mainRequest.bankAccountNumber, item.cmbls__Bank_Account_Number__c);
                System.assertEquals(mainRequest.bankRoutingNumber, item.cmbls__Bank_Routing_Number__c);
            }
        }
    }
    
    @IsTest
    static void relateDisbursements(){
        cmbls__Repayment__c repayment = [SELECT Id, Opportunity__c FROM cmbls__Repayment__c];
        Test.startTest();
        RepaymentService.relateDisbursements(new cmbls__Repayment__c[]{repayment});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Opportunity__c = :repayment.Opportunity__c AND cmbls__Repayment__c = :repayment.Id]);
    }
    
    @IsTest
    static void createExpenses(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        delete [SELECT Id FROM cmbls__Expense__c  WHERE cmbls__Repayment__c = :repayment.Id];
        
        Test.startTest();
        repayment.Total_Broker_Fee__c = 100;
        repayment.cmbls__Origination_Fee__c = 120;
        RepaymentService.createExpenses(new cmbls__Repayment__c[]{repayment});
        Test.stopTest();
        
        System.assertEquals(1, [
            SELECT COUNT() FROM cmbls__Expense__c WHERE
                cmbls__Repayment__c = :repayment.Id AND
                cmbls__Amount__c =:repayment.Total_Broker_Fee__c AND
                RecordTypeId = :RepaymentUtils.EXPENSE_RECORD_TYPE_EXPENSE AND
                cmbls__Fee_Type__c = :RepaymentUtils.BROKER_FEE
        ]);
        
        System.assertEquals(1, [
            SELECT COUNT() FROM cmbls__Expense__c WHERE
                cmbls__Repayment__c = :repayment.Id AND
                cmbls__Amount__c =:repayment.cmbls__Origination_Fee__c AND
                RecordTypeId = :RepaymentUtils.EXPENSE_RECORD_TYPE_INCOME AND
                cmbls__Fee_Type__c = :RepaymentUtils.ORIGINATION_FEE
        ]);
        
        System.assertEquals(2, [SELECT COUNT() FROM cmbls__Expense__c WHERE cmbls__Repayment__c = :repayment.Id]);
    }
    
    @IsTest
    static void createTransferQueuedEvents(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__Loan_Start_Date__c FROM cmbls__Repayment__c];
        repayment.cmbls__Loan_Start_Date__c = System.today().addDays(-20);
        update repayment;
    
        Test.startTest();
        repayment.Total_Broker_Fee__c = 100;
        repayment.cmbls__Origination_Fee__c = 120;
        RepaymentService.createTransferQueuedEvents(new cmbls__Repayment__c[]{repayment}, new Map<Id, cmbls__Repayment__c>());
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repayment.Id AND cmbls__Type__c = :TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION]);
    }
    
    @IsTest
    static void createTransferRecords(){
        cmbls__Repayment__c repayment = [
            SELECT  Id, cmbls__Loan_Start_Date__c, Total_Broker_Fee__c, cmbls__Principal_Balance_Amount__c, cmbls__Primary_Fund__c,
                    cmbls__Accrued_Interest__c, cmbls__Interest_Paid__c, cmbls__Interest_Credited__c, cmbls__Funding_Amount__c,
                    (SELECT Id, cmbls__Amount__c FROM cmbls__Expenses__r), (SELECT Id, cmbls__Amount__c FROM cmbls__Expense_Accruals__r)
            FROM cmbls__Repayment__c
        ];
        repayment.Total_Broker_Fee__c = 500;
        repayment.cmbls__Loan_Start_Date__c = System.today().addDays(-20);
        update repayment;

        cmbls__Queued_Event__c queuedEvent = new cmbls__Queued_Event__c(
            cmbls__Record_Id__c = repayment.Id,
            cmbls__Type__c = TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION
        );
        insert queuedEvent;

        cmbls__Fund__c fundAccount = [
            SELECT Id, cmbls__Default_Debit_ACH_Processor__c
            FROM cmbls__Fund__c
            WHERE Id = :cmbls__Loan_Servicing_Settings__c.getInstance().National_Funding_Fund_Id__c
        ];

        Decimal principalBalance = repayment.cmbls__Funding_Amount__c;
        Decimal originationFeeBalance = 0;
        for(cmbls__Expense__c item :repayment.cmbls__Expenses__r) originationFeeBalance += item.cmbls__Amount__c;

        Map<Id, Decimal> expenseBrokerFeesByRepayment = ExpenseSelector.getSumExpenseBrokerFeesByRepayment(new Set<Id>{repayment.Id});

        Decimal brokerFeeBalance = NumberUtils.getDecimal(expenseBrokerFeesByRepayment.get(repayment.Id));
        Decimal amount = (principalBalance + brokerFeeBalance) - originationFeeBalance;

        Test.startTest();
        RepaymentService.createTransferRecords(new cmbls__Queued_Event__c[]{queuedEvent});
        Test.stopTest();

        cmbls__Loan_Transfer__c transfer = [
            SELECT  Id, cmbls__Loan_Transfer_Date__c, cmbls__New_Fund__c, cmbls__Previous_Fund__c, Principal_Balance__c,
                    Interest_Balance__c, Origination_Fee_Balance__c, Broker_Fee_Balance__c,
                    cmbls__Amount__c, cmbls__New_ACH_Processor__c, cmbls__Type__c
            FROM cmbls__Loan_Transfer__c
            WHERE cmbls__Repayment__c = :repayment.Id
        ];

        System.assertEquals(System.today(), transfer.cmbls__Loan_Transfer_Date__c);
        System.assertEquals(repayment.cmbls__Primary_Fund__c, transfer.cmbls__Previous_Fund__c);
        System.assertEquals(fundAccount.Id, transfer.cmbls__New_Fund__c);
        System.assertEquals(principalBalance, transfer.Principal_Balance__c);
        System.assertEquals(brokerFeeBalance, transfer.Broker_Fee_Balance__c);
        System.assertEquals(originationFeeBalance, transfer.Origination_Fee_Balance__c);
        System.assertEquals(amount, transfer.cmbls__Amount__c);
        System.assertEquals(fundAccount.cmbls__Default_Debit_ACH_Processor__c, transfer.cmbls__New_ACH_Processor__c);
        System.assertEquals(RepaymentUtils.TRANSFER_TYPE_INTERNAL, transfer.cmbls__Type__c);
    }
    
    @IsTest
    static void createTransferRecordsDeletedRecord(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Id repaymentId = repayment.Id;
        delete repayment;
        delete [SELECT Id FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repaymentId];
        
        cmbls__Queued_Event__c queuedEvent = new cmbls__Queued_Event__c(cmbls__Record_Id__c = repaymentId, cmbls__Type__c = TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION);
        insert queuedEvent;
        
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repaymentId]);
        
        Test.startTest();
        RepaymentService.createTransferRecords(new cmbls__Queued_Event__c[]{queuedEvent});
        Test.stopTest();
        
        queuedEvent = [SELECT Id, Deleted_Record_Id__c FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repaymentId];
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Loan_Transfer__c WHERE cmbls__Repayment__c = :repaymentId]);
        Assert.isTrue(queuedEvent.Deleted_Record_Id__c);
    }
    
    @IsTest
    static void createTransferRecordsCanceledRecord(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_UNWIND;
        repayment.cmbls__Loan_Start_Date__c = System.today().addDays(-1);
        update repayment;
        
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Repayment__c WHERE Id = :repayment.Id AND cmbls__Status__c = :RepaymentUtils.STATUS_UNWIND]);
        
        delete [SELECT Id FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repayment.Id];
        
        cmbls__Queued_Event__c queuedEvent = new cmbls__Queued_Event__c(cmbls__Record_Id__c = repayment.Id, cmbls__Type__c = TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION);
        insert queuedEvent;
        
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repayment.Id]);
        
        Test.startTest();
        RepaymentService.createTransferRecords(new cmbls__Queued_Event__c[]{queuedEvent});
        Test.stopTest();
        
        queuedEvent = [SELECT Id, Deleted_Record_Id__c, Canceled__c FROM cmbls__Queued_Event__c WHERE cmbls__Record_Id__c = :repayment.Id];
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Loan_Transfer__c WHERE cmbls__Repayment__c = :repayment.Id]);
        Assert.isFalse(queuedEvent.Deleted_Record_Id__c);
        Assert.isTrue(queuedEvent.Canceled__c);
    }
    
    @IsTest
    static void getDebugLogForDMLFailure(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        Database.SaveResult result = Database.update(new cmbls__Repayment__c(Id = repayment.Id, cmbls__Payee_Account__c = null), false);
        Test.startTest();
        UtilityTools.getDebugLogForDMLFailure('', repayment, result);
        UtilityTools.getDoubleValFromDecimal(45);
        Test.stopTest();
    }
}