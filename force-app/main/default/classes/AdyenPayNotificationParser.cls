/*******************************************************************************************************************************
 * @Name         AdyenPayNotificationParser
 * @Author       Venkata Kalyan
 * @Date         05/10/2022
 * @Description  Apex class to parse the AdyenPayNotifications
 *******************************************************************************************************************************
 * Version    Developer                  Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan    05/10/2022   Initial Creation
 * Test Class - AdyenPayNotificationParser_Test
 
 ********************************************************************************************************************************/
public class AdyenPayNotificationParser {

	public class AdditionalData {
		public String authCode {get;set;} 
		public String paymentLinkId {get;set;} 
		public String cardHolderName {get;set;} 
		public String cardSummary {get;set;} 
		public String shopperCountry {get;set;} 
		public String threeDOfferedResponse {get;set;} 
		public String eci {get;set;} 
		public String checkout_cardAddedBrand {get;set;} // in json: checkout.cardAddedBrand
		public String threeDSVersion {get;set;} 
		public String authorisedAmountValue {get;set;} 
		public String issuerCountry {get;set;} 
		public String expiryDate {get;set;} 
		public String cavv {get;set;} 
		public String xid {get;set;} 
		public String authorisedAmountCurrency {get;set;} 
		public String threeDAuthenticatedResponse {get;set;} 
		public String cavvAlgorithm {get;set;} 
		public String cardBin {get;set;} 
		public String recurring_recurringDetailReference {get;set;} // in json: recurring.recurringDetailReference
		public String threeds2_cardEnrolled {get;set;} // in json: threeds2.cardEnrolled
		public String recurringProcessingModel {get;set;} 
		public String paymentMethod {get;set;} 
		public String recurring_shopperReference {get;set;} // in json: recurring.shopperReference

		public AdditionalData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'authCode') {
							authCode = parser.getText();
						} else if (text == 'paymentLinkId') {
							paymentLinkId = parser.getText();
						} else if (text == 'cardHolderName') {
							cardHolderName = parser.getText();
						} else if (text == 'cardSummary') {
							cardSummary = parser.getText();
						} else if (text == 'shopperCountry') {
							shopperCountry = parser.getText();
						} else if (text == 'threeDOfferedResponse') {
							threeDOfferedResponse = parser.getText();
						} else if (text == 'eci') {
							eci = parser.getText();
						} else if (text == 'checkout.cardAddedBrand') {
							checkout_cardAddedBrand = parser.getText();
						} else if (text == 'threeDSVersion') {
							threeDSVersion = parser.getText();
						} else if (text == 'authorisedAmountValue') {
							authorisedAmountValue = parser.getText();
						} else if (text == 'issuerCountry') {
							issuerCountry = parser.getText();
						} else if (text == 'expiryDate') {
							expiryDate = parser.getText();
						} else if (text == 'cavv') {
							cavv = parser.getText();
						} else if (text == 'xid') {
							xid = parser.getText();
						} else if (text == 'authorisedAmountCurrency') {
							authorisedAmountCurrency = parser.getText();
						} else if (text == 'threeDAuthenticatedResponse') {
							threeDAuthenticatedResponse = parser.getText();
						} else if (text == 'cavvAlgorithm') {
							cavvAlgorithm = parser.getText();
						} else if (text == 'cardBin') {
							cardBin = parser.getText();
						} else if (text == 'recurring.recurringDetailReference') {
							recurring_recurringDetailReference = parser.getText();
						} else if (text == 'threeds2.cardEnrolled') {
							threeds2_cardEnrolled = parser.getText();
						} else if (text == 'recurringProcessingModel') {
							recurringProcessingModel = parser.getText();
						} else if (text == 'paymentMethod') {
							paymentMethod = parser.getText();
						} else if (text == 'recurring.shopperReference') {
							recurring_shopperReference = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AdditionalData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class NotificationRequestItem {
		public AdditionalData additionalData {get;set;} 
		public Amount amount {get;set;} 
		public String eventCode {get;set;} 
		public Datetime eventDate {get;set;} 
		public String merchantAccountCode {get;set;} 
		public String merchantReference {get;set;} 
		public List<String> operations {get;set;} 
		public String paymentMethod {get;set;} 
		public String pspReference {get;set;} 
		public String reason {get;set;} 
		public String success {get;set;} 

		public NotificationRequestItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'additionalData') {
							additionalData = new AdditionalData(parser);
						} else if (text == 'amount') {
							amount = new Amount(parser);
						} else if (text == 'eventCode') {
							eventCode = parser.getText();
						} else if (text == 'eventDate') {
							string dt = parser.getText();
                            eventDate = Datetime.valueOf(dt.replace('T',' '));
						} else if (text == 'merchantAccountCode') {
							merchantAccountCode = parser.getText();
						} else if (text == 'merchantReference') {
							merchantReference = parser.getText();
						} else if (text == 'operations') {
							operations = arrayOfString(parser);
						} else if (text == 'paymentMethod') {
							paymentMethod = parser.getText();
						} else if (text == 'pspReference') {
							pspReference = parser.getText();
						} else if (text == 'reason') {
							reason = parser.getText();
						} else if (text == 'success') {
							success = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'NotificationRequestItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Amount {
		public String currency_Z {get;set;} // in json: currency
		public Integer value {get;set;} 

		public Amount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currency_Z = parser.getText();
						} else if (text == 'value') {
							value = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Amount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class NotificationItems {
		public NotificationRequestItem NotificationRequestItem {get;set;} 

		public NotificationItems(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'NotificationRequestItem') {
							NotificationRequestItem = new NotificationRequestItem(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'NotificationItems consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String live {get;set;} 
	public List<NotificationItems> notificationItems {get;set;} 

	public AdyenPayNotificationParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'live') {
						live = parser.getText();
					} else if (text == 'notificationItems') {
						notificationItems = arrayOfNotificationItems(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'AdyenPayNotificationParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static AdyenPayNotificationParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new AdyenPayNotificationParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	




    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }




    private static List<NotificationItems> arrayOfNotificationItems(System.JSONParser p) {
        List<NotificationItems> res = new List<NotificationItems>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new NotificationItems(p));
        }
        return res;
    }



}