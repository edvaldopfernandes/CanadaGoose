@isTest
public class GetOrderDataTest {
    @isTest
    public static void testGetOrderDetails() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Order oldOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today());
        insert oldOrder;

        // Call the getOrderDetails method
        List<Order> orderDetails = getOrderData.getOrderDetails(testAccount.Id);

        // Verify that the method returns the expected results
        System.assertEquals(1, orderDetails.size(), 'One Order record should be returned.');
        System.assertEquals(oldOrder.Id, orderDetails[0].Id, 'Returned Order should match the test Order.');

        // Add more assertions if needed
    }

    @isTest
    public static void testGetOrderLineItemDetails() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Order related to the Account
        Order testOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today());
        insert testOrder;

        // Create a test Order Line Item related to the Order
        Order_Line_Item__c testOrderLineItem = new Order_Line_Item__c(
            Order__c = testOrder.Id
            // Set other required fields as needed
        );
        insert testOrderLineItem;

        // Call the getOrderLineItemDetails method
        List<Order_Line_Item__c> orderLineItemDetails = getOrderData.getOrderLineItemDetails(testOrder.Id);

        // Verify that the method returns the expected results
        System.assertEquals(1, orderLineItemDetails.size(), 'One Order Line Item record should be returned.');
        System.assertEquals(testOrderLineItem.Id, orderLineItemDetails[0].Id, 'Returned Order Line Item should match the test Order Line Item.');

        // Add more assertions if needed
    }
}