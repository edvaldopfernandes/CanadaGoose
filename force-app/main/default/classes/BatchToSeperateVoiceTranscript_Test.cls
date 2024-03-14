/**
* ============================================
* Name: BatchToSeperateVoiceTranscript_Test
* Description: Test Class of BatchToSeperateVoiceTranscript Batch class.
 
* Author :- Venkat Kalyan
* Date   :- 06-01-2024
* =======================================================
* */

@isTest
public class BatchToSeperateVoiceTranscript_Test {
     
    @testsetup
    static void testsetup(){
        
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
        VoiceCall voice = new VoiceCall();
        voice.VoiceCustomerTranscript__c = 'Hi, I am Test.\n Please record my voice';
        voice.CallCenterId = [Select Id From callcenter LIMIT 1].Id;
        voice.VendorType = 'ContactCenter';        
        voice.CallStartDateTime = system.now();
        voice.CallEndDateTime = system.now();
        voice.FromPhoneNumber = '+14699875672';
        voice.ToPhoneNumber = '+18006077550';
        voice.CallType = 'Inbound';
        voice.Call_Disposition_Category__c = 'COLLAB/COLLECTION';
        voice.Call_Disposition_Sub_Category__c = 'COLLAB/COLLECTION - NBA';
        insert voice;
        
    }
    @isTest
    public static void testMethodToCheckCoverage(){
        Test.startTest();
        list<VoiceCall> listOfVoiceCall = [SELECT id, VoiceCustomerTranscript__c, RefinedVCTranscript__c, isProcessed__c FROM VoiceCall WHERE isProcessed__c = false];
        BatchToSeperateVoiceTranscript batchclass = new BatchToSeperateVoiceTranscript();
        Database.executeBatch(batchclass, 200);
        Test.stopTest();
        
    }
    
}