@isTest
public class GWGGiftCardCalloutQueuableTest {
    
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
    public static Case_Gift_Card__mdt  getData(string devName){
        Case_Gift_Card__mdt  cg;
        try{ cg = [select User__c,Password__c,Item_Id__c,Endpoint__c,Endpoint2__c from Case_Gift_Card__mdt where DeveloperName = :devName];}
        catch(Exception e){  System.debug('****Exception' + e.getMessage()); }
        return cg;
    }
    public static Map<string,HttpCalloutMock> GetRequest(String resbody) {
        Case_Gift_Card__mdt cg = getData('Canada_English');
        SingleRequestMock res = new SingleRequestMock(200,'OK',resbody,null);
        Map<string,HttpCalloutMock> mapOfrequests = new Map<string,HttpCalloutMock>();
        mapOfrequests.put(cg.Endpoint__c,res);
        mapOfrequests.put(cg.Endpoint2__c,res);
        return mapOfrequests;
    }
    public static Map<string,HttpCalloutMock> GetBadRequest(String resbody) {
        Case_Gift_Card__mdt cg = getData('Canada_English');
        SingleRequestMock res = new SingleRequestMock(400,'Bad Request',resbody,null);
        Map<string,HttpCalloutMock> mapOfrequests = new Map<string,HttpCalloutMock>();
        mapOfrequests.put(cg.Endpoint__c,res);
        mapOfrequests.put(cg.Endpoint2__c,res);
        return mapOfrequests;
    }
	public static testMethod void CalloutSuccessful() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
        Test.startTest();
        // Create test data
        GWG_Gift_Card__c testGiftCard1 = new GWG_Gift_Card__c( Business_Unit__c = 'Retail', Channel__c = 'Chat',Reason__c = 'Other',
                                                                  GWG_Country__c = 'Canada', GC_Language__c = 'en_US',Currency__c = 'CAD',
                                                                  E_cert_delivery_Method__c = 'Email', Email__c = 'test011@gmail.com',
                                                                  Entry_Greeting_From__c  = 'Canada Goose',Entry_Greeting_To__c = 'test',
                                                                  Gift_Card_Value__c = 100, Item_Quantity__c = 1, Line_Number__c = '1',
                                                                  Receiving_Email__c = 'test011@gmail.com',Receiving_Name__c = 'test',
                                                                  Region__c = 'North America - Canada',Customer__c = acclist[0].id);
        insert testGiftCard1;
        String resbody = '{"jsonrpc": "2.0", "id": "'+testGiftCard1.Name+'", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        testGiftCard1.IsApproved__c = true;
        update testGiftCard1;
        System.enqueueJob(new GWGGiftCardCalloutQueuable(resbody, testGiftCard1));
        Test.stopTest();
        System.assertEquals(true, testGiftCard1.IsApproved__c);
    }
   }
   public static testMethod void CalloutUnsuccessful() {
        User usr = [SELECT id FROM User WHERE Profile.Name  ='System Administrator' AND isActive = TRUE LIMIT 1];
        list<Account> acclist = [SELECT id FROM Account LIMIT 2];
        System.runAs(usr){
        Test.startTest();
        // Create test data
        GWG_Gift_Card__c testGiftCard1 = new GWG_Gift_Card__c( Business_Unit__c = 'Retail', Channel__c = 'Chat',Reason__c = 'Other',
                                                                  GWG_Country__c = 'Canada', GC_Language__c = 'en_US',Currency__c = 'CAD',
                                                                  E_cert_delivery_Method__c = 'Email', Email__c = 'test011@gmail.com',
                                                                  Entry_Greeting_From__c  = 'Canada Goose',Entry_Greeting_To__c = 'test',
                                                                  Gift_Card_Value__c = 100, Item_Quantity__c = 1, Line_Number__c = '1',
                                                                  Receiving_Email__c = 'test011@gmail.com',Receiving_Name__c = 'test',
                                                                  Region__c = 'North America - Canada',Customer__c = acclist[0].id);
        insert testGiftCard1;
        String resbody = '{"jsonrpc": "2.0", "id": "'+testGiftCard1.Name+'", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetBadRequest(resbody)));
        testGiftCard1.IsApproved__c = true;
        update testGiftCard1;
        System.enqueueJob(new GWGGiftCardCalloutQueuable(resbody, testGiftCard1));
        Test.stopTest();
        System.assertEquals(true, testGiftCard1.IsApproved__c);
    }
   }
}