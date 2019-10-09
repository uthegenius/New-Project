({
	quoteQLIList : function(component, event, helper) {
        var action = component.get("c.getAssociatedQLI");
        component.set("v.isLoading", true);
        action.setParams({
            quoteId: component.get("v.recordId")
        });
       
        action.setCallback(this,function(a){
            console.info(a.getReturnValue());
            component.set("v.quoteLineItemList", a.getReturnValue());
            component.set("{!v.isLoading}", false); 
        });
        $A.enqueueAction(action);
    },
   quoteName : function(component, event, helper) {
        var action = component.get("c.getQuoteName");
       console.info("KA:: AS "+component.get("v.recordId"));
        component.set("v.isLoading", true);
        action.setParams({
            quoteId: component.get("v.recordId")
        });
        
        action.setCallback(this,function(a){
            console.info("KA:: "+a.getReturnValue());
            component.set("v.quoteName", a.getReturnValue());
            //component.set("v.quoteURL","https://lwta--full.lightning.force.com/"+component.get("v.recordId"));
            component.set("v.quoteURL",window.location.href);
            component.set("{!v.isLoading}", false); 
        });
        $A.enqueueAction(action);
    },
    
   DeleteQLI : function(component, event, helper) {
       component.set("v.isLoading", true);
        var dep1 = component.find("dependent");
      var listOfId = [];
    for(var i=0;i<dep1.length;i++){
        var cond = dep1[i].get("v.value");
        if( cond == true){
          listOfId.push(component.find("dependent")[i].get("v.text"));
          }  
        
       } 
       console.log('KA:: selectd id' + listOfId);
       component.set("v.massDeleteList" , listOfId);       
         var delIdsPassInClass = component.get("v.massDeleteList");
         var action = component.get("c.massDeleteQLI");
         action.setParams({ 
             "delIDs" :  delIdsPassInClass
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
                
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'pester',
                    type: MessageType,
                    key: 'info_alt',
                    message: Message,
                    duration:' 3000'
                });
                component.set("v.isLoading", false);
                toastEvent.fire();
                if (response.getReturnValue().IsSuccessfull){
                    
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();  
                    
                }
                
                                                      
                
            }
        });
         $A.enqueueAction(action);
    },
    CancelDeleteQLI : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.quoteLineItemList");
        var checkvalue = component.find("SelectAll").get("v.value");        
        var dependent = component.find("dependent"); 
        if(checkvalue == true){
            for(var i=0; i<dependent.length; i++){
                dependent[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<dependent.length; i++){
                dependent[i].set("v.value",false);
            }
        }
    },
  /* checkAllCheckboxes : function(component, event, helper) {
        var checkboxes = component.find("dependent");
       var isSelectAll = component.find("isSelectAll");
        for (var i = 0; i < checkboxes.length; i++){
            if(isSelectAll == true){
                checkboxes[i].set("v.value",false);
                
            }
            
        }
    }*/
    
    checkAllCheckboxes : function(component, event, helper) {
        var slctCheck = event.getSource().get("v.value");
        var getCheckAllId = component.find("dependent");
        
        if (slctCheck == true) {
            for (var i = 0; i < getCheckAllId.length; i++) {
                component.find("dependent")[i].set("v.value", true);             
            }
        } else {
            for (var i = 0; i < getCheckAllId.length; i++) {
                component.find("dependent")[i].set("v.value", false);
            }
        }
    }
    
    
})