//DEMO-1003
@IsTest
private class candidaturaEstadoControllerTest {

    @IsTest
    static void listaTransicionesYCambiaEstado() {
        Candidatura__c cand = new Candidatura__c(Name = 'E', IdExterno__c = 'EST-1', Estado__c = 'Recibida');
        insert cand;
        List<String> permitidas = CandidaturaEstadoController.transicionesPermitidas(cand.Id);
        System.assert(permitidas.contains('En revisión'));
        System.assert(!permitidas.contains('Oferta'));
        CandidaturaEstadoController.cambiaEstado(cand.Id, 'En revisión');
        System.assertEquals('En revisión', [SELECT Estado__c FROM Candidatura__c WHERE Id = :cand.Id].Estado__c);
    }

    @IsTest
    static void transicionInvalidaDevuelveError() {
        Candidatura__c cand = new Candidatura__c(Name = 'I', IdExterno__c = 'EST-2', Estado__c = 'Recibida');
        insert cand;
        String mensaje;
        try {
            CandidaturaEstadoController.cambiaEstado(cand.Id, 'Oferta');
        } catch (AuraHandledException e) {
            mensaje = e.getMessage();
        }
        System.assert(mensaje != null && mensaje.contains('Transición no válida'), mensaje);
        System.assertEquals('Recibida', [SELECT Estado__c FROM Candidatura__c WHERE Id = :cand.Id].Estado__c);
    }

    @IsTest
    static void usuarioSinAccesoNoLee() {
        Candidatura__c cand = new Candidatura__c(Name = 'S', IdExterno__c = 'EST-3', Estado__c = 'Recibida');
        insert cand;
        User sinAcceso = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'SinAcceso',
            Email = 'sinacceso@test.org',
            Username = 'sinacceso' + DateTime.now().getTime() + '@test.org',
            Alias = 'sinacc',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert sinAcceso;
        Boolean fallo = false;
        System.runAs(sinAcceso) {
            try {
                CandidaturaEstadoController.transicionesPermitidas(cand.Id);
            } catch (Exception e) {
                fallo = true;
            }
        }
        System.assert(fallo, 'el usuario sin acceso debía fallar');
    }
}