//DEMO-1002
@IsTest
private class candidaturaRetencionBatchTest {

    @IsTest
    static void anonimizaSoloDescartadasAntiguas() {
        List<Candidatura__c> lote = new List<Candidatura__c>();
        for (Integer i = 0; i < 205; i++) {
            lote.add(new Candidatura__c(Name = 'C' + i, IdExterno__c = 'R-' + i, Estado__c = 'Recibida'));
        }
        insert lote;
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'Descartada';
        }
        update lote;
        for (Integer i = 0; i < 200; i++) {
            lote[i].FechaDescarte__c = Date.today().addMonths(-13);
        }
        update lote;

        Test.startTest();
        Database.executeBatch(new CandidaturaRetencionBatch(), 200);
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Candidatura__c WHERE Name = 'Anonimizada']);
        System.assertEquals(5, [SELECT COUNT() FROM Candidatura__c WHERE Estado__c = 'Descartada' AND Name != 'Anonimizada']);
    }
}