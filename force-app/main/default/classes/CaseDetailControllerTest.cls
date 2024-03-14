@isTest
public with sharing class CaseDetailControllerTest {
    @TestSetup
    static void createTestData(){
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact('testcontact', acc.Id, true);
        Style__c style = new Style__c(Name = 'Test');
        insert style;
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        cas.Style__c = style.Id;
        insert cas;

        // Create a dummy ContentVersion record
        ContentVersion dummyVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Dummy content')
        );
        insert dummyVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        // Create a ContentDocumentLink record and associate it with the dummy ContentDocument
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = documents[0].Id,
            LinkedEntityId = style.Id,
            ShareType = 'V'
        );
        insert link;
    }

    @isTest
    static void shouldGetCase() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();

        LightningController.Response resp = CaseDetailController.doInit(c.Id);

        Test.stopTest();

        Assert.isTrue(resp.success);
    }
}