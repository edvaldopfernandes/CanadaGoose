@isTest
public class PrintControllerTest {
    private static final String CONTACT_LAST_NAME1 = '227d5675cf3340043f';
    
    private static final String CONTACT_LAST_NAME2 = '227d5965cf3340043f';
    
    @isTest
    static void testgetLogisticsPrint()
    {
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME1,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult1 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        
       	Test.startTest();
		PrintController.CaseCountrySetting cseCounSet = PrintController.getLogisticsPrint(cas.Id);
        Test.stopTest();
 		
        system.assertEquals(cseCounSet.CounSet.ShippingIndicator, 'CA');
    }
    
    @isTest
    static void testgetPaidInspectionResults()
    {
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult1 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        inspectionResult1.Status__c = 'In progress';
        update inspectionResult1;
            
       	Test.startTest();
		List<Inspection_result__c> Inspections = PrintController.getPaidInspectionResults(cas.Id);
        Test.stopTest();
 		
        system.assertEquals(Inspections.size(), 1);   
    }
}