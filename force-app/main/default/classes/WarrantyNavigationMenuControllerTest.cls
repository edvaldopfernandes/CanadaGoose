@isTest
private class WarrantyNavigationMenuControllerTest {
    @isTest
    static void testGetNavigationMenuItems() {

        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact('testcontact', acc.Id, true);
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE 'Warranty Customer Community User' LIMIT 1];
        User userTest = new User(
            username = 'ovais.ali123@systemsltd.com',
            Alias =  'hamh',
            ProfileId = portalProfile.Id, 
            Email = 'ovais.ali@systemsltd.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ContactId = con.Id);
        insert userTest;

        Test.startTest();

        System.runAs(userTest) {
            List<NavigationMenuItem> result1 = WarrantyNavigationMenuController.getNavigationMenuItems('', 'Draft');
            List<NavigationMenuItem> result2 = WarrantyNavigationMenuController.getNavigationMenuItems('Default navigation', 'Draft');
        }

        Test.stopTest();
    }

    @isTest
    static void testGetCarouselImages() {

        Test.startTest();
        LightningController.Response result1 = WarrantyNavigationMenuController.getCarouselImages();
        Test.stopTest();
    }
}