({
    doInit : function(component, event) {
        var action = component.get("c.getEmails");
        action.setCallback(this, function(a) {
            component.set("v.Emails", a.getReturnValue());            
        });
        $A.enqueueAction(action);
    }, 
    init : function(component, event, helper) {
        var empApi = component.find("empApi");
        
        // Error handler function that prints the error to the console.
        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this);
        
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);
        
        var channel='/event/Demo_Event__e';
        var sub;
        
        // new events
        var replayId=-1;
        
        var callback = function (message) {
            component.find('notifLib').showToast({
                "title": "Message Received!",
                "message": message.data.payload.Message__c
            });        
        }.bind(this);
        
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
            sub = value;
            component.set("v.sub", sub);
        });
    }
})