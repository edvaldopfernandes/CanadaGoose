public class AccountTriggerHandler {
    // Used to avoid recursion between the account and user trigger
    public static Set<Id> setUserId = new Set<Id>();
    public static Boolean isFirstTime = true;
    
    /*
    * Function: OnBeforeInsert
    * --------------------
    * Trigger handler for the Before Insert event
    *
    *  lstNewAccounts: List of the new Account records being inserted
    *  mapNewAccounts: Map of the new Account records being inserted
    *
    *  returns: N/A
	*/
    public static void OnBeforeInsert(List<Account> lstNewAccounts, Map<Id, Account> mapNewAccounts) {
        Map<String, Country_Setting__mdt> mapCountrySetting = Utilities.GetCountrySettings();
        
        for (Account acc : lstNewAccounts) {
            Country_Setting__mdt countrySetting = (mapCountrySetting.containsKey(acc.ShippingCountryCode)) ? mapCountrySetting.get(acc.ShippingCountryCode) : mapCountrySetting.get(Utilities.DEFAULT_COUNTRY_CODE);
                    
            if (countrySetting != null) {
                acc.Region__c = countrySetting.Region__c;
                acc.Currency__c = countrySetting.Currency__c;
                acc.Locale__c = countrySetting.Locale_English__c;
                acc.Payment_Method__c = countrySetting.Payment_Method__c;
            }
            
             	acc.B2C_CustomerList__pc = System.label.CustomerListId;
             	acc.B2C_CustomerList_ID__pc = 'CanadaGooseCA';
            
            if(acc.Marketing_Consent_Status__pc == 'Implied'){
             	acc.Implied_timestamp__c = datetime.now();
            }
        }
    }
    /*
    * Function: OnAfterInsert
    */
    
    
    /*
    * Function: OnBeforeUpdate 
    * --------------------
    * Trigger handler for the Before Update event
    *
    *  lstNewAccounts: List of the new Account records being updated
    *  mapNewAccounts: Map of the new Account records being updated
    *  lstOldAccounts: List of the old Account records being updated
    *  mapOldAccounts: Map of the old Account records being updated
    *
    *  returns: N/A
	*/
    public static void OnBeforeUpdate(List<Account> lstNewAccounts, Map<Id, Account> mapNewAccounts, List<Account> lstOldAccounts, Map<Id, Account> mapOldAccounts) {
        Map<String, Country_Setting__mdt> mapCountrySetting = Utilities.GetCountrySettings();
        Set<Id> setContactIdToEnable = new Set<Id>();
			System.debug('In OnBeforeUpdate>>>>>');
        for (Account acc : lstNewAccounts) {
            Account oldAcc = mapOldAccounts.get(acc.Id);
         
            //To update Unsubscribed based on the data from SFMC
            if(acc.PersonHasOptedOutOfEmail != oldAcc.PersonHasOptedOutOfEmail && acc.PersonHasOptedOutOfEmail == true){
                acc.B2C_Add_To_Email_List__pc = false;
                acc.Marketing_Consent_Status__pc = 'Unsubscribed';
                acc.Marketing_Consent_Date__pc = datetime.now();
             }
            //To update data if the status is implied
            if(acc.Marketing_Consent_Status__pc != oldAcc.Marketing_Consent_Status__pc && acc.Marketing_Consent_Status__pc == 'Implied'){
             	acc.Implied_timestamp__c = datetime.now();
             }
            // Only assign region when the Shipping Country has changed
            if (acc.ShippingCountryCode != oldAcc.ShippingCountryCode) {
                Country_Setting__mdt countrySetting = (mapCountrySetting.containsKey(acc.ShippingCountryCode)) ? mapCountrySetting.get(acc.ShippingCountryCode) : mapCountrySetting.get(Utilities.DEFAULT_COUNTRY_CODE);
                    
                if (countrySetting != null) {
                    acc.Region__c = countrySetting.Region__c;
                    acc.Currency__c = countrySetting.Currency__c;
                    acc.Payment_Method__c = countrySetting.Payment_Method__c;

                    // Determine if the language is supported in the new Country
                    if (acc.Language__c == 'fr' && String.isNotBlank(countrySetting.Locale_French__c)) {
                        acc.Locale__c = countrySetting.Locale_French__c;
                    }
                    else if (acc.Language__c == 'de' && String.isNotBlank(countrySetting.Locale_German__c)) {
                        acc.Locale__c = countrySetting.Locale_German__c;
                    }
                    else if (acc.Language__c == 'zh_CN' && String.isNotBlank(countrySetting.Locale_Chinese__c)) {
                        acc.Locale__c = countrySetting.Locale_Chinese__c;
                    }
                    else if (acc.Language__c == 'it' && String.isNotBlank(countrySetting.Locale_Italian__c)) {
                        acc.Locale__c = countrySetting.Locale_Italian__c;
                    }
                    else {
                        if (String.isNotBlank(countrySetting.Locale_English__c))
                            acc.Locale__c = countrySetting.Locale_English__c;
                        acc.Language__c = 'en_US';
                    }    
                }
            } 
            
           // subscription source Code start --
            User_Ids__c ids = User_Ids__c.getOrgDefaults();
        	Profile currentProfile = new Profile ();
            User createdUser = new User();
            createdUser = [SELECT id, ProfileId FROM User WHERE id =:acc.CreatedById LIMIT 1];
            System.debug('<<createdUser11>>'+createdUser);
            if(createdUser.id != ids.Automated_Process__c){
        		currentProfile = [SELECT id, Name FROM Profile WHERE id =:createdUser.ProfileId LIMIT 1];
            }
            System.debug('<<currentProfile>>'+currentProfile);
            if(acc.Marketing_Consent_Status__pc == null ){
                if(System.UserInfo.getUserId() == ids.Automated_Process__c){
                         acc.Marketing_Consent_Status__pc = 'unconsented';
                         acc.Marketing_Subscription_Source__pc = 'Live Chat';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
                }
                if(System.UserInfo.getUserId() == ids.Warranty_Site_User__c ){
                         acc.Marketing_Consent_Status__pc = 'unconsented';
                         acc.Marketing_Subscription_Source__pc = 'Warranty';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
                }
                if(currentProfile != null && currentProfile.Name == 'Warranty CSR-Tier2 User' || currentProfile.Name == 'System Administrator' || currentProfile.Name =='Flagship Store' ){
                    	 acc.Marketing_Consent_Status__pc = 'unconsented';
                         acc.Marketing_Subscription_Source__pc = 'CSR';
                         acc.Marketing_Source_Location__pc = 'SFSC';
                         acc.Origin__pc = 'Service Portal';
                }
            }
            // subscription source Code start end

            // Verify which contacts need to enable the community user
            if (acc.IsPersonAccount && acc.Enable_Community_User__pc && !oldAcc.Enable_Community_User__pc) {
                setContactIdToEnable.add(acc.PersonContactId);
            }
        }

        if (!setContactIdToEnable.isEmpty()) {
            // Retrieve list of existing users to validate if user already exists
            Set<Id> setContactIdWithExistUser = new Set<Id>();

            for (User usr : [SELECT ContactId
                            FROM User
                            WHERE IsActive = true
                                AND ContactId IN :setContactIdToEnable]) {
                setContactIdWithExistUser.add(usr.ContactId);
            }

            // Check if there are contacts to enable
            if (setContactIdToEnable.size() != setContactIdWithExistUser.size()) {
                Id recTypeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
                Id recTypeRetailer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
                Id recTypeCSR = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CSR').getRecordTypeId();

                List<User> lstUsersToCreate = new List<User>();
                Map<String, Id> mapProfileNameToId = new Map<String, Id>();

                // Build a list of available community profiles
                for (Profile prof : [SELECT Id, Name
                                    FROM Profile
                                    WHERE UserType IN ('PowerCustomerSuccess', 'CSPLitePortal')]) {
                    mapProfileNameToId.put(prof.Name, prof.Id);
                }

                // Now start doing final list of validations before enabling the community user
                for (Account acc : lstNewAccounts) {
                    if (setContactIdToEnable.contains(acc.PersonContactId)) {
                        if (setContactIdWithExistUser.contains(acc.PersonContactId)) {
                            acc.addError('Cannot create a user as community user already exists and is active.');
                        }
                        else {
                            Id ProfileId;
                            
                            if (acc.RecordTypeId == recTypeCustomer)
                                ProfileId = mapProfileNameToId.get('Warranty Customer Community User');
                            
                            if (ProfileId == null)
                                acc.addError('Account\'s record type is not supported by this flow. Please contact your system administrator.');
                            else {
                                String randomString = String.valueOf(integer.valueOf(Math.random() * 10000000));

                                lstUsersToCreate.add(new User (
                                    Email = acc.PersonEmail
                                    , Username = acc.PersonEmail
                                    , FirstName = acc.FirstName
                                    , LastName = acc.LastName
                                    , Alias = acc.FirstName.left(1) + acc.LastName.left(3) + randomString.left(4)
                                    , CommunityNickName = (acc.FirstName + '.' + acc.LastName).toLowerCase() + randomString
                                    , MobilePhone = acc.PersonMobilePhone
                                    , Phone = acc.PersonHomePhone
                                    , Street = acc.ShippingStreet
                                    , City = acc.ShippingCity
                                    , PostalCode = acc.ShippingPostalCode
                                    , State = acc.ShippingState
                                    , StateCode = acc.ShippingStateCode
                                    , Country = acc.ShippingCountry
                                    , CountryCode = acc.ShippingCountryCode
                                    , ProfileId = ProfileId
                                    , ContactId = acc.PersonContactId
                                    , LocaleSidKey = acc.Locale__c
                                    , LanguageLocaleKey = acc.Language__c
                                    , EmailEncodingKey = 'ISO-8859-1'
                                    , TimeZoneSidKey = 'America/New_York'
                                ));
                            }
                        }
                    }
                }

                if (!lstUsersToCreate.isEmpty()) {
                    insert lstUsersToCreate;
                }
            }
        }
    }
    
    /*
    * Function: OnAfterUpdate 
    * --------------------
    * Trigger handler for the After Update event
    *
    *  lstNewAccounts: List of the new Account records being updated
    *  mapNewAccounts: Map of the new Account records being updated
    *  lstOldAccounts: List of the old Account records being updated
    *  mapOldAccounts: Map of the old Account records being updated
    *
    *  returns: N/A
	*/
    public static void OnAfterUpdate(List<Account> lstNewAccounts, Map<Id, Account> mapNewAccounts, List<Account> lstOldAccounts, Map<Id, Account> mapOldAccounts) {
        Set<Id> setCommunityAccountIds = new Set<Id>();
        Set<Id> setCommunityPersonAccountIds = new Set<Id>();

        for (Account acc : lstNewAccounts) {
            // First check for recursion before processing the record
            if (UserTriggerHandler.setUserAccountId.contains(acc.Id)) {
                UserTriggerHandler.setUserAccountId.remove(acc.Id);
            }
            // If no recursion, then process the record
            else {
                Account oldAcc = mapOldAccounts.get(acc.Id);

                if (acc.IsPersonAccount) {
                    // Only sync when selected Account info have changed
                    if (acc.ShippingStreet != oldAcc.ShippingStreet
                        || acc.ShippingCity != oldAcc.ShippingCity
                        || acc.ShippingState != oldAcc.ShippingState
                        || acc.ShippingStateCode != oldAcc.ShippingStateCode
                        || acc.ShippingPostalCode != oldAcc.ShippingPostalCode
                        || acc.ShippingCountry != oldAcc.ShippingCountry
                        || acc.ShippingCountryCode != oldAcc.ShippingCountryCode
                        || acc.PersonHomePhone != oldAcc.PersonHomePhone
                        || acc.PersonMobilePhone != oldAcc.PersonMobilePhone
                        || acc.FirstName != oldAcc.FirstName
                        || acc.LastName != oldAcc.LastName
                        || acc.PersonEmail != oldAcc.PersonEmail
                       ) {
                            setCommunityPersonAccountIds.add(acc.Id);
                        }
                }
                else {
                    // Only sync when selected Account info have changed
                    if (acc.ShippingStreet != oldAcc.ShippingStreet
                        || acc.ShippingCity != oldAcc.ShippingCity
                        || acc.ShippingState != oldAcc.ShippingState
                        || acc.ShippingStateCode != oldAcc.ShippingStateCode
                        || acc.ShippingPostalCode != oldAcc.ShippingPostalCode
                        || acc.ShippingCountry != oldAcc.ShippingCountry
                        || acc.ShippingCountryCode != oldAcc.ShippingCountryCode) {
                            setCommunityAccountIds.add(acc.Id);
                        }
                }
            }
        }

        if (!setCommunityPersonAccountIds.isEmpty()) {
            // Retrieve list of users to be synchronized
            List<User> lstCommunityUsers = new List<user>();
            for(User usr : [SELECT AccountId, FirstName, LastName, Email, Phone, 
                            MobilePhone, Street, City, PostalCode, State, StateCode, Country, CountryCode
                			FROM User
                            WHERE AccountId IN :setCommunityPersonAccountIds]){
              lstCommunityUsers.add(usr) ;                
          }
            /*List<User> lstCommunityUsers = [
                SELECT AccountId, FirstName, LastName, Email, Phone, MobilePhone
                	, Street, City, PostalCode, State, StateCode, Country, CountryCode
                FROM User
                WHERE AccountId IN :setCommunityPersonAccountIds
            ];*/

            if (!lstCommunityUsers.isEmpty()) {
                Map<Id, User> mapAccountIdToUser = new Map<Id, User>();
                List<Id> lstCommunityPersonUsersIdToUpdate = new List<Id>();
                
                for (User usr : lstCommunityUsers) {
                    mapAccountIdToUser.put(usr.AccountId, usr);
                }

                for (Account acc : lstNewAccounts) {
                    if (setCommunityPersonAccountIds.contains(acc.Id)) {
                        User usr = mapAccountIdToUser.get(acc.Id);

                        if (usr.Street != acc.ShippingStreet
                            || usr.City != acc.ShippingCity
                            || usr.State != acc.ShippingState
                            || usr.StateCode != acc.ShippingStateCode
                            || usr.PostalCode != acc.ShippingPostalCode
                            || usr.Country != acc.ShippingCountry
                            || usr.CountryCode != acc.ShippingCountryCode
                            || usr.Phone != acc.PersonHomePhone
                            || usr.MobilePhone != acc.PersonMobilePhone
                            || usr.FirstName != acc.FirstName
                            || usr.LastName != acc.LastName
                            || usr.Email != acc.PersonEmail
                           ) {
                               lstCommunityPersonUsersIdToUpdate.add(usr.Id);
                           }
                    }
                }

                // Sync users
                if (!lstCommunityPersonUsersIdToUpdate.isEmpty()) {
                    SyncCommunityPersonUsers(lstCommunityPersonUsersIdToUpdate);
                }
            }
        }
        
        if (!setCommunityAccountIds.isEmpty()) {
            // Retrieve list of users to be synchronized
            List<User> lstCommunityUsers = [
                SELECT AccountId, Phone, Street, City, PostalCode, State, StateCode, Country, CountryCode
                FROM User
                WHERE AccountId IN :setCommunityAccountIds
            ];
            
            if (!lstCommunityUsers.isEmpty()) {
                Map<Id, User> mapAccountIdToUser = new Map<Id, User>();
                List<Id> lstCommunityUsersIdToUpdate = new List<Id>();
                
                for (User usr : lstCommunityUsers) {
                    mapAccountIdToUser.put(usr.AccountId, usr);
                }
                
                for (Account acc : lstNewAccounts) {
                    if (setCommunityAccountIds.contains(acc.Id)) {
                        User usr = mapAccountIdToUser.get(acc.Id);
                        
                        if (usr.Street != acc.ShippingStreet
                            || usr.City != acc.ShippingCity
                            || usr.State != acc.ShippingState
                            || usr.StateCode != acc.ShippingStateCode
                            || usr.PostalCode != acc.ShippingPostalCode
                            || usr.Country != acc.ShippingCountry
                            || usr.CountryCode != acc.ShippingCountryCode
                            || usr.Phone != acc.Phone
                           ) {
                               lstCommunityUsersIdToUpdate.add(usr.Id);
                           }
                    }
                }
                
                // Sync users
                if (!lstCommunityUsersIdToUpdate.isEmpty()) {
                    SyncCommunityUsers(lstCommunityUsersIdToUpdate);
                }
            }
        }
    }
    
    /*
    * Function: SyncCommunityPersonUsers 
    * --------------------
    * Synchronize the User record with its corresponding Person Account record
    *
    *  lstUserId: List of User Id that requires synchronizing
    *
    *  returns: N/A
	*/
    @future
    private static void SyncCommunityPersonUsers(List<Id> lstUserId) {
        setUserId.addAll(lstUserId);

        // Retrieve list of users to be synchronized
        List<User> lstCommunityUsers = [
            SELECT FirstName, LastName, Email, Phone, MobilePhone 
            	, Street, City, State, StateCode, PostalCode, Country, CountryCode
            	, Account.FirstName, Account.LastName, Account.PersonEmail, Account.PersonHomePhone, Account.PersonMobilePhone
            	, Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode
            	, Account.ShippingState, Account.ShippingStateCode, Account.ShippingCountry
				, Account.ShippingCountryCode, Bypass_Validation__c
            FROM User
            WHERE Id IN :lstUserId
        ];

        // Set the bypass flag for admins / data load
        Id ProfileId = UserInfo.getProfileId();
        Boolean bypass = false;
        Map<id, Profile> profileMap = new Map<Id, Profile>();
        for(Profile pr :[Select Id FROM Profile Where Name = 'System Administrator'  OR NAME = 'API User' Limit 2]){
            if(!profileMap.containsKey(pr.Id)){
                profileMap.put(pr.id,pr);
            }
        }
            
        if(profileMap.size() > 0 && ProfileMap.ContainsKey(ProfileId)) {
            byPass = True; 
        }
            

        // Loop over the community users and update info
        for (User usr : lstCommunityUsers) {
            usr.Street = usr.Account.ShippingStreet;
            usr.City = usr.Account.ShippingCity;
            usr.State = usr.Account.ShippingState;
            usr.StateCode = usr.Account.ShippingStateCode;
            usr.PostalCode = usr.Account.ShippingPostalCode;
            usr.Country = usr.Account.ShippingCountry;
            usr.CountryCode = usr.Account.ShippingCountryCode;
            usr.Phone = usr.Account.PersonHomePhone;
            usr.MobilePhone = usr.Account.PersonMobilePhone;
            usr.FirstName = usr.Account.FirstName;
            usr.LastName = usr.Account.LastName;
            usr.Email = usr.Account.PersonEmail;
            if(bypass) {
                usr.Bypass_Validation__c = true;
            }
        }
        
        // Finally update the list of users
        update lstCommunityUsers;
    }
    
    /*
    * Function: SyncCommunityUsers 
    * --------------------
    * Synchronize the User record with its corresponding Account record
    *
    *  lstUserId: List of User Id that requires synchronizing
    *
    *  returns: N/A
	*/
    @future
    private static void SyncCommunityUsers(List<Id> lstUserId) {
        setUserId.addAll(lstUserId);

        // Retrieve list of users to be synchronized
        List<User> lstCommunityUsers = [
            SELECT Street, City, State, StateCode, PostalCode, Country, CountryCode, Phone
            	, Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode
            	, Account.ShippingState, Account.ShippingStateCode, Account.ShippingCountry
				, Account.ShippingCountryCode, Account.Phone, Bypass_Validation__c
            FROM User
            WHERE Id IN :lstUserId
        ];

        // Set the bypass flag for admins / data load
        Id ProfileId = UserInfo.getProfileId();
        Boolean bypass = false;
        Map<id, Profile> profileMap = new Map<Id, Profile>();
        for(Profile pr :[Select Id FROM Profile Where Name = 'System Administrator'  OR NAME = 'API User' Limit 2]){
            if(!profileMap.containsKey(pr.Id)){
                profileMap.put(pr.id,pr);
            }
        }
            
        if(profileMap.size() > 0 && ProfileMap.ContainsKey(ProfileId)) {
            byPass = True; 
        }

        // Loop over the community users and update info
        for (User usr : lstCommunityUsers) {
            usr.Street = usr.Account.ShippingStreet;
            usr.City = usr.Account.ShippingCity;
            usr.State = usr.Account.ShippingState;
            usr.StateCode = usr.Account.ShippingStateCode;
            usr.PostalCode = usr.Account.ShippingPostalCode;
            usr.Country = usr.Account.ShippingCountry;
            usr.CountryCode = usr.Account.ShippingCountryCode;
            usr.Phone = usr.Account.Phone;
            if(bypass) {
                usr.Bypass_Validation__c = true;
            }
        }
    
        // Finally update the list of users
        update lstCommunityUsers;
    }
}