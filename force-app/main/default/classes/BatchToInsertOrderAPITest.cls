@isTest
public class BatchToInsertOrderAPITest {
    @isTest
    public static void testBatchToInsertOrderAPI1() {
        // Create a test Account and insert it
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order oldOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today());
        insert oldOrder;

        // Create a test BatchToInsertOrderAPI instance
        BatchToInsertOrderAPI batch = new BatchToInsertOrderAPI(testAccount.Id);

        // Start the batch job
        Database.executeBatch(batch);

        // Perform assertions as needed to verify the functionality
        // For example, you can query Orders and related records created by the batch
        List<Order> createdOrders = [SELECT Id FROM Order WHERE AccountId = :testAccount.Id];
        // Assert other related data as well

        // Add your assertions here
        System.assertEquals(1, createdOrders.size(), 'One Order should have been created.');
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new batchToInserOrderMock());
       
        OD_GetOrderByEmail order = BatchToInsertOrderAPI.performHttpRequest('testEmail@test.com');
         Test.stopTest();
    }
     @isTest
     public static void testBatchToInsertOrderAPI2() {
        // Create a test Account and insert it
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order oldOrder = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.Today(), CSRCreatedTheOrder__c = UserInfo.getUserId());
        insert oldOrder;

        string body ='{ "segment_id": 513,  "customer_id": "003DR00000nUg8zYAC", "customer_master": {'
        				+ '"customer_master_id": 1200056, "customer_name": "Sh Yz", "customer_first_name": "Sh", '
        				+ '"customer_last_name": "Yz", "email": "testsharif2@abc.com", "phone_no": "6478888889", '
        				+ '"customer_locale_id": "en_CA" }, "customer_orders": [{ "order_id": 1531174, "order_no": "DVCA_A00178451", '
        				+ '"payment_status": "Paid", "order_total": 1581.25,"sales_company": "CG_Canada", '
        				+ '"address": { "address1": "R-121 Ilsley Ave", "address2": "", "city": "Dartmouth", "state_code": "NS", "country_code": "CA", "postal_code": "B3B 1S4" '
        				+ '}, "customer_order_lines": [{ "order_line_id": 1, "order_id": 1531174, "order_no": "DVCA_A00178451", "product_id": 801688939992, '
            			+ ' "product_name": "Chilliwack Bomber Heritage", "quantity": 1.0,"size": "S","color_name": "Stormy Sky",  '
            			+ '"base_price": 1375.00, "item_id": "7999L", "item_text": "Chilliwack Bomber", "price": 1375.00, "price_after_order_discount": 1375.00,'
            			+ '"tax": 206.25, "tax_basis": 0.0, "tax_class_id": "TPP", "tax_rate": 0.00, "parent_order_id": "" }], '
						+ '"invoice": [{ "invoice_id": "16637758033161498032", "invoice_status": "Closed", "invoice_total": 2912.95,"order_line_id": 1}],'
						+ '"created_by": "Customer"  }] }';
        Test.startTest();
         String csrId = String.valueOf(UserInfo.getUserId());
         BatchToInsertOrderAPI.updateCountOfOrders(csrId);
    
        OD_GetOrderByEmail order = new OD_GetOrderByEmail();
        order = OD_GetOrderByEmail.parse(body);
       
         BatchToInsertOrderAPI.populateData(order ,testAccount);
         Test.stopTest();
    }
}