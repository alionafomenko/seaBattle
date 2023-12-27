const oracledb = require('oracledb');
const dbconfig = require('./config.json');
let connection;

module.exports.connect = connect;
module.exports.registration = registration;
module.exports.autorisation = autorisation;
module.exports.startGame = startGame;
module.exports.getStatus = getStatus;
module.exports.sendCheckSum = sendCheckSum;

async function connect(){
    try {
        connection = await oracledb.getConnection(dbconfig);
        console.log('connected');

    } catch (e) {
        console.error(e)
    }

}


async function registration( name,  password) {
    console.log('method reg');
    try {
        let result = await connection.execute(`begin
  registration(p_name => :p_name,
               p_password => :p_password,
               p_error => :p_error);
end;
`, [ name,  password, {
            type: oracledb.DB_TYPE_VARCHAR,
            dir: oracledb.BIND_OUT
        }],
        {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}


async function autorisation( sessionId, name,  password) {
    try {
        let result = await connection.execute(`begin
  autorisation(p_sessionid => :p_sessionid,
               p_name => :p_name,
               p_password => :p_password,
               p_error => :p_error);
end;`, [sessionId, name,  password, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}


async function startGame( sessionId) {
    try {
        let result = await connection.execute(`begin
  startgame(p_sessionid => :p_sessionid,
            p_error => :p_error);
end;`, [sessionId, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}


async function getStatus(sessionId) {
    try {
        let result = await connection.execute(`begin
  getstatus(p_sessionid => :p_sessionid,
            p_status => :p_status,
            p_error => :p_error);
end;`, [sessionId, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return {status: result.outBinds[0], error: result.outBinds[1]};
    } catch (e) {
        console.error(e);
    }

}


async function sendCheckSum(sessionId, checkSum) {
    try {
        let result = await connection.execute(`begin
  sendchecksum(p_sessionid => :p_sessionid,
               p_checksum => :p_checksum,
               p_error => :p_error);
end;`, [sessionId, checkSum, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return {status: result.outBinds[0], error: result.outBinds[1]};
    } catch (e) {
        console.error(e);
    }

}