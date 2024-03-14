/**
 * @description Created as a part of the Zendesk Migration to Salesforce project.
 * This Class is used to create various constants for the Case object
 */
public without sharing class CaseTriggerService {
    /**
     * @description Created as a part of the Zendesk Migration to Salesforce project.
     * This method populates contact info on new cases
     * @param  newCases : list of new cases
     * @return
     */
    public static void associateCasesToContact(List<Case> newCases){
        Map<String, List<Case>> casesByEmail = new Map<String, List<Case>> ();
        for (Case newCase : newCases) {
            if (newCase.RecordTypeId == CaseConstants.RECORD_TYPE.EMAIL_SUPPORT
                && newCase.ContactId == NULL && newCase.SuppliedEmail != NULL) {
                if(!casesByEmail.containsKey(newCase.SuppliedEmail)){
                    casesByEmail.put(newCase.SuppliedEmail, new List<Case>());
                }
                casesByEmail.get(newCase.SuppliedEmail).add(newCase);
            }
        }
        if(casesByEmail.isEmpty()){
            return;
        }

        //get contacts
        Map<String, List<Contact>> contactsByEmail = getContactsByEmail(casesByEmail.keySet());

        Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Map<String, Account> personAccountsByEmail = new Map<String, Account>();
        //update contact
        for(String email : casesByEmail.keySet()){
            for(Case newCase : casesByEmail.get(email)){
                if(contactsByEmail.containsKey(email)){
                    newCase.ContactId = contactsByEmail.get(email)[0].Id;
                } else{
                    //create new person account
                    personAccountsByEmail.put(email, createPersonAccount(newCase, customerRT));
                }
            }
        }

        if(!personAccountsByEmail.isEmpty()){
            //insert person accounts
            insert personAccountsByEmail.values();
            for (Account personAccount : [SELECT PersonEmail, PersonContactId FROM Account WHERE Id IN: personAccountsByEmail.values()])  {
                for(Case newCase : casesByEmail.get(personAccount.PersonEmail)){
                    newCase.ContactId = personAccount.PersonContactId;
                }
            }
        }
    }

    /**
     * @description Created as a part of the Zendesk Migration to Salesforce project.
     * This method query contacts with emails and arrange these by emails 
     * @param  emailIds : set of emails
     * @return Map<String, List<Contact>> : map of list of contacts with email ids
     */
    private static Map<String, List<Contact>> getContactsByEmail(Set<String> emailIds){
        Map<String, List<Contact>> contactsByEmail = new Map<String, List<Contact>> ();
        for (Contact contact : [SELECT Email FROM Contact WHERE Email IN: emailIds ORDER BY CreatedDate DESC])  {
            if(!contactsByEmail.containsKey(contact.Email)){
                contactsByEmail.put(contact.Email, new List<Contact>());
            }
            contactsByEmail.get(contact.Email).add(contact);
        }
        return contactsByEmail;
    }

    /**
     * @description Created as a part of the Zendesk Migration to Salesforce project.
     * This method creates an instance of person account 
     * @param  newCase : new case record
     * @return Account : instance of Account 
     */
    private static Account createPersonAccount(Case newCase, Id customerRT){
        String firstName = '';
        String[] customerName = (String.isBlank(newCase.SuppliedName) 
            ? newCase.SuppliedEmail.substringBefore('@') 
            : newCase.SuppliedName).split(' ');
        String lastName = customerName.get(customerName.size()-1);
        for(Integer i = 0; i < customerName.size()-1; i++){
            firstName = firstName + customerName.get(i)+' ';
        }
        firstName = firstName.trim();
        return new Account(
            FirstName = firstName,
            LastName = lastName,
            RecordTypeId = customerRT,
            PersonEmail = newCase.SuppliedEmail
        );
    }
}