({
    navigateToRecord:function(component, event, recId)
    {
        //alert(recId);
        var sobjectEvent=$A.get("e.force:navigateToSObject");
        sobjectEvent.setParams({
            "recordId": recId  
        });
        sobjectEvent.fire();
    }
    ,
    closeQuickAction : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
    
})