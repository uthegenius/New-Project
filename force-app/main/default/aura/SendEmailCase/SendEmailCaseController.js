({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   sendEmail: function(component, event, helper) {
       
       
     
       var action = component.get("c.sendemailtoTeam");
        debugger;
        action.setParams({ Caseid : component.get("v.recordId")});
        // set callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var res=response.getReturnValue();
                if(res==="Succeed")
                {
                    $A.get("e.force:closeQuickAction").fire();
                     var toastEvent = $A.get("e.force:showToast");
                     
                   toastEvent.setParams({
                              title: "Success!",
                              message: "Email has been Sent!",
                              type: "success"
                               });
                     toastEvent.fire();

                }
                else if(res==="NoTeam")
                {
                     $A.get("e.force:closeQuickAction").fire();
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                              title: "Failed!",
                              message: "Sorry Team does not exists!",
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
                     toastEvent.fire();
                
                            
            }
        });
        // enqueue action
        $A.enqueueAction(action);
       
         


       
   },
})