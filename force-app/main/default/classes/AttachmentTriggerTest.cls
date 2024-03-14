@isTest public class AttachmentTriggerTest {
    @isTest static void caseAfterInsertTest() {
        // Query an existing user for testing
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u) {
            Case randomCase = new Case(Subject = 'AttachmentTriggerTest',Accept_Cleaning_Health_Policy__c = true);
            insert randomCase;
            Attachment randomAttachment = new Attachment(ParentId = randomCase.Id, Name = 'test.txt', Body = Blob.valueOf('Test'));
            JCFS.JiraTriggerTestHelper.testAfterInsert(randomAttachment);
        }
    }
}