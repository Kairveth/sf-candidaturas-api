//DEMO-1008
public with sharing class CandidaturaService {

    public class CandidaturaException extends Exception {}
    public class TransicionException extends Exception {}
    public class PermisoException extends Exception {}

    public class Result {
        public Id id;
        public Boolean created;
    }

    public static Result upsertByIdExterno(Map<String, Object> body) {
        compruebaPermisos(body);
        Candidatura__c cand = new Candidatura__c(IdExterno__c = (String) body.get('idExterno'));
        if (body.containsKey('nombre')) {
            cand.Name = (String) body.get('nombre');
        }
        if (body.containsKey('estado')) {
            cand.Estado__c = (String) body.get('estado');
        }
        Database.UpsertResult ur = Database.upsert(cand, Candidatura__c.IdExterno__c, false);
        if (!ur.isSuccess()) {
            Database.Error err = ur.getErrors()[0];
            if (err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                throw new TransicionException(err.getMessage());
            }
            throw new CandidaturaException(err.getMessage());
        }
        Result r = new Result();
        r.id = ur.getId();
        r.created = ur.isCreated();
        return r;
    }

    private static void compruebaPermisos(Map<String, Object> body) {
        if (!Schema.sObjectType.Candidatura__c.isCreateable() || !Schema.sObjectType.Candidatura__c.isUpdateable()) {
            throw new PermisoException('Sin permiso de escritura en Candidatura__c');
        }
        if (!Schema.sObjectType.Candidatura__c.fields.IdExterno__c.isUpdateable()) {
            throw new PermisoException('Sin permiso de escritura en IdExterno__c');
        }
        if (body.containsKey('nombre') && !Schema.sObjectType.Candidatura__c.fields.Name.isUpdateable()) {
            throw new PermisoException('Sin permiso de escritura en Name');
        }
        if (body.containsKey('estado') && !Schema.sObjectType.Candidatura__c.fields.Estado__c.isUpdateable()) {
            throw new PermisoException('Sin permiso de escritura en Estado__c');
        }
    }
}