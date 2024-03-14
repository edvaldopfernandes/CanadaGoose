public with sharing class VoiceCallTranscriptResponse {
    public ConversationEntries[] conversationEntries;
    public class ConversationEntries {
        public String clientDuration;
        public String clientTimestamp;
        public String identifier;
        public String messageText;
        public Sender sender;
        public String serverReceivedTimestamp;
    }
    
    public class Sender {
        public String appType;
        public String role;
        public String subject;
    }
}