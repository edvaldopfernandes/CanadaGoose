@isTest
private class TopNavigationControllerTest {
    private static final String USER_LAST_NAME = 'R8Ggmk7KTjFtuUz2pz';
    
    @testSetup
    static void Init() {
        // Create a regular account
        Account acc = TestDataFactory.createTestAccount(true);
        
        Contact cont = TestDataFactory.createTestContact(USER_LAST_NAME, acc.Id, true);
        
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, cont, false);
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_CA';
        insert usr;		        
    }
    
    static testMethod void testChangeLanguage() {
        Test.startTest(); 
        User usr = [SELECT CountryCode FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        
        Utilities.CountrySetting countrySetting = Utilities.GetCountrySetting(usr.CountryCode);
        
        system.runAs(usr) {
            TopNavigationController.TopNavigationStruct struct = TopNavigationController.getNavigationParameters();
            
            System.assertEquals(false, struct.ShowEnglish, 'Default language is set to English, so it must be hidden.');
            System.assertEquals(countrySetting.ShowFrench, struct.ShowFrench, 'French display should match country setting.');
            System.assertEquals(countrySetting.ShowGerman, struct.ShowGerman, 'German display should match country setting.');
            System.assertEquals(countrySetting.ShowChinese, struct.ShowChinese, 'Chinese display should match country setting.');
            
            TopNavigationController.setUserLanguageAndLocale('fr', 'fr_CA');
        }
                
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        System.assertEquals('fr', usr.LanguageLocaleKey, 'User language must be changed to French.');
        System.assertEquals('fr_CA', usr.LocaleSidKey, 'User Locale must be changed to French Canada.');
        
        system.runAs(usr) {
            TopNavigationController.TopNavigationStruct struct = TopNavigationController.getNavigationParameters();
            
            System.assertEquals(countrySetting.ShowEnglish, struct.ShowEnglish, 'English display should match country setting.');
            System.assertEquals(false, struct.ShowFrench, 'Default language is set to French, so it must be hidden.');
            System.assertEquals(countrySetting.ShowGerman, struct.ShowGerman, 'German display should match country setting.');
            System.assertEquals(countrySetting.ShowChinese, struct.ShowChinese, 'Chinese display should match country setting.');
            
            // Update country to Germany to support German
            usr.CountryCode = 'DE';
            usr.Country = 'Germany';
            update usr;
            
            countrySetting = Utilities.GetCountrySetting(usr.CountryCode);
            
            TopNavigationController.setUserLanguageAndLocale('de', 'de_DE');
        }        
                
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        System.assertEquals('de', usr.LanguageLocaleKey, 'User language must be changed to German.');
        System.assertEquals('de_DE', usr.LocaleSidKey, 'User Locale must be changed to German Germany.');
        
        system.runAs(usr) {
            TopNavigationController.TopNavigationStruct struct = TopNavigationController.getNavigationParameters();
            
            System.assertEquals(countrySetting.ShowEnglish, struct.ShowEnglish, 'English display should match country setting.');
            System.assertEquals(countrySetting.ShowFrench, struct.ShowFrench, 'French display should match country setting.');
            System.assertEquals(false, struct.ShowGerman, 'Default language is set to German, so it must be hidden.');
            System.assertEquals(countrySetting.ShowChinese, struct.ShowChinese, 'Chinese display should match country setting.');
            
            // Update country to Germany to support German
            usr.CountryCode = 'CN';
            usr.Country = 'China';
            usr.State = 'Beijing';
            usr.StateCode = '11';
            update usr;
            
            countrySetting = Utilities.GetCountrySetting(usr.CountryCode);
            
            TopNavigationController.setUserLanguageAndLocale('zh_CN', 'zh_CN');
        }
                
        usr = [SELECT LanguageLocaleKey, LocaleSidKey FROM User WHERE LastName = :USER_LAST_NAME limit 1]; 
        System.assertEquals('zh_CN', usr.LanguageLocaleKey, 'User language must be changed to Chinese.');
        System.assertEquals('zh_CN', usr.LocaleSidKey, 'User Locale must be changed to Chinese China.');
        
        system.runAs(usr) {
            TopNavigationController.TopNavigationStruct struct = TopNavigationController.getNavigationParameters();

            System.assertEquals(countrySetting.ShowEnglish, struct.ShowEnglish, 'English display should match country setting.');
            System.assertEquals(countrySetting.ShowFrench, struct.ShowFrench, 'French display should match country setting.');
            System.assertEquals(countrySetting.ShowGerman, struct.ShowGerman, 'German display should match country setting.');
            System.assertEquals(false, struct.ShowChinese, 'Default language is set to Chinese, so it must be hidden.');
        }
        
        Test.stopTest();
    }
}