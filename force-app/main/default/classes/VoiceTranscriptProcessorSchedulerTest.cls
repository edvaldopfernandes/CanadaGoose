@IsTest
public class VoiceTranscriptProcessorSchedulerTest {
	public static string cron_exp = '0 0 0 15 3 ? 2024';
    @isTest
    public static void schedulerTestMethod(){
        
        Test.startTest();
        	String JobId = System.schedule('VoiceTranscriptProcessorSchedulerTest', cron_exp, new  VoiceTranscriptProcessorScheduler());
        Test.stopTest();
    }
}