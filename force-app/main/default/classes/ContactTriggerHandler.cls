public without sharing class ContactTriggerHandler {
    // Used to avoid recursion between the contact and user trigger
    public static Set<Id> setUserId = new Set<Id>();
    
    /*
    * Function: OnBeforeUpdate 
    * --------------------
    * Trigger handler for the Before Update event
    *
    *  lstNewContacts: List of the new Contact records being updated
    *  mapNewContacts: Map of the new Contact records being updated
    *  lstOldContacts: List of the old Contact records being updated
    *  mapOldContacts: Map of the old Contact records being updated
    *
    *  returns: N/A
    */
    public static void OnBeforeUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts, List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts) {
        Set<Id> setContactIdToEnable = new Set<Id>();
        Map<Id, Account> mapParentAccount = new Map<Id, Account>();
        
        for (Contact cont : lstNewContacts) {
            // Verify which contacts need to enable the community user
            Contact oldCont = mapOldContacts.get(cont.Id);
            if (cont.Enable_Community_User__c && !oldCont.Enable_Community_User__c) {
                setContactIdToEnable.add(cont.Id);
                mapParentAccount.put(cont.AccountId, null);
            }
        }

        if (!setContactIdToEnable.isEmpty()) {
            // Retrieve list of accounts for contacts that need to be enabled as community users
            for (Account acc : [SELECT RecordType.DeveloperName, ShippingStreet, ShippingCity, ShippingPostalCode
                                    , ShippingState, ShippingStateCode, ShippingCountry, ShippingCountryCode
                                    , Language__c, Locale__c 
                                FROM Account
                                WHERE Id IN :mapParentAccount.keySet()]) {
                mapParentAccount.put(acc.Id, acc);
            }

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
                List<User> lstUsersToCreate = new List<User>();
                Map<String, Id> mapProfileNameToId = new Map<String, Id>();

                // Build a list of available community profiles
                for (Profile prof : [SELECT Id, Name
                                    FROM Profile
                                    WHERE UserType IN ('PowerCustomerSuccess', 'CSPLitePortal')]) {
                    mapProfileNameToId.put(prof.Name, prof.Id);
                }

                // Now start doing final list of validations before enabling the community user
                for (Contact cont : lstNewContacts) {
                    if (setContactIdToEnable.contains(cont.Id)) {
                        if (setContactIdWithExistUser.contains(cont.Id)) {
                            cont.addError('Cannot create a user as community user already exists and is active.');
                        }
                        else {
                            Account acc = mapParentAccount.get(cont.AccountId);
                            Id ProfileId;
                            
                            if (acc.RecordType.DeveloperName == 'Retailer')
                                ProfileId = mapProfileNameToId.get('Warranty Retailer Community User');
                            else if (acc.RecordType.DeveloperName == 'CSR')
                                ProfileId = mapProfileNameToId.get('Warranty CSR-Tier1 Community User');
                            
                            if (ProfileId == null)
                                cont.addError('Account\'s record type is not supported by this flow. Please contact your system administrator.');
                            else {
                                String randomString = String.valueOf(integer.valueOf(Math.random() * 10000000));

                                lstUsersToCreate.add(new User (
                                    Email = cont.Email
                                    , Username = cont.Email
                                    , FirstName = cont.FirstName
                                    , LastName = cont.LastName
                                    , Alias = cont.FirstName.left(1) + cont.LastName.left(3) + randomString.left(4)
                                    , CommunityNickName = (cont.FirstName + '.' + cont.LastName).left(30).toLowerCase() + randomString
                                    , MobilePhone = cont.MobilePhone
                                    , Phone = cont.Phone
                                    , Street = acc.ShippingStreet
                                    , City = acc.ShippingCity
                                    , PostalCode = acc.ShippingPostalCode
                                    , State = acc.ShippingState
                                    , StateCode = acc.ShippingStateCode
                                    , Country = acc.ShippingCountry
                                    , CountryCode = acc.ShippingCountryCode
                                    , ProfileId = ProfileId
                                    , ContactId = cont.Id
                                    , LocaleSidKey = acc.Locale__c
                                    , LanguageLocaleKey = acc.Language__c
                                    , EmailEncodingKey = 'UTF-8'
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
    *  lstNewContacts: List of the new Contact records being updated
    *  mapNewContacts: Map of the new Contact records being updated
    *  lstOldContacts: List of the old Contact records being updated
    *  mapOldContacts: Map of the old Contact records being updated
    *
    *  returns: N/A
	*/
    public static void OnAfterUpdate(List<Contact> lstNewContacts, Map<Id, Contact> mapNewContacts, List<Contact> lstOldContacts, Map<Id, Contact> mapOldContacts) {
        Set<Id> setCommunityContactIds = new Set<Id>();
        
        for (Contact cont : lstNewContacts) {
            // First check for recursion before processing the record
            if (UserTriggerHandler.setUserContactId.contains(cont.Id)) {
                UserTriggerHandler.setUserContactId.remove(cont.Id);
            }
            // If no recursion, then process the record
            else {
                Contact oldCont = mapOldContacts.get(cont.Id);
                
                // Only sync when Name and Email have changed
                if (cont.FirstName != oldCont.FirstName
                    || cont.LastName != oldCont.LastName
                    || cont.Email != oldCont.Email
                    || cont.Phone != oldCont.Phone
                    || cont.MobilePhone != oldCont.MobilePhone) {
                        setCommunityContactIds.add(cont.Id);
                    }
            }
        }
        
        if (!setCommunityContactIds.isEmpty()) {
            // Retrieve list of users to be synchronized
            List<User> lstCommunityUsers = [
                SELECT ContactId, Email, FirstName, LastName, Phone, MobilePhone
                FROM User
                WHERE ContactId IN :setCommunityContactIds
            ];
            
            if (!lstCommunityUsers.isEmpty()) {
                Map<Id, User> mapContactIdToUser = new Map<Id, User>();
                List<Id> lstCommunityUsersIdToUpdate = new List<Id>();
                
                for (User usr : lstCommunityUsers) {
                    mapContactIdToUser.put(usr.ContactId, usr);
                }
                
                for (Contact cont : lstNewContacts) {
                    if (setCommunityContactIds.contains(cont.Id)) {
                        User usr = mapContactIdToUser.get(cont.Id);
                        
                        if (usr.FirstName != cont.FirstName
                            || usr.LastName != cont.LastName
                            || usr.Email != cont.Email
                            || usr.Phone != cont.Phone
                            || usr.MobilePhone != cont.MobilePhone
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
        
        /*
        // Retrieve list of users to be synchronized
        Map<Id, User> mapCommunityUsers = new Map<Id, User>([SELECT Id FROM User WHERE ContactId IN :setCommunityContactIds]);
        
        if (!mapCommunityUsers.isEmpty()) {
            setUserId.addAll(mapCommunityUsers.keySet());
            SyncCommunityUsers(mapCommunityUsers.keySet());
        }*/
    }
    
    /*
    * Function: SyncCommunityUsers 
    * --------------------
    * Synchronize the User record with its corresponding Contact record
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
            SELECT Email, FirstName, LastName, Phone, MobilePhone
            	, Contact.Email, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.MobilePhone
            FROM User
            WHERE Id IN :lstUserId
        ];

        // Loop over the community users and update info
        for (User usr : lstCommunityUsers) {
            usr.FirstName = usr.Contact.FirstName;
            usr.LastName = usr.Contact.LastName;
            usr.Email = usr.Contact.Email;
            usr.Phone = usr.Contact.Phone;
            usr.MobilePhone = usr.Contact.MobilePhone;
        }
        
        // Finally update the list of users
        update lstCommunityUsers;
    }
}