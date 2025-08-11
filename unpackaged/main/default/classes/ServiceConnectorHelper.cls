public with sharing class ServiceConnectorHelper {
    
    public static Boolean runningInASandbox {
        get {
            if(runningInASandbox == null) runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            return runningInASandbox;
        }
        set;
    }
    
    public static HttpResponse sendRequest(String method, String url, Map<String,String> headers, String requestBody){
        return sendRequest(method, url, headers, requestBody, null);
    }
    
    //Method to execute REST request to external service.
    public static HttpResponse sendRequest(String method, String url, Map<String,String> headers, String requestBody, String certificateName){
        return sendRequest(method, url, headers, requestBody, null, null);
    }
    
    public static HttpResponse sendRequest(String method, String url, Map<String,String> headers, String requestBody, String certificateName, Integer timeOut){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(url);
        req.setTimeout(timeOut != null ? timeOut : 120000);
        if(String.isNotBlank(certificateName)) req.setClientCertificateName(certificateName);
        if(String.isNotBlank(requestBody)) req.setBody(requestBody);
        for(String key: headers.keySet()) req.setHeader(key, headers.get(key));
        return new Http().send(req);
    }
    
    public static HttpResponse sendWellsFargoRequest(String method, String url, Map<String,String> headers, String requestBody){
        WF_Api_Settings__c settings = WF_Api_Settings__c.getInstance();
        String prodCert = settings.Production_Certificate_Name__c ?? 'WellsFargoProduction';
        String stagingCert = settings.Staging_Certificate_Name__c ?? 'WellsFargoStaging';
        String certificateName = (runningInASandbox) ? stagingCert : prodCert;
        return sendRequest(method, url, headers, requestBody, certificateName, NumberUtils.getInteger(WellsFargoAPI.WF_Settings.API_TimeOut__c));
    }

}