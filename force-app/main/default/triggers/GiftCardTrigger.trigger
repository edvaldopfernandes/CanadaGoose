trigger GiftCardTrigger on Case (before update) {
   /* Map<Id,Case> old = Trigger.oldMap;
    system.debug(LoggingLevel.Info,':before');
    List<Id> caseIds = new List<Id>();
    for (Case c : Trigger.new) {
        system.debug(LoggingLevel.Info,'::old' + old.get(c.id).IsApproved__c);
        system.debug(LoggingLevel.Info,'::new' + c.IsApproved__c);
        
        //Checking old IsApproved value of case to avoid redundancy
        if(c.IsApproved__c && !old.get(c.id).IsApproved__c){
            system.debug(LoggingLevel.Info,':Test');
            c.Comments_from_CE_Ops__c = '';
            System.enqueueJob(new GCcalloutQueueable(c));
        }
        else if(c.Approval_Status__c == 'Rejected'){
             caseIds.add(c.id);
        } 
    }
    if(caseIds != NUll && CaseIds.size()>0){
        ProcessInstanceStep piStep = new ProcessInstanceStep();
        Map<id, processInstanceStep> mapOfApproverDetails =  new Map<id,ProcessInstanceStep>();
        mapOfApproverDetails = CaseHelper.getApproverDetails(caseIds);
        
        for(case c : Trigger.new){
            if(mapOfApproverDetails.containsKey(c.id)){
                piStep = mapOfApproverDetails.get(c.Id); 
            
                if(piStep.Comments != NULL){
                    c.Comments_from_CE_Ops__c = piStep.Comments;
                }
            }
        }
    } */
}