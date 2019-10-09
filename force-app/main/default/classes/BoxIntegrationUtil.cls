public class BoxIntegrationUtil 
{
    private ApexPages.StandardController controller;
    
    public String strLogoType {get; set;}
    
    public Quote objQuote;
    
    public BoxIntegrationUtil(ApexPages.StandardController stdController)
    {
      this.controller = stdController;
        this.objQuote = (Quote)stdController.getRecord();

        system.debug('ah::param inside BoxIntegrationUtil ' + ApexPages.currentPage().getParameters().get('id'));
    	system.debug('ah::param inside BoxIntegrationUtil 2 ' + ApexPages.currentPage().getParameters().get('brands'));
        
        system.debug('ah::objQuote Id ' + objQuote.Id);
        system.debug('ah::objQuote.RecordTypeId ' + objQuote.RecordTypeId);
        string strRecordType = Schema.SObjectType.Quote.getRecordTypeInfosById().get(objQuote.RecordTypeId).getName();
        system.debug('ah::BoxIntegrationUtil strRecordType ' + strRecordType);
        
        if (strRecordType.contains('Final') && objQuote.Final_Quote__c)
        {
            getFQLineItems();
            system.debug('ah::getFQLineItems');
        }
        else if(strRecordType.contains('Standard'))
        {
			getMQLineItems ();
            system.debug('ah::getMQLineItems');

        }
        else if(strRecordType.contains('Influencer'))
        {
            getIQLineItems();
            system.debug('ah::getIQLineItems');            
        }
        
    }
    

    
 
    public List<QuoteLineItem> listMQLI {get;set;}
    public List<QuoteLineItem> listFQLI {get;set;}
    public List<QuoteLineItem> listIQLI {get;set;}
    
    public List<String> listProductBrands {get;set;}
    
    public Double totalQuotedValue {     
        get {
              if (totalQuotedValue == null)
              {
                  totalQuotedValue = 0.0;
              }
              return totalQuotedValue;
         }
    set;}
    
    public Double totalMasterPumberRewards {     
        get {
              if (totalMasterPumberRewards == null)
              {
                  totalMasterPumberRewards = 0.0;
              }
              return totalMasterPumberRewards;
         }
    set;}    
    
    public Double totalMasterQuotedValue {     
        get {
              if (totalMasterQuotedValue == null)
              {
                  totalMasterQuotedValue = 0.0;
              }
              return totalMasterQuotedValue;
         }
    set;}   
    
    public Double totalPumberRewards {     
        get {
              if (totalPumberRewards == null)
              {
                  totalPumberRewards = 0.0;
              }
              return totalPumberRewards;
         }
    set;}     

    public void getMQLineItems ()
    {
        String strBrandsParam = ApexPages.currentPage().getParameters().get('brands');
        system.debug('ah::strBrandsParam........ ' + strBrandsParam);
        
        List<String> listBrandsfromParam ;
        List<QuoteLineItem>   listQLI;
        
        if (strBrandsParam != null)
        {
        	listBrandsfromParam  = strBrandsParam.split(';');
        
        
        List<String> listBrands;
        
        if (!String.isBlank(objQuote.Opportunity.Account.brand__c))
        {
          listBrands = objQuote.Opportunity.Account.brand__c.split(';');
        }

        //List<QuoteLineItem> listQLI; 
        //if (listBrands != null && listBrands.size() > 0)
        //{        
        //as per discussion with ZP on 14th June 2018 status meeting, approved price is quoted price
        listQLI = [select Quantity, UnitPrice, Approved_Price__c, Plumber_Reward_Value__c, Requested_Price__c, Quoted_Price__c, Line_Number__c,
                                            Extended_Rewards__c, Product2.Name, Product2.Description, Location__c, Product2.ProductCode, AlternateProduct__c, 
                                            Total__c, Product2.Brand__c, Product_Discontinue_Date__c, Product2.Replacement_Product__c, Budget_Total__c 
                                            from QuoteLineItem where QuoteId = :objQuote.Id and Product2.brand__c in :listBrandsfromParam and Quote.Final_quote__c = false
                                            order by Line_Number__c];
        //}
        }
        
        Set<String> setProductBrands = new Set<String>();
        
        if (listQLI != null && listQLI.size() > 0)
        {
            listMQLI = new List<QuoteLineItem>();
                
            for (QuoteLineItem qli : listQLI)
            {
                listMQLI.add(qli);
                
                //add product brand
                if (!String.isBlank(qli.Product2.Brand__c))
                {
                  setProductBrands.add(qli.Product2.Brand__c);    
                }
                
                
                if (qli.AlternateProduct__c == null)
                {
                    totalMasterQuotedValue += qli.Total__c == null ? 0: qli.Total__c;
                    // as per discussion with Badar, total plumber rewards should be sum of ext. rewards minus alternate ext rewards
                    //totalMasterPumberRewards += qli.Plumber_Reward_Value__c == null ? 0: qli.Plumber_Reward_Value__c;
                    totalMasterPumberRewards += qli.Extended_Rewards__c == null ? 0: qli.Extended_Rewards__c;                    
                }
            }
            system.debug('ah::listMQLI ' + listMQLI);
            system.debug('ah::setProductBrands ' + setProductBrands);
                
            if (setProductBrands != null && setProductBrands.size() == 1 && setProductBrands.contains('Grohe'))
            {
                strLogoType = 'GROHE';
                system.debug('ah::strLogoType 1 ' + strLogoType) ;
            }
            else /*if (setProductBrands != null && setProductBrands.size() > 0 && !setProductBrands.contains('Grohe'))*/
            {
                strLogoType = 'ALL';
                system.debug('ah::strLogoType 2 ' + strLogoType) ;
            }
            /*
            else
            {
                strLogoType = 'NONE';
                system.debug('ah::strLogoType 3 ' + strLogoType) ;            
            }
			*/
        }
    }    
    
    public void getFQLineItems ()
    {
        String strBrandsParam = ApexPages.currentPage().getParameters().get('brands');
        system.debug('ah::strBrandsParam ' + strBrandsParam);
        
        List<String> listBrandsfromParam;
        
        if (strBrandsParam != null)
        {
        	listBrandsfromParam = strBrandsParam.split(';');
        }
        
        /*
        List<String> listBrands;
        
        if (!String.isBlank(objQuote.Opportunity.Account.brand__c))
        {
          listBrands = objQuote.Opportunity.Account.brand__c.split(';');
        }
        */
        
        List<QuoteLineItem> listAR;
        
        if (listBrandsfromParam != null && listBrandsfromParam.size() > 0)
        {
            //as per discussion with ZP on 14th June 2018 status meeting, approved price is quoted price
            listAR = [select Quantity, Quoted_Price__c, Requested_Price__c, Total__c, Plumber_Reward_Value__c, AlternateProduct__c,
                                            Extended_Rewards__c, Product2.ProductCode, Product2.Description, Location__c, Line_Number__c, Product2.brand__c, 
                      Product_Discontinue_Date__c, Budget_Total__c, Product2.Replacement_Product__c, Quote.Account_Name__c
                                            from QuoteLineItem where QuoteId = :objQuote.Id and Product2.brand__c in :listBrandsfromParam  and Quote.Final_quote__c = true
                              order by Line_Number__c];
        }
        
        Set<String> setProductBrands = new Set<String>();
         
        if (listAR != null && listAR.size() > 0)
        {
            listFQLI = new List<QuoteLineItem>();    
            for (QuoteLineItem qli : listAR)
            {
                listFQLI.add(qli) ;
                //add product brand
                if (!String.isBlank(qli.Product2.Brand__c))
                {
                  setProductBrands.add(qli.Product2.Brand__c);    
                }
                
                if (qli.AlternateProduct__c == null)
                {                
                    totalQuotedValue += qli.Total__c == null ? 0: qli.Total__c;
                    totalPumberRewards += qli.Extended_Rewards__c == null ? 0: qli.Extended_Rewards__c;
                }
            }
        }
        
        listProductBrands = new List<String>();
        //listProductBrands.addAll(setProductBrands);
        
        system.debug('ah::listBrandsfromParam ' + listBrandsfromParam);
        system.debug('ah::setProductBrands ' + setProductBrands);
        
        listProductBrands = listBrandsfromParam;
       
        if (setProductBrands != null && setProductBrands.size() == 1 && setProductBrands.contains('Grohe'))
        {
            strLogoType = 'GROHE';
            system.debug('ah::strLogoType 1 ' + strLogoType) ;
        }
        else /*if (setProductBrands != null && setProductBrands.size() > 0 && !setProductBrands.contains('Grohe'))*/
        {
            strLogoType = 'ALL';
            system.debug('ah::strLogoType 2 ' + strLogoType) ;
        }
        /*
        else
        {
            strLogoType = 'NONE';
            system.debug('ah::strLogoType 3 ' + strLogoType) ;            
        }
		*/
    }
    
    //influencer quote
    public void getIQLineItems ()
    {
        List<QuoteLineItem> listAR = [select Quantity, Quoted_Price__c, Requested_Price__c, Total__c, Plumber_Reward_Value__c, AlternateProduct__c,
                  					  Extended_Rewards__c, Product2.ProductCode, Product2.Description, Location__c, Line_Number__c, Product2.brand__c, 
                                      Product_Discontinue_Date__c, Budget_Price__c, Quote.Budget__c, Product2.Replacement_Product__c, Budget_Total__c
                  from QuoteLineItem where QuoteId = :objQuote.Id
                  order by Line_Number__c];
		
        system.debug('ah::listAR ' + listAR);
        
 		Set<String> setProductBrands = new Set<String>();
        
        if (listAR != null && listAR.size() > 0)
        {
            listIQLI = new List<QuoteLineItem>();    
            for (QuoteLineItem qli : listAR)
            {
                listIQLI.add(qli) ;
                //add product brand
                if (!String.isBlank(qli.Product2.Brand__c))
                {
                  setProductBrands.add(qli.Product2.Brand__c);    
                }
                
                if (qli.AlternateProduct__c == null)
                {                
                    totalQuotedValue += qli.Budget_Total__c == null ? 0: qli.Budget_Total__c;
                    totalPumberRewards += qli.Extended_Rewards__c == null ? 0: qli.Extended_Rewards__c;
                }
            }
        }
        
       
      if (setProductBrands != null && setProductBrands.size() == 1 && setProductBrands.contains('Grohe'))
        {
            strLogoType = 'GROHE';
            system.debug('ah::strLogoType 1 ' + strLogoType) ;
        }
        else /*if (setProductBrands != null && setProductBrands.size() > 0 && !setProductBrands.contains('Grohe'))*/
        {
            strLogoType = 'ALL';
            system.debug('ah::strLogoType 2 ' + strLogoType) ;
        }
        /*
        else
        {
            strLogoType = 'NONE';
            system.debug('ah::strLogoType 3 ' + strLogoType) ;            
        }
		*/
    }    
    
    @future (callout=true)
    public static void createFolderinBox (Id qId){
        box.Toolkit boxToolkit = new box.Toolkit();        
        String strBoxFolderId = boxToolkit.createFolderForRecordId(qId, null, true);
        boxToolkit.commitChanges(); 
        system.debug('ah::create folder for quote ' + qId + ' ' + strBoxFolderId);   
        
        system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
        
        Quote qot = new Quote(Id=qId, Box_Folder_Id__c=strBoxFolderId);
        update qot;
    }
    
    @future (callout=true)
    public static void createFolderinBox (Set<Id> setId, String strObject)
    {
        if (setId != null && setId.size() > 0 && !String.isBlank(strObject))
        {
            box.Toolkit boxToolkit = new box.Toolkit();     
            
            List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c IN : setId  ];
            Map<String, String> mapFRUP = new Map<String, String>();
            
            if (listBoxFRUP != null && listBoxFRUP.size() > 0)
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
            }             
           
            List<Sobject> listObject = Database.query('SELECT Id, Box_Folder_Id__c FROM ' + strObject + ' Where Id in :setId');

            if (listObject != null && listObject.size() > 0)
            {                
                List<Sobject> updatedRecords = new List<Sobject>();
                
                for (Sobject obj : listObject)
                {
                    if (!mapFRUP.containsKey(obj.Id))
                    {
                        String strBoxFolderId = boxToolkit.createFolderForRecordId(obj.Id, null, true);
                        boxToolkit.commitChanges(); 
                        
                        obj.put('Box_Folder_Id__c', strBoxFolderId);
                        updatedRecords.add(obj);
                    }
                }

                if (updatedRecords != null && updatedRecords.size() > 0)
                {
                	update updatedRecords;
                }
            }
        }
    }      
}