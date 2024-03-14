public with sharing class UserProfileController extends LightningController {
    
    @AuraEnabled
    public static Response getUserInfo() {
        try {
            User user = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            Contact userCnt = [
                SELECT Id, 
                    AccountId, 
                    Account.Phone, 
                    Account.ShippingStreet, 
                    Account.AddressComplement__c, 
                    Account.ShippingPostalCode, 
                    Account.ShippingCity, 
                    Account.ShippingState, 
                    Account.ShippingCountry,
                    Email,
                    FirstName,
                    LastName
                FROM Contact 
                WHERE Id =:user.ContactId LIMIT 1
            ];

            ContactWrapper cnt = new ContactWrapper();
            cnt.contactId = userCnt.Id;
            cnt.accountId = userCnt.AccountId;
            cnt.firstName = userCnt.FirstName;
            cnt.lastName = userCnt.LastName;
            cnt.email = userCnt.Email;
            cnt.phone = userCnt.Account.Phone;
            cnt.street = userCnt.Account.ShippingStreet;
            cnt.complement = userCnt.Account.AddressComplement__c;
            cnt.zipCode = userCnt.Account.ShippingPostalCode;
            cnt.city = userCnt.Account.ShippingCity;
            cnt.state = userCnt.Account.ShippingState;
            cnt.country = userCnt.Account.ShippingCountry;

            return new Response(true, 'success', cnt);
        } catch(Exception e) {
            return new Response(false, e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Response updateUserInfo(ContactWrapper cntWpr) {
        try {

            Contact cnt = new Contact();
            cnt.Id = cntWpr.contactId;
            cnt.FirstName = cntWpr.firstName;
            cnt.LastName = cntWpr.lastName;
            cnt.Email = cntWpr.email;

            update cnt;
            
            Account acc = new Account();
            acc.Id = cntWpr.accountId;
            acc.Phone = cntWpr.phone;
            acc.ShippingStreet = cntWpr.street;
            acc.AddressComplement__c = cntWpr.complement;
            acc.ShippingPostalCode = cntWpr.zipCode;
            acc.ShippingCity = cntWpr.city;
            acc.ShippingState = cntWpr.state;
            acc.ShippingCountry = cntWpr.country;

            update acc;

            return new Response(true, 'success');
        } catch(Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    public class ContactWrapper {
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public Id accountId {get; set;}
        @AuraEnabled
        public String firstName {get; set;}
        @AuraEnabled
        public String lastName {get; set;}
        @AuraEnabled
        public String email {get; set;}
        @AuraEnabled
        public String phone {get; set;}
        @AuraEnabled
        public String street {get; set;}
        @AuraEnabled
        public String complement {get; set;}
        @AuraEnabled
        public String zipCode {get; set;}
        @AuraEnabled
        public String city {get; set;}
        @AuraEnabled
        public String state {get; set;}
        @AuraEnabled
        public String country {get; set;}
    }
}