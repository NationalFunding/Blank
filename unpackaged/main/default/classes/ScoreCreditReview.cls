/**
 * Created by oporter on 9/13/2018.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: ScoreCreditReview
* DESCRIPTION: This is the action behind the "Rescore" button on the Credit Review page
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @version        1.0
* @created        2018-09-14
* @modified
* @systemLayer
* @see
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1              oporter@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v2              test@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2024-10-22      Updated code to use v4 version of Tokenizer Endpoint per PD-5335 (FTC-614)
*
*/

global class ScoreCreditReview {

    @RemoteAction
    global static Map<String, String> rescoreCreditReviewRemoteAction(string credit_reviewId){
        return rescoreCreditReview(credit_reviewId);
    }

    public static Map<String, String> rescoreCreditReview(string credit_reviewId){
        //Annual Revenue, SIC Code, PG1 Fico
        Map<String, String> scoreResult = new Map<String, String>();
        Credit_review__c obj = [
                select Id,Annual_Revenue__c, SIC_Code__c, PG1__c, PG1__r.FICO_Score__c,PG_1_EQF_Score__c,
                        Create_WC_Decision_Record__c,
                        WC_Decision_Recomendation__c,
                        WC_Decision_Record__c
                from Credit_review__c
                where id = :credit_reviewId
        ];

        if(obj.Annual_Revenue__c != null && obj.SIC_Code__c != null && obj.PG1__c != null && obj.PG_1_EQF_Score__c != null) {
            // Store what the origin value of the decision record
            String orig_rec = obj.WC_Decision_Recomendation__c;
            // YhatModels.decisionMdl expects a list of Credit Review IDs so that's what we give it
            List<Id> crIds = new List<Id>();
            crIds.add(credit_reviewId);

            // decision the Credit Review
            getScore(crIds);

            // Get the new decision recommendation
            Credit_Review__c cr = [SELECT Id, WC_Decision_Recomendation__c from Credit_Review__c where id = :credit_reviewId];
            String final_rec = cr.WC_Decision_Recomendation__c;

            scoreResult.put('before', orig_rec);
            scoreResult.put('after', final_rec);
            return scoreResult;
        }
        else {
            throw new GenericException('The Credit Review is missing information. Please ensure Annual Revenue, FICO Score, and SIC Code are filled in before pulling again.');
        }
    }

    public static Boolean isSuccessStatus(HttpResponse httpResponse){
        Integer httpStatus = integer.valueof(httpResponse.getStatusCode());
        return httpStatus >= 200 && httpStatus <= 299;
    }

    public static void getScore(List<Id> creditReviewIds){
        HTTPCalloutConfiguration__mdt creditModelConfig = HTTPCalloutConfiguration__mdt.getInstance('CreditModel');
        String creditModelEndpoint = creditModelConfig.Endpoint__c;
        String apikey = creditModelConfig.APIKEY__c;

        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        String stsEndpoint = stsConfig.Endpoint__c; 
             
        String authentication = authorize(stsEndpoint, apikey);
        Integer responseStatus;
        for(Id crId : creditReviewIds) {
            postCreditReviewService(creditModelEndpoint, authentication, crId);
        }
    }

    public static String authorize(String stsEndpoint, String apikey){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(stsEndpoint);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('"' + apikey + '"');
        httpRequest.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        if (!isSuccessStatus(response)) {
            throw new GenericException('There has been an error calling the STS service.');
        }
        String securityToken = response.getBody();
        String tokenizerAuthentication = 'token ' + securityToken;
        return tokenizerAuthentication;
    }

    public static void postCreditReviewService(String creditModelEndpoint, String authorization, Id creditReviewId){
        HttpRequest creditModelRequest = new HttpRequest();
        creditModelRequest.setMethod('POST');
        creditModelRequest.setEndpoint(creditModelEndpoint);
        creditModelRequest.setHeader('Authorization', authorization);
        creditModelRequest.setHeader('Content-Type', 'application/json');
        creditModelRequest.setTimeout(120000);
        creditModelRequest.setBody('{"CreditReviewId":"' + creditReviewId + '"}');
        Http http = new Http();
        HttpResponse response = http.send(creditModelRequest);
        if (!isSuccessStatus(response)) {
            throw new GenericException('There has been an error calling the Credit Model service.');
        }
    }
}