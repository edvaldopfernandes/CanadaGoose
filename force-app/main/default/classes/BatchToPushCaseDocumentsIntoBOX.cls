//Batch to push the documents from content version//
public class BatchToPushCaseDocumentsIntoBOX implements Database.Batchable<Sobject>,
Database.AllowsCallouts, Database.RaisesPlatformEvents {

    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch'); 
        return Database.getQueryLocator([SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE  Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_case__r.ClosedDate < :range.Range_End_Date__c]); 
                                         
    }
    
    public void execute(Database.BatchableContext BC, List<Box_Case_Folder__c> listOfCases){
       		box.Toolkit boxToolkit = new box.Toolkit();
            list<Box_Case_Folder__c> listOfFailedBoxRecords = new list<Box_Case_Folder__c>();
            for(Box_Case_Folder__c c : listOfCases){
               
                    for(contentDocumentLink cdl: [SELECT ContentDocumentId, Id, LinkedEntityId FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId =: c.Related_case__c ]){
                        Id caseId = null;
                        String attName = null;   
                        for(ContentVersion cv : [SELECT Id,FileExtension, ContentDocumentId, ContentBodyId, Description, Owner.Name,Title,VersionData, VersionNumber 
                                                    FROM ContentVersion WHERE ContentDocumentId =: cdl.ContentDocumentId 
                                                    AND IsLatest = true LIMIT 1]){
                            if(c.Box_Folder_Id__c != null){
                                if(attName == cv.Title && caseId == cdl.ContentDocumentId){
                                    attName = cv.Title  + DateTime.now() + cv.owner.Name +'.'+ cv.FileExtension;
                                }
                                else{ attName = cv.Title + cv.owner.Name+ '.' + cv.FileExtension; }
                               
                                caseId = cdl.ContentDocumentId;
                                attachment att = new attachment(name = attName, body = cv.VersionData ,parentid =cdl.ContentDocumentId);
                                boxToolkit.createFileFromAttachment(att, null,c.Box_Folder_Id__c, null);
                            }
                        }
                 
                   }
                
            } 
           boxToolkit.commitChanges();
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}