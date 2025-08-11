trigger ContactGenerateHash on Contact (before insert, before update) {

        for(Contact c : trigger.new)     {
        
              if (c.SSN_Encrypted__c != '' && c.SSN_Encrypted__c != null && (trigger.isInsert || c.SSN_Encrypted__c != trigger.oldMap.get(c.id).SSN_Encrypted__c)) { // You need to check to see if it's changed, otherwise you're generating a hash on EVERY save
                   String temp = c.SSN_Encrypted__c.replace('-','') + '3M!NamoN#piM'; // remove dashes and salts are added to the end of the string
                   Blob mac = Crypto.generateDigest('SHA-256',Blob.valueOf(temp)); // you should be generating a digest, not a message authenticator
                   String csvBody = EncodingUtil.convertToHex(mac);
                   c.SSN_Hashed__c = csvBody;
                }
            else if (c.SSN_Encrypted__c == '' && (trigger.isInsert || c.SSN_Encrypted__c != trigger.oldMap.get(c.id).SSN_Encrypted__c)) c.SSN_Hashed__c = ' ';
        }

}