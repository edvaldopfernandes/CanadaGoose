({
    doInit: function(component) {
        //return;
        var action = component.get("c.getNavigationParameters"); 
 
        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            if (state === "SUCCESS") {
                var navParams = response.getReturnValue();
                if (navParams != null) {
                    component.set("v.CurrentLanguage", navParams.CurrentLanguage);
                    component.set("v.ShowEnglish", navParams.ShowEnglish);
                    component.set("v.ShowFrench", navParams.ShowFrench);
                    component.set("v.ShowGerman", navParams.ShowGerman);
                    component.set("v.ShowChinese", navParams.ShowChinese);
                    component.set("v.ShowItalian", navParams.ShowItalian);
                    component.set("v.ShowSpanish", navParams.ShowSpanish);//venkata
                    component.set("v.LocaleEnglish", navParams.LocaleEnglish);
                    component.set("v.LocaleFrench", navParams.LocaleFrench);
                    component.set("v.LocaleGerman", navParams.LocaleGerman);
                    component.set("v.LocaleChinese", navParams.LocaleChinese);
                    component.set("v.LocaleItalian", navParams.LocaleItalian);
                    component.set("v.LocaleSpanish", navParams.LocaleSpanish);//venkata
                    component.set("v.ShowLanguagePicker", navParams.ShowLanguagePicker);
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },
    
    setLanguage : function(component,event, helper) {
        var languageCode = event.currentTarget.dataset.language;
        var localeCode = event.currentTarget.dataset.locale;

        var action = component.get("c.setUserLanguageAndLocale");
        action.setParams({
            "languageCode": languageCode
            , "localeCode": localeCode
        });
        
        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                    location.reload();
                }
                else
                    console.log("Failed to update language preferences.")

            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})