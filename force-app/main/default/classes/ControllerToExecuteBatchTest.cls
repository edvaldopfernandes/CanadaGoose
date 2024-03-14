@isTest public class ControllerToExecuteBatchTest {
	 @isTest
    public static void testControllerToExecuteBatch() {
        Test.startTest();
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            
            Account acc =[SELECT id FROM Account LIMIT 1];
            String msg = ControllerToExecuteBatch.executeBatch(acc.id);
        Test.stopTest();
    }
}