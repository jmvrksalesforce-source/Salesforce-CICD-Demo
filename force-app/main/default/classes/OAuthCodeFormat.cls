public class OAuthCodeFormat {
    public String clientId     {set;get;}
    public String clientSecret   {set;get;}
    public String redirectUrl  {set;get;}
    public String code      {set;get;}
    public string accessToken  {set;get;}
    public String jsonString  {set;get;}
    public List<String> names   {set;get;}
    public OAuthCodeFormat(){
        redirectUrl='https://sfjmvrk-dev-ed--c.vf.force.com/apex/myResponse';
    }
    public PageReference getMyCode(){
        String url='https://test.salesforce.com/services/oauth2/authorize?';
        url=url+'response_type=code&client_id='+clientId+'&redirect_uri='+redirectUrl;
        PageReference p=new PageReference(url);
        return p;
    }
    public void load(){
        code=Apexpages.currentpage().getparameters().get('code');
    }
    public void getToken(){
        Http p=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        String body='grant_type=authorization_code&';
        body=body+'client_secret='+clientsecret;
        body=body+'&client_id='+clientId;
        body=body+'&redirect_uri='+redirectUrl;
        body=body+'&code='+code;
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response=p.send(request);
        jsonString=response.getBody();
         System.JSONParser jp=JSON.createParser(jsonString);
        while(jp.nextToken()!=null){
            if(jp.getText()=='access_token'){
                jp.nextToken();
                accessToken=jp.getText();
            }
        }
    }
    public void getData(){
        Http p=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndPoint('https://mcmakler--st.sandbox.my.salesforce.com/00Q8E000009wSL6');
        request.setMethod('GET');
        request.setHeader('Authorization','OAuth '+accessToken);
        HttpResponse response=p.send(request);
        jsonString=response.getBody();
        names=new List<String>();
        System.JSONParser jp=JSON.createParser(jsonString);
        while(jp.nextToken()!=null){
            if(jp.getText()=='name'){
                jp.nextToken();
                names.add(jp.getText());
            }
        }
    }
}