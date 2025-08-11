/**
 * BatchCheckWFNotifications class
 * @author CloudMyBiz (r)
 * @date 3/28/2023
 */

global inherited sharing class BatchCheckWFNotifications implements Schedulable, Database.AllowsCallouts{
    public static final Set<String> IGNORED_STATUS = new Set<String>{PaymentUtils.PAYMENT_STATUS_FAILED, PaymentUtils.PAYMENT_STATUS_CANCELED};
    public static String accessToken;
    public static SObject[] affectedRecords = new SObject[]{};
    public static cmbls__Payment__c[] reversals = new cmbls__Payment__c[]{};
    public static ACH_Transaction_Log__c[] recordLogs = new ACH_Transaction_Log__c[]{};
    public static Integer pageNumber = 1;
    public static Boolean isTest = false;
    
    global BatchCheckWFNotifications(Integer pageNum){
        pageNumber = pageNum;
    }
    
    global BatchCheckWFNotifications(){}
    
    global void execute(SchedulableContext sc){
        accessToken = WellsFargoAPI.getAccessToken();
        processRequest(pageNumber);
    }
    
    public static void start(){
        System.schedule('WellsFargo - Check Late Return Notifications', '0 0 1,5,7 * * ?', new BatchCheckWFNotifications());
    }
    
    public static void processRequest(Integer pageNum){
        WellsFargo wfRequest = new WellsFargo();
        wfRequest.token = accessToken;
        WellsFargoAPI.achNotificationsCheck(wfRequest, pageNum);
        if(wfRequest.hasErrors){
            if(isTest){
                System.debug('\n\n====================== ACH Logs ===========================\n');
                System.debug(JSON.serialize(wfRequest.achLog.log) + '\n');
            }else{
                insert wfRequest.achLog.log;
            }
        }else{
            WellsFargo.NotificationsResponse response = (WellsFargo.NotificationsResponse)JSON.deserialize(wfRequest.rawResponse, WellsFargo.NotificationsResponse.class);
            processResponse(response);
            
            Boolean saveRecords = true;
            if(hasMoreNotifications(pageNum, response.getPages())){
                pageNum = pageNum + 1;
                
                if(shouldReschedule()){
                    resubmitJob(pageNum);
                }else{
                    saveRecords = false;
                    processRequest(pageNum);
                }
            }
            
            if(isTest){
                System.debug('====================== Affected Records ===========================\n');
                for(SObject item :affectedRecords){
                    System.debug(JSON.serialize(item) + '\n');
                }
                
                System.debug('\n\n====================== Reversals ===========================\n');
                for(SObject item :reversals){
                    System.debug(JSON.serialize(item) + '\n');
                }
                
                System.debug('\n\n====================== ACH Logs ===========================\n');
                for(SObject item :recordLogs){
                    System.debug(JSON.serialize(item) + '\n');
                }
            }else{
                if(saveRecords){
                    update affectedRecords;
                    insert reversals;
                    insert recordLogs;
                }
            }
        }
    }
    
    public static void processResponse(WellsFargo.NotificationsResponse response){
        //Collect affected Payment/Disbursements Ids
        Map<String, WellsFargo.Notification> notificationsById = new Map<String, WellsFargo.Notification>();
        for(WellsFargo.Notification item :response.notifications) notificationsById.put(item.getRecipientId(), item);
        
        affectedRecords = getAffectedRows(notificationsById.keySet());
        
        for(SObject item :affectedRecords){
            Boolean isPayment = item.Id.getSobjectType() == cmbls__Payment__c.getSObjectType();
            String externalId = (String)item.get((isPayment ? 'Wells_Fargo_Payment_ID_Formula__c' : 'Wells_Fargo_Disbursement_ID_Formula__c'));
            WellsFargo.Notification notification = getNotificationById(externalId, notificationsById);
            
            if(notification == null) continue;
            
            ACH_Transaction_Log__c log = getLog(notification, isPayment, item.Id);
            if(isPayment){
                String recordStatus = (String)item.get('cmbls__Status__c');
                if(WellsFargoAPI.WF_Settings.Create_Reversal_Payment_for_Late_Returns__c && !new Set<String>{Constant.STATUS_SCHEDULED, Constant.STATUS_PENDING, PaymentUtils.PAYMENT_STATUS_PRE_PENDING}.contains(recordStatus)){
                    cmbls__Payment__c reversal = PaymentService.getReversalPayment((cmbls__Payment__c)item);
                    reversal.cmbls__Effective_Date__c = log.Log_Date__c.addHours(2).date();
                    reversal.cmbls__Settlement_Date__c = log.CreatedDate;
                    reversals.add(reversal);
                    item.put('cmbls__Reversal_Created__c', true);
                }else{
                    item.put('cmbls__Status__c', Constant.STATUS_FAILED);
                }
            }else{
                item.put('cmbls__Status__c', PaymentUtils.PAYMENT_STATUS_FAILED);
            }
            recordLogs.add(log);
        }
    }
    
    public static ACH_Transaction_Log__c getLog(WellsFargo.Notification notification, Boolean isPayment, Id recordId){
        ACH_Transaction_Log__c log = new ACH_Transaction_Log__c(
            Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED,
            Log_Date__c = Datetime.now(),
            Request__c =  WellsFargoAPI.WF_Settings.WF_CHECK_NOTIFICATIONS_URL__c,
            Response__c = JSON.serialize(notification),
            Description__c = notification.getReturnReasonDescription(),
            Response_Code__c = notification.getReturnReasonCode()
        );
        if(isPayment){
            log.Payment__c = recordId;
        }else{
            log.Disbursement__c = recordId;
        }
        
        return log;
    }
    
    public static SObject[] getAffectedRows(Set<String> notificationsId){
        SObject[] affectedRecords = new SObject[]{};
        //Need to query all fields from payments due to potential clone on reversal
        affectedRecords.addAll(getPayments(notificationsId));
        affectedRecords.addAll(getDisbursements(notificationsId));
        return affectedRecords;
    }
    
    public static cmbls__Disbursement__c[] getDisbursements(Set<String> disbursementIds){
        return [
            SELECT Id, cmbls__Status__c, Wells_Fargo_Disbursement_ID_Formula__c
            FROM cmbls__Disbursement__c
            WHERE
                cmbls__Status__c NOT IN :IGNORED_STATUS AND
                Wells_Fargo_Disbursement_ID_Formula__c IN :disbursementIds
        ];
    }
    
    public static cmbls__Payment__c[] getPayments(Set<String> paymentIds){
        return [
            SELECT Id,  cmbls__Account_Lookup__c, cmbls__ACH_Batch__c,
                cmbls__ACH_Processor__c, cmbls__Check__c,
                cmbls__Add_to_Reserve__c, cmbls__Addenda__c, cmbls__Additional_Fee_Amortization_Date__c,
                cmbls__Amount_Applied_to_Advance__c, cmbls__Amount_Applied_to_Draw__c,
                cmbls__Amount_Applied_to_Draw_Reserve__c,
                cmbls__Amount_Applied_to_Fees__c, cmbls__Amount_Applied_to_Lender_Reimbursement__c,
                cmbls__Amount_Applied_to_Overcollection_Reserve__c, cmbls__Amount_Applied_to_Reserve__c,
                cmbls__Amount_Received_from_Borrower__c, cmbls__Applied_to_Cash_Collateral__c,
                cmbls__Applied_to_Deferred_Fees__c, cmbls__Applied_to_Escrow_Reserve__c,
                cmbls__Applied_to_Interest_Reserve__c, cmbls__Auto_Generated__c,
                cmbls__Bank_account_closed_count__c, cmbls__Bank_Account_Number__c,
                cmbls__Bank_Routing_Number__c, cmbls__Deduct_from_Reserve__c, cmbls__Disbursement__c,
                cmbls__Draw__c, cmbls__Effective_Date__c, cmbls__Error_Code__c,
                cmbls__Error_Description__c, cmbls__External_Transaction_ID__c,
                cmbls__Extra_Principal_Amount__c, cmbls__Fail_Date__c, cmbls__Fee_Collected__c,
                cmbls__Fee_Settings_Created__c, cmbls__Funding_Payment__c, cmbls__InterestAccrual__c,
                cmbls__Holdback__c, cmbls__Holdback_Amount__c, cmbls__Interest_Amortization_Date__c,
                cmbls__Interest_Payment_Amt__c, cmbls__Interest_Payment_Percent__c,
                cmbls__Merchant_Id__c, cmbls__Merchant_Name__c, cmbls__Merchant_Total_Amount__c,
                cmbls__Merchant_Total_Holdback__c, cmbls__Notes__c, cmbls__NSF_Count__c,
                cmbls__Omit_From_Invoice__c, cmbls__Omit_from_Open_Balance__c, cmbls__Original_Fund__c,
                cmbls__Original_Invoice__c, cmbls__Original_Invoice_Line_Item__c,
                cmbls__Original_Scheduled_Date__c, cmbls__Paid_Back__c, cmbls__Payment__c,
                cmbls__Payment_Method__c, cmbls__Payment_Number__c, cmbls__Payoff__c,
                cmbls__Payoff_Selected_Loan_Status__c, cmbls__Payoff_Selected_Remaining_Allocation__c,
                cmbls__Pending_Payment_Loan_Transfer__c, cmbls__Post_Write_Off_Record__c,
                cmbls__Posted_to_accounting__c, cmbls__Principal_Payment_Amt__c,
                cmbls__Principal_Payment_Percent__c, cmbls__Process_Date__c, cmbls__Processed_Amount__c,
                cmbls__Processor_Integration__c, cmbls__Repayment__c, cmbls__Manual_Allocation__c,
                cmbls__Repayment_Schedule__c, cmbls__Reserve_Deducted__c,
                cmbls__Reserve_Payment_Amount__c, cmbls__Resubmitted_Of__c,
                cmbls__Running_Principal_Balance__c, cmbls__Running_Principal_Balance_Number__c,
                cmbls__Scheduled_From_Portal__c, cmbls__Sequence__c, cmbls__Settlement_Date__c,
                cmbls__Settlement_Id__c, cmbls__Split_Batch__c, cmbls__Status__c,
                cmbls__Status_Image__c, cmbls__Sub_Type__c, cmbls__Running_Balance__c,
                cmbls__System_Notes__c, cmbls__Transaction_Amount__c, cmbls__Transaction_Type__c,
                cmbls__Type_of_Account__c, FinProdPaymentId__c, Payment__c, cmbls__Reversal_Created__c,
                Wells_Fargo_Payment_ID_Override__c, Wells_Fargo_Payment_ID_Formula__c
            FROM cmbls__Payment__c
            WHERE
                cmbls__Status__c NOT IN :IGNORED_STATUS AND
                cmbls__Reversal_Created__c = FALSE AND
                Wells_Fargo_Payment_ID_Formula__c IN :paymentIds
        ];
    }
    
    public static Boolean hasMoreNotifications(Integer pageNum, Integer totalPages){
        return pageNum < totalPages;
    }
    
    public static Boolean shouldReschedule(){
        return (
            Limits.getCallouts() >= Limits.getLimitCallouts() ||
            (affectedRecords.size() + 100) >= Limits.getLimitDmlRows() ||
            (reversals.size() + 100) >= Limits.getLimitDmlRows() ||
            (recordLogs.size() + 100) >= Limits.getLimitDmlRows()
        ) && !Test.isRunningTest();
    }
    
    public static void resubmitJob(Integer pageNum){
        Datetime resubmissionTime = System.now().addMinutes(5);
        String hour = String.valueOf(resubmissionTime.hour());
        String min = String.valueOf(resubmissionTime.minute());
        String day = String.valueOf(resubmissionTime.day());
        String month = String.valueOf(resubmissionTime.month());
        String year = String.valueOf(resubmissionTime.year());
        //parse to cron expression
        String nextFireTime = '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        System.schedule('WellsFargo - Check Late Return Notifications (Self)', nextFireTime, new BatchCheckWFNotifications(pageNum));
    }
    
    public static WellsFargo.Notification getNotificationById(String recipientId, Map<String, WellsFargo.Notification> notificationsById){
        WellsFargo.Notification output;
        for(String key :notificationsById.keySet()){
            if(recipientId.trim().equals(key)){
                output = notificationsById.get(key);
                break;
            }
        }
        
        return output;
    }
}