/**
* ============================================
* Name: AdyenConnector
* Description: Connector class for Adyen Integration call for PayByLink Creation
 
* Author :- Venkat Kalyan
* Date   :- 29-09-2022
* Test Class :- AdyenConnector_Test -- To be Created
* =======================================================
* */

public class AdyenConnector {
    
   public static string createPaymentLink(String APIKey, String reference,
                                          String shopperReference, string value,
                                            String valCurrency, String description, 
                                            String countrycode, String merchantAccount,
                                            String shopperLocale){
       	
        Map<String, Object> obj = new Map<String, Object>();
        Map<String, Object> amount = new Map<String, Object>();
       	
        amount.put('value', value);
       	amount.put('currency', valCurrency);
       	String amountVal = JSON.serialize(amount);
       	System.debug('amountVal%%%'+ amountVal);
		DateTime expireAt = DateTime.Now().AddDays(+69);
		system.debug('Time = ' + expireAt);
        obj.put('reference', reference);
        obj.put('amount', amountVal);
        obj.put('shopperReference', shopperReference);
        obj.put('description', description); 
        obj.put('countryCode', countrycode);
        obj.put('merchantAccount', merchantAccount);
        obj.put('shopperLocale', shopperLocale);
        obj.put('expiresAt',expireAt);
       
        string finalRequestBody = JSON.serialize(obj);
       	finalRequestBody = finalRequestBody.replace('"{','{');
        finalRequestBody = finalRequestBody.replace('}"','}');
        finalRequestBody = finalRequestBody.replace('\\','');
       
        System.debug('JSON.Serialize(obj)' + finalRequestBody);
        return performHTTPRequest(APIKey, 'POST', '', finalRequestBody);

    }
    
    public static String paymentLinksStatus(String payLinkId, String APIKey){
       return performHTTPRequest(APIKey,'GET', payLinkId, '');
    }
    public static String performHTTPRequest(String APIKey, String method, String suffix, String body) {
        String endpointSuffix = suffix;
        try {
            AdyenPayByLinkEndpoint__c payLinkURL = AdyenPayByLinkEndpoint__c.getInstance('PayByLink');
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000); //2 minutes
            // 'https://checkout-test.adyen.com/v68/paymentLinks/'
            if (!Test.isRunningTest()){
                req.setEndpoint(payLinkURL.URL__c+suffix);
            } 
            if (Test.isRunningTest()){
            req.setEndpoint('https://checkout-test.adyen.com/v68/paymentLinks/'+suffix);
            }
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('x-API-key', APIKey);
                          //'AQEthmfxLoLGbhBFw0m/n3Q5qf3Va4pDDJdLf2pZ1X0pe1dGmXyQj9vpnebKPiMTEMFdWw2+5HzctViMSCJMYAc=-9m9a3kvAnlkNf01OTV5daeBjr4x3uvEC/y4dWvtOVdQ=-e+sx2tEwhG>]^FDI');
            req.setMethod(method);
            if (!String.isBlank(body)) {
                req.setBody(body);
                System.debug('setting body: ' + req.getBody());
            }
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('response: ' + res.getBody());
            if (res.getStatusCode() == 201 || res.getStatusCode() == 200 ) {
                return res.getBody();
            } else {
                throw new CalloutException(res.getBody());
            }
        } catch (Exception e) {
            throw e;
        }
    }


}