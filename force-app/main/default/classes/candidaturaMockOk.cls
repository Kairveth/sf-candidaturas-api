//DEMO-1005
@IsTest
global class candidaturaMockOk implements HttpCalloutMock {

    global static Integer llamadas = 0;

    global HttpResponse respond(HttpRequest req) {
        llamadas++;
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{}');
        return res;
    }
}