({
    closeModel: function(component, event, helper) {
        component.destroy();
        $A.get("e.force:closeQuickAction").fire();
    },
    doInit: function (component, event, helper) {
        if(component.get("v.callType")=='SSS'){
            var a = component.get('c.submitToSAP');
            $A.enqueueAction(a);
            
        }        
    },
    submitToSAP: function(component, event, helper) {
        debugger;
        try{
            let button = event.getSource();
            button.set('v.disabled',true);
        }
        catch(err) {
            console.log(err);
        }
        component.set("v.isLoading", true);
        
        var action = component.get("c.callAction");
        action.setParams({
            ObjId : component.get("v.recordId"),
            callType: component.get("v.callType"),
        });
        
        
        
        action.setCallback(this, function(response) {  
            var state = response.getState();
            var MessageType ='success';
            var Message='';
            if (state === 'SUCCESS') {                                               
                if (response.getReturnValue().IsSuccessfull){
                    MessageType ='success';
                    Message = response.getReturnValue().SuccessMessage;
                }
                else{
                    MessageType ='error';
                    Message = response.getReturnValue().ErrorMessage;
                }
                setTimeout(function(){
                    //component.set("v.isLoading", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        type: MessageType,
                        key: 'info_alt',
                        message: Message,
                        duration:' 3000'
                    });
                    $A.get("e.force:closeQuickAction").fire();                    
                    toastEvent.fire();
                    //component.set("v.isLoading", false);
                    setTimeout(function(){
                    $A.get('e.force:refreshView').fire(); 
                        }, 4500)
                }, 1000);
                
            }
        });
        $A.enqueueAction(action); 
    },
    
})