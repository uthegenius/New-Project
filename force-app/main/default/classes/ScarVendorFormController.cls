/*
 Author:		Abid Raza
 Date: 			05th-Sep-2018
 Description:	This controller is used for Scar Vendor Form Visualforce Page.

*/

public class ScarVendorFormController 
{
    public static String scarID;
    public string IsChampion = '';
    private Integer serialNo=1;
    Public SCAR__c scar {get;set;}
    public static Integer addCount {get; set;}
    public List<ScarTeamWrapper> stWrapper {set;get;}
    public list<SCAR_Team__c> LstSCARTeam {get;set;}
    public Boolean showSection1{get;set;}
    public Boolean showSection2{get;set;}
    public Boolean showSection3{get;set;}
    public Boolean showSection4{get;set;}
    public Boolean showSection5{get;set;}
    public Boolean showSection6{get;set;}
    public Boolean showSection7{get;set;}
    public Boolean showSection8{get;set;}

    
    public ScarVendorFormController()
    {       
        scarID=ApexPages.currentPage().getParameters().get('id');
        	
        scar = new SCAR__c();
        
        if(!string.IsBlank(scarID))
        {
            scar = [SELECT Affected_Document_1_Date__c,Affected_Document_1_Owners_to_Update__c,Affected_Document_1__c,Send_Notification_to_Owner__c,
                    Affected_Document_2_Date__c,Affected_Document_2_Owners_to_Update__c,Affected_Document_2__c,Affected_Document_3_Date__c,
                    Affected_Document_3_Owners_to_Update__c,Affected_Document_3__c,Affected_Document_4_Date__c,Affected_Document_4_Owners_to_Update__c,
                    Affected_Document_4__c,Affected_Document_5_Date__c,Affected_Document_5_Owners_to_Update__c,Affected_Document_5__c,Affected_Document_6_Date__c,
                    Affected_Document_6_Owners_to_Update__c,Affected_Document_6__c,Affected_Document_7_Date__c,Affected_Document_7_Owners_to_Update__c,Affected_Document_7__c,
                    Affected_Document_8_Date__c,Affected_Document_8_Owners_to_Update__c,Affected_Document_8__c,Affected_Sites__c,Build_Date_for_Certified_Marterial__c,
                    Case_Owner_Email__c,Case__c,Closure_Statement_Validation__c,Corrective_Action_for_Why_Made__c,Corrective_Action_for_Why_Shipped__c,
                    Corrective_Action_Owner_s_Email__c,Corrective_Action_Owner_s_Name__c,Corrective_Action_Owner_s_Phone_Number__c,CreatedById,CreatedDate,
                    CurrencyIsoCode,Date_Issue_Occurred__c,Date_Supplier_Notified_of_Appr_Reject__c,How_Made_and_How_Verified__c,
                    How_this_issues_be_avoided_in_the_future__c,How_will_new_parts_be_identified__c,Id,IsDeleted,
                    LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Last_Notified_Vendor__c,LIXIL_SCAR__c,
                    Lixil_Supplier_Quality_Engineer_Comments__c,Lixil_Supplier_Quality_Engineer_Name__c,Lixil_Supplier_Quality_Phone__c,Lot_Number__c,Lot_Quantity__c,Manufacturing_Date__c,Name,
                    Other_Facilities_or_Platform_at_Risk__c,Other_Facilities_Platform_at_Risk_CA_Own__c,Other_Facilities_Platform_at_Risk_DueDt__c,
                    Other_Facilities_Platform_at_Risk_Part__c,Other_Production_Platform_Risk__c,OwnerId,Part_Number__c,Plat_Location_Issue_found_at__c,
                    PO_Number__c,Problem_Description__c,Product_Name__c,Product_Name__r.ProductCode,Rejection_Rate_or_Quantity__c,Review_Results__c,Sample_Size_AQL_Level__c,
                    SCAR_Issue_Date__c,SCAR_Type__c,Supplier_Contact__c,Supplier_Location__c,Supplier_Name__c,Supplier_Soring_Results__c,
                    SystemModstamp,Target_Completion_Date__c,Verification_of_Corrective_Action__c,What_actions_were_taken_to_Immediately__c,Why_Shipped_and_How_Verified__c,
                    X3D_Due_Date__c,X8D_Due_Date__c,Vendor_Shipping_Address__c FROM SCAR__c where Id =:ScarId];
            
            
            system.debug(scar.Lixil_Supplier_Quality_Phone__c);
            
            
            // Getting Scar team and adding to Wrapper.
            stWrapper = new List<ScarTeamWrapper>();
            LstSCARTeam = [SELECT Id,Name,Contact_Role__c,Email__c,Phone__c,SCAR_Contact_Name__c,SCAR_Form__c,Title__c FROM SCAR_Team__c where SCAR_Form__c =: ScarId Order by Contact_Role__c asc];
            
            if(LstSCARTeam != null && LstSCARTeam.size() > 0)
            {
                for(SCAR_Team__c st: LstSCARTeam)
                {
                   if(st.Contact_Role__c == 'Champion') 
                       IsChampion = 'Champion';
                   else
                       IsChampion = 'Team Member';
                   stWrapper.Add(new ScarTeamWrapper(st,IsChampion,serialNo++));
                }
            }
            
            
        }
    }
    
