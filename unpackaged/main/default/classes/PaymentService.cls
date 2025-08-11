/**
 * PaymentService class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class PaymentService{
    
    public static final String ACCOUNTING_PERIOD_FULL_ACCESS_PERMISSION_NAME = 'Fundingo_Accounting_Level_2';
    
    public static cmbls__Payment__c createOneTimePaymentFromInvocable(CreateOneTimePayment.CreateRequest mainRequest){
        
        if(String.isBlank(mainRequest.achProcessor)){
            cmbls__Repayment__c repayment = RepaymentSelector.getRepaymentById(mainRequest.repaymentId);
            mainRequest.achProcessor = repayment.cmbls__ACH_Processor__c;
        }
        
        cmbls__Payment__c record = new cmbls__Payment__c(
            cmbls__Repayment__c = mainRequest.repaymentId,
            RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID,
            cmbls__Effective_Date__c = mainRequest.effectiveDate,
            cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
            cmbls__Sub_Type__c = mainRequest.subType,
            cmbls__Payment_Method__c = PaymentUtils.PAYMENT_METHOD_ACH,
            cmbls__ACH_Processor__c = mainRequest.achProcessor,
            cmbls__Notes__c = mainRequest.notes,
            cmbls__Transaction_Amount__c = mainRequest.transactionAmount,
            cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED
        );
        insert record;
        return record;
    }
    
    public static cmbls__Payment__c rescheduleAPaymentFromInvocable(ReschedulePayment.RescheduleRequest mainRequest){
        cmbls__Payment__c oldPayment = PaymentSelector.getPaymentById(mainRequest.paymentId);
        if(oldPayment.cmbls__Status__c != PaymentUtils.PAYMENT_STATUS_SCHEDULED){
            String errorMessage = String.format(ReschedulePayment.NOT_SCHEDULED_ERROR_MESSAGE, new String[]{
                oldPayment.Name, oldPayment.cmbls__Status__c
            });
            throw new ReschedulePayment.ReschedulePaymentException(errorMessage);
        }
        
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{};
        cmbls__Payment__c newPayment = new cmbls__Payment__c(
            cmbls__Repayment__c = oldPayment.cmbls__Repayment__c,
            RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
            cmbls__Effective_Date__c = mainRequest.effectiveDate,
            cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
            cmbls__Sub_Type__c = oldPayment.cmbls__Sub_Type__c,
            cmbls__Transaction_Amount__c = oldPayment.cmbls__Transaction_Amount__c,
            cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED,
            cmbls__Payment_Method__c = PaymentUtils.PAYMENT_METHOD_ACH,
            cmbls__ACH_Processor__c = oldPayment.cmbls__ACH_Processor__c,
            cmbls__Notes__c = mainRequest.notes,
            Payment__c = oldPayment.Id
        );
        payments.add(newPayment);
        
        oldPayment.cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_CANCELED;
        if(String.isBlank(oldPayment.cmbls__Notes__c)){
            oldPayment.cmbls__Notes__c = '';
        }else{
            oldPayment.cmbls__Notes__c += '\n\n';
        }
        oldPayment.cmbls__Notes__c += mainRequest.notes;
        payments.add(oldPayment);
        
        upsert payments;
        return newPayment;
    }
    
    public static cmbls__Payment__c getReversalPayment(cmbls__Payment__c record){
        cmbls__Payment__c reversalPayment = record.clone(false, true, false, false);
        reversalPayment.RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID;
        reversalPayment.cmbls__Status__c = record.cmbls__Status__c;
        reversalPayment.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_ADJUSTMENT;
        reversalPayment.cmbls__Sub_Type__c = PaymentUtils.PAYMENT_SUBTYPE_REVERSAL;
        reversalPayment.cmbls__External_Transaction_ID__c = null;
        reversalPayment.Wells_Fargo_Payment_ID_Override__c = null;
        reversalPayment.cmbls__Reversal_Of__c = record.Id;
        reversalPayment.cmbls__ACH_Batch__c = null;
        reversalPayment.cmbls__Running_Balance__c = null;
        reversalPayment.cmbls__Sequence__c = null;
        reversalPayment.cmbls__Posted_to_accounting__c = null;
        
        return reversalPayment;
    }
    
    private static String getPendingPayments(String process, Set<Id> recordsForResubmission, Boolean count){
        String query = '';
        Datetime dta = Datetime.newInstance(DateTimeUtils.getNextValidDate(Date.today().addDays(1)), Time.newInstance(0, 0, 0, 0));
        String effectiveDate = dta.format('yyyy-MM-dd');
        String strActiveStatuses = getRepaymentActiveStatuses();
        Integer maxNumOfAttempts = NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Max_Number_of_attempts__c);
        
        if(process == WellsFargoAPI.PAYMENTS_PROCESS){
            query = getPendingPaymentQuery(effectiveDate, strActiveStatuses, maxNumOfAttempts, count);
        }else if (process == WellsFargoAPI.DISBURSEMENT_PROCESS){
            query = getPendingDisbursementQuery(effectiveDate, strActiveStatuses, maxNumOfAttempts, count);
        }
        
        if(recordsForResubmission != null && !recordsForResubmission.isEmpty()){
            Id[] resubmissionIds = new Id[]{};
            resubmissionIds.addAll(recordsForResubmission);
            query += ' OR Id IN ' + UtilityTools.getStringListForINSOQLClause(resubmissionIds);
        }
        return query;
    }
    
    public static String getPendingPayments(String process, Set<Id> recordsForResubmission){
        return getPendingPayments(process, recordsForResubmission, false);
    }
    
    public static String getPendingPaymentsCount(String process, Set<Id> recordsForResubmission){
        return getPendingPayments(process, recordsForResubmission, true);
    }
    
    private static String getPendingPaymentQuery(String effectiveDate, String strActiveStatuses, Integer maxNumOfAttempts, Boolean count){
        String[] fields = new String[]{
            'cmbls__Effective_Date__c','cmbls__ACH_Batch__r.cmbls__Status__c','cmbls__ACH_Batch__r.cmbls__Number_of_Settled_Payments__c',
            'cmbls__ACH_Batch__r.cmbls__Total_Settled_Payment_Amount__c','cmbls__ACH_Batch__r.cmbls__Number_of_Transactions__c',
            'cmbls__ACH_Batch__r.cmbls__Number_of_Pending_Payments__c','cmbls__ACH_Batch__r.cmbls__Total_Pending_Payment_Amount__c',
            'cmbls__ACH_Batch__r.cmbls__Number_of_Failed_Payments__c','cmbls__ACH_Batch__r.cmbls__Total_Failed_Payment_Amount__c',
            'cmbls__ACH_Batch__r.cmbls__Total_Transaction_Amount__c','cmbls__ACH_Batch__c','cmbls__ACH_Processor__c','cmbls__Account__c',
            'cmbls__Memo__c','cmbls__Bank_Account_Number__c','cmbls__Type_of_Account__c','cmbls__Bank_Routing_Number__c','cmbls__Status__c',
            'cmbls__Transaction_Amount__c','Wells_Fargo_Payment_ID_Formula__c','cmbls__ACH_Batch__r.WellsFargo_Number_of_Attempts__c'
        };
        
        String strFields = count ? 'COUNT()' : String.join(fields, ', ');
        
        return  'SELECT '+ strFields +' FROM cmbls__Payment__c WHERE ' +
                '(' +
                    'cmbls__ACH_Batch__r.cmbls__ACH_Provider_Name__c LIKE \'Wells Fargo%\' AND ' +
                    'cmbls__ACH_Batch__r.cmbls__Effective_Date__c = ' + effectiveDate + ' AND ' +
                    'RecordTypeId = \''+ PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID +'\' AND ' +
                    'cmbls__Status__c = \''+ PaymentUtils.PAYMENT_STATUS_SCHEDULED +'\' AND ' +
                    'cmbls__Transaction_Type__c = \'' + PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT + '\' AND ' +
                    'cmbls__Repayment__r.cmbls__Status__c IN ' + strActiveStatuses+ ' AND ' +
                    '(cmbls__ACH_Batch__r.WellsFargo_Number_of_Attempts__c = NULL OR cmbls__ACH_Batch__r.WellsFargo_Number_of_Attempts__c < ' + maxNumOfAttempts + ')' +
                ')';
    }
    
    private static String getPendingDisbursementQuery(String effectiveDate, String strActiveStatuses, Integer maxNumOfAttempts, Boolean count){
        String[] fields = new String[]{
            'cmbls__Effective_Date__c', 'cmbls__Disbursement_Batch__r.cmbls__Status__c',
            'cmbls__Disbursement_Batch__r.cmbls__Number_of_Settled_Disbursements__c',
            'cmbls__Disbursement_Batch__r.cmbls__Total_Settled_Disbursement_Amount__c',
            'cmbls__Disbursement_Batch__r.cmbls__Number_of_Transactions__c',
            'cmbls__Disbursement_Batch__r.cmbls__Number_of_Pending_Disbursements__c',
            'cmbls__Disbursement_Batch__r.cmbls__Total_Pending_Disbursement_Amount__c',
            'cmbls__Disbursement_Batch__r.cmbls__Number_of_Failed_Disbursements__c',
            'cmbls__Disbursement_Batch__r.cmbls__Total_Failed_Disbursement_Amount__c',
            'cmbls__Disbursement_Batch__r.cmbls__Total_Transaction_Amount__c', 'cmbls__Disbursement_Batch__c',
            'cmbls__ACH_Processor__c', 'cmbls__Status__c', 'cmbls__Memo__c', 'cmbls__Transaction_Amount__c',
            'cmbls__Payee_Name__c', 'cmbls__Bank_Account_Number__c', 'cmbls__Bank_Account_Type__c',
            'cmbls__Bank_Routing_Number__c', 'Wells_Fargo_Disbursement_ID_Formula__c',
            'cmbls__Disbursement_Batch__r.WellsFargo_Number_of_Attempts__c'
        };
        
        String strFields = count ? 'COUNT()' : String.join(fields, ', ');
        
        return 'SELECT '+ strFields +' FROM cmbls__Disbursement__c WHERE ' +
        '(' +
            'cmbls__Disbursement_Batch__r.cmbls__ACH_Provider_Name__c LIKE \'Wells Fargo%\' AND ' +
            'cmbls__Status__c = \''+ PaymentUtils.PAYMENT_STATUS_SCHEDULED + '\' AND ' +
            'cmbls__Disbursement_Batch__r.cmbls__Effective_Date__c = ' + effectiveDate + ' AND ' +
            'cmbls__Repayment__r.cmbls__Status__c != NULL AND ' +
            '(cmbls__Disbursement_Batch__r.WellsFargo_Number_of_Attempts__c = NULL OR cmbls__Disbursement_Batch__r.WellsFargo_Number_of_Attempts__c < ' + maxNumOfAttempts + ') AND ' +
            '(' +
                '(' +
                    'RecordTypeId = \'' + DisbursementUtils.PAYMENT_RECORD_TYPE_REFUND + '\' AND ' +
                    '(' +
                        'cmbls__Repayment__r.cmbls__Status__c = \'' + RepaymentUtils.STATUS_COMPLETE + '\' OR ' +
                        'CreatedById IN ' + getAccountingPeriodFullAccessUserIdsForQuery() +
                    ')' +
                ') ' +
                'OR ' +
                '(' +
                    'RecordTypeId != \''+ DisbursementUtils.PAYMENT_RECORD_TYPE_REFUND + '\' AND ' +
                    '(' +
                        'cmbls__Repayment__r.cmbls__Status__c IN ' + strActiveStatuses+ ' OR ' +
                        'RecordTypeId = \''+ DisbursementUtils.PAYMENT_RECORD_TYPE_TRANSFER + '\'' +
                    ')' +
                ')' +
            ') ' +
        ')';
    }
    
    private static List<Id> accountingPeriodFullAccessUserIds;
    public static List<Id> getAccountingPeriodFullAccessUserIds(){
        if(accountingPeriodFullAccessUserIds == null){
            Set<Id> userIds = new Set<Id>();
            for(PermissionSetAssignment assignment : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :ACCOUNTING_PERIOD_FULL_ACCESS_PERMISSION_NAME]){
                userIds.add(assignment.AssigneeId);
            }
            accountingPeriodFullAccessUserIds = new List<Id>(userIds);
        }
        
        return accountingPeriodFullAccessUserIds;
    }
    
    public static String getAccountingPeriodFullAccessUserIdsForQuery(){
        return UtilityTools.getStringListForINSOQLClause(getAccountingPeriodFullAccessUserIds());
    }
    
    public static String getSentToWellsFargoPendingPaymentsQuery(){
        return getSentToWellsFargoPendingPaymentsQuery(false);
    }
    
    public static Integer getSentToWellsFargoPendingPaymentsCount(){
        return Database.countQuery(getSentToWellsFargoPendingPaymentsQuery(true));
    }
    
    private static String getSentToWellsFargoPendingPaymentsQuery(Boolean getCount){
        String validPaymentStatus = '(\''+ PaymentUtils.PAYMENT_STATUS_SCHEDULED +'\',\''+ PaymentUtils.PAYMENT_STATUS_CANCELED + '\')';
        String query = 'SELECT ' + (getCount ? 'COUNT() ' : 'Id, Payment__c, Disbursement__c, Pre_Pending_Update_Attempts__c, CreatedDate ') +
            'FROM ACH_Transaction_Log__c ' +
            'WHERE Status__c = \'' + Constant.ACH_TRANSACTION_LOG_WF_SENT + '\' AND ' +
            'Response_Code__c = \'201\' AND ' +
            '(Pre_Pending_Update_Attempts__c = NULL OR Pre_Pending_Update_Attempts__c < ' + SentPaymentsProcessorBatch.getPrePendingUpdateMaxAttempts() + ') AND ' +
            '(Payment__r.cmbls__Status__c IN '+validPaymentStatus+' OR Disbursement__r.cmbls__Status__c IN '+validPaymentStatus+')';
        return query;
    }
    
    public static String getRepaymentActiveStatuses(){
        initRepStatuses();
        return UtilityTools.getStringListForINSOQLClause(activeStatuses);
    }
    
    public static void processACHBatchOnUpdate(cmbls__Payment__c[] records, Map<Id, cmbls__Payment__c> oldMap){
        if(oldMap == null) return;
        Set<Id> recordsToUpdate = new Set<Id>();
        for(cmbls__Payment__c item :records){
            cmbls__Payment__c oldItem = oldMap.get(item.Id);
            Boolean shouldChangeBatch = (item.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_SCHEDULED && String.isBlank(item.cmbls__ACH_Batch__c) &&
                oldItem.cmbls__ACH_Batch__c != item.cmbls__ACH_Batch__c) ||
                oldItem.cmbls__Effective_Date__c != item.cmbls__Effective_Date__c ||
                oldItem.cmbls__ACH_Processor__c != item.cmbls__ACH_Processor__c;
            if(shouldChangeBatch) recordsToUpdate.add(item.Id);
        }
        
        if(!recordsToUpdate.isEmpty()){
            String[] queryConditions = new String[]{};
            for(cmbls__Payment__c item :records){
                if(recordsToUpdate.contains(item.Id)){
                    queryConditions.add('(cmbls__Effective_Date__c = ' + DateTimeUtils.getSOQLDateFormat(item.cmbls__Effective_Date__c) + ' AND cmbls__ACH_Provider_Name__c = \'' + item.cmbls__ACH_Processor__c + '\')');
                }
            }
            
            String query = 'SELECT Id, cmbls__Effective_Date__c, cmbls__ACH_Provider_Name__c FROM cmbls__ACH_Batch__c WHERE cmbls__Status__c = \'Pending\' AND (' + String.join(queryConditions, ' OR ') + ')';
            Map<String, cmbls__ACH_Batch__c> achBatchMap = new Map<String, cmbls__ACH_Batch__c>();
            for(cmbls__ACH_Batch__c item :Database.query(query)){
                achBatchMap.put(item.cmbls__ACH_Provider_Name__c + '#' + item.cmbls__Effective_Date__c, item);
            }
            
            Set<Id> recordsWithoutBatches = new Set<Id>();
            Map<String, cmbls__ACH_Batch__c> achBatchesToCreate = new Map<String, cmbls__ACH_Batch__c>();
            for(cmbls__Payment__c item :records){
                if(recordsToUpdate.contains(item.Id)){
                    String key = item.cmbls__ACH_Processor__c + '#' + item.cmbls__Effective_Date__c;
                    if(!achBatchMap.containsKey(key)){
                        achBatchesToCreate.put(key, new cmbls__ACH_Batch__c(
                            cmbls__Status__c = 'Pending',
                            cmbls__Effective_Date__c = item.cmbls__Effective_Date__c,
                            cmbls__ACH_Provider_Name__c = item.cmbls__ACH_Processor__c
                        ));
                        recordsWithoutBatches.add(item.Id);
                    }else{
                        item.cmbls__ACH_Batch__c = achBatchMap.get(key).Id;
                    }
                }
            }
            
            if(!achBatchesToCreate.isEmpty()){
                insert achBatchesToCreate.values();
                for(cmbls__Payment__c item :records){
                    if(recordsWithoutBatches.contains(item.Id)){
                        String key = item.cmbls__ACH_Processor__c + '#' + item.cmbls__Effective_Date__c;
                        item.cmbls__ACH_Batch__c = achBatchesToCreate.get(key).Id;
                    }
                }
            }
        }
    }
    
    public static Boolean shouldMoveRepaymentToActive(cmbls__Payment__c record, cmbls__Payment__c oldRecord){
        return  (oldRecord == null || record.cmbls__Status__c != oldRecord.cmbls__Status__c) && 
                record.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_SETTLED &&
                record.RecordTypeId == PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID &&
                record.cmbls__Transaction_Type__c == PaymentUtils.PAYMENT_TRANSACTION_TYPE_ADJUSTMENT &&
                record.cmbls__Sub_Type__c == PaymentUtils.PAYMENT_SUBTYPE_REVERSAL;
    }
    
    private static List<String> activeStatuses;
    private static void initRepStatuses(){
        if(activeStatuses == null){
            activeStatuses = new List<String>{RepaymentUtils.STATUS_ACTIVE};
            for(cmbls__Active_Repayment_Statuses__c ars : [SELECT cmbls__Status__c FROM cmbls__Active_Repayment_Statuses__c]){
                activeStatuses.add(ars.cmbls__Status__c);
            }
        }
    }
}