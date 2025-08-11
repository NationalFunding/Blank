/**
 * RepaymentService class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class RepaymentService{
    
    public static void pauseAndResumeRepayment(Id repaymentId, Date resumeDate){
        update new cmbls__Repayment__c(Id = repaymentId, Pause_Date__c = System.today(), Resume_Date__c = resumeDate);
    }
    
    public static String reactivateRepaymentFromInvocable(ReactivateRepayment.ReactivateRequest mainRequest){
        String[] output = new String[]{};
        cmbls__Repayment__c repayment = RepaymentSelector.getRepaymentAndSchedulesById(mainRequest.repaymentId);
        repayment.cmbls__Status__c = RepaymentUtils.STATUS_ACTIVE;
        repayment.Notes__c = String.isNotBlank(repayment.Notes__c) ? '\n\n' : '';
        repayment.Notes__c += String.format(ReactivateRepayment.REPAYMENT_NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : '')
        }) + '\n\n' + mainRequest.notes;
        
        String notes = String.format(ReactivateRepayment.REPAYMENT_SCHEDULE_NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : '')
        }) + '\n\n' + mainRequest.notes;
        
        for(cmbls__Repayment_Schedule__c item :repayment.cmbls__Repayment_Schedules__r){
            item.cmbls__Next_Payment_Date__c = null;
            item.cmbls__Notes__c = String.isNotBlank(repayment.Notes__c) ? '\n\n' : '';
            item.cmbls__Notes__c += notes;
            output.add(item.Id);
        }
        
        Database.update(repayment);
        if(!output.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            Database.update(repayment.cmbls__Repayment_Schedules__r, dml);
            return String.join(output, ', ');
        }
        return '';
    }
    
    public static String updateBankingInformationFromInvocable(UpdateBankingInformation.UpdateRequest mainRequest){
        cmbls__Repayment__c record = RepaymentSelector.getRepaymentById(mainRequest.repaymentId);
        String priorBankName = record.cmbls__Bank_Name__c;
        String priorBankAccountNumber = record.cmbls__Bank_Account_Number__c;
        String priorBankRoutingNumber = record.cmbls__Bank_Routing_Number__c;
        
        String notes = String.format(UpdateBankingInformation.NOTE, new String[]{
            System.now().format('MM/dd/YYYY HH:mm'),
            (String.isNotBlank(mainRequest.fromRecord) ? ' from ' + mainRequest.fromRecord : ''),
            priorBankName, priorBankRoutingNumber, priorBankAccountNumber,
            mainRequest.bankName, mainRequest.bankRoutingNumber, mainRequest.bankAccountNumber
        }) + mainRequest.notes;
        
        record.cmbls__Bank_Account_Number__c = mainRequest.bankAccountNumber;
        record.cmbls__Bank_Name__c = mainRequest.bankName;
        record.cmbls__Bank_Routing_Number__c = mainRequest.bankRoutingNumber;
        record.cmbls__Type_of_Account__c = mainRequest.bankAccountType;
        record.Notes__c = String.isNotBlank(record.Notes__c) ? '\n\n' : '';
        record.Notes__c += notes;
    
        cmbls__Payment__c[] paymentsToUpdate = new cmbls__Payment__c[]{};
        cmbls__Repayment_Schedule__c[] schedulesToUpdate = new cmbls__Repayment_Schedule__c[]{};
        Id[] updatedPaymentIds = new Id[]{};
        Id[] updatedSchedulesIds = new Id[]{};
        if(mainRequest.updateScheduledPayments){
            Map<Id, cmbls__Payment__c[]> paymentsMap = PaymentSelector.getScheduledCreditPaymentsByRepaymentIds(new Set<Id>{mainRequest.repaymentId});
            if(paymentsMap.containsKey(mainRequest.repaymentId)){
                for(cmbls__Payment__c payment :paymentsMap.get(mainRequest.repaymentId)){
                    payment.cmbls__Bank_Account_Number__c = mainRequest.bankAccountNumber;
                    payment.cmbls__Bank_Routing_Number__c = mainRequest.bankRoutingNumber;
                    payment.cmbls__Type_of_Account__c = mainRequest.bankAccountType;
                    payment.cmbls__Notes__c = String.isNotBlank(payment.cmbls__Notes__c) ? '\n\n' : '';
                    payment.cmbls__Notes__c += notes;
                    System.debug(payment);
                    paymentsToUpdate.add(payment);
                    updatedPaymentIds.add(payment.Id);
                }
            }
        }
        
        if(mainRequest.updateRepaymentSchedules){
            for(cmbls__Repayment_Schedule__c item :RepaymentScheduleSelector.getRepaymentSchedulesByRepaymentIds(new Set<Id>{mainRequest.repaymentId})){
                if(item.cmbls__Active__c && String.isNotBlank(item.cmbls__Bank_Account_Number__c) && String.isNotBlank(item.cmbls__Bank_Routing_Number__c)){
                    item.cmbls__Bank_Account_Number__c = mainRequest.bankAccountNumber;
                    item.cmbls__Bank_Routing_Number__c = mainRequest.bankRoutingNumber;
                    item.cmbls__Notes__c = String.isNotBlank(item.cmbls__Notes__c) ? '\n\n' : '';
                    item.cmbls__Notes__c += notes;
                    schedulesToUpdate.add(item);
                    updatedSchedulesIds.add(item.Id);
                }
            }
        }
    
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        
        Database.update(record);
        Database.update(schedulesToUpdate, dml);
        Database.update(paymentsToUpdate, dml);
        
        return String.format(UpdateBankingInformation.OUTPUT, new String[]{
            mainRequest.repaymentId,
            String.valueOf(updatedPaymentIds.size()),
            (updatedPaymentIds.isEmpty() ? '' : String.join(updatedPaymentIds, ', ')),
            String.valueOf(updatedSchedulesIds.size()),
            (updatedSchedulesIds.isEmpty() ? '' : String.join(updatedSchedulesIds, ', '))
        });
    }
    
    public static void relateDisbursements(cmbls__Repayment__c[] records){
        Map<Id, cmbls__Repayment__c> repaymentsByOpportunity = new Map<Id, cmbls__Repayment__c>();
        for(cmbls__Repayment__c rep : records){
            repaymentsByOpportunity.put(rep.Opportunity__c, rep);
        }
    
        cmbls__Disbursement__c[] toUpdate = DisbursementSelector.getStagingDisbursementsForGivenOpportunities(repaymentsByOpportunity.keySet());
        for(cmbls__Disbursement__c dis : toUpdate){
            dis.cmbls__Repayment__c = repaymentsByOpportunity.get(dis.Opportunity__c).Id;
            dis.cmbls__Status__c = DisbursementUtils.DISBURSEMENT_STATUS_SCHEDULED;
        }
        
        update toUpdate;
    }
    
    public static void createExpenses(cmbls__Repayment__c[] records){
        List<cmbls__Expense__c> toInsert = new List<cmbls__Expense__c>();
        for(cmbls__Repayment__c rep : records){
            if(rep.cmbls__Origination_Fee__c > 0){
                toInsert.add(new cmbls__Expense__c(
                    cmbls__Repayment__c = rep.Id,
                    cmbls__Amount__c = rep.cmbls__Origination_Fee__c,
                    RecordTypeId = RepaymentUtils.EXPENSE_RECORD_TYPE_INCOME,
                    cmbls__Fee_Type__c = RepaymentUtils.ORIGINATION_FEE
                ));
            }
            
            if(rep.Total_Broker_Fee__c > 0){
                toInsert.add(new cmbls__Expense__c(
                    cmbls__Repayment__c = rep.Id,
                    cmbls__Amount__c = rep.Total_Broker_Fee__c,
                    RecordTypeId = RepaymentUtils.EXPENSE_RECORD_TYPE_EXPENSE,
                    cmbls__Fee_Type__c = RepaymentUtils.BROKER_FEE
                ));
            }
        }
        insert toInsert;
    
    }
    
    public static void createTransferQueuedEvents(cmbls__Repayment__c[] records, Map<Id, cmbls__Repayment__c> oldMap){
        Set<Id> recordIds = new Set<Id>();
        for(cmbls__Repayment__c item : RepaymentSelector.getQuickBridgeFundedRecords(new Map<Id, cmbls__Repayment__c>(records).keySet())){
            if(item.cmbls__Loan_Transfers__r.isEmpty() && item.cmbls__Loan_Start_Date__c != null){
                recordIds.add(item.Id);
            }
        }
        
        if(recordIds.isEmpty()) return;
        
        //Get existing pending Queued Events for these repayments we should create transfer records
        Set<Id> existingQueuedEvents = TransferQueuedEventBatch.getExistingEventsForGivenRecordIds(recordIds);
    
        //If we have the same size of existing Queued Events, means we already have this ids pending to be processed, exit, nothing else is needed
        if(existingQueuedEvents.size() == recordIds.size()) return;
    
        cmbls__Queued_Event__c[] queuedEvents = new cmbls__Queued_Event__c[]{};
        Map<Id, cmbls__Repayment__c> recordMap = new Map<Id, cmbls__Repayment__c>(records);
        for(Id item :recordIds){
            //If not an existing pending Queued Event, then include to the list to be saved
            if(!existingQueuedEvents.contains(item)){
                Date processOn = DateTimeUtils.getMaxDate(recordMap.get(item).cmbls__Loan_Start_Date__c, recordMap.get(item).cmbls__Funded_Date__c);
                if(recordMap.get(item).cmbls__Funded_Date__c == processOn) processOn = processOn.addDays(1);
                
                queuedEvents.add(new cmbls__Queued_Event__c(
                    cmbls__Date_Processed__c = null,
                    cmbls__Record_Id__c = item,
                    cmbls__Type__c = TransferQueuedEventBatch.TRANSFER_RECORDS_CREATION,
                    Process_On__c = processOn
                ));
            }
        }
        insert queuedEvents;
    }
    
    public static void createTransferRecords(cmbls__Queued_Event__c[] queuedEvents){
        LoanTransfer cls = new LoanTransfer(queuedEvents);
        cls.processQueuedEvents();
        cls.save();
    }
    
    public static void moveRepaymentsFromCompletedToActive(Set<Id> repaymentIds){
        Map<Id, cmbls__Repayment__c> repaymentMap = new Map<Id, cmbls__Repayment__c>();
        for(cmbls__Repayment__c repayment :RepaymentSelector.getRepaymentsById(repaymentIds)){
            if(repayment.cmbls__Status__c == RepaymentUtils.STATUS_COMPLETE) repaymentMap.put(repayment.Id, repayment);
        }
        
        if(repaymentMap.isEmpty()) return;
        
        Map<Id, cmbls__Repayment_Schedule__c[]> repaymentScheduleMap = RepaymentScheduleSelector.getActiveRepaymentSchedulesByRepaymentIds(repaymentMap.keySet());
        cmbls__Repayment_Schedule__c[] schedulesToUpdate = new cmbls__Repayment_Schedule__c[]{};
        for(Id repaymentId :repaymentMap.keySet()){
            repaymentMap.get(repaymentId).cmbls__Status__c = RepaymentUtils.STATUS_ACTIVE;
            if(repaymentScheduleMap.containsKey(repaymentId)){
                for(cmbls__Repayment_Schedule__c schedule :repaymentScheduleMap.get(repaymentId)){
                    schedule.cmbls__Next_Payment_Date__c = null;
                    schedulesToUpdate.add(schedule);
                }
            }
        }
        
        update schedulesToUpdate;
        update repaymentMap.values();
    }
    
}