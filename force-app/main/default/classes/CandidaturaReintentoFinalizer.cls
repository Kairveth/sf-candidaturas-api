//DEMO-1005
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
            System.debug(LoggingLevel.ERROR, 'Notificación fallida tras reintento: ' + ids.size() + ' candidaturas');
        }
    }
}