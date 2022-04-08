exports.handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const querystring = require('querystring');
    const qparms = request.querystring;
    const now = Date.now();
    console.log(`Running Lambda@Edge function on Origin Request at "${now}"`);
    console.log("EVENT0\n" + JSON.stringify(event, null, 2));

    var n = qparms.search(".com");
    var k = qparms.search("://");
    var stlnth = qparms.length;
    var domainName = qparms.slice(k+3, n+4);
    if (qparms.includes("\?")) {
        var qsmrk = qparms.search("\\?");
        var qrystg = qparms.slice(qsmrk+1, stlnth);
        var uri = qparms.slice(n+4, qsmrk);
    }
    else {
        var qrystg = "";
        var uri = qparms.slice(n+4, stlnth);
    }

    request.querystring = qrystg;
    request.uri = uri;
    request.origin.custom.domainName = domainName;
    request.headers['host'] = [{ key: 'host', value: domainName}];
    console.log("EVENT1\n" + JSON.stringify(event, null, 2));

    return callback(null, request);
};
