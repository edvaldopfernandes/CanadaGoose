public class BatchToDeleteArchivedContentBodies implements Database.Batchable<Sobject>, Database.RaisesPlatformEvents{
	 
    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        return Database.getQueryLocator([SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE Is_batch_for_content_document_failed__c = false  
                                         AND Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_Case__r.ClosedDate < :range.Range_End_Date__c
                                         ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Box_Case_Folder__c> listOfCaseFolders){
         list<ContentDocument> listOfContentBodiesToBeDeleted = new list<ContentDocument>();
          set<Id> setOfCaseId = new set<id>();
        	for(Box_Case_Folder__c boxRec : listOfCaseFolders){
            	setOfCaseId.add(boxRec.Related_Case__c);
            }
        system.debug('Idishere'+ setOfCaseId);
        	for(ContentDocumentLink cdl : [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setOfCaseId]){
            	listOfContentBodiesToBeDeleted.add(new ContentDocument(Id = cdl.ContentDocumentId));
             }
        system.debug('Listishere'+listOfContentBodiesToBeDeleted );
        	if(listOfContentBodiesToBeDeleted != null && listOfContentBodiesToBeDeleted.size()>0){
         		Database.delete(listOfContentBodiesToBeDeleted);
       		}
        	
    }
    public void finish(Database.BatchableContext BC){
        
	}
}