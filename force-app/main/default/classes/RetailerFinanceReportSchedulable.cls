global class RetailerFinanceReportSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc) {
        // Retrieve a list of all finance report regions
        List<Finance_Report_Setting__mdt> lstReportSetting = [SELECT MasterLabel, To__c, CC__c, Supported_Region__c FROM Finance_Report_Setting__mdt];
        
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
    }
}