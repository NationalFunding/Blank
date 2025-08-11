/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: OnlineSalesCalculator
* DESCRIPTION: Upon approval of a Funding Record, we will generate a token to launch the Calculator Service
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @created        2018-06-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v2                oporter@nationalfunding.com
* 2021-12-16        removed catch that was eating exceptions, cleaned up code, enabled callout from trigger
* 2024-10-22        Updated code to use v4 version of Tokenizer Endpoint per PD-5335 (FTC-614)
*
*/

global class OnlineSalesCalculator {

    //new method
    @InvocableMethod
    public static void invocableOnlineCalculatorLinkGeneratorOnDemand(List<Id> ids){        
        for(Id fundingId : ids) {
            callTokenizer(fundingId);
        }
    }
    
    public void onlineCalculatorShortenedLink(Map<Id, FPC_Funding_del__c> newfundIds, Map<Id, FPC_Funding_del__c> oldFundIds){
        Id singleFundingId = null;
        Map<Id, FPC_Funding_del__c> fundingMap = new Map<Id, FPC_Funding_del__c>();
        for(FPC_Funding_del__c funding : newfundIds.values()){
            fundingMap.put(funding.Lender_ID__c, funding);
        }

        for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :fundingMap.keySet()]){
            if(acc.Name.contains('National Funding')){
                if(!System.isFuture()) {
                    callTokenizer(fundingMap.get(acc.id).Id);
                }
            }
        }
    }

    @future(callout=true)
    public static void callTokenizer(Id funderId){
        Map<String, String> tokenCredMap = new Map<String, String>();
        Id parsedId;
        String parsedToken;

        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        String stsEndpoint = stsConfig.Endpoint__c ;
        String apikey = stsConfig.APIKey__C;
        HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
        String tokenizerAPIEndpoint = tokenizerConfig.Endpoint__c;

        //------->Authorization<--------------
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(stsEndpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('"' + apikey + '"');
        Http h = new Http();
        HttpResponse res = h.send(req);
        String authcred = res.getBody();
        String svcAuth = 'token ';
        svcAuth += authcred;
        if(svcAuth == 'token {"Message":"An error has occurred."}'){
            throw new GenericException('STS Service is down. Please contact your system admin.');
        }

        //------->POST<-----------------
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(tokenizerAPIEndpoint);
        req1.setHeader('Authorization', svcAuth);
        req1.setHeader('Content-Type', 'application/json');
        req1.setBody('{"data": {"ID":"' + funderId + '", "fundingId":"' + funderId + '", "GeneratingTime":"' + Date.today().format() + '"}}');

        Http h1 = new Http();
        HttpResponse res1 = h1.send(req1);
        String tokencred = res1.getBody();
        system.debug('tokencred:: ' + tokencred);

        JSONParser parser = JSON.createParser(tokencred);

        //parse and map the returned string
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token')) { 
                parser.nextToken();
                parsedToken = parser.getText();
            }
        }

        String tokenCredentialString = parsedToken;
        if(tokenCredentialString != null && tokenCredentialString != ''){
            fpc_funding_del__c f = new fpc_funding_del__c(Id= funderId,CalculatorLink__c= tokenCredentialString);
            system.debug('f:: ' +f );
            update f;
        }
    }
    
    public PageReference onlineCalculatorLinkGeneratorOnDemand(){
        String funderId = ApexPages.currentPage().getParameters().get('funderId');
        system.debug('funderID1:: ' + funderId);
        callTokenizer(funderId);
        return new pageReference('/' + funderId);
    }
}