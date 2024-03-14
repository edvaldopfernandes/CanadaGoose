@isTest
private class AcceptClaimChargesControllerTest {
    private static final String LAST_NAME = 's8XnKxChMmKvA4zRGe';
    
    @testSetup
    static void Init() { 
        Account acc = TestDataFactory.createTestAccount(true);
       
        Contact cont = TestDataFactory.createTestContact(LAST_NAME, acc.Id, true);
                          
        TestDataFactory.createTestCase(acc.Id, cont.Id, true);
    }
    
    static testMethod void testAcceptCharges() {
        Case testCase = [SELECT ID FROM Case WHERE Contact.LastName = :LAST_NAME];
        
        Test.startTest();
        AcceptClaimChargesController.acceptCharges(testCase.Id);
        Test.stopTest(); 
        
        testCase = [SELECT Accept_Charges__c FROM Case WHERE Contact.LastName = :LAST_NAME];
        System.assertEquals(true, testCase.Accept_Charges__c, 'Case Accept Charges must be set to true.');
    }
}