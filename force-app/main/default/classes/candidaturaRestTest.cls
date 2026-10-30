@IsTest
//DEMO-1008
private class candidaturaRestTest {

    static void llama(String json) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/candidaturas';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        CandidaturaRest.upsertCandidatura();
    }

    @IsTest
    static void creaCandidaturaConCodigo201() {
        llama('{"idExterno":"CAND-001","nombre":"Prueba"}');
        System.assertEquals(201, RestContext.response.statusCode);
        System.assertEquals(1, [SELECT COUNT() FROM Candidatura__c WHERE IdExterno__c = 'CAND-001']);
    }

    @IsTest
    static void reenvioActualizaSinDuplicar200() {
        llama('{"idExterno":"CAND-002","nombre":"Original"}');
        llama('{"idExterno":"CAND-002","nombre":"Cambiada"}');
        System.assertEquals(200, RestContext.response.statusCode);
        Candidatura__c cand = [SELECT Name FROM Candidatura__c WHERE IdExterno__c = 'CAND-002'];
        System.assertEquals('Cambiada', cand.Name);
        System.assertEquals(1, [SELECT COUNT() FROM Candidatura__c WHERE IdExterno__c = 'CAND-002']);
    }

    @IsTest
    static void sinIdExterno400SinCrear() {
        llama('{"nombre":"Sin clave"}');
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(0, [SELECT COUNT() FROM Candidatura__c]);
    }

    @IsTest
    static void jsonInvalido400() {
        llama('no es json');
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void estadoInvalidoDevuelve409() {
        llama('{"idExterno":"CAND-409","nombre":"Transicion","estado":"Recibida"}');
        llama('{"idExterno":"CAND-409","estado":"Oferta"}');
        System.assertEquals(409, RestContext.response.statusCode);
    }

    @IsTest
    static void sinPermisoDevuelve403SinCrear() {
        Profile p = [SELECT Id FROM Profile WHERE Name IN ('Standard User', 'Usuario estándar') LIMIT 1];
        User u = new User(
            Alias = 'sinperm',
            Email = 'sinperm@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Prueba',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es_ES',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Madrid',
            UserName = 'sinperm' + DateTime.now().getTime() + '@example.com'
        );
        insert u;
        System.runAs(u) {
            llama('{"idExterno":"CAND-403","nombre":"Sin permiso"}');
        }
        System.assertEquals(403, RestContext.response.statusCode);
        System.assertEquals(0, [SELECT COUNT() FROM Candidatura__c WHERE IdExterno__c = 'CAND-403']);
    }
}