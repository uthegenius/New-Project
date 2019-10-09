({
    closeModel: function(component, event, helper) {
        component.destroy();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    RequestAuthorization: function(component, event, helper) {
        var ExpiryDate = $('#expirymonth').val()+$('#expiryyear').val();
        var MerchantCurrency = component.get("v.Currency"); //alert(MerchantCurrency);
        var CardNumber = component.get("v.OrderRecord.Card_Number__c"); //alert(CardNumber);
        var CardType = component.get("v.OrderRecord.Card_Type__c"); //alert(CardType);
        var CardAmount = component.get("v.OrderRecord.Order_Amount__c"); //alert(CardAmount);
        var CardHolder = component.get("v.OrderRecord.Card_Holder__c"); //alert(CardHolder);
        var CardCVV = component.get("v.OrderRecord.CVV__c"); //alert(component.get("v.counter"));
        var counter = component.get("v.counter");
        
        if((ExpiryDate != 0 && ExpiryDate != "undefined" && ExpiryDate != null && ExpiryDate.length==6) && (CardNumber != "undefined" && CardNumber != null && CardNumber != '') && (CardType != "undefined" && CardType != null && CardType != '') && 
           (CardAmount != 0) && (CardHolder != "undefined" && CardHolder != null && CardHolder != '') && (CardCVV != "undefined" && CardCVV != null && CardCVV != 0))
        { 
            var edate = new Date(ExpiryDate.substr(2,4),ExpiryDate.substr(0,2),0);
            var today= new Date();
            
            if(edate < today){
                $('#divAlertMessage').html('Card Expiry must be greater or equal to this month and year');
                $('#idAlertMessage').show();
                
                setTimeout(function(){
                    $('#idAlertMessage').hide();
                }, 3000);

            }
            else if (edate == 'Invalid Date'){
                $('#divAlertMessage').html('Invalid month and year define. Please enter month and year in correct formate i.e. MM & YYYY');
                $('#idAlertMessage').show();
                
                setTimeout(function(){
                    $('#idAlertMessage').hide();
                }, 3000);
            }
            else{
				console.log($('#expirymonth').val()+$('#expiryyear').val());
                var actionReq = component.get("c.RequestCardAuthorization");
                actionReq.setParams({
                    OrderRecord1 : component.get("v.OrderRecord"),
                    MerchantCurrency : component.get("v.Currency"),
                    ExpiryDate : $('#expirymonth').val()+$('#expiryyear').val(),                    
                });
                actionReq.setCallback(this, function(response) {
                    console.log('response ' + response);
                    var state = response.getState();
                    var MessageType ='success';
                    var Message='';
                    var result = response.getReturnValue();
                    if (state == 'SUCCESS') 
                    {   
                        if (result == 'A')
                        {
                            MessageType ='success';
                            Message = 'Card is Authorized successfully.';
                            $A.get("e.force:closeQuickAction").fire();         
                        }
                        else
                        {
                            MessageType ='error';
                            if(result == 'C')
                            {
                                Message = 'Card Connect has declined Authorization.';
                                $A.get("e.force:closeQuickAction").fire(); 
                            }
                            else
                            {
                                Message = 'Please retry, there was some problem.';
                                $('#divAlertMessage').html(Message);
                                $('#idAlertMessage').show();
                                counter = ++counter;
                                component.set("v.counter", counter);
                                setTimeout(function(){
                                    $('#idAlertMessage').hide();
                                }, 4000);
                            }
                        }
                        
                        if(counter == 0 ||  counter == 3)
                        {
                            setTimeout(function(){
                                if(counter == 3) 
                                $A.get("e.force:closeQuickAction").fire(); 
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    mode: 'pester',
                                    type: MessageType,
                                    key: 'info_alt',
                                    message: Message,
                                    duration: '4000'
                                });           
                                toastEvent.fire();
                                setTimeout(function(){
                                    $A.get('e.force:refreshView').fire(); 
                                }, 4000)
                            }, 1000); 
                        }
                    }
                    else if (state === "ERROR") 
                    {
                        var errors2 = response.getError();
                        counter = ++counter;
                        component.set("v.counter", counter);
                        if(counter == 3)
                        {
                            $A.get("e.force:closeQuickAction").fire(); 
                            helper.handleErrors(errors2);
                        }
                        else
                        {
                            $('#divAlertMessage').html(errors2[0].message);
                            $('#idAlertMessage').show();
                            
                            setTimeout(function(){
                                $('#idAlertMessage').hide();
                            }, 3000);
                        }
                    }
                });
                
                $A.enqueueAction(actionReq); 
            }
            
        }
        else
        {
            if(CardAmount == 0)
                $('#divAlertMessage').html('Order Amount cannot be 0.');
            else if (ExpiryDate.length!=6)
                $('#divAlertMessage').html('Please enter card exipry in correct format. i.e. mmyyyy');
            else
                $('#divAlertMessage').html('Please fill all the fields.');
            $('#idAlertMessage').show();
            
            setTimeout(function(){
                $('#idAlertMessage').hide();
            }, 3000);
        } 
    },
    
    doInit : function(component, event, helper)
    {        
        $ = jQuery.noConflict();        
        var action = component.get("c.InitCtrl");
        action.setParams({
            paramOrderRecordId : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.OrderRecord", response.getReturnValue());
                
                
                if(component.get("v.OrderRecord.BillingStreet") == null ||
                       component.get("v.OrderRecord.BillingState") == null ||
                       component.get("v.OrderRecord.BillingCity") == null ||
                       component.get("v.OrderRecord.BillingPostalCode") == null||
                       component.get("v.OrderRecord.BillingCountry") == null)
                {
                    
                    var error = 'Billing address is not defined. Please enter billing address then try again.';
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        type: 'error',
                        key: 'info_alt',
                        message: error,
                        duration: '4000'
                    });           
                    toastEvent.fire();
                }
                else if(component.get("v.OrderRecord.isOrder_Simulator__c") == false)
                {
                    
                    var error = 'First simulate the order then authorize the card.';
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        type: 'error',
                        key: 'info_alt',
                        message: error,
                        duration: '4000'
                    });           
                    toastEvent.fire();
                }
                else if(component.get("v.OrderRecord.Count_of_0_Price_Lines__c") > 0)
                {
                    
                    var error = 'There are few 0-price products. To set the price in SAP, please work with the pricing team and Simulate the order to continue.';
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        type: 'error',
                        key: 'info_alt',
                        message: error,
                        duration: '4000'
                    });           
                    toastEvent.fire();
                }
            }
            
            
            
            var action1 = component.get("c.GetMerchantCurrency");
            action1.setParams({
                MerchantId : component.get("v.OrderRecord.Merchant_ID__c"),
            });
            action1.setCallback(this, function(response) {
                var state = response.getState();
                
                if (component.isValid() && state === "SUCCESS"){
                    component.set("v.Currency", response.getReturnValue());
                }
            });
            $A.enqueueAction(action1);
        });
        
        $A.enqueueAction(action);
        
        var idleTime = 0;
        var idleInterval = null;
        var isButtonVisible = 0;
     
        
        $(document).ready(function () {
            
            //Increment the idle time counter every minute.
            idleInterval = setInterval(timerIncrement, 1000); // 1 minute
            //Zero the idle timer on mouse movement.
            if(component.isValid())
            {
                $(this).mousemove(function (e) {
                    idleTime = 0;
                });
                $(this).keypress(function (e) {
                    idleTime = 0;
                });
            }
                    
        });
        
        function timerIncrement() 
        {
            var ExpiryDate = $('#expirymonth').val()+$('#expiryyear').val();
            var CardNumber = component.get("v.OrderRecord.Card_Number__c");
            var CardType = component.get("v.OrderRecord.Card_Type__c");
            var CardAmount = component.get("v.OrderRecord.Order_Amount__c");
            var CardHolder = component.get("v.OrderRecord.Card_Holder__c");
            var CardCVV = component.get("v.OrderRecord.CVV__c");
            idleTime = idleTime + 1;
            if (idleTime > 30 && ((ExpiryDate != 0 && ExpiryDate != "undefined" && ExpiryDate != null) || (CardNumber != "undefined" && CardNumber != null && CardNumber != '') || (CardType != "undefined" && CardType != null && CardType != '') || 
                                  (CardAmount != 0) || (CardHolder != "undefined" && CardHolder != null && CardHolder != '') || (CardCVV != "undefined" && CardCVV != null && CardCVV != 0)))
            {
                clearInterval(idleInterval);
                if(component.isValid())
                {
                    helper.NoActivityError();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            if(!component.isValid())
            {
                clearInterval(idleInterval);
            }
        }
        
         
        var action1 = component.get("c.getPickListValuesIntoList");
        action1.setParams({
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS")
            {
                var list = response.getReturnValue();
                component.set("v.picklistValues", list);
            }
        });
        $A.enqueueAction(action1);
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
    },
})