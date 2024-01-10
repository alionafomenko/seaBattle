const oracledb = require('oracledb');
const dbconfig = require('./config.json');
let connection;

module.exports.connect = connect;
module.exports.registration = registration;
module.exports.autorisation = autorisation;
module.exports.startGame = startGame;
module.exports.getStatus = getStatus;
module.exports.sendCheckSum = sendCheckSum;
module.exports.sendAllShipsMap = sendAllShipsMap;
module.exports.sendHit = sendHit;
module.exports.sendAnswer = sendAnswer;

async function connect(){
    try {
        connection = await oracledb.getConnection(dbconfig);
        console.log('db connected');

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
            p_game_id => :p_game_id,
            p_error => :p_error);
end;`, [sessionId, {
                type: oracledb.DB_TYPE_NUMBER,
                dir: oracledb.BIND_OUT
            },
            {
                    type: oracledb.DB_TYPE_VARCHAR,
                    dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return {game_id: result.outBinds[0], error: result.outBinds[1]}
    } catch (e) {
        console.error(e);
    }

}


async function getStatus(sessionId) {
    try {
        let result = await connection.execute(`begin
  getstatus(p_sessionid => :p_sessionid,
            p_status => :p_status,
            p_recent_hit => :p_recent_hit,
            p_recent_hit_result => :p_recent_hit_result,
            p_game_id => :p_game_id,
            p_winner_id => :p_winner_id,
            p_error => :p_error);
end;`, [sessionId,
            {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            },
            {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            },
            {
                type: oracledb.DB_TYPE_NUMBER,
                dir: oracledb.BIND_OUT
            },
            {
                type: oracledb.DB_TYPE_NUMBER,
                dir: oracledb.BIND_OUT
            },
            {
                    type: oracledb.DB_TYPE_VARCHAR,
                    dir: oracledb.BIND_OUT
            },
            {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return {status: result.outBinds[0], recent_hit: result.outBinds[1],
            recent_hit_result: result.outBinds[2], game_id: result.outBinds[3],
            winner: result.outBinds[4], error: result.outBinds[5] };
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
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}

async function sendAllShipsMap(sessionId, map) {
    try {
        let result = await connection.execute(`begin
  sendallshipsmap(p_sessionid => :p_sessionid,
               p_map => :p_map,
               p_error => :p_error);
end;`, [sessionId, map, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}

async function sendHit(sessionId, hit) {
    try {
        let result = await connection.execute(`begin
  sendhit(p_sessionid => :p_sessionid,
          p_hit => :p_hit,
          p_error => :p_error);
end;
`, [sessionId, hit, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}


async function sendAnswer(sessionId, hitResult) {
    try {
        let result = await connection.execute(`begin
  sendanswer(p_sessionid => :p_sessionid,
             p_hit_result => :p_hit_result,
             p_error => :p_error);
end;
`, [sessionId, hitResult, {
                type: oracledb.DB_TYPE_VARCHAR,
                dir: oracledb.BIND_OUT
            }],
            {outFormat: oracledb.OUT_FORMAT_OBJECT});
        return result.outBinds[0];
    } catch (e) {
        console.error(e);
    }

}