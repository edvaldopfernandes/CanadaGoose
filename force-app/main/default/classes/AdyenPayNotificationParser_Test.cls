/*******************************************************************************************************************************
 * @Name         AdyenPayNotificationParser_Test
 * @Author       Venkata Kalyan
 * @Date         05/10/2022
 * @Description  Test class of the AdyenPayNotificationParser
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    05/10/2022   Initial Creation
 
 ********************************************************************************************************************************/


@IsTest
public class AdyenPayNotificationParser_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
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
		'				\"recurring.shopperReference\":\"500DR000007j9bZYAQ\"'+
		'			},'+
		'			\"amount\": {'+
		'				\"currency\":\"CAD\",'+
		'				\"value\":2260'+
		'				},'+
		'				\"eventCode\":\"AUTHORISATION\",'+
		'				\"eventDate\":\"2022-10-04T18:38:34+02:00\",'+
		'				\"merchantAccountCode\":\"CanadaGooseCA_SFSC\",'+
		'				\"merchantReference\":\"500DR000007j9bZYAQ-20221004163640\",'+
		'				\"operations\":[\"CANCEL\",\"CAPTURE\",\"REFUND\"],'+
		'				\"paymentMethod\":\"mc\",'+
		'				\"pspReference\":\"FLDC6RLCKGNG5S82\",'+
		'				\"reason\":\"085308:0007:03\\/2030\",'+
		'				\"success\":\"true\"'+
		'		}'+
		'	    }'+
		'	  ]'+
		'    }';
		AdyenPayNotificationParser r = AdyenPayNotificationParser.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AdyenPayNotificationParser.AdditionalData objAdditionalData = new AdyenPayNotificationParser.AdditionalData(System.JSON.createParser(json));
		System.assert(objAdditionalData != null);
		System.assert(objAdditionalData.authCode == null);
		System.assert(objAdditionalData.paymentLinkId == null);
		System.assert(objAdditionalData.cardHolderName == null);
		System.assert(objAdditionalData.cardSummary == null);
		System.assert(objAdditionalData.shopperCountry == null);
		System.assert(objAdditionalData.threeDOfferedResponse == null);
		System.assert(objAdditionalData.eci == null);
		System.assert(objAdditionalData.checkout_cardAddedBrand == null);
		System.assert(objAdditionalData.threeDSVersion == null);
		System.assert(objAdditionalData.authorisedAmountValue == null);
		System.assert(objAdditionalData.issuerCountry == null);
		System.assert(objAdditionalData.expiryDate == null);
		System.assert(objAdditionalData.cavv == null);
		System.assert(objAdditionalData.xid == null);
		System.assert(objAdditionalData.authorisedAmountCurrency == null);
		System.assert(objAdditionalData.threeDAuthenticatedResponse == null);
		System.assert(objAdditionalData.cavvAlgorithm == null);
		System.assert(objAdditionalData.cardBin == null);
		System.assert(objAdditionalData.recurring_recurringDetailReference == null);
		System.assert(objAdditionalData.threeds2_cardEnrolled == null);
		System.assert(objAdditionalData.recurringProcessingModel == null);
		System.assert(objAdditionalData.paymentMethod == null);
		System.assert(objAdditionalData.recurring_shopperReference == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AdyenPayNotificationParser.NotificationRequestItem objNotificationRequestItem = new AdyenPayNotificationParser.NotificationRequestItem(System.JSON.createParser(json));
		System.assert(objNotificationRequestItem != null);
		System.assert(objNotificationRequestItem.additionalData == null);
		System.assert(objNotificationRequestItem.amount == null);
		System.assert(objNotificationRequestItem.eventCode == null);
		System.assert(objNotificationRequestItem.eventDate == null);
		System.assert(objNotificationRequestItem.merchantAccountCode == null);
		System.assert(objNotificationRequestItem.merchantReference == null);
		System.assert(objNotificationRequestItem.operations == null);
		System.assert(objNotificationRequestItem.paymentMethod == null);
		System.assert(objNotificationRequestItem.pspReference == null);
		System.assert(objNotificationRequestItem.reason == null);
		System.assert(objNotificationRequestItem.success == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AdyenPayNotificationParser.Amount objAmount = new AdyenPayNotificationParser.Amount(System.JSON.createParser(json));
		System.assert(objAmount != null);
		System.assert(objAmount.currency_Z == null);
		System.assert(objAmount.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AdyenPayNotificationParser.NotificationItems objNotificationItems = new AdyenPayNotificationParser.NotificationItems(System.JSON.createParser(json));
		System.assert(objNotificationItems != null);
		System.assert(objNotificationItems.NotificationRequestItem == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AdyenPayNotificationParser objAdyenPayNotificationParser = new AdyenPayNotificationParser(System.JSON.createParser(json));
		System.assert(objAdyenPayNotificationParser != null);
		System.assert(objAdyenPayNotificationParser.live == null);
		System.assert(objAdyenPayNotificationParser.notificationItems == null);
	}
}