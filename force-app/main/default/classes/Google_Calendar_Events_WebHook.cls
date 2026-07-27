@RestResource(urlMapping='/Google_Calendar_Events_WebHook/*')
global class Google_Calendar_Events_WebHook {
    @HttpPost
    global static void doPost() {
        System.debug('Google_Calendar_Events_WebHook doPost');

        try{
            RestRequest req = RestContext.request;
            String content=req.requestBody != null ? req.requestBody.toString() : '';
            syncEvent(content);
            system.debug(content);
        }catch(Exception e){ setResponse(400, e.getMessage() + ' ' + e.getCause()); return;}
		setResponse(200, 'Success');
    }

    public static void setResponse(Integer stCode, String body){
        RestResponse res = RestContext.response;
        res.statusCode=stCode;
        res.responseBody=Blob.valueOf(body);
    }
    
    public static void syncEvent(String content){
		System.debug('Google_Calendar_Events_WebHook syncEvent');
        
		System.debug(content);
        Event e=(Event) JSON.deserialize(content, Event.class);
        system.debug(e);
        
        insert e;
    }
}