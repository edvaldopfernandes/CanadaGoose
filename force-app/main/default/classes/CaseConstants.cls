/**
 * @description Created as a part of the Zendesk Migration to Salesforce project.
 * This Class is used to create various constants for the Case object
 */
public class CaseConstants {
    public static RecordTypes RECORD_TYPE = new RecordTypes();
    public class RecordTypes{
        public String EMAIL_SUPPORT = 
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_Support').getRecordTypeId();
    }
}