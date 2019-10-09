public class SFSupportDSR_Controller {
    public Date DSRDate{get;set;}
    private map<id,Wraper_DSR> DSRData{get;set;}
    public List<Wraper_DSR> ListDSRData{get;set;}
    public SFSupportDSR_Controller(){
        DSRData = new map<id,Wraper_DSR>();
        DSRDate = null;		 
        ListDSRData = new List<Wraper_DSR>();
    }
    public void fetchDSR(){
        DSRData = new map<id,Wraper_DSR>();
        for(CaseComment element:[select id,CommentBody,CreatedDate,Parent.Subject, Parent.CaseNumber,
                                 Parent.Status,Parent.Ready_in_Production__c, Parent.Ready_in_Fullcopy__c,
                                 Parent.Estimated_Hrs_to_Complete__c,ParentId,Parent.SF_Developer_Name__c
                                 from CaseComment
                                 where Parent.RecordType.DeveloperName = 'Salesforce_Cases'
                                 and   DAY_ONLY(CreatedDate) = :DSRDate  
                                 and CreatedById = :UserInfo.getUserId()])
        {
            Wraper_DSR DSR = new Wraper_DSR();
            DSR.CaseNumber = element.Parent.CaseNumber;
            DSR.CaseStatus = element.Parent.Status;
            DSR.EstimateHR = element.Parent.Estimated_Hrs_to_Complete__c;
            DSR.ReadyInProd = element.Parent.Ready_in_Production__c;
            DSR.ReadyInQA = element.Parent.Ready_in_Fullcopy__c;
            DSR.Subject = element.Parent.Subject;
            //DSR.Body = element.CommentBody;
            DSR.DSRDate = element.CreatedDate;
            DSRData.put(element.ParentId,DSR);
        }
        
        
        for(EmailMessage element:[select id,TextBody,CreatedDate,Parent.Subject, Parent.CaseNumber,
                                  Parent.Status,Parent.Ready_in_Production__c, Parent.Ready_in_Fullcopy__c,
                                  Parent.Estimated_Hrs_to_Complete__c,ParentId,Parent.SF_Developer_Name__c
                                  from EmailMessage
                                  where Parent.RecordType.DeveloperName = 'Salesforce_Cases'
                                  and   DAY_ONLY(CreatedDate) = :DSRDate
                                  and  (Status = '2' or Status = '3' or Status = '4')
                                  and CreatedById = :UserInfo.getUserId()])
        {
            Wraper_DSR DSR = new Wraper_DSR();
            DSR.CaseNumber = element.Parent.CaseNumber;
            DSR.CaseStatus = element.Parent.Status;
            DSR.EstimateHR = element.Parent.Estimated_Hrs_to_Complete__c;
            DSR.ReadyInProd = element.Parent.Ready_in_Production__c;
            DSR.ReadyInQA = element.Parent.Ready_in_Fullcopy__c;
            DSR.Subject = element.Parent.Subject;
            DSR.DevName = element.Parent.SF_Developer_Name__c;
            //DSR.Body = element.TextBody;
            DSR.DSRDate = element.CreatedDate;
            DSRData.put(element.ParentId,DSR);            
        }        
        
        List<CaseHistory> listCaseHist = [Select NewValue,OldValue,CaseId from CaseHistory
                                          Where CaseId = :DSRData.keySet()
                                          And   Field  = 'Burn_Hrs__c'
                                          And   DAY_ONLY(CreatedDate)   = :DSRDate
                                          order by CreatedDate
                                          ];
        for(CaseHistory element:listCaseHist){
            Wraper_DSR DSR = new Wraper_DSR();
            if(DSRData.containsKey(element.CaseId)){
                DSR = DSRData.get(element.CaseId);
                double hNew = double.valueOf(element.NewValue);
                double hOld = double.valueOf(element.OldValue);
                if(hNew==null){
                    hNew=0;
                }
                if(hOld==null){
                    hOld=0;
                }
                DSR.hours += hNew - hOld;
                //DSR.DSPhours = string.valueof(DSR.hours);//string.valueof((DSR.hours/0.6).setScale(2));
                DSR.DSPhours = string.valueof(DSR.hours).substringBefore('.').leftpad(2,'0')+':'+ 
                    		   string.valueof((double.valueOf(string.valueof(DSR.hours).substringAfter('.'))*0.6).setScale(0)).leftpad(2,'0');
                    
                DSRData.put(element.CaseId, DSR);                
            }
        }
        
        ListDSRData = DSRData.values();
        
    }
    private class Wraper_DSR{
        public String CaseNumber{get;set;}
        public String CaseStatus{get;set;}
        public Decimal EstimateHr{get;set;}
        public Date ReadyInProd{get;Set;}
        public Date ReadyInQA{get;set;}
        public String Subject{get;set;}
        public double hours{get;set;}
        public string DSPhours{get;set;}
        public DateTime DSRDate{get;set;}
        public string DevName{get;set;}
        public Wraper_DSR(){
            CaseNumber = '';
            CaseStatus = '';
            EstimateHr = null;
            ReadyInProd = null;
            ReadyInQA = null;
            Subject = '';
            hours = 0;
            DSRDate = null;
            DSPhours = '';
            DevName = '';
        }
    }
    
}