/************************
Author:         Muhammad Kashif Ali
Created Date:   20/Nov/2018 
Purpose:        This Trigger will be used to copy brands of wholeselers from Account to Project Brand field.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
20/Nov/2018          Muhammad Kashif Ali          Initial Development 
***********************************************************************************/

trigger WholesalersTrg on Wholesalers__c (after insert, after delete, before insert, before update) {
    
    List<Wholesalers__c> WholesalersList = new List<Wholesalers__c>();
    set<String> brands = new set<String>();
    set<id> setProjectId = new set<id>();
    Project__c proj;
    List<Project__c> projectList = new List<Project__c>();
    Set<Id> setwholeSalerID = new Set<Id>();
    id projectID;
    String brandsList;
    
    Set<Id> setAccountId = new Set<Id>();
    if ((Trigger.isbefore) && ( Trigger.isInsert  ||Trigger.isUpdate ))
    {
        map<string,Wholesalers__c> mapWhole = new map<string,Wholesalers__c>();
        for (Wholesalers__c wholeSaler : Trigger.New)
        {
            if( string.isnotblank(wholeSaler.Wholesaler__c) &&
               (
                   Trigger.oldMap==null ||
                   wholeSaler.Wholesaler__c != Trigger.oldMap.get(wholeSaler.Id).Wholesaler__c
               )
              )
                setProjectId.add(wholeSaler.Project__c);
        }
        
        if(!setProjectId.isEmpty()){
            
            Wholesalers__c[] wlsList = [select id,Wholesaler__c,Project__c from Wholesalers__c where Project__c= :setProjectId ];
            
            for (Wholesalers__c wholeSaler : wlsList)
            {
                if(string.isnotBlank( wholeSaler.Wholesaler__c)){
                    mapWhole.put(string.valueof(wholeSaler.Project__c)+string.valueof(wholeSaler.Wholesaler__c), wholeSaler) ;
                }
            }
            
            for (Wholesalers__c wholeSaler : Trigger.New)
            {
                if(mapWhole.containsKey(string.valueof(wholeSaler.Project__c)+string.valueof(wholeSaler.Wholesaler__c)) ){
                    wholeSaler.addError('You can\'t enter wholesale duplicates.');
                }
            }
            
        }
    }
    
    
    if ((Trigger.isAfter) && ( Trigger.isInsert  ||Trigger.isDelete ))
    {
        /// after insertion of wholesaler
        if(Trigger.isInsert && Trigger.isAfter)
        {
            for (Wholesalers__c wholeSaler : Trigger.New)
            {
                setwholeSalerID.add(wholeSaler.id); 
                setProjectId.add(wholeSaler.project__c);
                System.debug('KA:: WLS ID: '+ wholeSaler.project__c);
            }  
        }
        /// after deletion of wholesaler
        if(Trigger.isDelete && Trigger.isAfter)
        {  
            for (Wholesalers__c wholeSaler : Trigger.Old)
            {   
                setwholeSalerID.add(wholeSaler.id); 
                setProjectId.add(wholeSaler.project__c);
                projectID = wholeSaler.project__c;
                System.debug('KA:: WLS ID: '+ wholeSaler.project__c);
                System.debug('KA:: WLS ID: '+ wholeSaler.Wholesaler__c);
            }  
        }
        
        set<id> setWholeSalersIds = new set<id>();
        String brandsListWholeSeler='';
        // retrieving list of wholeslalers that inserted
        List<Wholesalers__c> wlsSalersList=  [select Wholesaler__r.id,Project__r.id from Wholesalers__c where Project__r.id IN :setProjectId];
        // check if project have wholesalers 1 or more. 
        if(wlsSalersList.size() > 0)
        {
            for(Wholesalers__c wlss : wlsSalersList  )
            {
                brandsListWholeSeler= '';
                /// retrieving and creating brands of all wholesalers which associated to project -> brand is a multivalued picklist
                for(Account acct : [select brand__c from Account where id =:wlss.Wholesaler__r.id])
                {
                    brandsListWholeSeler += acct.brand__c+';';
                }
                System.debug('KA:: brandsListWholeSeler '+ brandsListWholeSeler);
                // spliting brands in a string type list and then adding in set to retain only unique brands name
                Set<String> splitedBrands = new Set<String>();
                List<String> eachBrand = brandsListWholeSeler.split(';');
                for(String s : eachBrand)
                {
                    splitedBrands.add(s); 
                    System.debug('KA:: Splited String'+s);
                }
                System.debug('KA:: Value in Splited Brand'+ splitedBrands);
                String finalBrandString='';
                for(String ss : splitedBrands)
                {
                    System.debug('KA:: Splited String'+ss);
                    finalBrandString += ss+';';   
                }
                //// uniqe brands string creation end ////
                System.debug('KA:: Final String' +finalBrandString); 
                
                /// retriving project/ brands to update brands field of project
                for(Project__C proj : [select brand__c from Project__c where id = : wlss.Project__r.id])
                {
                    //// assigning list of brands to project brands fiels
                    proj.brand__c = finalBrandString;
                    projectList.add(proj);  
                }	   
            }  
        }
        else
        {
            /// If wlsSalersList list size is zero it means we have no associated wholesaler with project.
            //so need to assign null string to project brand field because if we are deleting last associated wholesaler
            //its not assigning null to brand field
            for(Project__C proj : [select brand__c from Project__c where id in : setProjectId])
            {
                proj.brand__c = '';
                projectList.add(proj); 
            }
        }
        /// DML operation to update all projects that are updated.
        if (projectList.size() > 0){
            try{
                update projectList;
            }catch(Exception e){
                System.debug('Exception is : ' + e.getMessage());
            }
        }else{
            System.debug('projectList Size is Zero');
        }
    }
}