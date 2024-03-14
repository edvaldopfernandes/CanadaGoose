@isTest
private class RetailerFinanceReportSchedulableTest {
    private static final String LAST_NAME = '3ANvR8GmPq5Gy9sc7c';
    
    @testSetup
    static void Init() { 
        Account acc = TestDataFactory.createTestRetailerAccount(true);
        
        Contact cont = TestDataFactory.createTestContact(LAST_NAME, acc.Id, true);
        
        Repair_Facility__c repFac= TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);

        Case cas = TestDataFactory.createTestCase(acc.Id, cont.Id, false);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;

        Repair__c rep = TestDataFactory.createTestRepair(true);

        Inspection_Result__c insp1 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        insp1.Status__c = 'In progress';
        insert insp1;
        
        Inspection_Result__c insp2 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        insp2.Status__c = 'Ready for Repair';
        insert insp2;

        Inspection_Result__c insp3 = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, false);
        insp3.Status__c = 'Completed';
        insert insp3;

        TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);
    }
    
    static testmethod void testSchedulable() {
        Datetime dt = Datetime.now().addSeconds(20);
        String hour = String.valueOf(dt.hour());
        String min = String.valueOf(dt.minute()); 
        String ss = String.valueOf(dt.second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        Test.startTest();
        RetailerFinanceReportSchedulable s = new RetailerFinanceReportSchedulable(); 
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        Test.stopTest();
    }
    
    static testmethod void testBatchable() {
        List<Finance_Report_Setting__mdt> lstReportSetting = [SELECT MasterLabel, To__c, CC__c, Supported_Region__c FROM Finance_Report_Setting__mdt Where MasterLabel = 'North America'];
        
        Test.startTest();
        // Loop over the report regions to schedule a batch job to run
        for (Finance_Report_Setting__mdt repSetting : lstReportSetting) {
            RetailerFinanceReportBatchable batchReport = new RetailerFinanceReportBatchable ();
            
            // Provide required parameters to query certain region and email output to the specified email addresses
            batchReport.sRegionName = repSetting.MasterLabel;
            batchReport.lstToAddress = new List<String> {repSetting.To__c};
            batchReport.lstCCAddress = repSetting.CC__c.split(',');
            batchReport.lstSupportedRegions = repSetting.Supported_Region__c.split(',');
            
            database.executebatch(batchReport);
        }
        Test.stopTest();
        
        List<Inspection_Result__c> lstInvoicedInsp = [SELECT Id FROM Inspection_Result__c WHERE Case__r.Contact.LastName = :LAST_NAME AND Status__c = 'Invoiced'];
        System.assertEquals(3, lstInvoicedInsp.size(), '3 inspection results must be marked invoiced');
        
        List<Inspection_Result__c> lstNotInvoicedInsp = [SELECT Status__c FROM Inspection_Result__c WHERE Case__r.Contact.LastName = :LAST_NAME AND Status__c != 'Invoiced'];
        System.assertEquals(1, lstNotInvoicedInsp.size(), '1 inspection result\'s status must not change');
        System.assertEquals('New', lstNotInvoicedInsp[0].Status__c, 'Inspection result\'s must remain New');
    }
}