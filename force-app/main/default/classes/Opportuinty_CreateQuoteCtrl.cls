/************************
Author:         Azfer Pervaiz
Created Date:   25/July/2018 
Purpose:        Opportuinty_CreateQuoteCtrl is the controller class for the Opportuinty_CreateQuote lighting component.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
25/July/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public with sharing class Opportuinty_CreateQuoteCtrl{

    @AuraEnabled
    public static String CreateQuoteCtrl(String paramOpportunityId, String paramRecordTyeDevName){
        String StringToReturn = '';
        
        List<Quote> listFinalQuote = [select Id, Final_Quote__c from Quote where Final_Quote__c = true and OpportunityId = :paramOpportunityId];
        
        List<Quote> listMasterQuote = [select Id, Final_Quote__c from Quote where Final_Quote__c = false and OpportunityId = :paramOpportunityId];
        
        if (listFinalQuote != null && listFinalQuote.size() > 0)
        {
            throw new AuraHandledException('Error: You are not allowed to create quote where the opportunity already has Final Quote');   
        }
        else if (listMasterQuote != null && listMasterQuote.size() > 0)
        {
            throw new AuraHandledException('Error: You are not allowed to create quote where the opportunity already has Master Quote. Please clone a quote rather creating a new one.'); 
        }
            
        else
        {
            Id RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: paramRecordTyeDevName AND SObjectType = 'Quote' LIMIT 1].Id;
            String OppName = [SELECT Name FROM Opportunity WHERE Id =: paramOpportunityId ].Name;
            String MaxVersion = null;
            String MaxUnique = null;
    
            List<AggregateResult> aggResult = [SELECT MAX(VersionNumber__c) MaxVersion, MAX(Unique_ID__c) MaxUnique 
                                                FROM Quote 
                                                WHERE OpportunityId = :paramOpportunityId 
                                                GROUP BY OpportunityId];
    
            if (aggResult != null && aggResult.size() > 0){
                MaxVersion = String.valueOf( aggResult[0].get('MaxVersion') );
                MaxUnique = String.valueOf( aggResult[0].get('MaxUnique') );
            }
            Quote QuoteObj = new Quote();
            QuoteObj.Name = OppName;
            QuoteObj.OpportunityId = paramOpportunityId;
            QuoteObj.RecordTypeId = RecordTypeId; 
            QuoteObj.Num_Approvals__c = null;
            QuoteObj.Version__c = MaxVersion;
            QuoteObj.Unique_ID__c = MaxUnique;
            QuoteObj.Quote_Create_Date__c = Date.today();
            QuoteObj.ExpirationDate = Date.today().AddYears(1);
            QuoteObj.Active_Quote__c = true;
    
            try{
                insert QuoteObj;
                StringToReturn = QuoteObj.Id;
            } catch(Exception ex) {
                throw new AuraHandledException('Error: '+ ex.getMessage());   
            }
        }
        
        return StringToReturn;
    }   
}