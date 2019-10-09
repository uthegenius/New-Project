({
    // following two methods are for the switching of tabs
    AddProductTab: function(component, event, helper) {
        var tab1 = component.find('AddProducId');
        var TabOnedata = component.find('AddProductTabDataId');
 
        var tab2 = component.find('CopyPasteId');
        var TabTwoData = component.find('CopyPasteTabDataId');
 
        //show and Active AddProduct tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');
        
    },
    CopyPasteTab: function(component, event, helper) {
 
        var tab1 = component.find('AddProducId');
        var TabOnedata = component.find('AddProductTabDataId');
 
        var tab2 = component.find('CopyPasteId');
        var TabTwoData = component.find('CopyPasteTabDataId');
 
        //show and Active CopyPastetables Tab
        $A.util.addClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-hide');
        $A.util.addClass(TabTwoData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');
  
    },
    // tabs swithcing method ends

    LoadJS : function(component, event, helper){
        var $ = jQuery.noConflict();
    },
    doInit : function(component, event, helper){

        component.set("v.isLoading", true);
        var action = component.get("c.InitCtrl");
        action.setParams({
            paramQuoteRecordId : component.get("v.recordId"),
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.QuoteProductlist", response.getReturnValue());
                 
            }
        });

        $A.enqueueAction(action); 
    },

    AddProduct : function(component, event, helper){
        component.set("v.isLoading", true);
        
        var varQuoteProductlist = component.get("v.QuoteProductlist");
        
        varQuoteProductlist = JSON.stringify(varQuoteProductlist);
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');

        var action = component.get("c.AddProductCtrl");
        action.setParams({
            paramListQuoteProductWrapper : varQuoteProductlist
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.QuoteProductlist", response.getReturnValue());
                 
            }
        });

        $A.enqueueAction(action); 
    },

    SaveProduct  : function(component, event, helper){
        component.set("v.isLoading", true);
        
        var varQuoteProductlist = component.get("v.QuoteProductlist");

        varQuoteProductlist = JSON.stringify(varQuoteProductlist);
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');
        
        var varPriceBook = component.get("v.PriceBookName");
        
        var action = component.get("c.SaveProductCtrl");
        action.setParams({
            paramQuoteRecordId : component.get("v.recordId"),
            paramPriceBookName : varPriceBook,
            paramListQuoteProductWrapper : varQuoteProductlist
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue().IsSuccessfull){
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            type: 'success',
                            message: 'Products are added. System is now fetching every day price.',
                            duration:' 3000'
                        });
                toastEvent.fire();
                var Action2 = component.get('c.UpdateEveryDayPrice');                
                Action2.setParams({
                    paramQuoteRecordId : component.get('v.recordId'),
                });
                Action2.setCallback(this, function(response) {
                    var state = response.getState();
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        component.set("v.isLoading", false);                                                
                        $A.get("e.force:closeQuickAction").fire();                          
                        $A.get('e.force:refreshView').fire();                        
                    }else{
                        component.set("v.isLoading", true); 
                    }
                });
 
                $A.enqueueAction(Action2);

            }else if ( !response.getReturnValue().IsSuccessfull && response.getReturnValue().ErrorMessage == 'Product Issue' ){
                component.set("v.isLoading", false);
                component.set("v.QuoteProductlist", response.getReturnValue().ListQuoteProductWrapper);
            }else if ( !response.getReturnValue().IsSuccessfull ){
                component.set("v.isLoading", false);
                component.set("v.errorMessage", response.getReturnValue().ErrorMessage);
            }
        });

        $A.enqueueAction(action); 
    },
    SaveProductPasted  : function(component, event, helper){
        component.set("v.isLoading", true);
        
        var varQuoteProductlist = component.get("v.QuoteProductCopyPastedlist");
        varQuoteProductlist = JSON.stringify(varQuoteProductlist);
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varQuoteProductlist = varQuoteProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');
        
        var varPriceBook = component.get("v.PriceBookName");
        
        var action = component.get("c.SaveProductCtrl");
        action.setParams({
            paramQuoteRecordId : component.get("v.recordId"),
            paramPriceBookName : varPriceBook,
            paramListQuoteProductWrapper : varQuoteProductlist
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue().IsSuccessfull){

                var Action2 = component.get('c.UpdateEveryDayPrice');
                
                Action2.setParams({
                    paramQuoteRecordId : component.get('v.recordId'),
                });
                Action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                       setTimeout(function(){
                            component.set("v.isLoading", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                type: 'success',
                                message: 'System is fetching "Everyday Price", please refresh the page in few seconds to see the updated "Everyday Price".'
                            });
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get('e.force:refreshView').fire(); 
                            toastEvent.fire();
                                
                        }, 30000);
                        
                    }
                });
 
                $A.enqueueAction(Action2);

            }else if ( !response.getReturnValue().IsSuccessfull && response.getReturnValue().ErrorMessage == 'Product Issue' ){
                component.set("v.isLoading", false);
                component.set("v.QuoteProductCopyPastedlist", response.getReturnValue().ListQuoteProductWrapper);
            }else if ( !response.getReturnValue().IsSuccessfull ){
                component.set("v.isLoading", false);
                component.set("v.errorMessagePastedSection", response.getReturnValue().ErrorMessage);
            }
        });

        $A.enqueueAction(action); 
    },


    CheckPastedDate : function(component, event, helper){
        var PastedData = component.find("TextAreaCopyPasteProduct").get("v.value");
        component.set("v.PastedData",PastedData);
        if( PastedData.length > 0 ){
            component.set("v.errorMessagePastedSection", '');
            var pasted = PastedData, rows = pasted.split("\n"), columns = [], fragment = document.createDocumentFragment();

            for(var item in rows){
                if( rows[item].length > 0 ){
                    var tr = jQuery("<tr/>");
                    columns = rows[item].split("\t");

                    for(var citems in columns)
                    {
                        if (columns[citems].length == 0) {
                            1 && tr.append(jQuery("<td/>").html(''));
                        } else {
                            columns[citems].length && tr.append(jQuery("<td/>").html(columns[citems]));
                        }
                    }
                    jQuery(fragment).append(tr);
                }
            }
            var div = document.createElement('div');
            div.appendChild( fragment.cloneNode(true) );
             

            var action = component.get("c.CheckPastedDateCtrl");
            action.setParams({
                paramQuoteRecordId : component.get("v.recordId"),
                paramStringObject : div.innerHTML,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.isLoading", false);
                if (component.isValid() && state === "SUCCESS"){
                    
                    component.set("v.ShowPasteSection", false );
                    component.set("v.ShowProcessedData",  true );
                    component.set("v.ShowProcessedDataBtn",  false );
                    
                    component.set("v.QuoteProductCopyPastedlist", response.getReturnValue());
                }
            });

            $A.enqueueAction(action); 
        }else{
            component.set("v.isLoading", false);
            component.set("v.errorMessagePastedSection", 'Unable to Process Data, Please Paste Data From Excel');
        }
    },
    ResetPasteSection : function(component, event, helper){
        component.set("v.ShowPasteSection", true );
        component.set("v.ShowProcessedData",  false );
        component.set("v.ShowProcessedDataBtn",  true );
    },
    
    closeComponent  : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
  
})