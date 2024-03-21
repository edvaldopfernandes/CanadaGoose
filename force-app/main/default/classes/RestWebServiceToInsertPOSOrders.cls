/*******************************************************************************************************************************
 * @Name         RestServiceToInsertOrderAndOthers
 * @Author       Venkata Kalyan
 * @Date         08/02/2024
 * @Description  Rest Web Service To order and others
 *******************************************************************************************************************************
 * Version      Developer                Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan        08/02/2024   Initial Creation
 ********************************************************************************************************************************/
@RestResource(urlMapping='/restWebServiceToInsertPOSOrders/')
global without sharing class RestWebServiceToInsertPOSOrders {

    @HttpPost
    global static String createRecordsFromXML() {
        // Parse XML from request body
        String xmlBody = RestContext.request.requestBody.toString();
        system.debug('XML Request Body'+ xmlBody);
        Dom.Document doc = new Dom.Document();
        Account acct = new Account();
        String errorMessage = '';
        RestResponse res = RestContext.response;
        try {
            doc.load(xmlBody);
            Dom.XMLNode emailNode = doc.getRootElement();
        	String email = emailNode.getChildElement('email_address', null).getText();
        	String firstName = emailNode.getChildElement('order', null).getChildElement('order_first_name', null).getText();
        	String lastName = emailNode.getChildElement('order', null).getChildElement('order_last_name', null).getText();
        	String consentType = emailNode.getChildElement('order', null).getChildElement('consent_type', null).getText();
        	acct = upsertAccount(email, firstName, lastName, consentType);
        	
        } 
        catch (Exception e) {
            errorMessage = e.getMessage();
            //return 'Error loading XML: ' + e.getMessage();
            System.debug('catch error message ' + e.getMessage());
            	IntegrationLogUtility.error = e.getMessage();
            if(xmlBody != null){
            	IntegrationLogUtility.status = 'Request captured With Error';
            }else {
                IntegrationLogUtility.status = 'Empty Request';
            }
            	IntegrationLogUtility.exp = e;
        }
        finally{
            	if(acct != null && acct.id != null){
            		res.statusCode = 200;
               		res.responseBody = Blob.valueOf(acct.id);
            	}
            	else{
           			res.statusCode = 400;
               		res.responseBody = Blob.ValueOf(errorMessage);
                	IntegrationLogUtility.status = 'Request captured With Error';
            	}
            	IntegrationLogUtility.createOutBoundLog(xmlBody, String.valueOf(res.statusCode) , 'restService_Order'+DateTime.now(), 'Inbound', 'restService_Order', null);
        }
		return acct.id != null ? String.valueOf(acct.id) : errorMessage ;
    }
      
    private static Account upsertAccount(String email, String firstName, String lastName, String consentType){
        List<Account> existingAccounts = [SELECT Id,PersonEmail, Marketing_Consent_Status__pc FROM Account WHERE PersonEmail = :email LIMIT 1];
        system.debug('<<Number of Accounts>>' + existingAccounts.size());
        Account acct = new Account();
        system.debug('<<<<<Line 145>>>>');
        system.debug('<<<<<Line 147>>>> email>>>' + email);
        if(!existingAccounts.isEmpty() && existingAccounts != null){
            system.debug('<<<<<Line 148>>>> email is found>>>' + email);
            acct = existingAccounts[0];
            if(acct.Marketing_Consent_Status__pc != 'express'){
                system.debug('<<<<<Line 149>>>>'+acct.Marketing_Consent_Status__pc);
                acct.Marketing_Consent_Status__pc = 'express';
                acct.Marketing_Source_Location__pc = 'POS';
                acct.Marketing_Subscription_Source__pc = 'POS';
                //acct.Marketing_Consent_Date__pc = ;
                update acct;
                system.debug('<<<<<Line 156>>>>'+ acct.id);
            }
        }
        else{
                system.debug('<<<<<Create New Account Code>>>>'+ email);
            	acct = new Account(PersonEmail = email, 
                                   FirstName = firstName, 
                                   LastName = lastName,
                                   recordtypeId = '0121N0000019B66QAE',
                                   //PersonMobilePhone = '6476754974',
                                   Marketing_Consent_Status__pc = 'express',
                                   Marketing_Source_Location__pc = 'POS' );
                try{
            		insert acct;
                system.debug('<<<<<Line 167>>>>'+ acct.id);
                } catch(Exception e){
                    system.debug('<<Error In Creating Account>>'+ e.getMessage());
                }
        	} 
        return acct;
    }
}