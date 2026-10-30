//DEMO-1008
@IsTest
private class candidaturaReenvioBatchTest {

    @IsTest
    static void reenviaSoloFallidasEnEntrevistaEnBulk() {
        List<Candidatura__c> lote = new List<Candidatura__c>();
        for (Integer i = 0; i < 200; i++) {
            lote.add(new Candidatura__c(Name = 'R' + i, IdExterno__c = 'F-' + i, Estado__c = 'Entrevista', EstadoEnvio__c = 'Fallido'));
        }
        lote.add(new Candidatura__c(Name = 'Otra', IdExterno__c = 'F-200', Estado__c = 'Recibida', EstadoEnvio__c = 'Fallido'));
        insert lote;
        candidaturaMockOk.llamadas = 0;
        Test.setMock(HttpCalloutMock.class, new candidaturaMockOk());
        Test.startTest();
        Database.executeBatch(new CandidaturaReenvioBatch(), 200);
        Test.stopTest();
        System.assertEquals(1, candidaturaMockOk.llamadas);
        System.assertEquals(200, [SELECT COUNT() FROM Candidatura__c WHERE EstadoEnvio__c = 'Enviado']);
        System.assertEquals(1, [SELECT COUNT() FROM Candidatura__c WHERE EstadoEnvio__c = 'Fallido']);
    }
}