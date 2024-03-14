trigger CDLTrigger on ContentDocumentLink (before insert) {
   
        for(ContentDocumentLink Cdl : trigger.new)
        {
            cdl.visibility = 'AllUsers';
        }

}