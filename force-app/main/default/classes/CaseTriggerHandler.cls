public class CaseTriggerHandler {
    
    /*
* Function: OnAfterUpdate 
* --------------------
* Trigger handler for the After Update event
*
*  lstNewCases: List of the new Case records being updated
*  mapNewCases: Map of the new Case records being updated
*  lstOldCases: List of the old Case records being updated
*  mapOldCases: Map of the old Case records being updated
*
*  returns: N/A
*/	
    public static void OnAfterUpdate(List<Case> lstNewCases, Map<Id, Case> mapNewCases, List<Case> lstOldCases, Map<Id, Case> mapOldCases) {
        Id recTypeWarrantyClaim = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Warranty_Claim'].Id;
        
        // Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim').getRecordTypeId();
        Set<Id> setAccountId = new Set<Id>();
        
        for (Case newCase : lstNewCases) {
            // Only process Warranty Claims
            if (newCase.RecordTypeId == recTypeWarrantyClaim) {
                setAccountId.add(newCase.AccountId);
            }
        }
        
        Map<Id, Account> mapCaseIdToAccount = new Map<Id, Account>([SELECT Id, Payment_Method__c FROM Account WHERE Id IN :setAccountId]);
        Set<Id> setCaseId = new Set<Id>();
        List<Invoice__c> lstWireTransferInvoices = new List<Invoice__c>();
        List<Id> rejectedCaseIds = new List<Id>();           
        for (Case newCase : lstNewCases) {
            Case oldCase = mapOldCases.get(newCase.Id);
            
            // Only process Warranty Claims
            System.debug('newCase.RecordTypeId ::'+ newCase.RecordTypeId);
            // System.debug('mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c ::'+ mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c);
            System.debug('oldCase.Status ::'+ oldCase.Status);
            System.debug('newCase.Status ::'+ newCase.Status);
            System.debug('!newCase.Payment_Made__c ::'+ !newCase.Payment_Made__c);
            System.debug('newCase.Payment_Pending__c ::'+ newCase.Payment_Pending__c);
            
            if (newCase.RecordTypeId == recTypeWarrantyClaim
                && mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c == 'Wire Transfer')
            {
                System.debug('mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c ::'+ mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c);
                
                if (newCase.Status == 'Pending Payment'
                    && newCase.Status != oldCase.Status
                    && !newCase.Payment_Made__c
                    && newCase.Payment_Pending__c > 0)
                {
                    System.debug('<<<<inside wired payment>>>>>>>');
                    lstWireTransferInvoices.add(new Invoice__c (
                        Case__c = newCase.Id
                        , Customer_Email__c = newCase.ContactEmail
                        , Payment_Method__c = 'wire-transfer'
                        , Status__c = 'Draft'
                    ));
                }
                
                // If payment has been made
                if (newCase.Status == 'Pending Payment'
                    && ((newCase.Payment_Made__c && !oldCase.Payment_Made__c)
                        || (newCase.Accept_Charges__c && !oldCase.Accept_Charges__c))
                   )
                {
                    setCaseId.add(newCase.Id);
                }
            }
            
            // Only process Warranty Claims
            else if (newCase.RecordTypeId == recTypeWarrantyClaim
                     && mapCaseIdToAccount.get(newCase.AccountId).Payment_Method__c == 'Adyen')
            {
                /*if (newCase.Status == 'Pending Payment' && newCase.Status != oldCase.Status && !newCase.Payment_Made__c && newCase.Payment_Pending__c > 0){
lstWireTransferInvoices.add(new Invoice__c (
Case__c = newCase.Id, Customer_Email__c = newCase.ContactEmail, Payment_Method__c = 'Adyen', Status__c = 'Draft'));
}*/
                
                // If payment is required
                if (newCase.Status == 'Pending Payment'
                    && newCase.Status != oldCase.Status
                    && !newCase.Payment_Made__c
                    && newCase.Payment_Pending__c > 0)
                {
                    lstWireTransferInvoices.add(new Invoice__c (
                        Case__c = newCase.Id
                        , Customer_Email__c = newCase.ContactEmail
                        , Payment_Method__c = 'Adyen'
                        , Status__c = 'Draft'
                    ));
                    System.debug('>>>> Line no 88>>>> Adyen Invoice');
                    
                }
                
                // If payment has been made
                if (newCase.Status == 'Pending Payment'
                    && ((newCase.Payment_Made__c && !oldCase.Payment_Made__c)|| (newCase.Accept_Charges__c && !oldCase.Accept_Charges__c))) {
                        setCaseId.add(newCase.Id);
                    }
            }
            if(newCase.Approval_Status__c =='Rejected' && newCase.Approval_Status__c != OldCase.Approval_Status__c){
                rejectedCaseIds.add(newCase.id);
            }
        }
        if(rejectedCaseIds != NULL && rejectedCaseIds.size()>0){
            caseHelper.sendEmail(rejectedCaseIds);
        }
        // When payment is required for wire-transfer claims, create new Draft invoices
        if (!lstWireTransferInvoices.isEmpty()) {
            insert lstWireTransferInvoices;
        }
        
        // When payment is received for wire-transfer claims, mark all Sent invoices as Paid
        if (!setCaseId.isEmpty()) {
            List<Invoice__c> lstInvoices = [SELECT Id, Status__c
                                            FROM Invoice__c
                                            WHERE Case__c IN :setCaseId
                                            AND Payment_Method__c = 'wire-transfer'
                                            AND Status__c = 'Sent'];
            if (!lstInvoices.isEmpty()) {
                for (Invoice__c inv : lstInvoices) {
                    inv.Status__c = 'Paid';
                }
            }
            
            update lstInvoices;
        }
        
        // update realted voiceCall Disposition data         
        set<string> lstCaseId = new set<string>();
        map<string,Case> mapIdWiseCase = new map<string,Case>();
        for(Case newCase : lstNewCases) {
            Case oldCase = mapOldCases.get(newCase.Id);
            if(newCase.Email_Disposition_Category__c != oldCase.Email_Disposition_Category__c || newCase.Email_Disposition__c !=  oldCase.Email_Disposition_Category__c){
                lstCaseId.add(newCase.Id);
                mapIdWiseCase.put(newCase.Id,newCase);                
            }                        
        }
        list<VoiceCall> lstVcToUpdate = new list<VoiceCall>();
        for(VoiceCall oVc : [Select Id,Related_Case__c,Call_Disposition_Sub_Category__c,Call_Disposition_Category__c From VoiceCall WHERE Related_Case__c  IN : lstCaseId]){
            oVc.Call_Disposition_Sub_Category__c =  mapIdWiseCase.get(oVc.Related_Case__c).Email_Disposition__c;
            oVc.Call_Disposition_Category__c =  mapIdWiseCase.get(oVc.Related_Case__c).Email_Disposition_Category__c;
            lstVcToUpdate.add(oVc);
        }
        if(checkRecursive.runOnce()){
            if(lstVcToUpdate.size() > 0){
                UPDATE lstVcToUpdate;
            }   
        }
    }
    /**
* Gift card trigger functionality on before update
*/
    public static void onBeforeUpdate(List<Case> newCases, Map<id, case> oldMapOfCases){
        system.debug(LoggingLevel.Info,':before Update');
        List<Id> caseIds = new List<Id>();
        for (Case c : newCases) {
            system.debug(LoggingLevel.Info,'::old' + oldMapOfCases.get(c.id).IsApproved__c);
            system.debug(LoggingLevel.Info,'::new' + c.IsApproved__c);
            
            //Checking old IsApproved value of case to avoid redundancy
            if(c.IsApproved__c && !oldMapOfCases.get(c.id).IsApproved__c){
                system.debug(LoggingLevel.Info,':Test');
                c.Comments_from_CE_Ops__c = '';
                System.enqueueJob(new GCcalloutQueueable(c));
            }
            else if(c.Approval_Status__c == 'Rejected'){
                caseIds.add(c.id);
            } 
            case oldCase = oldMapOfCases.get(c.id);
            string ownerId  = String.ValueOf(c.ownerid);
            String oldOwner = oldCase.ownerId;
            if(ownerId.startsWith('005') && oldOwner.startsWith('00G') && oldcase.ownerId != c.ownerId ){
                
                System.debug('??????!!!!!!');
                c.ownerId = oldcase.ownerId;
            }
        }
        if(caseIds != NUll && CaseIds.size()>0){
            ProcessInstanceStep piStep = new ProcessInstanceStep();
            Map<id, processInstanceStep> mapOfApproverDetails =  new Map<id,ProcessInstanceStep>();
            mapOfApproverDetails = CaseHelper.getApproverDetails(caseIds);
            
            for(case c : newCases){
                if(mapOfApproverDetails.containsKey(c.id)){
                    piStep = mapOfApproverDetails.get(c.Id); 
                    if(piStep.Comments != NULL){
                        c.Comments_from_CE_Ops__c = piStep.Comments;
                    }
                }
            }
        }
    }
    /**
* @description Created as a part of the Zendesk Migration to Salesforce project.
* This method is handles case before insert trigger
* @param  newCases : list of new cases
* @return
*/    
    public static void onBeforeInsert(List<Case> newCases){
        trac_EmailToCaseLoopPrevent.checkEmailToCaseLoop(newCases);
        CaseTriggerService.associateCasesToContact(newCases);
    }
    
    //public static void CloseMilestoneOnCaseStatusChange(List<Case> lstCase) {
    public static void CloseMilestoneOnCaseStatusChange(List<Case> lstCase) {
        
        DateTime completionDate = System.now();
        
        List<Id> updateCases = new List<Id>();
        
        for (Case c : lstCase) {
            if (c.Origin == 'Voice' &&
                c.Status == 'Closed')
            {
                updateCases.add(c.Id);
            }
        }
        if (updateCases.isEmpty() == false) {
            milestoneUtils.completeMilestone(updateCases, completionDate);
            
        }
        
    }		
}