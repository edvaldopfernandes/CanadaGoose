/*
    * Test Class: Test_BatchApexErrorEventHandler
    * --------------------
    * Batch class :- Test_BatchApexErrorEventHandler
    *
    *  Author : Venkata Kalyan
    *  returns: N/A
*/

@isTest
public class Test_BatchApexErrorEventHandler {

    @testsetup
    static void testsetup(){
    	Batch_Apex_Error_Settings__c apexError = new Batch_Apex_Error_Settings__c(
                                                  SetupOwnerId=UserInfo.getUserId(),
                                                  Send_Errors_To__c ='test@test.com',
                                                  Store_Errors_in_Custom_Object__c = TRUE,
      											  Update_Box_Case_Folder_Record__c = TRUE);
        upsert apexError;
   

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
        insert cas;
        
        Box_Case_Folder__c boxCaseFolder = new Box_Case_Folder__c();
        boxCaseFolder.Box_Folder_Id__c = '123424324234';
        boxCaseFolder.Related_Case__c = cas.id;
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
                list<Box_Case_Folder__c> listOfBoxFolder = new list<Box_Case_Folder__c>();
        		BatchApexErrorEventHandler handler = new BatchApexErrorEventHandler();
                listOfBoxFolder =[SELECT Id FROM Box_Case_Folder__c LIMIT 1 ];
        		list<BatchApexErrorEvent> errorEvents = new List <BatchApexErrorEvent>();
            	Batch_Apex_Error_Settings__c setting = Batch_Apex_Error_Settings__c.getInstance(userInfo.getUserId());
        		Database.executeBatch(new BatchToPushAttachmentsintoBOX());
                AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, 
                                  TotalJobItems, CreatedBy.Email FROM AsyncApexJob LIMIT 1];
                BatchApexErrorEvent event = new BatchApexErrorEvent(Phase='EXECUTE',
                                                                    AsyncApexJobId = a.id,Message='Errrorss',
                                                                    ExceptionType ='System.Type Exception',
                                                                    jobScope= listOfBoxFolder[0].id,
                                                                    StackTrace= 'apex class not working');
                    
                Database.SaveResult sr = EventBus.publish(event); 
                System.assertEquals(sr.success,TRUE);
                Test.getEventBus().deliver();
                errorEvents.add(event);
                handler.copyErrorsToSObject(errorEvents);
                handler.emailErrors(errorEvents,'test@test.com');
        		handler.updateBoxFolderRecord(errorEvents);
      Test.stopTest();
        
        
    }

}