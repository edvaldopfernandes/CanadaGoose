@isTest
public with sharing class WarrantyPolicyControllerTest {
    @isTest
    static void shouldSaveAgreement(){
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
            resp = WarrantyPolicyController.saveAgreement(true);
        }
        Test.stopTest();

        Assert.isTrue(resp.success);
    }
    @isTest
    static void shouldNotSaveAgreement(){
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
            resp = WarrantyPolicyController.saveAgreement(null);
        }
        Test.stopTest();

        Assert.isTrue(!resp.success);
    }
}