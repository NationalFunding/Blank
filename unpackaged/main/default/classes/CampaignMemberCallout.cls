public class CampaignMemberCallout {
    public class Input {
        @InvocableVariable(required=true)
        public String relativeUrl;
    }

    public class Output {
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String errorMessage;
    }

    @InvocableMethod(label='Campaign Member Action')
    public static List<Output> campaignMemberAction(List<Input> inputs) {
        List<Output> results = new List<Output>();

        Output result = new Output();

        if (inputs == null || inputs.isEmpty()) {
            result.errorMessage = 'No input provided.';
            results.add(result);
            return results;
        }

        Input input = inputs[0];

        String relativeUrl = input.relativeUrl;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CampaignMember_API/' + relativeUrl);
        req.setMethod('POST');
       	try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                String body = res.getBody();
                Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(body);
                Boolean isAccountUpdated = parsed.containsKey('AccountUpdated') ? (Boolean) parsed.get('AccountUpdated') : false;
                String accountId = parsed.containsKey('SalesforceAccountId') ? (String) parsed.get('SalesforceAccountId') : null;
                String leadId = parsed.containsKey('SalesforceLeadId') ? (String) parsed.get('SalesforceLeadId') : null;
                
                if(isAccountUpdated && string.isNotBlank(accountId)){
                    result.recordId = accountId;
                }else if(String.isNotBlank(leadId)){
                    result.recordId = leadId;
                }else{
                    result.errorMessage = 'Lead ID and Account Id not found in response.';
                }		
            } else {
                result.errorMessage = 'API Error: ' + res.getStatusCode() + ' - ' + res.getBody();
            }

        } catch (Exception e) {
            result.errorMessage = 'Exception: ' + e.getMessage();
        }

        results.add(result);
        return results;
    }
}