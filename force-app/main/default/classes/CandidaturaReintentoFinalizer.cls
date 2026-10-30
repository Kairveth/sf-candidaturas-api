//DEMO-1008
public with sharing class CandidaturaReintentoFinalizer implements Finalizer {

    private Set<Id> ids;
    private Integer intento;

    public CandidaturaReintentoFinalizer(Set<Id> ids, Integer intento) {
        this.ids = ids;
        this.intento = intento;
    }

    public void execute(FinalizerContext ctx) {
        if (ctx.getResult() != ParentJobResult.UNHANDLED_EXCEPTION) {
            return;
        }
        if (intento < 2) {
            System.enqueueJob(new CandidaturaNotificacionQueueable(ids, intento + 1));
        } else {
            marcarFallido(ids, ctx.getException().getMessage());
        }
    }

    @TestVisible
    private static void marcarFallido(Set<Id> ids, String error) {
        List<Candidatura__c> lote = [SELECT Id FROM Candidatura__c WHERE Id IN :ids WITH USER_MODE];
        for (Candidatura__c cand : lote) {
            cand.EstadoEnvio__c = 'Fallido';
            cand.UltimoErrorEnvio__c = error.left(255);
        }
        Database.update(lote, AccessLevel.USER_MODE);
    }
}