global class GetWeatherInfo {
    static String appid=System.Label.OpenWeatherApiKey;
    
    @AuraEnabled
    public static String GetWeatherInfo(Id AdrsId){
        system.debug('inside GetWeatherInfo');
        //Get Address__c details
        
        Address__c adr=[select id,Postal_Code__c,CountryCode__c from Address__c where id =:AdrsId];
        if(adr != null){
            if(String.isNotBlank(adr.Postal_Code__c) && String.isNotBlank(adr.CountryCode__c)){
                String PstlCd=adr.Postal_Code__c;
                if(adr.Postal_Code__c.contains(' ')) {
                    PstlCd = PstlCd.replaceall(' ','+');
                }
                return getLatLon(PstlCd, adr.CountryCode__c);
            } else return 'Error - Invalid PostalCode or CountryCode';
        }
        return 'Error - Address not found';
    }
    
    public static String getLatLon(String PostalCode, String CountryCode){
        system.debug('inside getLatLon');
        
        //CURRENT WEATHER API call
        try{
            String endPoint='https://api.openweathermap.org/data/2.5/weather?zip=' + PostalCode + ',' + CountryCode + '&appid=' + appid;
            http http=new http();
            httpRequest hReq=new httpRequest();
            hReq.setMethod('GET');
            hReq.setEndpoint(endPoint);
            httpResponse hResp = new httpResponse();
            hResp=http.send(hReq);
            if(hResp.getStatusCode()==200){
                CurrentWeatherApi cwa = new CurrentWeatherApi();
                cwa.coord = new coord();
                cwa = (CurrentWeatherApi) JSON.deserialize(hResp.getBody(), CurrentWeatherApi.class);
                return getOneCallData('lat=' + cwa.coord.lat + '&lon=' + cwa.coord.lon);
            } return  'Error - Invalid PostalCode or CountryCode ' + hResp.getBody();
        }catch(exception e){return 'Error - Invalid PostalCode or CountryCode - ' + e.getMessage();}
    }
    
    public static String getOneCallData(String LatLonStr){
        system.debug('inside getOneCallData');
        
        OneCallApi oca = new OneCallApi();
        //ONECALL API call for 3 hours forecast
        try{
            String endPoint='https://api.openweathermap.org/data/2.5/onecall?' + LatLonStr + '&units=metric&%20exclude=hourly,daily&appid=' + appid;
            http http=new http();
            httpRequest hReq=new httpRequest();
            hReq.setMethod('GET');
            hReq.setEndpoint(endPoint);
            httpResponse hResp = new httpResponse();
            hResp=http.send(hReq);
            if(hResp.getStatusCode()==200){
                oca = (OneCallApi) JSON.deserialize(hResp.getBody(), OneCallApi.class);
                return JSON.serialize(oca);
            } return  'Error - OneCall Api Error Message- ' + hResp.getBody();
        }catch(exception e){return 'Error - OneCall Api Error- ' + e.getMessage();}
    }
    
    //Current Weather Api Wrappers
    public class CurrentWeatherApi{
        public coord coord;
    }
    
    public class Coord{
        public Decimal lat;
        public Decimal lon;
    }
    
    //OneCall Api Wrappers
    public class OneCallApi{
        public current current;
        public List<hourly> hourly;
    }

    public class Current{
        public Decimal temp;
        public Decimal humidity;
        public Decimal wind_speed;
        public Decimal wind_deg;
        public List<weather> weather;
    }
    
    public class Weather{
        public String description;
        public string icon;
    }
    
    public class Hourly{
        public Decimal temp;
        public Decimal humidity;
        public Decimal wind_speed;
        public Decimal wind_deg;
        public List<weather> weather;
    }
}