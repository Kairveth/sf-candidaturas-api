//DEMO-1001
trigger CandidaturaTrigger on Candidatura__c (before update) {
    CandidaturaTriggerHandler.validaTransiciones(Trigger.new, Trigger.oldMap);
}