/*******************************************************************************************************************************
 * @Name         RestWebServiceToInsertPersonAccountTest
 * @Author       Venkata Kalyan
 * @Date         26/06/2023
 * @Description  Test class for RestWebServiceToInsertPersonAccount
 *******************************************************************************************************************************
 * Version      Developer                Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan        26/06/2023   Initial Creation
 ********************************************************************************************************************************/
 @IsTest
public class RestWebServiceToInsertPersonAccountTest {
	 @testSetup
    public static void createTestSetupData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(
            LastName = 'Test',
            FirstName = 'int01',
            Alias = 'int01',
            Email = 'int.test1@canadagoose.com',
            Username = 'testint01.test1@canadagoose.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );

        insert usr;
        
        Account acc= new Account(
          RecordTypeID= System.Label.personRecordTypeId,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='int.test11@canadagoose.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
        
        insert acc;
        
    }
    
    @IsTest
    static void testIsSuccess() {
        user usr = [SELECT id FROM USER WHERE EMAIL ='int.test1@canadagoose.com' LIMIT 1];
        List<Account> accList = [SELECT FirstName, LastName, recordtypeId, PersonEmail, PersonMobilePhone,
                                 	ShippingStreet, ShippingCity,ShippingState, ShippingPostalCode, ShippingCountryCode, CreatedDate FROM Account LIMIT 2 ];
        String msg = generateJson();
         System.debug('>>>> msg>>>'+msg);
        Test.startTest();
			RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        	req.requestURI = '/services/apexrest/restWebServiceToInsertPersonAccount/'; 
        	req.httpMethod = 'Post';
        	req.addHeader('Content-Type', 'application/json'); 
        	req.requestBody = Blob.valueof(msg);
        	RestContext.request = req;
        	RestContext.response = res; 
        system.runAs(usr){
            Test.setMock(HttpCalloutMock.class, new RestWebServiceToInsertAccMock(msg, 'Success'));
			RestWebServiceToInsertPersonAccount.doPost();
        	}
       
       Test.stopTest();

	}
    
     @IsTest
    static void testIsFailure() {
        user usr = [SELECT id FROM USER WHERE EMAIL ='int.test1@canadagoose.com' LIMIT 1];
        List<Account> accList = [SELECT FirstName, LastName, recordtypeId, PersonEmail, PersonMobilePhone,
                                 	ShippingStreet, ShippingCity,ShippingState, ShippingPostalCode, ShippingCountryCode, CreatedDate FROM Account LIMIT 2 ];
        String msg = generateJson();
         System.debug('>>>> msg>>>'+msg);
        Test.startTest();
			RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        	req.requestURI = '/services/apexrest/restWebServiceToInsertPersonAccount/'; 
        	req.httpMethod = 'Post';
        	req.addHeader('Content-Type', 'application/json'); 
        	req.requestBody = Blob.valueof(msg);
        	RestContext.request = req;
        	RestContext.response = res; 
        system.runAs(usr){
            Test.setMock(HttpCalloutMock.class, new RestWebServiceToInsertAccMock(msg,'Failure'));
			RestWebServiceToInsertPersonAccount.doPost();
        	}
       
       Test.stopTest();

	}
    
    
    @IsTest
    static void testIsprocessJSON() {
        user usr = [SELECT id FROM USER WHERE EMAIL ='int.test1@canadagoose.com' LIMIT 1];
        List<Account> accList = [SELECT FirstName, LastName, recordtypeId, PersonEmail, PersonMobilePhone,
                                 	ShippingStreet, ShippingCity,ShippingState, ShippingPostalCode, ShippingCountryCode, CreatedDate FROM Account LIMIT 2 ];
        String msg = generateJson();
        System.debug('>>>> msg>>>'+msg);
        Test.startTest();
        	RestRequest req = new RestRequest(); 
        	RestResponse res = new RestResponse();
        	req.requestURI = '/services/apexrest/restWebServiceToInsertPersonAccount/'; 
        	req.httpMethod = 'Post';
        	req.requestBody = Blob.valueof(msg);
        	RestContext.request = req;
        	RestContext.response = res; 
			RestWebServiceToInsertPersonAccount.processJSON(msg);
        	Test.setMock(HttpCalloutMock.class, new RestWebServiceToInsertAccMock(msg, 'Success'));
		Test.stopTest();
	}
    
    public static string generateJson(){
        String msg ='';
        string testDate = String.ValueOf(Date.today());
        testDate = testDate.replace('-','/');
        msg = '['; //  
        msg = msg + '{ "FirstName" : "Test", "LastName" : "User", "recordtypeId" : "'+ System.Label.personRecordTypeId +'", "PersonEmail" : "int.test11@canadagoose.com",';
        msg = msg +'"Language":"en_US", "PersonMobilePhone" : "234234234", "ShippingStreet" : "tyrytwr", "ShippingCity" : "Toronto", ';
        msg = msg +'"ShippingState" : "NY", "ShippingPostalCode": "11", ';
        msg = msg +'"ShippingCountryCode" : "US", "B2C_Gender_ID" : "0", "CreatedDate" : "2023-07-27T12:24:00"'; //+testDate;//"2023/08/26 3:27 pm"'; // 10/30/2016 3:27 pm
        msg = msg +', "Origin" : "Generations", "Marketing_Subscription_Source" : "Generations",';
        msg = msg +'"Marketing_Source_Location" : "Generations" , "Marketing_Consent_Status" : "express"}, ';
        msg = msg + '{"FirstName" : "Test", "LastName" : "User", "recordtypeId" : "'+ System.Label.personRecordTypeId +'", "PersonEmail" : "test2342341@test.com",';
        msg = msg +'"Language" : "en_US", "PersonMobilePhone" : "2342342343", "ShippingStreet" : "tyrytwr", "ShippingCity" : "Toronto", ';
        msg = msg +'"ShippingState" : "NY", "ShippingPostalCode": "11", ';
        msg = msg +'"ShippingCountryCode" : "CA", "B2C_Gender_ID" : "0", "CreatedDate" : "2023-07-27T12:24:00"';//+testDate;//"2023/08/26 3:27 pm"';
        msg = msg +', "Origin" : "Generations", "Marketing_Subscription_Source" : "Generations",';
        msg = msg +'"Marketing_Source_Location" : "Generations" , "Marketing_Consent_Status" : "express"}';
        msg = msg + ']';
        System.debug('jsonData-' + msg);
        return msg;
    }                           
        
}