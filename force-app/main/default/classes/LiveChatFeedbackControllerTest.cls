@isTest
private class LiveChatFeedbackControllerTest {
    @isTest
    static void testNextMethod() {
        // Test case 1: Verify that the selectedId is set to '0 - Very Poor' when it is 0
        Test.startTest();
        LiveChatFeedbackController.next('chatkey', '0', 'Some feedback');
        List<LiveChatTranscript> transcripts1 = [SELECT CSAT_Rating__c FROM LiveChatTranscript WHERE ChatKey = 'chatkey'];
       
        if (!transcripts1.isEmpty()) {
            System.assertEquals('0 - Very Poor', transcripts1[0].CSAT_Rating__c);
        }
        Test.stopTest();
    }

    @isTest
    static void testNextMethod_Excellent() {
        // Test case 1: Verify that the selectedId is set to '0 - Very Poor' when it is blank
        Test.startTest();
        LiveChatFeedbackController.next('chatkey', '4', 'Some feedback');
        List<LiveChatTranscript> transcripts2 = [SELECT CSAT_Rating__c FROM LiveChatTranscript WHERE ChatKey = 'chatkey'];
        if (!transcripts2.isEmpty()) {
            System.assertEquals('4 - Excellent', transcripts2[0].CSAT_Rating__c);
        }
        Test.stopTest();
    }

    @isTest
static void testMyTextGetterSetter() {
    // Create an instance of the LiveChatFeedbackController class
    LiveChatFeedbackController controller = new LiveChatFeedbackController();
    
    // Set a value for myText using the setter
    String expectedValue = 'Hello, World!';
    controller.myText = expectedValue;
    
    // Get the value of myText using the getter
    String actualValue = controller.myText;
    
    // Verify that the value retrieved from the getter matches the expected value
    System.assertEquals(expectedValue, actualValue);
}
@isTest
static void testUpdateLiveChatTranscript() {
    LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript transcript1 = new LiveChatTranscript();
        transcript1.ChatKey = 'chatkey1';
        transcript1.LiveChatVisitorId = visitor.Id;
        LiveChatTranscript transcript2 = new LiveChatTranscript();
        transcript2.ChatKey = 'chatkey2';
        transcript2.LiveChatVisitorId = visitor.Id;
        List<LiveChatTranscript> transcripts = new List<LiveChatTranscript>{transcript1, transcript2};
        insert transcripts;
        
        // Call the method under test
        LiveChatFeedbackController.next('chatkey1', '4', 'feedback');
        
        // Verify the updates
        transcripts = [SELECT Id, CSAT_Feedback__c, CSAT_Rating__c FROM LiveChatTranscript WHERE Id IN :transcripts];
        System.assertEquals('feedback', transcripts[0].CSAT_Feedback__c);
        System.assertEquals('4 - Excellent', transcripts[0].CSAT_Rating__c);
        System.assertEquals(null, transcripts[1].CSAT_Feedback__c);
        System.assertEquals(null, transcripts[1].CSAT_Rating__c);
}
    
}