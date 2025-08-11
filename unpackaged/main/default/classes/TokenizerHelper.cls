/**
 * Created by oporter on 10/15/2018..
 * //note for self: tokenizer can take in lead, contact, and funding id
 * 
 * 2024-10-22      Updated code to use v4 version of Tokenizer Endpoint per PD-5335 (FTC-614)
 */

global class TokenizerHelper {
    private String tokensAPIEndpoint;
    private String tokenizerAPIKey;

    public TokenizerHelper(){
        initalizeFromConfig();
    }
    private void initalizeFromConfig() {
        HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
        this.tokensAPIEndpoint = tokenizerConfig.Endpoint__c;
        this.tokenizerAPIKey = tokenizerConfig.APIKEY__c;
    }

    public HttpResponse postTokenizer(String securityToken, String payloadJSON) {
        system.debug('payloadJSON:: ' + payloadJSON);
        if (payloadJSON == null) {
            throw new GenericException('Tokenizer was called with no IDs. The ID must be either a Contact or Lead.');
        }
        HttpRequest tokenizerRequest = new HttpRequest();
        tokenizerRequest.setMethod('POST');
        tokenizerRequest.setEndpoint(tokensAPIEndpoint);
        tokenizerRequest.setHeader('Authorization', 'token ' + securityToken);
        tokenizerRequest.setHeader('Content-Type', 'application/json');
        tokenizerRequest.setTimeout(30000);
        tokenizerRequest.setBody(payloadJSON);
        Http http = new Http();
        HttpResponse response = http.send(tokenizerRequest);
        if (!WebHelper.isSuccessStatus(response)) {
            throw new GenericException('There has been an error calling the tokenizer service.');
        }
        return response;
    }
  
    private Map<String, String> parseBulkResponse(String response) {
        system.debug('response to be parsed:: ' + response);
        TokensListWrapper tokensListWrapper = new TokensListWrapper();
        tokensListWrapper.tokenItems = (List<TokensListWrapper.TokenItem>)JSON.deserialize(response, List<TokensListWrapper.TokenItem>.class);

        Map<String, String> tokenIdMap = new Map<String, String>();
        for(TokensListWrapper.TokenItem t : tokensListWrapper.tokenItems) {
            tokenIdMap.put(t.Id, t.Token);
        }
        return tokenIdMap;
    }

    public String getTokenizedPayload(Map<String, String> payload) {
        TokensBulkRequestWrapper tokensBulkRequestWrapper = new TokensBulkRequestWrapper();
        TokensBulkRequestWrapper.TokenItem tokenItem = new TokensBulkRequestWrapper.TokenItem();
        tokenItem.Id = '1';
        tokenItem.Properties = payload;
        tokensBulkRequestWrapper.TokenItems = new List<TokensBulkRequestWrapper.TokenItem>{tokenItem};

        Map<String, String> tokenizedPayload = getTokenizedPayloadsBulk(tokensBulkRequestWrapper);
        if(tokenizedPayload.containsKey('1') == false) {
            throw new GenericException('The tokenizer did not return the expected result. Id not found.');
        }
        return tokenizedPayload.get('1');
    }

    public Map<String, String> getTokenizedPayloadsBulk(TokensBulkRequestWrapper payloads) {
        STSHelper stsHelper = new STSHelper();
        String tokenizerSecurityToken = stsHelper.getSecurityToken(tokenizerAPIKey);
        String requestBody = JSON.serialize(payloads.TokenItems);


        HttpResponse httpResponse = postTokenizer(tokenizerSecurityToken, requestBody);
        if (!WebHelper.isSuccessStatus(httpResponse)) {
            throw new GenericException('There has been an error calling the tokenizer service.');
        }

        String httpResponseString = httpResponse.getBody();
        Map<String, String> idAndTokenMap = parseBulkResponse(httpResponseString);
        system.debug('tokenIDMap:: ' + idAndTokenMap);
        if (idAndTokenMap == null || idAndTokenMap.isEmpty()) {
            throw new GenericException('The tokenizer service did not provide the expected return.');
        }
        return idAndTokenMap;
    }
}