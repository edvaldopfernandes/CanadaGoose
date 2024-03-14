/**
* ============================================
* Name: PayLinkResponseParser_Test
* Description: Test class of PayLinkResponseParser
 
* Author :- Venkat Kalyan
* Date   :- 29-09-2022
* ============================================
* */
@IsTest
public class PayLinkResponseParser_Test {
	
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"amount\": {'+
		'        \"currency\": \"CAD\",'+
		'        \"value\": 22'+
		'    },'+
		'    \"countryCode\": \"CA\",'+
		'    \"description\": \"Test Payment\",'+
		'    \"expiresAt\": \"2022-09-30T10:53:46Z\",'+
		'    \"merchantAccount\": \"CanadaGooseCA\",'+
		'    \"reference\": \"001929501\",'+
		'    \"reusable\": false,'+
		'    \"shopperLocale\": \"en-CA\",'+
		'    \"shopperReference\": \"001929501\",'+
		'    \"id\": \"PLCB8B9A1B19762FEC\",'+
		'    \"status\": \"active\",'+
		'    \"url\": \"https://test.adyen.link/PLCB8B9A1B19762FEC\"'+
		'}';
		PayLinkResponseParser r = PayLinkResponseParser.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PayLinkResponseParser.Amount objAmount = new PayLinkResponseParser.Amount(System.JSON.createParser(json));
		System.assert(objAmount != null);
		System.assert(objAmount.currency_Z == null);
		System.assert(objAmount.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		PayLinkResponseParser objPayLinkResponseParser = new PayLinkResponseParser(System.JSON.createParser(json));
		System.assert(objPayLinkResponseParser != null);
		System.assert(objPayLinkResponseParser.amount == null);
		System.assert(objPayLinkResponseParser.countryCode == null);
		System.assert(objPayLinkResponseParser.description == null);
		System.assert(objPayLinkResponseParser.expiresAt == null);
		System.assert(objPayLinkResponseParser.merchantAccount == null);
		System.assert(objPayLinkResponseParser.reference == null);
		System.assert(objPayLinkResponseParser.reusable == null);
		System.assert(objPayLinkResponseParser.shopperLocale == null);
		System.assert(objPayLinkResponseParser.shopperReference == null);
		System.assert(objPayLinkResponseParser.id == null);
		System.assert(objPayLinkResponseParser.status == null);
		System.assert(objPayLinkResponseParser.url == null);
	}
}