global class BulkCustomerImportClear implements Database.Batchable<SObject>{
    
    @TestVisible public Datetime oneDayBefore = Datetime.now().addDays(-1);

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(oneDayBefore);
        String query = 'select State__c, Origin__c, Email__c, Has_Been_Processed__c, Marketing_Subscription_Source__c, Marketing_Consent_Status__c, First_Name__c, Last_Name__c, B2C_CustomerList__c, City__c, Consent_Date__c, Contact__c, CountryCode__c from Customer_Data_Temp_Store__c WHERE LastModifiedDate < :oneDayBefore';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Customer_Data_Temp_Store__c> records) {
        List<Customer_Data_Temp_Store__c> recordsToRemove = new List<Customer_Data_Temp_Store__c>();
        for(Customer_Data_Temp_Store__c cdts : records) {
            if(cdts.Has_Been_Processed__c == true) {
                recordsToRemove.add(cdts);
            }
        }
        try {
            delete recordsToRemove;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
  
    global void finish(Database.BatchableContext bc) {

    }

}