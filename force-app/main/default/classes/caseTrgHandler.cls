/*-------------------------------------------------------------------------------------------------
Author:             Ibad Mohiuddin
Date:               30-July-2018
Version:            1.0
Description:        Case Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
30-July-2018            Ibad Mohiuddin           Initial Development
***********************************************************************************/
public class caseTrgHandler {
    
    
    public Case caseObject;
    private ApexPages.StandardController controller ;
    public static PageReference pgRef;
    public caseTrgHandler(ApexPages.StandardController stdController)
    {
        controller = stdController;
        this.caseObject = (Case)stdController.getRecord();
        pgRef = stdController.view();
    }
    
    public static void addcon(List<Case> caseListTrg)
    { 
        
        List<Case> caseList = new List<Case>();
        Set<string> contactIdList = new Set<string>();
        Set<string> sku = new Set<string>();
        List<Date> strdate = new List<Date>();
        List<Asset> assto = new List<Asset>();
        
        String RecordTypeIdWS=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId();
        for(Case cc:caseListTrg)
        {
            if(cc.RecordTypeId==RecordTypeIdWS)
            {
                caseList.add(cc);
                system.debug(cc.Contact__c);
                contactIdList.add(cc.ContactId);
                sku.add(cc.Model_SKU__c);
                strdate.add(cc.Product_Purchase_Date__c);
                
            }
        }    
        
        Map<string,string> assetcontactToSKU = new Map<string,string>();
        Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Consumer_Asset').getRecordTypeId();
        List<Asset> aasetList = new List<Asset>();
        aasetList=[Select Id,ProductCode,ContactId, SAP_Product_Code__c From Asset where ContactId In:contactIdList and SAP_Product_Code__c	 In:sku and PurchaseDate 	In : strdate ];
        
        if(aasetList.size()>0)
        {
            
            for(Asset ass:aasetList)
            {
                
                assetcontactToSKU.put(ass.ContactId,ass.SAP_Product_Code__c);
                
                
            }      
        }
        
        
        
        Map<string,string> CaseProduct = new Map<string,string>();
        Set<string> skuList =  new Set<string>();
        for(case caseObj:caseList)
        {
            CaseProduct.put(caseObj.id,caseObj.Model_SKU__c);
            skuList.add(caseObj.Model_SKU__c);
            
        }
        
        Map<string,string> caseidtoProduct = new Map<string,string>();
        List<Product2> caseProductList = new List<Product2>();
        caseProductList = [Select id,Name,ProductCode,SAP_Product_Code__c From Product2 WHERE SAP_Product_Code__c	 IN :skuList];
        for(case cc:caseList)
        {
            for(Product2 pr : caseProductList)
            {
                if(CaseProduct.get(cc.id)==pr.SAP_Product_Code__c)
                {
                    caseidtoProduct.put(cc.id,pr.id);
                }
            }
            
        }
        
        if(caseProductList.size()>0)
            
        {
            List<String> emailAddresses = new List<String>(); 
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
            Account__c ac = Account__c.getInstance();
            string accountName = ac.Name__c;
            system.debug(accountName);
            id accountid;
            List<Account> accountidList  = [Select Id from Account where Name=:accountName limit 1];
            system.debug(accountidList.size());
            if(accountidList.size()>0)
            {
                accountid=accountidList[0].id;
                system.debug(accountid);
            }
            
            Map<String,Case> emailtoCase = new Map<String,Case>();
            for (Case caseObj:CaseList)
            {
                
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedEmail!='')
                {
                    emailAddresses.add(caseObj.SuppliedEmail);
                    emailtoCase.put(caseObj.SuppliedEmail,caseObj);
                    system.debug('Email Address: '+caseObj.SuppliedEmail);
                }
                
            }
            
            //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
            List<Contact> listContacts = [Select Id,Email From Contact Where Email in:emailAddresses];
            for(Contact cc:listContacts)
            {
                system.debug(cc.email);
            }
            Set<String> takenEmails = new Set<String>();
            for (Contact c:listContacts)
            {
                takenEmails.add(c.Email);
            }
            System.debug(takenEmails.size());
            Map<String,Contact> emailToContactMap = new Map<String,Contact>();
            List<Case> casesToUpdate = new List<Case>();
            List<string> emailaddress = new List<string>();
            
            
            for (Case caseObj:CaseList) 
            {
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedName!=null &&
                    caseObj.SuppliedEmail!=null &&
                    caseObj.SuppliedName!='' &&
                    caseObj.SuppliedEmail!='' &&
                    !takenEmails.contains(caseObj.SuppliedEmail))
                {
                    //The case was created with a null contact
                    //Let's make a contact for it
                    System.debug('Case with Null Contact');
                    emailaddress.add(caseObj.SuppliedEmail);
                    String[] nameParts = caseObj.SuppliedName.split(' ',2);
                    System.debug(nameParts.size());
                    if (nameParts.size() == 2)
                    {
                        System.debug(recordTypeId);
                        Contact cont = new Contact(FirstName=nameParts[0],
                                                   LastName=nameParts[1],
                                                   Email=caseObj.SuppliedEmail,
                                                   AccountId=accountId,
                                                   RecordTypeId= recordTypeId,
                                                   Phone=caseObj.SuppliedPhone,
                                                   OtherCity=caseObj.City__c,
                                                   OtherState=caseObj.State__c,
                                                   OtherCountry=caseObj.Country__c,
                                                   OtherPostalCode=caseObj.Postal_Code__c,
                                                   OtherStreet=caseObj.Street_Address__c
                                                  );
                        System.debug('Contact Name:'+nameParts[0]+nameParts[1]);
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                    }
                    
                    else if (nameParts.size() == 1)
                    {
                        System.debug(recordTypeId);
                        
                        Contact cont = new Contact( LastName=nameParts[0],
                                                   Email=caseObj.SuppliedEmail,
                                                   AccountId=accountId,
                                                   RecordTypeId= recordTypeId,
                                                   Phone=caseObj.SuppliedPhone,
                                                   OtherCity=caseObj.City__c,
                                                   OtherState=caseObj.State__c,
                                                   OtherCountry=caseObj.Country__c,
                                                   OtherPostalCode=caseObj.Postal_Code__c,
                                                   OtherStreet=caseObj.Street_Address__c
                                                  );
                        
                        System.debug('Contact Last Name:'+nameParts[0]);
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                        
                    }
                    
                    
                    
                }
                else {
                    
                    for(string sr:assetcontactToSKU.keyset()){
                        if(sr==caseObj.ContactId&&assetcontactToSKU.get(sr)==caseObj.Model_SKU__c	)
                        {
                            caseObj.Contact_and_Asset_Exists__c=true;
                        }
                        
                    }
                    
                    if(assetcontactToSKU.isEmpty()){
                        system.debug('Asset doest not exist');
                        Asset asse = new Asset(Name=caseObj.Model_SKU__c,
                                               ContactId=caseObj.ContactId,
                                               RecordTypeId= assetrecordTypeId,
                                               Receipt_Number__c=caseObj.Receipt_Number__c,
                                               PurchaseDate=caseObj.Product_Purchase_Date__c,
                                               Purchased_Location__c=caseobj.AccountId,
                                               Product2Id=caseidtoProduct.get(caseObj.id),
                                               AccountId=accountid,
                                               Quantity= caseObj.Asset_Quantity__c
                                              );
                        assto.add(asse);
                        caseObj.Contact_and_Asset_Created__c=true;
                    }
                }
            }
            
            
            List<Contact> newContacts = emailToContactMap.values();
            List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
            
