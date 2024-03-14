/*
    * Test Class: Test_BatchToPushEmailMessageIntoBox 
    * --------------------
    * Batch class :- BatchToPushEmailMessageIntoBox
    *
    *  Author : Venkata Kalyan
    *  returns: N/A
*/

@isTest
public class Test_BatchToPushEmailMessageIntoBox {
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
        cas.Status ='closed';
        upsert cas;
        
        Box_Case_Folder__c boxCaseFolder = new Box_Case_Folder__c();
        boxCaseFolder.Box_Folder_Id__c = '123424324234';
        boxCaseFolder.Related_Case__c = cas.id;
        insert boxCaseFolder;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = userinfo.getUserEmail(),
                                      FromName = userinfo.getName(),
                                      ToAddress = userinfo.getUserEmail(),
                                      Subject = cas.Id + 'Test Subject1',
                                      TextBody = 'Testing the body text1',
                                      HtmlBody = 'Testing the body text1',
                                      ParentId = cas.Id)); 
        newEmail.add(new EmailMessage(FromAddress = userinfo.getUserEmail(),
                                      FromName = userinfo.getName(),
                                      ToAddress = userinfo.getUserEmail(),
                                      Subject = cas.Id + 'Test Subject2',
                                      TextBody = 'Testing the body text2',
                                      HtmlBody = 'Testing the body text2',
                                      ParentId = cas.Id)); 
        insert newEmail;

    }
    @isTest
    public static void testMethodToCheckCoverage(){
        Test.startTest();
         Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        list<Box_Case_Folder__c> listOfCases = [SELECT Box_Folder_Id__c, 
                                                Related_Case__c, Related_Case__r.createdDate,
                                                Is_batch_for_attachments_failes__c FROM Box_Case_Folder__c];
        system.assertEquals(1, listOfCases.size());
        list<EmailMessage> emailList = [SELECT ParentId, Id, FromAddress, FromName, HtmlBody, 
                                            Subject,TextBody, ToAddress 
                                            FROM EmailMessage ORDER BY ParentID DESC];
        system.assertEquals(2, emailList.size());

        BatchToPushEmailMessageIntoBox batchclass = new BatchToPushEmailMessageIntoBox();
        Database.executeBatch(batchclass, 200);
        Test.stopTest();
        
    }
    
}