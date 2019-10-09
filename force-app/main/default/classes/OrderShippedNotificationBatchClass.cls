global class OrderShippedNotificationBatchClass  implements Database.Batchable<AggregateResult>, System.Schedulable   {
    
    public void execute(System.SchedulableContext sc)
    {
        OrderShippedNotificationBatchClass ordershp = new OrderShippedNotificationBatchClass();        
        database.executeBatch(ordershp, 200);   
        
    }
    
     public static void scheduleJobForEveryHour(String JobName){
        System.schedule('Order_Shipped_notification_Batch/Hour '+JobName, '0 0 19 * * ?', new OrderShippedNotificationBatchClass() ); 
         //0 0 19 1/1 * ? *
         //0 0 19 * * ? *
    } 
    set<id> setCaseId = new set<id>();
    set<id> setOrderItemId = new set<id>();
    set<String> setCarrierUrlCode = new set<String>();
    Map<String , id> mapCarrierURL = new Map<String , id>();
    global Iterable<AggregateResult>  Start(Database.BatchableContext bc)
    {        
        // this query is retrieving shipped orders records
        String query ='select id, Attribute6__c,Attribute5__c,Ship_To_Account__r.SAP_Account_Number__c ,Carrier__r.URL__c, Shipping_Tracking__c,Order.Case__r.Web_to_Case_URL__c,  Order.ownerid,Order.Order_SAP_ID__c,Product2Id,Product2.Name,Order.Case__c,Order.Case__r.Contact.Email,Order.Case__r.Contact.LastName,Customer_Order_Number__c,sum(Quantity) qty,Carrier__c from OrderItem where Attribute6__c !=null and Remaining_Quantity__c=0 and Shipment_Email_Status__c!=true and Order.Case__r.Contact.Email!=null group by id, Attribute6__c,Attribute5__c,Order.ownerid,Product2Id,Order.Case__c,Order.Case__r.Contact.Email,Customer_Order_Number__c,Carrier__c,Product2.Name,Order.Case__r.Contact.LastName,Order.Order_SAP_ID__c ,Ship_To_Account__r.SAP_Account_Number__c ,Carrier__r.URL__c,Shipping_Tracking__c,Order.Case__r.Web_to_Case_URL__c LIMIT 1500';
        system.debug('HB::'+query);
        return new AggregateResultIterable(query);
    }
    global void Execute(Database.BatchableContext bc, List<AggregateResult> orderShipperList)
    {
        System.debug('Shipper List: '+orderShipperList);
        List<Messaging.SingleEmailMessage> listMasterMails = new List<Messaging.SingleEmailMessage>();
        List<OrderItem> listOrderItem = new List<OrderItem>();
        id iddd=null;
        id convertCaseId;
        case caseIdStr=null;
        boolean checkTracking;
        system.debug(orderShipperList.size());
        List<String> listTrackingNumber = new List<String>();
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply-lwta@lixil.com'];
        for(AggregateResult  ordItm:orderShipperList)
        {
            // checking if trakcing is same for multiple order items
            checkTracking = listTrackingNumber.contains(String.valueOf(ordItm.get('Attribute6__c')));
            // if same tracking number found then it will ignore to create email for that items
            if(ordItm.get('Email')!= null && checkTracking == false   ){
                
                listTrackingNumber.add(String.valueOf(ordItm.get('Attribute6__c')));
                setCarrierUrlCode.add(ordItm.get('Attribute5__c')+'');
                iddd = ordItm.get('id')+'';
                setOrderItemId.add(iddd);
                convertCaseId = String.valueOf(ordItm.get('Case__c'));
                caseIdStr = [select casenumber from case where id=:convertCaseId LIMIT 1];
                //creating email notification 
                // adding email notification in email list to send multiple emails
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.get(0).id);
                email.setSubject('Order ' + ordItm.get('Order_SAP_ID__c')+' Shipped – Case Ref. '+ caseIdStr.caseNumber);
                email.setToAddresses(new String[] {ordItm.get('Email')+''});
                email.setBccAddresses(new String[] {'kashif.ali@gettectonic.com'});
                
                
                
                String bodyMessage='Dear '+ ordItm.get('LastName')+',<br><p>Thank you for contacting LIXIL Water Technology. We have shipped your <span style=color:red;> Order</span> Number '+ordItm.get('Order_SAP_ID__c')+' against <span style=color:red;> Case </span> '+
                    'Number '+caseIdStr.caseNumber+' and you should receive it in 3-5 '+
                    'business days. Please have the case number & order available if you need to contact us in '+
                    'the future. Also, you can get the latest tracking information for your shipment by clicking on the link below.</p> '+
                    'Product Name: '+getAllProductsByTrackingNo(String.valueOf(ordItm.get('Attribute6__c')),orderShipperList)+' <br>'+
                    'This is a system generated email, if you need more information or assistance please reply to your original Case Number '+caseIdStr.caseNumber+' email or call us directly. Do not respond to this email.<br>'+
                    '<br><br>Sincerely,<br><br><b>LIXIL Water Technology Americas</b><br>'+
                    getTollFreeString((String.valueOf(ordItm.get('Web_to_Case_URL__c')))!=null ?String.valueOf(ordItm.get('Web_to_Case_URL__c')):'abc.ASAmerica.com') +'</body></html>';
                
                email.setHtmlBody(bodyMessage);
                listMasterMails.add(email);
                
            }
            
        } 
        
        if(listMasterMails.size() > 0)
        {
            System.debug('Email Sent Size' +  listMasterMails.size());
            // sendgin bulk emails
            Messaging.sendEmail(listMasterMails);
            
        }
        
        // copying carried URL on basis of carrie code/////
        if(setCarrierUrlCode.size() > 0)
        {
            for(carrier__c car: [select name, id from carrier__c where Name in: setCarrierUrlCode])
            {
                mapCarrierURL.put(car.name, car.id);   
            }
            
        }
        if(mapCarrierURL.size() > 0 )
        {
            listOrderItem =[select id, carrier__c,Attribute5__c,Attribute6__c from OrderItem where id in: setOrderItemId];
            List<OrderItem> orderItemToUpdate = new List<OrderItem>();
            for(OrderItem ordrItm :  listOrderItem )
            {
                //setTrackingNumber.add(ordrItm.Attribute6__c);
                if(ordrItm.carrier__c ==null)
                {
                    ordrItm.carrier__c = mapCarrierURL.get(ordrItm.Attribute5__c);	
                    
                }
                ordrItm.Shipment_Email_Status__c = true;
                orderItemToUpdate.add(ordrItm);
            }
            if(orderItemToUpdate.size() > 0)
            {
                update orderItemToUpdate;
            }
            
        }
        
    }
    global void Finish(Database.BatchableContext bc)
    {         
    }
    // getting all products list against tracking number to add in email boday
    private string getAllProductsByTrackingNo(String trackingNumber, List<AggregateResult> orderShipperList)
    {
        List<String> listProducts = new List<String>();
        String varCarrier_URL='';
        String varShipping_Tracking,varSAP_Account_Number;
        String prodList='';
        String generatedURL='';
        String tempTrackingUrl = 'https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=';
        boolean firstProd =false;
        for(AggregateResult  ordItm:orderShipperList)
        {
            if(trackingNumber == String.valueOf(ordItm.get('Attribute6__c')))
            {
                varCarrier_URL = String.valueOf(ordItm.get('URL__c'));
                varShipping_Tracking =String.valueOf(ordItm.get('Shipping_Tracking__c'));
                varSAP_Account_Number = String.valueOf(ordItm.get('SAP_Account_Number__c'));
                
                if(firstProd==true)
                {
                    prodList+='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                }
                else
                {
                    firstProd=true; 
                }
                prodList += ''+ String.valueOf(ordItm.get('Name')) +'<br>';
                generatedURL  ='Tracking Number: '+generateTrackingCarrierUR((varCarrier_URL!=null? varCarrier_URL: ''),
                                                                             (varShipping_Tracking!=null? varShipping_Tracking:'1') ,
                                                                             (varSAP_Account_Number!=null?varSAP_Account_Number:'1'))+'<br>';             
            }
        }
        return prodList+generatedURL;
    }
    // generating Tracking URL
    private String generateTrackingCarrierUR(String varCarrier_URL,string varShipping_Tracking,string varSAP_Account_Number )
    {
        String finalTrackingURL;
        if(varCarrier_URL!=null  && (varShipping_Tracking!=null || varSAP_Account_Number!=null)  )
        {
            finalTrackingURL = varCarrier_URL;
            finalTrackingURL = finalTrackingURL.replace('%trackingnum%',varShipping_Tracking);
            finalTrackingURL= finalTrackingURL.replace('shiptocodeWOT0', varSAP_Account_Number);
            
       }
        else
        {
            
            return varShipping_Tracking;  
         }
        System.debug('KA:: finalTrackingURL'+finalTrackingURL); 
        return '<a href='+finalTrackingURL+'>'+varShipping_Tracking+'</a>';
    }
    // getting Toll Free numbers on basis of case domain.
    private String getTollFreeString(String caseDomain)
    {
        String startString;
			 startString = caseDomain.Substring(0,caseDomain.indexof('.'));
			 caseDomain = caseDomain.Substring(startString.length()+1,caseDomain.length()-1);  
      
			  
        System.debug('KA:: caseDomain '+ caseDomain);
        if(caseDomain=='ASAmerica')
        {
            return 'American Standard Toll Free Line: 1-800-442-1902';
        }
        else if(caseDomain=='CanadaASB')
        {
            return 'American Standard Brands Toll Free Line: 1-800-387-0369';
        }
        else if(caseDomain=='CanadaGrohe')
        {
            return 'Grohe Toll Free Line: 1-888-644-7643';
        }
        else if(caseDomain=='GroheUS')
        {
            return 'Grohe Toll Free Line: 1-800-444-7643';
        }
        else if(caseDomain=='LHSAmerica')
        {
            return 'Lixil Home Services Toll Free Line: 1-866-423-0800';
        }
        else
        {
            return '';
        }
    }
}