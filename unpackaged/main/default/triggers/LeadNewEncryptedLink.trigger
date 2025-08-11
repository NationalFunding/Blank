trigger LeadNewEncryptedLink on Lead (after insert) {
    List<Lead> leadList = [Select Id, Encrypted_Email_String__c, Response_Channel__c, Encrypted_Email_String_Refresh_Date__c, Lending_Tree_Id__c, 
                    IsConverted, Originating_Brand__c, National_Funding_WebId__c, Web_Id_NatFund__c, OwnerId From Lead Where Id=: trigger.new[0].id];
    for (Lead l : leadList) {

        String brand;
        String sourceOrg = 'National Funding';
        Boolean userHasBothBrands = false;
        User userInfo = new User();

        if(l.ownerId != null) {
            //owned by a user
            if (l.OwnerId.getSObjectType() == Schema.User.SObjectType) {
                userInfo = [Select Id, Available_Brands__c From User Where Id =:l.OwnerId];
                if(userInfo?.Available_Brands__c != null) {
                    if(userInfo.Available_Brands__c.contains('Quick Bridge') && userInfo.Available_Brands__c.contains('National Funding')) {
                        userHasBothBrands = true;
                    }
                    else if(userInfo.Available_Brands__c.contains('Quick Bridge')) {
                        brand = 'Quick Bridge';
                    }
                    else if(userInfo.Available_Brands__c.contains('National Funding')) {
                        brand = 'National Funding';
                    }
                } else {
                    brand = 'National Funding';
                }
            }
            else {
                //if not owned by a user, we are checking the originating brand field on lead and if that is null, we are defaulting to generating both tokens
                if(l.Originating_Brand__c != null) {
                     brand = l.Originating_Brand__c;
                } else {
                    userHasBothBrands = true;
                }
            }
        }

        String val;
        if(l.National_Funding_WebId__c != NULL && l.Web_Id_NatFund__c == NULL){
            l.Web_Id_NatFund__c = l.National_Funding_WebId__c;
        } 
        if(l.Encrypted_Email_String__c == null && l.Response_Channel__c == 'Internet' && !l.IsConverted){
            val = l.id + ',' + l.Web_Id_NatFund__c;
            system.debug('OP val1: ' + val);
        }
        if(l.Encrypted_Email_String__c == null && l.Lending_Tree_Id__c != NULL && !l.IsConverted){
            val = l.id + ',' + l.Web_Id_NatFund__c;
            system.debug('OP val2: ' + val);
        }
        if(userHasBothBrands) {
            ConsoleApplicationLinkController.getShortenedLinkLT(val, sourceOrg, 'Quick Bridge');
            ConsoleApplicationLinkController.getShortenedLinkLT(val, sourceOrg, 'National Funding');
        } else {
            ConsoleApplicationLinkController.getShortenedLinkLT(val, sourceOrg, brand);
        }
    }
    update leadList;
}