/** 
 *  @Description: Helper for Callout. Uses Metadata records for config
 *  @Created:     10/15/2018 by Olivia Porter, National Funding (Ticket: N/A)
 *  @Updated:     08/05/2025 by Will Caisido, FairSquare (Ticket: BAU-762)
 */

global class STSHelper {
    private String stsAPIEndpoint;

    public STSHelper(){
        initalizeFromConfig();
    }

    // Constructor for Test Class:
    public STSHelper(String customEndpoint) {
        this.stsAPIEndpoint = customEndpoint;
    }

    private void initalizeFromConfig() {
        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        this.stsAPIEndpoint = stsConfig.Endpoint__c ;
    }

    public String getSecurityToken(String apiKey) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(stsAPIEndpoint);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('"' + apikey + '"');
        httpRequest.setTimeout(30000);
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);

        if (!WebHelper.isSuccessStatus(httpResponse)) {
            throw new GenericException('There has been an error calling the STS service.');
        }
        String securityToken = httpResponse.getBody();
        return securityToken;
    }
}