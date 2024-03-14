/**********************************************************************************************
* @description  : CaseController is a class that provides methods to retrieve open cases, the last 
case created by the current user, image data of a record in base64 format, and a list of 
Inspection_Result__c records associated with a given caseId
***********************************************************************************************/
public with sharing class CaseController {
    
    /**********************************************************************************************
    * @description  : returns a list of open cases for the current user
    * @param        : none
    * @return       : List<Case> - a list of open cases for the current user
    ***********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getOpenCases() {
        return [SELECT Id, CaseNumber, Style__r.Name, Status, CreatedDate
                FROM Case 
                WHERE Status != 'Closed' 
                AND CreatedById = :UserInfo.getUserId() 
                ORDER BY CreatedDate DESC];
    }
    
    /**********************************************************************************************
    * @description  : Returns the last case created by the current user that is not closed
    * @return       : List<Case> - List of cases
    ***********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getLastCase() {
        return [SELECT Id, CaseNumber, Style__r.Name, Style__r.Id, Status, toLabel(Status) statusTranslated, CreatedDate, Description
                FROM Case
                WHERE Status != 'Closed'
                AND CreatedById = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC LIMIT 1];
    }

    /**********************************************************************************************
    * @description  : Returns the image data of a record in base64 format
    * @param        : String recordId - Id of the record
    * @return       : String - base64 encoded image data
    ***********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getImageData(String recordId) {
        // Query ContentDocumentLink to get the ContentDocumentId
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId 
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :recordId 
                                                   LIMIT 1];
        
        if (documentLinks.isEmpty()) {
            return null; // No image found for the record
        }
        
        String contentDocumentId = documentLinks[0].ContentDocumentId;
        
        // Query ContentVersion to get the image file
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentId 
                                                LIMIT 1];
        
        if (contentVersions.isEmpty()) {
            return null; // No image file found for the ContentDocumentId
        }
        
        // Access the image file data
        Blob imageData = contentVersions[0].VersionData;
        
        // Convert the image data to a base64 string
        return EncodingUtil.base64Encode(imageData);
    }

    /**********************************************************************************************
    * @description  : Returns a list of Inspection_Result__c records associated with a given caseId
    * @param        : Id caseId - The Id of the case for which the Inspection_Result__c records are to be returned
    * @return       : List<Inspection_Result__c> - A list of Inspection_Result__c records associated with the given caseId
    ***********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<	Inspection_Result__c> getInspectionResults(Id caseId) {
        return [SELECT Id, Name, RecordTypeId, Repair_Type__c, Display_Price__c
                FROM Inspection_Result__c
                WHERE Case__c = :caseId];
    }
}