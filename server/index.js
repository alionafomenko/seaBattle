const http = require('http');
const url = require('url');
const callToDB = require('./callToDatabase');
const uuid = require('uuid');



const HTTP_PORT = 8080;



async function request(request, response) {

    let cookies = parseCookies(request.headers.cookie);
    let sessionId = cookies['SESSIONID'];
    console.log('sessionId', sessionId);

    let setSessionId;
    if (!sessionId) {
        setSessionId = uuid.v4();
        sessionId = setSessionId;
    }

    let data = await read_params(request);

    console.log('data: ' + JSON.stringify(data));

    if (/^\/registration/.test(request.url) && request.method === 'POST'){
       let error = await callToDB.registration( data.params.name, data.params.password);
       data.error = error;
    } else if (/^\/autorization/.test(request.url) && request.method === 'POST'){
        let error = await callToDB.autorisation(sessionId, data.params.name, data.params.password);
        data.error = error;
    } else if (/^\/startGame/.test(request.url) && request.method === 'POST'){
        data = await callToDB.startGame(sessionId);
    } else if (/^\/getStatus/.test(request.url) && request.method === 'GET'){
        data = await callToDB.getStatus(sessionId);
    }  else if (/^\/sendCheckSum/.test(request.url) && request.method === 'POST'){
        data.error = await callToDB.sendCheckSum(sessionId, data.params.checkSum);
    }  else if (/^\/sendAllShipsMap/.test(request.url) && request.method === 'POST'){
        data.error = await callToDB.sendAllShipsMap(sessionId, data.params.map);
    } else if (/^\/sendHit/.test(request.url) && request.method === 'POST'){
        data.error = await callToDB.sendHit(sessionId, data.params.hit);
    } else if (/^\/sendAnswer/.test(request.url) && request.method === 'POST'){
        data.error = await callToDB.sendAnswer(sessionId, data.params.hitResult);
    }

    gen_response(data, setSessionId, response);

}


function gen_response(data, setSessionId, response) {
    if (setSessionId){
        console.log('setSessionId:', setSessionId);
        response.setHeader('Set-Cookie', 'SESSIONID=' + setSessionId +'; Path=/');
    }
    response.setHeader('Content-Type', 'application/json');
    response.setHeader('Access-Control-Allow-Origin', 'http://aliona:5173');
    response.setHeader('Access-Control-Allow-Credentials', true);
    response.setHeader('Access-Control-Allow-Headers','*')
    response.setHeader('Access-Control-Allow-Methods','*')
    response.end(JSON.stringify(data));

    /* console.log('response',data);*/
};


http.createServer(function (req, res) {

    request(req, res);

}).listen(HTTP_PORT);

console.log('Server is listening on ' + HTTP_PORT);

function read_params(req) {

    let data = {url: req.url, method: req.method};

    return new Promise((resolve) => {

            if (req.method === 'POST') {
                let body = '';

                req.on('end', function () {
                    try {
                        if (body) {
                            data.params = JSON.parse(body);
                        } else {
                            data.params = '';
                        }
                    } catch (e) {
                        data.params = '';
                    }

                    resolve(data);
                });

                req.on('data', function (data) {
                    body += data;
                });

            } else {
                data.params = url.parse(req.url, true).query;
                resolve(data);
            }
        }
    );

}

function parseCookies(cookies) {
    let list = {},
        rc = cookies;

    rc && rc.split(';').forEach(function (cookie) {
        //util.log('cookie:' + cookie);
        let parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });
    return list;
}




async function main() {
    await callToDB.connect();

}

main();
