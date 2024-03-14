@isTest
private class ContactTriggerHandlerTest {
    private static final String CONTACT_LAST_NAME = 'Ta7Wu7vUCdyYvP4Ay';
    private static final String CONTACT_LAST_NAME2 = 'rQabYkC3PwxrwDV38Q';
    
	@testSetup
    static void Init() {
        Account acc = TestDataFactory.createTestAccount(true);
       
        Contact cont = TestDataFactory.createTestContact(CONTACT_LAST_NAME, acc.Id, true);
        
        Account acc2 = TestDataFactory.createTestRetailerAccount(true);
        TestDataFactory.createTestContact(CONTACT_LAST_NAME2, acc2.Id, true);

        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, cont, true);
        
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :usr.Id LIMIT 1];
        
        acc.Language__c = usr.LanguageLocaleKey;
        acc.Locale__c = usr.LocaleSidKey;
        update acc;
    }
    
    static testMethod void testSyncCommunityContacts() {
        Test.startTest();
        Contact cont = [SELECT Id, FirstName FROM Contact WHERE LastName = :CONTACT_LAST_NAME LIMIT 1];
        
        cont.FirstName = 'Foo'; 
        update cont; 
        Test.stopTest(); 

        User usr = [SELECT FirstName FROM User WHERE ContactId = :cont.Id LIMIT 1];
        System.assertEquals(cont.FirstName, usr.FirstName, 'User first name must match the Contact first name.');
    }
    
    static testMethod void testEnableCommunityContact() {
        Test.startTest();
        Contact cont = [SELECT Id, LastName FROM Contact WHERE LastName = :CONTACT_LAST_NAME2 LIMIT 1];
        
        cont.Enable_Community_User__c = true;
        cont.FirstName = 'Test';
        update cont;
        Test.stopTest(); 

        List<User> lstUser = [SELECT LastName FROM User WHERE ContactId = :cont.Id];
        System.assertEquals(1, lstUser.size(), 'User record must be created for the Contact.');
        System.assertEquals(cont.LastName, lstUser[0].LastName, 'User last name must match the Contact last name.');
    }
}