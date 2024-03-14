global class RetailerFinanceReportBatchable implements Database.Batchable<sObject>, Database.Stateful
{
    // Public parameters used for the filename and email message
    public String sRegionName;
    public List<String> lstToAddress;
    public List<String> lstCCAddress;
    public List<String> lstSupportedRegions;

    // Private parameters used to build the final output file
    private List<Inspection_Result__c> lstInspectionResultToInvoice = new List<Inspection_Result__c>();
    private String csvHeader = 'Date Opened,Case Number,Account Number,Account Name,Style,Style #,Colour,Size,Under Warranty,Accept Charges?,List Price,Total Discount Value,Total Price,Currency,Repair,Shipping Country,Shipping State/Province,Shipping Zip/Postal Code,Retailer Customer Reference #\n';
    private String csvBody = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Build the query that will be used to get the retailer invoices
        String query = 
            'SELECT Case__r.CreatedDate, Case__r.CaseNumber, Case__r.Style__r.Name, Case__r.StyleNumber__c, Case__r.Colour__c, Case__r.Size__c' +
            '	, Case__r.Accept_Charges__c, Case__r.Retailer_Customer_Reference__c' +
            '	, Case__r.Account.Account_Number__c, Case__r.Account.Name, Case__r.Account.ShippingCountry' +
            '	, Case__r.Account.ShippingPostalCode, Case__r.Account.ShippingState' +
            '	, Id, Under_Warranty__c, List_Price__c, Total_Discount_Value__c, Price__c, Currency__c, Status__c, Repair__r.Name' +
            ' FROM Inspection_Result__c' +
            ' WHERE Status__c IN (\'Ready for Repair\', \'In progress\', \'Completed\')' +
            ' 	AND RecordType.DeveloperName = \'Repair\'' +
            ' 	AND Case__r.Account.RecordType.DeveloperName = \'Retailer\'' +
            ' 	AND Case__r.Region__c IN (\'' + String.join(lstSupportedRegions, '\',\'') + '\')' +
            (Test.isRunningTest() ? '' : ' 	AND CreatedDate < TODAY') +
            '	AND Under_Warranty__c = FALSE';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Inspection_Result__c> scope) {
        for(Inspection_Result__c inspResult : scope) {
            // Add a record for the final update
            lstInspectionResultToInvoice.add(new Inspection_Result__c(Id = inspResult.Id, Status__c = 'Invoiced'));

            // Concatenate the record to the main CSV body parameter
            csvBody = csvBody +
                inspResult.Case__r.CreatedDate.format('yyyy/MM/dd') + ',' +
                inspResult.Case__r.CaseNumber + ',' +
                inspResult.Case__r.Account.Account_Number__c + ',"' +
                inspResult.Case__r.Account.Name + '","' +
                inspResult.Case__r.Style__r.Name + '","' +
                (String.isBlank(inspResult.Case__r.StyleNumber__c) ? '' : inspResult.Case__r.StyleNumber__c) + '","' +
                (String.isBlank(inspResult.Case__r.Colour__c) ? '' : inspResult.Case__r.Colour__c) + '",' +
                (String.isBlank(inspResult.Case__r.Size__c) ? '' : inspResult.Case__r.Size__c) + ',' +
                (inspResult.Under_Warranty__c ? 'TRUE' : 'FALSE') + ',' +
                (inspResult.Case__r.Accept_Charges__c ? 'TRUE' : 'FALSE') + ',' +
                inspResult.List_Price__c + ',' +
                inspResult.Total_Discount_Value__c + ',' +
                inspResult.Price__c + ',"' +
                inspResult.Currency__c + '","' +
                inspResult.Repair__r.Name + '","' +
                inspResult.Case__r.Account.ShippingCountry + '","' +
                (String.isBlank(inspResult.Case__r.Account.ShippingPostalCode) ? '' : inspResult.Case__r.Account.ShippingPostalCode) + '","' +
                (String.isBlank(inspResult.Case__r.Account.ShippingState) ? '' : inspResult.Case__r.Account.ShippingState) + '","' +
                (String.isBlank(inspResult.Case__r.Retailer_Customer_Reference__c) ? '' : inspResult.Case__r.Retailer_Customer_Reference__c) + '"\n';
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Verify that were records in this batch run
        if (!lstInspectionResultToInvoice.isEmpty()) {
            // First update the inspection result to mark them invoiced to avoid pulling them on the next batch run
            update lstInspectionResultToInvoice;
            
            // If update succeeds, then send the email including the attachment with the exported data
            String sEmailSubject = 'Warranty Retailer Invoices - ' + sRegionName + ' - ' + Datetime.now().addDays(-7).format('yyyy/MM/dd') + ' - ' + Datetime.now().addDays(-1).format('yyyy/MM/dd');
            
            blob csvBlob = Blob.valueOf(csvHeader + csvBody);
            
            // Build the CSV Attachment
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            csvAttachment.setFileName(sEmailSubject + '.csv');
            csvAttachment.setBody(csvBlob);
            
            // Build the email message record
            Messaging.SingleEmailMessage emailMsg =new Messaging.SingleEmailMessage();
            emailMsg.setSubject(sEmailSubject);
            emailMsg.setToAddresses(lstToAddress);
            if (!lstCCAddress.isEmpty()) {
                emailMsg.setCcAddresses(lstCCAddress);
            }
            emailMsg.setPlainTextBody('Please find attached the ' + sEmailSubject);
            emailMsg.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttachment});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
        }
    }
}