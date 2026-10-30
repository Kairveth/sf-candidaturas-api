//DEMO-1008
public with sharing class CandidaturaReenvioBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Candidatura__c WHERE EstadoEnvio__c = 'Fallido' AND Estado__c = 'Entrevista'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Candidatura__c> lote) {
        System.enqueueJob(new CandidaturaNotificacionQueueable(new Map<Id, Candidatura__c>(lote).keySet()));
    }

    public void finish(Database.BatchableContext bc) {
    }
}