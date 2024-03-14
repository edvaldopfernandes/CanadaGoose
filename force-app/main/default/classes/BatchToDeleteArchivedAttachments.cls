public class BatchToDeleteArchivedAttachments implements Database.Batchable<Sobject>, Database.RaisesPlatformEvents{
    
    
    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        return Database.getQueryLocator([SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE Is_batch_for_attachments_failes__c = false  
                                         AND Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_Case__r.ClosedDate < :range.Range_End_Date__c
                                        ]); // AND Related_case__c = '5003l00000zAuBKAA0' 
    }
    
    public void execute(Database.BatchableContext BC, List<Box_Case_Folder__c> listOfCaseFolders){
         list<Attachment> listOfAttachmentsToBeDeleted = new list<Attachment>();
          set<Id> setOfCaseId = new set<id>();
            for(Box_Case_Folder__c boxRec : listOfCaseFolders){
            setOfCaseId.add(boxRec.Related_Case__c);
            }
        system.debug('Idishere'+ setOfCaseId);
            for(EmailMessage emsg : [SELECT Id FROM EmailMessage WHERE ParentId IN :setOfCaseId]){
                for(Attachment att  :[SELECT Id FROM attachment WHERE parentId =: emsg.Id]){
                    listOfAttachmentsToBeDeleted.add(att);  
                }
             }
        system.debug('Listishere'+listOfAttachmentsToBeDeleted );
            if(listOfAttachmentsToBeDeleted != null && listOfAttachmentsToBeDeleted.size()>0){
                Database.delete(listOfAttachmentsToBeDeleted);
            }
            
    }
    public void finish(Database.BatchableContext BC){
        
    }

}