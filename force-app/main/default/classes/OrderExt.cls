public class OrderExt 
{
    public Order objOrder;
    private ApexPages.StandardController controller;
    public static PageReference pgRef; 
    
    public OrderExt(ApexPages.StandardController stdController)
    {
        controller = stdController;
        this.objOrder = (Order)stdController.getRecord();
        this.objOrder = [Select Order_SAP_ID__c,isOrderAmountApproved__c,RecordType.DeveloperName,Credit_Card_Authorization__c from order where id=:objorder.Id][0];
        pgRef = stdController.view();
    }    
    
    public PageReference orderRefresh(){
        PageReference ReturnPage = new PageReference('/' + objOrder.id); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;  
    }
    
    public PageReference refreshOrderShipping(){         
            List<Informatica_Order_Callout.InformaticaResponse> status= Informatica_Order_Callout.callShippmentDetail(objOrder.Order_SAP_ID__c);
            
            return null;
    }
    
    public PageReference submitTOSAP(){   
            if (!objOrder.isOrderAmountApproved__c && objOrder.RecordType.DeveloperName!='Credit_Card_Sales') 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR ,' This order has not been approved yet. Please submit this order for the approval process.'));
            }
            else if (string.isBlank(objOrder.Credit_Card_Authorization__c) && objOrder.RecordType.DeveloperName=='Credit_Card_Sales') 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR ,' Credit Card information should be authorized before submitting an order to SAP. Please perform credit card authorization first.'));
            }
            else{
                List<Informatica_Order_Callout.InformaticaResponse> status = Informatica_Order_Callout.callSubmitToSAP(objOrder.Id);
                if(status[0].MESSAGE_TYPE=='S') {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM ,' '+Status[0].MESSAGE));
                }
                else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR ,' '+Status[0].MESSAGE));
                }   
            }            
            return null;
    }
    
}