/************************
Author:         Azfer Pervaiz
Created Date:   18/July/2018 
Purpose:        Asset Trg Handler.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
18/July/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class ProductTrgHandler{
    
    public void OnBeforeInsert(List<Product2> newObjects, Map<Id, Product2> newMap){
        for( Product2 ProductObj : newObjects )
        {
            if( !ProductObj.IsActive ){
                ProductObj.IsActive = true;
            }
        }
    }
    
    public void OnAfterInsert(List<Product2> newObjects, Map<Id, Product2> newMap){
        List<PricebookEntry> ListPriceBookEntry = new List<PricebookEntry>(); 
        Id Pricebook2Id = ReturnPriceBookId();
        List<CurrencyType> lstCurrencies = [Select IsoCode FROM CurrencyType Where IsActive= true];
        if(!lstCurrencies.isEmpty()){
            for( Product2 ProductObj : newObjects )
            {
                for(CurrencyType CT:lstCurrencies){
                    ListPriceBookEntry.add( new PricebookEntry( Product2Id = ProductObj.Id, Pricebook2Id = Pricebook2Id, 
                                                           UnitPrice = 0, IsActive = true, UseStandardPrice = false,
                                                           CurrencyISOCode = ct.IsoCode) );
                }
            }
            
            if( ListPriceBookEntry.size() > 0 ){
                List<Database.SaveResult> saveResults = Database.insert(ListPriceBookEntry, false);
                
                for(Database.SaveResult saveResult : saveResults)
                {
                    if(saveResult.isSuccess())
                        continue;
                    for(Database.Error err : saveResult.getErrors())
                    {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        
    }
    
    private Id ReturnPriceBookId(){
        if(!Test.isRunningTest())   
        {
            return [SELECT Id FROM PriceBook2 WHERE IsStandard = true].Id;
        }
        else
        {
            return Test.getStandardPricebookId();
        }
    }
    
    /*       public void CreateEntitlements(List<Product2> WarrantyProductList)
{
set<Id> WarrantyProductIds = new Set<Id>();
for(Product2 prod: WarrantyProductList)
{
WarrantyProductIds.add(prod.Id);
}
List<Entitlement> ListOfExistingEntitlements = new List<Entitlement>();
Set<Id> SetEntitlementIds = new Set<Id>();
Entitlement ent;
List<Entitlement> ListToBeCreatedEntitlements = new List<Entitlement>();
ListOfExistingEntitlements = [Select Id,Name,Product__c from Entitlement where Product__c in: WarrantyProductIds];

if(ListOfExistingEntitlements.size() > 0)
{
for(Entitlement ent1: ListOfExistingEntitlements)
{
SetEntitlementIds.add(ent1.Product__c);
}
}

for(Product2 prod: WarrantyProductList)
{
if(!SetEntitlementIds.contains(prod.Id))
{
ent = new Entitlement();
ent.Product__c = prod.Id;
ent.StartDate = Date.today();
ent.EndDate = Date.today().AddYears(Integer.ValueOF(prod.Warranty_years__c));
ListToBeCreatedEntitlements.add(ent);
}
}

if(ListToBeCreatedEntitlements.size() > 0)
{
insert ListToBeCreatedEntitlements;
}
}
*/
    
    
    
    
    
    
    
    
}