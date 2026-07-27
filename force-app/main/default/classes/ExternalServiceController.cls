/****************************************************************************************/
/* Author       : Madhu Ramakrishna                                                     */
/* Created Date : 16.09.2024                                                            */
/* Test Class   : ExternalServiceControllerTest                                         */
/* Description  : Task by Beyonnex                                                      */
/* ------------------------------------ Change Logs ----------------------------------- */
/* Changed By   : Date       : Description                                              */
/****************************************************************************************/
public with sharing class ExternalServiceController {
    @AuraEnabled
    public static ResponseWrapper getResponse() {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        
        try {
            String endpointUrl = ExternalService__c.getInstance('DefaultSettings').External_API_Endpoint__c;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('GET');
            
            HttpResponse res = http.send(request);
            if (res.getStatusCode() == 200) {
                ResponseWrapper deserializedResponse = (ResponseWrapper)JSON.deserialize(res.getBody(),ResponseWrapper.class);
                responseWrapper.status = deserializedResponse.success == true ? 'Success' : 'Failed';
                responseWrapper.statusCode = String.valueOf(res.getStatusCode());
            } else {
                responseWrapper.status = 'Failed';
                responseWrapper.statusCode = String.valueOf(res.getStatusCode());
            }
        } catch (Exception e) {
            responseWrapper.status = 'Error';
            responseWrapper.statusCode = 'N/A';
        }
        
        return responseWrapper;
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String statusCode;
    }
}