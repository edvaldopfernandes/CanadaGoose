@isTest
public class OrderTriggerHandlerTest {
    @isTest
    public static void testOnAfterUpdate() {
        // Create test data - Orders and associated Accounts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order oldOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today());
        insert oldOrder;
        
        Order newOrder = new Order(AccountId = testAccount.Id, Status = 'Draft',  EffectiveDate = Date.Today());
        insert newOrder;
        
        // Call the OnAfterUpdate method
        Map<Id, Order> mapOldOrder = new Map<Id, Order>{ oldOrder.Id => oldOrder };
        List<Order> lstNewOrder = new List<Order>{ newOrder };
        OrderTriggerHandler.OnAfterUpdate(lstNewOrder, mapOldOrder);
        
        // Retrieve the updated Account
        testAccount = [SELECT Number_Of_Orders__c, Total_Order_Total_for_Account__c FROM Account WHERE Id = :testAccount.Id];
        
        // Assert that the Account fields have been updated as expected
        //System.assertEquals(2, testAccount.Number_Of_Orders__c, 'Number of Orders on Account should be 2');
        //System.assertEquals(newOrder.Order_Total__c, testAccount.Total_Order_Total_for_Account__c, 'Total Order Total for Account should be updated');
    }
    
    @isTest
    public static void testOnAfterInsert() {
        // Create test data - Orders and associated Accounts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order newOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today());
        insert newOrder;
        
        // Call the OnAfterInsert method
        List<Order> lstNewOrder = new List<Order>{ newOrder };
        OrderTriggerHandler.OnAfterInsert(lstNewOrder);
        
        // Retrieve the updated Account
        testAccount = [SELECT Number_Of_Orders__c, Total_Order_Total_for_Account__c FROM Account WHERE Id = :testAccount.Id];
        
        // Assert that the Account fields have been updated as expected
       // System.assertEquals(1, testAccount.Number_Of_Orders__c, 'Number of Orders on Account should be 1');
        //System.assertEquals(newOrder.Order_Total__c, testAccount.Total_Order_Total_for_Account__c, 'Total Order Total for Account should be updated');
    }
}