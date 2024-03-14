@isTest
public class VoiceCallTriggerHandlerTest {
    
    @isTest static void VoiceCallMethod() {
        
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
        
        Test.startTest();                                                                                
         Insert oVc;
         update oVc;
        Test.stopTest();
        
    }
    
}