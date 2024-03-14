@isTest
private class InventoryTriggerHandlerTest {
    private static final String SMART_SKU = '9ybEPfMTGwMJ4UKhmp';

    static testMethod void testSyncInventoryUpload() {
        Test.startTest(); 
        Inventory__c invt = TestDataFactory.createTestInventory(SMART_SKU, true);
        
        Inventory__c testInvt = [SELECT Id, Name, Smart_SKU__c FROM Inventory__c WHERE Smart_SKU__c = :SMART_SKU limit 1];
        
        System.assertEquals(testInvt.Smart_SKU__c, testInvt.Name, 'Name field must match Smart SKU value.');
        
        Inventory__c invt2 = invt.clone(false, false, false, false);
        invt2.Available_Quantity__c = 15;
        invt2.Upload_Operation__c = 'Add';
        
        upsert invt2 Smart_SKU__c;
        Test.stopTest(); 
        
        testInvt = [SELECT Id, Name, Smart_SKU__c, Available_Quantity__c FROM Inventory__c WHERE Name = :SMART_SKU limit 1];
        
        System.assertEquals(115, testInvt.Available_Quantity__c, 'Available quantity must match the addition of the two inventory counts.');
    }
}