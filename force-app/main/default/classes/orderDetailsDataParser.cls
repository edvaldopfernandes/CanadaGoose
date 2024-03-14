/**
* ============================================
* Name: orderDetailsDataParser
* Description: Code to parse and save order data
 
* Author :- Venkat Kalyan
* Date   :- 26-02-2023
* Test Class :- 
* =======================================================
* */
public class orderDetailsDataParser {    
    @AuraEnabled
    public static Map<String,Object> getDeserialize( String rId) {
        System.debug('getDeserialize called.');
        System.debug('RID:'+rId);
        List<Account> contactId= [SELECT PersonContactId FROM Account WHERE ID = :rid];
        //System.debug('ContactID:'+contactId[0].PersonContactId);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('callout:AzureCredsForOrderAPI/api/customer/getorders/0031D00000h7ENJQA2');
        req.setEndpoint('callout:AzureCredsForOrderAPI/api/customer/getorders/'+contactId[0].PersonContactId);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        String body = new Http().send(req).getBody();

        HttpResponse response = h.send(req);
        System.debug('Response ' + response.getbody());
        Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(body);
        System.debug('Users name is: ' + data.get('customer_id'));
        return data;
    }
}