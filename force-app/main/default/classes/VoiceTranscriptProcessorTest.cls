@isTest
public class VoiceTranscriptProcessorTest {
    
      @isTest
    public static void testMethod1(){
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
        oVc.VoiceCallTranscriptProcessed__c = false;
        oVc.OwnerID = userinfo.getUserId();
        oVC.VendorCallKey = 'ff87e68a-3787-4790-bc7a-79baaceffaef';
        Insert oVc;
       
        system.debug('----> ' + [SELECT Id, VendorCallKey FROM VoiceCall WHERE VoiceCallTranscriptProcessed__c = false AND Owner.Name <> 'Automated Process']);             
       
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        test.StartTest();
            VoiceTranscriptProcessor obj = new VoiceTranscriptProcessor();
            DataBase.executeBatch(obj); 
        test.stopTest();
        
        }
}