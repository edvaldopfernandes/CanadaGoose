public with sharing class CaseListController {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {

        return [SELECT Id, CaseNumber, Status, Style__r.Name FROM Case WHERE ContactId = '0037A00000pxzd2QAA'];
    }
}