({
    doInit : function(component, event, helper) {
        component.set("v.loading","True");
        helper.loadPhysicians(component, event);
    },
    
    getPhysicianSched : function(component, event, helper) {
        var currSpec = component.get("v.currSpec");
        if(currSpec==null || currSpec=='None') alert('Please select a Specialization');
        else {
            component.set("v.loading","True");

            var offSet= component.get('v.offSet');
            component.set('v.offSet',0);

            component.set("v.DispHdr","False");
            component.set("v.physicians",[]);
            component.set("v.weekIdx",0);
            helper.loadPhysicians(component, event);
        }
    },
    
    getAuthentication : function(component, event, helper) {
        helper.getGoogleAuthentication(component, event);
    },
    
    AuthenticationLater : function(component, event, helper) {
        component.set("v.showModal",-1);
    },
    
    SpecChanged : function(component, event, helper) {
        var currSpec = component.get("v.currSpec");
        if(currSpec=="None" || currSpec==""){
            component.set("v.DispHdr","False");
            component.set("v.loading","False");
            component.set("v.fee","0");
        }
        else{
            var fees=component.get("v.fees");
            
            for(var key in fees){
                if(fees[key].key == currSpec) component.set("v.fee",fees[key].value);
            }
            //helper.loadPhysicians(component, event);
        }
    },
    
    addNxtWkIcnBlink : function(component, event, helper) {
        var itm= component.find('nxtWkIcn');
        $A.util.addClass(itm,'blink');
    },
    
    rmvNxtWkIcnBlink : function(component, event, helper) {
        var itm= component.find('nxtWkIcn');
        $A.util.removeClass(itm,'blink');
    },
    
    addBckWkIcnBlink : function(component, event, helper) {
        var itm= component.find('prvWkIcn');
        $A.util.addClass(itm,'blink');
    },
    
    rmvBckWkIcnBlink : function(component, event, helper) {
        var itm= component.find('prvWkIcn');
        $A.util.removeClass(itm,'blink');
    },
    
    prevPage : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.physicians",[]);
        var offSet= component.get('v.offSet');
        component.set('v.offSet',offSet-1);
        
        component.set("v.DispHdr","False");
        helper.loadPhysicians(component, event);
    },
    
    nextPage : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        component.set("v.physicians",[]);
        var offSet= component.get('v.offSet');
        component.set('v.offSet',offSet+1);
        
        helper.loadPhysicians(component, event);
    },
    
    getMorningSlots : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        component.set("v.physicians",[]);
        component.set("v.slotType","Morning");
        
        helper.loadPhysicians(component, event);
    },
    
    getEveningSlots : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        component.set("v.physicians",[]);
        component.set("v.slotType","Evening");
        
        helper.loadPhysicians(component, event);
    },
    
    getAllDaySlots : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        component.set("v.physicians",[]);
        component.set("v.slotType","All");
        
        helper.loadPhysicians(component, event);
    },
    
    nextWeek : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        component.set("v.physicians",[]);
        
        var weekIdx = component.get("v.weekIdx");
        weekIdx = weekIdx + 1;
        component.set("v.weekIdx",weekIdx);
        
        helper.loadPhysicians(component, event);
    },
    
    prevWeek : function(component, event, helper) {
        component.set("v.loading","True");
        component.set("v.DispHdr","False");
        var weekIdx = component.get("v.weekIdx");
        component.set("v.physicians",[]);
        
        weekIdx = weekIdx - 1;
        component.set("v.weekIdx",weekIdx);
        
        helper.loadPhysicians(component, event);
    },
    
    closeApp : function(component,event,helper){
        component.set("v.loading","False");
        component.set("v.showModal",-1);
    },
    
    
    closeDialog : function(component,event,helper){
        component.set("v.loading","False");
        component.set("v.showModal",0);
    },
    
    SendSharingRequest : function(component,event,helper){
        component.set("v.showModal",0);
        helper.SendGCalSharingRequest(component,event);
    },
    
    DontSendSharingRequest : function(component,event,helper){
        component.set("v.showModal",5);
    },
    
    submitEvent : function(component,event,helper){
        component.set("v.showModal",0);
        component.set("v.loading","True");
        helper.SubmitEvent(component,event);
    },
    
    submitEvent2 : function(component,event,helper){
        component.set("v.showModal",0);
        component.set("v.loading","True");
        component.set("v.createGCal","false");
        helper.SubmitEvent(component,event);
    },
    
    getPatientInfo : function(component,event,helper){
        var allValid = component.find('validateField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (allValid) component.set("v.showModal",2);
    },
    
    createEvent : function(component, event, helper) {
        var params = event.getParams();
        
        component.set("v.params", params);
        component.set("v.DoctorName", params["salutation"] + ' ' + params["cntName"]);
        component.set("v.DateMonthDay", params["monthDate"] + ' - ' + params["day"]);
        component.set("v.Time", params["slot"]);
        component.set("v.fee", params["fee"]);
        component.set("v.showModal",1);
    },
})