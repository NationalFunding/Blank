/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: BatchToMaskData 
* DESCRIPTION:This batch class is used to mask the actual data after sandbox refresh. exe: email will be updated with .invalid string at the end.
* @author         Supriya Gore
* @version        1.0
* @created        17/03/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
public class BatchToMaskData implements Database.Batchable<SObject>,Database.Stateful {
    
        private String query,objectName,filterCondition;
        Map<string,string> mapFieldWithMaskType;
        public Integer numberOfErrors = 0;
        public Integer totalRecordCount = 0;
        public list<errorWrapper> listErrorWrapper=new list<errorWrapper>();
        
        //below is the constructor which forms the string query from input data
        public BatchtoMaskData(String objectName, map<string,string> mapFieldWithMaskType, String filterCondition){
            this.mapFieldWithMaskType = mapFieldWithMaskType;
            this.objectName = objectName;
            this.filterCondition = filterCondition;
            query='Select ';
            for(String field: mapFieldWithMaskType.keyset()){
                if(query =='Select '){
                    query+= field;
                }else{
                    query+=','+ field;
                }
            }
            
            query+= ' from '+objectName;
            if(filterCondition<>null){
                query += filterCondition;
            }
            system.debug('Final Query '+query);
        }
        
        
        // Start method to fetch records based on the dynamic query
        public Database.QueryLocator start(Database.BatchableContext BC) {
        try{
            return Database.getQueryLocator(query);
           }Catch(Exception e){
               system.debug('inside start method catch ');
               numberOfErrors++;
               listErrorWrapper.add(new errorWrapper('NA', e.getMessage()));
           }
           return Database.getQueryLocator('SELECT Id FROM Account WHERE Id = null');
        }
        
        // Process method to mask the email addresses and other fields
        public void execute(Database.BatchableContext BC, List<SObject> scope) {
                Set<SObject> recordsToUpdate = new Set<SObject>();
                try{
                for(Sobject s: scope){
                    for(String field: mapFieldWithMaskType.keyset()){
                    
                    System.debug('Field Name '+field + 'Masktype '+mapFieldWithMaskType.get(field));
                    if(mapFieldWithMaskType.get(field)=='invalid'){
                        if (s.get('Email') != null && !((string)s.get('Email')).endsWith('.invalid')) {
                            String email = (String) s.get('Email');
                            s.put('Email', email+'.invalid');
                        }
                    }else{
                        if(s.get(field)!=null)
                        s.put(field, mapFieldWithMaskType.get(field));
                    }
                     
                    }
                    if(!recordsToUpdate.contains(s)){
                      recordsToUpdate.add(s);
                    } 
                     
                    
            }
            }catch (Exception e) {
                    // Handle general exceptions during the execution
                    System.debug('Error during execution: ' + e.getMessage());
                    numberOfErrors++;
                    listErrorWrapper.add(new errorWrapper('NA', e.getMessage()));
            }
            
            // Update the records with masked email
            if (!recordsToUpdate.isEmpty()) {
            List<SObject> recordListToUpdate = new List<SObject>(recordsToUpdate);
           try{
                List<Database.SaveResult> sRes = Database.update(recordListToUpdate, false);
                for(Integer i=0;i<sRes.size();i++){
                    totalRecordCount++;
                    if (!sRes.get(i).isSuccess()){
                        NumberOfErrors++;
                        Database.Error error = sRes.get(i).getErrors().get(0);
                        listErrorWrapper.add(new errorWrapper(Scope.get(i).Id, error.getMessage()));
                    }
                }
            }catch (Exception e) {
                    // Handle general exceptions during the execution
                    System.debug('Error during execution: ' + e.getMessage());
            }
            }
            
        }
        // End method to handle post-processing
        public void finish(Database.BatchableContext BC) {
            // Optional: send an email or log any information
            System.debug('Batch processing is complete.');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Batch to mask '+objectName +' records batch success & error list');
            // Retrieve the custom label containing the comma-separated address
            String addressString = System.Label.Data_Masking_Admin_Email;  
            
            // Split the address string into individual components using the comma separator
            List<String> addressComponents = addressString.split(',');
            
            // Optionally, you can trim spaces to clean up the address components
            for (Integer i = 0; i < addressComponents.size(); i++) {
                addressComponents[i] = addressComponents[i].trim();
            }
            list<String> toAddress=new list<String>();
            for (String address : addressComponents) {
                toAddress.add(address);
            }
            String body;
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
            System.debug(d.getSandboxName());
            body='Hello,<br/><br/> In the '+ d.getSandboxName() +' Sandbox, Total Records Processed '+ totalRecordCount  + ' With '+ numberOfErrors + ' failure.';
            if(listErrorWrapper.isempty()==false){
            
                body+=' <br/><br/> <br/> Following ids were not updated due to following Errror :<br/><br/><br/>';
                for(ErrorWrapper eWl: listErrorWrapper){
                    body=body+' id '+eWl.objectid +' Error '+eWl.error+'<br/>';
                }
            }
            email.setHtmlBody(body);
            email.setToAddresses(toaddress);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email}); 
        }
        //Wrapper class for error logging
        public class ErrorWrapper{
            public string objectId;
            public String error;
            public ErrorWrapper(string objectId,String error){
                this.objectId =objectId;
                this.error= error;
            }
        }
        
    }