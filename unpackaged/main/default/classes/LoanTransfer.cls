public inherited sharing class LoanTransfer{
    public cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
    private Map<Id, cmbls__Queued_Event__c> queuedEventsByRepayment;
    private cmbls__Repayment__c[] repayments;
    private Map<Id, Decimal> originationFeeExpensesByRepayment;
    private Map<Id, Decimal> expenseBrokerFeesByRepayment;
    private cmbls__Loan_Transfer__c[] loanTransfersToCreate;
    private cmbls__Debug_Log__c[] logs;
    private cmbls__Fund__c fundRecord;
    
    public LoanTransfer(cmbls__Queued_Event__c[] queuedEvents){
        this.queuedEventsByRepayment = new Map<Id, cmbls__Queued_Event__c>();
        for(cmbls__Queued_Event__c item :queuedEvents) this.queuedEventsByRepayment.put(item.cmbls__Record_Id__c, item);
        this.repayments = RepaymentSelector.getQuickBridgeFundedRecords(this.queuedEventsByRepayment.keySet());
        this.originationFeeExpensesByRepayment = ExpenseSelector.getSumOriginationFeeExpensesByRepayment(this.queuedEventsByRepayment.keySet());
        this.expenseBrokerFeesByRepayment = ExpenseSelector.getSumExpenseBrokerFeesByRepayment(this.queuedEventsByRepayment.keySet());
        this.fundRecord = RepaymentSelector.getTransferFundRecord(settings.National_Funding_Fund_Id__c);
        this.loanTransfersToCreate = new cmbls__Loan_Transfer__c[]{};
        this.logs = new cmbls__Debug_Log__c[]{};
    }
    
    public void processQueuedEvents(){
        
        for(cmbls__Repayment__c repayment :this.getRepaymentsToProcess()){
            Decimal principalBalance = NumberUtils.getDecimal(repayment.cmbls__Funding_Amount__c);
            Decimal originationFeeBalance = NumberUtils.getDecimal(originationFeeExpensesByRepayment.get(repayment.Id));
            Decimal brokerFeeBalance = NumberUtils.getDecimal(expenseBrokerFeesByRepayment.get(repayment.Id));
            this.loanTransfersToCreate.add(this.getRecord(repayment.Id, principalBalance, originationFeeBalance, brokerFeeBalance));
        }
        
        Integer index = 0;
        for(Database.SaveResult result :Database.insert(this.loanTransfersToCreate, false)){
            cmbls__Loan_Transfer__c record = this.loanTransfersToCreate[index];
            cmbls__Queued_Event__c queuedEvent = this.queuedEventsByRepayment.get(record.cmbls__Repayment__c);
            queuedEvent.cmbls__Date_Processed__c = System.now();
            queuedEvent.cmbls__Number_of_Attempts__c = NumberUtils.getDecimal(queuedEvent.cmbls__Number_of_Attempts__c) + 1;
            
            if(!result.isSuccess()){
                cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLFailure(null, record, result);
                log.cmbls__Subject__c = String.format(RepaymentUtils.AUTOMATIC_TRANSFER_ERROR_SUBJECT, new String[]{record.cmbls__Repayment__c});
                log.cmbls__Description__c = RepaymentUtils.AUTOMATIC_TRANSFER_ERROR_DESCRIPTION;
                this.logs.add(log);
                
                queuedEvent.cmbls__Date_Processed__c = null;
            }
            index++;
        }
    }
    
    public void save(){
        Database.update(this.queuedEventsByRepayment.values());
        Database.insert(this.logs);
    }
    
    public cmbls__Repayment__c[] getRepaymentsToProcess(){
        Map<Id, cmbls__Repayment__c> repaymentMap = new Map<Id, cmbls__Repayment__c>(this.repayments);
        cmbls__Repayment__c[] repaymentsToProcess = new cmbls__Repayment__c[]{};
        for(Id repaymentId :this.queuedEventsByRepayment.keySet()){
            if(!repaymentMap.containsKey(repaymentId)){
                this.queuedEventsByRepayment.get(repaymentId).Deleted_Record_Id__c = true;
            }else{
                cmbls__Repayment__c repayment = repaymentMap.get(repaymentId);
                if(repayment.cmbls__Loan_Start_Date__c <= System.today()){
                    cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLFailure(null, repayment, null);
                    log.cmbls__Subject__c = String.format(RepaymentUtils.AUTOMATIC_TRANSFER_ERROR_SUBJECT, new String[]{repayment.Id});
                    log.cmbls__Description__c = RepaymentUtils.AUTOMATIC_TRANSFER_ERROR_DESCRIPTION;
                    if(repayment.cmbls__Status__c == RepaymentUtils.STATUS_UNWIND){
                        this.queuedEventsByRepayment.get(repaymentId).Canceled__c = true;
                        log.cmbls__Log__c += '- Message: Invalid Repayment Status "' + repayment.cmbls__Status__c + '"';
                        this.logs.add(log);
                    }else if(String.isBlank(repayment.cmbls__Primary_Fund__c) || this.fundRecord == null){
                        log.cmbls__Log__c += '- Message: Missing Required Fields' +
                            '- Fields: \n' +
                            '--- cmbls__Primary_Fund__c = "' + repayment.cmbls__Primary_Fund__c + '"\n' +
                            '--- cmbls__New_Fund__c = "' + this.fundRecord?.Id + '"\n';
                        this.logs.add(log);
                    }else{
                        repaymentsToProcess.add(repayment);
                    }
                }
            }
        }
        return repaymentsToProcess;
    }
    
    public cmbls__Loan_Transfer__c getRecord(Id repaymentId, Decimal principalBalance, Decimal originationFeeBalance, Decimal brokerFeeBalance){
        return new cmbls__Loan_Transfer__c(
            cmbls__Loan_Transfer_Date__c = System.today(),
            cmbls__New_Fund__c = fundRecord.Id,
            Principal_Balance__c = principalBalance,
            Interest_Balance__c = 0,
            Origination_Fee_Balance__c = originationFeeBalance,
            cmbls__Indirect_Cost_Origination_Fee__c = originationFeeBalance,
            Broker_Fee_Balance__c = brokerFeeBalance,
            cmbls__Unpaid_Accrued_Interest__c = 0,
            cmbls__Amount__c = (principalBalance + brokerFeeBalance) - originationFeeBalance,
            cmbls__Type__c = RepaymentUtils.TRANSFER_TYPE_INTERNAL,
            cmbls__Repayment__c = repaymentId,
            cmbls__Unaccrued_Expense_Balances__c = 'Include in Loan Transfer'
        );
    }
}