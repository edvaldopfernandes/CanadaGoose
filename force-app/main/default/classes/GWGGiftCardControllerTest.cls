@isTest
public class GWGGiftCardControllerTest {
	@testSetUp
    public static void testSetUpData(){
        profile pr = [SELECT id FROM profile WHERE Name ='System Administrator' LIMIT 1];
        String randomString = String.valueOf(Math.random());
        String ACCOUNT_NAME = String.valueOf(Math.random());
        DateTime dt = DateTime.Now().addDays(-365);
        Id recTypeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User usr = new User( Alias = randomString.substring(0, 8), Email = randomString + '@canadagoose.com', EmailEncodingKey = 'UTF-8',
                                FirstName = randomString, LastName = randomString, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
                                ProfileId = pr.Id, IsActive = true, TimezoneSidKey = 'America/Los_Angeles', Username = randomString + '@noemail.com',
                                Street = '250 Bowie Avenue', City = 'Toronto', Country = 'Canada', CountryCode = 'CA' , State = 'Ontario',
                                StateCode = 'ON' , MobilePhone = '4160000000', PostalCode = 'M6E 2R9');
        insert usr;
        System.runAs(usr){
        	Account acc = new Account( FirstName = ACCOUNT_NAME, LastName ='ACCOUNT_NAME'+'last', ShippingStreet = '250 Bowie Avenue', ShippingCity = 'Toronto',
            						ShippingCountry = 'Canada', ShippingCountryCode = 'CA',ShippingState = 'Ontario', ShippingStateCode = 'ON',
            						Currency__c = 'CAD', ShippingPostalCode = 'M6E 2R9', recordTypeId = recTypeCustomer, Last_GWGGC_Issued_Date__c = dt) ;
        	insert acc;
            Account acc1 = new Account( FirstName = ACCOUNT_NAME, LastName ='ACCOUNT_NAME'+'last1', ShippingStreet = '250 Bowie Avenue', ShippingCity = 'Toronto',
            						ShippingCountry = 'Canada', ShippingCountryCode = 'CA',ShippingState = 'Ontario', ShippingStateCode = 'ON',
            						Currency__c = 'CAD', ShippingPostalCode = 'M6E 2R9', recordTypeId = recTypeCustomer) ;
        	insert acc1;
        }
 
    }
	public static testMethod void testMethod1() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
            Test.startTest();
                String cardId = GWGGiftCardController.createGiftCard(String.ValueOf(acclist[0].id), 'Chat', 'Retail', 'Other', '100' , 'en_US', 'Canada');
         	Test.stopTest();
        }
    }
    public static testMethod void testMethod2() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
            Test.startTest();
               String cardId = GWGGiftCardController.createGiftCard(String.ValueOf(acclist[0].id), 'Chat', 'Retail', 'Other', '100' , 'en_US', 'Canada');
               GWG_Gift_Card__c card = [SELECT id, customer__c FROM GWG_Gift_Card__c WHERE id =: cardId LIMIT 1 ];
               boolean check1 = GWGGiftCardController.checkPermission();
            Test.stopTest();
        }
    }
     public static testMethod void testMethod3() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
            Test.startTest();
               String cardId = GWGGiftCardController.createGiftCard(String.ValueOf(acclist[0].id), 'Chat', 'Retail', 'Other', '100' , 'de', 'Austria');
               GWG_Gift_Card__c card = [SELECT id, customer__c FROM GWG_Gift_Card__c WHERE id =: cardId LIMIT 1 ];
               Account record  = GWGGiftCardController.getAccountLanguage(String.ValueOf(acclist[0].id));
            Test.stopTest();
        }
    }
     public static testMethod void testMethod4() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
            Test.startTest();
               String cardId = GWGGiftCardController.createGiftCard(String.ValueOf(acclist[0].id), 'Chat', 'Retail', 'Other', '600' , 'en_US', 'Canada');
               GWG_Gift_Card__c card = [SELECT id, customer__c FROM GWG_Gift_Card__c WHERE id =: cardId LIMIT 1 ];
            Test.stopTest();
        }
    }
    public static testMethod void testMethod5() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
            Test.startTest();
               String cardId = GWGGiftCardController.createGiftCard(String.ValueOf(acclist[0].id), 'Chat', 'Retail', 'Other', '600' , 'en_US', 'Canada');
               GWG_Gift_Card__c card = [SELECT id, customer__c FROM GWG_Gift_Card__c WHERE id =: cardId LIMIT 1 ];
              
               List<GWG_Gift_Card__c> cardLists = GWGGiftCardController.getGiftCards(String.ValueOf(acclist[0].id));
            Test.stopTest();
        }
    }
	
}