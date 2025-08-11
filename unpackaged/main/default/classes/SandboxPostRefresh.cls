/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: SandboxPostRefresh
* DESCRIPTION:This class runs automatically after sandbox refresh and invokes data masking batch class
* @author         Supriya Gore
* @version        1.0
* @created        18/03/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
global class SandboxPostRefresh implements SandboxPostCopy {
//Below is the method of sandboxpostcopy interface which will invoke data masking batch after sandbox refresh
        global void runApexClass(SandboxContext context) {
            if(context!=null){
                System.debug(context.organizationId());
                System.debug(context.sandboxId());
                System.debug(context.sandboxName());
            }
            
            // Query all custom metadata records
            List<Data_Masking_Configuration__mdt> metadataRecords = [SELECT ObjectName__c, FieldName__c, MaskType__c,QueryFilter__c,IsActive__c FROM Data_Masking_Configuration__mdt where IsActive__c =true];
            
            // Create a map to store values with DeveloperName as the key
            Map<String, Map<String, String>> metadataMap = new Map<String, Map<String, String>>();
            Map<string,string> objectFilter = new Map<string,string>();
            // Iterate through the metadata records and add them to the map
            for (Data_Masking_Configuration__mdt record : metadataRecords) {
                // Create a sub-map to store the field values for each record
                Map<String, String> fieldValues = new Map<String, String>();
                //fieldValues.put(record.FieldName__c, record.MaskType__c);
                if(record.QueryFilter__c != null){
                    string filter = ' '+record.QueryFilter__c;
                    if(!objectFilter.containsKey(record.ObjectName__c)){
                        objectFilter.put(record.ObjectName__c,' '+filter);
                    }
                }
                // Add the sub-map to the main map with DeveloperName as the key
                if (!metadataMap.containsKey(record.ObjectName__c)) {
                    metadataMap.put(record.ObjectName__c, new Map<String, String>());
                }
                metadataMap.get(record.ObjectName__c).put(record.FieldName__c, record.MaskType__c);
            }
            For(String ObjectName: metadataMap.keySet()){
            string queryFilter ='';
            if(objectFilter.get(ObjectName)!=null)
            queryFilter = objectFilter.get(ObjectName);
                BatchToMaskData batch = new BatchToMaskData(ObjectName,metadataMap.get(ObjectName),queryFilter);  // Specify the object type
                Database.executeBatch(batch, 200);
            }
        }
    }