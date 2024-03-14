/*******************************************************************************************************************************
 * @Name         AdyenPayLinkRestResource
 * @Author       Venkata Kalyan
 * @Date         27/09/2022
 * @Description  Apex class to create the custom notifications for Pay Link for Adyen
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    27/09/2022   Initial Creation
 * Test Class -- AdyenPayLinkRestResource_Test
 
 ********************************************************************************************************************************/

@RestResource(urlMapping='/adyenNotificationResource/')
global without sharing class AdyenPayLinkRestResource {
    @HttpPost
    global static void doPost() {
        String message = '';
        string resBody = '';
        string reqBody = '';
        Id logRecordTypeId;
        logRecordTypeId = Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get('Adyen Integration Log').getRecordTypeId();
        String recId = '';
        
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            reqBody = body.toString();
             
            System.debug('>>>request %%%'+reqBody);
            if (reqBody != null ) {
                System.debug('>>>request if not null%%%'+reqBody);
                AdyenPayNotificationParser parser = AdyenPayNotificationParser.parse(reqBody);
               	recId = updateCaseAndInvoice(parser);
                IntegrationLogUtility.status = 'Success';
            }
             
            else{
                IntegrationLogUtility.error = 'request body is not correct>>';
                IntegrationLogUtility.status = 'API Failure';
            }
        } catch (Exception ex) {
            System.debug('message' +ex.getMessage());
            IntegrationLogUtility.error = ex.getMessage();
            IntegrationLogUtility.status = 'Process Failure';
            IntegrationLogUtility.exp = ex;
        }
        finally{
            system.debug(message);
            IntegrationLogUtility.createOutBoundLog(reqBody,'' , recId, 'Inbound', 'AdyenNotification', logRecordTypeId);
        }
        resBody = '"{[accepted]}"';
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = blob.ValueOf(resBody);
        
    }
    
    public static String  updateCaseAndInvoice(AdyenPayNotificationParser parser){
        list<AdyenPayNotificationParser.NotificationItems> notiItems = new list<AdyenPayNotificationParser.NotificationItems>();
        String caseId ;
        List<Case> listOfCases = new list<case>();
        Map<String,Invoice__c> MapOfInvoices = new Map<String, Invoice__c>();
        list<Invoice__c> listOfInvoices = new List<Invoice__c>();
        if(parser.notificationItems != null){
        	notiItems = parser.notificationItems;
            for(AdyenPayNotificationParser.NotificationItems item :notiItems){
                
                AdyenPayNotificationParser.NotificationRequestItem reqItems;
                AdyenPayNotificationParser.AdditionalData addData ;
                
                if(item.NotificationRequestItem != null){
                    reqItems = item.NotificationRequestItem;
                    if(reqItems.additionalData != null){
                        addData = reqItems.additionalData;
                        caseId = '';
                        if(addData.recurring_shopperReference != null || reqItems.merchantReference != null){
                            caseId = addData.recurring_shopperReference;
                            if(caseId == null){
                                string cas = reqItems.merchantReference;
                                list<string> arr = cas.split('-');
                                caseId = arr[0];
                            }
                      
                            listOfCases.add(new case(id = caseId,
                                                        Payment_Adyen_Reference__c = reqItems.pspReference !=null ? reqItems.pspReference : '',
                                                    	Payment_Made__c = Boolean.valueOf(reqItems.success)));
                            if(!MapOfInvoices.containsKey(caseId)){
                                
                                MapOfInvoices.put(caseId, new Invoice__c(Case__c = caseId,
                                                             Adyen_Auth_code__c =addData.authCode != null? addData.authCode : reqItems.reason ,
                                                             Payment_Method__c = reqItems.paymentMethod != null ? reqItems.paymentMethod : '',
                                                             PSP_Reference__c = reqItems.pspReference != null ? reqItems.pspReference : '',
                                                             Settlement_Date__c = reqItems.eventDate != null ? reqItems.eventDate : null,
                                                             Status__c = String.valueOf(reqItems.success != 'true' ? 'Ready' : 'Paid')
                                                            ));
                            }
                        }
                    }
                }
            }
            for(Invoice__c invoice :[SELECT Id,Case__c FROM Invoice__c WHERE Case__c IN : MapOfInvoices.keyset() AND IsLatest__c = true]){
               
                    Invoice.Adyen_Auth_code__c = MapOfInvoices.get(invoice.Case__c).Adyen_Auth_code__c;
                    Invoice.Payment_Method__c = MapOfInvoices.get(invoice.Case__c).Payment_Method__c;
                    Invoice.PSP_Reference__c = MapOfInvoices.get(invoice.Case__c).PSP_Reference__c;
                    Invoice.Settlement_Date__c = MapOfInvoices.get(invoice.Case__c).Settlement_Date__c;
                    Invoice.Status__c = MapOfInvoices.get(invoice.Case__c).Status__c;
                	listOfInvoices.add(Invoice);
                
            }
            
            if(listOfInvoices != null && listOfInvoices.size() > 0){
                
                Database.update(listOfInvoices, false);
            }
            if(listOfCases != null && listOfCases.size() > 0){
                
                Database.update(listOfCases, false);
            }
        }
        return caseId;
  }

}