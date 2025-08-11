/**
 * ACHTransactionsSelector class
 * @author CloudMyBiz (r)
 * @date 14/07/2022
 * @description
 * @group 
 */

public inherited sharing class ACHTransactionsSelector {

    static final List<String> OPEN_ACH_TRANSACTION_STATUS = new List<String>{
        Constant.ACH_TRANSACTION_LOG_STATUS_FAILED, Constant.ACH_TRANSACTION_LOG_STATUS_PENDING
    };

    static final List<String> SENT_TO_WF_STATUS = new List<String>{
        Constant.ACH_TRANSACTION_LOG_WF_SENT
    };

    public static Map<Id, ACH_Transaction_Log__c> getTransactionsByPmtOrDisbursement(List<SObject> records){
        Map<Id, ACH_Transaction_Log__c> ret = new Map<Id, ACH_Transaction_Log__c>();
        Set<Id> recordIds = new Set<Id>();
        for(SObject record : records){
            recordIds.add(record.Id);
        }

        for(ACH_Transaction_Log__c achLog : [SELECT Id, Payment__c, Disbursement__c, Status__c, Response_Code__c FROM ACH_Transaction_Log__c
            WHERE Payment__c IN :recordIds OR Disbursement__c IN :recordIds ORDER BY CreatedDate DESC]){
            if(achLog.Payment__c != null && !ret.containsKey(achLog.Payment__c)){
                ret.put(achLog.Payment__c, achLog);
            }else if(achLog.Disbursement__c != null && !ret.containsKey(achLog.Disbursement__c)){
                ret.put(achLog.Disbursement__c, achLog);
            }
        }
        return ret;
    }

    public static List<ACH_Transaction_Log__c> getNotResolvedACHTransactions(String objectType){
        Map<Id, ACH_Transaction_Log__c> ret = new Map<Id, ACH_Transaction_Log__c>();

        for(ACH_Transaction_Log__c achLog : getACHTransactions(objectType, OPEN_ACH_TRANSACTION_STATUS)){
            if(achLog.Payment__c != null && !ret.containsKey(achLog.Payment__c)){
                ret.put(achLog.Payment__c, achLog);
            }else if(achLog.Disbursement__c != null && !ret.containsKey(achLog.Disbursement__c)){
                ret.put(achLog.Disbursement__c, achLog);
            }
        }
        return ret.values();
    }

    public static List<ACH_Transaction_Log__c> getSentToWFACHTransactions(String objectType){
        Map<Id, ACH_Transaction_Log__c> ret = new Map<Id, ACH_Transaction_Log__c>();

        for(ACH_Transaction_Log__c achLog : getACHTransactionsSentToWF(objectType)){
            if(achLog.Payment__c != null && !ret.containsKey(achLog.Payment__c) && achLog.Payment__r.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_PRE_PENDING){
                ret.put(achLog.Payment__c, achLog);
            }else if(achLog.Disbursement__c != null && !ret.containsKey(achLog.Disbursement__c) && achLog.Disbursement__r.cmbls__Status__c == PaymentUtils.PAYMENT_STATUS_PRE_PENDING){
                ret.put(achLog.Disbursement__c, achLog);
            }
        }
        return ret.values();
    }

    private static List<ACH_Transaction_Log__c> getACHTransactions(String objectType, List<String> achTransactionStatus){
        if(objectType == cmbls__Disbursement__c.getSObjectType().getDescribe().getName()){
            return [
                SELECT  Status__c, Response__c, Payment__c, Payment__r.cmbls__Status__c, Disbursement__c,
                        Disbursement__r.cmbls__Status__c, Payment__r.cmbls__Effective_Date__c, Disbursement__r.cmbls__Effective_Date__c,
                        Disbursement__r.Wells_Fargo_Disbursement_ID_Formula__c
                FROM ACH_Transaction_Log__c
                WHERE   Disbursement__c != NULL AND
                        Status__c IN :achTransactionStatus
                ORDER BY CreatedDate DESC
            ];
        }else if(objectType == cmbls__Payment__c.getSObjectType().getDescribe().getName()){
            return [
                SELECT  Status__c, Payment__c, Response__c, Disbursement__c, Log_Date__c, CreatedDate,
                        //Need to query all fields from payments due to potential clone on reversal
                        Id, Payment__r.cmbls__Account_Lookup__c, Payment__r.cmbls__ACH_Batch__c,
                        Payment__r.cmbls__ACH_Processor__c, Payment__r.cmbls__Check__c,
                        Payment__r.cmbls__Add_to_Reserve__c, Payment__r.cmbls__Addenda__c, Payment__r.cmbls__Additional_Fee_Amortization_Date__c,
                        Payment__r.cmbls__Amount_Applied_to_Advance__c, Payment__r.cmbls__Amount_Applied_to_Draw__c,
                        Payment__r.cmbls__Amount_Applied_to_Draw_Reserve__c,
                        Payment__r.cmbls__Amount_Applied_to_Fees__c, Payment__r.cmbls__Amount_Applied_to_Lender_Reimbursement__c,
                        Payment__r.cmbls__Amount_Applied_to_Overcollection_Reserve__c, Payment__r.cmbls__Amount_Applied_to_Reserve__c,
                        Payment__r.cmbls__Amount_Received_from_Borrower__c, Payment__r.cmbls__Applied_to_Cash_Collateral__c,
                        Payment__r.cmbls__Applied_to_Deferred_Fees__c, Payment__r.cmbls__Applied_to_Escrow_Reserve__c,
                        Payment__r.cmbls__Applied_to_Interest_Reserve__c, Payment__r.cmbls__Auto_Generated__c,
                        Payment__r.cmbls__Bank_account_closed_count__c, Payment__r.cmbls__Bank_Account_Number__c,
                        Payment__r.cmbls__Bank_Routing_Number__c, Payment__r.cmbls__Deduct_from_Reserve__c, Payment__r.cmbls__Disbursement__c,
                        Payment__r.cmbls__Draw__c, Payment__r.cmbls__Effective_Date__c, Payment__r.cmbls__Error_Code__c,
                        Payment__r.cmbls__Error_Description__c, Payment__r.cmbls__External_Transaction_ID__c,
                        Payment__r.cmbls__Extra_Principal_Amount__c, Payment__r.cmbls__Fail_Date__c, Payment__r.cmbls__Fee_Collected__c,
                        Payment__r.cmbls__Fee_Settings_Created__c, Payment__r.cmbls__Funding_Payment__c, Payment__r.cmbls__InterestAccrual__c,
                        Payment__r.cmbls__Holdback__c, Payment__r.cmbls__Holdback_Amount__c, Payment__r.cmbls__Interest_Amortization_Date__c,
                        Payment__r.cmbls__Interest_Payment_Amt__c, Payment__r.cmbls__Interest_Payment_Percent__c,
                        Payment__r.cmbls__Merchant_Id__c, Payment__r.cmbls__Merchant_Name__c, Payment__r.cmbls__Merchant_Total_Amount__c,
                        Payment__r.cmbls__Merchant_Total_Holdback__c, Payment__r.cmbls__Notes__c, Payment__r.cmbls__NSF_Count__c,
                        Payment__r.cmbls__Omit_From_Invoice__c, Payment__r.cmbls__Omit_from_Open_Balance__c, Payment__r.cmbls__Original_Fund__c,
                        Payment__r.cmbls__Original_Invoice__c, Payment__r.cmbls__Original_Invoice_Line_Item__c,
                        Payment__r.cmbls__Original_Scheduled_Date__c, Payment__r.cmbls__Paid_Back__c, Payment__r.cmbls__Payment__c,
                        Payment__r.cmbls__Payment_Method__c, Payment__r.cmbls__Payment_Number__c, Payment__r.cmbls__Payoff__c,
                        Payment__r.cmbls__Payoff_Selected_Loan_Status__c, Payment__r.cmbls__Payoff_Selected_Remaining_Allocation__c,
                        Payment__r.cmbls__Pending_Payment_Loan_Transfer__c, Payment__r.cmbls__Post_Write_Off_Record__c,
                        Payment__r.cmbls__Posted_to_accounting__c, Payment__r.cmbls__Principal_Payment_Amt__c,
                        Payment__r.cmbls__Principal_Payment_Percent__c, Payment__r.cmbls__Process_Date__c, Payment__r.cmbls__Processed_Amount__c,
                        Payment__r.cmbls__Processor_Integration__c, Payment__r.cmbls__Repayment__c, Payment__r.cmbls__Manual_Allocation__c,
                        Payment__r.cmbls__Repayment_Schedule__c, Payment__r.cmbls__Reserve_Deducted__c,
                        Payment__r.cmbls__Reserve_Payment_Amount__c, Payment__r.cmbls__Resubmitted_Of__c,
                        Payment__r.cmbls__Running_Principal_Balance__c, Payment__r.cmbls__Running_Principal_Balance_Number__c,
                        Payment__r.cmbls__Scheduled_From_Portal__c, Payment__r.cmbls__Sequence__c, Payment__r.cmbls__Settlement_Date__c,
                        Payment__r.cmbls__Settlement_Id__c, Payment__r.cmbls__Split_Batch__c, Payment__r.cmbls__Status__c,
                        Payment__r.cmbls__Status_Image__c, Payment__r.cmbls__Sub_Type__c, Payment__r.cmbls__Running_Balance__c,
                        Payment__r.cmbls__System_Notes__c, Payment__r.cmbls__Transaction_Amount__c, Payment__r.cmbls__Transaction_Type__c,
                        Payment__r.cmbls__Type_of_Account__c, Payment__r.FinProdPaymentId__c, Payment__r.Payment__c, Payment__r.cmbls__Reversal_Created__c,
                        Payment__r.Wells_Fargo_Payment_ID_Override__c, Payment__r.Wells_Fargo_Payment_ID_Formula__c, Payment__r.cmbls__Response_Code__c,
                        Disbursement__r.cmbls__Status__c, Disbursement__r.cmbls__Effective_Date__c
                FROM ACH_Transaction_Log__c
                WHERE Payment__c != NULL AND Status__c IN :achTransactionStatus
                ORDER BY CreatedDate DESC
            ];
        }
        return new List<ACH_Transaction_Log__c>();
    }
    
    private static List<ACH_Transaction_Log__c> getACHTransactionsSentToWF(String objectType){
        if(objectType == cmbls__Disbursement__c.getSObjectType().getDescribe().getName()){
            return [
                SELECT Status__c, Response__c, Payment__c, Payment__r.cmbls__Status__c, Disbursement__c,
                    Disbursement__r.cmbls__Status__c, Payment__r.cmbls__Effective_Date__c, Disbursement__r.cmbls__Effective_Date__c,
                    Disbursement__r.Wells_Fargo_Disbursement_ID_Formula__c
                FROM ACH_Transaction_Log__c
                WHERE Disbursement__c != NULL AND Status__c IN :SENT_TO_WF_STATUS
                ORDER BY CreatedDate DESC
            ];
        }else if(objectType == cmbls__Payment__c.getSObjectType().getDescribe().getName()){
            return [
                SELECT  Status__c, Payment__c, Response__c, Disbursement__c, Log_Date__c, CreatedDate,
                    //Need to query all fields from payments due to potential clone on reversal
                    Id, Payment__r.cmbls__Account_Lookup__c, Payment__r.cmbls__ACH_Batch__c,
                    Payment__r.cmbls__ACH_Processor__c, Payment__r.cmbls__Check__c,
                    Payment__r.cmbls__Add_to_Reserve__c, Payment__r.cmbls__Addenda__c, Payment__r.cmbls__Additional_Fee_Amortization_Date__c,
                    Payment__r.cmbls__Amount_Applied_to_Advance__c, Payment__r.cmbls__Amount_Applied_to_Draw__c,
                    Payment__r.cmbls__Amount_Applied_to_Draw_Reserve__c,
                    Payment__r.cmbls__Amount_Applied_to_Fees__c, Payment__r.cmbls__Amount_Applied_to_Lender_Reimbursement__c,
                    Payment__r.cmbls__Amount_Applied_to_Overcollection_Reserve__c, Payment__r.cmbls__Amount_Applied_to_Reserve__c,
                    Payment__r.cmbls__Amount_Received_from_Borrower__c, Payment__r.cmbls__Applied_to_Cash_Collateral__c,
                    Payment__r.cmbls__Applied_to_Deferred_Fees__c, Payment__r.cmbls__Applied_to_Escrow_Reserve__c,
                    Payment__r.cmbls__Applied_to_Interest_Reserve__c, Payment__r.cmbls__Auto_Generated__c,
                    Payment__r.cmbls__Bank_account_closed_count__c, Payment__r.cmbls__Bank_Account_Number__c,
                    Payment__r.cmbls__Bank_Routing_Number__c, Payment__r.cmbls__Deduct_from_Reserve__c, Payment__r.cmbls__Disbursement__c,
                    Payment__r.cmbls__Draw__c, Payment__r.cmbls__Effective_Date__c, Payment__r.cmbls__Error_Code__c,
                    Payment__r.cmbls__Error_Description__c, Payment__r.cmbls__External_Transaction_ID__c,
                    Payment__r.cmbls__Extra_Principal_Amount__c, Payment__r.cmbls__Fail_Date__c, Payment__r.cmbls__Fee_Collected__c,
                    Payment__r.cmbls__Fee_Settings_Created__c, Payment__r.cmbls__Funding_Payment__c, Payment__r.cmbls__InterestAccrual__c,
                    Payment__r.cmbls__Holdback__c, Payment__r.cmbls__Holdback_Amount__c, Payment__r.cmbls__Interest_Amortization_Date__c,
                    Payment__r.cmbls__Interest_Payment_Amt__c, Payment__r.cmbls__Interest_Payment_Percent__c,
                    Payment__r.cmbls__Merchant_Id__c, Payment__r.cmbls__Merchant_Name__c, Payment__r.cmbls__Merchant_Total_Amount__c,
                    Payment__r.cmbls__Merchant_Total_Holdback__c, Payment__r.cmbls__Notes__c, Payment__r.cmbls__NSF_Count__c,
                    Payment__r.cmbls__Omit_From_Invoice__c, Payment__r.cmbls__Omit_from_Open_Balance__c, Payment__r.cmbls__Original_Fund__c,
                    Payment__r.cmbls__Original_Invoice__c, Payment__r.cmbls__Original_Invoice_Line_Item__c,
                    Payment__r.cmbls__Original_Scheduled_Date__c, Payment__r.cmbls__Paid_Back__c, Payment__r.cmbls__Payment__c,
                    Payment__r.cmbls__Payment_Method__c, Payment__r.cmbls__Payment_Number__c, Payment__r.cmbls__Payoff__c,
                    Payment__r.cmbls__Payoff_Selected_Loan_Status__c, Payment__r.cmbls__Payoff_Selected_Remaining_Allocation__c,
                    Payment__r.cmbls__Pending_Payment_Loan_Transfer__c, Payment__r.cmbls__Post_Write_Off_Record__c,
                    Payment__r.cmbls__Posted_to_accounting__c, Payment__r.cmbls__Principal_Payment_Amt__c,
                    Payment__r.cmbls__Principal_Payment_Percent__c, Payment__r.cmbls__Process_Date__c, Payment__r.cmbls__Processed_Amount__c,
                    Payment__r.cmbls__Processor_Integration__c, Payment__r.cmbls__Repayment__c, Payment__r.cmbls__Manual_Allocation__c,
                    Payment__r.cmbls__Repayment_Schedule__c, Payment__r.cmbls__Reserve_Deducted__c,
                    Payment__r.cmbls__Reserve_Payment_Amount__c, Payment__r.cmbls__Resubmitted_Of__c,
                    Payment__r.cmbls__Running_Principal_Balance__c, Payment__r.cmbls__Running_Principal_Balance_Number__c,
                    Payment__r.cmbls__Scheduled_From_Portal__c, Payment__r.cmbls__Sequence__c, Payment__r.cmbls__Settlement_Date__c,
                    Payment__r.cmbls__Settlement_Id__c, Payment__r.cmbls__Split_Batch__c, Payment__r.cmbls__Status__c,
                    Payment__r.cmbls__Status_Image__c, Payment__r.cmbls__Sub_Type__c, Payment__r.cmbls__Running_Balance__c,
                    Payment__r.cmbls__System_Notes__c, Payment__r.cmbls__Transaction_Amount__c, Payment__r.cmbls__Transaction_Type__c,
                    Payment__r.cmbls__Type_of_Account__c, Payment__r.FinProdPaymentId__c, Payment__r.Payment__c, Payment__r.cmbls__Reversal_Created__c,
                    Payment__r.Wells_Fargo_Payment_ID_Override__c, Payment__r.Wells_Fargo_Payment_ID_Formula__c,
                    Disbursement__r.cmbls__Status__c, Disbursement__r.cmbls__Effective_Date__c
                FROM ACH_Transaction_Log__c
                WHERE Payment__c != NULL AND Status__c IN :SENT_TO_WF_STATUS
                ORDER BY CreatedDate DESC
            ];
        }
        return new List<ACH_Transaction_Log__c>();
    }

}