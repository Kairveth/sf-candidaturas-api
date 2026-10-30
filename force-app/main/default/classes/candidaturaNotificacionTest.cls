//DEMO-1008
@IsTest
private class candidaturaNotificacionTest {

    @IsTest
    static void entrevistaEnBulkUnaSolaLlamada() {
        List<Candidatura__c> lote = creaLote(200);
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'En revisión';
        }
        update lote;
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'Entrevista';
        }
        candidaturaMockOk.llamadas = 0;
        Test.setMock(HttpCalloutMock.class, new candidaturaMockOk());
        Test.startTest();
        update lote;
        Test.stopTest();
        System.assertEquals(1, candidaturaMockOk.llamadas);
    }

    @IsTest
    static void envioOkMarcaEnviadoEnBulk() {
        List<Candidatura__c> lote = creaLote(200);
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'En revisión';
        }
        update lote;
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'Entrevista';
        }
        Test.setMock(HttpCalloutMock.class, new candidaturaMockOk());
        Test.startTest();
        update lote;
        Test.stopTest();
        Integer enviados = [SELECT COUNT() FROM Candidatura__c WHERE EstadoEnvio__c = 'Enviado'];
        System.assertEquals(200, enviados);
    }

    @IsTest
    static void marcarFallidoGuardaErrorEnBulk() {
        Set<Id> ids = new Map<Id, Candidatura__c>(creaLote(200)).keySet();
        CandidaturaReintentoFinalizer.marcarFallido(ids, 'HTTP 500');
        List<Candidatura__c> fallidas = [SELECT UltimoErrorEnvio__c FROM Candidatura__c WHERE EstadoEnvio__c = 'Fallido'];
        System.assertEquals(200, fallidas.size());
        System.assertEquals('HTTP 500', fallidas[0].UltimoErrorEnvio__c);
    }

    static List<Candidatura__c> creaLote(Integer n) {
        List<Candidatura__c> lote = new List<Candidatura__c>();
        for (Integer i = 0; i < n; i++) {
            lote.add(new Candidatura__c(Name = 'N' + i, IdExterno__c = 'E-' + i, Estado__c = 'Recibida'));
        }
        insert lote;
        return lote;
    }
}