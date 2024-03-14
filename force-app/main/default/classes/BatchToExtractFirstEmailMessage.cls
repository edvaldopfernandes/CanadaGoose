/**
* ============================================
* Name: BatchToExtractFirstEmailMessage
* Description: Batch to Extract First Email Message
 
* Author :- Venkata Kollipara
* Date   :- 09-01-2024
* Test Class :- BatchToExtractFirstEmailMessageTest - To be created
* =======================================================
* */
public class BatchToExtractFirstEmailMessage implements Database.Batchable<Sobject>, Database.RaisesPlatformEvents{
                                                 
	public Database.querylocator start (Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT First_Email_Message__c,IsProcessed__c,Id,Status,TextBody FROM EmailMessage 
                                       WHERE  CreatedDate = LAST_YEAR  
                                       AND Parent.Case_Record_Type__c='Email Support' 
                                       AND (NOT FromAddress LIKE '%@canadagoose%')]);
	}
    //IsProcessed__c = false AND
    public void execute(Database.BatchableContext BC, List<EmailMessage> listOfEmails){
        list<EmailMessage> listOfEmailMsg =  new list<EmailMessage>();
        try{
        	for(EmailMessage email : listOfEmails){
                system.debug('<<<<email.TextBody>>>>>>'+ email.TextBody );
                String firstSplit = '';
                if(email.TextBody!= NULL && String.isNotBlank(email.TextBody)){
                	if(email.TextBody.contains('Sent from')){
                	firstSplit = email.TextBody.substringBefore('Sent from');
                }
                else if(email.TextBody.contains('On Sun')){
                	firstSplit = email.TextBody.substringBefore('On Sun');
                }
                else if(email.TextBody.contains('On Mon')){
                	firstSplit = email.TextBody.substringBefore('On Mon');
                }
                else if(email.TextBody.contains('On Tue')){
                	firstSplit = email.TextBody.substringBefore('On Tue');
                }
                else if(email.TextBody.contains('On Wed')){
                	firstSplit = email.TextBody.substringBefore('On Wed');
                }
                else if(email.TextBody.contains('On Thur')){
                	firstSplit = email.TextBody.substringBefore('On Thur');
                }
                else if(email.TextBody.contains('On Fri')){
                	firstSplit = email.TextBody.substringBefore('On Fri');
                }
                else if(email.TextBody.contains('On Sat')){
                	firstSplit = email.TextBody.substringBefore('On Sat');
                }
                else if(email.TextBody.contains('<ce@canadagoose.com')){
                	firstSplit = email.TextBody.substringBefore('<ce@canadagoose.com');
                }
                    
                else if(email.TextBody.contains('<cesupport@canadagoose.com')){
                	firstSplit = email.TextBody.substringBefore('<cesupport@canadagoose.com');
                }
                else if(email.TextBody.contains('<europe@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<europe@canadagoose.com>');
                }
                else if(email.TextBody.contains('<newsletter@enews.canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<newsletter@enews.canadagoose.com>');
                }
                else if(email.TextBody.contains('<cguk@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cguk@canadagoose.com>');
                }  
                else if(email.TextBody.contains('<cgie@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cgie@canadagoose.com>');
                }   
   				else if(email.TextBody.contains('<cgnl@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cgnl@canadagoose.com>');
                }   
                   
				else if(email.TextBody.contains('Canada Goose UK Customer Service <cguk@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('Canada Goose UK Customer Service <cguk@canadagoose.com>');
                }                       
                else if(email.TextBody.contains('<ce@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<ce@canadagoose.com>');
                }  
                else if(email.TextBody.contains('<cgit@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cgit@canadagoose.com>');
                }  
                  
                else if(email.TextBody.contains('<cgse@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cgse@canadagoose.com>');
                }  
                else if(email.TextBody.contains('<cgfr@canadagoose.com>')){
                	firstSplit = email.TextBody.substringBefore('<cgfr@canadagoose.com>');
                }
                else if(email.TextBody.contains('Disclaimer')){
                	firstSplit = email.TextBody.substringBefore('Disclaimer');
                }
                else if(email.TextBody.contains('Disclaimer:This')){
                	firstSplit = email.TextBody.substringBefore('Disclaimer:This');
                } System.debug('firstSplit>>>'+firstSplit);
                if(String.IsNotBlank(firstSplit)){
                    email.First_Email_Message__c = firstSplit;
                    email.IsProcessed__c = true;
              		listOfEmailMsg.add(email);
                } 
             }
           }
        	if(listOfEmailMsg.size() > 0){
                Database.update(listOfEmailMsg, false);
            }
        } Catch(Exception ex){ throw new DMLException('Exception in execute method ofBatchToExtractFirstEmailMessage '+ ex.getMessage()); } 
    }
    public void finish(Database.BatchableContext BC){}
}