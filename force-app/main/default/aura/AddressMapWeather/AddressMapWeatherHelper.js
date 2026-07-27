({
    loadCurrentWeather : function(component, event) {
        var action = component.get("c.GetWeatherInfo");
        action.setParams({ AdrsId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().startsWith('Error - ')){
                    alert(response.getReturnValue());
                    component.set("{!v.CurrentWeather}",response.getReturnValue());
                }else{
                    var obj=JSON.parse(response.getReturnValue());
                    //parse current data
                    component.set("{!v.CurrentTemp}",obj["current"]["temp"]);
                    component.set("{!v.CurrentIcon}",obj["current"]["weather"][0]["icon"]);
                    component.set("{!v.CurrentHumidity}","Humidity: " + obj["current"]["humidity"] + " %");
                    component.set("{!v.CurrentWindSpeed}","Wind speed: " + obj["current"]["wind_speed"] + " m/s");
                    component.set("{!v.CurrentWeather}",obj["current"]["weather"][0]["description"]);
                    
                    //parse forcast +1h data
                    component.set("{!v.ForcastTemp1}",obj["hourly"][0]["temp"]);
                    component.set("{!v.ForcastIcon1}",obj["hourly"][0]["weather"][0]["icon"]);
                    component.set("{!v.ForcastHumidity1}","Humidity: " + obj["hourly"][0]["humidity"] + " %");
                    component.set("{!v.ForcastWindSpeed1}","Wind speed: " + obj["hourly"][0]["wind_speed"] + " m/s");
                    component.set("{!v.ForcastWeather1}",obj["hourly"][0]["weather"][0]["description"]);
                    
                    //parse forcast +2h data
                    component.set("{!v.ForcastTemp2}",obj["hourly"][1]["temp"]);
                    component.set("{!v.ForcastIcon2}",obj["hourly"][1]["weather"][0]["icon"]);
                    component.set("{!v.ForcastHumidity2}","Humidity: " + obj["hourly"][1]["humidity"] + " %");
                    component.set("{!v.ForcastWindSpeed2}","Wind speed: " + obj["hourly"][1]["wind_speed"] + " m/s");
                    component.set("{!v.ForcastWeather2}",obj["hourly"][1]["weather"][0]["description"]);
                    
                    //parse forcast +3h data
                    component.set("{!v.ForcastTemp3}",obj["hourly"][2]["temp"]);
                    component.set("{!v.ForcastIcon3}",obj["hourly"][2]["weather"][0]["icon"]);
                    component.set("{!v.ForcastHumidity3}","Humidity: " + obj["hourly"][2]["humidity"] + " %");
                    component.set("{!v.ForcastWindSpeed3}","Wind speed: " + obj["hourly"][2]["wind_speed"] + " m/s");
                    component.set("{!v.ForcastWeather3}",obj["hourly"][2]["weather"][0]["description"]);
                    
                    var d=new Date();
                    var TMStr = d.toLocaleTimeString();
                    
                    d.setHours(d.getHours()+1);
                    var d1=d.toLocaleTimeString().substr(0,5);
                    TMStr = d.toLocaleTimeString();
                    if(d1.endsWith(':')) d1=d.toLocaleTimeString().substr(0,4);
                    var tabLabel1 = component.find("one").get("v.label");
                    tabLabel1[0].set("v.value", d1 + TMStr.substr(TMStr.length - 3, TMStr.length - 1));
                    
                    d.setHours(d.getHours()+1);
                    var d2=d.toLocaleTimeString().substr(0,5);
                    TMStr = d.toLocaleTimeString();
                    if(d2.endsWith(':')) d2=d.toLocaleTimeString().substr(0,4);
                    var tabLabel2 = component.find("two").get("v.label");
                    tabLabel2[0].set("v.value", d2 + TMStr.substr(TMStr.length - 3, TMStr.length - 1));
                    
                    d.setHours(d.getHours()+1);
                    var d3=d.toLocaleTimeString().substr(0,5);
                    TMStr = d.toLocaleTimeString();
                    if(d3.endsWith(':')) d3=d.toLocaleTimeString().substr(0,4);
                    var tabLabel3 = component.find("three").get("v.label");
                    tabLabel3[0].set("v.value", d3 + TMStr.substr(TMStr.length - 3, TMStr.length - 1));
                }
                
                var tab = event.getSource();
                switch (tab.get('v.id')) {
                    case 'Now' :
                        this.injectComponent(component.get("v.CurrentIcon"), 
                                             component.get("v.CurrentTemp"), 
                                             component.get("v.CurrentHumidity"), 
                                             component.get("v.CurrentWindSpeed"), 
                                             component.get("v.CurrentWeather"), 
                                             'c:CurrentWeather', 
                                             tab);
                        break;
                }
            }
            else if (state === "ERROR") {}
        });
        $A.enqueueAction(action);
    },
    
    injectComponent: function (CurrentIcon, CurrentTemp, CurrentHumidity, CurrentWindSpeed, CurrentWeather, name, target) {
        $A.createComponent(name, {CurrentIcon : CurrentIcon, 
                                  CurrentTemp : CurrentTemp, 
                                  CurrentHumidity : CurrentHumidity, 
                                  CurrentWindSpeed : CurrentWindSpeed, 
                                  CurrentWeather : CurrentWeather
                                 }, function (contentComponent, status, error) {
                                     if (status === "SUCCESS") {
                                         target.set('v.body', contentComponent);
                                     } else {
                                         throw new Error(error);
                                     }
                                 });
    }
})