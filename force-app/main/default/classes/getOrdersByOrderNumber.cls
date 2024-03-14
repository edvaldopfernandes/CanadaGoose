public class getOrdersByOrderNumber {
    
    @AuraEnabled(cacheable =true)
    public static Map<String,Object> getDeserialize( String orderNum) {
        System.debug('getDeserialize called.');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('callout:AzureCredsForOrderAPI/api/customer/getorders/aboS7lXtaJOyEiR5l0CJGQFUMJ');
        req.setEndpoint('callout:AzureCredsForOrderAPI'+System.Label.URLForGetOrderByNumber+orderNum);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        String body = new Http().send(req).getBody();

        HttpResponse response = h.send(req);
        Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(body);
        System.debug('Users name is: ' + data.get('customer_id'));
        return data;
    }

}