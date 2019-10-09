/*
* Created by: Tectonic (MB) on 5/28/18
* Description: (LSCIP-129) - System should be able to validate if wholesaler can be added to the project opportunity based on opportunity line items. 
*         (LSCIP-128) - System should be able to validate allowed product based on agency product attribute before allowing adding product in to the opportunity product/quotes.
* Change log: 
   Changed by: Tectonic (MB) on 6/12/18   - LSCIP-68 - QLI consolidation.
  Changed by: Tectonic (MB) on 6/21/18   - LSCIP-187- Update Quote Consolidation Logic
*/
public class QuoteLineItemTrgHandler 
{
    // create a map of OLI brand with product id as key
    Map<Id, String> mapQLIBrands = new Map<Id, String>();
    List<Id> OppLineItemIds = new List<Id>();
 
    
    public void consolidateQLI(List<Quote> finalQuotes){
        // method used for LSCIP-68 - QLI consolidation. Multi products to one line item with qty and price consolidated.
        Map<Id, QuoteLineItem> consolidatedQLIs = new Map<Id, QuoteLineItem>();
        List<QuoteLineItem> qliToDel = new List<QuotelineItem>();
        List<QuoteLineItem> alternateQli = new List<QuoteLineItem>();
        
        if (finalQuotes != null && finalQuotes.size() > 0)
        {
            for(QuoteLineItem qli: [SELECT Requested_Price__c, Quantity, Subtotal, Total__c, Unique_ID__c, Product2Id, AlternateProduct__c
                                    FROM QuoteLineItem 
                                    WHERE QuoteId IN: finalQuotes])
            {
                // consolidate if alternate product is not assigned
                if(String.isBlank(String.valueOf(qli.AlternateProduct__c)) )
                {
                    if(consolidatedQLIs.containsKey(qli.Product2Id))
                    {
                        QuoteLineItem existingQli = consolidatedQLIs.get(qli.Product2Id);
                        existingQli.Quantity += qli.Quantity;
                        existingQli.Is_Consolidated__c = true;
                        consolidatedQLIs.put(qli.Product2Id, existingQli);
                        qliToDel.add(qli);
                    }
                    else 
                    {
                        qli.Is_Consolidated__c = true;
                        consolidatedQLIs.put(qli.Product2Id, qli);                
                    }
                }
                // make a list of line items with alternate products
                else alternateQli.add(qli);
            }
        }

        if (consolidatedQLIs != null && consolidatedQLIs.size() > 0)        
        {
            // consolidate qlis by updating  
            update consolidatedQLIs.values();
        }
          
        if (qliToDel != null && qliToDel.size() > 0)
        {
            // delete qlis that have been consolidated
            delete qliToDel;
        }
        
        if (alternateQli != null && alternateQli.size() > 0)
        {
            // delete QLIs with alternate product
            delete alternateQli;
        }
    }
    
    // MB: 7/11/18 - OpplineItem Update
    /*
    public void updateOppLineItemNumberOnQuote(List<QuoteLineItem> lineItems)
    {
        if (OppLineItemIds != null && OppLineItemIds.size() > 0)
        {
            // get Opportunities
            System.debug('OppLineItemIds:: ' + OppLineItemIds);
            
            Map<Id, OpportunityLineItem> mapOpps = new Map<id, OpportunityLineItem>([SELECT id, Line_Number__c FROM OpportunityLineItem WHERE Id IN: OppLineItemIds]);
            if(mapOpps.size() > 0)
            {
                if (lineItems != null && lineItems.size() > 0)
                {
                    for(QuoteLineItem qli: lineItems)
                    {
                        System.debug('Map Opp Prod Id:' + mapOpps.get(qli.OppProdId__c).Line_Number__c);
                        if( String.isNotBlank(qli.OppProdId__c) ) qli.Line_Number__c = mapOpps.get(qli.OppProdId__c).Line_Number__c;
                    }
                }
            }
        }
    }
	*/
}