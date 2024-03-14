/**
* ============================================
* Name: BatchToSeperateTranscriptBody_Test
* Description: Test Class of BatchToSeperateTranscriptBody Batch class.
 
* Author :- Venkat Kalyan
* Date   :- 23-11-2022
* =======================================================
* */
@isTest
public class BatchToSeperateTranscriptBody_Test {
    
    @testsetup
    static void testsetup(){
        
        Chat_button_text_mapping__c chatText = new Chat_button_text_mapping__c();
        chatText.Name ='LiveAgent_NA_English';
        chatText.LiveChatText__c = 'Live Chat';
        insert chatText;
        Style__c style = new Style__c( Name = 'Test001');//Initialize
        insert style;
        Account acc = TestDataFactory.createTestAccount(false);
        acc.ShippingStreet = '123 Test';
        acc.ShippingCity = 'Brasil';
        acc.ShippingState = 'Amazonas';
        acc.ShippingStateCode = 'AM';
        acc.ShippingCountry = 'Brazil';
        acc.ShippingCountryCode = 'BR';
        acc.ShippingPostalCode = '12345';
        insert acc;
        Contact con = TestDataFactory.createTestContact('Testuser12', acc.Id, true);
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        list<LiveChatButton> buttonList = [SELECT id, DeveloperName, MasterLabel, IsActive,Type FROM  LiveChatButton WHERE DeveloperName ='LiveAgent_NA_English'];
        LiveChatTranscript chatTranscript = new LiveChatTranscript();
        chatTranscript.LiveChatButtonId = buttonList.size()>0 ? buttonList[0].id : null;
        chatTranscript.ContactId = con.id;
        chatTranscript.body ='<p align="center">Chat Started: Thursday, November 16, 2023, 08:27:57 (-0400)</p><p align="center">Chat Origin: LiveAgent-NA-English</p><p align="center">Agent Abigayle S C</p>( 24s ) Live Chat: Thank you for reaching out to us here at Canada Goose, I hope you are doing well. My name is Abigayle, how may I assist you?<br>( 1m 24s ) Christian: Hi, I am looking at the photojournalist jacket which I think looks awesome. My question is if this one is waterproof? Best regards Christian from Norway<br>( 2m 27s ) Live Chat: Thank you for being so interested in our product! We here at Canada Goose appreciate your business. It&#39;s not waterproof but it&#39;s windproof and water-resistant.<br>( 3m 8s ) Christian: Thanks! Do you know if there are any similar styles that are waterproof as well?<br>( 4m 34s ) Live Chat: Not exactly like it but our Mountaineer Jacket and Mountaineer Jacket are waterproof. Here is a link o the waterproof coats we have, https://www.canadagoose.com/us/en/shop/men/?prefn1=features&amp;prefv1=Waterproof&amp;srule=featured.<br>( 4m 49s ) Live Chat: Skreslet Parka sorry<br>( 6m 38s ) Live Chat: Is there anything else I could assist you with?<br>( 7m 47s ) Christian: Thanks so much! I will have a closer look and maybe get back to you. Wish you a great day<br>( 7m 50s ) Live Chat: You&#39;re welcome. Thank you for contacting Canada Goose. Have a great day!<br>';
        chatTranscript.status ='Completed';
        chatTranscript.LiveChatVisitorId = chatVisitor.id;
        chatTranscript.createdDate = Datetime.now();
        insert chatTranscript;
    }
    @isTest
    public static void testMethodToCheckCoverage(){
        Test.startTest();
        Chat_button_text_mapping__c chatText = Chat_button_text_mapping__c.getValues('LiveAgent_NA_English');
        list<LiveChatButton> buttonList = [SELECT id, DeveloperName, MasterLabel, IsActive,Type FROM  LiveChatButton WHERE DeveloperName ='LiveAgent_NA_English'];
        list<LiveChatTranscript> listOfchatTranscript = [SELECT id, Status, body, LiveChatButton.DeveloperName, Contact.FirstName, createdDate
                                                         FROM LiveChatTranscript WHERE Status = 'Completed' AND createdDate >= LAST_WEEK ];
        System.debug('chatText>>'+chatText);
        System.debug('buttonList>>'+buttonList);
        System.debug('listOfchatTranscript>>>>>>'+listOfchatTranscript);
        BatchToSeperateTranscriptBody batchclass = new BatchToSeperateTranscriptBody();
        Database.executeBatch(batchclass, 100);
        
        BatchToSeperateTranscriptBody batch = new BatchToSeperateTranscriptBody();
        String schCron = '0 30 23 ? * SUN *';
        System.schedule('BatchToSeperateTranscriptBodyScheduler', schCron, batch);
        Test.stopTest();
        
    }

    
}