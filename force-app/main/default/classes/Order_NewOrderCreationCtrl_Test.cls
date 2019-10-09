@IsTest
public class Order_NewOrderCreationCtrl_Test {
    @isTest static void createOrderFromCaseValidation1() {        
            system.debug(Order_NewOrderCreationCtrl.fetchRecordTypeValues());
            system.debug(Order_NewOrderCreationCtrl.getRecTypeId('Credit Card Sales'));
    }    
}