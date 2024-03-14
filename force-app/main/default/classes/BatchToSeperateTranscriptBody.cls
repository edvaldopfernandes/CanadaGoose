/**
* ============================================
* Name: BatchToSeperateTranscriptBody
* Description: Batch to create Transcript body text from raw body text of live transcript body.
 
* Author :- Venkat Kalyan
* Date   :- 30-09-2022
* Test Class :- BatchToSeperateTranscriptBody_Test 
* =======================================================
* */
public class BatchToSeperateTranscriptBody implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

    public Database.querylocator start(Database.BatchableContext bc){
        
        string query = 'SELECT id, Status, body, LiveChatButton.DeveloperName, Contact.FirstName FROM LiveChatTranscript WHERE Status = \'Completed\' AND CreatedDate >= LAST_WEEK'; System.debug('<<>> query'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<LiveChatTranscript> listOfLiveChatTranscript){
        
        list<LiveChatTranscript> listOfupdatedChat = new List<LiveChatTranscript>(); // list to store the updated chat records
        Map<Id,list<String>> MapOfbodylines = new Map<Id,List<String>>(); // Map Of seperated lines
        Map<id, LiveChatTranscript> MapOfChatTranscript = new Map<Id, LiveChatTranscript>(); // Map of unprocessed chat transcripts
        Map<Id, Chat_button_text_mapping__c> MapOfChatTexts = new Map<Id, Chat_button_text_mapping__c>();
        for(LiveChatTranscript chat : listOfLiveChatTranscript){
           list<String> listOfbodylines = new list<String>();// list to store the splited body lines
           if(!MapOfChatTranscript.containsKey(chat.id)){
              MapOfChatTranscript.put(chat.id, chat);  }
           if(chat.body != null){
               listOfbodylines = chat.Body.split('<br>'); }
           if(!MapOfbodylines.containsKey(chat.id)) {
               MapOfbodylines.put(chat.id, listOfbodylines); }
           if(!MapOfChatTexts.containsKey(chat.id)) { System.debug('>>>>chat.LiveChatButton.DeveloperName>>>>>'+chat.LiveChatButton.DeveloperName);
               Chat_button_text_mapping__c chatText = Chat_button_text_mapping__c.getValues(chat.LiveChatButton.DeveloperName); System.debug('>>>>chatText>>>>'+chatText.LiveChatText__c);
               if(chatText.LiveChatText__c != null && chatText.ebot__c != null){ MapOfChatTexts.put(chat.id, chatText); } } System.debug('>>>MapOfChatTexts>>>'+MapOfChatTexts);
        } if(MapOfbodylines != null && MapOfbodylines.size()> 0){
           for(Id chatId : MapOfbodylines.keyset()){
              LiveChatTranscript chat = new LiveChatTranscript();
              String modifiedChatBody = '';
              String agentChatBody = '';
              String customerChatBody = '';
              String chatBotBody = '';
              for(string line : MapOfbodylines.get(chatId)){ System.debug('>>>>>MapOfChatTexts.get(chatId)>>>>'+MapOfChatTexts.get(chatId));
                 if(line.indexOf(':') != -1){
                    line = line.substring(line.indexOf(':') +1, line.length());                                          
                 }
                 if(MapOfChatTexts.containsKey(chatId) && MapOfChatTexts.get(chatId).LiveChatText__c != null 
                    && line.contains(MapOfChatTexts.get(chatId).LiveChatText__c)){ System.debug('Index of Live Chat'+line.indexOf(MapOfChatTexts.get(chatId).LiveChatText__c));
    				 modifiedChatBody = modifiedChatBody + line.substring(line.indexOf(MapOfChatTexts.get(chatId).LiveChatText__c)).trim() +'\n' ;
                     agentChatBody = agentChatBody + line.substring(line.indexOf(MapOfChatTexts.get(chatId).LiveChatText__c)).trim() +'\n' ;
                        if(MapOfChatTexts.get(chatId).ebot__c != null && line.contains(MapOfChatTexts.get(chatId).ebot__c)){
                        	chatBotBody = chatBotBody + line.substring(line.indexof(MapOfChatTexts.get(chatId).ebot__c)+ 1).trim() + '\n'; system.debug('chatBotBody>>>'+ chatBotBody );
                        }
				   }
                  else {
                      if(line.contains(')') && !line.contains('<p')  && MapOfChatTexts.containsKey(chatId) && !line.contains(MapOfChatTexts.get(chatId).ebot__c)){
                        system.debug('>>>'+line.indexOf(')')); System.debug('>>'+line.substring(line.indexOf(')')+1));
                       	modifiedChatBody = modifiedChatBody + 
                            					line.substring(line.indexOf(')')+1).trim()+'\n';
                        customerChatBody = customerChatBody + 
                            					line.substring(line.indexOf(')')+1).trim();// +'\n';
                        customerChatBody = customerchatBody.remove('\n');
                      }
                  }
                 
                   system.debug('ModifiedChatBody>>>'+modifiedChatBody);
                   system.debug('agentChatBody>>>'+agentChatBody);
                  customerChatBody = customerChatBody.replaceAll('[\n\r]+', '\n');
				  customerChatBody = customerChatBody.replaceAll('\n[ \t]*\n', '\n');
                  customerChatBody = customerChatBody.replaceAll('&#39;',''); 
                  customerChatBody = customerChatBody.replaceAll('&quot;', '');
                  customerChatBody = customerChatBody.replaceAll('‚Äô','');
                  customerChatBody = customerChatBody.replaceAll('‚Äôt','t');
                  customerChatBody = customerChatBody.replaceAll('&amp;', 'and');
                  customerChatBody = customerChatBody.replaceAll('&gt;', '');
                  customerChatBody = customerChatBody.replaceAll('&lt;', '');
                  customerChatBody = customerChatBody.replaceAll(',Äú', '"');
                  customerChatBody = customerChatBody.replaceAll('   ', ' '); 
                  customerChatBody = customerChatBody.replaceAll('it‚Äôs','its'); 
                  customerChatBody = customerChatBody.replaceAll('won‚Äôt','wont');
                  customerChatBody = customerChatBody.replaceAll('I‚Äôm','I am');
                  customerChatBody = customerChatBody.replaceAll('can‚Äôt','cannot');
                  customerChatBody = customerChatBody.replaceAll('doesn‚Äôt','doesnt');                                          
                  customerChatBody = customerChatBody.replaceAll('men‚Äôs','mens'); 
			      customerChatBody = customerChatBody.replaceAll('I‚Äôve','I');
				  customerChatBody = customerChatBody.replaceAll('it‚Äôll','it will');
                  system.debug('customerChatBody>>>'+customerChatBody);
              }
                chat.Id = chatId;
                chat.Refined_body__c = ModifiedChatBody;
                chat.Agent_Trans_body__c = agentChatBody.remove('\n');
                chat.CS_Trans_Body__c = customerChatBody;
               if(Chat.Refined_body__c != null){ chat.IsProcessed__c = true; } 
               	listOfupdatedChat.add(chat);
          }
        }
        if(listOfupdatedChat != null && listOfupdatedChat.size() >0)
        {
            Database.update(listOfupdatedChat, false);
        }
    }
   public void finish(Database.BatchableContext bc){}
    public void execute(schedulableContext sc){}
}