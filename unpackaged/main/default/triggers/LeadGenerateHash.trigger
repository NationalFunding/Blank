trigger LeadGenerateHash on Lead (before insert, before update) {

        for(Lead l : trigger.new) {
               if (l.SSN_Encrypted__c != '' && l.SSN_Encrypted__c != null && (trigger.isInsert || l.SSN_Encrypted__c != trigger.oldMap.get(l.id).SSN_Encrypted__c)) { // You need to check to see if it's changed, otherwise you're generating a hash on EVERY save
                   String temp = l.SSN_Encrypted__c.replace('-','') + '3M!NamoN#piM'; // salts are added to the end of the string
                   Blob mac = Crypto.generateDigest('SHA-256',Blob.valueOf(temp)); // you should be generating a digest, not a message authenticator
                   String csvBody = EncodingUtil.convertToHex(mac);
                   l.SSN_Hashed__c = csvBody;
                }
            else if (l.SSN_Encrypted__c == '' && (trigger.isInsert || l.SSN_Encrypted__c != trigger.oldMap.get(l.id).SSN_Encrypted__c)) l.SSN_Hashed__c = ' ';
        }

}