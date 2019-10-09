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
			paramOpportunityRecordId : component.get("v.recordId"),
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.OpportunityProductlist", response.getReturnValue());
               	 
            }
        });

        $A.enqueueAction(action); 
    },

    AddProduct : function(component, event, helper){
    	component.set("v.isLoading", true);
        
        var varOpportunityProductlist = component.get("v.OpportunityProductlist");
        varOpportunityProductlist = JSON.stringify(varOpportunityProductlist);
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');
        
        var action = component.get("c.AddProductCtrl");
		action.setParams({
            paramListOpportunityProductWrapper : varOpportunityProductlist
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.OpportunityProductlist", response.getReturnValue());
               	 
            }
        });

        $A.enqueueAction(action); 
    },

	SaveProduct  : function(component, event, helper){
    	component.set("v.isLoading", true);
        
        var varOpportunityProductlist = component.get("v.OpportunityProductlist");
        varOpportunityProductlist = JSON.stringify(varOpportunityProductlist);
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');
        
        var varPriceBook = component.get("v.PriceBookName");
        
        var action = component.get("c.SaveProductCtrl");
		action.setParams({
			paramOpportunityRecordId : component.get("v.recordId"),
			paramPriceBookName : varPriceBook,
            paramListOpportunityProductWrapper : varOpportunityProductlist
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue().IsSuccessfull){
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();                    
            }else if ( !response.getReturnValue().IsSuccessfull && response.getReturnValue().ErrorMessage == 'Product Issue' ){
                component.set("v.OpportunityProductlist", response.getReturnValue().ListOpportunityProductWrapper);
            }else if ( !response.getReturnValue().IsSuccessfull ){
                component.set("v.errorMessage", response.getReturnValue().ErrorMessage);
            }
        });

        $A.enqueueAction(action); 
    },
    SaveProductPasted  : function(component, event, helper){
    	component.set("v.isLoading", true);
        
        var varOpportunityProductlist = component.get("v.OpportunityProductCopyPastedlist");
        varOpportunityProductlist = JSON.stringify(varOpportunityProductlist);
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductQuantity":""/g,'"ProductQuantity":0');
        varOpportunityProductlist = varOpportunityProductlist.replace(/"ProductAlterNumber":""/g,'"ProductAlterNumber":null');
        
        var varPriceBook = component.get("v.PriceBookName");
        
        var action = component.get("c.SaveProductCtrl");
		action.setParams({
			paramOpportunityRecordId : component.get("v.recordId"),
			paramPriceBookName : varPriceBook,
            paramListOpportunityProductWrapper : varOpportunityProductlist
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue().IsSuccessfull){
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();                    
            }else if ( !response.getReturnValue().IsSuccessfull && response.getReturnValue().ErrorMessage == 'Product Issue' ){
                component.set("v.OpportunityProductCopyPastedlist", response.getReturnValue().ListOpportunityProductWrapper);
            }else if ( !response.getReturnValue().IsSuccessfull ){
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
                paramOpportunityRecordId : component.get("v.recordId"),
    			paramStringObject : div.innerHTML,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.isLoading", false);
                if (component.isValid() && state === "SUCCESS"){
                	
                    component.set("v.ShowPasteSection", false );
                    component.set("v.ShowProcessedData",  true );
                    component.set("v.ShowProcessedDataBtn",  false );
                    
                    component.set("v.OpportunityProductCopyPastedlist", response.getReturnValue());
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