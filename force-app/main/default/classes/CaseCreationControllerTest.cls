@isTest
public with sharing class CaseCreationControllerTest {
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
            resp = CaseCreationController.getUserInfo();
        }
        Test.stopTest();

        Assert.isTrue(resp.success);
    }

    @isTest
    static void shouldGetPicklistValues(){
        Test.startTest();
        List<Map<String,String>> picklist = CaseCreationController.getPicklistValues('Size__c');
        Test.stopTest();
        Assert.isTrue(!picklist.isEmpty());
    }

    @isTest
    static void shouldGetImageUploadValues(){
        Test.startTest();
        LightningController.Response picklist = CaseCreationController.getImageUploadValues();
        Test.stopTest();
        Assert.isTrue(picklist.success);
    }

    @isTest
    static void shouldCreateCase(){

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
        
        CaseCreationController.ImgData imgData = new CaseCreationController.ImgData();
        imgData.base64 = 'Dummy Content';
        imgData.filename = 'Test.jpg';

        CaseCreationController.Image img = new CaseCreationController.Image('Test', 'Test', false, 'Test', 1, new List<Object>());
        img.image = imgData;

        CaseCreationController.CaseCreation creation = new CaseCreationController.CaseCreation('Abewie Ave', '250', 'ABCDEF', 'Toronto', 'Ontario', 'Canada', '11111');
        creation.customerIssue = new List<String>{'Down'};
        creation.images = new List<CaseCreationController.Image>{img};

        LightningController.Response resp;

        Test.startTest();
        System.runAs(userTest) {
            resp = CaseCreationController.saveCase(creation);
        }
        Test.stopTest();
        System.debug('@@@ERROR - ' + resp.message);
        Assert.isTrue(resp.success);
    }
}