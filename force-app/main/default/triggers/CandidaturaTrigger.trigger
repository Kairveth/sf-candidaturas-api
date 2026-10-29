//DEMO-1005
trigger CandidaturaTrigger on Candidatura__c (before update, after update) {
    if (Trigger.isBefore) {
        CandidaturaTriggerHandler.validaTransiciones(Trigger.new, Trigger.oldMap);
    } else {
        CandidaturaTriggerHandler.encolaEntrevistas(Trigger.new, Trigger.oldMap);
    }
}