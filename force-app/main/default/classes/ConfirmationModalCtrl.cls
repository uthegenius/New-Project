public class ConfirmationModalCtrl {
    @AuraEnabled 
    public static RequestStatus callAction(String ObjId, String callType){
        Informatica_Order_Callout.InformaticaResponse status = new Informatica_Order_Callout.InformaticaResponse();
        RequestStatus result = new RequestStatus();
        status.MESSAGE_TYPE = 'C';
        
        if(callType=='OSS'){ // OSS=Order Submit To SAP , Action button on Order 
            Order objOrder = [Select Order_SAP_ID__c,
                              isOrderAmountApproved__c,
                              RecordType.DeveloperName,
                              Authorization_Code__c,
                              isSent_To_Sap__c,
                              isOrder_Simulator__c,
                              Count_of_0_Price_Lines__c,
                              (select Category_1__c,
                               Category_2__c,
                               Category_3__c
                               from orderitems
                               Where (Category_1__c = null or
                                      Category_2__c = null or
                                      Category_3__c = null)
                              )
                              from order 
                              where id=:ObjId][0];
            system.debug(objOrder);
            try{
                if (objOrder.isSent_To_Sap__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This order has already been submitted to SAP and an order created.';
                }
                else if (!objOrder.isOrder_Simulator__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'Order simulation is required before sending order to SAP.';
                }
                else if (objOrder.orderitems!= null && objOrder.orderitems.size()>0 && objOrder.RecordType.DeveloperName!='Credit_Card_Sales'){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'Category 1, 2, 3 must be defined.';
                }                
                else if (!objOrder.isOrderAmountApproved__c && objOrder.RecordType.DeveloperName!='Credit_Card_Sales'){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This order has not been approved yet. Please submit this order for the approval process.';
                }                
                else if ( objOrder.Count_of_0_Price_Lines__c>0 && objOrder.RecordType.DeveloperName=='Credit_Card_Sales'){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'There are few 0-price products. To set the price in SAP, please work with the pricing team and Simulate the order to continue.';
                }
                else if (string.isBlank(objOrder.Authorization_Code__c) && objOrder.RecordType.DeveloperName=='Credit_Card_Sales'){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'Credit Card information should be authorized before submitting an order to SAP. Please perform credit card authorization first.';
                }
                else{
                    List<Informatica_Order_Callout.InformaticaResponse> tempStatus = Informatica_Order_Callout.callSubmitToSAP(objOrder.Id);
                    if(tempStatus.isEmpty()){
                        status.MESSAGE_TYPE = 'C';
                        status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                    }
                    else{
                        status = tempStatus[0]; 
                    }                        
                }                    
            }                            
            
            catch (CalloutException ce) {
                status.MESSAGE = ce.getMessage()+' '+ce.getLineNumber();                
            }
            catch (Exception e){
                status.MESSAGE = e.getMessage()+' '+e.getLineNumber();                
            }
        }
        else if(callType=='DSS') { // Defect return case submit to SAP
            Case objCase = [Select Order_SAP_ID__c,
                            isSent_To_Sap__c
                            from Case 
                            where id=:ObjId][0];
            try{
                if (objCase.isSent_To_Sap__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'The defect return has already been submitted to SAP.';
                }
                else{
                    List<Informatica_Order_Callout.InformaticaResponse> tempStatus = Informatica_Order_Callout.callSubmitToSAP(ObjId);                      
                    if(tempStatus.isEmpty()){
                        status.MESSAGE_TYPE = 'C';
                        status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                    }
                    else{
                        status = tempStatus[0]; 
                    }
                }
                
            }
            catch (CalloutException ce) {
                status.MESSAGE = ce.getMessage()+' '+ce.getLineNumber();                
            }
            catch (Exception e){
                status.MESSAGE = e.getMessage()+' '+e.getLineNumber();                
            }
        }
        else if(callType=='SSS') { // Order Simulator
            
            Order objOrder = [Select Order_SAP_ID__c,
                              isOrderAmountApproved__c,
                              RecordType.DeveloperName,
                              Credit_Card_Authorization__c,
                              Count_of_0_Price_Lines__c,
                              isSent_To_Sap__c,
                              isOrder_Simulator__c,
                              Order_Sub_Type__c,
                              Freight__c,
                              ShippingCity,
                              ShippingCountry,
                              ShippingState,
                              ShippingPostalCode,
                              ShippingStreet,
                              TotalAmount, 
                              (Select Id From orderitems Where UnitPrice>0)
                              from order
                              
                              where id=:ObjId][0];
            List<OrderItem> oli = [select id from orderitem where orderid = :ObjId];
            if (objOrder.isSent_To_Sap__c){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = 'Order simulator cannot be performed for Orders that are already submitted to SAP.';
            }
            else if(oli.isEmpty()){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = 'You have not yet entered the product of the order. To proceed further, please add the product.';
            }
            else if (objOrder.Order_Sub_Type__c =='DR' && ((objOrder.Freight__c<0 ||objOrder.Freight__c==null) || objOrder.OrderItems.isEmpty()))  {
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = 'Freight charges should be greater than or equal to 0 and unit price should be greater than 0 for DR orders.';
            }
            else if (objOrder.Order_Sub_Type__c =='ZCRS' && (objOrder.Freight__c<0 ||objOrder.Freight__c==null))  {
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = 'Freight charges should be greater than or equal to 0 for ZCRS orders.';
            }
            else if (string.isBlank(objOrder.ShippingCity)||
                     string.isBlank(objOrder.ShippingCountry)||
                     string.isBlank(objOrder.ShippingState)||
                     string.isBlank(objOrder.ShippingStreet)||
                     string.isBlank(objOrder.ShippingPostalCode)
                    ){
                        status.MESSAGE_TYPE = 'E';
                        status.MESSAGE = 'Shipping address must be defiend.';
                    }
            else{
                List<Informatica_Order_Callout.InformaticaResponse> tempStatus = Informatica_Order_Callout.callOrderSimulator(objOrder.Id);                      
                if(tempStatus.isEmpty()){
                    status.MESSAGE_TYPE = 'C';
                    status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                }
                else{
                    status = tempStatus[0]; 
                }
            }          
        }
        else if(callType=='GSD') { // Get shipping detaion
            
            Order objOrder = [Select Order_SAP_ID__c,
                              isOrderAmountApproved__c,
                              RecordType.DeveloperName,
                              Credit_Card_Authorization__c,
                              isSent_To_Sap__c,
                              isOrder_Simulator__c,
                              (select Category_1__c,
                               Category_2__c,
                               Category_3__c
                               from orderitems
                               Where (Category_1__c = null or
                                      Category_2__c = null or
                                      Category_3__c = null)
                              )
                              from order 
                              where id=:ObjId][0];
            if (string.isBlank(objOrder.Order_SAP_ID__c)){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = 'SAP Order Number should be defined before getting the shipping details.';
            }
            else{
                List<Informatica_Order_Callout.InformaticaResponse> tempStatus = Informatica_Order_Callout.callShippmentDetail(objOrder.Order_SAP_ID__c);                     
                if(tempStatus.isEmpty()){
                    status.MESSAGE_TYPE = 'C';
                    status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                }
                else{
                    status = tempStatus[0]; 
                }
            }
        }
        else if(callType=='RPR'){
            Quote aQuote = [select id,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Is_Active_Final_Quote__c from Quote where id = :ObjId limit 1];
            try{
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Name from Profile where Id=:profileId].Name;
                Id UserId = userinfo.getUserId();
                if(!aQuote.Is_Active_Final_Quote__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This operation can only performed on Active Quote.';   
                }
                else if(aQuote != null ||
                        aQuote.First_Level_Approver__c == UserId ||
                        aQuote.Second_Level_Approver__c == UserId ||
                        aQuote.Third_Level_Approver__c == UserId ||
                        profileName.contains('System Administrator')
                       ){
                           
                           List<Informatica_Quote_Callout.InformaticaResponse> qStatus = Informatica_Quote_Callout.call(ObjId,'PR');            
                           if(qStatus.isEmpty()){
                               status.MESSAGE_TYPE = 'C';
                               status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                           }
                           else{
                               status.MESSAGE_TYPE = 'S';
                               status.MESSAGE = qStatus[0].MESSAGE;
                           }
                       }
                else{
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'You are not allowed to perform this operation.';
                }
            }
            catch(Exception ex){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = ex.getMessage();
                if ( status.MESSAGE.contains('Connectivity to SAP') ||
                    status.MESSAGE.contains('Some thing went wrong')){
                        status.MESSAGE_TYPE = 'C';
                    }
            }
        }
        else if(callType=='FQ'){
            Quote aQuote = [select id,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Is_Active_Final_Quote__c from Quote where id = :ObjId limit 1];
            try{
                if(!aQuote.Is_Active_Final_Quote__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This operation can only performed on Active Quote.';   
                }
                else {
                    ApexPages.StandardController sc = new ApexPages.StandardController(aQuote);        
                    QuoteExt qe = new QuoteExt(sc);
                    qe.isLightning = True;
                    PageReference p = qe.markQuoteAsFinal();                
                    status.MESSAGE_TYPE = 'S';
                    status.MESSAGE = 'The quote has be marked final quote successfully.';    
                }
            }
            catch(Exception ex){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = ex.getMessage();
                if ( status.MESSAGE.contains('Connectivity to SAP') ){
                    status.MESSAGE_TYPE = 'C';
                }
            }
            
        }
        else if(callType=='PR'){
            Quote aQuote = [select id,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Is_Active_Final_Quote__c from Quote where id = :ObjId limit 1];
            try{
                if(!aQuote.Is_Active_Final_Quote__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This operation can only performed on Active Quote.';   
                }
                else {
                    ApexPages.StandardController sc = new ApexPages.StandardController(aQuote);        
                    QuoteExt qe = new QuoteExt(sc);
                    qe.isLightning = True;
                    PageReference p = qe.reviewPrice();                
                    status.MESSAGE_TYPE = 'S';
                    status.MESSAGE = 'The price review completed successfully.';  
                }
            }
            catch(Exception ex){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = ex.getMessage();
                if ( status.MESSAGE.contains('Connectivity to SAP') ||
                    status.MESSAGE.contains('Some thing went wrong')){
                        status.MESSAGE_TYPE = 'C';
                    }
            }
            
        }
        else if(callType=='SA'){
            Quote aQuote = [select id,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Is_Active_Final_Quote__c from Quote where id = :ObjId limit 1];
            try{
                if(!aQuote.Is_Active_Final_Quote__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This operation can only performed on Active Quote.';   
                }
                else {
                    ApexPages.StandardController sc = new ApexPages.StandardController(aQuote);        
                    QuoteExt qe = new QuoteExt(sc);
                    qe.isLightning = True;
                    PageReference p = qe.submitForApproval();                
                    status.MESSAGE_TYPE = 'S';
                    status.MESSAGE = 'Submit for approval completed.';   
                }
            }
            catch(Exception ex){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = ex.getMessage();
                if ( status.MESSAGE.contains('Connectivity to SAP') ||
                    status.MESSAGE.contains('Some thing went wrong')){
                        status.MESSAGE_TYPE = 'C';
                    }
            }
            
        }
        else if(callType=='STS'){
            Quote aQuote = [select id,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Is_Active_Final_Quote__c from Quote where id = :ObjId limit 1];
            try{
                if(!aQuote.Is_Active_Final_Quote__c){
                    status.MESSAGE_TYPE = 'E';
                    status.MESSAGE = 'This operation can only performed on Active Quote.';   
                }
                else {
                    ApexPages.StandardController sc = new ApexPages.StandardController(aQuote);        
                    QuoteExt qe = new QuoteExt(sc);
                    qe.isLightning = True;
                    PageReference p = qe.markQuoteAsFinal();                
                    status.MESSAGE_TYPE = 'S';
                    status.MESSAGE = 'Submit to SAP completed.';  
                }
            }
            catch(Exception ex){
                status.MESSAGE_TYPE = 'E';
                status.MESSAGE = ex.getMessage();
                if ( status.MESSAGE.contains('Connectivity to SAP') ||
                    status.MESSAGE.contains('Some thing went wrong')){
                        status.MESSAGE_TYPE = 'C';
                    }
            }
            
        }
        
        if ( status.MESSAGE.contains('Connectivity to SAP') ||
            status.MESSAGE.contains('went wrong')){
                status.MESSAGE_TYPE = 'C';
                status.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
            }
        
        if(status.MESSAGE_TYPE=='S'){
            result.IsSuccessfull = True;
            result.SuccessMessage = status.MESSAGE;
        }
        else{
            result.IsSuccessfull = FALSE;
            result.ErrorMessage = status.MESSAGE;
        }        
        system.debug(status);
        if(status.MESSAGE_TYPE == 'C'){
            try{
            List<Lixil_Configuration__mdt> LixilSetting = [Select Value__c
                                                           from Lixil_Configuration__mdt 
                                                           where DeveloperName = 'Integration_Failure_Email_Recipient'];
            if(!LixilSetting.isEmpty()){
                OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = 'sf_casemanagement@lixilamericas.com'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setBccSender(false); 
                List<String> emailRecipients  = new List<String>();
                if(callType=='OSS'){
                    emailRecipients = LixilSetting[0].Value__c.split(',');
                }
                else{
                    emailRecipients.add('hanif.babar@gettectonic.com');
                }
                
                message.toAddresses = emailRecipients;   
                message.setOrgWideEmailAddressId(owea.get(0).id);
                String body = 'Hi, <br/>There is something went wrong in Salesforce to SAP integration that requires immediate attention. Please share SAP Number against below SF Number and/or confirm the status of below communication in SAP.<br/><br/>';
                if(ObjId.startsWith('801')) {
                    Order a = [Select OrderNumber,PONumber From order where id = :ObjId];
                    body = body+'Order Number : '+ a.OrderNumber +' <br/>';
                    body = body+'PO Number : '+ a.PONumber +' <br/>';
                    
                }
                else if(ObjId.startsWith('500')) {
                    Case a = [Select CaseNumber From Case where id = :ObjId];
                    body = body+'Case Number : '+ a.CaseNumber +' <br/>';
                }
                else {
                    Quote a = [Select SF_Quote_External_Id__c,QuoteNumber From Quote where id = :ObjId];
                    body = body+'SAP Quote Number : '+ a.SF_Quote_External_Id__c +' <br/>';
                    body = body+'SF Quote Number : '+ a.QuoteNumber +' <br/>';
                }                
                body = body+'Call Type : '+ callType +' <br/>';
                body = body+'SF User Email : '+ UserInfo.getUserEmail() +' <br/>';
                body = body+'<br/>Sincerely<br/>';
                body = body+' LIXIL Water Technology Americas	';
                message.subject = 'ATTENTION : Salesforce to SAP Integration failed.'; 
                message.setHtmlBody(body);
                message.setSaveAsActivity(true);
                message.setWhatId(ObjId);            
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message}; 
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
        }
        return result;
    }
    
    @InvocableMethod(label='Order Submit to SAP' description='When service order is approved then automatically send order to SAP')
    public static void CallSubmitToSAP_Order(List<Order> orders) {
        if(!orders.isEmpty()){
            RequestStatus result = ConfirmationModalCtrl.callAction(orders[0].Id,'OSS');
            if(!result.IsSuccessfull && result.ErrorMessage!='OK'){
                UpdateOrder(orders[0].Id, result.ErrorMessage);
            }
            else{
                CallSubmitToSAP_Order(orders[0].Id);
            }
        }
    }    
    @future(callout=true)
    private static void CallSubmitToSAP_Order(Id anOrder){
        ConfirmationModalCtrl.callAction(anOrder,'OSS');
    }    
    @future(callout=true)
    private static void UpdateOrder(Id anOrder,String error){
        update new order(Id = anOrder,
                         Informatica_Result__c = error
                        );
    }
    
}