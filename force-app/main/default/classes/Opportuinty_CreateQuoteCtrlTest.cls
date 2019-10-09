/************************
Author:         Azfer Pervaiz
Created Date:   14/Aug/2018 
Purpose:        Opportuinty_CreateQuoteCtrl is the test class for the Opportuinty_CreateQuoteCtrl controller.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
14/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class Opportuinty_CreateQuoteCtrlTest {
	
	@isTest static void CreateQuoteCtrlTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

        Test.startTest();
	    Opportuinty_CreateQuoteCtrl.CreateQuoteCtrl( OpportunityObj.Id, 'Standard_Quote' );
        Test.stopTest();
    }
}