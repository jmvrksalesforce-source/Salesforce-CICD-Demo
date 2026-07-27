({
    loadPhysicians : function(component, event) {
        var action = component.get("c.getPhysicians");
        action.setParams({
            spec :component.get("v.currSpec"),
            weekIdx :component.get("v.weekIdx"),
            offSet :component.get("v.offSet"),
            slotType :component.get("v.slotType"),
            recsPerPage : component.get("v.recsPerPage"),
            appDt : component.get("v.appDt"),
            srchDctr : component.get("v.srchDctr")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                component.set("v.DispHdr","False");
                if(resp.startsWith('Error')){
                    component.set("v.loading","False");
                    alert(resp);
                }else if(resp.startsWith('Info-')){
                    component.set("v.loading","False");
                    if(resp.length>=6) resp=resp.substring(6,resp.length);
                    alert(resp);
                }else if(resp=='Missing Custom Settings'){
                    component.set("v.showModal",-1);
                    component.set("v.AuthMsg",'Your Profile Not Authorized to access Google Credentials from Custom Settings');
                }else if(resp.startsWith('Missing Google Authrization')){
                    component.set("v.showModal",3);
                    component.set("v.AuthMsg",'Missing Google Authrization. This application needs Google calendar authentication.');
                }else{
                    var obj=JSON.parse(resp);
                    if(component.get("v.firstRun") == "True") {
                        var specs=[];
                        specs.push({ value: 'None', label: '<None Selected>'});
                        var fees=[];
                        fees.push({value:'0',key:'0'});
                        for(var i=0;i<obj['specializations'].length;i++){
                            var v=''+obj['specializations'][i];
                            specs.push({ value: v, label: v});
                            fees.push({value:obj['fees'][i],key:v});
                        }
                        component.set("v.specs",specs);
                        component.set("v.fees",fees);
                        component.set("v.firstRun","False");
                    }
                    component.set("v.showModal",0);
                    component.set("v.specPhysMap",obj['specPhysMap']);
                    var TotalRecs = obj['TotalRecs'];
                    component.set("v.TotalRecs",TotalRecs);
                    
                    var recsPerPage = component.get("v.recsPerPage");
                    var offSet = component.get("v.offSet");
                    if((offSet + 1 ) * recsPerPage > TotalRecs) {
                        component.set("v.offSetRight", TotalRecs);
                    } else {
                        component.set("v.offSetRight", (offSet + 1 ) * recsPerPage);
                    }
                    
                    var scheduleMap = [];
                    var objScheduleMap = obj['scheduleMap'];
                    var dayTtls = [];
                    var dayMonthTtls = [];
                    var j=0;
                    for (var key in objScheduleMap) {
                        var val = {};
                        val = objScheduleMap[key];
                        scheduleMap.push({value:val, key:key});

                        if(j==0){
                            if(val.length != undefined){
                                for(var i=0;i<val.length;i++){
                                    if(i<7){
                                        dayTtls.push({value:val[i].day, key:val[i].monthDate});
                                        dayMonthTtls.push(val[i].monthDate);
                                    }
                                }
                            } else {
                                dayTtls.push(val.day);
                                dayMonthTtls.push(val.monthDate);
                            }
                            j++;
                        }
                    }
                    
                    component.set("v.dayTtls",dayTtls);
                    component.set("v.dayMonthTtls",dayMonthTtls);
                    
                    component.set("v.scheduleMap",scheduleMap);
                    if(dayTtls.length > 0){
                        component.set("v.loading","False");
                    }
                    
                    var specPhysMap = component.get("v.specPhysMap");
                    if(specPhysMap!==undefined && specPhysMap!==null){
                        component.set("v.physicians",specPhysMap[component.get("v.currSpec")]);
                    }

					var phys = [];
					phys = component.get("v.physicians");
                    
                    if(phys !== undefined) {
                        component.set("v.DispHdr","True");
                    }
                    component.set("v.loading","False");
                }
            }
        });
        $A.enqueueAction(action);
    },

	getGoogleAuthentication : function(component,event){
        var action = component.get("c.getAuthUrl");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var uri=response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": response.getReturnValue()
                });
                urlEvent.fire();
                component.set("v.showModal",-1);
            }
        });
        $A.enqueueAction(action);
    },
    
    SubmitEvent : function(component,event){
        var params = component.get("v.params");
        
        var action = component.get("c.createAppointment");
        action.setParams({
            createGCal :component.get("v.createGCal"),
            cntId :params["cntId"],
            slot :params["slot"],
            day :params["day"],
            monthDate :params["monthDate"],
            year :params["year"],
            patientName : component.get("v.Salutation") + ' ' + component.get("v.PatientName"),
            email : component.get("v.Email"),
            mobile : component.get("v.Mobile"),
            subject : component.get("v.Subject"),
            fee : component.get("v.fee")
        });
        action.setCallback(this, function(response) {
            component.set("v.createGCal","true");
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                if(resp.startsWith('Error')){
                    alert(resp);
                } else if(resp.startsWith('Insufficient Access')){
                    component.set("v.showModal",4);
                    var vs=[];
                    vs=resp.split(':');
                    for(var i=0;i<vs.length;i++){
                        if(i==1) component.set("v.DrEmail",vs[i]);
                    }
                } else {
                    //Add toast Message
                    $A.get("e.force:showToast").setParams({
                        "title": "Appointment confirmed!",
                        "message": resp
                    }).fire();
                    this.loadPhysicians(component, event);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    SendGCalSharingRequest : function(component,event){
        var params = component.get("v.params");
        
        var action = component.get("c.sendGCalSharingRequest");
        action.setParams({
            createGCal :component.get("v.createGCal"),
            cntId :params["cntId"],
            slot :params["slot"],
            day :params["day"],
            monthDate :params["monthDate"],
            year :params["year"],
            patientName : component.get("v.Salutation") + ' ' + component.get("v.PatientName"),
            email : component.get("v.Email"),
            mobile : component.get("v.Mobile"),
            subject : component.get("v.Subject"),
            fee : component.get("v.fee")
        });
        action.setCallback(this, function(response) {
            component.set("v.createGCal","true");
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                if(resp.startsWith('Error')){
                    alert(resp);
                } else {
                    //Add toast Message
                    $A.get("e.force:showToast").setParams({
                        "title": "Success!",
                        "message": "Email Request Sent"
                    }).fire();
                    component.set("v.showModal",5);
                }
            }
        });
        $A.enqueueAction(action);
    },
})