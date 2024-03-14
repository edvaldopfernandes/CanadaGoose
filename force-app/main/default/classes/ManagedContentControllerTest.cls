@isTest
private class ManagedContentControllerTest {

    @IsTest(SeeAllData=true)
    static void shouldGetContents() {

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

        Map<String, ConnectApi.ManagedContentNodeValue> resp = new Map<String, ConnectApi.ManagedContentNodeValue>();

        System.runAs(userTest) {
            String networkId = [SELECT Id FROM Network WHERE Name = 'CG - Warranty' LIMIT 1].Id;
            String key = ConnectApi.ManagedContent.getAllManagedContent(networkId, 0, 1, 'en_US', 'cms_image').items[0].contentKey;
            resp = ManagedContentController.getContent(key, 0, 1, 'en_US', '');
        }

        Test.stopTest();
    }
}