    public void addRows()
    {
        scarID=ApexPages.currentPage().getParameters().get('id');
        IsChampion = 'Team Member';
        for(Integer idx=0; idx<addCount; idx++)
          stWrapper.add(new ScarTeamWrapper(new SCAR_Team__c(),IsChampion,serialNo++));
          integer k=1;
          for(ScarTeamWrapper st: stWrapper)
          {
              st.serialNo=k;
              k++;
          }
       
    }    
    
    // These Methods were written to Hide and show Sections on button click. (Ibad : 20th-Sep-2018)
    integer num=0;
    public PageReference method1() {
        num++;
        
        if(num==1){
            showSection1= true;
        }
        else if (num==2){
            
            showSection1= true;
            showSection2= true;
      
        }  else if (num==3){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
      
        }  else if (num==4){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
            showSection4= true;

      
        }  else if (num==5){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
            showSection4= true;
            showSection5= true;
      
        }  else if (num==6){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
            showSection4= true;
            showSection5= true;
            showSection6= true;
            
      
        }
        
        else if (num==7){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
            showSection4= true;
            showSection5= true;
            showSection6= true;
            showSection7= true;
            
      
        }else if (num==8){
            
            showSection1= true;
            showSection2= true;
            showSection3= true;
            showSection4= true;
            showSection5= true;
            showSection6= true;
            showSection7= true;
            showSection8= true;
            
      
        }
        return null;
    }
    
    public PageReference save() 
    {
        SCAR_Vendor_Form_Email__c scarformsettings = SCAR_Vendor_Form_Email__c.getinstance();
        pagereference pf;
        try
        {     
            scarID=ApexPages.currentPage().getParameters().get('id');
            List<SCAR_Team__c> LstScarTeamToUpsert = new List<SCAR_Team__c> ();
            List<SCAR_Team__c> LstScarTeamToDelete = new List<SCAR_Team__c> ();
            
            for(ScarTeamWrapper stw : stWrapper)
            {
                if(stw.IsChampion == 'Team Member')
                {
                    if(stw.st.SCAR_Form__c != null)
                    {
                        if(string.IsBlank(stw.st.SCAR_Contact_Name__c) && string.IsBlank(stw.st.Email__c) && string.IsBlank(stw.st.Phone__c) && string.IsBlank(stw.st.Title__c))
                        {
                            LstScarTeamToDelete.add(stw.st);
                        }
                        else
                        {
                            LstScarTeamToUpsert.add(stw.st);
                        }
                    }
                    else
                    {
                        if(!string.IsBlank(stw.st.SCAR_Contact_Name__c) && !string.IsBlank(stw.st.Email__c))
                        {
                            stw.st.SCAR_Form__c = scarID;
                            stw.st.Contact_Role__c = IsChampion;
                            stw.st.Name = stw.st.SCAR_Contact_Name__c;
                            LstScarTeamToUpsert.add(stw.st);
                        }
                    }
                }
            }
            
            if(LstScarTeamToDelete.Size() > 0)
            {
                Delete LstScarTeamToDelete;
            }
            if(LstScarTeamToUpsert.Size() > 0)
            {
                Upsert LstScarTeamToUpsert;
            }
            Update scar;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your form has been successfully submitted.'));
            pf = new PageReference(scarformsettings.SuccessPageURL__c);
            pf.setredirect(true);
        }
        catch(Exception ex)
        {
           apexpages.addmessages(ex);
           pf = null;
        }  
        
        return pf;
    }
    
    public class ScarTeamWrapper
    {
        public SCAR_Team__c st{get; set;}
        public Integer serialNo {get;set;}
        Public string IsChampion{get; set;}
        
        public ScarTeamWrapper(SCAR_Team__c st,string IsChampion, Integer serialNo)
        {
            this.st = st;
            this.IsChampion = IsChampion;
            this.serialNo = serialNo;
        }
    } 
}