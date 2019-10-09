/*
 Author:		Abid Raza
 Date: 			05th-Sep-2018
 Description:	This trigger is used for checkbox to be true to sent email for last 5 sections of SCAR form.
*/

trigger SCARTrg on SCAR__c (Before Update) 
{
    If(Trigger.IsUpdate && trigger.IsBefore)
    {
        for(SCAR__c scar: Trigger.New)
        {
            if(scar.Is_Last_5_Sections_Email_Sent__c == false && scar.SCAR_Team_Count__c > 0 && !string.IsBlank(scar.Affected_Sites__c) && !string.IsBlank(scar.Problem_Description__c) && !string.IsBlank(scar.What_actions_were_taken_to_Immediately__c) && !string.IsBlank(scar.Other_Production_Platform_Risk__c) && !string.IsBlank(scar.Supplier_Soring_Results__c)
               && (string.isBlank(scar.How_Made_and_How_Verified__c) || string.isBlank(scar.Why_Shipped_and_How_Verified__c) || string.isBlank(scar.Corrective_Action_for_Why_Made__c) || string.isBlank(scar.Corrective_Action_Owner_s_Name__c) || string.isBlank(scar.Corrective_Action_for_Why_Shipped__c) || string.isBlank(scar.Corrective_Action_Owner_s_Email__c) || scar.Target_Completion_Date__c != null || string.isBlank(scar.Corrective_Action_Owner_s_Phone_Number__c) || string.isBlank(scar.Verification_of_Corrective_Action__c) || scar.Build_Date_for_Certified_Marterial__c != null || string.isBlank(scar.How_will_new_parts_be_identified__c) || string.isBlank(scar.How_this_issues_be_avoided_in_the_future__c) || string.isBlank(scar.Other_Facilities_or_Platform_at_Risk__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_Part__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_CA_Own__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_DueDt__c) || string.isBlank(scar.Affected_Document_1__c) || string.isBlank(scar.Affected_Document_1_Owners_to_Update__c) || scar.Affected_Document_1_Date__c != null || string.isBlank(scar.Affected_Document_2__c) || string.isBlank(scar.Affected_Document_2_Owners_to_Update__c) || scar.Affected_Document_2_Date__c != null  || string.isBlank(scar.Affected_Document_3__c) || string.isBlank(scar.Affected_Document_3_Owners_to_Update__c) || scar.Affected_Document_3_Date__c != null || string.isBlank(scar.Affected_Document_4__c) || string.isBlank(scar.Affected_Document_4_Owners_to_Update__c) || scar.Affected_Document_4_Date__c != null || string.isBlank(scar.Affected_Document_5__c) || string.isBlank(scar.Affected_Document_5_Owners_to_Update__c) || scar.Affected_Document_5_Date__c != null || string.isBlank(scar.Affected_Document_6__c) || string.isBlank(scar.Affected_Document_6_Owners_to_Update__c) || scar.Affected_Document_6_Date__c != null || string.isBlank(scar.Affected_Document_7__c) || string.isBlank(scar.Affected_Document_7_Owners_to_Update__c) || scar.Affected_Document_7_Date__c != null || string.isBlank(scar.Affected_Document_8__c) || string.isBlank(scar.Affected_Document_8_Owners_to_Update__c) || scar.Affected_Document_8_Date__c != null || string.isBlank(scar.Closure_Statement_Validation__c)))
            {
                scar.Is_Last_5_Sections_Email_Sent__c = true;
            }
        }
    }
}