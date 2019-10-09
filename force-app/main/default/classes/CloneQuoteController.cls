/*
* Created by: Tectonic (MB) on 6/5/18
* Description: (LSCIP-65)(PQ-12) - As an approver, I should be able to identify what was approved earlier and what is change in new version of the quote.
* Updated by: Tectonic (AR) on 6/28/18    Reason: Error Handling
*/
public with sharing class CloneQuoteController 
{
    @AuraEnabled
    public static String cloneQuote(String quoteId, String recTypeDevName)
    {
        try
        {
            List<QuoteLineItem> lstQLI = [select Id, Product2.isActive, Product2.Name, Line_Number__c, Product2.SAP_Product_Code__c
                                          from QuoteLineItem 
                                          where QuoteId = :quoteId and product2.isActive = false];
            
            if (lstQLI != null && lstQLI.size() > 0)
            {
                String errorMessage = 'This quote contains inactive products. ' +
                    				  'If you want to proceed to clone the quote, then the system will remove the inactive product from the new cloned quote.';
                /*
                errorMessage += errorMessage + '<br><br> <table><thead><tr><td>Line Number</td><td>SAP Product Code</td></tr></thead><tbody>'; 
                    
                for (QuoteLineItem li : lstQLI)
                {
                    errorMessage += '<tr><td>' + li.Line_Number__c + '</td><td>' + li.Product2.SAP_Product_Code__c + '</td></tr>';
                }
                
                errorMessage += '</tbody></table>';
                  */ 
                
                //throw new AuraHandledException('Error: '+ 'errorMessage');
                /*
                AuraHandledException e = new AuraHandledException('Warning: ');
                e.setMessage(errorMessage);
                system.debug('ah::e ' + e);
                throw e;    
				*/
                
                throw new CloneQuoteControllerException(errorMessage);
            }
            else
            {
                system.debug('Quote Id:' + quoteId);
                List<QuoteLineItem> clonedQlis = new List<QuoteLineItem>();
                Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: recTypeDevName AND SObjectType = 'Quote' LIMIT 1].Id;
                Quote q = [SELECT AccountId, First_Level_Approver__c , First_Level_Backup_Approver__c,Second_Level_Approver__c,Second_Level_Backup_Approver__c,
                                  AdditionalAddress, AdditionalName, Approval_Notes__c, Approver_Notes__c, BillingAddress, BillingName, Budget__c, 
                                  Budget_Price_Total__c, ContactId, ContractId, Description, Discount, Email, ExpirationDate, Fax, Final_Quote__c, 
                                  GrandTotal, IsCloned__c, LineItemCount, Master_Quote__c, OpportunityId, Phone, Pricebook2Id, Quote_Create_Date__c, 
                                  Quote_Id__c, Name, QuoteNumber, RecordTypeId, QuoteToAddress, QuoteToName, Quote_Total__c, Remaining_Quantity__c, 
                                  ShippingAddress, ShippingName, Shipped_Quanity__c, ShippingHandling, Status, Subtotal, IsSyncing, Tax, TotalPrice, 
                                  Unique_ID__c, Version__c, Discount__c 
                           FROM Quote 
                           WHERE Id =: quoteId];
                
                Quote clonedQuote = q.clone(false, true, false, false);
                clonedQuote.IsCloned__c = true;
                clonedQuote.RecordTypeId = recordTypeId;
                clonedQuote.Status = 'Draft';
                clonedQuote.Num_Approvals__c = null;
                clonedQuote.Active_Quote__c = true;
                //   ClonedQuote.First_Level_Approver__c = 
                System.debug('cloned quote:' + clonedQuote );
                insert clonedQuote;
                // insert Quote Line Items
                List<QuoteLineItem> qlis = [SELECT Approved_Price__c, Color__c, IsPriceReviewed__c ,Budget_Percent__c, Budget_Price__c, ServiceDate, Discount, 
                                                    Extended_Rewards__c, isCloned__c, ListPrice, Flag__c, Floor_Price__c, GM__c, GM_Percentage__c, Description, 
                                                    LineNumber, Line_Number__c,Location__c, No_Changes__c, Num_Approvals__c, Open_Quantity__c, 
                                                    Original_Unit_Price__c, Plumber_Reward_Value__c, Product2Id, PricebookEntryId, Quantity, QuoteId, 
                                                    Remaining_Quantity__c, Requested_Price__c, UnitPrice, Shipped_Quantity__c, Streatch_Price__c, Subtotal, 
                                                    Total__c, TotalPrice, Unique_ID__c, Wholesaler_Price__c,AlternateProduct__c,Everyday_Price__c
                                            FROM QuoteLineItem 
                                            WHERE QuoteId =: q.Id];
                for(QuoteLineItem qli: qlis)
                {
                    QuoteLineItem qliCopy = qli.clone(false, true);
                    qliCopy.QuoteId = clonedQuote.Id;
                    qliCopy.Original_Unit_Price__c = qli.UnitPrice;
                    qliCopy.Num_Approvals__c = null;
                    qliCopy.isCloned__c = true;
                    clonedQlis.add(qliCopy);
                }
                system.Debug('Cloned QLIs::'+clonedQlis);
                insert clonedQlis;
                quoteId = clonedQuote.Id;
                
                List<Quote> listQuotes = [select Id, Active_Quote__c from Quote where Id != :clonedQuote.Id and OpportunityId = :clonedQuote.OpportunityId];
                system.debug('ah:: list of quotes to be set as inactive ' + listQuotes);
                
                if (listQuotes != null && listQuotes.size() > 0)
                {
                    for (Quote qot : listQuotes)
                    {
                        qot.Active_Quote__c = false;
                    }
                    
                    update listQuotes;
                }
                
            }
        }
        catch(Exception ex) 
        { 
            system.debug('Error: '+ ex.getMessage()+' '+ex.getLineNumber());
            throw new AuraHandledException('Error: '+ ex.getMessage()+' '+ex.getLineNumber());   
        }
        
        return quoteId;
    }
    
    public class CloneQuoteControllerException extends Exception {}
}