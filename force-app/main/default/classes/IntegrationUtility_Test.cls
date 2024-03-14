/*******************************************************************************************************************************
 * @Name         IntegrationLogUtility_Test
 * @Author       Venkata Kalyan
 * @Date         11/10/2022
 * @Description Test class for AdyenPayNotification Integration Utility
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    11/10/2022   Initial Creation
 
 ********************************************************************************************************************************/
@IsTest
public class IntegrationUtility_Test {

   static testMethod void testParse() {
       Test.startTest();
        Exception exp;
        
        Id logRecordTypeId = Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get('Adyen Integration Log').getRecordTypeId();
    	IntegrationLogUtility.error ='wqeqwe';
    	IntegrationLogUtility.status = 'Process Failure';
    	IntegrationLogUtility.exp = exp;
        IntegrationLogUtility.createOutBoundLog('request structure', 'response structure', 'Case001', 'Inbound', 'AdyenNotification', logRecordTypeId);
      Test.stopTest();
   }
}