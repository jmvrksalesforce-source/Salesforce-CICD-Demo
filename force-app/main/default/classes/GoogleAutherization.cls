public class GoogleAutherization {
    public string message{get;set;}
    
    public void load(){
        GoogleCalendar__c gc = GoogleCalendar__c.getInstance(Userinfo.getProfileId());
        if(gc.Access__c=='' || gc.Access__c==null) {
            String code=Apexpages.currentpage().getparameters().get('code');
            String body='';
            body+='code='+Apexpages.currentpage().getparameters().get('code');
            body+='&client_id='+gc.clientId__c;
            body+='&client_secret='+gc.clientSecret__c;
            body+='&redirect_uri='+gc.RedirectUri__c;
            body+='&grant_type=authorization_code';
            body+='&scope=https://www.googleapis.com/auth/admin.directory.resource.calendar';
            
            Http p=new Http();
            HttpRequest request=new HttpRequest();
            
            request.setHeader('Content-type','application/x-www-form-urlencoded');
            request.setEndPoint('https://www.googleapis.com/oauth2/v4/token');
            
            request.setBody(body);
            request.setMethod('POST');
            HttpResponse response=p.send(request);
            String accessToken = '', refreshToken = '';
            
            System.JSONParser jp=JSON.createParser(response.getBody());
            while(jp.nextToken()!=null){
                if(jp.getText()=='access_token'){
                    jp.nextToken();
                    accessToken=jp.getText();
                }
                if(jp.getText()=='refresh_token'){
                    jp.nextToken();
                    refreshtoken=jp.getText();
                }
            }
            if(accessToken!='') gc.AccessToken__c = accessToken;
            if(refreshToken!='') gc.RefreshToken__c = refreshToken;
            update gc;
            
            if(accessToken!='') message = 'Authorization success!';
        }
    }
}