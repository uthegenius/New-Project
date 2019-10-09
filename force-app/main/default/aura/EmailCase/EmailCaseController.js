({
    handleClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.email.Id")
        });
        navEvt.fire();
        window.setTimeout(
            $A.getCallback(function() {
                var clickme = component.get('v.onclick');
                $A.enqueueAction(clickme); 
            }), 6000
        );
        
    },
    handleCaseClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.email.ParentId")
        });
        navEvt.fire();     
    }
})