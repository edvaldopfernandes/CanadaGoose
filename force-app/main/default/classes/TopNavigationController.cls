public class TopNavigationController {
	/*
    * Class: TopNavigationStruct
    * --------------------
    * Class to define object to be passed to lightning controller
    * 
    *  CurrentLanguage: Current language for the logged in user
    *  ShowEnglish: Boolean that determines if the current user's country support English
    *  ShowFrench: Boolean that determines if the current user's country support French
    *  ShowGerman: Boolean that determines if the current user's country support German
    *  ShowChinese: Boolean that determines if the current user's country support Chinese
    */
    public class TopNavigationStruct{
        @AuraEnabled public String CurrentLanguage;
        @AuraEnabled public String LocaleEnglish;
        @AuraEnabled public String LocaleFrench;
        @AuraEnabled public String LocaleGerman;
        @AuraEnabled public String LocaleChinese;
        @AuraEnabled public String LocaleItalian;
        @AuraEnabled public String LocaleSpanish;//venkata
        @AuraEnabled public Boolean ShowEnglish;
        @AuraEnabled public Boolean ShowFrench;
        @AuraEnabled public Boolean ShowGerman;
        @AuraEnabled public Boolean ShowChinese;
        @AuraEnabled public Boolean ShowItalian;
        @AuraEnabled public Boolean ShowSpanish;//venkata
        @AuraEnabled public Boolean ShowLanguagePicker;
        
        public TopNavigationStruct(){
            CurrentLanguage = 'EN';
            LocaleEnglish = '';
            LocaleFrench = '';
            LocaleGerman = '';
            LocaleChinese = '';
            LocaleItalian = '';
            LocaleSpanish = '';//venkata
            ShowEnglish = false;
            ShowFrench = false;
            ShowGerman = false;
            ShowChinese = false;
            ShowItalian = false;
            ShowSpanish = false;//venkata
            ShowLanguagePicker = false;
        }
    }
    
    /*
    * Function: getNavigationParameters
    * --------------------
    * Get navigation parameters that will control the display of the top navigation
    * 
    *  returns: a struct holding all required parameters
    */
    @AuraEnabled
    public static TopNavigationStruct getNavigationParameters() {
        TopNavigationStruct navParams = new TopNavigationStruct();
        Integer ShowLanguageCounter = 0;

		// Get the logged in user country code and selected language        
		User loggedUser = [SELECT CountryCode, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
        
        if (loggedUser != null) {
            // Determine which language to display on the language picker
            String userLanguage = loggedUser.LanguageLocaleKey;
            
            if (userLanguage == 'fr')
                navParams.CurrentLanguage = 'FR';
            else if (userLanguage == 'de')
                navParams.CurrentLanguage = 'DE';
            else if (userLanguage == 'zh_CN')
                navParams.CurrentLanguage = '中文';
             else if (userLanguage == 'it')
                navParams.CurrentLanguage = 'IT';
            else if (userLanguage == 'es')
                navParams.CurrentLanguage = 'ES';//venkata
            else
                navParams.CurrentLanguage = 'EN';
            
            Utilities.CountrySetting countrySetting = Utilities.GetCountrySetting(loggedUser.CountryCode);
            
            navParams.LocaleEnglish = countrySetting.LocaleEnglish;
            navParams.LocaleFrench = countrySetting.LocaleFrench;
            navParams.LocaleGerman = countrySetting.LocaleGerman;
            navParams.LocaleChinese = countrySetting.LocaleChinese;
            navParams.LocaleItalian = countrySetting.LocaleItalian;
            navParams.LocaleSpanish = countrySetting.LocaleSpanish;//venkata
            
            if (countrySetting != null) {
                if (countrySetting.ShowEnglish && userLanguage != 'en_US') {
                    navParams.ShowEnglish = true;
                    ShowLanguageCounter ++;
                }
                
                if (countrySetting.ShowFrench && userLanguage != 'fr') {
                    navParams.ShowFrench = true;
                    ShowLanguageCounter ++;
                }
                
                if (countrySetting.ShowGerman && userLanguage != 'de') {
                    navParams.ShowGerman = true;
                    ShowLanguageCounter ++;
                }
                
                if (countrySetting.ShowChinese && userLanguage != 'zh_CN') {
                    navParams.ShowChinese = true;
                    ShowLanguageCounter ++;
                }
                
                if (countrySetting.ShowItalian && userLanguage != 'it') {
                    navParams.ShowItalian = true;
                    ShowLanguageCounter ++;
                }
                
                if (countrySetting.ShowSpanish && userLanguage != 'es') { //venkata
                    navParams.ShowSpanish = true;
                    ShowLanguageCounter ++;
                }
            }
            
            navParams.ShowLanguagePicker = (ShowLanguageCounter > 0);
        }
        return navParams;
    }
    
    /*
    * Function: setUserLanguageAndLocale
    * --------------------
    * Set the logged in user language and locale with the specified parameter
    * 
    * languageCode: specified language in the supported LocaleKey format
    * localeCode: specified locale in the supported LocaleKey format
    * 
    * returns: boolean determining success of the operation
    */
    @AuraEnabled
    public static Boolean setUserLanguageAndLocale(String languageCode, String localeCode) {
        try {
            update new User(
                Id = UserInfo.getUserId()
                , LanguageLocaleKey = languageCode
                , LocaleSidKey = localeCode
                , Bypass_Validation__c = true
            );
        }
        catch (Exception e) {
            System.debug('Error during updating user language: ' + e.getStackTraceString());
            return false;
        }
        
        return true;
    }
}