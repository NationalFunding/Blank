/**
 * ChartOfAccountService class
 * @author CloudMyBiz (r)
 * @date 10/26/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global inherited sharing class ChartOfAccountService{
    public static final String ERROR_MESSAGE = 'Unable to Populate GL Accounts due to the following errors: \n\n{0}';
    
    @TestVisible private static final String ERROR_MISSING_REPAYMENT_LOOKUP = 'Missing Repayment Lookup (Repayment__c) on {0} object.';
    @TestVisible private static final String ERROR_MISSING_REPAYMENT_RECORD = 'Missing Repayment record related.';
    @TestVisible private static final String ERROR_MISSING_RECORD_CONFIG = 'Missing object configuration for {0} object.';
    @TestVisible private static final String ERROR_MISSING_TYPE_ENTITY = 'Product Type / Entity configuration not found: {0} - {1}.';
    @TestVisible private static final String ERROR_SUBJECT = 'Loan Servicing - Chart of Accounts - Populate GL Records: Process Error';
    @TestVisible private static final String ERROR_EXISTING_RECORD = 'Duplicate Record - There is an existing {0} with same values: {1}';
    @TestVisible private static final String ERROR_INVALID_OBJECT = 'Invalid or Null Object (API Name): {0}';
    @TestVisible private static final String ERROR_INVALID_GL_FIELD = 'Not a valid field for {0}';
    
    @TestVisible private static final String DEBUG_LOG_SOBJECT_UPDATE_FAILURE_SUBJECT = 'Loan Servicing - Chart of Accounts - Populate GL Records: Update Related Record Failure';
    @TestVisible private static final String DEBUG_LOG_SOBJECT_UPDATE_FAILURE_DESCRIPTION = '{0} record tried to be updated but failed';
    @TestVisible private static Boolean SKIP_LOGIC_ON_TEST = false;
    @TestVisible private static Boolean THROW_EXCEPTION_ON_TEST = false;
    @TestVisible private static Id testPaymentRecordFailureId;
    public static String QUEUED_EVENT_TYPE = 'CHART_OF_ACCOUNTS';
    
    @InvocableMethod(Label='Populate GL Accounts')
    global static String[] mainInvocableMethod(ChartOfAccountRequest[] request){
        String[] response = new String[]{};//needed for Flows, we need to return the same amount of results of requests
        Set<Id> recordIds = new Set<Id>();
        if(request != null){
            for(ChartOfAccountRequest item : request){
                response.add(item.recordId);
                recordIds.add(item.recordId);
            }
        }
        if(Test.isRunningTest() && SKIP_LOGIC_ON_TEST) return response;
        try{
            createQueuedEvent(recordIds);
        }catch(Exception e){
            insert new cmbls__Debug_Log__c(
                cmbls__Subject__c = ERROR_SUBJECT,
                cmbls__Description__c = e.getMessage(),
                cmbls__Log__c = String.format(ERROR_MESSAGE, new String[]{e.getStackTraceString()})
            );
        }
        return response;
    }
    
    public static void validateChartOfAccountRecordCreation(Chart_of_Account__c[] records){
        Chart_of_Account__c[] existingRecords = ChartOfAccountSelector.getChartOfAccounts();
        for(Chart_of_Account__c record :records){
            SObjectType selectedObject = Schema.getGlobalDescribe().get(record.Object_API_Name__c);
            if(selectedObject == null){
                record.addError('Object_API_Name__c', String.format(ERROR_INVALID_OBJECT, new String[]{record.Object_API_Name__c}));
                continue;
            }else if(!selectedObject.getDescribe().fields.getMap().containsKey(record.GL_Account_Field_API_Name__c.toLowerCase())){
                record.addError('GL_Account_Field_API_Name__c', String.format(ERROR_INVALID_GL_FIELD, new String[]{record.Object_API_Name__c}));
                continue;
            }
            
            for(Chart_of_Account__c existing :existingRecords){
                if(record.Id != existing.Id && record.Object_API_Name__c == existing.Object_API_Name__c && record.GL_Account_Field_API_Name__c == existing.GL_Account_Field_API_Name__c){
                    record.addError(String.format(ERROR_EXISTING_RECORD, new String[]{Chart_of_Account__c.getSObjectType().getDescribe().getLabel(), existing.Name}));
                    break;
                }
            }
        }
    }
    
    public static void validateChartOfAccountKeyRecordCreation(Chart_of_Account_Key__c[] records){
        Chart_of_Account_Key__c[] existingRecords = ChartOfAccountSelector.getChartOfAccountKeys();
        for(Chart_of_Account_Key__c record :records){
            for(Chart_of_Account_Key__c existing :existingRecords){
                if(record.Id != existing.Id){
                    if(String.isNotBlank(record.Product_Type__c) && record.Product_Type__c == existing.Product_Type__c && record.Company__c == existing.Company__c){
                        record.addError(String.format(ERROR_EXISTING_RECORD, new String[]{Chart_of_Account_Key__c.getSObjectType().getDescribe().getLabel(), existing.Name}));
                        break;
                    }
                }
            }
        }
    }
    
    public static void createQueuedEvent(Set<Id> recordIds){
        Set<Id> existingQueuedEvents = new Set<Id>();
        for(cmbls__Queued_Event__c item :getNotProcessedEventsByRecords(recordIds)){
            existingQueuedEvents.add(item.cmbls__Record_Id__c);
        }
        
        cmbls__Queued_Event__c[] records = new cmbls__Queued_Event__c[]{};
        for(Id recordId :recordIds){
            if(!existingQueuedEvents.contains(recordId)){
                records.add(new cmbls__Queued_Event__c(
                    cmbls__Record_Id__c = recordId,
                    cmbls__Type__c = QUEUED_EVENT_TYPE
                ));
            }
        }
        
        insert records;
    }
    
    public static void processQueuedEvents(cmbls__Queued_Event__c[] queuedEvents){

        Map<Id, cmbls__Queued_Event__c> eventsByRecordId = new Map<Id, cmbls__Queued_Event__c>();
        cmbls__Debug_Log__c[] debugLogs = new cmbls__Debug_Log__c[]{};
        
        try{
            if(Test.isRunningTest() && THROW_EXCEPTION_ON_TEST) throw new ChartOfAccountException('TEST EXCEPTION');
            
            SObject[] recordsToUpdate = new SObject[]{};

            //We need to separate the record ids (queuedEvent.cmbls__Record_Id__c) by type, to run queries
            Map<String, Set<Id>> recordIdsByType = new Map<String, Set<Id>>();
            for(cmbls__Queued_Event__c event :queuedEvents){
                String objectType = ((Id)event.cmbls__Record_Id__c).getSobjectType().getDescribe().getName();
                if(!recordIdsByType.containsKey(objectType)) recordIdsByType.put(objectType, new Set<Id>());
                recordIdsByType.get(objectType).add((Id)event.cmbls__Record_Id__c);
                eventsByRecordId.put(event.cmbls__Record_Id__c, event);
            }
            
            //This will perform queries inside a loop, no other way to do this since the fields and objects we need to query
            //are dynamic, however, this scenario will not exceed 6 or 7 objects types, so worst scenario, this will perform
            //7 queries
            Map<Id, SObject> affectedRecordsMap = new Map<Id, SObject>();
            for(String objectName :recordIdsByType.keySet()){
                SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                affectedRecordsMap.putAll(new Map<Id, SObject>(getRelatedSObjectRecords(objectType, recordIdsByType.get(objectName))));
            }
            
            for(String objectTypeKey :recordIdsByType.keySet()){
                SObject[] recordsToProcess = new SObject[]{};
                for(Id recordId :recordIdsByType.get(objectTypeKey)){
                    if(affectedRecordsMap.containsKey(recordId)){
                        recordsToProcess.add(affectedRecordsMap.get(recordId));
                    }else{
                        eventsByRecordId.put(recordId, populateEventFields(eventsByRecordId.get(recordId), null, true));
                    }
                }
                
                if(!recordsToProcess.isEmpty()){
                    ChartOfAccount instance = new ChartOfAccount(recordsToProcess);
                    debugLogs.addAll(instance.getErrors());
                    recordsToUpdate.addAll(instance.getRecordsToUpdate());

                    Set<Id> recordsWithErrors = instance.getRecordIdsWithErrors();
                    for(Id recordId :recordIdsByType.get(objectTypeKey)){
                        if(!recordsWithErrors.contains(recordId) && affectedRecordsMap.containsKey(recordId)){
                            eventsByRecordId.put(recordId, populateEventFields(eventsByRecordId.get(recordId), System.now(), false));
                        // If the record has any issues update number of attempts to the associated queued event
                        }else if(recordsWithErrors.contains(recordId)){
                            eventsByRecordId.put(recordId, populateEventFields(eventsByRecordId.get(recordId), null, false));
                        }
                    }
                }
            }

            //Test failure
            if(Test.isRunningTest() && String.isNotBlank(testPaymentRecordFailureId)){
                for(SObject record :recordsToUpdate){
                    if(record.Id == testPaymentRecordFailureId) record.put('cmbls__Transaction_Amount__c', null);
                }
            }
            
            Integer index = 0;
            for(Database.SaveResult result :Database.update(recordsToUpdate, false)){
                if(!result.isSuccess()){
                    SObject record = recordsToUpdate[index];
                    eventsByRecordId.get(record.Id).cmbls__Date_Processed__c = null;
                    cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLFailure(null, record, result);
                    log.cmbls__Subject__c = DEBUG_LOG_SOBJECT_UPDATE_FAILURE_SUBJECT;
                    log.cmbls__Queued_Event__c = eventsByRecordId.get(record.Id).Id;
                    log.cmbls__Description__c = String.format(DEBUG_LOG_SOBJECT_UPDATE_FAILURE_DESCRIPTION, new String[]{
                        record.getSObjectType().getDescribe().getLabel()
                    });
                    debugLogs.add(log);
                }
                index++;
            }
        }catch(Exception e){
            debugLogs.add(new cmbls__Debug_Log__c(
                cmbls__Subject__c = ERROR_SUBJECT,
                cmbls__Description__c = e.getMessage(),
                cmbls__Log__c = String.format(ERROR_MESSAGE, new String[]{e.getStackTraceString()})
            ));
        }finally{
            insert debugLogs;
            update eventsByRecordId.values();
        }
    }
    
    public static cmbls__Queued_Event__c[] getNotProcessedEventsByRecords(Set<Id> records){
        return [
            SELECT Id, cmbls__Record_Id__c FROM cmbls__Queued_Event__c
            WHERE cmbls__Type__c = :QUEUED_EVENT_TYPE
            AND cmbls__Date_Processed__c = NULL
            AND Deleted_Record_Id__c = FALSE
            AND cmbls__Record_Id__c IN: records
        ];
    }
    
    public static Integer getBatchSize(){
        National_Funding_Settings__c settings = National_Funding_Settings__c.getInstance();
        return (settings.Chart_of_Account_Batch_Size__c != null) ? Integer.valueOf(settings.Chart_of_Account_Batch_Size__c) : 20;
    }
    
    private static SObject[] getRelatedSObjectRecords(SObjectType sObjectType, Set<Id> recordIds){
        String objectName = sObjectType.getDescribe().getName();
        List<String> objectFields = new List<String>(sObjectType.getDescribe().fields.getMap().keySet());
        if(sObjectType == cmbls__Payment__c.getSObjectType()) objectFields.add('cmbls__Reversal_Of__r.Cash_GL__c');
        return Database.query('SELECT ' + String.join(objectFields, ',') + ' FROM ' + objectName + ' WHERE Id IN :recordIds');
    }
    
    private static cmbls__Queued_Event__c populateEventFields(cmbls__Queued_Event__c event, Datetime dateProcessed, Boolean isDeletedRecord){
        if(event != null){
            event.Deleted_Record_Id__c = isDeletedRecord;
            event.cmbls__Date_Processed__c = dateProcessed;
            event.cmbls__Last_Attempt__c = System.now();
            event.cmbls__Number_of_Attempts__c = NumberUtils.getInteger(event.cmbls__Number_of_Attempts__c) + 1;
        }
        return event;
    }
    
    global class ChartOfAccountRequest {
        @InvocableVariable(Label='Record Id' Required=true)
        global Id recordId;
        
        @InvocableVariable(Label='Save Records?' Required=true)
        global Boolean saveRecords;
    }
    
    public class ChartOfAccount{
        private cmbls__Debug_Log__c[] errors = new cmbls__Debug_Log__c[]{};
        private SObject[] recordsToProcess = new SObject[]{};
        private SObject[] recordsToUpdate = new SObject[]{};
        private Map<Id, cmbls__Repayment__c> repaymentMap;
        private Chart_of_Account_Key__c[] chartOfAccountKeys;
        private Chart_of_Account__c[] chartOfAccounts;
        
        public ChartOfAccount(SObject[] records){
            Set<Id> repaymentIds = new Set<Id>();
            for(SObject record :records){
                if(this.isRepaymentRecord(record)){
                    repaymentIds.add(record.Id);
                    this.recordsToProcess.add(record);
                    continue;
                }
                
                if(!this.isInterCompanyTransactionRecord(record) && this.getRepaymentLookupFieldName(record) == null){
                    this.errors.add(new cmbls__Debug_Log__c(
                        cmbls__Subject__c = ERROR_SUBJECT,
                        cmbls__Description__c = String.format(ERROR_MISSING_REPAYMENT_LOOKUP, new String[]{record.getSObjectType().getDescribe().getName()}),
                        cmbls__Record_Id__c = record.Id
                    ));
                    continue;
                }
                
                if(!this.isInterCompanyTransactionRecord(record)) repaymentIds.add(this.getRepaymentLookupId(record));
                this.recordsToProcess.add(record);
            }
            this.processRecords(repaymentIds);
        }

        public SObject[] getRecordsToUpdate(){
            return this.recordsToUpdate;
        }
    
        public cmbls__Debug_Log__c[] getErrors(){
            return this.errors;
        }
        
        public Set<Id> getRecordIdsWithErrors(){
            Set<Id> output = new Set<Id>();
            for(cmbls__Debug_Log__c item :this.errors) output.add(item.cmbls__Record_Id__c);
            return output;
        }
        
        private void processRecords(Set<Id> repaymentIds){
            this.repaymentMap = new Map<Id, cmbls__Repayment__c>(RepaymentSelector.getRepaymentsById(repaymentIds));
            for(SObject record :this.recordsToProcess){
                cmbls__Repayment__c repayment;
                if(this.isInterCompanyTransactionRecord(record)){
                    repayment = new cmbls__Repayment__c();
                }else{
                    repayment = this.isRepaymentRecord(record) ?
                                this.repaymentMap.get(record.Id) :
                                this.repaymentMap.get((Id)record.get(this.getRepaymentLookupFieldName(record)));
                }
                
                if(repayment == null){
                    this.errors.add(new cmbls__Debug_Log__c(
                        cmbls__Subject__c = ERROR_SUBJECT,
                        cmbls__Description__c = ERROR_MISSING_REPAYMENT_RECORD,
                        cmbls__Record_Id__c = record.Id
                    ));
                    continue;
                }
        
                record = this.setRecord(record, repayment);
                if(record != null) this.recordsToUpdate.add(record);
            }
        }
    
        private SObject setRecord(SObject record, cmbls__Repayment__c repayment){
            Chart_of_Account__c[] chartOfAccounts = this.getChartOfAccountRecords(record);
            if(chartOfAccounts == null) return null;
    
            Chart_of_Account_Key__c[] chartOfAccountKeys = this.getChartOfAccountKeyRecords(record, repayment);
            if(chartOfAccountKeys == null) return null;
            
            for(Chart_of_Account__c chartOfAccount :chartOfAccounts){
                for(Chart_of_Account_Key__c chartOfAccountKey :chartOfAccountKeys){
                    if(this.haveKeyMatch(chartOfAccount, chartOfAccountKey, record, repayment)){
                        record.put(chartOfAccount.GL_Account_Field_API_Name__c, chartOfAccount.get(chartOfAccountKey.Key__c));
                        break;
                    }
                }
            }
            
            if(record.getSObjectType() == cmbls__Payment__c.getSObjectType()){
                cmbls__Payment__c paymentRecord = (cmbls__Payment__c)record;
                if(String.isNotBlank(paymentRecord.cmbls__Reversal_Of__c)){
                    record.put('Cash_GL__c', paymentRecord.cmbls__Reversal_Of__r.Cash_GL__c);
                }
            }
    
            return record;
        }
        
        private Chart_of_Account_Key__c[] getChartOfAccountKeyRecords(SObject record, cmbls__Repayment__c repayment){
            Map<String, Chart_of_Account_Key__c> chartOfAccountKeys = new Map<String, Chart_of_Account_Key__c>();
            
            Map<String, Chart_of_Account__c[]> chartOfAccountByObject = new Map<String, Chart_of_Account__c[]>();
            for(Chart_of_Account__c item :getChartOfAccounts()){
                if(!chartOfAccountByObject.containsKey(item.Object_API_Name__c)) chartOfAccountByObject.put(item.Object_API_Name__c, new Chart_of_Account__c[]{});
                chartOfAccountByObject.get(item.Object_API_Name__c).add(item);
            }
    
            String objectApiName = record.getSObjectType().getDescribe().getName();
            Chart_of_Account__c[] chartOfAccounts = chartOfAccountByObject.get(objectApiName);
            if(chartOfAccounts != null){
                for(Chart_of_Account__c chartOfAccount : chartOfAccounts){
                    for(Chart_of_Account_Key__c item : this.getChartOfAccountKeys()){
                        if(this.haveKeyMatch(chartOfAccount, item, record, repayment)) chartOfAccountKeys.put(item.Key__c, item);
                    }
                }
            }
            
            if(chartOfAccountKeys.isEmpty()){
                this.errors.add(new cmbls__Debug_Log__c(
                    cmbls__Subject__c = ERROR_SUBJECT,
                    cmbls__Description__c = String.format(ERROR_MISSING_TYPE_ENTITY, new String[]{repayment.Product_Type__c, repayment.cmbls__Primary_Fund__r.Name}),
                    cmbls__Record_Id__c = record.Id
                ));
                return null;
            }
            return chartOfAccountKeys.values();
        }
        
        private Boolean haveKeyMatch(Chart_of_Account__c chartOfAccount, Chart_of_Account_Key__c chartOfAccountKey, SObject record, cmbls__Repayment__c repayment){
            String[] fundLookups = this.getFundLookupFields(chartOfAccount.Fund_Lookup__c);
            if(!fundLookups.isEmpty()){
                if(fundLookups.size() > 1){
                    Id previousFund = (Id)record.get(fundLookups[0]);
                    Id newFund = (Id)record.get(fundLookups[1]);
                    if(previousFund == chartOfAccountKey.Previous_Company__c && newFund == chartOfAccountKey.Company__c){
                        return true;
                    }
                }else{
                    
                    if(String.isBlank(chartOfAccountKey.Product_Type__c) && this.isInterCompanyTransactionRecord(record)){
                        if((Id)record.get(fundLookups[0]) == chartOfAccountKey.Company__c && String.isBlank(chartOfAccountKey.Previous_Company__c)) return true;
                    }
                    
                    if(String.isNotBlank(chartOfAccountKey.Product_Type__c)){
                        Id fundId = fundLookups[0].equalsIgnoreCase('cmbls__Primary_Fund__c') ? repayment.cmbls__Primary_Fund__c : (Id)record.get(fundLookups[0]);
                        if(fundId == chartOfAccountKey.Company__c && chartOfAccountKey.Product_Type__c.equalsIgnoreCase(repayment.Product_Type__c)){
                            return true;
                        }
                    }
                }
            }
            return false;
        }
        
        private String[] getFundLookupFields(String value){
            String[] output = new String[]{};
            if(String.isNotBlank(value)){
                for(String item :value.split(',')){
                    if(String.isNotBlank(item.trim())) output.add(item.trim());
                }
            }
            return output;
        }
    
        private Chart_of_Account__c[] getChartOfAccountRecords(SObject record){
            String objectName = record.getSObjectType().getDescribe().getName();
            Chart_of_Account__c[] chartOfAccounts = new Chart_of_Account__c[]{};
            Boolean configFound = false;
            for(Chart_of_Account__c item :this.getChartOfAccounts()){
                if(item.Object_API_Name__c.equalsIgnoreCase(objectName)){
                    configFound = true;
                    if(this.sobjectFieldExist(record.getSObjectType(), item.GL_Account_Field_API_Name__c)){
                        chartOfAccounts.add(item);
                    }
                }
            }
    
            if(!configFound){
                this.errors.add(new cmbls__Debug_Log__c(
                    cmbls__Subject__c = ERROR_SUBJECT,
                    cmbls__Description__c = String.format(ERROR_MISSING_RECORD_CONFIG, new String[]{record.getSObjectType().getDescribe().getName()}),
                    cmbls__Record_Id__c = record.Id
                ));
                return null;
            }
            
            return chartOfAccounts;
        }
        
        private Chart_of_Account_Key__c[] getChartOfAccountKeys(){
            if(this.chartOfAccountKeys == null) this.chartOfAccountKeys = ChartOfAccountSelector.getChartOfAccountKeys();
            return this.chartOfAccountKeys;
        }
    
        private Chart_of_Account__c[] getChartOfAccounts(){
            if(this.chartOfAccounts == null) this.chartOfAccounts = ChartOfAccountSelector.getChartOfAccounts();
            return this.chartOfAccounts;
        }
    
        private Id getRepaymentLookupId(SObject record){
            return this.sobjectFieldExist(record.getSObjectType(), 'Repayment__c') ?
                (Id)record.get('Repayment__c') :
                (Id)record.get('cmbls__Repayment__c');
        }
        
        private Boolean isRepaymentRecord(SObject record){
            return cmbls__Repayment__c.getSObjectType() == record.getSObjectType();
        }
    
        private Boolean isInterCompanyTransactionRecord(SObject record){
            return cmbls__Intercompany_Transaction__c.getSObjectType() == record.getSObjectType();
        }
        
        private String getRepaymentLookupFieldName(SObject record){
            if(this.sobjectFieldExist(record.getSObjectType(), 'Repayment__c')){
                return 'Repayment__c';
            }
            else if(this.sobjectFieldExist(record.getSObjectType(), 'cmbls__Repayment__c')){
                return 'cmbls__Repayment__c';
            }
            return null;
        }
    
        public Boolean sobjectFieldExist(SObjectType objectType, String fieldName){
            return objectType.getDescribe().fields.getMap().containsKey(fieldName.toLowerCase());
        }
    }
    
    public class ChartOfAccountException extends Exception{}
}