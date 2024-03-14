/**
 * Class Name : CaseHelper
 * Created By : Venkata Kalyan, 01 June 2021
 * Last Modified By : Venkata Kalyan, June 21 2021
 * Test Class Name  : GiftCardTriggerTest
 * Description      : This class helps in sending emial notification to CSR in the case of rejection of Approval.   
 * 
 ***/
public class CaseHelper {

    public static Map<id,ProcessInstanceStep> getApproverDetails(List<id> caseIds){
       Map<id, processInstanceStep> mapOfApproverDetails =  new Map<id,ProcessInstanceStep>();
        Map<Id, Id> mapOfInstanceWithCase = new Map<id, id>();
        
        for(processInstance pinstance : [SELECT Id, TargetObjectId FROM ProcessInstance 
                                         WHERE TargetObjectId IN :CaseIds]){
              if(!mapOfInstanceWithCase.containsKey(pinstance.Id)) {
                 mapOfInstanceWithCase.put(pinstance.id, pinstance.TargetObjectId);
              }                           
        }
        
        for(ProcessInstanceStep piStep : [SELECT Id,StepStatus,comments, ProcessInstanceId FROM ProcessInstanceStep
                                          WHERE ProcessInstanceId IN :mapOfInstanceWithCase.keyset() ORDER BY CreatedDate Desc LIMIT 1]){
         if(!mapOfApproverDetails.containsKey(mapOfInstanceWithCase.get(piStep.ProcessInstanceId))){
             mapOfApproverDetails.put(mapOfInstanceWithCase.get(piStep.ProcessInstanceId),piStep);  
          }
                                                                                
        }
        return mapOfApproverDetails;
    }
    public static void sendEmail(list<id> caseIds){
        String comments ='';
        Map<id, processInstanceStep> mapOfApproverDetails =  new Map<id,ProcessInstanceStep>();
        mapOfApproverDetails = CaseHelper.getApproverDetails(caseIds);
        List<Inspection_Result__c> insList = [SELECT id, LastModifiedById, case__r.CaseNumber FROM Inspection_Result__c  
                                              WHERE Case__c IN:CaseIds 
                                              AND RecordType.Name = 'Replacement' 
                                              ORDER by LastModifiedById DESC LIMIT 1];
        ProcessInstanceStep piStep = new ProcessInstanceStep();
        
       /*List<ProcessInstance> pInstance = [SELECT Id, TargetObjectId FROM ProcessInstance 
                                  WHERE TargetObjectId IN :CaseIds];
        if(pInstance != NULL && pInstance.size() > 0){
            piStep = [SELECT Id,StepStatus,comments FROM ProcessInstanceStep
                      WHERE ProcessInstanceId =: pInstance[0].id ORDER BY CreatedDate Desc LIMIT 1 ];
        }*/
        piStep = mapOfApproverDetails.get(caseIds[0]);
        System.debug ('*****'+piStep);
        if(piStep.comments == NULL){
            comments = 'NA';
        }
        if(piStep.comments != NULL){
            comments = piStep.Comments;
        }
        EmailTemplate et =[SELECT id, body, Subject FROM EmailTemplate WHERE Name ='Rejection Notification to CSR'];
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
                owea = [SELECT Id, Address, DisplayName FROM 
                                OrgWideEmailAddress WHERE DisplayName='Approval for Warranty Gift Card'];
        
        if(test.isRunningTest() || insList.size() >0){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setTargetObjectId(insList[0].LastModifiedById); 
            String plainText = et.Body;
            //Replace merged field with user information  
            
            plainText = plainText.replace('{!Case.CaseNumber}', insList[0].case__r.CaseNumber );
            plainText = plainText.replace('{!ApprovalRequest.Comments}',comments);
            
            
            //Change with Template ID
            //mail.setTemplateId(et.id);
            mail.setHTMLbody(plainText);
            mail.setSubject(et.subject);
            //
            
            //Record ID for which letter will be generated
            //mail.setWhatId(insList[0].case__c); 
            mail.setBccSender(false); 
            mail.setUseSignature(false); 
            if ( owea != null) {
                    mail.setOrgWideEmailAddressId(owea.id);

            }
            mail.setSaveAsActivity(false); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    }
}