exports.handler = async (event, context) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;
    const headerNameSrc = 'cross-origin';
    const headerNameDst = 'Cross-Origin-Resource-Policy';

    headers[headerNameDst.toLowerCase()] = [{
        key: headerNameDst,
        value: headerNameSrc,
    }];
    console.log("EVENT0\n" + JSON.stringify(event, null, 2));

    return response;
};
