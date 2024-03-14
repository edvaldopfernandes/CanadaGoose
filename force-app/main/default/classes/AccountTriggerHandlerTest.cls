@isTest
private class AccountTriggerHandlerTest {
    private static final String ACCOUNT_NAME = 'ens4twnZUEQthS9gWw';
    private static final String ACCOUNT_NAME2 = 'kV9MfBV5JJET9dyQ42';
    private static final String PERSON_ACCOUNT_NAME = 'REN88vyjbaERC8Z2gu';
    private static final String PERSON_ACCOUNT_NAME2 = '4N3vSCDPjZXg7W359e';
    
    @testSetup
    static void Init() {
        TestDataFactory.createTestCommunitySettingOrgDefault(true);
        
        // Create a regular account
        Account acc = TestDataFactory.createTestAccount(ACCOUNT_NAME, true);
       
        Contact cont = TestDataFactory.createTestContact(ACCOUNT_NAME, acc.Id, true);
                          
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, cont, true);
        
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :usr.Id LIMIT 1];
        
        acc.Language__c = usr.LanguageLocaleKey;
        acc.Locale__c = usr.LocaleSidKey;
        update acc;
        
        // Create a person account
        system.debug('Creating Person Account');
        Account pAcc = TestDataFactory.createTestPersonAccount(PERSON_ACCOUNT_NAME, true);

        User pUsr = TestDataFactory.createTestWarrantyCommunityPersonUser(pAcc, true);
        
        pUsr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE Id = :pUsr.Id LIMIT 1];
        
        pAcc.Language__c = pUsr.LanguageLocaleKey;
        pAcc.Locale__c = pUsr.LocaleSidKey;
        update pAcc;
        
        // Create an account with no country
        Account acc2 = TestDataFactory.createTestAccount(ACCOUNT_NAME2, false);
        acc2.ShippingState = null;
        acc2.ShippingStateCode = null;
        acc2.ShippingCountry = null;
        acc2.ShippingCountryCode = null;
        insert acc2;
        
        TestDataFactory.createTestPersonAccount(PERSON_ACCOUNT_NAME2, true);
    }
    
    static testMethod void testSyncCommunityAccounts() {
        Test.startTest(); 
        Account acc = [SELECT Id, ShippingCountryCode, Region__c FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1]; 
        System.assertEquals(acc.Region__c, 'North America - Canada', 'Account region must be set to NA-CA.');

        Utilities.CountrySetting countrySetting = Utilities.GetCountrySetting(Utilities.DEFAULT_COUNTRY_CODE);

        Account acc2 = [SELECT Id, ShippingCountryCode, Region__c FROM Account WHERE Name = :ACCOUNT_NAME2 LIMIT 1]; 
        System.assertEquals(countrySetting.Region, acc2.Region__c, 'Account region must be set to default international region ' + countrySetting.Region);

        acc.ShippingCountry = 'United States';
        acc.ShippingCountryCode = 'US';
        acc.ShippingState = 'New York';
        acc.ShippingStateCode = 'NY';
        update acc;
        
        Test.stopTest();
        
        acc = [SELECT Region__c, ShippingCountryCode FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        System.assertEquals(acc.Region__c, 'North America - USA', 'Account region must be set to NA-USA.');
        
        User usr = [SELECT CountryCode FROM User WHERE AccountId = :acc.Id LIMIT 1];
        System.assertEquals(acc.ShippingCountryCode, usr.CountryCode, 'User country code must match the account shipping country code.');
        
        acc.ShippingCountry = 'Zimbabwe';
        acc.ShippingCountryCode = 'ZW';
        update acc;
        
        acc = [SELECT Region__c FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1]; 
        System.assertEquals(countrySetting.Region, acc.Region__c, 'Account region must be set to default international region ' + countrySetting.Region);
    }
    
    static testMethod void testSyncCommunityPersonAccounts() {
        Test.startTest(); 
        Account acc = [SELECT Id, ShippingCountryCode, Region__c FROM Account WHERE LastName = :PERSON_ACCOUNT_NAME LIMIT 1]; 
        System.assertEquals(acc.Region__c, 'North America - Canada', 'Account region must be set to NA-CA.');

        acc.ShippingCountry = 'United States';
        acc.ShippingCountryCode = 'US';
        acc.ShippingState = 'New York';
        acc.ShippingStateCode = 'NY';
        update acc;
        
        Test.stopTest();
        
        acc = [SELECT Region__c, ShippingCountryCode FROM Account WHERE LastName = :PERSON_ACCOUNT_NAME LIMIT 1];
        System.assertEquals(acc.Region__c, 'North America - USA', 'Account region must be set to NA-USA.');
        
        User usr = [SELECT CountryCode FROM User WHERE AccountId = :acc.Id LIMIT 1];
        System.assertEquals(acc.ShippingCountryCode, usr.CountryCode, 'User country code must match the account shipping country code.');
        
        acc.ShippingCountry = 'Zimbabwe';
        acc.ShippingCountryCode = 'ZW';
        update acc;
        
        Utilities.CountrySetting countrySetting = Utilities.GetCountrySetting(Utilities.DEFAULT_COUNTRY_CODE);

        acc = [SELECT Region__c FROM Account WHERE LastName = :PERSON_ACCOUNT_NAME LIMIT 1]; 
        System.assertEquals(countrySetting.Region, acc.Region__c, 'Account region must be set to default international region ' + countrySetting.Region);
    }
    
    static testMethod void testEnableCommunityContact() {
        Test.startTest();
        Contact cont = [SELECT Id, LastName FROM Contact WHERE LastName = :PERSON_ACCOUNT_NAME2 LIMIT 1];
        
        cont.Enable_Community_User__c = true;
        cont.FirstName = 'Test';
        update cont;
        Test.stopTest(); 

        List<User> lstUser = [SELECT LastName FROM User WHERE ContactId = :cont.Id];
        System.assertEquals(1, lstUser.size(), 'User record must be created for the Contact.');
        System.assertEquals(cont.LastName, lstUser[0].LastName, 'User last name must match the Contact last name.');
    }
}