public with sharing class VoiceTranscriptProcessorUtil {
    private static VoiceTranscriptSalesforceCaller voiceTranscriptSalesforceCaller = new VoiceTranscriptSalesforceCaller();
    
    public static VoiceCallTranscriptResponse getVoiceCallTranscript(String conversationId) {
        if(String.isBlank(conversationId)) {
            System.debug('<<ConversationId is blank in VoiceTranscriptProcessorUtil.getVoiceCallTranscript>>');
            return null;
        }
        HttpResponse theResponse = voiceTranscriptSalesforceCaller.getVoiceTranscriptFromOrg(conversationId);
        if(theResponse.getStatusCode() != 200) {
            System.debug('<<There was an error while retreiving voice transcript : ' + theResponse.getBody() + '>>');
            return null;
        }
        return (VoiceCallTranscriptResponse) JSON.deserialize(theResponse.getBody(), VoiceCallTranscriptResponse.class);
    }

    public static List<VoiceCall> getVoiceCallToUpdateWithSeparatedConversation(Map<String, VoiceCallTranscriptResponse> voiceCallIdToVoiceCallTranscriptResponse) {
        if(voiceCallIdToVoiceCallTranscriptResponse.isEmpty()) {
            return null;
        }
        
        List<VoiceCall> voiceCallsToUpdate = new List<VoiceCall>();
        for(String voiceCallId : voiceCallIdToVoiceCallTranscriptResponse.keySet()) {
            VoiceCall voiceCall = new VoiceCall(
                Id = voiceCallId
                , VoiceAgentTranscript__c = ''
                , VoiceCustomerTranscript__c = ''
            );
            VoiceCallTranscriptResponse theResponse = voiceCallIdToVoiceCallTranscriptResponse.get(voiceCallId);
            
            for(Integer i=theResponse.conversationEntries.size()-1; i >= 0; i--) {
                if(theResponse.conversationEntries[i].sender.role.equalsIgnoreCase('Agent')) {
                    voiceCall.VoiceAgentTranscript__c +=  theResponse.conversationEntries[i].messageText + '\n';
                } else {
                    voiceCall.VoiceCustomerTranscript__c += theResponse.conversationEntries[i].messageText + '\n';
                }
            }
            voiceCall.VoiceCallTranscriptProcessed__c = true;
            voiceCallsToUpdate.add(voiceCall);
        }

        return voiceCallsToUpdate;
    }

    public static Database.SaveResult[] updateRecords(List<VoiceCall> records) {
        if(records.isEmpty()) {
            return null;
        }

        return Database.update(records, false);
    }
}