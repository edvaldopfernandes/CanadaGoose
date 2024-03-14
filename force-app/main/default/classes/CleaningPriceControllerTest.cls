@isTest
private class CleaningPriceControllerTest {
    private static final String USER_LAST_NAME = 'EX3ZMAKSjQraY2CjTc';
    
    static testMethod void testGetContactCurrencyCode() {
		// Init data
        String currencyCode;
        Account acc = TestDataFactory.createTestAccount(true);
       
        Contact cont = TestDataFactory.createTestContact(USER_LAST_NAME, acc.Id, true);
                          
        User loggedUser = TestDataFactory.createTestWarrantyCommunityUser(USER_LAST_NAME, cont.Id, true);
        
        Test.startTest();
        
        System.runAs(loggedUser) {
            currencyCode = CleaningPriceController.getContactCurrencyCode();
        }
        
        Test.stopTest(); 
        
        System.assertEquals(currencyCode, 'CAD', 'Returned currency code must match the currency configured on the logged in user.');
    }
}