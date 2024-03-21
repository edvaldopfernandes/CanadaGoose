public with sharing class CaseCreationController extends LightningController {

    public static Map<String, Schema.SObjectField> caseFieldsMap = Case.sObjectType.getDescribe().fields.getMap();
    
    @AuraEnabled
    public static Response getUserInfo() {
        User user = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        Contact userCnt = [
            SELECT Id, 
                AccountId, 
                Account.Phone, 
                Account.ShippingStreet, 
                Account.AddressComplement__c, 
                Account.ShippingPostalCode, 
                Account.ShippingCity, 
                Account.ShippingState, 
                Account.ShippingCountry 
            FROM Contact 
            WHERE Id =:user.ContactId LIMIT 1
        ];

        CaseCreation context = new CaseCreation(
            userCnt.Account.ShippingStreet, 
            userCnt.Account.AddressComplement__c, 
            userCnt.Account.ShippingPostalCode, 
            userCnt.Account.ShippingCity, 
            userCnt.Account.ShippingState, 
            userCnt.Account.ShippingCountry, 
            userCnt.Account.Phone
        );

        return new Response(true, 'success', context);
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getPicklistValues(String fieldName) {
        List<Map<String,String>> listOfValues = new List<Map<String,String>>();
        
        //grab the list of picklist values for the passed field on the sobject
        List<Schema.PicklistEntry> ple = caseFieldsMap.get(fieldName).getDescribe().getPickListValues();

        for (Schema.PicklistEntry f : ple) {
            listOfValues.add(new Map<String, String> {
                'label' => f.getLabel(),
                'value' => f.getValue()
            });
        }
        return listOfValues;
    }
    
    @AuraEnabled
    public static Response getImageUploadValues() {
        List<Image> images = new List<Image>();

        List<CaseCreationImgUpload__mdt> imageMdts = [
            SELECT Id, 
                DeveloperName, 
                Label__c, 
                Required__c, 
                FileType__c, 
                Order__c,
                (
                    SELECT Id,
                        Title__c,
                        ImageName__c,
                        HelpText__c,
                        ImageUpload__c
                    FROM CaseCreationImagesInfos__r
                )
            FROM CaseCreationImgUpload__mdt 
            ORDER BY Order__c ASC
        ];

        for(CaseCreationImgUpload__mdt image : imageMdts) {
            images.add(new Image(image.Label__c, image.DeveloperName, image.Required__c, image.FileType__c, image.Order__c, image.CaseCreationImagesInfos__r));
        }

        return new Response(true, 'Success', images);
    }

    @AuraEnabled
    public static Response saveCase(CaseCreation caseObj) {
        try {
            User user = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            Contact userCnt = [SELECT Id, AccountId FROM Contact WHERE Id =:user.ContactId LIMIT 1];
            
            updateUserAcct(userCnt, caseObj);
            Case context = insertCase(userCnt, caseObj);
            insertImages(caseObj.images, context.Id);

            // Recuperar o CaseNumber após inserir o Case
            String caseNumber = [SELECT CaseNumber FROM Case WHERE Id =:context.Id].CaseNumber;
            system.debug('id' + context.Id);

            // Incluir o CaseNumber na resposta usando o campo values
            Map<String, Object> values = new Map<String, Object>();
            values.put('caseId', context.Id);
            values.put('caseNumber', caseNumber);

            system.debug('case number' + caseNumber);

            return new Response(true, 'Success', values);
        } catch (Exception e) {
            System.debug('@@@ERROR - ' + e.getStackTraceString());
            System.debug('@@@ERROR - ' + e.getMessage());
            return new Response(false, e.getMessage());
        }
    }

    public static Case insertCase(Contact userCnt, CaseCreation caseObj) {
        List<Style__c> styles = [
            SELECT Id
            FROM Style__c 
            WHERE Name =:caseObj.styleNumber
        ];

        if(styles.isEmpty()) {
            Style__c style = new Style__c(Name = caseObj.styleNumber);
            insert style;
            styles.add(style);
        }

        Case context = new Case();

        context.AccountId = userCnt.AccountId;
        context.ContactId = userCnt.Id;
        context.Description = caseObj.description;
        context.Accept_Cleaning_Health_Policy__c = true;
        context.Style__c = styles[0].Id;
        context.StyleNumber__c = caseObj.styleNumber;
        context.Colour__c = caseObj.colour;
        context.Size__c = caseObj.size;
        context.Customer_Issue__c = String.join(caseObj.customerIssue, ';');
        
        insert context;

        return context;
    }

    public static void updateUserAcct(Contact userCnt, CaseCreation caseObj) {
        Account userAcct = new Account();

        userAcct.Id = userCnt.AccountId;
        userAcct.ShippingStreet = caseObj.address;
        userAcct.AddressComplement__c = caseObj.complement;
        userAcct.ShippingPostalCode = caseObj.zipCode;
        userAcct.ShippingCity = caseObj.city;
        userAcct.ShippingState = caseObj.province;
        userAcct.ShippingCountry = caseObj.country;
        userAcct.Phone = caseObj.phone;

        update userAcct;
    }

    public static void insertImages(List<Image> images, Id caseId) {

        Map<String, ContentVersion> versionsMap = new Map<String, ContentVersion>();

        for (Image image : images) {
            if(image.image != null) {
                ContentVersion vrs = new ContentVersion(
                    Title = image.image.filename,
                    PathOnClient = image.image.filename,
                    VersionData = EncodingUtil.base64Decode(image.image.base64)
                );

                if(Test.isRunningTest()) {
                    vrs.NetworkId = [SELECT Id FROM Network LIMIT 1].Id;
                }

                versionsMap.put(image.image.filename, vrs);
            }
        }

        if(versionsMap.isEmpty()) {
            return;
        }

        insert versionsMap.values();

        System.debug('versions - ' + versionsMap.values());

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for(ContentVersion version : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:versionsMap.values()]) {
            links.add(
                new ContentDocumentLink(
                    ContentDocumentId = version.ContentDocumentId,
                    LinkedEntityId = caseId,
                    ShareType = 'V'
                )
            );
        }

        insert links;

        System.debug('links - ' + links);
    }

    public class CaseCreation {
        @AuraEnabled
        public String address { get; set; }
        @AuraEnabled
        public String complement { get; set; }
        @AuraEnabled
        public String zipCode { get; set; }
        @AuraEnabled
        public String province { get; set; }
        @AuraEnabled
        public String city { get; set; }
        @AuraEnabled
        public String country { get; set; }
        @AuraEnabled
        public String phone { get; set; }
        @AuraEnabled
        public String styleNumber { get; set; }
        @AuraEnabled
        public String colour { get; set; }
        @AuraEnabled
        public String size { get; set; }
        @AuraEnabled
        public List<String> customerIssue { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public List<Image> images { get; set; }

        public CaseCreation() {}

        public CaseCreation(String address, String complement, String zipCode, String city, String province, String country, String phone) {
            this.address = address;
            this.complement = complement;
            this.zipCode = zipCode;
            this.province = province;
            this.city = city;
            this.country = country;
            this.phone = phone;
        }
    }

    public class Image {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String developerName { get; set; }
        @AuraEnabled
        public Boolean required { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }
        @AuraEnabled
        public List<Object> helpInfos { get; set; }
        @AuraEnabled
        public ImgData image { get; set; }

        public Image() {}

        public Image(String label, String developerName, Boolean required, String fileType, Decimal order, List<Object> helpInfos) {
            this.label = label;
            this.developerName = developerName;
            this.required = required;
            this.fileType = fileType;
            this.order = order;
            this.helpInfos = helpInfos;
        }
    }

    public class ImgData {
        @AuraEnabled
        public String filename { get; set; }
        @AuraEnabled
        public String base64 { get; set; }
    }
}