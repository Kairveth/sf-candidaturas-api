//DEMO-1005
@IsTest
private class candidaturaNotificacionTest {

    @IsTest
    static void entrevistaEnBulkUnaSolaLlamada() {
        List<Candidatura__c> lote = new List<Candidatura__c>();
        for (Integer i = 0; i < 200; i++) {
            lote.add(new Candidatura__c(Name = 'N' + i, IdExterno__c = 'E-' + i, Estado__c = 'Recibida'));
        }
        insert lote;
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
}