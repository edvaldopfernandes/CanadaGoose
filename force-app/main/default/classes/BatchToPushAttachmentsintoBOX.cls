//Batch to push the attachments of email messages of case records.
public class BatchToPushAttachmentsintoBOX implements Database.Batchable<Sobject>,
Database.AllowsCallouts, Database.RaisesPlatformEvents{
	
    
    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch');
        return Database.getQueryLocator([SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_case__r.ClosedDate < :range.Range_End_Date__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<Box_Case_Folder__c> listOfCaseFolders){
   	
        box.Toolkit boxToolkit = new box.Toolkit();
        list<Box_Case_Folder__c> listOfFailedBoxRecords = new list<Box_Case_Folder__c>();
        for(Box_Case_Folder__c boxRec : listOfCaseFolders){
        
        	for(EmailMessage emsg : [SELECT Id, parentId FROM EmailMessage WHERE ParentId = :boxRec.Related_Case__c]){
            	for(Attachment att  :[SELECT Id, parentId,Name, body FROM attachment WHERE parentId =: emsg.Id]){
            		String attName = String.valueOf(att.id) + att.Name;
                    integer count = 1;
                	if(boxRec.Box_Folder_Id__c != null){
                        System.debug('>>>'+att.Name +count);
                       
                  		boxToolkit.createFileFromAttachment(att, attName,boxRec.Box_Folder_Id__c, null);
            		}
                    ++count;
                    
        		}
             }
        }
       boxToolkit.commitChanges();
      
    }
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}