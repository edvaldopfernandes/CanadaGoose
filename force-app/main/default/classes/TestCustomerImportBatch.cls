@IsTest
public class TestCustomerImportBatch {
    
    //TODO take a second look at if these test cases will fail with data in the org

    @IsTest
    public static void testBulkCustomerImportClearScheduler() {
        String cronExpr = '0 0 0 15 3 ? 2055';
        List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob];
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
        Test.startTest();
        System.schedule('myJobTestJobName', cronExpr, new BulkCustomerImportClearScheduler());
        Test.stopTest();
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('BulkCustomerImportClearScheduler', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('BulkCustomerImportClear', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
    }

    @IsTest
    public static void testBulkCustomerImportScheduler() {
        String cronExpr = '0 0 0 15 3 ? 2055';
        List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob];
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
        Test.startTest();
        System.schedule('myJobTestJobName', cronExpr, new CustomerImportScheduler());
        Test.stopTest();
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('CustomerImportScheduler', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('BulkCustomerImporter', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');

    }

    @IsTest
    public static void testBulkCustomerImportClearExecute() {
        List<Customer_Data_Temp_Store__c> cdtsList = new List<Customer_Data_Temp_Store__c>();
        for(Integer i = 0; i < 200; i++) {
            Customer_Data_Temp_Store__c cdts = new Customer_Data_Temp_Store__c();
            cdts.Has_Been_Processed__c = true; 
            cdts.Email__c = i + 'test@gmail.com';
            cdtsList.add(cdts);
        }
        insert cdtsList;
        Test.startTest();
        BulkCustomerImportClear bcic = new BulkCustomerImportClear();
        //Aritificially set the day to check two days in advance
        bcic.oneDayBefore = Datetime.now().addDays(2);
        Database.executeBatch(bcic);
        Test.stopTest();
        cdtsList = [SELECT Id FROM Customer_Data_Temp_Store__c WHERE Has_Been_Processed__c = true];
        System.assertEquals(0, cdtsList.size(), 'Expected size should be zero');
    }

    @IsTest
    public static void testBulkCustomerImporter() {
        List<Customer_Data_Temp_Store__c> cdtsList = new List<Customer_Data_Temp_Store__c>();
        Customer_Data_Temp_Store__c cdts = new Customer_Data_Temp_Store__c();
        cdts.Has_Been_Processed__c = true; 
        cdts.Email__c = 'testBulkCustomerImporter@gmail.com';
        cdts.Origin__c = 'Flagship Store';
        cdts.Consent_Date__c = System.now();
        cdts.Marketing_Subscription_Source__c = 'test';
        cdts.Marketing_Consent_Status__c = 'express';
        cdts.City__c = 'Maple Ridge';
        cdts.Is_Friends_Family_Lead__c = true;
        cdts.CountryCode__c = 'CA';
        cdts.State__c = 'British Columbia';
        cdts.Marketing_Source_Location__c = 'test';
        cdts.Preferred_Lang__c = 'FR';
        cdts.Generations_Trade_In__c = true;
        cdts.Gender_Id__c = 1;
        cdts.Has_Been_Processed__c = false;
        cdtsList.add(cdts);
        insert cdtsList;
        Test.startTest();
        BulkCustomerImporter bcic = new BulkCustomerImporter();
        Database.executeBatch(bcic);
        Test.stopTest();
        List<Account> accList = [SELECT Id FROM Account WHERE PersonEmail = 'testBulkCustomerImporter@gmail.com'];
        System.assertEquals(1, accList.size(), 'New test account should be created');
    }
    @IsTest
    public static void testBulkCustomerImporterUpdate() {
        List<Customer_Data_Temp_Store__c> cdtsList = new List<Customer_Data_Temp_Store__c>();
        List<Account> accUpList = new List<Account>();
        Customer_Data_Temp_Store__c cdts = new Customer_Data_Temp_Store__c();
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'New';
        acc.PersonEmail = 'testBulkCustomerImporterupdate@gmail.com';
        acc.Marketing_Consent_Status__pc = 'unconsented';
        accUpList.add(acc);
        insert accUpList;
        cdts.Has_Been_Processed__c = true; 
        cdts.Email__c = 'testBulkCustomerImporterupdate@gmail.com';
        cdts.Origin__c = 'Flagship Store';
        cdts.Is_Friends_Family_Lead__c = true;
        cdts.Consent_Date__c = System.now();
        cdts.Marketing_Subscription_Source__c = 'test';
        //cdts.Marketing_Consent_Status__c = 'express';
        cdts.City__c = 'Maple Ridge';
        cdts.CountryCode__c = 'CA';
        cdts.State__c = 'British Columbia';
        cdts.Marketing_Source_Location__c = 'test';
        cdts.Preferred_Lang__c = 'FR';
        cdts.Generations_Trade_In__c = true;
        cdts.Gender_Id__c = 1;
        cdts.Has_Been_Processed__c = false;
        cdtsList.add(cdts);
        insert cdtsList;
        Test.startTest();
        BulkCustomerImporter bcic = new BulkCustomerImporter();
        Database.executeBatch(bcic);
        Test.stopTest();
        List<Account> accList = [SELECT Id FROM Account WHERE PersonEmail = 'testBulkCustomerImporterupdate@gmail.com'];
        System.assertEquals(1, accList.size(), 'account should be updated');
    }
    @IsTest
    public static void testBulkCustomerImporterUpdateSecond() {
        List<Customer_Data_Temp_Store__c> cdtsList = new List<Customer_Data_Temp_Store__c>();
        List<Account> accUpList = new List<Account>();
        Customer_Data_Temp_Store__c cdts = new Customer_Data_Temp_Store__c();
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'New';
        acc.PersonEmail = 'testBulkCustomerImporterSecond@gmail.com';
        acc.Marketing_Consent_Status__pc = 'express';
        accUpList.add(acc);
        insert accUpList;
        cdts.Has_Been_Processed__c = true; 
        cdts.Email__c = 'testBulkCustomerImporterSecond@gmail.com';
        cdts.Is_Friends_Family_Lead__c = true;
        cdts.Origin__c = 'Flagship Store';
        cdts.Consent_Date__c = System.now();
        cdts.Marketing_Subscription_Source__c = 'test';
        cdts.Marketing_Consent_Status__c = 'express';
        cdts.City__c = 'Maple Ridge';
        cdts.CountryCode__c = 'CA';
        cdts.State__c = 'British Columbia';
        cdts.Marketing_Source_Location__c = 'test';
        cdts.Preferred_Lang__c = 'FR';
        cdts.Generations_Trade_In__c = true;
        cdts.Gender_Id__c = 1;
        cdts.Has_Been_Processed__c = false;
        cdtsList.add(cdts);
        insert cdtsList;
        Test.startTest();
        BulkCustomerImporter bcic = new BulkCustomerImporter();
        Database.executeBatch(bcic);
        Test.stopTest();
        List<Account> accList = [SELECT Id FROM Account WHERE PersonEmail = 'testBulkCustomerImporterSecond@gmail.com'];
        System.assertEquals(1, accList.size(), 'account should be updated');
    }
}