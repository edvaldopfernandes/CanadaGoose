@isTest
private class InspectionResultsUtilityTest {
    private static final String CONTACT_LAST_NAME1 = '227d5675cf2230043f';
    private static final String CONTACT_LAST_NAME2 = '01593011050a137c45';
    private static final String CONTACT_LAST_NAME3 = '20391411befcdde4ee';

    @isTest static void testInsert(){
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult1 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        Inspection_Result__c inspectionResult2 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        Inspection_Result__c inspectionResult3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        inspectionResult3.Status__c = 'In progress';
        insert inspectionResult3;
        
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        update cas;

        Inspection_Result__c ir1 = [SELECT Id FROM Inspection_Result__c WHERE Id =: inspectionResult1.Id];
        Inspection_Result__c ir2 = [SELECT Id FROM Inspection_Result__c WHERE Id =: inspectionResult2.Id];
        Inspection_Result__c ir3 = [SELECT Id FROM Inspection_Result__c WHERE Id =: inspectionResult3.Id];

        System.assertNotEquals(ir1,null,'error ir1');
        System.assertNotEquals(ir2,null,'error ir2');
        System.assertNotEquals(ir3,null,'error ir3');

    }
    
    @isTest static void testGetTaxedInspectionResults() {
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
            
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        Inspection_Result__c inspectionResult3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        inspectionResult3.Status__c = 'In progress';
        insert inspectionResult3;
        
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        update cas;
        
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, con, false);
        usr.LanguageLocaleKey = 'en_US';
        insert usr;	
        
        
       
        System.runAs(usr)
        {
            Test.startTest();
            
            List<Inspection_Result__c> InspectionResults = InspectionResultsUtility.getPendingInspectionResults(cas.Id);
            InspectionResultsUtility.TaxedInspectionResultStruct tirs = InspectionResultsUtility.getTaxedInspectionResults(cas.Id);
            InspectionResultsUtility.TaxedInspectionResultStruct tirpost = InspectionResultsUtility.PostTaxedInspectionResults(cas.Id);
            
            
            Test.stopTest();
            
            System.assertEquals(tirs.InspectionResults.size(), 2);
            System.assertEquals(tirpost.InspectionResults.size(), 2);
        }
    }
    
    @isTest static void testInspectionResults() {
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, con, false);
        usr.LanguageLocaleKey = 'en_US';
        insert usr;	
        
       
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
        Inspection_Result__c inspectionResult3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        inspectionResult3.Status__c = 'In progress';
        insert inspectionResult3;
        
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        update cas;
         System.runAs(usr)
        {    
        
        
        
       
        
            Test.startTest();
            List<Inspection_Result__c> InspectionResults = InspectionResultsUtility.getInspectionResults(cas.Id,false);
            Test.stopTest();
            
            System.assertEquals(InspectionResults.size(), 1);
        }
    }
    
    @isTest static void testGetPendingPaymentNoResults() {
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
            
        Inspection_Result__c inspectionResult3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        inspectionResult3.Status__c = 'In progress';
        insert inspectionResult3;
        
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Check In With Customer';
        update cas;
        
        Test.startTest();
        List<Inspection_Result__c> InspectionResults = InspectionResultsUtility.getPendingInspectionResults(cas.Id);
        Test.stopTest();
        
        System.assertEquals(InspectionResults, null);
    }
}