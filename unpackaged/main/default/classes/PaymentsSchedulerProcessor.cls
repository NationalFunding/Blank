global class PaymentsSchedulerProcessor implements Schedulable {
    String process;
    
    public PaymentsSchedulerProcessor(String p){
        this.process = p;
    }

    global void execute(SchedulableContext SC){
        if(this.process == WellsFargoAPI.PAYMENTS_PROCESS){
            Database.executeBatch(new PaymentsBatchProcessor(WellsFargoAPI.PAYMENTS_PROCESS), PaymentsBatchProcessor.getBatchScope());
        }else if(this.process == WellsFargoAPI.DISBURSEMENT_PROCESS){
            Database.executeBatch(new PaymentsBatchProcessor(WellsFargoAPI.DISBURSEMENT_PROCESS), PaymentsBatchProcessor.getBatchScope());
        }
    }
}