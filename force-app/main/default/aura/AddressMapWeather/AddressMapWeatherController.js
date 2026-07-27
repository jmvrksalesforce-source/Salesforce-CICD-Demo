({
    handleCurrent : function(component, event, helper) {
        if(component.get("v.InitialRun") == "1"){
            component.set("v.InitialRun","0");
            helper.loadCurrentWeather(component, event);
        }
    }
})