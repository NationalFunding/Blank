/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: AccountTriggerHelper
* DESCRIPTION:This class is a part of trigger related logic
* @author         Amrit
* @version        1.0
* @created        22/01/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
public class AccountTriggerHelper {
	private static final List<String> LEGAL_TERMS = new List<String>{
         'A Professional Limited Liability Company','limited liability company','ltd liability company','Limited Liability Partnership','A Professional Corporation',
         'A Professional Corporati','A Professional Corp','Professional Corporation','PROFESSIONAL CORPORATI','Professional Corp','Limited Partnership',
         'Sole Proprietor','Sole Proprietor','Sole Prop','incorporated','corporation','incorporate','incorporat','corporatio','incorpora','corporati',
         'incorpor','corporat','LIMITED','incorpo','corpora','incorp','limite','corpor','corpo', 'CORP','LLC','ltd','INC','LLP'
    };
    public static void beforeInsert (List<Account> newAccounts)
	{
		//Generating Vendor Number for Vendor Acct record Type (SPR-78)
        generateVendorNumber(newAccounts);
        accountGenerateHash(newAccounts, null);
		nFPhoneNormalizationA(newAccounts);
	}
	public static void beforeUpdate (List<Account> newAccounts, Map<Id, Account> oldAccounts)
	{
		accountGenerateHash(newAccounts, oldAccounts);
		nFPhoneNormalizationA(newAccounts);
	}
	private static void accountGenerateHash(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
        // Get current user and their group memberships
        Id userId = UserInfo.getUserId();
        List<GroupMember> groupMembers = [
            SELECT Group.Name 
            FROM GroupMember 
            WHERE UserOrGroupId = :userId
        ];
        
        Set<String> userGroups = new Set<String>();
        for (GroupMember gm : groupMembers) {
            userGroups.add(gm.Group.Name);
        }
        
        for (Account acc : newAccounts) {
            String federalTaxId = acc.Fed_Tax_ID__c;
            // Handle Insert and Update Logic
            if (Trigger.isInsert || (Trigger.isUpdate && oldAccounts != null && oldAccounts.get(acc.Id).Fed_Tax_ID__c != acc.Fed_Tax_ID__c)) {
                // Validate and sanitize Federal Tax ID
                if (String.isNotBlank(federalTaxId)) {
                    federalTaxId = federalTaxId.replaceAll('[^0-9]', '');
                    if (federalTaxId.length() != 9) {
                        federalTaxId = '';
                        if (!userGroups.contains('Auto Data Standardization')) {
                            acc.addError('The entered Federal Tax Id number is incorrect. Please ensure the following formatting is followed: ##-####### or ######### and that there are 9 numeric digits.');
                            continue;
                        }
                    }
                    acc.Fed_Tax_ID__c = federalTaxId;
                    // Generate hashed value
                    String saltedValue = federalTaxId + '3M!NamoN#piM';
                    Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(saltedValue));
                    acc.Fed_Tax_ID_Hashed__c = EncodingUtil.convertToHex(hash);
                } else {
                    acc.Fed_Tax_ID_Hashed__c = '';
                }
            }
        }
    }
    private static void nFPhoneNormalizationA(List<Account> accounts) {
		String legalName;
		String legalNameNormal;
		String allPunctuation = '~!@#$%^*()_+|}{":?><`=;/.,][-\'\\';
        for (Account acc : accounts) {
            legalName = acc.Legal_Name__c;
            if (String.isNotBlank(legalName)) {
                legalNameNormal = legalName.toUpperCase();
                // Replace '&' and other special characters
                legalNameNormal = legalNameNormal.replaceAll('&AMP;', ' AND ').replaceAll('&APOS;', '\'').replaceAll('&', ' AND ');
                if (legalNameNormal.containsAny(allPunctuation)) {
					legalNameNormal = legalNameNormal.replaceAll('\\p{Punct}', '');
					System.debug('got into punctuation::' + legalNameNormal);
				}
                // Replace "CO" with "COMPANY" (ensure case insensitivity)
            	legalNameNormal = legalNameNormal.replaceAll('(?i)\\bCO\\b', 'COMPANY'); 
                // Handle legal terms at the end of the name
                for (String term : LEGAL_TERMS) {
                    if (legalNameNormal.endsWithIgnoreCase(' ' + term)) {
                        String regex = '(?i)(' + term + ')$';
                        legalNameNormal = legalNameNormal.replaceAll(regex, '');
                        break;
                    }
                }
				// Normalize whitespace (remove multiple spaces)
            	legalNameNormal = legalNameNormal.replaceAll('\\s+', ' ').trim();
                acc.Legal_Name_Normal__c = legalNameNormal;
            }
            // Normalize phone fields
            normalizePhone(accounts);
        }
    }    
    private static void normalizePhone(List<Account> accounts)
    {
        // Define a map to hold the field names and corresponding trim fields
        Map<String, String> phoneFields = new Map<String, String>{
            'Phone' => 'Phone_Trim__c',
            'Phone_2__c' => 'Phone_2_Trim__c',
            'Phone_3__c' => 'Phone_3_Trim__c'
        };
        NF_Lead_Utility.normalizePhoneFields(accounts,phoneFields);
    }
    private static void generateVendorNumber(List<Account> newAccounts) {
        //Generating Vendor Number for Vendor Acct record Type (SPR-78)
        Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor Acct').getRecordTypeId();
        List<Account> accts = new List<Account>();
        
        for (account acct : newAccounts){
        	if (acct.RecordTypeId == vendorRecordTypeId)
            accts.add(acct);
		}
    	if (accts.size() > 0)
        CBSL_AccountCommands.generateVendorNumber(accts);
    }
}