({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.isBoxFolderExits");
        console.info('KA:: '+component.get("v.recordId"));
        action.setParams({
            paramQuoteRecordId : component.get("v.recordId"),
        });
        
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: 'There is a problem with the integrity of the box folder. Therefore, the box folder or PDF would not be created.',
                    messageTemplate: 'There is a problem with the integrity of the box folder. Therefore, the box folder or PDF would not be created.\n--------------------\nSolution\n--------------------\nNote. Most of the time box folder create with some delay, Therefore please check the folder after some time.\n1. You would see Create Folder button in box section for such issue, Press create folder button.\n2. If folder is created successfully then you can create Quote PDF\n3. If folder is not created successfully then you would be prompted an error that a Folder with some name like " FIVE POINTS ELEMENTARY SCHOOL RENOVATION_1" already exits in box. Copy the folder name and go to the {1}. Search the folder name and delete it.\n4. Refresh quote in salesforce and perform step 1 and 2 again.',
                    messageTemplateData: ['Salesforce', {
                        url: 'https://account.box.com/login?redirect_url=%2F',
                        label: 'Box',
                    }],
                    duration:' 15000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action); 
        
        var action = component.get("c.checkQuote");
        console.info('KA:: '+component.get("v.recordId"));
        action.setParams({
            paramQuoteRecordId : component.get("v.recordId"),
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var Obj = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS" && Obj.Message!=''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message: Obj.Message,
                    messageTemplate: Obj.Message,
                    messageTemplateData: ['Salesforce', {
                        url: '/'+Obj.ActiveQuote.Id,
                        label: Obj.ActiveQuote.Version__c,
                    }],
                    duration:' 15000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action); 
        
        
    },
})