@isTest
public class OrderTriggerTest {
    @isTest
    public static void testOrderAfterUpdate() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Order
        Order testOrder = new Order(
            AccountId = testAccount.Id
            // Set other required fields as needed
        );
        insert testOrder;

        // Modify the test Order (simulate an update)
        testOrder.Status = 'Shipped';
        update testOrder;

        // Verify that the trigger handler logic was called and performed as expected
        // You can add more assertions to validate your trigger handler logic

        // Add assertions as needed
    }

    @isTest
    public static void testOrderAfterInsert() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Order
        Order testOrder = new Order(
            AccountId = testAccount.Id
            // Set other required fields as needed
        );

        // Insert the test Order
        Test.startTest();
        insert testOrder;
        Test.stopTest();

        // Verify that the trigger handler logic was called and performed as expected
        // You can add more assertions to validate your trigger handler logic

        // Add assertions as needed
    }
}