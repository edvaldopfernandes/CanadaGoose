public with sharing class VoiceTranscriptProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            , VendorCallKey 
            FROM VoiceCall 
            WHERE VoiceCallTranscriptProcessed__c = false             
        ]);
    }

    public void execute(Database.BatchableContext bc, List<VoiceCall> records){
        if(records == null && records.isEmpty()) {
            System.debug('<<Records passed to the method is empty.>>');
            return;
        }
        Map<String, VoiceCallTranscriptResponse> voiceCallIdToVoiceCallTranscriptResponse = new Map<String, VoiceCallTranscriptResponse>();
        for(VoiceCall voiceCall : records) {
            VoiceCallTranscriptResponse loopVoiceCallTranscriptResponse = VoiceTranscriptProcessorUtil.getVoiceCallTranscript(voiceCall.VendorCallKey);
            if(loopVoiceCallTranscriptResponse == null) {
                System.debug('<<VoiceCall transcript was null for the voice call with Id : '+ voiceCall.Id + '>>');
                continue;
            }
            
            voiceCallIdToVoiceCallTranscriptResponse.put(voiceCall.Id,loopVoiceCallTranscriptResponse);
        }
        
        if(voiceCallIdToVoiceCallTranscriptResponse.isEmpty()) {
            System.debug('<<voiceCallIdToVoiceCallTranscriptResponse do not have elements to iterate>>');
            return;
        }

        List<VoiceCall> voiceCallsToUpdate = VoiceTranscriptProcessorUtil.getVoiceCallToUpdateWithSeparatedConversation(voiceCallIdToVoiceCallTranscriptResponse);
        if(voiceCallsToUpdate.isEmpty()) {
            System.debug('<<Did not get any voice calls to update>>');
            return;
        }

        Database.SaveResult[] voiceCallSaveResults = VoiceTranscriptProcessorUtil.updateRecords(voiceCallsToUpdate);
    }   

    public void finish(Database.BatchableContext bc){
        
    }
}