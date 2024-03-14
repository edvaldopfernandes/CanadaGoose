/*
    * Test Class: Test_BatchToDeleteArchivedAttachments 
    * --------------------
    * Batch class :- BatchToDeleteArchivedAttachments
    *
    *  Author : Venkata Kalyan
    *  returns: N/A
*/

@isTest
public class Test_BatchToDeleteArchivedAttachments {
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
        boxCaseFolder.Is_batch_for_attachments_failes__c = false;
        insert boxCaseFolder;
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = userinfo.getUserEmail(),
                                      FromName = userinfo.getName(),
                                      ToAddress = userinfo.getUserEmail(),
                                      Subject = 'Test Subject',
                                      TextBody = 'Testing the body text',
                                      HtmlBody = 'Testing the body text',
                                      ParentId = cas.Id)); 
        insert newEmail;
        
        Attachment att = new Attachment(ParentId = newEmail[0].id,
                                        Name ='Testing the attachments',
                                        body = blob.valueOf('Testing the attachment body'));
        insert att;
        
    }
    @isTest
    public static void testMethodToCheckCoverage(){
        Test.startTest();
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        list<Box_Case_Folder__c> listOfCases = [SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE Is_batch_for_attachments_failes__c = false  
                                         AND Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_Case__r.ClosedDate < :range.Range_End_Date__c];
        system.assertEquals(1, listOfCases.size());
        list<EmailMessage> emailList = [SELECT id, FromAddress, ToAddress, FromName, Subject,
                                        TextBody, HtmlBody, ParentId FROM EmailMessage];
        system.assertEquals(1, emailList.size());
        list<attachment> listOfAtt = [SELECT Id, ParentId, Name, body FROM Attachment];
        system.assertEquals(1, listOfAtt.size());
        BatchToDeleteArchivedAttachments batchclass = new BatchToDeleteArchivedAttachments();
        Database.executeBatch(batchclass, 200);
        Test.stopTest();
        
    }
    
}