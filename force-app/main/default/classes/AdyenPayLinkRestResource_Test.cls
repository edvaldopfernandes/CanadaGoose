/*******************************************************************************************************************************
 * @Name         AdyenPayLinkRestResource_Test
 * @Author       Venkata Kalyan
 * @Date         11/10/2022
 * @Description  Test class for AdyenPayLinkRestResource
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    11/10/2022   Initial Creation
 
 ********************************************************************************************************************************/
@IsTest
public class AdyenPayLinkRestResource_Test {
    
@testSetup
    public static void createTestSetupData(){
       
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(
            LastName = 'Test',
            FirstName = 'Adyen',
            Alias = 'tadyen',
            Email = 'adyen.test1@gmail.com',
            Username = 'adyen.test1@gmail.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        User usr2 = new User(
            LastName = 'Test',
            FirstName = 'Adyen2',
            Alias = 'tAdy2',
            Email = 'adyen.test2@gmail.com',
            Username = 'adyen.test2@gmail.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );

        insert usr;
        insert usr2;

        system.runAs(usr2){
            
        Account acc = TestDataFactory.createTestAccount(false);
        acc.ShippingStreet = '123 Test';
        acc.ShippingCity = 'Brasil';
        acc.ShippingState = 'Amazonas';
        acc.ShippingStateCode = 'AM';
        acc.ShippingCountry = 'Brazil';
        acc.ShippingCountryCode = 'BR';
        acc.ShippingPostalCode = '12345';
        insert acc;
        
        Contact con = TestDataFactory.createTestContact('uUQ42StQPFfjhVvra4', acc.Id, true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac = TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);

        Test.startTest();
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Pending Payment';
        update cas;
        
        List<Invoice__c> listInvoices = [SELECT Status__c, Payment_Method__c FROM Invoice__c WHERE Case__c = :cas.Id];
        System.assertEquals(1, listInvoices.size(), 'One wire-transfer invoice must be created');
        System.assertEquals('Draft', listInvoices[0].Status__c, 'Invoice must be created in Draft state');
        System.assertEquals('wire-transfer', listInvoices[0].Payment_Method__c, 'Invoice must be created with payment method of wire-transfer');

        List<Inspection_Result__c> lstInspectionResult = [SELECT Id FROM Inspection_Result__c WHERE Invoice__c = :listInvoices[0].Id];
        System.assertEquals(1, lstInspectionResult.size(), 'Inspection result must be assigned to the new draft invoice.');
        Test.stopTest();
        
        // Mark case as paid
        cas.Payment_Made__c = true;
        update cas;

        listInvoices = [SELECT Status__c FROM Invoice__c WHERE Case__c = :cas.Id];
        System.assertEquals('Paid', listInvoices[0].Status__c, 'Invoice must be updated to Paid state');
        }
    }
    static testMethod void postMethod() {
        
        
        case c = [SELECT id FROM case  limit 1];
        List<Invoice__c> lstInvoices = [SELECT Status__c, Payment_Method__c FROM Invoice__c WHERE Case__c = :c.Id];
        user usr = [select id from user where email = 'adyen.test2@gmail.com'];
        String JSONSuccess = '{'+
		'	\"live\":\"false\",'+
		'	\"notificationItems\":['+
		'	  {'+
		'	    \"NotificationRequestItem\":{'+
		'			\"additionalData\":{'+
		'				\"authCode\":\"085308\",'+
		'				\"paymentLinkId\":\"PLBFF3B7B629981FD3\",'+
		'				\"cardHolderName\":\"Checkout Shopper PlaceHolder\",'+
		'				\"cardSummary\":\"0007\",'+
		'				\"shopperCountry\":\"CA\",'+
		'				\"threeDOfferedResponse\":\"N\",'+
		'				\"eci\":\"N\\/A\", 										\"checkout.cardAddedBrand\":\"mcstandarddebit\",'+
		'				\"threeDSVersion\":\"1.0.2\",'+
		'				\"authorisedAmountValue\":\"2260\",'+
		'				\"issuerCountry\":\"CA\",'+
		'				\"expiryDate\":\"03\\/2030\",'+
		'				\"cavv\":\"N\\/A\",'+
		'				\"xid\":\"N\\/A\",'+
		'				\"authorisedAmountCurrency\":\"CAD\",'+
		'				\"threeDAuthenticatedResponse\":\"N\\/A\",'+
		'				\"cavvAlgorithm\":\"N\\/A\", '+
		'				\"cardBin\":\"222240\", '+
		'			   	\"recurring.recurringDetailReference\":\"FPTVQJM933M84H82\",'+
		'				\"threeds2.cardEnrolled\":\"false\", '+
		'				\"recurringProcessingModel\":\"Subscription\",'+
		' 				\"paymentMethod\":\"mc\",'+
		'				\"recurring.shopperReference\":\"'+c.id+'"'+
		'			},'+
		'			\"amount\": {'+
		'				\"currency\":\"CAD\",'+
		'				\"value\":2260'+
		'				},'+
		'				\"eventCode\":\"AUTHORISATION\",'+
		'				\"eventDate\":\"2022-10-04T18:38:34+02:00\",'+
		'				\"merchantAccountCode\":\"CanadaGooseCA_SFSC\",'+
		'				\"merchantReference\":\"'+c.id+'-20221004163640\",'+
		'				\"operations\":[\"CANCEL\",\"CAPTURE\",\"REFUND\"],'+
		'				\"paymentMethod\":\"mc\",'+
		'				\"pspReference\":\"FLDC6RLCKGNG5S82\",'+
		'				\"reason\":\"085308:0007:03\\/2030\",'+
		'				\"success\":\"true\"'+
		'		}'+
		'	    }'+
		'	  ]'+
		'    }';
        
        String JSONFailure = '{'+
		'	\"live\":\"false\",'+
		'	\"notificationItems\":['+
		'	  {'+
		'	    \"NotificationRequestItem\":{'+
		'			\"additionalData\":{'+
		'				\"authCode\":\"085308\",'+
		'				\"paymentLinkId\":\"PLBFF3B7B629981FD3\",'+
		'				\"cardHolderName\":\"Checkout Shopper PlaceHolder\",'+
		'				\"cardSummary\":\"0007\",'+
		'				\"shopperCountry\":\"CA\",'+
		'				\"threeDOfferedResponse\":\"N\",'+
		'				\"eci\":\"N\\/A\", 										\"checkout.cardAddedBrand\":\"mcstandarddebit\",'+
		'				\"threeDSVersion\":\"1.0.2\",'+
		'				\"authorisedAmountValue\":\"2260\",'+
		'				\"issuerCountry\":\"CA\",'+
		'				\"expiryDate\":\"03\\/2030\",'+
		'				\"cavv\":\"N\\/A\",'+
		'				\"xid\":\"N\\/A\",'+
		'				\"authorisedAmountCurrency\":\"CAD\",'+
		'				\"threeDAuthenticatedResponse\":\"N\\/A\",'+
		'				\"cavvAlgorithm\":\"N\\/A\", '+
		'				\"cardBin\":\"222240\", '+
		'			   	\"recurring.recurringDetailReference\":\"FPTVQJM933M84H82\",'+
		'				\"threeds2.cardEnrolled\":\"false\", '+
		'				\"recurringProcessingModel\":\"Subscription\",'+
		' 				\"paymentMethod\":\"mc\",'+
		'				\"recurring.shopperReference\":\"'+c.id+'"'+
		'			},'+
		'			\"amount\": {'+
		'				\"currency\":\"CAD\",'+
		'				\"value\":2260'+
		'				},'+
		'				\"eventCode\":\"AUTHORISATION\",'+
		'				\"eventDate\":\"2022-10-04T18:38:34+02:00\",'+
		'				\"merchantAccountCode\":\"CanadaGooseCA_SFSC\",'+
		'				\"merchantReference\":\"'+c.id+'-20221004163640\",'+
		'				\"operations\":[\"CANCEL\",\"CAPTURE\",\"REFUND\"],'+
		'				\"paymentMethod\":\"mc\",'+
		'				\"pspReference\":\"FLDC6RLCKGNG5S82\",'+
		'				\"reason\":\"085308:0007:03\\/2030\",'+
		'				\"success\":\"false\"'+
		'		}'+
		'	    }'+
		'	  ]'+
		'    }';
      
        String JSONMsgNoBody = '';
        
        
        Test.startTest();
 
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/adyenNotificationResource/';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSONSuccess);
            RestContext.request = req;
            RestContext.response = res;
            System.runAs(usr) {
                AdyenPayLinkRestResource.doPost();
            }

            RestRequest req1 = new RestRequest();
            RestResponse res1 = new RestResponse();
            req1.requestURI = '/services/apexrest/adyenNotificationResource/';
            req1.httpMethod = 'POST';
            req1.requestBody = Blob.valueOf(JSONFailure);
            RestContext.request = req1;
            RestContext.response = res1;
            System.runAs(usr) {
                AdyenPayLinkRestResource.doPost();
            }
  
        Test.stopTest();
    }
}