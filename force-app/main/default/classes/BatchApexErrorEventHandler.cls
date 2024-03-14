public with sharing class BatchApexErrorEventHandler {
    public Map<Id,AsyncApexJob> jobMap;
    public Map<Id,ApexClass> classMap;

    public BatchApexErrorEventHandler(){}

    public void handle(BatchApexErrorEvent[] errorEvents){
        Batch_Apex_Error_Settings__c settings = getSettings();
        getClassInfo(errorEvents);
        if(settings.Store_Errors_in_Custom_Object__c == TRUE){
            copyErrorsToSObject(errorEvents);
            updateBoxFolderRecord(errorEvents);
        }
        if(settings.Send_Errors_To__c != null){
            System.debug('Sending email');
            emailErrors(errorEvents, settings.Send_Errors_To__c);
        }
    }

    public Batch_Apex_Error_Settings__c getSettings(){
        return Batch_Apex_Error_Settings__c.getInstance();
    }

    public void getClassInfo(BatchApexErrorEvent[] errorEvents){
        Set<Id> jobIds = new Set<Id>();
        for(BatchApexErrorEvent errorEvent: errorEvents){
            jobIds.add(errorEvent.AsyncApexJobId);
        }
        jobMap = new Map<Id,AsyncApexJob>([SELECT Id, ApexClassID FROM AsyncApexJob WHERE Id IN :jobIds]);
        Set<Id> classIds = new Set<Id>();
        for(AsyncApexJob job : jobMap.values()){
            classIds.add(job.ApexClassId);
        }
        classMap = new Map<Id,ApexClass>([SELECT Id, Name FROM ApexClass WHERE Id IN :classIds]);
    }

    public void copyErrorsToSObject(BatchApexErrorEvent[] errorEvents){
        Batch_Apex_Error__c[] errors = new Batch_Apex_Error__c[]{};
        for(BatchApexErrorEvent errorEvent: errorEvents){
            String className ='';
            if(jobMap != NULL && jobMap.containsKey(errorEvent.AsyncApexJobId) && 
               classMap.containsKey(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId)){	
            	className = classMap.get(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId).Name;
            }
            errors.add(new Batch_Apex_Error__c(
                    Apex_Class__c = className,
                    Job_Id__c = errorEvent.AsyncApexJobId,
                    Batch_Phase__c = errorEvent.Phase,
                    Exception__c = errorEvent.Message,
                    Exception_Type__c = errorEvent.ExceptionType,
                    Job_Scope__c = errorEvent.JobScope,
                    Replay_ID__c = errorEvent.ReplayId,
                    Stack_Trace__c = errorEvent.StackTrace
            ));
        }
        insert errors;
    }
    public void updateBoxFolderRecord(BatchApexErrorEvent[] errorEvents){
        Box_Case_Folder__c[] listOfBoxRecord  = new Box_Case_Folder__c[]{};
        
		for(BatchApexErrorEvent errorEvent: errorEvents){
            Box_Case_Folder__c boxRecord = new Box_Case_Folder__c();
            boxRecord.id = errorEvent.JobScope;
           	String className ='';
            if(jobMap != NULL && jobMap.containsKey(errorEvent.AsyncApexJobId) && 
               classMap.containsKey(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId)){	
            	className = classMap.get(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId).Name;
            }
            if(className =='BatchToPushAttachmentsintoBOX'){
               boxRecord.Is_batch_for_attachments_failes__c = true;
            }
            else if(className =='BatchToPushCaseDocumentsIntoBOX'){
             	boxRecord.Is_batch_for_content_document_failed__c = true;
            }else if(className =='BatchToPushEmailMessageIntoBox'){
                boxRecord.Is_batch_for_emailmessages_failed__c = true;
            }
            
            listOfBoxRecord.add(boxRecord);
        }  
        if(listOfBoxRecord != null && listOfBoxRecord.size() > 0 ){
          update listOfBoxRecord;  
        }
    }
    public void emailErrors(BatchApexErrorEvent[] errorEvents, String recipients){
        Messaging.reserveSingleEmailCapacity(1);
        String[] toAddresses = new String[]{};
        if(recipients.contains(',')){
            toAddresses = recipients.split(',');
        }else{
            toAddresses.add(recipients);
        }
        String subject = 'Batch Apex Error Notification';
        String body = 'The following batch failed during execution and did not recover: \n\n';
        for(BatchApexErrorEvent errorEvent: errorEvents){
            String className ='';
            if(jobMap != NULL && jobMap.containsKey(errorEvent.AsyncApexJobId) && 
               classMap.containsKey(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId)){	
            	className = classMap.get(jobMap.get(errorEvent.AsyncApexJobId).ApexClassId).Name;
            }
            
            body += 'Job Id: '+errorEvent.AsyncApexJobId+'\n'+className + ' failed during ' + errorEvent.Phase + '.\nException: '+errorEvent.Message+'\nStack trace: '+errorEvent.StackTrace + '\nAffected records: '+errorEvent.JobScope;
        }
        sendEmail(toAddresses,subject,body);
    }

    public static List<Messaging.SendEmailResult> sendEmail(List<String> toAddresses,String subject, String body){
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setUseSignature(false);
        List<Messaging.SendEmailResult> res = Test.isRunningTest() ? new List<Messaging.SendEmailResult>{(Messaging.SendEmailResult)JSON.deserialize('{}',Messaging.SendEmailResult.class)} : Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        return res;
    }
}