trigger onIntegrationStagingSave on Integration_Staging__c (Before Insert,Before Update) {
    
    List<Integration_Staging__c> lstContactUs = new List<Integration_Staging__c>();
    List<Integration_Staging__c> lstWarrenty = new List<Integration_Staging__c>();
    for(Integration_Staging__c element:Trigger.New){
        if(element.Record_Type__c == 'Contact Us'){
            lstContactUs.add(element);
        }
        else if(element.Record_Type__c == 'Warranty Registration'){
            lstWarrenty.add(element);
        }
    }
    if(!lstContactUs.isEmpty()){
        IntegrationStaging_Handler.ContactUs(lstContactUs);
    }
    if(!lstWarrenty.isEmpty()){
        IntegrationStaging_Handler.Warranty(lstWarrenty);
    }
    
}