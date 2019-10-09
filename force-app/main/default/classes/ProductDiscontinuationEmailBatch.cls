/************************
Author:         Abid Raza
Created Date:   21/June/2018 
Purpose:        Batch Class to send Email to Opportunity team and Project Team about Discontinued Products in Quote Line Items.
************************/

global with sharing class ProductDiscontinuationEmailBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global transient List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    set<Id> DiscontinuedProductIds = new set<Id>();
    set<String> emailAddressesList = new set<String>();
    String body = '';
    
    //Constructor initialization
    global ProductDiscontinuationEmailBatch(Set<Id> ProductIds) 
    {
        DiscontinuedProductIds = ProductIds;
        system.Debug('DiscontinuedProductIds::'+DiscontinuedProductIds);
    }
    
    global ProductDiscontinuationEmailBatch() 
    {
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'Select Id,LineNumber,Description,Product2.Discontinue_date__c,Product2Id,Product2.ProductCode,Product2.Name,QuoteId,Quote.QuoteNumber,Quote.OpportunityId,Quote.Opportunity.Name,Quote.Opportunity.Project__c,Quote.Opportunity.Project__r.Name,Quantity from QuoteLineItem where Quote.ExpirationDate >= today';
        system.Debug('query::'+query);
        system.Debug('DiscontinuedProductIds::'+DiscontinuedProductIds);
        if(DiscontinuedProductIds.size() > 0)
            query += ' and Product2Id in: DiscontinuedProductIds';
        else
            query += ' and Product2.Discontinue_date__c = today';
        system.Debug('query1::'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<QuoteLineItem> scope)
    {
        try
        {
            set<Id> OpportunityIds = new Set<Id>();
            set<Id> OppIdsOppTeam = new Set<Id>();
            set<Id> ProjIdsProjTeam = new Set<Id>();
            map<Id,List<OpportunityTeamMember>> mapOpportunityTeamMembers = new map<Id,List<OpportunityTeamMember>>();
        	map<Id,List<Project_Team__c>> mapProjectTeamMembers = new map<Id,List<Project_Team__c>>();
            
      		system.Debug('(List<QuoteLineItem>) scope::'+(List<QuoteLineItem>) scope);
            for(QuoteLineItem qli: (List<QuoteLineItem>) scope)
            {
                OpportunityIds.add(qli.Quote.OpportunityId);
            }
            system.Debug('SetOfOpportunityIds::'+OpportunityIds);
            
            // Get all the opportunities.
            List<Opportunity> opportunities = [Select Id,Name,StageName,RecordType.DeveloperName,CloseDate,Project__c from Opportunity where Id in:OpportunityIds and CloseDate >= today and (StageName != 'Completed' or StageName != 'lost' or StageName != 'invalid')];
            system.Debug('ListOfOpportunities::'+opportunities);
            
            if(opportunities.Size() > 0)
            {
                for(Opportunity opp: opportunities)
                {
                    if(opp.RecordType.DeveloperName == 'Display' || opp.RecordType.DeveloperName == 'Initiative')
                        OppIdsOppTeam.add(opp.Id);
                    else if(opp.RecordType.DeveloperName == 'Projects')
                        ProjIdsProjTeam.add(opp.Project__c);
                }
            }
            system.Debug('OppIdsOppTeam::'+OppIdsOppTeam);
            system.Debug('ProjIdsProjTeam::'+ProjIdsProjTeam);
            
            // Getting Opportunity Team Members
            if(OppIdsOppTeam.Size() > 0)
            {
                for(OpportunityTeamMember oppTeam : [SELECT id, UserId, User.Email,OpportunityId, TeamMemberRole FROM OpportunityTeamMember
                                                     WHERE OpportunityId in: OppIdsOppTeam])
                {
                    if(mapOpportunityTeamMembers.containsKey(oppTeam.OpportunityId))
                    {
                        mapOpportunityTeamMembers.get(oppTeam.OpportunityId).add(oppTeam);
                    }
                    else
                    { 
                        mapOpportunityTeamMembers.put(oppTeam.OpportunityId, new List<OpportunityTeamMember> { oppTeam });
                    }
                }
            }
            system.Debug('mapOpportunityTeamMembers::'+mapOpportunityTeamMembers);
            
            // Getting Project Team Members
            if(ProjIdsProjTeam.Size() > 0)
            {
                for(Project_Team__c projTeam : [SELECT id, User__c, User__r.Email,Project__c,Role__c FROM Project_Team__c
                                                WHERE Project__c in: ProjIdsProjTeam])
                {
                    if(mapProjectTeamMembers.containsKey(projTeam.Project__c))
                    {
                        mapProjectTeamMembers.get(projTeam.Project__c).add(projTeam);
                    }
                    else
                    { 
                        mapProjectTeamMembers.put(projTeam.Project__c, new List<Project_Team__c> { projTeam });
                    }
                }
            }
            system.Debug('mapProjectTeamMembers::'+mapProjectTeamMembers);
            
            set<Id> ProductIds = new set<Id>();
            body = '<html><body> Below Products need attention regarding discontinuation Date.<br>';
            for(QuoteLineItem qli: (List<QuoteLineItem>) scope)
            {
                if(!ProductIds.Contains(qli.Product2Id))
                {
                  ProductIds.add(qli.Product2Id);
                    body += '<br>Product Code: ' + +qli.Product2.ProductCode + '           Product Name: '+qli.Product2.Name +'             Product Discontinuation Date: ' +qli.Product2.Discontinue_date__c;
                }
                System.debug('EmailBody::'+body);
                
                if(qli.Quote.OpportunityId != null && qli.Quote.Opportunity.Project__c == null)
                {
                    // Email Addresses for Opportunity Team Members
                    if(mapOpportunityTeamMembers.Size() > 0)
                    {
                        for(Id oppId : mapOpportunityTeamMembers.keySet())
                        { 
                            if(oppId == qli.Quote.OpportunityId)
                            {
                                for(OpportunityTeamMember otm : mapOpportunityTeamMembers.get(oppId))
                                { 
                                    emailAddressesList.add(otm.User.Email);
                                }
                                System.debug('emailAddressesOTM::'+emailAddressesList);
                            }
                        }
                    }
                }
                else if(qli.Quote.OpportunityId != null && qli.Quote.Opportunity.Project__c != null)
                {
                    // Email Addresses for Project Team Members
                    if(mapProjectTeamMembers.Size() > 0)
                    {
                        for(Id projId : mapProjectTeamMembers.keySet())
                        { 
                            if(projId == qli.Quote.Opportunity.Project__c)
                            {   
                                for(Project_Team__c ptm : mapProjectTeamMembers.get(projId))
                                { 
                                    emailAddressesList.add(ptm.User__r.Email);
                                }
                                System.debug('emailAddressesPTM::'+emailAddressesList);
                            }
                        }
                    }
                }
            }
            body += '<br></body></html>';
        }
        catch(Exception e)
        {
            System.debug('Error:: '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        try
        {
            System.debug('emailAddressesList::'+emailAddressesList);
            List<string> ListEmailAddresses = new List<string>(emailAddressesList);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(ListEmailAddresses);
            mail.setSubject('Discontinued Product on Quote Line Item');
            mail.setHtmlBody(body);
            System.debug('Mail::'+mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        catch(Exception e)
        {
            System.debug('Error1:: '+e.getMessage());
        }
        
    }
    
}