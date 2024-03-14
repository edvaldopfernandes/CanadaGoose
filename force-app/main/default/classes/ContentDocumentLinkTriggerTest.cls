@isTest public class ContentDocumentLinkTriggerTest {
    @isTest static void caseAfterInsertTest() {
        
       // Query an existing user for testing
       User u = [SELECT Id FROM User LIMIT 1];

        System.runAs(u) {
            Case oCase = new Case(Subject = 'ContentDocumentTriggerTest');
            insert oCase;
            ContentVersion contentVersion = new ContentVersion(PathOnClient = 'PathOnClient', VersionData = Blob.valueOf('Test'));
            insert contentVersion;
            
            ContentVersion createdContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
         
                ContentDocumentLink randomContentDocumentLink = 
                    new ContentDocumentLink(
                        ContentDocumentId = createdContentVersion.ContentDocumentId, 
                        LinkedEntityId = oCase.Id,
                        ShareType = 'V'
                    );
                JCFS.JiraTriggerTestHelper.testAfterInsert(randomContentDocumentLink);
           
        }
    }
}