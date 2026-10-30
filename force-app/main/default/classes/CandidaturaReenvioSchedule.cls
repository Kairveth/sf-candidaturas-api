//DEMO-1008
public with sharing class CandidaturaReenvioSchedule implements Schedulable {

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new CandidaturaReenvioBatch(), 200);
    }
}