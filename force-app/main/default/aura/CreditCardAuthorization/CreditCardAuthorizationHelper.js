({
	    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error",
            duration: '4000'
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
            console.log('ah::warning ' + toastParams.message);
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    
    NoActivityError : function() {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: 'Screen was in Idle state for a minute. To secure credit card info, screen has been closed.',
            type: "error",
            duration: '8000'
        };
        
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})