/*******************************************************************************************************************************
 * @Name         PersonAccountJSONParser
 * @Author       Venkata Kalyan
 * @Date         26/06/2023
 * @Description  Parser to RestWebServiceToInsertPersonAccount
 *******************************************************************************************************************************
 * Version      Developer                Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan        26/06/2023   Initial Creation
 ********************************************************************************************************************************/

public class PersonAccountJSONParser {

	public String FirstName;
	public String LastName;
	public String recordtypeId;
	public String PersonEmail;
	public String Language;
	public Long PersonMobilePhone;
	public String ShippingStreet;
	public String ShippingCity;
	public String ShippingState;
	public String ShippingPostalCode;
	public String ShippingCountryCode;
    //public String MarketingCountryCode;
	public Integer B2C_GenderID;
    public String CreatedDate;
	public String Marketing_Consent_Date;
	public String Origin;
	public String Marketing_Subscription_Source;
	public String Marketing_Source_Location;
	public String Marketing_Consent_Status;

	
	public static List<PersonAccountJSONParser> parse(String json) {
		return (List<PersonAccountJSONParser>) System.JSON.deserialize(json, List<PersonAccountJSONParser>.class);
	}
}