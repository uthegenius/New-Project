/************************
Author:         Azfer Pervaiz
Created Date:   27/June/2018 
Purpose:        RequestStatus Request Status Class for lighting component Request.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
27/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class RequestStatus {		
	@AuraEnabled public Boolean IsSuccessfull  { Get;Set; }
	@AuraEnabled public String ErrorMessage  { Get;Set; }
	@AuraEnabled public String SuccessMessage  { Get;Set; }
	@AuraEnabled public List<AddProductQuoteCtrl.QuoteProductWrapper> ListQuoteProductWrapper { Get;Set; }
	@AuraEnabled public List<AddProductOpportunityCtrl.OpportunityProductWrapper> ListOpportunityProductWrapper { Get;Set; }
	@AuraEnabled public List<AddProductCampaignCtrl.CampaignProductWrapper> ListCampaignProductWrapper { Get;Set; }
	@AuraEnabled public List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper { Get;Set; }
	

	public RequestStatus(){
		IsSuccessfull = false;
		ErrorMessage = SuccessMessage = '';
		ListQuoteProductWrapper = new List<AddProductQuoteCtrl.QuoteProductWrapper>();
		ListOpportunityProductWrapper = new List<AddProductOpportunityCtrl.OpportunityProductWrapper>();
		ListCampaignProductWrapper = new List<AddProductCampaignCtrl.CampaignProductWrapper>();
		ListOrderItemWrapper = new List<AddProductOrderCtrl.OrderItemWrapper>();
	}
}