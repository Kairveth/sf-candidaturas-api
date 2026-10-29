//DEMO-1001
public with sharing class CandidaturaService {

    public class CandidaturaException extends Exception {}
    public class TransicionException extends Exception {}

    public class Result {
        public Id id;
        public Boolean created;
    }

    public static Result upsertByIdExterno(Map<String, Object> body) {
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
}