({
    init : function(component, event, helper) {
        
        component.set("v.isLoading", true);
        
        var action = component.get("c.fetchRecordTypeValues");
        
        action.setCallback(this, function(response){
            
            component.set("v.isLoading", false);
            
            var state = response.getState();
            
            if(state === "SUCCESS"){ 
                
                var retVal = response.getReturnValue();
                
                component.set("v.lstOfRecordType",retVal);
                component.set("v.selectedRecType",retVal[0]);
                //component.set("v.selectedRecType",retVal[0]);
            }
            
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    // //check rec type values
    // handleChange: function (component, event) {
    //     var checkOpt = event.getParam("selOpt");
        
    //     component.set('v.selectedRecType', checkOpt);
        
    // },
    
    //Creates activity record and redirect
    createRecord: function(component, event, helper) {
        component.set("v.isOpen", true);
        
        var recTypeVal = component.get("v.selectedRecType");
        
        var action = component.get("c.getRecTypeId");
        action.setParams({
            "recordTypeLabel": recTypeVal
        });
        
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                var getObjWrpValue  = response.getReturnValue();
                var RecTypeID = getObjWrpValue.recTypeId;
                var context = getObjWrpValue.uiTheme;
                var region =getObjWrpValue.userRegion;
                var callCenter=getObjWrpValue.callCenter;
                
                if(context == 'Theme4t' || context == 'Theme3') {
          
                    component.set("v.isLoading", true);
                    sforce.one.createRecord('Order', RecTypeID, 
                        {   AccountId : component.get("v.CaseRecordField.AccountId"), 
                            Case__c : component.get("v.recordId"),
                            EffectiveDate :  $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                            Region__c:region,
                         	//Call_Center__c:region.substring(0, 2).toUpperCase() +' - '+callCenter,
                            Status :  'Open'
                        }
                                 
                     );
                    //alert(callCenter);
                    component.set("v.isLoading", false);
                    component.set("v.isOpen", false);
                } 
                else{
                    component.set("v.isLoading", true);
                    var createRecordEvent = $A.get("e.force:createRecord");
                    var defaultValues = {
                            'AccountId': component.get("v.CaseRecordField.AccountId"),
                            'Case__c' : component.get("v.recordId"),
                            'EffectiveDate' : $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                            'Region__c':region,
                            //'Call_Center__c':region.substring(0, 2).toUpperCase() +' - '+callCenter,
                            'Status' : 'Open'
                        };
                    //alert(defaultValues);
                    createRecordEvent.setParams({
                        "entityApiName": 'Order',
                        "recordTypeId": RecTypeID,
                        "defaultFieldValues": defaultValues
                    });
                    //alert (region.substring(0, 2).toUpperCase() +' - '+callCenter);
                   //alert(callCenter);
                    createRecordEvent.fire();
                    component.set("v.isLoading", false);
                }
            } else if (state == "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Oops!",
                    "message": "No Internet Connection"
                });
                toastEvent.fire();
                
            } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})