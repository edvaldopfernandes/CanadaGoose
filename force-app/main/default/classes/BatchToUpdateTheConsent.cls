/**
* ============================================
* Name: BatchToUpdateTheConsent
* Description: Batch to update the consent status
 
* Author :- Venkata Kollipara
* Date   :- 10-11-2023
* Test Class :- BatchToUpdateTheConsentTest
* =======================================================
* */
public class BatchToUpdateTheConsent implements Database.Batchable<Sobject> {
                                                 
	public Database.querylocator start (Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT Id, PersonEmail, Marketing_Consent_Status__pc,CreatedByID, B2C_Add_To_Email_List__pc,Marketing_Source_Location__pc,PersonHasOptedOutOfEmail, 
                                       Origin__pc, Origin__c, Marketing_Subscription_Source__pc,B2C_CustomerList__pc,B2C_CustomerList_ID__pc FROM Account]);
	}
    public void execute(Database.BatchableContext BC, List<account> listOfAccount){
        User_Ids__c  ids = User_Ids__c.getOrgDefaults();
        if(ids != null && ids.Automated_Process__c != null && ids.Warranty_Site_User__c  != null){
            for(account acc : listOfAccount){   
				if(acc.Marketing_Consent_Status__pc == null && (acc.Marketing_Subscription_Source__pc =='' ||acc.Marketing_Subscription_Source__pc == null) && acc.CreatedByID == ids.Automated_Process__c ){
                         acc.Marketing_Consent_Status__pc = 'Un consented';
                         acc.Marketing_Subscription_Source__pc = 'Live Chat';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
            	}
            	if(acc.Marketing_Consent_Status__pc == null && (acc.Marketing_Subscription_Source__pc =='' ||acc.Marketing_Subscription_Source__pc == null) && acc.CreatedByID == ids.Warranty_Site_User__c ){
                         acc.Marketing_Consent_Status__pc = 'Un consented';
                         acc.Marketing_Subscription_Source__pc = 'Warranty';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
            	}
  				if(acc.Marketing_Consent_Status__pc == null && (acc.Marketing_Subscription_Source__pc =='' ||acc.Marketing_Subscription_Source__pc == null) && acc.CreatedByID != ids.Warranty_Site_User__c && acc.CreatedByID != ids.Automated_Process__c){
                         acc.Marketing_Consent_Status__pc = 'Un consented';
                         acc.Marketing_Subscription_Source__pc = 'CSR ';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
            	}
                if(acc.Marketing_Consent_Status__pc == 'express' && acc.Marketing_Subscription_Source__pc != NULL && acc.Marketing_Subscription_Source__pc.contains('Paid Lead Gen')){               
                         acc.Marketing_Subscription_Source__pc = 'Paid Lead Gen';
                         acc.Marketing_Source_Location__pc = 'SFMC';
                         acc.Origin__pc = 'Ad hoc Campaign';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && ( acc.Marketing_Subscription_Source__pc == 'Website' 
                   || acc.Marketing_Subscription_Source__pc.contains('Basecamp') 
                   || acc.Marketing_Subscription_Source__pc.contains('Canada Goose'))){
                           
                         acc.Marketing_Subscription_Source__pc = 'Website';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && ( acc.Marketing_Subscription_Source__pc == 'Website - Email Signup' 
                   || acc.Marketing_Subscription_Source__pc.contains('Contest') 
                   || acc.Marketing_Subscription_Source__pc.contains('Website - Email Sign up In'))){ 
                       
                         acc.Marketing_Subscription_Source__pc = 'Website - Email Signup';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
                if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && ( acc.Marketing_Subscription_Source__pc == 'Website - Create Account' 
                   || acc.Marketing_Subscription_Source__pc.contains('Website - Account Registr') 
                   || acc.Marketing_Subscription_Source__pc.contains('Website - Edit Account'))) {
                       
						 acc.Marketing_Subscription_Source__pc = 'Website - Create Account';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
                if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && ( acc.Marketing_Subscription_Source__pc == 'Website - Checkout' 
                   || acc.Marketing_Subscription_Source__pc.contains('Sito Web - Checkout'))){
                       
                         acc.Marketing_Subscription_Source__pc = 'Website - Checkout';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
           		if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc == 'POS'){
                         acc.Origin__pc = 'POS';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'express' 
                   && acc.Marketing_Subscription_Source__pc == null){
                         acc.Marketing_Subscription_Source__pc = 'Service Cloud';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'Unsubscribed' 
                   && acc.Marketing_Subscription_Source__pc == 'Paid Lead Gen'){
                         acc.Marketing_Source_Location__pc = 'SFMC';
                         acc.Origin__pc = 'Ad Hoc Campaign';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'Unsubscribed' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && acc.Marketing_Subscription_Source__pc.Contains('Website')){
           				 acc.Marketing_Subscription_Source__pc = 'Website';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
           		if(acc.Marketing_Consent_Status__pc == 'Unsubscribed' 
                   && acc.Marketing_Subscription_Source__pc == null){
                         acc.Marketing_Subscription_Source__pc = 'Service Cloud';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'active' 
                   && acc.Marketing_Subscription_Source__pc != NULL 
                   && acc.Marketing_Subscription_Source__pc.Contains('Website')){
                         acc.Marketing_Consent_Status__pc = 'Un Consented';
                         acc.Marketing_Subscription_Source__pc = 'Website';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'active' 
                   && acc.Marketing_Subscription_Source__pc == null){
                         acc.Marketing_Consent_Status__pc = 'Un Consented';
                         acc.Marketing_Subscription_Source__pc = 'Website';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
            	if(acc.Marketing_Consent_Status__pc == 'bounced' 
                   || acc.Marketing_Consent_Status__pc == 'held'){
                         acc.Marketing_Consent_Status__pc = 'Un Consented';
                         acc.Marketing_Subscription_Source__pc = 'Website';
                         acc.Marketing_Source_Location__pc = 'SFCC';
                         acc.Origin__pc = 'Website';
            	}
                if(acc.Marketing_Consent_Status__pc == 'implied' 
                   && acc.Marketing_Subscription_Source__pc == 'POS'){
                         acc.Marketing_Consent_Status__pc = 'Un Consented';
                         acc.Origin__pc = 'POS';
            	}
                
            	if(acc.PersonHasOptedOutOfEmail == TRUE 
                   && acc.B2C_Add_To_Email_List__pc == FALSE ){
                		acc.Marketing_Consent_Status__pc = 'Unsubscribed';
            	}
            	if(acc.B2C_CustomerList__pc == null 
                   && acc.B2C_CustomerList_ID__pc == null){
                		acc.B2C_CustomerList__pc = System.label.CustomerListId;
             	        acc.B2C_CustomerList_ID__pc = 'CanadaGooseCA';
            	}
        	}
        }
        if(listOfAccount.size() > 0){  Database.update(listOfAccount, false); }
    }
    public void finish(Database.BatchableContext BC){}
}