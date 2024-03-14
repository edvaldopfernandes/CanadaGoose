@isTest
private class CDLTriggerTest {

    @isTest
    static void TriggerTest() {
        
       Account ac1 = TestDataFactory.createTestAccount(false);
        ac1.ShippingCity = 'Houston';
        ac1.ShippingPostalCode = '77057';
        ac1.ShippingState = 'Texas';
        ac1.ShippingStateCode = 'TX';
        ac1.ShippingCountryCode = 'US';
        ac1.ShippingCountry = 'United States';
        ac1.Currency__c = 'USD';
        insert ac1;
        
        Contact ct1 = TestDataFactory.createTestContact('OneSourceTest', ac1.Id, true);
        
        Repair_Facility__c rf1 = TestDataFactory.createTestRepairFacility('77057','Elk Grove Village','IL','US',true);
        
        Case cs1 = TestDataFactory.createTestCase(ac1.Id, ct1.Id, false);
        cs1.Repair_Facility__c=rf1.Id;
        insert cs1;
        
        String content = 'Hello';
        ContentNote note = new ContentNote(
            Title = 'Test',
            Content = Blob.valueOf(content)
        );
        insert note;
        
        ContentDocumentLink testNote = new ContentDocumentLink();
        testNote.ContentDocumentId = note.id;
        testNote.LinkedEntityId = cs1.id;
        testNote.sharetype = 'I';
        insert testNote;
        system.assert((note.id != null));
    }
}