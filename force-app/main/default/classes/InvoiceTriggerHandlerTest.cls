@isTest
private class InvoiceTriggerHandlerTest {
    private static final String CONTACT_LAST_NAME = 'fwc3nGr44xZyGMtrCB';

    @isTest static void testInsertInvoice(){
        //Initialize
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
           
        Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Style__c style = new Style__c();
        style.name ='57576M';
        insert style;
        
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME, acc.Id, true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac = TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult1 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        Inspection_Result__c inspectionResult2 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);

        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        cas.Tag_Removed__c = true;
        cas.Style__c =style.id;
        update cas;
        
        Test.startTest();
        Invoice__c inv = TestDataFactory.createTestInvoice(cas.Id, true);
        Test.stopTest();
        
        List<Inspection_Result__c> lstInspectionResult = [SELECT Id FROM Inspection_Result__c WHERE Invoice__c = :inv.Id];
  
        System.assertEquals(2, lstInspectionResult.size(), 'Two inspection results must be assigned to the new draft invoice.');
        
        // Update default language to french
        acc.Language__c = 'fr';
        update acc;
        TestDataFactory.createTestInvoice(cas.Id, true);
        
        // Update default language to german
        acc.Language__c = 'de';
        update acc;
        TestDataFactory.createTestInvoice(cas.Id, true);
        
        // Update default language to chinese
        acc.Language__c = 'zh_CN';
        update acc;
        Invoice__c inv2 = TestDataFactory.createTestInvoice(cas.Id, false);
        inv2.Payment_Method__c = 'visa';
        inv2.Status__c = 'Paid';
        insert inv2;
    }
}