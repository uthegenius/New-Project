public class IntegrationStaging_Handler {
    
    public static void ContactUs(List<Integration_Staging__c> Data){
        try{
            map<string,Contact> mapContact = new map<string,Contact>();
            map<string,Asset> mapAsset = new map<string,Asset>();
            map<string,case> mapCase = new map<string,Case>();
            for(Integration_Staging__c element:Data){
                try{
                    Contact aContact = new Contact();
                    Asset anAsset = new Asset();
                    Case aCase = new Case();
                    if(string.isNotBlank(element.Field_17__c)){
                        aContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
                        aContact.FirstName = element.Field_3__c;
                        aContact.LastName = element.Field_4__c;
                        aContact.OtherStreet = element.Field_9__c;
                        aContact.OtherStreet2__c = element.Field_31__c;
                        aContact.OtherCity = element.Field_6__c;
                        aContact.OtherState = element.Field_7__c;
                        aContact.OtherPostalCode = element.Field_8__c;
                        aContact.OtherCountry = element.Field_10__c;
                        aContact.MailingStreet2__c = element.Field_32__c;
                        aContact.MailingStreet = element.Field_14__c;
                        aContact.MailingCity = element.Field_11__c;
                        aContact.MailingState = element.Field_12__c;
                        aContact.MailingPostalCode = element.Field_13__c;
                        aContact.MailingCountry  = element.Field_15__c;
                        aContact.Phone = element.Field_16__c;
                        aContact.Email = element.Field_17__c;
                        aContact.ByPassVal__c = True;
                        //aContact.AccountId='0011k00000DZmVrAAL'; // For Sandbox
                        aContact.AccountId='0013l00002038ij';	   // For Production
                        aContact.BP_External_Id__c  = element.Field_17__c;
                        aContact.Company__c  = element.Field_30__c;
                        aContact.Newsletter_Signup__c = element.Field_40__c;
                        aContact.MarketingCloudContact__c = string.isBlank(element.Field_33__c)?False:Boolean.valueof(element.Field_33__c);
                        mapContact.put(element.Field_17__c,aContact);
                    }
                    
                    if(string.isNotBlank(element.Field_24__c)){
                        anAsset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Consumer_Asset').getRecordTypeId();
                        anAsset.Order_SAP_Line_ID__c = element.Field_24__c+'-'+element.Field_25__c;
                        anAsset.Name = 'Auto Fill by SF Workflow';
                        anAsset.Asset_Sub_Record_Type__c = element.Field_38__c;
                        anAsset.Contact= new contact (BP_External_Id__c = element.Field_17__c);
                        if(string.isNotBlank(element.Field_26__c)){
                            anAsset.PurchaseDate = Date.valueOf(element.Field_26__c);
                        }
                        
                        anAsset.Product2 = new Product2(SAP_Product_Code__c=element.Field_25__c);
                        mapAsset.put(element.Field_24__c+'-'+element.Field_25__c,anAsset);
                    }
                    
                    
                    if(string.isNotBlank(element.Field_2__c)&&string.isNotBlank(element.Field_17__c)){
                        aCase.Type=element.Field_1__c;
                        aCase.Case_Sub_Type__c=element.Field_5__c;
                        if(string.isNotBlank(element.Field_1__c)&&string.isNotBlank(element.Field_5__c)){
                            // If Type and SubType are both provided
                            if(element.Field_1__c == 'EDI'){
                                if(element.Field_5__c == 'Missing customer SKU' 
                                  || element.Field_5__c == 'Material xref not found'
                                  || element.Field_5__c == 'PO line item reference number missing' 
                                  || element.Field_5__c == 'Open-closed plants report'
                                  || element.Field_5__c == 'Open ship complete report'
                                  || element.Field_5__c == 'Duplicate found'
                                  || element.Field_5__c == 'Store/branch not found in the xref table'
                                  || element.Field_5__c == 'Store/branch not found'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Literature'){
                                if(element.Field_5__c == 'Price books' 
                                  || element.Field_5__c == 'Color chips'
                                  || element.Field_5__c == 'Catalogues'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Stock Inquiry'){
                                aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();         
                            }
                            else if(element.Field_1__c == 'WarrantyHelp'){
                                if(element.Field_5__c == 'Parts Request' 
                                  || element.Field_5__c == 'Product Troubleshooting'
                                  || element.Field_5__c == 'Installation'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Return'){
                                if(element.Field_5__c == 'Defective Return' 
                                   || element.Field_5__c == 'Customer Error' 
                                   || element.Field_5__c == 'Warehouse Error' 
                                   || element.Field_5__c == 'Factory Error' 
                                   || element.Field_5__c == 'Accommodation' 
                                   || element.Field_5__c == 'Freight Damage' 
                                   || element.Field_5__c == 'Warehouse Error'
                                   || element.Field_5__c == 'Buyer\'s Remorse'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Order'){
                                if(element.Field_5__c == 'Line cancellation' 
                                   || element.Field_5__c == 'Customer Error' 
                                   || element.Field_5__c == 'Order cancellation' 
                                   || element.Field_5__c == 'Order entry' 
                                   || element.Field_5__c == 'Order status' 
                                   || element.Field_5__c == 'Order modification'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Suggestions/General Inquiries'){
                                if(element.Field_5__c == 'Where to buy' 
                                   || element.Field_5__c == 'Product Recommendation' 
                                   || element.Field_5__c == 'Plumber Recommendation' 
                                   || element.Field_5__c == 'Questions' 
                                   || element.Field_5__c == 'New Inquiry' 
                                   || element.Field_5__c == 'How to view Shipping Status'
                                   || element.Field_5__c == 'How to process Return'
                                   || element.Field_5__c == 'How to process a Defective Return'
                                   || element.Field_5__c == 'How to Cancel an Item'
                                   || element.Field_5__c == 'How to Add a Quote'
                                   || element.Field_5__c == 'How to Print Invoices/Packing Slips'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Return'){
                                if(element.Field_5__c == 'Defective Return' 
                                   || element.Field_5__c == 'Customer Error' 
                                   || element.Field_5__c == 'Warehouse Error' 
                                   || element.Field_5__c == 'Factory Error' 
                                   || element.Field_5__c == 'Accommodation' 
                                   || element.Field_5__c == 'Freight Damage' 
                                   || element.Field_5__c == 'Warehouse Error'
                                   || element.Field_5__c == 'Buyer\'s Remorse'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Order'){
                                if(element.Field_5__c == 'Line cancellation' 
                                   || element.Field_5__c == 'Customer Error' 
                                   || element.Field_5__c == 'Order cancellation' 
                                   || element.Field_5__c == 'Order entry' 
                                   || element.Field_5__c == 'Order status' 
                                   || element.Field_5__c == 'Order modification'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                            else if(element.Field_1__c == 'Quality'){
                                if(element.Field_5__c == 'DXV AT100' 
                                   || element.Field_5__c == 'DXV AT200' 
                                   || element.Field_5__c == 'Fittings' 
                                   || element.Field_5__c == 'Fixtures' 
                                   || element.Field_5__c == 'Grohe' 
                                   || element.Field_5__c == 'Safety Tubs'
                                   || element.Field_5__c == 'Selectronic Product'
                                   || element.Field_5__c == 'Whirlpool'){
                                      aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();          
                                }
                            }
                        }
                        else {
                            aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId();  
                        }
                        aCase.Consumer_Request__c = True;
                        aCase.Description=element.Field_2__c;
                        aCase.Contact=new contact (BP_External_Id__c = element.Field_17__c);
                        if(string.isNotBlank(element.Field_24__c)){
                            aCase.Asset = new Asset(Order_SAP_Line_ID__c = element.Field_24__c+'-'+element.Field_25__c);
                        }
                        aCase.Origin='Web';
                        aCase.Contact_Us_Type__c=element.Field_18__c;
                        aCase.Profession__c=element.Field_19__c;
                        aCase.Contact_Us_Sub_Type__c=element.Field_23__c;
                        aCase.Web_to_Case_URL__c = element.Field_34__c;
                        aCase.Brand__c = element.Field_35__c;
                        acase.Language__c = element.Field_36__c;
                        aCase.Country__c = element.Field_37__c;
                        element.Field_27__c = string.isBlank(element.Field_27__c)?null:element.Field_27__c;
                        aCase.Register_Warranty_Online__c= string.isBlank(element.Field_27__c)?False:Boolean.valueof(element.Field_27__c);
                        aCase.Recommend_AS_Grohe__c = string.isBlank(element.Field_28__c)?null:Integer.valueof(element.Field_28__c);
                        element.Field_22__c = string.isBlank(element.Field_22__c)?null:element.Field_22__c;
                        aCase.Signup_AS_Grohe_News_letter__c=string.isBlank(element.Field_22__c)?False:Boolean.valueof(element.Field_22__c);
                        aCase.Queue_Name_WR__c=element.Field_29__c;
                        aCase.Register_Warranty_Online__c = string.isBlank(element.Field_39__c)?False:Boolean.valueof(element.Field_39__c);
                        mapCase.put(aContact.FirstName+' '+aContact.LastName,aCase);
                    }
                }
                catch(Exception e){
                    element.Status__c = e.getMessage()+' '+e.getLineNumber();
                }
            }
            
            List<Database.upsertResult> uCR = new List<Database.upsertResult>();
            List<Database.SaveResult> sr = new List<Database.SaveResult>();
            if(!mapContact.values().isEmpty()){
                uCR=Database.upsert(mapContact.values(),contact.BP_External_Id__c,false);
            }
            if(!mapAsset.values().isEmpty()){
                uCR.addall(Database.upsert(mapAsset.values(),Asset.Order_SAP_Line_ID__c,false));
            }
            
            if(!mapCase.values().isEmpty()){
                sr = Database.insert(mapCase.values(),false);
            }
            
            for(Database.UpsertResult result:uCR) {
                for(Integration_Staging__c element:Data){
                    if (!result.isSuccess()) 
                    {                                                
                        element.Status__c = element.Status__c+'/n'+result.getErrors()[0].getMessage();                    
                    }
                    
                }
            }
            
            for(Database.SaveResult result:sr) {
                for(Integration_Staging__c element:Data){
                    if (result.isSuccess()) 
                    {                        
                        element.Case__c =  result.id;
                        element.Status__c = 'Success';
                        AttachmentToBox.createPDFInBoxAndEmail(element.Id,element.case__c);                    
                    }
                    else{
                        
                        element.Status__c = element.Status__c+'/n'+result.getErrors()[0].getMessage();                    
                    }
                    
                }
            }
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLineNumber());
        }
    }
    
    public static void Warranty(List<Integration_Staging__c> Data){
        try{
            map<string,Contact> mapContact = new map<string,Contact>();
            map<string,Asset> mapAsset = new map<string,Asset>();
            map<string,case> mapCase = new map<string,Case>();
            
            System.debug('Input Data ==> ' + Data);
            
            String statusString = '';	// Status string to be sent back
            
            for(Integration_Staging__c element:Data){
                try{
                    Contact aContact = new Contact();
                    Asset anAsset = new Asset();
                    Case aCase = new Case();
                    if(string.isNotBlank(element.Field_17__c)){
                        aContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
                        aContact.FirstName = element.Field_3__c;
                        aContact.LastName = element.Field_4__c;
                        aContact.OtherStreet = element.Field_9__c;
                        aContact.OtherStreet2__c = element.Field_31__c;
                        aContact.OtherCity = element.Field_6__c;
                        aContact.OtherState = element.Field_7__c;
                        aContact.OtherPostalCode = element.Field_8__c;
                        aContact.OtherCountry = element.Field_10__c;
                        aContact.MailingStreet2__c = element.Field_32__c;
                        aContact.MailingStreet = element.Field_14__c;
                        aContact.MailingCity = element.Field_11__c;
                        aContact.MailingState = element.Field_12__c;
                        aContact.MailingPostalCode = element.Field_13__c;
                        aContact.MailingCountry  = element.Field_15__c;
                        //aContact.AccountId='0011k00000DZmVrAAL'; // For Sandbox
                        aContact.AccountId='0013l00002038ij';      // For Production
                        aContact.Phone = element.Field_16__c;
                        aContact.Email = element.Field_17__c;
                        aContact.ByPassVal__c = True;
                        aContact.BP_External_Id__c  = element.Field_17__c;
                        aContact.Company__c  = element.Field_30__c;
                        aContact.Newsletter_Signup__c = element.Field_40__c;
                        aContact.MarketingCloudContact__c = string.isBlank(element.Field_33__c)?False:Boolean.valueof(element.Field_33__c);
                        mapContact.put(element.Field_17__c,aContact);
                    }
                    
                    if(string.isNotBlank(element.Field_24__c)){
                        anAsset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Consumer_Asset').getRecordTypeId();
                        anAsset.Order_SAP_Line_ID__c = element.Field_24__c+'-'+element.Field_25__c;
                        anAsset.Name = 'Auto Fill by SF Workflow';
                       // anAsset.ProductDescription = element.Field_47__c;Language__c
                       	anAsset.Quantity = Decimal.valueOf(element.Field_47__c) ;
                        anAsset.Brand__c = element.Field_35__c;
                        anAsset.Language__c = element.Field_36__c;
                        anAsset.Country__c = element.Field_37__c;
                        anAsset.Place_of_Purchase__c = element.Field_48__c;
                        anAsset.Installed_By__c = element.Field_49__c;
                        anAsset.Installed_By_Other__c = element.Field_50__c;
                        anAsset.Asset_Sub_Record_Type__c = element.Field_38__c;
                        if(string.isNotBlank(element.Field_42__c)){
                            anAsset.InstallDate = Date.valueOf(element.Field_42__c);
                        }
                        anAsset.Contact= new contact (BP_External_Id__c = element.Field_17__c);
                        if(string.isNotBlank(element.Field_26__c)){
                            anAsset.PurchaseDate = Date.valueOf(element.Field_26__c);
                        }
                        
                        anAsset.Product2 = new Product2(SAP_Product_Code__c=element.Field_25__c);
                        mapAsset.put(element.Field_24__c+'-'+element.Field_25__c,anAsset);
                        // *** Debugging Code Start *** //
                        /*
                        system.debug('Asset ==> ' + anAsset.Name);
                        system.debug('Asset ==> ' + anAsset.PurchaseDate);
                        system.debug('Asset ==> ' + anAsset.InstallDate);
                        system.debug('Asset ==> ' + anAsset.Quantity);
                        */
                        // *** Debugging Code End *** //
                    }
                                       
                }
                catch(Exception e){
                    statusString = statusString + 'E: ' + e.getMessage() + '___';
                    element.Status__c = e.getMessage();
                    //System.debug('Error Message 1: ' + e.getMessage()+' '+e.getLineNumber());
                }
            }
            
            List<Database.upsertResult> uCR = new List<Database.upsertResult>();
            List<Database.SaveResult> sr = new List<Database.SaveResult>();
            if(!mapContact.values().isEmpty()){
                uCR=Database.upsert(mapContact.values(),contact.BP_External_Id__c,false);
            }
            if(!mapAsset.values().isEmpty()){
                uCR=Database.upsert(mapAsset.values(),Asset.Order_SAP_Line_ID__c,false);
            }
            /*if(!mapCase.values().isEmpty()){
                sr = Database.insert(mapCase.values(),false);
            }*/
            for(Database.UpsertResult result:uCR) {
                for(Integration_Staging__c element:Data){
                    if (result.isSuccess()) 
                    {                        
                        //element.Case__c =  result.id;
                        if(string.isNotBlank(result.id)){
                        	statusString = statusString + 'S: ' + '-' + result.id + '___';
                        	element.Status__c = statusString;
                            AttachmentToBox.createPDFInBoxAndEmail(element.Name,result.id);
                        }                        
                    }
                    else
                    {
                    	statusString = statusString + 'E: ' + result.getErrors()[0].getMessage() + '___';
                    	element.Status__c = result.getErrors()[0].getMessage();
                    	//System.debug('Error Message 2: ' + result.getErrors()[0].getMessage());                    
                    }
                }
            }
            
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLineNumber());
        }
    }
    
}