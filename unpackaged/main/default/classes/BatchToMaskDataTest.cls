/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: BatchToMaskDataTest 
* DESCRIPTION:This test class for batch class BatchToMaskData which is used to mask the actual data after sandbox refresh.
* @author         Supriya Gore
* @version        1.0
* @created        17/03/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
@isTest
public class BatchToMaskDataTest {
    
    @isTest
    static void testBatchExecution() {
        // Step 1: Create test data (Contacts with emails)
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                LastName = 'Test ' + i,
                Email = 'user' + i + '@example.com',
                Phone = '11111111'
            ));
        }
        insert contacts;
        
        Test.startTest();
            map<String,String> mapfieldType = new map<String,String>();
            mapfieldType.put('Phone','888-888-8888');
            mapfieldType.put('Email','invalid');
            
            // Instantiate the batch with 'Contact' as the object type
            BatchToMaskData batch = new BatchToMaskData('Contact',mapfieldType,'');
            // Execute the batch with a batch size of 2
            Database.executeBatch(batch);
            
            // Step 3: Verify the results
            // Query the records after the batch has executed
            List<Contact> updatedContacts = [SELECT Id, Email FROM Contact WHERE Id IN :contacts];
            
            // Step 4: Assert that the email addresses are masked
            for (Contact c : updatedContacts) {
                Integer lastDotIndex = c.Email.lastIndexOf('.');
                String result = (lastDotIndex != -1) ? c.Email.substring(lastDotIndex + 1) : '';
                System.assertNotEquals(result + '@example.com', c.Email, 'Email should be masked');
            }
            BatchToMaskData.errorWrapper errorwrapper =  new BatchToMaskData.errorWrapper(updatedContacts[0].id,'test error');
        test.stopTest();
    }
}