({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      $A.get("e.force:closeQuickAction").fire();
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
       
     
   },
 
    
    cancelBtn : function(component, event, helper) { 
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 

    },
    
    
   deleteQuote: function(component, event, helper) {
       
       
       //component.set("v.Spinner", true);
       var action = component.get("c.deletedquoteAction");
        action.setParams({ qid : component.get("v.recordId")});
        // set callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var res=response.getReturnValue();
                if(res==="Succeed")
                {

                    
                    $A.get("e.force:closeQuickAction").fire();
                     var toastEvent = $A.get("e.force:showToast");
                     var homeEvent = $A.get("e.force:navigateToObjectHome");

                     
                   toastEvent.setParams({
                              title: "Success!",
                              message: "Quote was deleted!",
                              type: "success"
                               });
                
                    homeEvent.setParams({
                    "scope": "Opportunity"
                    });
                
                     homeEvent.fire();
                     toastEvent.fire();

                }
                else if(res==="Failed")
                {
                     $A.get("e.force:closeQuickAction").fire();
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                              title: "Failed!",
                              message: "Quote cannot be deleted. Please contact your Salesforce administrator.",
                              type: "failed"
                               });
                   toastEvent.fire();

                    
                    
                }
                component.set("v.isOpen", false);
                $A.get("e.force:closeQuickAction").fire();
                //console.log("Quote cloned");
            }
            else if (state === "INCOMPLETE") {
                // show incomplete error message
            }
            else if (state === "ERROR") {
                //helper.closeQuickAction(component, event, helper);
                component.set("v.isOpen", false);
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                              title: "Failed!",
                              message: "Something might went wrong Contact your admin Support!",
                              type: "success"
                               });
                
                //var toastEvent = $A.get("e.force:closedQuickAtion");                
                
                
                     toastEvent.fire();
                
                            
            }
        });
        // enqueue action
        $A.enqueueAction(action);
       
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