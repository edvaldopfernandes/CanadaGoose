@isTest
public class UserProfileControllerTest {
    @TestSetup
    static void createTestData(){
        TestDataFactory.createTestQueueIDOrgDefault(true);
    }

    @isTest
    static void shouldGetUserInfo(){

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

        LightningController.Response resp;
        
        Test.startTest();
        System.runAs(userTest) {
            resp = UserProfileController.getUserInfo();
        }
        Test.stopTest();

        Assert.isTrue(resp.success);
    }

    @isTest
    static void shouldUpdateUserInfoSuccess(){

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

        LightningController.Response resp;
        
        Test.startTest();
        System.runAs(userTest) {
            resp = UserProfileController.getUserInfo();

            UserProfileController.ContactWrapper cnt = (UserProfileController.ContactWrapper) resp.values;
            cnt.firstName = 'Change';

            resp = UserProfileController.updateUserInfo(cnt);
        }
        Test.stopTest();

        Assert.isTrue(resp.success);
    }

    @isTest
    static void shouldUpdateUserInfoFail(){

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

        LightningController.Response resp;
        
        Test.startTest();
        System.debug('Teste start');
        System.runAs(userTest) {
            resp = UserProfileController.getUserInfo();
            System.debug('Resp depois de getUserInfo: ' + resp);

            UserProfileController.ContactWrapper cnt = (UserProfileController.ContactWrapper) resp.values;
            System.debug('Estado do ContactWrapper antes da alteração: ' + cnt);
            
            cnt.contactId = '003000000000000AAA';
            System.debug('Estado do ContactWrapper após alteração para null: ' + cnt);

            resp = UserProfileController.updateUserInfo(cnt);
            System.debug('Resposta de updateUserInfo com contactId nulo: ' + resp);
        }
        Test.stopTest();

        Assert.isTrue(!resp.success);
    }
}