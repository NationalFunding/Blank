public class RelatedContentDocumentLinkRecords {
   
    @AuraEnabled
    public static List<Id> shareFiles(List<Id> cdl, String OpportunityId){
                
        List<Id> insertedRecords = new List<Id> {};
        
        for(Id link : cdl){
            
            ContentDocumentLink document = New ContentDocumentLink(LinkedEntityId = OpportunityId, ContentdocumentId = link, shareType = 'V');
			Insert document;
            insertedRecords.add(document.Id);
        }
        
        return insertedRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<object> getfiles(string recordId) {
        return [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility, 
            	ContentDocument.Title, ContentDocument.Description, ContentDocument.FileExtension, ContentDocument.FileType, ContentDocument.CreatedDate 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =:recordId
            ORDER BY ContentDocument.CreatedDate DESC

        ];
    }
    
    @AuraEnabled
    public static List<object> getOppfiles(string recordId) {
        return [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility, 
            	ContentDocument.Title, ContentDocument.Description, ContentDocument.FileExtension, ContentDocument.FileType, ContentDocument.CreatedDate 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =:recordId
            ORDER BY ContentDocument.CreatedDate DESC

        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<object> getRelatedFiles(string AccountId, string OpportunityId){
        
        List <Contact> c = [SELECT Id
                            From Contact
                            Where AccountId =:AccountId];
        
        Set<Id> records = new Set<Id> {};
            
       	for(Contact con : c){
            records.add(con.Id);
       	}
        
        records.add(AccountId);
                
        List<object> documents = [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility, 
            	ContentDocument.Title, ContentDocument.Description, ContentDocument.FileExtension, ContentDocument.FileType, ContentDocument.CreatedDate 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =:records
            ORDER BY ContentDocument.CreatedDate DESC

        ];
        
        //Remove Duplicates
       	Set<object> myset = new Set<object>();
        List<object> result = new List<object>();
        myset.addAll(documents);
        result.addAll(myset);
        
        return result;
        
    }  

}