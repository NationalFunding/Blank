/*
* Created by oporter on 12/28/18
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: SyndicationOrchestrator
* DESCRIPTION: When NF does not approve a deal, we send the deal to Syndication. This class is the interfaction between us and the other provider APIS.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @version        1.0
* @created        2018-12.28
* @modified
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* v1              test@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* v2			  
*2025-05-02		  Update getSyndication method regarding SPR-122.Fetches the Syndication configuration based on the brand.
*
*/

public with sharing class SyndicationOrchestrator {

    @InvocableMethod
    public static void getSyndication(List<SyndicationRequestWrapper> requests) {
        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
         Map<String, HTTPCalloutConfiguration__mdt> syndicationConfigMap = new Map<String, HTTPCalloutConfiguration__mdt>{
            'Quick Bridge' => HTTPCalloutConfiguration__mdt.getInstance('Syndication_QB'),
            'Default'      => HTTPCalloutConfiguration__mdt.getInstance('Syndication')
        };
        
        for (SyndicationRequestWrapper request : requests) {
            Id fundingId = request.fundingId;
            HTTPCalloutConfiguration__mdt syndicateConfig = syndicationConfigMap.containsKey(request.brand) ? syndicationConfigMap.get(request.brand) : syndicationConfigMap.get('Default');
            authenticateAndPostSyndicationService(stsConfig.Endpoint__c, syndicateConfig.APIKey__c, syndicateConfig.Endpoint__c, fundingId);        
    	}
    }

    public static String authorize(String stsEndpoint, String apikey){
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(stsEndpoint);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('"' + apikey + '"');
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        if (!WebHelper.isSuccessStatus(response)) {
            throw new GenericException('There has been an error calling the STS service.');
        }
        String securityToken = response.getBody();
        system.debug('security token:: ' + securityToken);
        String tokenizerAuthentication = 'token ' + securityToken;
        return tokenizerAuthentication;
    }

    @Future(callout=true)
    public static void authenticateAndPostSyndicationService(String stsEndpoint, String apikey, String syndicationEndpoint, Id fundingId){
        String authorization = authorize(stsEndpoint, apikey);
        HttpRequest synHttpRequest = new HttpRequest();
        synHttpRequest.setMethod('POST');
        synHttpRequest.setEndpoint(syndicationEndpoint);
        synHttpRequest.setHeader('Authorization', authorization);
        synHttpRequest.setHeader('Content-Type', 'application/json');
        synHttpRequest.setBody('{"FundingId":"' + fundingId + '"}');
        Http http = new Http();
        HttpResponse response = http.send(synHttpRequest);
        system.debug('response:: ' + response);
        system.debug('response:: ' + response.getBody());
        if (!WebHelper.isSuccessStatus(response)) {
            updateFundingRecordError(response.getStatusCode(), response.getStatus(), fundingId);
        }
    }

    public static void updateFundingRecordError(Integer statusCode, String status, Id fundingId){
        NFLogger.logError('SyndicationOrchestrator', 'There has been an issue with Funding Record(s): ' + fundingId, status);
        FPC_Funding_del__c fundingRecord = new FPC_Funding_del__c(Id = fundingId, Status__c = 'Error', Error_Message__c = status);
        update fundingRecord;
    }
    
    public class SyndicationRequestWrapper {
        @InvocableVariable(required=true)
        public Id fundingId;
    
        @InvocableVariable(required=true)
        public String brand;
    }
}