@isTest
private class UserTriggerHandlerTest {
    private static final String USER_LAST_NAME = '4qEQNqWyYNNvvfc6AE';
    private static final String PERSON_USER_LAST_NAME = 'psDP5M9Sa6aUaYK7Bd';
    
    @testSetup
    static void Init() {
        TestDataFactory.createTestCommunitySettingOrgDefault(true);
        
        // Create a regular account
        Account acc = TestDataFactory.createTestAccount(true);
       
        Contact cont = TestDataFactory.createTestContact(USER_LAST_NAME, acc.Id, true);
                          
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, cont, true);
        
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :usr.Id LIMIT 1];
        
        acc.Language__c = usr.LanguageLocaleKey;
        acc.Locale__c = usr.LocaleSidKey;
        update acc;
        
        // Create a person account
        Account pAcc = TestDataFactory.createTestPersonAccount(PERSON_USER_LAST_NAME, true);

        User pUsr = TestDataFactory.createTestWarrantyCommunityPersonUser(pAcc, true);
        
        pUsr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :pUsr.Id LIMIT 1];
        
        pAcc.Language__c = pUsr.LanguageLocaleKey;
        pAcc.Locale__c = pUsr.LocaleSidKey;
        update pAcc;
    }
    
    static testMethod void testSyncCommunityAccount() {
        Test.startTest(); 
        User usr = [SELECT Id, AccountId, Street FROM User WHERE LastName = :PERSON_USER_LAST_NAME limit 1]; 
        
        usr.Street = 'Foo Street';
        usr.FirstName = 'Foo';
        update usr; 
        
        Test.stopTest(); 
        
        Account acc = [SELECT ShippingStreet, FirstName FROM Account WHERE Id = :usr.AccountId];
        System.assertEquals(usr.Street, acc.ShippingStreet, 'Account shipping street must match the user shipping street.');
        System.assertEquals(usr.FirstName, acc.FirstName, 'Account first name must match the user first name.');
    }
    
    static testMethod void testSyncCommunityPersonAccount() {
        Test.startTest(); 
        User usr = [SELECT Id, AccountId, Street FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        
        usr.Street = 'Foo Street';
        update usr; 
        
        Test.stopTest(); 
        
        Account acc = [SELECT ShippingStreet FROM Account WHERE Id = :usr.AccountId];
        System.assertEquals(usr.Street, acc.ShippingStreet, 'Account shipping street must match the user shipping street.');
    }
    
    static testMethod void testSyncCommunityContact() {
        Test.startTest(); 
        User usr = [SELECT Id, ContactId, FirstName FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        
        usr.FirstName = 'Foo';
        update usr; 
        
        Test.stopTest(); 
        
        Contact cont = [SELECT FirstName FROM Contact WHERE Id = :usr.ContactId];
        System.assertEquals(usr.FirstName, cont.FirstName, 'Contact first name must match the user first name.');
    }
    
    static testMethod void testCountryAndLanguageSupport() {
        Test.startTest(); 
        User usr = [SELECT LanguageLocaleKey FROM User WHERE LastName = :USER_LAST_NAME limit 1];
        usr.Country = 'China';
        usr.CountryCode = 'CN';
        usr.State = 'Beijing';
        usr.StateCode = '11';
        usr.LanguageLocaleKey = 'zh_CN';
        update usr;
        
        usr = [SELECT LanguageLocaleKey FROM User WHERE LastName = :USER_LAST_NAME limit 1];
        System.assertEquals('zh_CN', usr.LanguageLocaleKey, 'User language must remain Chinese.');
        
        usr.Country = 'United States';
        usr.CountryCode = 'US';
        usr.State = 'New York';
        usr.StateCode = 'NY';
        update usr;
        
        Test.stopTest(); 
        
        usr = [SELECT LanguageLocaleKey FROM User WHERE LastName = :USER_LAST_NAME limit 1];
        System.assertEquals('en_US', usr.LanguageLocaleKey, 'User language must defaulted to English since Chinese is not supported in USA.');
    }
    
    static testMethod void testValidations() {
        Test.startTest(); 
        User usr = [SELECT LanguageLocaleKey FROM User WHERE LastName = :USER_LAST_NAME limit 1];
        usr.Country = null;
        usr.CountryCode = null;
        usr.State = null;
        usr.StateCode = null;
        usr.Street = null;
        usr.City = null;
        usr.MobilePhone = null;
        try { update usr; } catch (Exception e) {}
        
        usr.MobilePhone = '1234567890';
        try { update usr; } catch (Exception e) {}

        usr.Country = 'China';
        usr.CountryCode = 'CN';
        usr.Street = 'Test';
        usr.City = 'Test';
        try { update usr; } catch (Exception e) {}
    }
}