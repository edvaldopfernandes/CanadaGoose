@isTest
public class subscribeMeControllerTest {
    @isTest
    static void testUpdateAccountData_Subscribed() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Call the updateAccountData method with isSubscribed as true
        Account updatedAccount = subscribeMeController.updateAccountData(acc.Id, true, 'US', 'English', '00000000');

        // Verify that the account is updated correctly
        System.assertEquals(false, updatedAccount.PersonHasOptedOutOfEmail);
        System.assertEquals(true, updatedAccount.B2C_Add_To_Email_List__pc);
        System.assertEquals('US', updatedAccount.Marketing_Country_Code__pc);
        System.assertEquals('express', updatedAccount.Marketing_Consent_Status__pc);
        System.assertEquals('Service Cloud', updatedAccount.Marketing_Source_Location__pc);
        System.assertEquals('CSR', updatedAccount.Marketing_Subscription_Source__pc);
        System.assertEquals('English', updatedAccount.Preferred_Lang__pc);
        System.assertEquals('00000000', updatedAccount.PersonMobilePhone);
    }

    @isTest
    static void testUpdateAccountData_Unsubscribed() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Call the updateAccountData method with isSubscribed as false
        Account updatedAccount = subscribeMeController.updateAccountData(acc.Id, false, 'US', 'English', '000000000');

        // Verify that the account is updated correctly
        System.assertEquals(true, updatedAccount.PersonHasOptedOutOfEmail);
        System.assertEquals(false, updatedAccount.B2C_Add_To_Email_List__pc);
        System.assertEquals('Unsubscribed', updatedAccount.Marketing_Consent_Status__pc);
    }

    @isTest
    static void testGetAccountData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Call the getAccountData method
        Account returnedAccount = subscribeMeController.getAccountData(acc.Id);

        // Verify that the correct account is returned
        System.assertEquals(acc.Id, returnedAccount.Id);
    }

    @isTest
    static void testGetMetaData() {
        // Call the getMetaData method
        List<Country_Code__mdt> metaData = subscribeMeController.getMetaData();

        // Verify that metadata records are returned
        System.assertNotEquals(0, metaData.size());
    }
}