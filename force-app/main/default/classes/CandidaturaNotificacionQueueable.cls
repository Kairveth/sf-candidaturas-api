//DEMO-1005
public with sharing class CandidaturaNotificacionQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> ids;
    private Integer intento;

    public CandidaturaNotificacionQueueable(Set<Id> ids) {
        this(ids, 1);
    }

    public CandidaturaNotificacionQueueable(Set<Id> ids, Integer intento) {
        this.ids = ids;
        this.intento = intento;
    }

    public void execute(QueueableContext ctx) {
        System.attachFinalizer(new CandidaturaReintentoFinalizer(ids, intento));
        List<Candidatura__c> lote = [SELECT IdExterno__c, Name, Estado__c FROM Candidatura__c WHERE Id IN :ids];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Destino_Candidaturas');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload(lote)));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() >= 300) {
            throw new CalloutException('HTTP ' + res.getStatusCode());
        }
    }

    private static List<Map<String, String>> payload(List<Candidatura__c> lote) {
        List<Map<String, String>> datos = new List<Map<String, String>>();
        for (Candidatura__c cand : lote) {
            datos.add(new Map<String, String>{ 'idExterno' => cand.IdExterno__c, 'nombre' => cand.Name, 'estado' => cand.Estado__c });
        }
        return datos;
    }
}