global class BulkCustomerImporter implements Database.Batchable<SObject> {
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT State__c, Gender_Id__c, Consent_Date__c, Preferred_Lang__c,Marketing_Source_Location__c,Origin__c, Email__c, Has_Been_Processed__c, Is_Friends_Family_Lead__c,Marketing_Subscription_Source__c,Marketing_Consent_Status__c, First_Name__c, Last_Name__c, B2C_CustomerList__c, City__c, Contact__c, CountryCode__c,Generations_Trade_In__c FROM Customer_Data_Temp_Store__c where Contact__c = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Customer_Data_Temp_Store__c> records) {
        List<String> emailList = new List<String>();
        List<Account> accountList = new List<Account>();
        list<contact> contactList = new list<contact>();
        List<Customer_Data_Temp_Store__c> customerDataTempStoresToUpdate = new List<Customer_Data_Temp_Store__c>();
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Customer' and SObjectType = 'Account'];

        //Get the temp record emails
        for(Customer_Data_Temp_Store__c cdts : records) {
            emailList.add(cdts.Email__c);
        }
		System.debug('emailList>>'+emailList);
		
        List<Contact> existingContacts = [SELECT Id, email, Marketing_Consent_Status__c FROM Contact WHERE email IN :emailList];
        Map<String,contact> EmailContacIdMap = new Map<String,contact>();
        //Get the existing contact emails and map them
        for(Contact c : existingContacts) {
            if(c.Email != null) {
                if(!EmailContacIdMap.containsKey(c.email)){
                	EmailContacIdMap.put(c.email, c);
                }
            }
        }
		
		System.debug('>>EmailContacIdMap'+EmailContacIdMap);
        //Process the records
        for(Customer_Data_Temp_Store__c cdts : records) {
            //Ignore any records without emails or that have already been processed
            if(cdts.Email__c == null || cdts.Has_Been_Processed__c == true) {
                continue;
            }
            //Get and set the associated contact Id
			System.debug('>>cdts.EMail__c in EmailContacIdMap>>'+EmailContacIdMap.containsKey(cdts.Email__c));
            
            if(EmailContacIdMap.containsKey(cdts.Email__c) && EmailContacIdMap.get(cdts.Email__c) != null 
               	&& EmailContacIdMap.get(cdts.Email__c).Marketing_Consent_Status__c == 'express') {
				
				System.debug('>>In If line 45 cdts.EMail__c in EmailContacIdMap>>'+EmailContacIdMap.get(cdts.Email__c));
                contact con = new Contact(id = EmailContacIdMap.get(cdts.Email__c).id);
                con.Generations_Trade_In__c = cdts.Generations_Trade_In__c;
				con.Is_Friends_Family_Lead__c = cdts.Is_Friends_Family_Lead__c;
                contactList.add(con);
				cdts.Contact__c = EmailContacIdMap.get(cdts.Email__c).id;
                cdts.Has_Been_Processed__c = true;
                customerDataTempStoresToUpdate.add(cdts);
            }
            if(EmailContacIdMap.containsKey(cdts.Email__c) && EmailContacIdMap.get(cdts.Email__c) != null 
               && EmailContacIdMap.get(cdts.Email__c).Marketing_Consent_Status__c != 'express') {
				
				System.debug('>>In If line  cdts.EMail__c in EmailContacIdMap>>'+EmailContacIdMap.get(cdts.Email__c));
                contact con = new Contact(id = EmailContacIdMap.get(cdts.Email__c).id);
                con.Generations_Trade_In__c = cdts.Generations_Trade_In__c;
                con.Marketing_Consent_Status__c = cdts.Marketing_Consent_Status__c;
                con.Origin__c = cdts.Origin__c;
                con.B2C_Add_To_Email_List__c = true;
				con.Marketing_Consent_Date__c = cdts.Consent_Date__c; 
                con.Marketing_Subscription_Source__c = cdts.Marketing_Subscription_Source__c;
                con.Marketing_Source_Location__c = cdts.Marketing_Source_Location__c;
                con.B2C_Add_To_Email_List__c = true;
                con.Is_Friends_Family_Lead__c = cdts.Is_Friends_Family_Lead__c; 
                contactList.add(con);
				cdts.Contact__c = EmailContacIdMap.get(cdts.Email__c).id;
                cdts.Has_Been_Processed__c = true;
                customerDataTempStoresToUpdate.add(cdts);
            }
            else {
                //If there is no contact Id create a new PersonAccount
                Account newPersonAccount = new Account(RecordTypeId=personAccountRecordType.Id);
                System.debug('>>In else  line 53 cdts.');
				
				if(cdts.First_Name__c != null) {
                    newPersonAccount.FirstName = cdts.First_Name__c;
                } else {
                    newPersonAccount.FirstName = 'Unknown';
                }
                if(cdts.Last_Name__c != null) {
                    newPersonAccount.LastName = cdts.Last_Name__c;
                } else {
                    newPersonAccount.LastName = 'Unknown';
                }
                if(cdts.Marketing_Consent_Status__c != null) {
                    newPersonAccount.Marketing_Consent_Status__pc = cdts.Marketing_Consent_Status__c;
                } else {
                    newPersonAccount.Marketing_Consent_Status__pc = 'express';
                }
                if(cdts.Is_Friends_Family_Lead__c != null) {
                    newPersonAccount.Is_Friends_Family_Lead__pc = cdts.Is_Friends_Family_Lead__c;
                } else {
                    newPersonAccount.Is_Friends_Family_Lead__pc = false;
                }
                if(cdts.Origin__c != null) {
                    newPersonAccount.Origin__pc = cdts.Origin__c;
                }
                if(cdts.Consent_Date__c != null) {
                    newPersonAccount.Marketing_Consent_Date__pc = cdts.Consent_Date__c;
                }
                if(cdts.B2C_CustomerList__c != null) {
                    newPersonAccount.B2C_CustomerList_ID__pc = 'a0mDb000003mQv0IAE';
                }
                if(cdts.Marketing_Subscription_Source__c != null) {
                    newPersonAccount.Marketing_Subscription_Source__pc = cdts.Marketing_Subscription_Source__c;
                }
                if(cdts.City__c != null) {                        
                    newPersonAccount.PersonMailingCity = cdts.City__c;
                    newPersonAccount.ShippingCity = cdts.City__c;//Changed by Venkata as part of quick fix
                }
                
                if (cdts.CountryCode__c != null) {
					 System.debug('>>In If  line 87 cdts.');
                    newPersonAccount.PersonMailingCountryCode = cdts.CountryCode__c;
                    newPersonAccount.ShippingCountryCode = cdts.CountryCode__c;//Changed by Venkata as part of quick fix
					 System.debug('>>In If  line 91 cdts.+ newPersonAccount.ShippingCountryCode'+ newPersonAccount.ShippingCountryCode);
                }
                if (cdts.State__c != null) {
                    newPersonAccount.PersonMailingState = cdts.State__c;
                    newPersonAccount.ShippingState = cdts.State__c;//Changed by Venkata as part of quick fix
					 System.debug('>>In If  line 96 cdts.+ newPersonAccount.ShippingState'+ newPersonAccount.ShippingState);
                }
                if(cdts.Marketing_Source_Location__c != null) {
                    newPersonAccount.Marketing_Source_Location__pc = cdts.Marketing_Source_Location__c;
                }
                if(cdts.Preferred_Lang__c != null) {
                    newPersonAccount.Preferred_Lang__pc = cdts.Preferred_Lang__c;
                }else {
                    newPersonAccount.Preferred_Lang__pc = 'EN';
                }
                if(cdts.Gender_Id__c != null) {
                    newPersonAccount.B2C_Gender_ID__pc = cdts.Gender_Id__c;
                }else{
                    newPersonAccount.B2C_Gender_ID__pc = Integer.valueOf('3');
                }
                newPersonAccount.Generations_Trade_In__pc = cdts.Generations_Trade_In__c;
                newPersonAccount.PersonEmail = cdts.Email__c; 
                newPersonAccount.B2C_Add_To_Email_List__pc = true;
                accountList.add(newPersonAccount);
				 System.debug('>>In If  line 109 cdts.+ accountList'+ accountList);
                cdts.Has_Been_Processed__c = true;
            }
        }
        try {
			System.debug('>>In If  line 114 cdts.+ accountList'+ accountList);
            if(accountList.size() > 0) {
                // Insert the new PersonAccounts
                insert accountList;
                List<Id> accIdList = new List<Id>();
                for(Account a : accountList) {
                    accIdList.add(a.Id);
                }
                //Get all the new PersonAccount details missing
                accountList = [SELECT Id, PersonContactId, PersonEmail FROM Account WHERE Id IN :accIdList];
				System.debug('>>In If  line 124 cdts.+  after insertion accountList'+ accountList);
                Map<String, Id> insertedEmailToAccountId = new Map<String,Id>();
                //Map the email and contact Id
                for(Account a : accountList) {
                    if(a.Id != null && a.PersonEmail != null) {
                        insertedEmailToAccountId.put(a.PersonEmail, a.PersonContactId);
                    }
                }
				
				System.debug('insertedEmailToAccountId >> '+insertedEmailToAccountId);
                //Add the new contact Id to the temp object
                for(Customer_Data_Temp_Store__c cdts : records) {
                    if(cdts.Email__c != null && insertedEmailToAccountId.containsKey(cdts.Email__c)) {
						System.debug('insertedEmailToAccountId.get(cdts.Email__c) >> '+insertedEmailToAccountId.get(cdts.Email__c));
                        cdts.Contact__c = insertedEmailToAccountId.get(cdts.Email__c);
                    } 
                }
               
            }
            if(contactList.size() > 0){
                Database.update(contactList, false);
            }
			
			System.debug('records >> in 143'+ records);
            if(records.size() > 0) {
                update records;
            }
			System.debug('records >> in 143 After Update '+ records);
        } catch(Exception e) {
            System.debug(e);
        }
    }
  
    global void finish(Database.BatchableContext bc) {
    }
}