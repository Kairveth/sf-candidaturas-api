//PENDIENTE-CLAVE
@RestResource(urlMapping='/candidaturas/*')
global with sharing class CandidaturaRest {

    @HttpPost
    global static void upsertCandidatura() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> body = parse(RestContext.request.requestBody);
        String idExterno = body == null ? null : (String) body.get('idExterno');
        if (String.isBlank(idExterno)) {
            responde(res, 400, '{"error":"idExterno obligatorio"}');
            return;
        }
        try {
            CandidaturaService.Result result = CandidaturaService.upsertByIdExterno(body);
            responde(res, result.created ? 201 : 200, JSON.serialize(result));
        } catch (CandidaturaService.CandidaturaException e) {
            responde(res, 400, JSON.serialize(new Map<String, String>{ 'error' => e.getMessage() }));
        } catch (CandidaturaService.TransicionException e) {
            responde(res, 409, JSON.serialize(new Map<String, String>{ 'error' => e.getMessage() }));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'CandidaturaRest: ' + e.getTypeName());
            responde(res, 500, '{"error":"error interno"}');
        }
    }

    private static Map<String, Object> parse(Blob payload) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(payload.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private static void responde(RestResponse res, Integer codigo, String json) {
        res.statusCode = codigo;
        res.responseBody = Blob.valueOf(json);
    }
}