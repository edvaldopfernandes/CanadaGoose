/**
 * This class handles the Live Chat feedback functionality.
 */
global class LiveChatFeedbackController {
    public String myText { get; set; }
    
    /**
     * This method is invoked remotely to handle the next action in the Live Chat feedback process.
     * It updates the CSAT_Feedback__c and CSAT_Rating__c fields in the LiveChatTranscript records based on the provided parameters.
     * 
     * @param chatkey The chat key associated with the LiveChatTranscript records.
     * @param selectedId The selected rating ID.
     * @param feedback The feedback provided by the user.
     */
    @RemoteAction
    global static void next(String chatkey, String selectedId, String feedback) {
        // If the selectedId is 0, set it to '0 - Very Poor'
        if (selectedId.equals('0')) {
            selectedId = '0 - Very Poor';  
        } else if (selectedId.equals('4')) {
            // If the selectedId is '4', set it to '4 - Excellent'
            selectedId = '4 - Excellent';
        } 
        
        try {
            // Query the LiveChatTranscript records based on the chatkey
            List<LiveChatTranscript> transcripts = [SELECT Id FROM LiveChatTranscript WHERE ChatKey = :chatkey];
            
            // Update the CSAT_Feedback__c and CSAT_Rating__c fields in each LiveChatTranscript record
            
            for (LiveChatTranscript transcript : transcripts) {
                transcript.SkillId = null;
                transcript.CSAT_Feedback__c = feedback;
                transcript.CSAT_Rating__c = selectedId;
            }
            
            // Update the LiveChatTranscript records
            update transcripts;
        } catch (Exception e) {
            // Handle the exception here or throw it to be caught at a higher level
            throw e;
        }
    }  
}