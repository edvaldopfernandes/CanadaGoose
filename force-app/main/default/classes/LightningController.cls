public virtual class LightningController {
    public class Response {
        @AuraEnabled
        public Boolean success;
        
        @AuraEnabled
        public String message;
        
        @AuraEnabled
        public Object values;

        public Response(Boolean success, String message, Object values) {
            this.success = success;
            this.message = message;
            this.values = values;
        }

        public Response(Boolean success, String message) {
            this(success, message, null);
        }
    }
}