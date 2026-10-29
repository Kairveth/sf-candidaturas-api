//DEMO-1001
public with sharing class CandidaturaTriggerHandler {

    private static final Map<String, Set<String>> TRANSICIONES = new Map<String, Set<String>>{
        'Recibida' => new Set<String>{ 'En revisión', 'Descartada' },
        'En revisión' => new Set<String>{ 'Entrevista', 'Descartada' },
        'Entrevista' => new Set<String>{ 'Oferta', 'Descartada' },
        'Oferta' => new Set<String>(),
        'Descartada' => new Set<String>()
    };

    public static void validaTransiciones(List<Candidatura__c> nuevas, Map<Id, Candidatura__c> antiguas) {
        for (Candidatura__c cand : nuevas) {
            String previo = antiguas.get(cand.Id).Estado__c;
            if (cand.Estado__c == previo) {
                continue;
            }
            Set<String> permitidas = TRANSICIONES.get(previo);
            if (permitidas == null || !permitidas.contains(cand.Estado__c)) {
                cand.addError('Transición no válida: ' + previo + ' a ' + cand.Estado__c);
                continue;
            }
            if (cand.Estado__c == 'Descartada') {
                cand.FechaDescarte__c = Date.today();
            }
        }
    }

    public static Set<String> permitidas(String estado) {
        return TRANSICIONES.containsKey(estado) ? TRANSICIONES.get(estado) : new Set<String>();
    }
}