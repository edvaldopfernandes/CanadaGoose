/**
* ============================================
* Name: BatchToSeperateVoiceTranscript
* Description: Batch to seperate voice Transcript body text from raw body text of live transcript body.
* Author :- Venkat Kalyan
* Date   :- 20-12-2023
* Test Class :- BatchToSeperateVoiceTranscript_Test 
* =======================================================
**/
public class BatchToSeperateVoiceTranscript implements Database.Batchable<sObject>, Database.RaisesPlatformEvents{
   
    public Database.querylocator start(Database.BatchableContext bc){
        
        string query = 'SELECT id, VoiceCustomerTranscript__c, RefinedVCTranscript__c, isProcessed__c FROM VoiceCall WHERE isProcessed__c = false';
        if(!test.isRunningTest()){  updateTriggerSettings(true); }
        return Database.getQueryLocator(query);
    }
	public void execute(Database.BatchableContext bc, List<VoiceCall> listOfVoiceCall){
    	list<VoiceCall> listOfupdatedVoiceCall = new List<VoiceCall>(); // list to store the updated voice records
        try {
   			for(VoiceCall voice : listOfVoiceCall){
        		string refinedBody = '';
            	if(!String.isEmpty(voice.VoiceCustomerTranscript__c)){
                    refinedBody = voice.VoiceCustomerTranscript__c;
                    refinedBody = refinedBody.replaceAll('[\n\r]+|&quot;|&amp;|&#39;|\n[ \t]*\n|&gt;|&lt;|,Äú', '');
               		
                	system.debug('refinedBody>>>'+refinedBody);
                    voice.RefinedVCTranscript__c = refinedBody;
                    voice.IsChatRefined__c = true;
               	}
                  voice.isProcessed__c = true;
                  listOfupdatedVoiceCall.add(voice);
            }
            if(listOfupdatedVoiceCall != null && listOfupdatedVoiceCall.size() >0){
                Database.update(listOfupdatedVoiceCall, false);
            }
           
        }
        catch(Exception ex){ throw new UnexpectedException ('Exception in BatchToSeperateVoiceTranscript '+ ex.getMessage());}
    }
    public void finish(Database.BatchableContext bc){
        if(!test.isRunningTest()){ updateTriggerSettings(false); }
    }
	public void updateTriggerSettings(boolean trSwitch){
        Trigger_Switch__c obj = Trigger_Switch__c.getInstance('VoiceCallTrigger'); obj.AvoidTriggerOnBatchRun__c = trSwitch; update obj;
    }    
}