            if(newContacts.size()>0)
            {  
                //insert newContacts;
                Database.SaveResult[] sr;
                try{
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true; 
                    sr = Database.insert(newContacts, dml);
                }
                
                catch(exception e)
                {
                    system.debug('Exception '+e);
                }
                
                Integer sizeList = newContacts.size();
                List<Asset> assetList = new List<Asset>();
                for(Database.SaveResult srr :sr)
                {
                    if(srr.isSuccess()){
                        for(Contact ct:newContacts)
                        {
                            Case caseObj = emailtoCase.get(ct.email);
                            Asset asse = new Asset(Name=caseObj.Model_SKU__c,
                                                   ContactId=ct.Id,
                                                   RecordTypeId= assetrecordTypeId,
                                                   Receipt_Number__c=caseObj.Receipt_Number__c,
                                                   PurchaseDate=caseObj.Product_Purchase_Date__c,
                                                   Purchased_Location__c=caseobj.AccountId,
                                                   Product2Id=caseidtoProduct.get(caseObj.id),
                                                   AccountId=accountid,
                                                   Quantity= caseObj.Asset_Quantity__c
                                                  );
                            assto.add(asse);
                            caseObj.Contact_and_Asset_Created__c=true;            
                            
                        }
                        
                    }
                    
                }   
                
            } 
            
