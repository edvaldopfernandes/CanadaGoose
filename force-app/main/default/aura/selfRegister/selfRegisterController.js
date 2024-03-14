({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
    },
    
    handleSelfRegister: function (component, event, helper) {
        event.preventDefault();
        console.log('test');
        helper.handleSelfRegister(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleSelfRegister(component, event, helper);
        }
    },
    onCheck: function(cmp, evt) { 
		var checkCmp = cmp.find("checkbox");
        var resultCmp = cmp.find("checkResult");
        resultCmp.set("v.value", ""+checkCmp.get("v.value"));
        cmp.set("v.emailOpted", checkCmp.get("v.value")); 
	 },
})