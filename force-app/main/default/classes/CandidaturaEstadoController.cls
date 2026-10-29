//DEMO-1003
public with sharing class CandidaturaEstadoController {

     @AuraEnabled(cacheable=true)
    public static List<String> transicionesPermitidas(Id candidaturaId) {
        List<Candidatura__c> lista = [
            SELECT Estado__c FROM Candidatura__c WHERE Id = :candidaturaId WITH USER_MODE LIMIT 1
        ];
        if (lista.isEmpty()) {
            throw error('Candidatura no disponible');
        }
        return new List<String>(CandidaturaTriggerHandler.permitidas(lista[0].Estado__c));
    }

    @AuraEnabled
    public static void cambiaEstado(Id candidaturaId, String nuevoEstado) {
        if (!Schema.sObjectType.Candidatura__c.isUpdateable()
            || !Schema.sObjectType.Candidatura__c.fields.Estado__c.isUpdateable()) {
            throw error('Sin permiso para cambiar el estado');
        }
        Candidatura__c cand = new Candidatura__c(Id = candidaturaId, Estado__c = nuevoEstado);
        try {
            update cand;
        } catch (DmlException e) {
            throw error(e.getDmlMessage(0));
        }
    }

    private static AuraHandledException error(String mensaje) {
        AuraHandledException e = new AuraHandledException(mensaje);
        e.setMessage(mensaje);
        return e;
    }
}