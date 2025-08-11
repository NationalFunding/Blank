/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * TITLE: QBUnsubscribe
 * DESCRIPTION: This class is used in Unsubscribe_QB Email Service for Unsubscribe of Quick Bridge
 * @author         Amrit
 * @version        1.0
 * @created        30/05/2025
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 */
global class QBUnsubscribe implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope env
    ) {
        // Create an InboundEmailResult object to return the result
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // Contact and Lead lists to hold all the updated records
        List<Contact> contactList = new List<Contact>();
        List<Lead> leadList = new List<Lead>();
        
        // Convert subject line to lowercase for case-insensitive matching
        String subjectLower = email.subject != null ? email.subject.toLowerCase() : '';
        String keyword = 'unsubscribe';
        
        // Check if the subject contains the keyword
        Boolean unsubMe = subjectLower.contains(keyword);
        
        if (unsubMe) {
            try {
                // Query matching Contacts
                for (Contact c : [
                    SELECT Id, Name, Email, QB_Marketing_Opt_Out__c
                    FROM Contact
                    WHERE Email = :env.fromAddress
                        AND QB_Marketing_Opt_Out__c = false
                    LIMIT 100
                ]) {
                    c.QB_Marketing_Opt_Out__c = true;
                    contactList.add(c);
                }
                
                // Update all matched Contacts
                if (!contactList.isEmpty()) {
                    update contactList;
                }
            } catch (System.QueryException e) {
                System.debug('Contact Query Issue: ' + e.getMessage());
            }

            try {
                // Query matching Leads
                for (Lead l : [
                    SELECT Id, Name, Email, QB_Marketing_Opt_Out__c
                    FROM Lead
                    WHERE Email = :env.fromAddress
                        AND IsConverted = false
                        AND QB_Marketing_Opt_Out__c = false
                    LIMIT 100
                ]) {
                    l.QB_Marketing_Opt_Out__c = true;
                    leadList.add(l);
                    System.debug('Lead Object: ' + l);
                }

                // Update all matched Leads
                if (!leadList.isEmpty()) {
                    update leadList;
                }
            } catch (System.QueryException e) {
                System.debug('Lead Query Issue: ' + e.getMessage());
            }

            System.debug('Found the unsubscribe word in the subject line.');
        } else {
            System.debug('No unsubscribe word found in the subject line.');
        }

        // Set result to success and return
        result.success = true;
        return result;
    }
}