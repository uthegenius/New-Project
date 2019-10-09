public with sharing class WarrantyRegistrationController 
{
    public case c {get;set;}
    public Attachment attachment1 
    {
        get {
            if (attachment1 == null)
                attachment1 = new Attachment();
            return attachment1;
        }
        set;
    }
    
    
    public Attachment attachment2 
    {
        get {
            if (attachment2 == null)
                attachment2 = new Attachment();
            return attachment2;
        }
        set;
    }
    public Attachment attachment3 
    {
        get {
            if (attachment3 == null)
                attachment3 = new Attachment();
            return attachment3;
        }
        set;
    }
    public Attachment attachment4 
    {
        get {
            if (attachment4 == null)
                attachment4 = new Attachment();
            return attachment4;
        }
        set;
    }
    public Attachment attachment5 
    {
        get {
            if (attachment5 == null)
                attachment5 = new Attachment();
            return attachment5;
        }
        set;
    }
  
    public WarrantyRegistrationController()
    {
      c = new Case();    
    }
    
    public PageReference upload() 
    {
        try 
        {
            if(c != null)
            {
              // look for an associated contact with the same email
                Contact[] cnt = [SELECT Id FROM Contact WHERE Email = :c.SuppliedEmail LIMIT 1];
                if(cnt.size() > 0) c.ContactId = cnt[0].Id;
                
                // Specify DML options to ensure the assignment rules are executed
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                c.setOptions(dmlOpts);
                // set case record type to technical suppport for all cases created from web-to-case 
                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId();
                // set case origin
                c.Origin = 'Web';
                // Insert the case
                insert c;
                 string con;
                 Case[] cnte = [SELECT Id,ContactId FROM Case WHERE id = :c.id LIMIT 1];
                 if(cnte.size() > 0)  con = cnte[0].ContactId;
                system.debug('Con'+con);


                
               List<Asset> assetList = new List<Asset>();
               List<Contact> ccList = new List<Contact>();
               string assetId;
               if(con!=null)
               {
                   system.debug('Con'+con);
                   system.debug('SAP Product Code'+c.Model_SKU__c);
                   system.debug('Purchase Date'+c.Product_Purchase_Date__c);
                   assetList=[Select id,ContactId from Asset where ContactId =:con AND  SAP_Product_Code__c	 =:c.Model_SKU__c and PurchaseDate=:c.Product_Purchase_Date__c];
                   
               }
                else{
                    system.debug('ContactId Nul');
                   system.debug('Contact Id'+c.ContactId);
                   system.debug('SAP Product Code'+c.Model_SKU__c);
                   system.debug('Purchase Date'+c.Product_Purchase_Date__c);
                    
                }
               system.debug('Asset List Size'+assetList.size());
               
               if(assetList!=null && assetList.size()>0)
               {
                   assetId=assetList[0].id;
                   BoxConnectUtil.createFolderinBox(assetId);
                   system.debug('Created the folder in BOX');
                   
               }
                
               
                
               // insert attachment and relate it to case
                if(attachment1.Name != '' && assetId!=null)
                {
                    attachment1.OwnerId = UserInfo.getUserId();
                    attachment1.ParentId = assetId; // the record the file is attached to
                    attachment1.IsPrivate = false;
                    
                    insert attachment1;                    
                }
                if(attachment2.Name != '' && assetId!=null)
                {
                    attachment2.OwnerId = UserInfo.getUserId();
                    attachment2.ParentId = assetId; // the record the file is attached to
                    attachment2.IsPrivate = false;
                    
                    insert attachment2;                    
                }
                if(attachment3.Name != '' && assetId!=null)
                {
                    attachment3.OwnerId = UserInfo.getUserId();
                    attachment3.ParentId = assetId; // the record the file is attached to
                    attachment3.IsPrivate = false;
                    
                    insert attachment3;                    
                }
                if(attachment4.Name != '' && assetId!=null)
                {
                    attachment4.OwnerId = UserInfo.getUserId();
                    attachment4.ParentId = assetId; // the record the file is attached to
                    attachment4.IsPrivate = false;
                    
                    insert attachment4;                    
                }
                if(attachment5.Name != '' && assetId!=null)
                {
                    attachment5.OwnerId = UserInfo.getUserId();
                    attachment5.ParentId = assetId; // the record the file is attached to
                    attachment5.IsPrivate = false;
                    
                    insert attachment5;                    
                }
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Thanks for contacting! We will get back to you as soon as possible.'));
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            attachment1 = new Attachment(); 
            attachment2 = new Attachment();
            attachment3 = new Attachment();
            attachment4 = new Attachment();
            attachment5 = new Attachment();
        }
        return null;
    }
    
}