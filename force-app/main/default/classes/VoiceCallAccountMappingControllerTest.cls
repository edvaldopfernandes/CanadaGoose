@isTest
public class VoiceCallAccountMappingControllerTest {
    
    @isTest
    private static void vcAccountLinkCreationTest(){
        
        Account a = new Account(
            RecordTypeId = [
                SELECT  Id
                FROM    RecordType
                WHERE   SobjectType='Account'
                AND     IsPersonType=TRUE
                LIMIT   1
            ].Id,
            LastName = 'lastname',
            B2C_Customer_No__pc = '123',
            
            PersonEmail = 'a@a.com',
            B2C_Disable_Integration__pc = false
        );
        
        // Insert the test account record
        Database.insert(a);
        
        
        VoiceCall oVc = new VoiceCall();
        oVc.CallCenterId = [Select Id From callcenter LIMIT 1].Id;
        oVc.VendorType = 'ContactCenter';        
        oVc.CallStartDateTime = system.now();
        oVc.CallEndDateTime = system.now();
        oVc.FromPhoneNumber = '+14699875672';
        oVc.ToPhoneNumber = '+18006077550';
        oVc.CallType = 'Inbound';
        oVc.Call_Disposition_Category__c = 'COLLAB/COLLECTION';
        oVc.Call_Disposition_Sub_Category__c = 'COLLAB/COLLECTION - NBA';
        oVc.Related_Person_Account__c = a.Id;                                                                                         
        Insert oVc;
        
        VoiceCall oVc2 = new VoiceCall();
        oVc2.CallCenterId = [Select Id From callcenter LIMIT 1].Id;
        oVc2.VendorType = 'ContactCenter';        
        oVc2.CallStartDateTime = system.now();
        oVc2.CallEndDateTime = system.now();
        oVc2.FromPhoneNumber = '+14699875672';
        oVc2.ToPhoneNumber = '+18006077550';
        oVc2.CallType = 'Inbound';
        oVc2.Call_Disposition_Category__c = 'COLLAB/COLLECTION';
        oVc2.Call_Disposition_Sub_Category__c = 'COLLAB/COLLECTION - NBA';
        Insert oVc2;
        
        Account a2 = new Account(
            RecordTypeId = [
                SELECT  Id
                FROM    RecordType
                WHERE   SobjectType='Account'
                AND     IsPersonType=TRUE
                LIMIT   1
            ].Id,
            LastName = 'lastname2',
            B2C_Customer_No__pc = '12223',
            
            PersonEmail = 'a@a2.com',
            B2C_Disable_Integration__pc = false
        );
        
        Test.startTest();
            VoiceCallAccountMappingController.findPersonAccRecord(oVc2.Id);
            VoiceCallAccountMappingController.createNewPersonAccountandLink(a2, oVc2.Id);          
            VoiceCallAccountMappingController.searchByPersonEmail('a@a.com');                
            VoiceCallAccountMappingController.findPersonAccRecord(oVc.Id); 
        Test.StopTest();
        
        
    }
  
}