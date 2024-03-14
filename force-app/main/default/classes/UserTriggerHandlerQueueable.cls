public class UserTriggerHandlerQueueable implements Queueable {
    
    private Set<Id> lstUsers;
    
    public UserTriggerHandlerQueueable(set<Id> listOfUsersParams) {
        this.lstUsers = new set<Id>(listOfUsersParams);
    }
    public void execute(QueueableContext context)
    {
        List<Contact> lstCommunityContacts = new List<Contact>(); 
        if (!this.lstUsers.isEmpty()) {
            // Loop over the community users and update their corresponding contact record and fields
            for (User usr : [SELECT ContactId, FirstName, LastName, Email, Phone, MobilePhone FROM User WHERE Id IN :lstUsers AND ContactId != null]) {
                lstCommunityContacts.add(new Contact(
                    Id = usr.ContactId
                    , FirstName = usr.FirstName
                    , LastName = usr.LastName
                    , Email = usr.Email
                    , Phone = usr.Phone
                    , MobilePhone = usr.MobilePhone
                ));
            }
            
            // Finally update the list of contacts
            update lstCommunityContacts;
            system.debug('Queueable contact: '+lstCommunityContacts);
        }
    }
}