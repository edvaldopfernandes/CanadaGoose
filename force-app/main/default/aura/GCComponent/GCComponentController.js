({
    doInit : function(component,event,helper){
        //Get Case Id
        debugger
        var objectName = component.get("v.sobjecttype")
        console.log(component.get("v.sobjecttype"));
     
        if(objectName == "Case"){
            
            var cid = component.get("v.recordId");
            
            component.set("v.CaseId", cid);
            helper.UpdateFields(component);
        }
        else
        {
            console.log(component.get("v.recordId"));
            var IRid = component.get("v.recordId");
            var action = component.get("c.GetCaseofIR");
            action.setParams({ "IRid" : IRid });
            action.setCallback(this, function(response) {
                console.log('caseir' + response.getReturnValue());
                component.set("v.CaseId", response.getReturnValue());
                helper.UpdateFields(component);
            });
            $A.enqueueAction(action);
        }
    }, 
    
    refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire(); 
        //window.location.reload()
    },
    
    setgcamt : function(component, event, helper) {
        var idval = event.target.id;
        var sign = component.get("v.sign");
        var val = event.target.value;
        var curr = component.get("v.curr");
        var gcamt = component.get("v.gcamt");
        var percentAmount;
        
        if(!val || isNaN(val)) {
            val = 0;
        }
        
        if(idval == 'refamt') {
            var vgct = component.get("v.gct").substring(5);
            percentAmount = (parseFloat(val) + parseFloat(vgct)).toFixed(2);
        }
        if(idval == 'statetax') {
            var vgca = component.get("v.gca").substring(5);
            percentAmount = (parseFloat(val) + parseFloat(vgca)).toFixed(2);
        }
        
        component.set("v.gcamt",curr + sign + percentAmount);
    },
    
    removecurr : function(component, event, helper) {
        var num = event.target.value.substring(5);
        
        var idval = event.target.id;
        
        if(idval == 'refamt') {
            component.set("v.gca", num);
        }
        if(idval == 'statetax') {
            component.set("v.gct", num);
        }
    },
    
    addcurr : function(component, event, helper) {
        var idval = event.target.id;
        var sign = component.get("v.sign");
        
        if(idval == 'refamt') {
            var errdiv = component.find('err');
            var errtxt = component.find('errtxt');
            
            console.log(event.target.value);
            component.set("v.gca", event.target.value);
            var vgca = component.get("v.gca");
            
            if(vgca && !isNaN(vgca)) {
                $A.util.removeClass(errdiv, 'slds-has-error');
                component.set("v.err", '');
            }
            else {
                $A.util.addClass(errdiv, 'slds-has-error');
                component.set("v.err", 'Enter a numeric value!');
                vgca = 0;
            }
            var c = component.get("v.curr");
            component.set("v.gca", c + sign + vgca);
        }
        
        if(idval == 'statetax') {
            var errdiv = component.find('terr');
            var errtax = component.find('errtax');
            
            console.log(event.target.value);
            component.set("v.gct", event.target.value);
            var vgct = component.get("v.gct");
            
            if(vgct && !isNaN(vgct)) {
                $A.util.removeClass(errdiv, 'slds-has-error');
                component.set("v.terr", '');
            }
            else {
                $A.util.addClass(errdiv, 'slds-has-error');
                component.set("v.terr", 'Enter a numeric value!');
                vgct = 0;
            }
            var c = component.get("v.curr");
            component.set("v.gct", c + sign + vgct);
        }
    },
    
    handleonSubmit : function(component, event, helper) {
        var curr = component.get("v.curr");
        var gcamt = component.get("v.gcamt");
      //  var egb = component.find("egb");
        
      //  var vegb = egb.get("v.value");
        var vgca = component.get("v.gca").substring(5);
        var vgct = component.get("v.gct").substring(5);
        console.log('vgca'+vgca);
        console.log('vgct'+vgct);
        
        //changes for adding tax value - end
        var percentAmount = (parseFloat(vgca) + parseFloat(vgct)).toFixed(2);
        console.log(percentAmount);
        /*component.set("v.gcamt",curr + '$ ' + percentAmount);
        var vgcamt = component.get("v.gcamt");
        console.log('vgcamt'+vgcamt);*/
        
        if (vgca && vgct) {
            if (percentAmount < 50 || percentAmount > 3000) {
                event.preventDefault();
                var a = component.get('c.handleOnAmtError');
                $A.enqueueAction(a);
            }
            else { 
                event.preventDefault(); // stop form submission
                var eventFields = event.getParam("fields");
                eventFields["Refund_Total_Before_Taxes__c"] = vgca;
                eventFields["State_Tax_Rate__c"] = vgct;
                eventFields["Refund_Total__c"] = percentAmount.toString();
                component.find("CaseForm").submit(eventFields);
            }
        } else {
            event.preventDefault();
            var a = component.get('c.handleOnError');
            $A.enqueueAction(a);
        }
        
    },
    
    
    handleOnSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type" : "success"
        });
        toastEvent.fire();
    },
    
    handleOnError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Please fill out required fields.",
            "type" : "error"
        });
        toastEvent.fire();
    },
    
    handleOnAmtError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Gift Card amount should not be less than 50 and not more than 3000.",
            "type" : "error"
        });
        toastEvent.fire();
    },
    
})