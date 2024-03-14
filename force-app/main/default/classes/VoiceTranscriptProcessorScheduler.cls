public class VoiceTranscriptProcessorScheduler implements System.Schedulable {
    public  void execute(System.SchedulableContext ctx) {
		Database.executeBatch(new VoiceTranscriptProcessor(), 1);
    }

}