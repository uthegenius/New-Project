/************************
Author:         Azfer Pervaiz
Created Date:   18/July/2018 
Purpose:        Asset Trg Handler.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
18/July/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************
07/August/2018        Abid Raza              Cancelled Assets tasks should also be changed to Cancelled Status. 
***********************************************************************************/

public without sharing class AssetTrgHandler {
    
    public void OnBeforeInsert(List<Asset> newObjects, Map<Id, Asset> newMap){
		List<Asset> ListToPopulateName = new List<Asset>(); 
		List<Id> ListProductId = new List<Id>(); 
        set<Id> ContactIds = new Set<Id>();
        List<Asset> ListToPopulateAccount = new List<Asset>();
		
		for( Asset AssetObj : newObjects )
		{
            if(AssetObj.Product2Id==null && AssetObj.Asset_Name__c!=null )
            {
             	AssetObj.Name =  AssetObj.Asset_Name__c;  
            }
            else if(AssetObj.Product2Id!=null && AssetObj.Asset_Name__c==null )
            {
            	AssetObj.Name =  AssetObj.Product2Id;   
            }  
			if( AssetObj.Product2Id != null ){
				ListToPopulateName.add( AssetObj );
				ListProductId.add( AssetObj.Product2Id );
			}
            
            if(AssetObj.ContactId != null && AssetObj.AccountId == null)
            {
                ListToPopulateAccount.add(AssetObj);
                ContactIds.add(AssetObj.ContactId);
            }
		}

		if( ListToPopulateName.size() > 0 ){
			PopulateProductName( ListToPopulateName, ListProductId );
		}
        
        if( ListToPopulateAccount.size() > 0 ){
			PopulateAccountId( ListToPopulateAccount, ContactIds );
		}
	}

	//public void OnAfterInsert(List<Asset> newObjects, Map<Id, Asset> newMap){}

    public void onBeforeUpdate(List<Asset> oldObjects, List<Asset> newObjects, Map<Id, Asset> oldMap, Map<Id, Asset> newMap){
		List<Asset> ListToPopulateName = new List<Asset>(); 
		List<Id> ListProductId = new List<Id>(); 
        Set<Id> CancelledAssetIds = new Set<Id>();
		
		Asset OldAssetObj;
		for( Asset AssetObj : newObjects )
		{
			OldAssetObj = oldMap.get( AssetObj.Id );
			if( AssetObj.Product2Id != null && AssetObj.Product2Id != OldAssetObj.Product2Id ){
				ListToPopulateName.add( AssetObj );
				ListProductId.add( AssetObj.Product2Id );
			}
            
            if(AssetObj.Asset_Status__c == 'Cancelled' && AssetObj.Asset_Status__c != OldAssetObj.Asset_Status__c)
                CancelledAssetIds.add(AssetObj.Id);
            system.Debug('CancelledAssetIds::'+CancelledAssetIds);
		}

		if( ListToPopulateName.size() > 0 ){
			PopulateProductName( ListToPopulateName, ListProductId );
		}
        
        if(CancelledAssetIds.size() > 0 ){
			GetTasks(CancelledAssetIds);
		}
	}
    
    public void OnAfterInsert(List<Asset> newObjects, Map<Id, Asset> newMap)
    {
        List<Id> ListProductIds = new List<Id>(); 
        //set<Id> ListAccountIds = new set<Id>();
        List<Asset> ListProductAssets = new List<Asset>();
        
		for(Asset AssetObj : newObjects)
		{
            //BoxConnectUtil.createFolderinBox(AssetObj.id);
			if(AssetObj.Product2Id != null )
            {
				ListProductIds.add(AssetObj.Product2Id);
                //ListAccountIds.add(AssetObj.AccountId);
                ListProductAssets.add(AssetObj);
			}
		}
        
        if(ListProductIds.size() > 0)
        {
            CreateEntitlements(ListProductAssets,ListProductIds);
        }
        
	}
    
    public void onAfterUpdate(List<Asset> oldObjects, List<Asset> newObjects, Map<Id, Asset> oldMap, Map<Id, Asset> newMap)
    {
        List<Id> ListProductIds = new List<Id>(); 
        List<Id> OldProductIds = new List<Id>(); 
        List<Id> AssetIds = new List<Id>(); 
        //set<Id> ListAccountIds = new set<Id>();
        List<Asset> ListProductAssets = new List<Asset>();
        
        Asset OldAssetObj;
		for(Asset AssetObj : newObjects)
		{
            OldAssetObj = oldMap.get( AssetObj.Id );
			if( AssetObj.Product2Id != null && AssetObj.Product2Id != OldAssetObj.Product2Id )
            {
				ListProductIds.add(AssetObj.Product2Id);
                OldProductIds.add(OldAssetObj.Product2Id);
                AssetIds.add(AssetObj.Id);
                //ListAccountIds.add(AssetObj.AccountId);
                ListProductAssets.add(AssetObj);
			}
		}
        
        //Delete Old Entitlements in case of Product change on Asset.
        List<Entitlement> ListOfOldEntitlements = new List<Entitlement>();
        ListOfOldEntitlements = [Select Id from Entitlement where Product__c in: OldProductIds and AssetId in: AssetIds];
        
        if(ListOfOldEntitlements.size() > 0)
            Delete ListOfOldEntitlements;
        
        if(ListProductIds.size() > 0)
        {
            CreateEntitlements(ListProductAssets,ListProductIds);
        }
	}

	//Method To Fetch Product name and update Asset Name
	private void PopulateProductName(List<Asset> paramListToPopulateName, List<Id> paramListProductId ){

		Map<Id,Product2> MapProduct = new Map<Id,Product2>([SELECT Id,Name FROM Product2 WHERE Id IN : paramListProductId ]);

		for( Asset AssetObj : paramListToPopulateName )
		{
			if( MapProduct.get( AssetObj.Product2Id ) != null ){
                
				AssetObj.Name = MapProduct.get( AssetObj.Product2Id ).Name;
			}
		}
	}
    
    //Method To Fetch Tasks against cancelled Assets and mark them cancelled too.
	private void GetTasks(Set<Id> AssetIds)
    {
        List<Task> LstOfTasks = [Select Id,Status from Task where WhatId in: AssetIds];
        
        if(LstOfTasks.size() > 0)
        {
            for(Task tsk: LstOfTasks)
                tsk.Status = 'Cancelled';
            
            Update LstOfTasks;
        }
	}
    
    //Method To Fetch Account against contact and update Asset Account Id.
	private void PopulateAccountId(List<Asset> ListToPopulateAccount, set<Id> ContactIds ){

		Map<Id,Contact> MapContact = new Map<Id,Contact>([SELECT Id,Name,AccountId FROM Contact WHERE Id IN : ContactIds ]);

		for( Asset AssetObj : ListToPopulateAccount )
		{
			if( MapContact.get( AssetObj.ContactId ) != null ){
				AssetObj.AccountId = MapContact.get( AssetObj.ContactId ).AccountId;
			}
		}
	}
    
    //Method To Create Entitlements for assets if product is attached to Asset with Warranty.
    private void CreateEntitlements(List<Asset> paramListofAssets, List<Id> paramListProductId )
    {
        Map<Id,Product2> MapProduct = new Map<Id,Product2>([SELECT Id,Name,ProductCode,Warranty_years__c,Warranty_years_description__c FROM Product2 WHERE Id IN : paramListProductId ]);
        List<Entitlement> ListToBeAddedEntitlements = new List<Entitlement>();
        Entitlement ent;
        
        for( Asset AssetObj : paramListofAssets )
        {
            if( MapProduct.get(AssetObj.Product2Id) != null && string.isNotBlank(AssetObj.AccountId))
            {
                if(MapProduct.get( AssetObj.Product2Id ).Warranty_years__c != null && !string.IsBlank(MapProduct.get( AssetObj.Product2Id ).Warranty_years_description__c ))
                {
                    ent = new Entitlement();
                    ent.AccountId = AssetObj.AccountId;
                    ent.AssetId = AssetObj.Id;
                    ent.Product__c = AssetObj.Product2Id;
                    ent.Name = MapProduct.get( AssetObj.Product2Id ).ProductCode + ' ' + MapProduct.get( AssetObj.Product2Id ).Warranty_years__c + ' Years Warranty';
                    ent.StartDate = Date.today();
                    ent.EndDate = Date.today().AddYears(Integer.valueOf(MapProduct.get( AssetObj.Product2Id ).Warranty_years__c));
                    ListToBeAddedEntitlements.add(ent);
                }
            }
        }
        if(ListToBeAddedEntitlements.size() > 0)
        {
            insert ListToBeAddedEntitlements;
        }
    }
}