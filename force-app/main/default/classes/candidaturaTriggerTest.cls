//DEMO-1001
@IsTest
private class candidaturaTriggerTest {

    @IsTest
    static void transicionValidaEnBulk200() {
        List<Candidatura__c> lote = new List<Candidatura__c>();
        for (Integer i = 0; i < 200; i++) {
            lote.add(new Candidatura__c(Name = 'C' + i, IdExterno__c = 'B-' + i, Estado__c = 'Recibida'));
        }
        insert lote;
        for (Candidatura__c cand : lote) {
            cand.Estado__c = 'En revisión';
        }
        update lote;
        System.assertEquals(200, [SELECT COUNT() FROM Candidatura__c WHERE Estado__c = 'En revisión']);
    }

    @IsTest
    static void transicionInvalidaFalla() {
        Candidatura__c cand = new Candidatura__c(Name = 'X', IdExterno__c = 'INV-1', Estado__c = 'Recibida');
        insert cand;
        cand.Estado__c = 'Oferta';
        Database.SaveResult sr = Database.update(cand, false);
        System.assertEquals(false, sr.isSuccess());
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, sr.getErrors()[0].getStatusCode());
        System.assertEquals('Recibida', [SELECT Estado__c FROM Candidatura__c WHERE Id = :cand.Id].Estado__c);
    }
}