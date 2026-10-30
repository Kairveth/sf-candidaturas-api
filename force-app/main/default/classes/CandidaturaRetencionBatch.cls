//DEMO-1008
public with sharing class CandidaturaRetencionBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date limite = Date.today().addMonths(-12);
        return Database.getQueryLocator([
            SELECT Id, Name FROM Candidatura__c
            WHERE Estado__c = 'Descartada' AND FechaDescarte__c <= :limite AND Name != 'Anonimizada'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Candidatura__c> lote) {
        for (Candidatura__c cand : lote) {
            cand.Name = 'Anonimizada';
            cand.IdExterno__c = null;
        }
        update lote;
    }

    public void finish(Database.BatchableContext bc) {
    }
}