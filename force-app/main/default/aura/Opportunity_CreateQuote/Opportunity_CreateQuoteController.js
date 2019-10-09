({
    doCreateQuote : function(component, event, helper) {
        
        component.set("v.isLoading", true);

        var action = component.get("c.CreateQuoteCtrl");
        action.setParams({ 
        	paramOpportunityId : component.get("v.recordId"),
        	paramRecordTyeDevName : component.get("v.value") 
        });
        // set callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.CreateQuoteId", response.getReturnValue());
                component.set("v.isLoading", false);
                // helper.navigateToRecord(component, event, component.get("v.CreateQuoteId") );
 
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.CreateQuoteId")
                });
                navEvt.fire();

                // $A.get("e.force:closeQuickAction").fire();
                // $A.get('e.force:refreshView').fire();     
            }
            else if (state === "INCOMPLETE") {
                // show incomplete error message
            }
            else if (state === "ERROR") {
                helper.closeQuickAction(component, event, helper);
                let errors = response.getError();
                
                helper.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
        
    },
    cancel : function(component, event, helper){
        helper.closeQuickAction(component, event, helper);
    }
})