public class Utilities {
	public static final String DEFAULT_COUNTRY_CODE = '00';
    
    public class CountrySetting {
        @AuraEnabled
        public String CountryCode;
        @AuraEnabled
        public String Region;
        @AuraEnabled
        public String CountryCurrency;
        @AuraEnabled
        public String AdyenMerchantAccount;
        @AuraEnabled
        public String ExternalCompanyId;
        @AuraEnabled
        public String ShippingIndicator;
        @AuraEnabled
        public String PaymentMethod;
        @AuraEnabled
        public String LocaleEnglish;
        @AuraEnabled
        public String LocaleFrench;
        @AuraEnabled
        public String LocaleGerman;
        @AuraEnabled
        public String LocaleChinese;
        @AuraEnabled
        public String LocaleItalian;
        @AuraEnabled
        public String LocaleSpanish; // Venkata
        @AuraEnabled
        public String apiKey; // Venkata
        @AuraEnabled
        public Boolean ShowEnglish {get { return String.isNotBlank(LocaleEnglish); }}
        @AuraEnabled
        public Boolean ShowFrench {get { return String.isNotBlank(LocaleFrench); }}
        @AuraEnabled
        public Boolean ShowGerman {get { return String.isNotBlank(LocaleGerman); }}
        @AuraEnabled
        public Boolean ShowChinese {get { return String.isNotBlank(LocaleChinese); }}
         @AuraEnabled
        public Boolean ShowItalian {get { return String.isNotBlank(LocaleItalian); }}
      	 @AuraEnabled
        public Boolean ShowSpanish {get { return String.isNotBlank(LocaleSpanish); }} //Venkata
       
        

        public CountrySetting (Country_Setting__mdt countrySetting) {
            this.CountryCode = countrySetting.MasterLabel;
            this.Region = countrySetting.Region__c;
            this.CountryCurrency = countrySetting.Currency__c;
            this.AdyenMerchantAccount = countrySetting.Adyen_Merchant_Account__c;
            this.ExternalCompanyId = countrySetting.External_Company_Id__c;
            this.ShippingIndicator = countrySetting.Shipping_Indicator__c;
            this.PaymentMethod = countrySetting.Payment_Method__c;
            this.LocaleEnglish = countrySetting.Locale_English__c;
            this.LocaleFrench = countrySetting.Locale_French__c;
            this.LocaleGerman = countrySetting.Locale_German__c;
            this.LocaleChinese = countrySetting.Locale_Chinese__c;
            this.LocaleItalian = countrySetting.Locale_Italian__c;
            this.LocaleSpanish = countrySetting.Locale_Spanish__c; // Venkata
            this.apiKey = countrySetting.APIKey__c; // Venkata
        }
    }

    /*
    * Function: GetCountrySettings 
    * --------------------
    * Get a map of all available country codes and their corresponding settings
    *
    * returns: Map of all available country codes and their corresponding settings
	*/
    public static Map<String, Country_Setting__mdt> GetCountrySettings() {
        Map<String, Country_Setting__mdt> mapCountrySetting = new Map<String, Country_Setting__mdt>();
        
        // Query the Metadata object and build the map
        for (Country_Setting__mdt country :
             [SELECT MasterLabel, Region__c, Currency__c, Adyen_Merchant_Account__c
              , External_Company_Id__c, Shipping_Indicator__c, Payment_Method__c, APIKey__c
              , Locale_English__c, Locale_French__c, Locale_German__c, Locale_Chinese__c, Locale_Italian__c, Locale_Spanish__c
              FROM Country_Setting__mdt]) {
            mapCountrySetting.put(country.MasterLabel, country);
        }
        system.debug('mapCountrySetting GetCountrySettings: ' + mapCountrySetting);
        return mapCountrySetting;
    }
    
    /*
    * Function: GetCountrySetting
    * --------------------
    * Get a country setting for the specified country codes
    *
	* countryCode: Country code to query
	*
    * returns: Map of all available country codes and their corresponding settings
	*/
    @AuraEnabled
    public static CountrySetting GetCountrySetting(String countryCode) {
        List<Country_Setting__mdt> countrySetting = [
            SELECT MasterLabel, Region__c, Currency__c, Adyen_Merchant_Account__c
            	, External_Company_Id__c, Shipping_Indicator__c, Payment_Method__c, APIKey__c
            	, Locale_English__c, Locale_French__c, Locale_German__c, Locale_Chinese__c, Locale_Italian__c, Locale_Spanish__c
            FROM Country_Setting__mdt
            WHERE MasterLabel = :countryCode
        ];
        system.debug('GetCountrySetting GetCountrySetting:' + countrySetting);
        if (countryCode == DEFAULT_COUNTRY_CODE && countrySetting.isEmpty()) {
            system.debug('countryCode GetCountrySetting: null');
            return null;
        }
            
        else if (countrySetting.isEmpty()) {
            system.debug('countryCode GetCountrySetting: '+GetCountrySetting(DEFAULT_COUNTRY_CODE));
            // If country not found, then return default country setting with code DEFAULT_COUNTRY_CODE
            return GetCountrySetting(DEFAULT_COUNTRY_CODE);
        }
        else {
            CountrySetting CountrySettingObj = new CountrySetting(countrySetting[0]);
            system.debug('countryCode GetCountrySetting: '+CountrySettingObj);
            return CountrySettingObj;
        }
    }
}