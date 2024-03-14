/**
* ============================================
* Name: BatchToUpdateTheConsentTest
* Description: Test Class of BatchToUpdateTheConsent Batch class.
 
* Author :- Venkata Kalyan
* Date   :- 15-01-2022
* =======================================================
* */
@isTest
public class BatchToUpdateTheConsentTest {
    
    @testsetup
    static void testsetup(){
        list<Account> listOfAccounts = new list<Account>();
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User_Ids__c settings = new User_Ids__c();
        settings.SetupOwnerId = UserInfo.getOrganizationId();
    	settings.Automated_Process__c = UserInfo.getUserId();
    	settings.Warranty_Site_User__c = UserInfo.getUserId();
        insert settings;
		
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'sysAdmin', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testing123234user42zwer@testorg.com');
		insert u;
        
        for(Integer i = 0; i < 20; i++){
        	Account acc = new Account(RecordTypeId= recordTypeId, FirstName= 'Test FN-' + i,
                                           LastName='Test LN-' + i, PersonEmail= 'test-' + i + '@example.com');
            acc.ShippingStreet = '100 Queensquay E';
            acc.ShippingCity = 'Toronto';
            acc.ShippingState = 'Ontario';
            acc.ShippingStateCode = 'On';
            acc.ShippingCountry = 'Canada';
            acc.ShippingCountryCode = 'CA';
            acc.ShippingPostalCode = 'M1S 5L6';
            acc.PersonHasOptedOutOfEmail = false;
            acc.Origin__c = 'Generations';
            
            if(i == 1){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Website';
            }
            if(i == 2){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Paid Lead Gen';
            }
            if(i == 3){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Basecamp';
            }
            if(i == 4){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Contest';
            }
            if(i == 5){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Contest';
            }
            if(i == 6){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Website - Edit Account';
            }
            if(i == 7){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'Website - Checkout';
            }
            if(i == 8){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = 'POS';
            }
            if(i == 9){
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 10){
                acc.Marketing_Consent_Status__pc = 'Unsubscribed';
                acc.Marketing_Subscription_Source__pc = 'Paid Lead Gen';
            }
            if(i == 11){
                acc.Marketing_Consent_Status__pc = 'Unsubscribed';
                acc.Marketing_Subscription_Source__pc = 'Website';
            }
            if(i == 12){
                acc.Marketing_Consent_Status__pc = 'Unsubscribed';
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 13){
                acc.Marketing_Consent_Status__pc = 'active';
                acc.Marketing_Subscription_Source__pc = 'Website';
            }
            if(i == 14){
                acc.Marketing_Consent_Status__pc = 'active';
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 15){
                acc.Marketing_Consent_Status__pc = 'implied';
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 16){
                acc.PersonHasOptedOutOfEmail = TRUE;
              	acc.B2C_Add_To_Email_List__pc = FALSE;
            }
            if(i == 17){
                acc.B2C_CustomerList__pc = null;
                acc.B2C_CustomerList_ID__pc = null;
            }
            if(i == 18){
                acc.Marketing_Consent_Status__pc = 'bounced';
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 19){
                acc.Marketing_Consent_Status__pc = null;
                acc.Marketing_Subscription_Source__pc = null;
            }
            if(i == 20){
                acc.Marketing_Consent_Status__pc = 'implied';
                acc.Marketing_Subscription_Source__pc = 'POS';
            }
            listOfAccounts.add(acc);
        }
        
        System.runAs(u) {
            Account acc = new Account(RecordTypeId= recordTypeId, FirstName= 'Test FN---',
                                           LastName='Test LN---', PersonEmail= 'test-cool@example.com');
            acc.ShippingStreet = '100 Queensquay E';
            acc.ShippingCity = 'Toronto';
            acc.ShippingState = 'Ontario';
            acc.ShippingStateCode = 'On';
            acc.ShippingCountry = 'Canada';
            acc.ShippingCountryCode = 'CA';
            acc.ShippingPostalCode = 'M1S 5L6';
            acc.PersonHasOptedOutOfEmail = false;
            acc.Origin__c = 'Generations';
            acc.Marketing_Consent_Status__pc = null;
            acc.Marketing_Subscription_Source__pc = null;
          insert acc;
        }
        insert listOfAccounts;
         
    }
    
    @isTest
    public static void testMethodToCheckCoverage(){
        Test.startTest();
        list<Account> listOfAccount = [SELECT Id, PersonEmail, Marketing_Consent_Status__pc,CreatedByID, B2C_Add_To_Email_List__pc,Marketing_Source_Location__pc,PersonHasOptedOutOfEmail, 
                                       Origin__pc, Origin__c, Marketing_Subscription_Source__pc,B2C_CustomerList__pc,B2C_CustomerList_ID__pc FROM Account];
        system.debug('<<<account recrds>>>'+listOfAccount);
        BatchToUpdateTheConsent batchclass = new BatchToUpdateTheConsent();
        Database.executeBatch(batchclass, 100);
        Test.stopTest();
        
    }

    
}