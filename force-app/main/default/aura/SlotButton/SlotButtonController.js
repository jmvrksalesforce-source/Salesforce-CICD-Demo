({
    fireEvent : function(component, event, helper) {
        var evnt = component.getEvent("SlotEvent1");
        evnt.setParams({
            cntName:component.get("v.cntName"),
            salutation:component.get("v.salutation"),
            cntId:component.get("v.cntId"),
            title:component.get("v.title"),
            fee:component.get("v.fee"),
            day:component.get("v.day"),
            slotType:component.get("v.slotType"),
            dayIndex:component.get("v.dayIndex"),
            slot:component.get("v.slot"),
            year:component.get("v.year"),
            monthDate:component.get("v.monthDate")
        }).fire();
    }
})