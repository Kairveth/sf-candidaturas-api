//DEMO-1003
public with sharing class CandidaturaEstadoController {

    @AuraEnabled
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
        Candidatura__c cand = new Candidatura__c(Id = candidaturaId, Estado__c = nuevoEstado);
        Database.SaveResult sr = Database.update(cand, false, AccessLevel.USER_MODE);
        if (!sr.isSuccess()) {
            throw error(sr.getErrors()[0].getMessage());
        }
    }

    private static AuraHandledException error(String mensaje) {
        AuraHandledException e = new AuraHandledException(mensaje);
        e.setMessage(mensaje);
        return e;
    }
}