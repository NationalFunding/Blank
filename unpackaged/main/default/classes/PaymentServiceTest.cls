/**
 * PaymentServiceTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class PaymentServiceTest{
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    
        delete [SELECT Id FROM cmbls__Payment__c];
    
        insert new cmbls__Payment__c(
            cmbls__Repayment__c = repayment.Id,
            RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
            cmbls__Effective_Date__c = System.today().addDays(1),
            cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
            cmbls__Sub_Type__c = 'Adjustment',
            cmbls__Transaction_Amount__c = 4000,
            cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED,
            cmbls__Payment_Method__c = PaymentUtils.PAYMENT_METHOD_ACH,
            cmbls__ACH_Processor__c = 'ACH.com'
        );
        
        insert new cmbls__Active_Repayment_Statuses__c(
            cmbls__Status__c = 'Active',
            Name = 'Active'
        );
        Test.stopTest();
    }
    
    @IsTest
    static void createOneTimePaymentFromInvocable(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        CreateOneTimePayment.CreateRequest mainRequest = new CreateOneTimePayment.CreateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.effectiveDate = System.today().addDays(15);
        mainRequest.transactionAmount = 2000;
        mainRequest.subType = 'Adjustment';
        mainRequest.achProcessor = 'ACH.com';
        mainRequest.notes = 'Test Notes';
        
        Test.startTest();
        cmbls__Payment__c payment = PaymentService.createOneTimePaymentFromInvocable(mainRequest);
        Test.stopTest();
        System.assertNotEquals(null, payment.Id);
    }
    
    @IsTest
    static void rescheduleAPaymentFromInvocable(){
        cmbls__Repayment__c repayment = [SELECT Id, (SELECT Id, Name, cmbls__Status__c FROM cmbls__Payments__r LIMIT 1) FROM cmbls__Repayment__c];
        
        ReschedulePayment.RescheduleRequest mainRequest = new ReschedulePayment.RescheduleRequest();
        mainRequest.paymentId = repayment.cmbls__Payments__r[0].Id;
        mainRequest.effectiveDate = System.today().addDays(10);
        mainRequest.notes = 'Test Notes';
        
        Test.startTest();
        cmbls__Payment__c payment = PaymentService.rescheduleAPaymentFromInvocable(mainRequest);
        System.assertNotEquals(null, payment.Id);
    
        String errorMessage = String.format(ReschedulePayment.NOT_SCHEDULED_ERROR_MESSAGE, new String[]{
            repayment.cmbls__Payments__r[0].Name, PaymentUtils.PAYMENT_STATUS_PENDING
        });
        try{
            update new cmbls__Payment__c(Id = repayment.cmbls__Payments__r[0].Id, cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_PENDING);
            PaymentService.rescheduleAPaymentFromInvocable(mainRequest);
            System.assert(false, 'Should thrown an exception');
        }catch(Exception e){
            System.assertEquals(errorMessage, e.getMessage());
        }
        Test.stopTest();
        
    }
    
    @IsTest
    static void getPendingPayments(){
        Test.startTest();
        String query = PaymentService.getPendingPayments(WellsFargoAPI.PAYMENTS_PROCESS, new Set<Id>());
        query = PaymentService.getPendingPayments(WellsFargoAPI.DISBURSEMENT_PROCESS, new Set<Id>());
        Test.stopTest();
    }
    
    @IsTest
    static void getPendingRefundDisbursements(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_COMPLETE;
        update repayment;
        
        cmbls__Disbursement__c record = TestDataFactory.createDisbursement(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_REFUND, DisbursementUtils.DISBURSEMENT_STATUS_SCHEDULED, 'Wells Fargo - QBF Funding');
        record.cmbls__Effective_Date__c = DateTimeUtils.getNextValidDate(Date.today().addDays(1));
        record.cmbls__Repayment__c = repayment.Id;
        insert record;
        
        Test.startTest();
        String query = PaymentService.getPendingPayments(WellsFargoAPI.DISBURSEMENT_PROCESS, new Set<Id>());
        cmbls__Disbursement__c result = (cmbls__Disbursement__c)Database.query(query);
        Test.stopTest();
        
        Assert.areEqual(record.Id, result.Id);
    }
    
    @IsTest
    static void getReversalPayment(){
        cmbls__Payment__c originalPayment = Database.query('SELECT ' + String.join(new List<String>(cmbls__Payment__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') + ' FROM cmbls__Payment__c LIMIT 1');
        Test.startTest();
        PaymentService.getRepaymentActiveStatuses();
        cmbls__Payment__c reversal = PaymentService.getReversalPayment(originalPayment);
        Test.stopTest();
        
        Assert.areEqual(PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID, reversal.RecordTypeId);
        Assert.areEqual(originalPayment.cmbls__Status__c, reversal.cmbls__Status__c);
        Assert.areEqual(PaymentUtils.PAYMENT_TRANSACTION_TYPE_ADJUSTMENT, reversal.cmbls__Transaction_Type__c);
        Assert.areEqual(PaymentUtils.PAYMENT_SUBTYPE_REVERSAL, reversal.cmbls__Sub_Type__c);
        Assert.areEqual(null, reversal.cmbls__External_Transaction_ID__c);
        Assert.areEqual(null, reversal.Wells_Fargo_Payment_ID_Override__c);
        Assert.areEqual(originalPayment.Id, reversal.cmbls__Reversal_Of__c);
        Assert.areEqual(null, reversal.cmbls__ACH_Batch__c);
        Assert.areEqual(null, reversal.cmbls__Running_Balance__c);
        Assert.areEqual(null, reversal.cmbls__Sequence__c);
        Assert.areEqual(null, reversal.cmbls__Posted_to_accounting__c);
    }
    
    @IsTest
    static void syncACHBatchOnUpdate(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c LIMIT 1];
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 500, System.today(), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 300, System.today(), 'Wells Fargo - NFAS2 Collections'),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 500, System.today().addDays(1), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 300, System.today().addDays(1), 'Wells Fargo - NFAS2 Collections')
        };
        insert payments;
        Test.startTest();
        payments[0].cmbls__ACH_Processor__c = 'ACH.com';
        payments[0].cmbls__Effective_Date__c = System.today().addDays(1);
        payments[1].cmbls__Effective_Date__c = System.today().addDays(1);
        payments[2].cmbls__ACH_Processor__c = 'Wells Fargo - QBF Funding';
        payments[3].cmbls__Effective_Date__c = System.today().addDays(1);
        update payments;
        Test.stopTest();
    }
    
    @IsTest
    static void paymentReversalOnInsert(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        cmbls__Payment__c distPayment = TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SETTLED, 4000, System.today().addDays(-1), null);
        distPayment.cmbls__Transaction_Type__c = 'Distribution';
        insert distPayment;
        
        Date nextPaymentDate = cmbls.DatetimeUtils.getNextValidDate(System.today().addDays(10));
        cmbls__Repayment_Schedule__c[] schedules = new cmbls__Repayment_Schedule__c[]{
            TestDataFactory.createRepaymentSchedule(repayment.Id),
            TestDataFactory.createRepaymentSchedule(repayment.Id)
        };
        schedules[0].cmbls__Active__c = true;
        schedules[0].cmbls__Next_Payment_Date__c = nextPaymentDate;
        schedules[1].cmbls__Next_Payment_Date__c = nextPaymentDate;
        insert schedules;
        
        schedules = [SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c = :repayment.Id ORDER BY cmbls__Active__c DESC];
        Assert.areEqual(nextPaymentDate, schedules[0].cmbls__Next_Payment_Date__c);
        Assert.areEqual(nextPaymentDate, schedules[1].cmbls__Next_Payment_Date__c);
        
        repayment = [SELECT Id, cmbls__Status__c, cmbls__Open_Balance__c FROM cmbls__Repayment__c];
        Assert.areEqual(distPayment.cmbls__Transaction_Amount__c, repayment.cmbls__Open_Balance__c);
        Assert.areEqual(RepaymentUtils.STATUS_ACTIVE, repayment.cmbls__Status__c);
        
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT, PaymentUtils.PAYMENT_STATUS_SETTLED, 3000, System.today(), null),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT, PaymentUtils.PAYMENT_STATUS_SETTLED, 1000, System.today(), null)
        };
        insert payments;
        
        repayment = [SELECT Id, cmbls__Status__c, cmbls__Open_Balance__c FROM cmbls__Repayment__c];
        
        Assert.areEqual(0, repayment.cmbls__Open_Balance__c);
        Assert.areEqual(RepaymentUtils.STATUS_COMPLETE, repayment.cmbls__Status__c);
        
        Test.startTest();
        cmbls__Payment__c reversal = TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SETTLED, 1000, System.today(), null);
        reversal.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_ADJUSTMENT;
        reversal.cmbls__Sub_Type__c = PaymentUtils.PAYMENT_SUBTYPE_REVERSAL;
        insert reversal;
        Test.stopTest();
        
        repayment = [SELECT Id, cmbls__Status__c  FROM cmbls__Repayment__c];
        Assert.areEqual(RepaymentUtils.STATUS_ACTIVE, repayment.cmbls__Status__c);
        
        schedules = [SELECT Id, cmbls__Next_Payment_Date__c FROM cmbls__Repayment_Schedule__c WHERE cmbls__Repayment__c = :repayment.Id ORDER BY cmbls__Active__c DESC];
        Assert.areNotEqual(nextPaymentDate, schedules[0].cmbls__Next_Payment_Date__c);
        Assert.areEqual(nextPaymentDate, schedules[1].cmbls__Next_Payment_Date__c);
    }
}