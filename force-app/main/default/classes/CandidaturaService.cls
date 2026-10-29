public with sharing class CandidaturaService {

    public class CandidaturaException extends Exception {}

    public class Result {
        public Id id;
        public Boolean created;
    }

    public static Result upsertByIdExterno(Map<String, Object> body) {
        Candidatura__c cand = new Candidatura__c(IdExterno__c = (String) body.get('idExterno'));
        if (body.containsKey('nombre')) {
            cand.Name = (String) body.get('nombre');
        }
        Database.UpsertResult ur = Database.upsert(cand, Candidatura__c.IdExterno__c, false);
        if (!ur.isSuccess()) {
            throw new CandidaturaException(ur.getErrors()[0].getMessage());
        }
        Result r = new Result();
        r.id = ur.getId();
        r.created = ur.isCreated();
        return r;
    }
}