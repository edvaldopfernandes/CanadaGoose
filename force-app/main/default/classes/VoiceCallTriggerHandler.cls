public class VoiceCallTriggerHandler {
    
    public static void voiceCallBeforeInsert(list<VoiceCall> triggernew){
        for(VoiceCall vc : triggernew){   
            if(vc.Related_Case__c == null){
                Case oCase = new Case();
                oCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voice_Support').getRecordTypeId();              
                oCase.Language_Email_Support__c = vc.Language__c;
                oCase.Region_Email_Support__c = vc.Region__c;
                oCase.OwnerID = vc.OwnerId;
                oCase.Country__c = vc.Country__c;
                oCase.status = 'Case Opened';                    
                
                // Check if the call type is 'Transfer' and the 'Previous_Call__c' field is populated.
                if (vc.PreviousCallId != null) {
                    
                    // If so, retrieve the associated Account from the previous call.
                    // Assuming that 'Previous_Call__c' contains the ID of the previous VoiceCall record.
                    VoiceCall previousCall = [SELECT Related_Person_Account__c FROM VoiceCall WHERE Id = :vc.PreviousCallId LIMIT 1];
                    if (previousCall != null && previousCall.Related_Person_Account__c != null) {
                        vc.Related_Person_Account__c = previousCall.Related_Person_Account__c;
                    }
                }
                
                try {
                    insert oCase;  
                    
                } catch (DmlException e) {
                    // Handle any potential errors during the insertion
                    System.debug('Error creating Case: ' + e.getMessage());
                }
                vc.Related_Case__c = oCase.Id;
            }        
        }    
    }
    
    
    public static void voiceCallAfterUpdate(list<VoiceCall> triggernew, map<id, voiceCall> mapOfOldRecord){
        map<string,VoiceCall> mapCaseWiseVC = new map<string,VoiceCall>();
        list<case> oCaseToUpdate = new list<case>();
        for(VoiceCall vc : triggernew){
            if(mapOfOldRecord != null && mapOfOldRecord.containsKey(vc.id) && 
               	mapOfOldRecord.get(vc.id).VoiceCallTranscriptProcessed__c != vc.VoiceCallTranscriptProcessed__c &&
               	vc.VoiceCallTranscriptProcessed__c == true){
                   return;
             }
            system.debug('VoiceCallTriggerHandler.voiceCallAfterUpdate +++ Line 47');
            
            if(vc.Related_Case__c != null){               
                mapCaseWiseVC.put(vc.Related_Case__c, vc);
            }            
        }
        
        for(Case oCase : [Select Id,Language_Email_Support__c,Country__c,OwnerId,Email_Disposition_Category__c,status,
                          Email_Disposition__c,
                          Return_Conditions_Confirmed_Ecomm__c,Region_Email_Support__c 
                          From Case WHERE ID IN :mapCaseWiseVC.keySet()]){
                              
                          oCase.Email_Disposition_Category__c = mapCaseWiseVC.get(oCase.Id).Call_Disposition_Category__c;
                          oCase.Email_Disposition__c = mapCaseWiseVC.get(oCase.Id).Call_Disposition_Sub_Category__c;
                          oCase.Country__c = mapCaseWiseVC.get(oCase.Id).Country__c;
                          oCase.Region_Email_Support__c = mapCaseWiseVC.get(oCase.Id).Region__c;
                          oCase.OwnerId = mapCaseWiseVC.get(oCase.Id).OwnerId;
                          oCase.Language_Email_Support__c = mapCaseWiseVC.get(oCase.Id).Language__c;
                          oCase.Escalation__c = mapCaseWiseVC.get(oCase.Id).Do_Not_Auto_Close_Case__c;                              
                              
     					  if(mapCaseWiseVC.get(oCase.Id).Related_Person_Account__c != null) {
      					     oCase.AccountId = mapCaseWiseVC.get(oCase.Id).Related_Person_Account__c ;
                           }                       
                          if(mapCaseWiseVC.get(oCase.Id).CallDisposition == 'completed' && mapCaseWiseVC.get(oCase.Id).Do_Not_Auto_Close_Case__c == false ){
                             oCase.status = 'Closed';                                  
                             System.debug('oCase.status ' + oCase.status);
                          }
                              oCaseToUpdate.add(oCase); 
                          }
        
        try {
            if(oCaseToUpdate.size() > 0 ){
                System.debug('oCaseToUpdate ' + oCaseToUpdate);
                Update oCaseToUpdate;    
            }
        } catch (DmlException e) {
            // Handle any potential errors during the insertion
            System.debug('Error updating Case: ' + e.getMessage());
        }  
    } 
}