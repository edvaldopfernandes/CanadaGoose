public class ContactSearchController {
	@AuraEnabled(cacheable=true)
    
    public static List<contact> searchByEmail(String email) {
        if (String.isBlank(email)) {
            return new List<contact>();
        }
        String searchQuery = '%' + email + '%';
        return [SELECT Id, Name, Email FROM contact WHERE Email LIKE :searchQuery LIMIT 10];
    
	}
    @AuraEnabled()
    public static string createAccount(String email, String firstName, String lastName, String mobile, string language, Boolean consent, 
                                       string street, string city, string state, string country, string postalcode, boolean shippingAdd,
                                       string shipstreet, string shipcity, string shipstate, string shipcountry, string shippostalcode) {
        try{
            Account acc;
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            if (String.isNotBlank(email) && String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(mobile)) {
              acc = new Account(FirstName = firstName, LastName = lastName, PersonEmail = email, PersonMobilePhone = mobile, Language__c = language, 
                                B2C_Add_To_Email_List__pc = consent, PersonMailingStreet = street,
                                PersonMailingCity = city, PersonMailingState = state, PersonMailingCountry = country, 
                                PersonMailingPostalCode = postalcode, recordTypeId = personAccountRTId);
                
                if(consent == true){
                         acc.Marketing_Consent_Status__pc = 'express';
                         acc.Marketing_Subscription_Source__pc = 'retailer';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
               }
                if(consent == false){
                         acc.Marketing_Consent_Status__pc = 'unconsented';
                         acc.Marketing_Subscription_Source__pc = 'retailer';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
               }
                if(shippingAdd == true){
                      	 acc.ShippingStreet = street;
                      	 acc.ShippingCity = city;
                      	 acc.ShippingState = state;
                      	 acc.ShippingCountry = country;
                      	 acc.ShippingPostalCode = postalcode;
                }
                if(shippingAdd == false){
                      	 acc.ShippingStreet = shipstreet;
                      	 acc.ShippingCity = shipcity;
                      	 acc.ShippingState = shipstate;
                      	 acc.ShippingCountry = shipcountry;
                      	 acc.ShippingPostalCode = shippostalcode;
                }

                insert acc;
            }  
            
            return acc.id;
        } Catch(Exception ex){
            return ex.getMessage();
        }
	}
}