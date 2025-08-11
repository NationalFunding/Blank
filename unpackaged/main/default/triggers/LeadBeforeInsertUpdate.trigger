trigger LeadBeforeInsertUpdate on Lead (before insert, before update) 
{
    /** 4/5/12 walter - moving to account owner model so this is no longer needed
    
    Profile prof1 = [Select Id, Name from Profile where Name = 'FPC - Lease - Sales User'];
    
    Profile prof2 = [Select Id, Name from Profile where Name = 'FPC - MCA - Sales User'];   
     */
     
    //update the SIC lookup
    String sics = '';
    for (Lead l : Trigger.New) 
    {   
        if((Trigger.isInsert && l.SICCODE__c != null) || (Trigger.isUpdate && l.SICCODE__c != Trigger.oldMap.get(l.Id).SICCODE__c))
        {
            if(l.SICCODE__c != null)
            {
                sics +=  '\'' + l.SICCODE__c + '\',';
            }
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
    
    
    for (Lead l : Trigger.New) 
    {   
        if((Trigger.isInsert && l.SICCODE__c != null) || (Trigger.isUpdate && l.SICCODE__c != Trigger.oldMap.get(l.Id).SICCODE__c))
        {
            if(sicMap.get(l.SICCODE__c) != null)
            {
                l.SIC_Name__c = sicMap.get(l.SICCODE__c).Id;
                l.SICName__c = sicMap.get(l.SICCODE__c).SIC_Name__c;
            }
            else
            {
                l.SIC_Name__c = null;
                l.SICName__c = null;
                
            }
        }
    }   
    //End of update SIC lookup
    
  /** 4/5/12 walter - moving to account owner model so this is no longer needed
  this gets rid of  validation rule(s)...
   i.e. "Status Lease is Required", "Status MCA is Required"
    
    for (Lead l : Trigger.New) 
    {  
        System.debug('UserInfo.getProfileId ' +UserInfo.getProfileId() );

        if(UserInfo.getProfileId().Contains(prof1.Id))
        {
            System.debug('Status_Lease__c ' +l.FPC_Rep_Lease__c );
            
           
            
            if(l.Status_Lease__c == null)
            {
                l.Status_Lease__c.addError('Status Lease is Required');
            }
            else if(l.FPC_Rep_Lease__c == null)
            {
                l.FPC_Rep_Lease__c = UserInfo.getUserId();
                
                  String UID = UserInfo.getUserId();
                    User u = [select id,Email from User where Id = :UID];

                        l.Lease_Rep_Email__c = u.Email;
                
            }
            
            
          //  if(l.Status_MCA__c != Trigger.oldMap.get(l.Id).Status_MCA__c)
         //   {
         //       l.Status_MCA__c.addError('You do not have enough permissions to change the Status MCA field');
        //    } 
            
             if(l.Refer_To__c == 'Lease')
            {
                l.Refer_To__c.addError('You cannot Refer to Lease Users');
            }
        }   
        
        else if(UserInfo.getProfileId().contains(prof2.Id) )
        {
            System.debug('Status_MCA__c ' +l.FPC_Rep_MCA__c );
            if(l.Status_MCA__c == null)
            {
                l.Status_MCA__c.addError('Status MCA is Required');
            }
            else if(l.FPC_Rep_MCA__c == null)
            {
                l.FPC_Rep_MCA__c = UserInfo.getUserId();
               
                
                String UID = UserInfo.getUserId();

              User u = [select id,Email from User where Id = :UID];

                 l.MCA_Rep_Email__c = u.Email;
            }
            
         //   if(l.Status_Lease__c != Trigger.oldMap.get(l.Id).Status_Lease__c)
        //    {
       //         l.Status_Lease__c.addError('You do not have enough permissions to change the Status Lease field');
       //     }
            
              if(l.Refer_To__c == 'MCA')
            {
                l.Refer_To__c.addError('You cannot Refer to MCA Users');
            }
            
         //    if(l.Status_Lease__c != Trigger.oldMap.get(l.Id).Status_Lease__c)
        //    {
         //       l.Status_Lease__c.addError('You do not have enough permissions to change the Status Lease field');
        //    }
            
        }
        
    }   
    */
    
}