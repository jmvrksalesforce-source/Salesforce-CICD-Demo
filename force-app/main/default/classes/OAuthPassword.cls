public class OAuthPassword {
    public String clientId     {set;get;}
    public String clientSecret   {set;get;}
    public String username    {set;get;}
    public String password    {set;get;}
    public String  jsonString  {set;get;}
    public String accessToken  {set;get;}
    public List<String> names   {set;get;}
    public void getToken(){
system.debug('getToken');
        String url='https://test.salesforce.com/services/oauth2/token';
        String body='grant_type=password&';
        body=body+'client_id='+clientId;
        body=body+'&client_secret='+clientSecret;
        body=body+'&username='+username;
        body=body+'&password='+password;
        Http p=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndPoint(url);
        request.setBody(body);
        request.setMethod('POST');
        HttpResponse response=p.send(request);
        jsonString=response.getBody();
        System.JSONParser jp=JSON.createParser(jsonString);
        accessToken=jsonString;
system.debug(jsonString);
system.debug('I am here1');
        while(jp.nextToken()!=null){
            if(jp.getText()=='access_token'){
system.debug('Iam Here2');
                jp.nextToken();
                accessToken=jp.getText();
system.debug(accessToken);
            }
        }
    }
    public void getData(){
        Http p=new Http();
        HttpRequest request=new HttpRequest();
        request.setEndPoint('https://mcmakler--st.sandbox.my.salesforce.com/services/data/v59.0/sobjects/Account/0015t00001HeyBd');
        request.setMethod('GET');
        request.setHeader('Authorization','OAuth '+accessToken);
        HttpResponse response=p.send(request);
        jsonString=response.getBody();
    }
}