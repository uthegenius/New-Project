@isTest
public class pagedirectionsTest {
    @isTest static void testMethod1(){ 
        PageReference myVfPage = Page.showExternalPage;
        Test.setCurrentPage(myVfPage);        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('URL','www.google.com');
        pagedirections a = new pagedirections();
        a.urlRedirection();
    }
}