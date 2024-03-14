/*******************************************************************************************************************************
 * @Name         IntegrationLogUtility
 * @Author       Venkata Kalyan
 * @Date         05/10/2022
 * @Description  AdyenPayNotification Integration Utility
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    05/10/2022   Initial Creation
 * Test class - IntegrationLogUtility_Test
 
 ********************************************************************************************************************************/

Public Class IntegrationLogUtility {
  
    public static string error;
    public static string status;
    public static Exception exp;
    
    Public static void createOutBoundLog(string req, string res, string rec, string method, string thirdparty, Id recordTypeId){
        Integration_Log__c log = new Integration_Log__c();
        log.Method__c = method;
        log.Record_Id__c = rec;
        log.Request__c = req;
        log.Response__c = res;
        log.Error_Message__c = error;
//        system.debug('exception :- '+exp.getMessage() );
        if(exp != null){
            log.Exception__c = exp.getMessage();
            log.Stack_trace__c = exp.getStackTraceString();
        }
        log.Status__c = status;
        log.Integration_Source__c = thirdparty;
       	insert log;
    }
    
}