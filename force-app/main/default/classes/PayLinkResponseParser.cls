/**
* ============================================
* Name: PayLinkResponseParser
* Description: Response parser of CreatePayLinkResponseParser 
 
* Author :- Venkat Kalyan
* Date   :- 29-09-2022
* Test Class :- PayLinkResponseParser_Test
* ============================================
* */

public class PayLinkResponseParser {

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
	
	public Amount amount {get;set;} 
	public String countryCode {get;set;} 
	public String description {get;set;} 
	public datetime expiresAt {get;set;} 
	public String merchantAccount {get;set;} 
	public String reference {get;set;} 
	public Boolean reusable {get;set;} 
	public String shopperLocale {get;set;} 
	public String shopperReference {get;set;} 
	public String id {get;set;} 
	public String status {get;set;} 
	public String url {get;set;} 

	public PayLinkResponseParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'amount') {
						amount = new Amount(parser);
					} else if (text == 'countryCode') {
						countryCode = parser.getText();
					} else if (text == 'description') {
						description = parser.getText();
					} else if (text == 'expiresAt') {
						string dt =parser.getText();
                        expiresAt = Datetime.valueOf(dt.replace('T',' '));
					} else if (text == 'merchantAccount') {
						merchantAccount = parser.getText();
					} else if (text == 'reference') {
						reference = parser.getText();
					} else if (text == 'reusable') {
						reusable = parser.getBooleanValue();
					} else if (text == 'shopperLocale') {
						shopperLocale = parser.getText();
					} else if (text == 'shopperReference') {
						shopperReference = parser.getText();
					} else if (text == 'id') {
						id = parser.getText();
					} else if (text == 'status') {
						status = parser.getText();
					} else if (text == 'url') {
						url = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'PayLinkResponseParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static PayLinkResponseParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new PayLinkResponseParser(parser);
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
	
}