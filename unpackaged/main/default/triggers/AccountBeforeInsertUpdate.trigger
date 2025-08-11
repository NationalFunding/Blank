trigger AccountBeforeInsertUpdate on Account (before insert, before update,before delete) 
{
    if(!trigger.isDelete){
                //**update the SIC lookup
                String sics = '';
                for (Account a : Trigger.New) 
                {   
                    if((Trigger.isInsert && a.Sic != null) || (Trigger.isUpdate && a.Sic != Trigger.oldMap.get(a.Id).Sic))
                    {
                        if(a.Sic != null)
                        {
                            sics +=  '\'' + a.Sic + '\',';
                        }
                    }
                    if(trigger.isUpdate && a.name == 'TriggerOnOpportunity' && !UtilityTools.dummyAccUpdate && a.LP_Cust_Number__c <> trigger.oldMap.get(a.id).LP_Cust_Number__c){
                        a.addError('You do not have access to modify this reocrd');
                    }
                }
                
                if(sics != '')
                {
                    integer len = sics.length();
                    sics = sics.substring(0, len - 1);
                }
                
                //load a map of sic codes
                Map<String,FPC_SIC__c> sicMap = new Map<String,FPC_SIC__c>();
                if(sics != '')
                {
                    String SICQuery = 'Select Id, SIC_Code__c, SIC_Name__c from FPC_SIC__c where SIC_Code__c in (' + sics + ')';
                    for (FPC_SIC__c fs : Database.query(SICQuery))      
                    {
                        if(sicMap.get(fs.SIC_Code__c) == null)
                        {
                            sicMap.put(fs.SIC_Code__c, fs);
                        }
                    } 
                }
                
                
                for (Account a : Trigger.New) 
                {   
                    if((Trigger.isInsert && a.Sic != null) || (Trigger.isUpdate && a.Sic != Trigger.oldMap.get(a.Id).Sic))
                    {
                        if(sicMap.get(a.Sic) != null)
                            a.SIC_Name__c = sicMap.get(a.Sic).SIC_Name__c;
                        else
                            a.SIC_Name__c = null;
                        a.SICCODE__c = a.Sic;
                    }
                    
                      
                }   
                //**End of update SIC lookup
    }
    else {
         if(trigger.old != null && trigger.old.size() == 1 && trigger.old[0].name == 'TriggerOnOpportunity' ){
            trigger.old[0].addError('You do not have enough permissions to delete this Record.');
            
         }
     }
}