            for (Case caseObj:casesToUpdate) 
            {
                Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
                caseObj.ContactId = newContact.Id;
            }
            
            
        }
        else{
            
            for(case cs:caseListTrg)
            {
                cs.Product_does_not_exists__c=true;
            }
            
            
        }
        
        if(assto.size()>0)
        {
            try
            {
                insert assto;
            }
            catch(Exception e){
                
                system.debug('Exception'+e);
                
            }
        } 
    } 
    
    
    
    
    
    public static void createFolderinBox (List<case> caseTrgList)
    {
        Set<id> casesIdtoCreateFolder = new Set<id>();
        if (caseTrgList != null && caseTrgList.size() > 0)
        {
            Set<id> caseId = new Set<id>();
            
            for(Case cs:caseTrgList)
            {
                caseId.add(cs.id);
            }
            
            Map<string,string>mapFRUP = new Map<string,string>();
            
            List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c 
                                              from box__FRUP__c where box__Record_ID__c in :caseId];
            
            if (listBoxFRUP != null && listBoxFRUP.size() > 0)
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
            }  
            
            for(Case cs:caseTrgList)
            {
                if (!mapFRUP.containsKey(cs.Id))
                {
                    casesIdtoCreateFolder.add(cs.id);
                }
            }
        }
        
        if(casesIdtoCreateFolder.size()>0 && casesIdtoCreateFolder!=null && !Test.isRunningTest())
        {
            BoxConnectUtil.createFolderinBoxList(casesIdtoCreateFolder);
        }
        
        
    }
    
    
    public static void queueAssignement(List<Case> caseListTrg)
    {
        List<Case> caseList = new List<Case>();
        
        String RecordTypeIdTS=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();
        String RecordTypeIdCS=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();
        Map<string,Case> assetCaseMap = new Map<String,Case>();
        for(Case cc:caseListTrg)
        {
            if((cc.RecordTypeId==RecordTypeIdTS||cc.RecordTypeId==RecordTypeIdCS) && cc.Type=='Quality')
            {
                caseList.add(cc);
            }
        }
        
        
        
        if(caseList.size()>0){
            
            for (Case c : caseList)
            {
                if (c.AssetId  != null) {
                    assetCaseMap.put(c.AssetId,c);
                    system.debug('Asset Exists');
                    
                }
            }
            
            Map<string,String> AssetDivisionCode = new Map<String,String>();
            Map<string,String> DivisionCodeAsset = new Map<String,String>();
            
            List<Case> caseUpdateList = new List<Case>();
            
            if(!assetCaseMap.isEmpty()){
                for(Asset asse : [Select Id,Product2.Division_Code__c From Asset Where id IN :assetCaseMap.KeySet()])
                    
                {    
                    system.debug('Asset ID  '+asse.id+'with Divison Code '+asse.Product2.Division_Code__c);
                    
                    AssetDivisionCode.put(asse.id,asse.Product2.Division_Code__c);
                    DivisionCodeAsset.put(asse.Product2.Division_Code__c,asse.id);
                    
                }
                
            }
            if(!AssetDivisionCode.isEmpty()){
                List<Material_Number_Mapping__c> materialMappingList = [Select id,Queue_Category__c,Division__c FROM Material_Number_Mapping__c WHERE Division__c IN :DivisionCodeAsset.KeySet()];
                for(Case cs:caseList)
                {
                    
                    string divisionCode = AssetDivisionCode.get(cs.AssetId);
                    for (Material_Number_Mapping__c mmn : materialMappingList)
                    {
                        if(divisionCode==mmn.division__c)
                        {
                            cs.Queue_Category__c=mmn.Queue_Category__c;
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
}