public with sharing class VoiceTranscriptSalesforceCaller {
    private static final String NAMED_CREDENTIALS = 'connect_api_canadagoose';
    private static String URL = '/services/data/v58.0/connect/conversation/{CONVERSATION_ID}/entries';
    
    public HttpResponse getVoiceTranscriptFromOrg(String conversationId) {
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:'+ NAMED_CREDENTIALS + URL.replace('{CONVERSATION_ID}', conversationId));     
         return new Http().send(request);            
    }
}