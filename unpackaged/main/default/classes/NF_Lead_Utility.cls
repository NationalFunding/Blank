public class NF_Lead_Utility 
{
    public string b = null;
    
    public void normalizedPhone(List<Lead> leads)
    {
        for(Lead l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Phone))
                {
                    string p = l.Phone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);              
                    if (b != null) 
                    {
                        l.Phone_Trim__c = b;
                    }
                    
                }
                else
                {
                    l.Phone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
                
            }
        }
    }
    
    public void normalizedMPhone(List<Lead> leads)
    {
        for(Lead l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.MobilePhone))
                {
                    string p = l.MobilePhone;    
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.MobilePhone_Trim__c = b;
                    }
                }
                else
                {
                    l.MobilePhone_Trim__c = null;
                }
            }
            catch(Exception e)
            {    
            }
        }
    }
    
    
    public void normalizedHPhone(List<Lead> leads)
    {
        for(Lead l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Home_Phone__c))
                {
                    string p = l.Home_Phone__c;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.Home_Phone_Trim__c = b;
                    } 
                }
                else
                {
                    l.Home_Phone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    
    //<!-------contacts------------>
    public void normalizedPhoneContact(List<Contact> leads)
    {
        for(Contact l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Phone))
                {
                    string p = l.Phone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.Phone_Trim__c = b;
                    }
                    
                }
                else
                {
                    l.Phone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    
    
    public void normalizedPhoneMContact(List<Contact> leads)
    {
        for(Contact l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.MobilePhone))
                {
                    string p = l.MobilePhone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.MobilePhone_Trim__c = b;
                    }
                }
                else
                {
                    l.MobilePhone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    
    
    public void normalizedPhoneOContact(List<Contact> leads)
    {
        for(Contact l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.OtherPhone))
                {
                    string p = l.OtherPhone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.OtherPhone_Trim__c = b;
                    } 
                }
                else
                {
                    l.OtherPhone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    
    
    public void normalizedPhoneHContact(List<Contact> leads)
    {
        for(Contact l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.HomePhone))
                {
                    string p = l.HomePhone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.HomePhone_Trim__c = b;
                    }   
                }
                else
                {
                    l.HomePhone_Trim__c = null;
                }
            }
            catch(Exception e)
            {   
            }
        }
    }
    
    //<!-------Account------------>
    public void normalizedPhoneAccount(List<Account> leads)
    {
        for(Account l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Phone))
                {
                    string p = l.Phone;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);                    
                    if (b != null) 
                    {
                        l.Phone_Trim__c = b;
                    } 
                }
                else
                {
                    l.Phone_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    
    public void normalizedPhone2Account(List<Account> leads)
    {
        for(Account l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Phone_2__c))
                {
                    string p = l.Phone_2__c;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.Phone_2_Trim__c = b;
                    }
                }
                else
                {
                    l.Phone_2_Trim__c = null;
                }
            }
            catch(Exception e)
            {  
            }
        }
    }
    
    public void normalizedPhone3Account(List<Account> leads)
    {
        for(Account l : leads)
        {
            try
            {   
                if(String.isNotBlank(l.Phone_3__c))
                {
                    string p = l.Phone_3__c;
                    string a = p.replaceAll('[^0-9]', '');
                    Decimal b = Decimal.valueOf(a);
                    if (b != null) 
                    {
                        l.Phone_3_Trim__c = b;
                    }   
                }
                else
                {
                    l.Phone_3_Trim__c = null;
                }
            }
            catch(Exception e)
            {
            }
        }
    }
    //Amrit: Existing phone Normalize methods can be replaced with this generic method. 
     public static void normalizePhoneFields(List<SObject> records, Map<String, String> phoneFields) {
        for (SObject record : records) {
            // Loop through each phone field in the map
            for (String phoneField : phoneFields.keySet()) {
                try {
                    String phoneValue = (String) record.get(phoneField); // Get the phone value
                    String phoneTrimField = phoneFields.get(phoneField); // Get the trim field to store cleaned phone number

                    if (String.isNotBlank(phoneValue)) {
                        // Clean phone number to keep only digits
                        String cleanedPhone = phoneValue.replaceAll('[^0-9]', '');

                        if (!String.isEmpty(cleanedPhone)) {
                            // Convert cleaned phone number to Decimal
                            Decimal phoneDecimal = Decimal.valueOf(cleanedPhone);
                            if (phoneDecimal != null) {
                                // Set the cleaned phone number to the corresponding trim field
                                record.put(phoneTrimField, phoneDecimal);
                            }
                        }
                    } else {
                        // If phone value is blank, set trim field to null
                        record.put(phoneTrimField, null);
                    }
                } catch (Exception e) {
                    // Handle exception as needed (e.g., logging errors)
                    System.debug('Error processing phone field: ' + phoneField + ' for record ' + record.Id);
                    // Optionally log the error for debugging purposes
                }
            }
        }
    }
}