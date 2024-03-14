trigger CaseTrigger on Case (before insert, after update, before update) {
    
    /* @description Added before insert context as a part of the Zendesk Migration to Salesforce project.
*/
    
    Trigger_Switch__c  triggerSwitch = new Trigger_Switch__c(); 
    triggerSwitch = Trigger_Switch__c.getInstance('CaseTrigger');
    if((test.isRunningTest()) || (triggerSwitch.Switch__c == true)){
        if(Trigger.isBefore && Trigger.isInsert) {
            CaseTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate) { // GiftCardTrigger Code
            CaseTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
            CaseTriggerHandler.CloseMilestoneOnCaseStatusChange(Trigger.new);
         
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
           CaseTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            //if(checkRecursive.runOnce()){
               //CaseTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                
                String jiraProjectId = Label.Jira_project_id;
                String jiraIssueTypeId = Label.Jira_issue_type_id;
                List<Case> casesToUpdate = new List<Case>();
                for (Case updatedCase : Trigger.new) {                
                    if (updatedCase.Status != 'Closed' 
                        && updatedCase.Origin == 'Voice' 
                        
                        && updatedCase.JIRA_Creation_Status__c  == 'CaseReadyForJIRA'
                       ) {
                           // If conditions are met, create Jira issue
                           JCFS.API.createJiraIssue(jiraProjectId, jiraIssueTypeId); 
                           Case updatedRecord = new Case(id=updatedCase.Id, JIRA_Creation_Status__c = 'JIRACreated');                         
                           casesToUpdate.add(updatedRecord);
                       }
                }
                if(casesToUpdate != null && casesToUpdate.size() > 0) {
                    Database.update(casesToUpdate);
                }
                JCFS.API.pushUpdatesToJira();
            //}
        }
    }
}