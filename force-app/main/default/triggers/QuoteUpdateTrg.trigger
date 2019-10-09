trigger QuoteUpdateTrg on Quote_Account_Update__c (after insert) {
    
    
   if(Trigger.isAfter && Trigger.isInsert)
   {
       Set<id> quoteId = new Set<id>();
       List<Quote> updatedQuote = new List<Quote>();
       Map<string,Quote_Account_Update__c> idtoQuote= new Map<string,Quote_Account_Update__c>();
       List<Quote_Account_Update__c> QuoteAccupdate = new List<Quote_Account_Update__c>();
       Map<string,string> QuoteIDToAccountId = new Map<string,string>();

       
       for(Quote_Account_Update__c quoteupdate:Trigger.new)
       {
           quoteId.add(quoteupdate.Quote__c);
           QuoteAccupdate.add(quoteupdate);
           idtoQuote.put(quoteupdate.Quote__c,quoteupdate);
           QuoteIDToAccountId.put(quoteupdate.Quote__c,quoteupdate.Account__c);
           system.debug('Added in to the RecordList');
           
       }
       
       List<Quote> qu = new List<Quote>();
       if(quoteId!=null && quoteId.size()>0)
       {
           qu=[Select id,Account__c,ProjectId__c,Project__c From Quote where id IN :  quoteId ];
       }
       
       Map<id,Quote> quotetoAccountId = new Map<id,Quote>();    

       Map<id,Quote> quotetoProjectid = new Map<id,Quote>();    
       Map<string,string> paramMapQuoteIdProjectId = new Map<string,string>();
       Map<string,Quote> paramMapQuoteIdToQuote = new Map<string,Quote>();


       if(qu!=null && qu.size()>0)
       {
           system.debug(qu);
           for(Quote quo:qu)
           {
               system.debug('Quote Exists');
               quotetoAccountId.put(quo.id,quo);
               system.debug('quo.Project__c'+quo.Project__c);
               if(quo.ProjectId__c!=null &&quo.ProjectId__c!='' )
               {
                   system.debug('Contain project');
                   paramMapQuoteIdProjectId.put(quo.id,quo.ProjectId__c);
               
               }
               
               paramMapQuoteIdToQuote.put(quo.id,quo);
               
               
           }
       }
       
     
       
       Map<String,Set<String>> MapProjectToWholesaler = new Map<String,Set<String>>();
       for( Wholesalers__c WholesalersObj : [SELECT Id, Wholesaler__c, Project__c 
											FROM Wholesalers__c 
											WHERE Project__c IN : paramMapQuoteIdProjectId.values() ] )
    	{
    		if( MapProjectToWholesaler.get( WholesalersObj.Project__c ) != null ){
    			
    			Set<String> SetTemp = MapProjectToWholesaler.get( WholesalersObj.Project__c );
    			SetTemp.add( WholesalersObj.Wholesaler__c );

    		}else{
    			MapProjectToWholesaler.put( WholesalersObj.Project__c, new Set<String>{ WholesalersObj.Wholesaler__c } );
                system.debug('Project Exists');
    		} 
    	}
       
       
       
       
       if(QuoteAccupdate!=null && quotetoAccountId!=null && quotetoAccountId.size()>0 )
       {
        
           for(Quote_Account_Update__c qau:QuoteAccupdate)
           {
           
               if(quotetoAccountId.containskey(qau.Quote__c))
               {
                   System.debug('Quote Matches');
                   Quote q = quotetoAccountId.get(qau.Quote__c);
                   system.debug('Quote has been added to list');
                   system.debug('paramMapQuoteIdProjectId'+paramMapQuoteIdProjectId);
                   if(paramMapQuoteIdProjectId!=null && paramMapQuoteIdProjectId.size()>0 && paramMapQuoteIdProjectId.containskey(q.id))
                       {
                           system.debug('  Contain Project');
                           string projectId = paramMapQuoteIdProjectId.get(q.id);
                            Set<String> SetWholeSaler;
                            if( MapProjectToWholesaler.get( projectId ) != null )
            
                           {
                                SetWholeSaler = MapProjectToWholesaler.get( projectId );
                                
                                if( !SetWholeSaler.contains(qau.Account__c ) )
                                {
                                    qau.addError('Please select appropriate wholesaler which is realted to quote\'s project');
                                }
                               
                               else if ( SetWholeSaler.contains(qau.Account__c ) )
                               {
                                    q.Account__c=qau.Account__c;
                                   updatedQuote.add(q);
                  
                               }
                            }
            
                           else if (!String.isBlank(qau.Account__c ))
            
                           {
                
                               qau.addError('Please select appropriate wholesaler which is related to quote\'s project');
            
                          
                           }
                           
                     }else if(paramMapQuoteIdProjectId.size()==0)
                     
                         {
                                                   
                             qau.addError('Please select appropriate wholesaler which is related to quote\'s project');
    
                         }
                       
               }
               
           }
           
       }
       
       
       if(updatedQuote!=null && updatedQuote.size()>0)
       {
           system.debug('Inserted into the List');
           try{
           
               update updatedQuote;    
           
           }catch(Exception e)
           {
       
               system.debug('Error');

               
             }
           
       }
       
       
       
       
       
   }

}