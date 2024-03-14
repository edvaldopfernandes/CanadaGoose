/**
* ============================================
* Name: AdyenConnectorTest
* Description: Test class for Connector class for Adyen Integration call for PayByLink Creation
 
* Author :- Venkat Kalyan
* Date   :- 30-09-2022
* =======================================================
* */

@IsTest
public class AdyenConnector_Test {

    @isTest
    static void testSetup(){
        	AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
            paylink.Name='PayByLink';
            paylink.URL__c = 'https://google.com';
            insert paylink;
    }
   static testMethod void testParse() {
       
       Test.startTest();
       user u = new user();
       u.id = Userinfo.getUserId();
       System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
            
            
    AdyenPayByLinkEndpoint__c payLinkURL = AdyenPayByLinkEndpoint__c.getInstance('PayByLink');
           AdyenConnector.createPaymentLink('sadadasf', 'asfasfa',
                                              '45345345', '22',
                                               'CAD', 'Test', 
                                                'CA', 'CanadaGooseCA',
                                                'en-CA');
           AdyenConnector.paymentLinksStatus('412342342134', 'sadadasf');
       }
        Test.stopTest();
   }
}