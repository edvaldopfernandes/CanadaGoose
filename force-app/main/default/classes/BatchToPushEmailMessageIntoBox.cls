//Batch to push the email messages in the form of csv file of case records.
public class BatchToPushEmailMessageIntoBox implements Database.Batchable<Sobject>, 
													   Database.AllowsCallouts,
													   Database.RaisesPlatformEvents
{

    public Database.querylocator start (Database.BatchableContext BC){
        Batch_Archival_Range__c range = Batch_Archival_Range__c.getValues('Date Range for Batch'); 
        return Database.getQueryLocator([SELECT Id, Related_case__c, Box_Folder_Id__c FROM Box_Case_Folder__c 
                                         WHERE Related_case__r.ClosedDate > :range.Range_Start_Date__c 
                                         AND Related_Case__r.ClosedDate <:range.Range_End_Date__c]);
        
        //AND Related_case__c = '5003l00000zAmglAAC'
    }
    //SELECT CreatedDate,Description,Id,IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId 
    //FROM Attachment WHERE CreatedDate > 2018-01-01T00:00:00.000Z AND CreatedDate <2019-01-01T00:00:00.000ZSELECT BccAddress,CcAddress,CreatedById,CreatedDate,
         
    public void execute(Database.BatchableContext BC, List<Box_Case_Folder__c> listOfCases){
        box.Toolkit boxToolkit = new box.Toolkit();
        list<Box_Case_Folder__c> listOfFailedBoxRecords = new list<Box_Case_Folder__c>();
        for(Box_Case_Folder__c box : listOfCases){
            for( EmailMessage emsg : [SELECT ParentId,Id ,FromAddress,FromName,HtmlBody,Subject,TextBody, ToAddress 
                                            FROM EmailMessage 
                                            WHERE ParentID =:box.Related_Case__c ORDER BY ParentID DESC]){
                        String boxFolderId = null;
                        String csvContent = null; 
                        String regExp = '<style>[^<]*<\\/style>|<\\/?\\w*\\b[^>]*>'; 
                        Pattern tagPattern = Pattern.compile(regExp); 
                        String plainHtmlBody = tagPattern.matcher(emsg.htmlbody).replaceAll('');
                        plainHtmlBody = plainHtmlBody.unescapeHTML3();
                    
                        csvContent ='ParentId,Id,FromAddress,FromName,Subject,TextBody,ToAddress,HtmlBody \n';  
                        csvContent = csvContent +emsg.ParentId+','+emsg.Id+','+emsg.FromAddress+','+emsg.FromName+','+emsg.Subject+','+emsg.TextBody+','+emsg.ToAddress+','+ plainHTMLBody;                           
                                
                        Attachment att = new Attachment();
                        att.Name = emsg.ParentId+'-'+emsg.Id+'-EmailMsgFile.csv';
                        att.ParentId =emsg.ParentId;
                        att.Body = Blob.valueOf(csvContent);
                    
                        if(box.Box_Folder_Id__c != null){
                           boxToolkit.createFileFromAttachment(att, null,box.Box_Folder_Id__c, null);
                        }
                }
            
        }
        boxToolkit.commitChanges();
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}