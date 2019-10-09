({
    doCloneQuote : function(component, event, helper) {
        //Disable the button
        var btn = event.getSource();
		btn.set("v.disabled",true);
        //alert(component.get("v.value"));
        // call clone quote controller method
        var action = component.get("c.cloneQuote");
        debugger;
        action.setParams({ quoteId : component.get("v.recordId"), recTypeDevName : component.get("v.value") });
        // set callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // show success message
                component.set("v.clonedQuoteId", response.getReturnValue());
                helper.navigateToRecord(component, event, component.get("v.clonedQuoteId") );
                $A.get("e.force:closeQuickAction").fire();
                console.log("Quote cloned");
            }
            else if (state === "INCOMPLETE") {
                // show incomplete error message
            }
            else if (state === "ERROR") {
                helper.closeQuickAction(component, event, helper);
                let errors = response.getError();
                
                helper.handleErrors(errors);
                //let errorData = JSON.parse(action.getError()[0]);
                //console.error("Error: "+ errorData.message);
                
             //  var errorMsg = action.getError()[0].message;
              //  console.error("Error:"+errorMsg);
               
            }
        });
        // enqueue action
        $A.enqueueAction(action);
        
    },
    cancel : function(component, event, helper){
        //$A.get("e.force:closeQuickAction").fire();
        helper.closeQuickAction(component, event, helper);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
      
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})