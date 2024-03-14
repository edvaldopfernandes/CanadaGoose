({
    doInit : function(component, event, helper) {
        var action = component.get("c.getUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.reEnterNewPassword", null);
        component.set("v.oldPassword", null);
        component.set("v.newPassword", null);
        component.set("v.isOpen", false);
    },
    
    checkPasswordNew: function(component, event, helper) {
        // for checking the newly entered password, after the new password validates the customer can insert the re-entered password
        var strongRegex = new RegExp("^(?=.*[A-Za-z0-9_])(?=.{8,})");
        component.set("v.reEnterNewPassword", null);
        
        if(component.get("v.reEnterNewPassword") != component.get("v.newPassword")) {
            component.set("v.NewpasswordChecked", true);
            component.set("v.passwordChecked", true);
        }
        
        if(component.get("v.oldPassword") == component.get("v.newPassword")) {
            component.set("v.responseback",$A.get("$Label.c.Warranty_ChangePassword_Error_DifferentOldNewPassword"));
            component.set("v.passwordChecked", true);
            component.set("v.NewpasswordChecked", true);
            return ;
        }
        
        if(!strongRegex.test(component.get("v.newPassword"))) {
            component.set("v.responseback",$A.get("$Label.c.Warranty_ChangePassword_Error_PasswordNotStrong"));
            component.set("v.passwordChecked", true);
            component.set("v.NewpasswordChecked", true);
            
            return ;
        }
        component.set("v.responseback",null);
        component.set("v.NewpasswordChecked", false);
    },
    
    checkPasswordReEnter: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"
        if(component.get("v.reEnterNewPassword") != component.get("v.newPassword"))
        {
            component.set("v.responseback",$A.get("$Label.c.Warranty_ChangePassword_Error_PasswordsNotMatch"));
            component.set("v.passwordChecked", true);
            return ;
        }
        component.set("v.passwordChecked", false);
    },
    
    changePasswd: function(component, event, helper) {
        //component.set("v.isOpen", false);
        component.set("v.ServerResponseback",null);
        component.set("v.ServerPasswordChecked",false);
        
        var action = component.get("c.changePassword");
        action.setParams({
            "newPassword":component.get("v.newPassword"),
            "verifyNewPassword":component.get("v.reEnterNewPassword"),
            "oldPassword":component.get("v.oldPassword")
        });
        
        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var responseback = response.getReturnValue();
                
                if (responseback) {
                    component.set("v.ServerResponseback",response.getReturnValue());
                    component.set("v.ServerPasswordChecked",true);
                }
                else
                {
                    //password is changed correctly
                    component.set("v.responseback", responseback);
                    component.set("v.PasswordChanged", true);
                    component.set("v.isOpen", false);
                }
            }
            else {
                console.log("Failed Changing password" + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }    
})