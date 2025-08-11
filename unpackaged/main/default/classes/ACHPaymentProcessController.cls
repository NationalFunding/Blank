public with sharing class ACHPaymentProcessController {
    
    private ApexPages.StandardSetController standardController;
    public Boolean fileStatus{get;set;}
    List <String> fileNames = new List<String>();
    Date createdDate{get;set;}
    
    public ACHPaymentProcessController(ApexPages.StandardSetController controller) {
        this.standardController = controller;
    }
    
    public PageReference processACHPayments() {
        Set<Id> paymentIds = new Set<Id>();
        for(SObject payment : standardController.getSelected()){
            paymentIds.add(payment.id);
        }
        if (paymentIds.size()>0) {
            List<Ach_payment__c> paymentsWithNoOrgBankAccounts = [select Id,Organization_s_Bank_Account__c from Ach_Payment__c where Organization_s_Bank_Account__c=null and Id in:paymentIds ];
            
            if(paymentsWithNoOrgBankAccounts.size()>0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,
                                    'Some of the ACH Payment Objects are not having Organization bank account.Please assign them the appropriate organization Bank Account.'));
            }
            AggregateResult[] createdDateCount = [select count(Id),Create_ACH_File_Date__c from ACH_Payment__c 
                                                where Id in:paymentIds 
                                                and Create_ACH_File_Date__c != null 
                                                group by Create_ACH_File_Date__c ];
            if(createdDateCount.size() > 1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                            'For the selected records, the Create ACH File Date is different. All records must have the same Create ACH File Date.'));  
                return null;
            }else if((Date)createdDateCount[0].get('Create_ACH_File_Date__c') != Date.Today()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For the selected records to process,the Create ACH File Date should be today\'s Date. '));  
                return null;
            }else if(createdDateCount.size()==1){
                createdDate = (Date)createdDateCount[0].get('Create_ACH_File_Date__c');
            }
            List<Bank_Account__c> orgBanks = [select Id,ACH_ID__c,Bank_ACH_Code__c,Bank_Name__c,National_Funding_Account__c
                                            ,Company_Name__c,Fed_Tax_Id__c,Folder_Name__c,
                                            Routing_Number__c,Standard_Entry_Class__c from Bank_Account__c where RecordType.Name='Organization'];
            for(Bank_Account__c bank:orgBanks){
                AggregateResult[] payOnThisDateCount = [select count(Id),Pay_On_This_Date__c from ACH_Payment__c 
                                                where Id in : paymentIds and Pay_On_This_Date__c != null 
                                                and Create_ACH_File_Date__c != null and Organization_s_Bank_Account__c=:bank.Id
                                                group by Pay_On_This_Date__c ];
                Map<Date,List<ACH_Payment__c>> paymentsMap = new Map<Date,List<ACH_Payment__c>>();
                if(payOnThisDateCount.size() > 0){
                    for(Integer i = 0; i < payOnThisDateCount.size() ; i++){
                        paymentsMap.put((Date)payOnThisDateCount[i].get('Pay_On_This_Date__c'),
                                            [select Id ,Name,
                                            ACH_File_Generated__c,
                                            ACH_File_Generated_Date__c,
                                            Amount__c,
                                            Create_ACH_File_Date__c,
                                            Pay_On_This_Date__c,
                                            NF_Lease_Loan_Number__c,
                                            Opportunity__c,
                                            Payee_s_Account_Type__c,
                                            Payee_s_Bank_Account_Number__c,
                                            Payee_s_Bank_Name__c,
                                            Payee_s_Name__c,
                                            Payee_s_Routing_Number__c,
                                            Receiving_Company_Name__c
                                            from ACH_Payment__c
                                            where Id in : paymentIds 
                                            and Pay_On_This_Date__c =:(Date)payOnThisDateCount[i].get('Pay_On_This_Date__c')   
                                            and ACH_File_Generated__c = false and Organization_s_Bank_Account__c=:bank.Id]);
                    }
                }
                try {
                    for(Date payDate:paymentsMap.keySet()){
                        ACHFileGenerator ach = new ACHFileGenerator(paymentsMap.get(payDate),payDate,createdDate,bank);
                        Document d = [select Id,Name from Document where Id=:ach.generateACH() limit 1];
                        String fileName = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+d.id+'">'+d.Name+'</a>';
                        system.debug(fileName);
                        fileNames.add(fileName);
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'ACH files generated are:'));
                    for(Integer i=0 ; i < fileNames.size() ; i++){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'&nbsp;' + fileNames[i]));
                    }
                }catch(Exception e){
                    system.debug('Message:'+e.getMessage()+'line number:'+e.getLineNumber());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ACH file could not be generated.'));
                }
            }
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No ACH payment records were selected.'));
        }
        return null;
    }

}