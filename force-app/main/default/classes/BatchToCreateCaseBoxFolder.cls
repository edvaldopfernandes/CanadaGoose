// Batch to create case box folder mapping record with case id and boxFolderId in BOX_Case_Folder__c object 
public class BatchToCreateCaseBoxFolder implements Database.Batchable<Sobject>,
Database.AllowsCallouts, Database.Stateful{

    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        return Database.getQueryLocator([SELECT Id FROM case WHERE ClosedDate > :range.Range_Start_Date__c 
                                         AND ClosedDate <:range.Range_End_Date__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<case> listOfCases){
        box.Toolkit boxToolkit = new box.Toolkit();
        List<Box_Case_Folder__c > listOfUpdatedCasesFolders = new List<Box_Case_Folder__c >();
        
        Id userId = UserInfo.getUserId();
        for(Case iteratedCase : listOfCases){
            Box_Case_Folder__c folderRec = new Box_Case_Folder__c ();
            folderRec.Box_Folder_Id__c = boxToolkit.createFolderForRecordId(iteratedCase.id, null, true);
            System.debug('New Case folder Id:>>'+ folderRec.Box_Folder_Id__c);
            //box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
            //String collabId = boxToolkit.createCollaborationOnRecord(userId, iteratedCase.id ,collabType, false);
            folderRec.Related_Case__c  = iteratedCase.id;
            //system.debug('new collaboration id: '+ collabId);
            listOfUpdatedCasesFolders.add(folderRec);
        }
        
        Schema.sobjectField externalIdField = Box_Case_Folder__c.fields.BOX_Folder_Id__c;
        Database.upsert(listOfUpdatedCasesFolders, externalIdField, false);
        boxToolkit.commitChanges();
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}