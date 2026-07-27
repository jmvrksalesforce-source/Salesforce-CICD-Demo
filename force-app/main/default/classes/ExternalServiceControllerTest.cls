@IsTest
public class ExternalServiceControllerTest {

    @TestSetup
    static void setupTestData() {
        test.startTest();
        insert (new ExternalService__c( Name = 'DefaultSettings', External_API_Endpoint__c = 'https://mock.api/endpoint' ));
        test.stoptest();
    }

    private class SuccessfulCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class FailedCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": false}');
            res.setStatusCode(500); // Simulate failure
            return res;
        }
    }

    @IsTest
    static void testSuccessfulResponse() {
        Test.setMock(HttpCalloutMock.class, new SuccessfulCalloutMock());

        ExternalServiceController.ResponseWrapper response = ExternalServiceController.getResponse();

        System.assertEquals('Success', response.status);
        System.assertEquals('200', response.statusCode);
    }

    @IsTest
    static void testFailedResponse() {
        Test.setMock(HttpCalloutMock.class, new FailedCalloutMock());
        
        ExternalServiceController.ResponseWrapper response = ExternalServiceController.getResponse();

        System.assertEquals('Failed', response.status);
        System.assertEquals('500', response.statusCode);
    }

    @IsTest
    static void testError() {
        test.starttest();
            delete [SELECT Id FROM ExternalService__c WHERE Name = 'DefaultSettings'];
        test.stoptest();
        
        ExternalServiceController.ResponseWrapper response = ExternalServiceController.getResponse();

        System.assertEquals('Error', response.status);
        System.assertEquals('N/A', response.statusCode);
    }
}