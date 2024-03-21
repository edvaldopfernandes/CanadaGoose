public with sharing class CaseDetailController extends LightningController {

    @AuraEnabled
    public static Response doInit(Id recordId){
        try {
            System.debug('recordId - ' + recordId);
            Case record = getCase(recordId);
            List<ContentVersion> versions = getImage(record.Style__c);

            return new Response(true, 'success', new Map<String, Object> {
                'case' => record,
                'images' => versions
            });
        } catch(Exception e) {
            return new Response(false, e.getMessage() + ' ' + e.getStackTraceString());
        }      
    }

    public static Case getCase(Id recordId) {
        List<Case> caseList = [
            SELECT Id,
                CaseNumber,
                CreatedDate,
                Style__c,
                Style__r.Name,
                Description,
                WIP_Status__c,
                Status,
                toLabel(Status) statusTranslated
            FROM Case
            WHERE Id =:recordId
        ];
        System.debug('Case List: ' + caseList);
        return (caseList.isEmpty() ? null : caseList[0]);
    }

    public static List<ContentVersion> getImage(Id styleId) {

        if(styleId == null) {
            return null;
        }

        List<ContentDocumentLink> links = [
            SELECT Id,
                ContentDocumentId,
                LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =:styleId
        ];

        if(links.isEmpty()) {
            return null;
        }

        Set<Id> docIds = new Set<Id>();

        for(ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }

        List<ContentVersion> versions = [
            SELECT Id,
                ContentDocumentId,
                VersionData,
                Title
            FROM ContentVersion
            WHERE IsLatest = true AND ContentDocumentId IN:docIds
        ];

        return versions;
    }
}