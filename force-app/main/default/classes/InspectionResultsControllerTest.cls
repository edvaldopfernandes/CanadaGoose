@isTest
private class InspectionResultsControllerTest {
    private static final String CONTACT_LAST_NAME = 'a4f6fa63c9a8f24f81';
    
    @isTest static void TestgetInspectionResult() {
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME,acc.Id,true);
        
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, con, true);
        system.debug(usr);
        
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        system.debug('Created Case');
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        system.debug('Updated Case with Repair facility');
        system.debug('Creating two inspection results in new status');
        system.debug(acc.Currency__c);
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        system.debug('Creating one inspection result in progress status');
        Inspection_Result__c inspectionResult3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        inspectionResult3.Status__c = 'In progress';
        insert inspectionResult3;
        
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        update cas;
        System.runAs(usr)
        {    
            Test.startTest();
            system.debug('getting Pending Inspection Results');
            List<Inspection_Result__c> InspectionResults2 = InspectionResultsUtility.getPendingInspectionResults(cas.Id);
            system.debug('getting Taxed Inspection results');
            InspectionResultsUtility.TaxedInspectionResultStruct irstruct = InspectionResultsController.getTaxedInspectionResults(cas.Id);
            Test.stopTest();
            system.debug('Test Finished');
            if (irstruct != null) {
                List<Inspection_Result__c> InspectionResults = irstruct.InspectionResults;
                System.assertEquals(InspectionResults.size(), 2);
            }
        }
    }
}