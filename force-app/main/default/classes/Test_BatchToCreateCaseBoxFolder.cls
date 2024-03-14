/*
    * Test Class: Test_BatchToCreateCaseBoxFolder 
    * --------------------
    * Batch class :- BatchToCreateCaseBoxFolder
    *
    *  Author : Venkata Kalyan
    *  returns: N/A
*/

@isTest
public class Test_BatchToCreateCaseBoxFolder {
    @testsetup
    static void testsetup(){
        
        Batch_Archival_Range__c range = new Batch_Archival_Range__c();
        range.Name ='Date Range for Batch';
        range.Range_Start_Date__c = Date.today()-1;
        range.Range_End_date__c =  Date.today()+2;
        insert range;
        //Initialize
        Style__c style = new Style__c( Name = 'Test001');
        insert style;
        
        Account acc = TestDataFactory.createTestAccount(false);
        acc.ShippingStreet = '123 Test';
        acc.ShippingCity = 'Brasil';
        acc.ShippingState = 'Amazonas';
        acc.ShippingStateCode = 'AM';
        acc.ShippingCountry = 'Brazil';
        acc.ShippingCountryCode = 'BR';
        acc.ShippingPostalCode = '12345';
        insert acc;
        
        Contact con = TestDataFactory.createTestContact('Testuser12', acc.Id, true);
        
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac = TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        cas.Status = 'Closed';
        upsert cas;
        
        
              
    
    }
    @isTest
    public static void testonlyMethod1(){
        Test.startTest();
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        list<case> listOfCases = [SELECT Id FROM case WHERE ClosedDate > :range.Range_Start_Date__c 
                                         AND ClosedDate <:range.Range_End_Date__c];
        
        BatchToCreateCaseBoxFolder batchclass = new BatchToCreateCaseBoxFolder();
        Database.executeBatch(batchclass, 200);
        Test.stopTest();
        
    }
    
}