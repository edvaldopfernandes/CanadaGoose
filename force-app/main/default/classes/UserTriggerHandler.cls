public class UserTriggerHandler {
    // Used to avoid recursion between the user and contact trigger
    public static Set<Id> setUserContactId = new Set<Id>();
    // Used to avoid recursion between the user and account trigger
    public static Set<Id> setUserAccountId = new Set<Id>();
    
    /*
    * Function: OnBeforeInsert
    * --------------------
    * Trigger handler for the Before Insert event
    *
    *  lstNewUsers: List of the new User records being inserted
    *  mapNewUsers: Map of the new User records being inserted
    *
    *  returns: N/A
	*/
    public static void OnBeforeInsert(List<User> lstNewUsers, Map<Id, User> mapNewUsers) {
        Map<String, Country_Setting__mdt> mapCountrySetting = Utilities.GetCountrySettings();
        
        for (User usr : lstNewUsers) {
            // Only work on community users only 
            if (usr.ContactId != null) {
                // Get settings for the Country
                Country_Setting__mdt countrySetting = (mapCountrySetting.containsKey(usr.CountryCode)) ? mapCountrySetting.get(usr.CountryCode) : mapCountrySetting.get(Utilities.DEFAULT_COUNTRY_CODE);
                
                if (countrySetting != null) {
                    // Determine if the language is supported in the new Country
                    if (usr.LanguageLocaleKey == 'fr' && String.isNotBlank(countrySetting.Locale_French__c)) {
                        usr.LocaleSidKey = countrySetting.Locale_French__c;
                    }
                    else if (usr.LanguageLocaleKey == 'de' && String.isNotBlank(countrySetting.Locale_German__c)) {
                        usr.LocaleSidKey = countrySetting.Locale_German__c;
                    }
                    else if (usr.LanguageLocaleKey == 'zh_CN' && String.isNotBlank(countrySetting.Locale_Chinese__c)) {
                        usr.LocaleSidKey = countrySetting.Locale_Chinese__c;
                    }
                    else if (usr.LanguageLocaleKey == 'it' && String.isNotBlank(countrySetting.Locale_Italian__c)) {
                        usr.LocaleSidKey = countrySetting.Locale_Italian__c;
                    }
                    else if (usr.LanguageLocaleKey == 'es' && String.isNotBlank(countrySetting.Locale_Spanish__c)) {//-- venkata
                        usr.LocaleSidKey = countrySetting.Locale_Spanish__c;//
                    }// venkata ----
                    else {
                        if (String.isNotBlank(countrySetting.Locale_English__c))
                            usr.LocaleSidKey = countrySetting.Locale_English__c;
                        usr.LanguageLocaleKey = 'en_US';
                    }
                }
            } 
        }
    }
    
    /*
    * Function: OnBeforeUpdate 
    * --------------------
    * Trigger handler for the Before Update event
    *
    *  lstNewUsers: List of the new User records being updated
    *  mapNewUsers: Map of the new User records being updated
    *  lstOldUsers: List of the old User records being updated
    *  mapOldUsers: Map of the old User records being updated
    *
    *  returns: N/A
	*/
    public static void OnBeforeUpdate(List<User> lstNewUsers, Map<Id, User> mapNewUsers, List<User> lstOldUsers, Map<Id, User> mapOldUsers) {
        Map<String, Country_Setting__mdt> mapCountrySetting = Utilities.GetCountrySettings();
        Map<Id, Profile> mapProfile = new Map<Id, Profile> ([SELECT Id FROM Profile WHERE Name IN ('Warranty Customer Community User', 'Warranty Retailer Community User')]);
        
        for (User usr : lstNewUsers) {
            // Only work on community users only 
            if (usr.ContactId != null && mapProfile.containsKey(usr.ProfileId)) {
                User oldUsr = mapOldUsers.get(usr.Id);
                Boolean bError = false;
                
                if (!usr.Bypass_Validation__c) {
                    if (String.isBlank(usr.MobilePhone)) {
                        usr.MobilePhone.addError(System.Label.Warranty_Validation_FieldRequired);
                        bError = true;
                    }
                    
                    if (String.isBlank(usr.Street)) {
                        usr.Street.addError(System.Label.Warranty_Validation_FieldRequired);
                        bError = true;
                    }
                    
                    if (String.isBlank(usr.City)) {
                        usr.City.addError(System.Label.Warranty_Validation_FieldRequired);
                        bError = true;
                    }
                    
                    if (String.isBlank(usr.CountryCode)) {
                        usr.Country.addError(System.Label.Warranty_Validation_FieldRequired);
                        bError = true;
                    }
                    else if (String.isBlank(usr.State)
                        && String.isBlank(usr.StateCode)
                        && Community_Setting__c.getOrgDefaults().Country_Codes_with_States__c.contains(usr.CountryCode))
                    {
                        usr.State.addError(System.Label.Warranty_Validation_FieldRequired);
                        bError = true;
                    }
                }
                
                // Only if the country or language changes
                if (!bError && (usr.CountryCode != oldUsr.CountryCode || usr.LanguageLocaleKey != oldUsr.LanguageLocaleKey))
                    //&& (usr.Bypass_Validation__c == oldUsr.Bypass_Validation__c || usr.Bypass_Validation__c))
                {
                    usr.Bypass_Validation__c = false;
                    
                    // Get settings for the Country
                    Country_Setting__mdt countrySetting = (mapCountrySetting.containsKey(usr.CountryCode)) ? mapCountrySetting.get(usr.CountryCode) : mapCountrySetting.get(Utilities.DEFAULT_COUNTRY_CODE);
                    
                    if (countrySetting != null) {
                        system.debug('(usr.LanguageLocaleKey UserTriggerHandler: '+usr.LanguageLocaleKey);
                        system.debug('(countrySetting.Locale_French__c UserTriggerHandler: '+countrySetting.Locale_French__c);
                        system.debug('(countrySetting.Locale_German__c UserTriggerHandler: '+countrySetting.Locale_German__c);
                        system.debug('(countrySetting.Locale_Chinese__c UserTriggerHandler: '+countrySetting.Locale_Chinese__c);
                        system.debug('(countrySetting.Locale_Italian__c UserTriggerHandler: '+countrySetting.Locale_Italian__c);
                        
                        // Determine if the language is supported in the new Country
                        if (usr.LanguageLocaleKey == 'fr' && String.isNotBlank(countrySetting.Locale_French__c)) {
                            usr.LocaleSidKey = countrySetting.Locale_French__c;
                        }
                        else if (usr.LanguageLocaleKey == 'de' && String.isNotBlank(countrySetting.Locale_German__c)) {
                            usr.LocaleSidKey = countrySetting.Locale_German__c;
                        }
                        else if (usr.LanguageLocaleKey == 'zh_CN' && String.isNotBlank(countrySetting.Locale_Chinese__c)) {
                            usr.LocaleSidKey = countrySetting.Locale_Chinese__c;
                        }
                        else if (usr.LanguageLocaleKey == 'it' && String.isNotBlank(countrySetting.Locale_Italian__c)) {
                            usr.LocaleSidKey = countrySetting.Locale_Italian__c;
                        }
                        else if (usr.LanguageLocaleKey == 'es' && String.isNotBlank(countrySetting.Locale_Spanish__c)) {//-- venkata
                        	usr.LocaleSidKey = countrySetting.Locale_Spanish__c;//
                    	}// venkata ----
                        else {
                            if (String.isNotBlank(countrySetting.Locale_English__c))
                                usr.LocaleSidKey = countrySetting.Locale_English__c;
                            usr.LanguageLocaleKey = 'en_US';
                        }
                    }
                }
            } 
        }
    }
    
    /*
    * Function: OnAfterInsert
    * --------------------
    * Trigger handler for the After Insert event
    *
    *  lstNewUsers: List of the new User records being inserted
    *  mapNewUsers: Map of the new User records being inserted
    *
    *  returns: N/A
	*/
    public static void OnAfterInsert(List<User> lstNewUsers, Map<Id, User> mapNewUsers) {
        Set<Id> setCommunityContactIds = new Set<Id>();
        Set<Id> setCommunityAccountIds = new Set<Id>();
        Set<Id> lstCommunityUserIds = new Set<Id>();
                
        for (User usr : lstNewUsers) {
            // Get a list of community users only 
            if (usr.ContactId != null) {
                setCommunityContactIds.add(usr.ContactId);
                setCommunityAccountIds.add(usr.AccountId);
                lstCommunityUserIds.add(usr.Id);
            } 
        }

        System.debug('setCommunityContactIds: ' + setCommunityContactIds);
        System.debug('setCommunityAccountIds: ' + setCommunityAccountIds);
        System.debug('lstCommunityUserIds: ' + lstCommunityUserIds);
        
        
        // Initiate the synchronization for the selected users
        if (!setCommunityContactIds.isEmpty()) {
            //SyncCommunityContacts(lstCommunityUserIds, setCommunityContactIds);
            setUserContactId.addAll(setCommunityContactIds);
            system.enqueueJob(new UserTriggerHandlerQueueable(lstCommunityUserIds)); 
        }
        
        if (!setCommunityAccountIds.isEmpty()) {
            SyncCommunityAccounts(lstCommunityUserIds, setCommunityAccountIds);
        }
    }
    
    /*
    * Function: OnAfterUpdate 
    * --------------------
    * Trigger handler for the After Update event
    *
    *  lstNewUsers: List of the new User records being updated
    *  mapNewUsers: Map of the new User records being updated
    *  lstOldUsers: List of the old User records being updated
    *  mapOldUsers: Map of the old User records being updated
    *
    *  returns: N/A
	*/
    public static void OnAfterUpdate(List<User> lstNewUsers, Map<Id, User> mapNewUsers, List<User> lstOldUsers, Map<Id, User> mapOldUsers) {
        Set<Id> setCommunityContactIds = new Set<Id>();
        Set<Id> setCommunityAccountIds = new Set<Id>();
        Set<Id> setCommunityPersonAccountIds = new Set<Id>();
        List<Id> lstCommunityUserIds = new List<Id>();
        List<Id> lstCommunityAllAccountIds = new List<Id>();
        Map<Id, Account> mapAllUserAccount = new Map<Id, Account>();
        
        system.debug('lstNewUsers OnAfterUpdate: ' + lstNewUsers);
        for (User usr : lstNewUsers) {
            if (!AccountTriggerHandler.setUserId.contains(usr.Id)
                && !ContactTriggerHandler.setUserId.contains(usr.Id)
                && usr.ContactId != null
               ) {
                   lstCommunityAllAccountIds.add(usr.AccountId);
               }
        }

        if (!lstCommunityAllAccountIds.isEmpty())
        	mapAllUserAccount = new Map<Id, Account>([SELECT Id, IsPersonAccount FROM Account WHERE Id IN :lstCommunityAllAccountIds]);
        
        for (User usr : lstNewUsers) {
            // First check for recursion before processing the record
            if (AccountTriggerHandler.setUserId.contains(usr.Id)) {
                AccountTriggerHandler.setUserId.remove(usr.Id);
            }
            else if (ContactTriggerHandler.setUserId.contains(usr.Id)) {
                ContactTriggerHandler.setUserId.remove(usr.Id);
            }
            // If no recursion, then process the record
            else {
                User oldUsr = mapOldUsers.get(usr.Id);
                
                // Get a list of community users only that has changed values
                if (usr.ContactId != null) {
                    if (mapAllUserAccount.containsKey(usr.AccountId) && mapAllUserAccount.get(usr.AccountId).IsPersonAccount) {
                        // If contact related info changes
                        if (usr.FirstName != oldUsr.FirstName
                            || usr.LastName != oldUsr.LastName
                            || usr.Email != oldUsr.Email
                            || usr.Phone != oldUsr.Phone
                            || usr.MobilePhone != oldUsr.MobilePhone
                            || usr.Street != oldUsr.Street
                            || usr.City != oldUsr.City
                            || usr.PostalCode != oldUsr.PostalCode
                            || usr.State != oldUsr.State
                            || usr.StateCode != oldUsr.StateCode
                            || usr.Country != oldUsr.Country
                            || usr.CountryCode != oldUsr.CountryCode
                            || usr.LanguageLocaleKey != oldUsr.LanguageLocaleKey
                            || usr.LocaleSidKey != oldUsr.LocaleSidKey
                           ) {
                               setCommunityPersonAccountIds.add(usr.AccountId);
                               lstCommunityUserIds.add(usr.Id);
                           }
                    }
                    else {
                        // If contact related info changes
                        if (usr.FirstName != oldUsr.FirstName
                            || usr.LastName != oldUsr.LastName
                            || usr.Email != oldUsr.Email
                            || usr.Phone != oldUsr.Phone
                            || usr.MobilePhone != oldUsr.MobilePhone
                           ) {
                               setCommunityContactIds.add(usr.ContactId);
                               lstCommunityUserIds.add(usr.Id);
                           }
                        
                        // If account related info changes
                        if (usr.Street != oldUsr.Street
                            || usr.City != oldUsr.City
                            || usr.PostalCode != oldUsr.PostalCode
                            || usr.State != oldUsr.State
                            || usr.StateCode != oldUsr.StateCode
                            || usr.Country != oldUsr.Country
                            || usr.CountryCode != oldUsr.CountryCode
                            || usr.LanguageLocaleKey != oldUsr.LanguageLocaleKey
                            || usr.LocaleSidKey != oldUsr.LocaleSidKey
                           ) {
                               setCommunityAccountIds.add(usr.AccountId);
                               lstCommunityUserIds.add(usr.Id);
                           }
                    }
                }
            }
        }
        
        if (!setCommunityContactIds.isEmpty()) {
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([
                SELECT Id, FirstName, LastName, Email, Phone, MobilePhone
                FROM Contact
                WHERE Id IN :setCommunityContactIds
            ]);
        
            if (!mapContacts.isEmpty()) {
                Set<Id> lstContactUserIdToSync = new Set<Id>();
                Set<Id> setContactUserToSync = new Set<Id>();
                
                for (User usr : lstNewUsers) {
                    if (setCommunityContactIds.contains(usr.ContactId)) {
                        Contact cont = mapContacts.get(usr.ContactId);
                        
                        // Only sync contact if there are changes from user record
                        if (cont.FirstName != usr.FirstName
                            || cont.LastName != usr.LastName
                            || cont.Email != usr.Email
                            || cont.Phone != usr.Phone
                            || cont.MobilePhone != usr.MobilePhone) {
                                lstContactUserIdToSync.add(usr.Id);
                                setContactUserToSync.add(cont.Id);
                            }
                    }
                }
                
                // Initiate the synchronization for the selected contacts
                if (!lstContactUserIdToSync.isEmpty()) {
                    //SyncCommunityContacts(lstContactUserIdToSync, setContactUserToSync);
                     setUserContactId.addAll(setContactUserToSync);
                     system.enqueueJob(new UserTriggerHandlerQueueable(lstContactUserIdToSync));
                }
            }
        }
        
        if (!setCommunityAccountIds.isEmpty()) {
            Map<Id, Account> mapAccounts = new Map<Id, Account>([
                SELECT Id, ShippingStreet, ShippingCity, ShippingPostalCode
                    , ShippingState, ShippingStateCode, ShippingCountry, ShippingCountryCode
                    , Locale__c, Language__c
                FROM Account
                WHERE Id IN :setCommunityAccountIds
            ]);
        
            if (!mapAccounts.isEmpty()) {
                Set<Id> lstAccountUserIdToSync = new Set<Id>();
                Set<Id> setAccountIdToSync = new Set<Id>();
                
                for (User usr : lstNewUsers) {
                    if (setCommunityAccountIds.contains(usr.AccountId)) {
                        Account acc = mapAccounts.get(usr.AccountId);
                        
                        // Only sync accounts if there are changes from user record
                        if (acc.ShippingStreet != usr.Street
                            || acc.ShippingCity != usr.City
                            || acc.ShippingState != usr.State
                            || acc.ShippingStateCode != usr.StateCode
                            || acc.ShippingPostalCode != usr.PostalCode
                            || acc.ShippingCountry != usr.Country
                            || acc.ShippingCountryCode != usr.CountryCode
                            || acc.Locale__c != usr.LocaleSidKey
                            || acc.Language__c != usr.LanguageLocaleKey
                           ) {
                                lstAccountUserIdToSync.add(usr.Id);
                                setAccountIdToSync.add(acc.Id);
                            }
                    }
                }

                // Initiate the synchronization for the selected accounts
                if (!lstAccountUserIdToSync.isEmpty()) {
                    SyncCommunityAccounts(lstAccountUserIdToSync, setAccountIdToSync);
                }
            }
        }
        
        if (!setCommunityPersonAccountIds.isEmpty()) {
            Map<Id, Account> mapAccounts = new Map<Id, Account>([
                SELECT Id, ShippingStreet, ShippingCity, ShippingPostalCode
                    , ShippingState, ShippingStateCode, ShippingCountry, ShippingCountryCode
                    , Locale__c, Language__c, PersonHomePhone, PersonMobilePhone
                    , PersonEmail, FirstName, LastName
                FROM Account
                WHERE Id IN :setCommunityPersonAccountIds
            ]);
        
            if (!mapAccounts.isEmpty()) {
                Set<Id> lstPersonAccountUserIdToSync = new Set<Id>();
                Set<Id> setPersonAccountIdToSync = new Set<Id>();
                
                for (User usr : lstNewUsers) {
                    if (setCommunityPersonAccountIds.contains(usr.AccountId)) {
                        Account acc = mapAccounts.get(usr.AccountId);
                        
                        // Only sync accounts if there are changes from user record
                        if (acc.ShippingStreet != usr.Street
                            || acc.ShippingCity != usr.City
                            || acc.ShippingState != usr.State
                            || acc.ShippingStateCode != usr.StateCode
                            || acc.ShippingPostalCode != usr.PostalCode
                            || acc.ShippingCountry != usr.Country
                            || acc.ShippingCountryCode != usr.CountryCode
                            || acc.Locale__c != usr.LocaleSidKey
                            || acc.Language__c != usr.LocaleSidKey
                            || acc.PersonHomePhone != usr.Phone
                            || acc.PersonMobilePhone != usr.MobilePhone
                            || acc.FirstName != usr.FirstName
                            || acc.LastName != usr.LastName
                            || acc.PersonEmail != usr.Email
                           ) {
                                lstPersonAccountUserIdToSync.add(usr.Id);
                                setPersonAccountIdToSync.add(acc.Id);
                            }
                    }
                }

                // Initiate the synchronization for the selected accounts
                if (!lstPersonAccountUserIdToSync.isEmpty()) {
                    SyncCommunityPersonAccounts(lstPersonAccountUserIdToSync, setPersonAccountIdToSync);
                }
            }
        }
    }
    
    @future
    /*
    * Function: SyncCommunityPersonAccounts
    * --------------------
    * Synchronize the Person Account record with its corresponding User record
    *
    *  setAccountId: Set of Account Id that requires synchronizing
    *
    *  returns: N/A
	*/
    public static void SyncCommunityPersonAccounts(Set<Id> lstUserId, Set<Id> setAccountId) {
        setUserAccountId.addAll(setAccountId);
        List<Account> lstCommunityPersonAccounts = new List<Account>();
        system.debug('SyncCommunityPersonAccounts lstUserId: '+lstUserId);
        // First retrieve list of users that requires synchronizing
        List<User> lstUsers = [
            SELECT AccountId, LocaleSidKey, LanguageLocaleKey
            	, Street, City, PostalCode, State, StateCode, Country, CountryCode
            	, FirstName, LastName, Email, Phone, MobilePhone
            FROM User
            WHERE Id IN :lstUserId AND ContactId != null
        ];
        
        if (!lstUsers.isEmpty()) {
            // Loop over the community users and update their corresponding contact record and fields
            for (User usr : lstUsers) {
                lstCommunityPersonAccounts.add(new Account(
                    Id = usr.AccountId
                    , ShippingStreet = usr.Street
                    , ShippingCity = usr.City
                    , ShippingState = usr.State
                    , ShippingStateCode = usr.StateCode
                    , ShippingPostalCode = usr.PostalCode
                    , ShippingCountry = usr.Country
                    , ShippingCountryCode = usr.CountryCode
                    , Locale__c = usr.LocaleSidKey
                    , Language__c = usr.LanguageLocaleKey
                    , FirstName = usr.FirstName
                    , LastName = usr.LastName
                    , PersonEmail = usr.Email
                    , PersonHomePhone = usr.Phone
                    , PersonMobilePhone = usr.MobilePhone
                ));
            }
            
            // Finally update the list of accounts
            update lstCommunityPersonAccounts;
        }
    }
    
    @future
    /*
    * Function: SyncCommunityAccounts
    * --------------------
    * Synchronize the Account record with its corresponding User record
    *
    *  setAccountId: Set of Account Id that requires synchronizing
    *
    *  returns: N/A
	*/
    public static void SyncCommunityAccounts(Set<Id> lstUserId, Set<Id> setAccountId) {
        setUserAccountId.addAll(setAccountId);
        List<Account> lstCommunityAccounts = new List<Account>();
        
        // First retrieve list of users that requires synchronizing
        List<User> lstUsers = [
            SELECT AccountId, LocaleSidKey, LanguageLocaleKey
            	, Street, City, PostalCode, State, StateCode, Country, CountryCode
            FROM User
            WHERE Id IN :lstUserId AND ContactId != null
        ];

        if (!lstUsers.isEmpty()) {
            // Loop over the community users and update their corresponding contact record and fields
            for (User usr : lstUsers) {
                lstCommunityAccounts.add(new Account(
                    Id = usr.AccountId
                    , ShippingStreet = usr.Street
                    , ShippingCity = usr.City
                    , ShippingState = usr.State
                    , ShippingStateCode = usr.StateCode
                    , ShippingPostalCode = usr.PostalCode
                    , ShippingCountry = usr.Country
                    , ShippingCountryCode = usr.CountryCode
                    , Locale__c = usr.LocaleSidKey
                    , Language__c = usr.LanguageLocaleKey
                ));
            }
            
            // Finally update the list of accounts
            update lstCommunityAccounts;
        }
    }
   
    
}