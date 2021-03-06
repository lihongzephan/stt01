﻿// vars
var gbolDebug = true;
var aryClients = [];
var fs = require('fs');
var intHBTimeout = 30000;
var bolAllowDuplicateLogin = true;


var base64 = require('base-64');
var utf8 = require('utf8');

var intTTSCHMax = 256;



// For wikipedia
const http = require('https');



// Bing Image Search
// Old key
//var BingSubscriptionKey = 'b0541b758e434de198f1cc60e02ed865';
// New key
var BingSubscriptionKey = 'c91fc63e21fe4b009ab0904ef3b6efff';
var BingHost = 'api.cognitive.microsoft.com';
var BingPath = '/bing/v7.0/images/search';
let httpsBing = require('https');



// Baidu Ai vars
var AipOcrClient = require("baidu-aip-sdk").ocr;
var AipImageClassifyClient = require("baidu-aip-sdk").imageClassify;
var AipSpeechClient = require("baidu-aip-sdk").speech;

// Baidu Ai vars
var AipOcrClient = require("baidu-aip-sdk").ocr;
var AipImageClassifyClient = require("baidu-aip-sdk").imageClassify;
var AipSpeechClient = require("baidu-aip-sdk").speech;

// 设置APPID/AK/SK
var BaiduAPP_ID = "14301112";
var BaiduAPI_KEY = "3Fq5fsenXArjXfaMuInYfhqO";
var BaiduSECRET_KEY = "Xmw4PIUFtHp8rF9VXaN4Fk5G1tS1c6VV";

// 新建一个对象，建议只保存一个对象调用服务接口
var clientBaidu = new AipOcrClient(BaiduAPP_ID, BaiduAPI_KEY, BaiduSECRET_KEY);
var clientBaiduImageClassify = new AipImageClassifyClient(BaiduAPP_ID, BaiduAPI_KEY, BaiduSECRET_KEY);
var clientSpeech = new AipSpeechClient(BaiduAPP_ID, BaiduAPI_KEY, BaiduSECRET_KEY);

var BaiduTranslateAppID = "20180927000212888";
var BaiduTranslateAppKey = "YwjB9cJ_L6E8HCCDZKng";


// Email Related
var nodemailer = require('nodemailer');
var transporter = nodemailer.createTransport({
    host: "smtp.mxhichina.com",
    port: 465,
    secure: true, // true for 465, false for other ports
    auth: {
      user: 'info@zephan.top', // Email User Name
      pass: fs.readFileSync('infoATzephan.top.txt').toString().replace(/\n/g, '') // Email Password stored in a file in the same directory of app.js
    }
});


Date.prototype.Format = function (fmt) { //author: meizz
    let o = {
        "M+": this.getMonth() + 1, // Month
        "d+": this.getDate(), // Day
        "h+": this.getHours(), // Hour
        "m+": this.getMinutes(), // Minute
        "s+": this.getSeconds(), // Seconds
        "q+": Math.floor((this.getMonth() + 3) / 3), // Quarter
        "S": this.getMilliseconds() // Milliseconds
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (let k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
};


// Console Related
function funUpdateConsole(msg, bolDebugOnly) {
    let bolShouldShow = false;
    try {
        if (bolDebugOnly) {
            if (gbolDebug) {
                bolShouldShow = true;
            }
        } else {
            bolShouldShow = true;
        }
        if (bolShouldShow) {
            let strTempDate = new Date().Format("yyyy-MM-dd hh:mm:ss");
            console.log(strTempDate + " : " + msg);
        }
    } catch (err) {
        console.log(err.message);
    }
}



// The new method use connection pool, which connection(s) will be created automatically when needed
var mysql = require('mysql');
var pool = mysql.createPool({
    connectionLimit: 10,
    host: "localhost",
    user: "root",
    password: fs.readFileSync('mysqlpw.txt').toString().replace(/\n/g, ''),
    database: "ken068802"
});




// Socket.IO Server for Server Monitor to connect
var appServer = require('express')();
var httpServer = require('http').Server(appServer);
var ioServer = require('socket.io')(httpServer);

appServer.get('/', function (req, res) {
    res.sendFile(__dirname + '/server.html');
});

ioServer.on('connection', function (socket) {
    funUpdateConsole('ken068802 WebServer Monitor Initialized', false);
    socket.on('disconnect', function () {
        funUpdateConsole('ken068802 WebServer Monitor Disconnected', false);
    });
});

httpServer.listen(10502, function () {
    funUpdateConsole('ken068802 WebServer Monitor listening on *:10502', false);
});

function funUpdateServerMonitor(strMsg, bolDebugOnly) {
    let bolShouldShow = false;
    try {
        if (bolDebugOnly) {
            if (gbolDebug) {
                bolShouldShow = true;
            }
        } else {
            bolShouldShow = true;
        }
        if (bolShouldShow) {
            let strTempDate = new Date().Format("yyyy-MM-dd hh:mm:ss");
            ioServer.emit('chat message', strTempDate + " : " + strMsg);
        }
    } catch (err) {
        //
    }
}




// Socket.IO Server for Client to connect
var ioClient = require('socket.io');
var httpClient = require('http');

var serverClient = httpClient.createServer(function (req, res) {
    let headers = {};
    headers["Access-Control-Allow-Origin"] = "*";
    headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, DELETE, OPTIONS";
    //    headers["Access-Control-Allow-Credentials"] = true;
    headers["Access-Control-Max-Age"] = '86400'; // 24 hours
    headers["Access-Control-Allow-Headers"] = "X-Requested-With, Access-Control-Allow-Origin, X-HTTP-Method-Override, Content-Type, Authorization, Accept";
    res.writeHead(200, headers);
    res.end();
});
serverClient.listen(10531, '');

var serverRBClient = httpClient.createServer(function (req, res) {
    let headers = {};
    headers["Access-Control-Allow-Origin"] = "*";
    headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, DELETE, OPTIONS";
    //    headers["Access-Control-Allow-Credentials"] = true;
    headers["Access-Control-Max-Age"] = '86400'; // 24 hours
    headers["Access-Control-Allow-Headers"] = "X-Requested-With, Access-Control-Allow-Origin, X-HTTP-Method-Override, Content-Type, Authorization, Accept";
    res.writeHead(200, headers);
    res.end();
});
serverRBClient.listen(10533, '');


funUpdateConsole('ThisApp Socket.IO Server running at port 10531', false);

funUpdateConsole('RB Socket.IO Server running at port 10533', false);






// Core Programs



// Show Clients' List every 30 seconds
function funShowClients() {
    for (let i = 0; i < aryClients.length; i++) {
        try {
            funUpdateServerMonitor("Connection Code: " + aryClients[i].connectionCode + "&nbsp;&nbsp;&nbsp;User ID: " + aryClients[i].userId + "&nbsp;&nbsp;&nbsp;WebRTC Id: " + aryClients[i].webRtcId, true);
        } catch (err) {
            //
        }
    }
    // let dtTemp = Date.now();
    setTimeout(funShowClients, 30000);
}
funShowClients();



// Listen to socket
var socketAll = new ioClient();
socketAll.attach(serverClient);

// var socketAll = ioClient.listen(serverClient);
socketAll.on('connection', function (socket) {
    funUpdateServerMonitor("Client Connected, Socket ID: " + socket.id, false);
    // socket.emit("UpdateYourSocketID", socket.id);

    // Add Connection to Array with Empty User ID
    aryClients.push({ connectionCode: socket.id, userId: '', lastHB: Date.now(), socket: socket, webRtcId: ''});


    socket.on('removeClientUserId', function (userid) {
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socket.id) {
                aryClients[i].userId = "";
                funUpdateConsole("Remove User ID: " + userid + " from Socket ID: " + socket.id, true);
            }
        }
        // socketAll.emit("ServerUpdateUserList", aryClients);
    });


    socket.on('disconnect', function () {
        funUpdateServerMonitor("Client Disconnected, Socket ID: " + socket.id, false);
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socket.id) {
                aryClients.splice(i, 1);
            }
        }
        // socketAll.emit("ServerUpdateUserList", aryClients);
    });


    socket.on('HB', function (strUserID, strWebRtcId) {
        funUpdateServerMonitor("Heart Beat from Socket ID: " + socket.id, true);
        //funUpdateServerMonitor("HB webRtcId: " + strWebRtcId, true);
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socket.id) {
                aryClients[i].lastHB = Date.now();
                aryClients[i].userId = strUserID;
                aryClients[i].webRtcId = strWebRtcId;
            }
        }

        // HB Return
        socketAll.emit('HBReturn');
    });


    socket.on('ActivateToServer', function (strUsrID, strActCode) {
        funActivate(strUsrID, strActCode, socket.id);
    });

    socket.on('SendEmailAgain', function (strUsrID, strLang) {
        funSendEmailAgain(strUsrID, strLang, socket.id);
    });

    socket.on('LoginToServer', function (strUsrID, strUsrPW, bolFirstTime) {
        funCheckLogin(strUsrID, strUsrPW, socket.id, bolFirstTime);
    });

    socket.on('LogoutFromServer', function (data) {
        funLogout(socket.id);
    });

    socket.on('Register', function (strUsrID, strUsrPW, strUsrNick, strUsrEmail, strLang) {
        funCheckRegister(strUsrID, strUsrPW, strUsrNick, strUsrEmail, socket.id, strLang);
    });

    socket.on('GetPerInfo', function (strUsrID) {
        funGetPerInfo(strUsrID, socket.id);
    });

    socket.on('ChangePerInfo', function (strUsrID, strUsrNick, strUsrEmail, bolEmailChanged, strLang) {
        funChangePerInfo(strUsrID, strUsrNick, strUsrEmail, bolEmailChanged, socket.id, strLang);
    });

    socket.on('ChangePassword', function (strUsrID, strUsrPWOld, strUsrPW) {
        funChangePassword(strUsrID, strUsrPWOld, strUsrPW, socket.id);
    });

    socket.on('ForgetPassword', function (strUsrEmail, strLang) {
        funForgetPassword(strUsrEmail, socket.id, strLang);
    });

    socket.on('ClientNeedAIML', function (strAIML, strLang) {
        let clientUserId = '';
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socket.id) {
                clientUserId = aryClients[i].userId;
                break;
            }
        }
        funUpdateServerMonitor("Client Need Python aiml: " + strAIML + ' userid: ' + clientUserId + ' strLang: ' + strLang, false);
        
        // Increate Counter
        gintAIMLCount += 1;

        // Push into Array
        aryAIML.push({ count: gintAIMLCount, sockID: socket.id, userID: clientUserId});
        
        funpyAIMLGotDataFromClient('', 'ANSWER::' + gintAIMLCount.toString() + ';' + strAIML);

        // funRequestPythonAIML(strAIML, strLang, socket.id, clientUserId);
    });

    socket.on('RBMoveRobot', function (RBcode,aryRBMoveRobot) {
        funRBMoveRobot(RBcode,aryRBMoveRobot);
    });

    socket.on('ZFBClientSentValue', function (strValue) {
        funZFBValueDB(strValue);
    });

    socket.on('PIBRequestPhotoClassify', function (imgB64) {
        let usrId = '';
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socket.id) {
                usrId = aryClients[i].userId;
                break;
            }
        }

        funUpdateServerMonitor('Got pib photo request classify from usrId: ' + usrId);

        funBaiduAIImageClassify(imgB64, 'pibRequestPhoto', [socket.id, usrId]);
    });

    socket.on('SttRequestPibWebRtc', function (strUserID) {
        let webRtcId = '';

        for (let x = 0; x < aryClients.length; x++) {
            if (aryClients[x].userId === strUserID && aryClients[x].connectionCode != socket.id) {
                webRtcId = aryClients[x].webRtcId;
                break;
            }
        }

        socketAll.emit("ServerSendPibWenRtcToStt", [webRtcId]);
        if (webRtcId == '') {
            funUpdateServerMonitor('Cannot found pib webrtc id');
        } else {
            funUpdateServerMonitor('Sent Pib Web Rtc id to stt: ' + webRtcId);
        }

    });

    // Catch any unexpected error, to avoid system hangs
    socket.on('error', function () { });
});
// Disconnect clients without HB
function funCheckHB() {
    try {
        for (let i = 0; i < aryClients.length; i++) {
            if (Date.now() > aryClients[i].lastHB + intHBTimeout) {
                funUpdateServerMonitor("No HB Disconnect: " + aryClients[i].connectionCode, true);
                aryClients[i].socket.disconnect();
            }
        }
    } catch (err) {
        // If someone disconnect, there will be an error because aryClients.length changes
        // funUpdateServerMonitor("No HB Disconnect Error: " + err, true);
    }

    // let dtTemp = Date.now();
    setTimeout(funCheckHB, intHBTimeout);
}
funCheckHB();










// SQL Related


// Check Login
function funCheckLogin(strUsrID, strUsrPW, socketID, bolFirstTime) {
    try {
        let sql = 'Select usr_id, usr_nick, usr_status, usr_picture From userid where usr_id = ? AND usr_pw = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID, strUsrPW], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', bolFirstTime, result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        aryResult[0] = '1000';
                    } else {
                        // Login Success, replace usr_id in aryClient
                        funUpdateClientUserId(strUsrID, socketID);
                    }
                    socketAll.to(`${socketID}`).emit('LoginResult', aryResult);
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('LoginResult', ['9999', bolFirstTime, '9999']);
    }
}
// Update aryClient when Login Success
function funUpdateClientUserId(userid, socketID) {
    try {
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode === socketID) {
                aryClients[i].userId = userid;
                aryClients[i].lastHB = Date.now();
                funUpdateServerMonitor("Update User ID: " + userid + " from Socket ID: " + socketID, true);
                break;
            }
        }
        // socketAll.emit("ServerUpdateUserList", aryClients);

        if (!bolAllowDuplicateLogin) {
            // Duplicate Login is not allowed
            // Remove all other Login Users with the same userid
            for (let i = 0; i < aryClients.length; i++) {
                if (aryClients[i].connectionCode !== socketID && aryClients[i].userId === userid) {
                    // Here same userID logined with another socket connection, we need to remove that connection
                    socketAll.to(`${aryClients[i].connectionCode}`).emit('ForceLogoutByServer', ['9001']);
                    funUpdateServerMonitor("Duplicate Login ID: " + aryClients[i].userId + " removed with Socket ID: " + aryClients[i].connectionCode, true);
                    // Clear UserID of this socket connection
                    aryClients[i].userId = '';
                }
            }
        }
    } catch (err) {
        funUpdateServerMonitor("funUpdateClientUserId Unexpected Error: " + err, true);
    }
}
// Logout From Server
function funLogout(socketID) {
    try {
        for (let i = 0; i < aryClients.length; i++) {
            if (aryClients[i].connectionCode == socketID) {
                aryClients[i].userId = '';
                break;
            }
        }
    } catch (err) {
        funUpdateServerMonitor("funLogout Unexpected Error: " + err, true);
    }
}
// Register Check Existing UserID
function funCheckRegister(strUsrID, strUsrPW, strUsrNick, strUsrEmail, socketID, strLang) {
    try {
        let sql = 'SELECT usr_id FROM userid WHERE usr_id = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        // Not Found, Add New Record
                        funAddNewUser(strUsrID, strUsrPW, strUsrNick, strUsrEmail, socketID, strLang);
                    } else {
                        // Record Found, return Error
                        aryResult[0] = '1000';
                        socketAll.to(`${socketID}`).emit('RegisterResult', aryResult);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('RegisterResult', ['9999', '9999']);
    }
}
// Add New User
function funAddNewUser(strUsrID, strUsrPW, strUsrNick, strUsrEmail, socketID, strLang) {
    try {
        let sql = 'INSERT INTO userid (usr_id, usr_nick, usr_pw, usr_email, usr_joindt, usr_status, usr_confirmcode) VALUES (?, ?, ?, ?, ?, ?, ?)';
        let strTempDate = new Date().Format("yyyy-MM-dd hh:mm:ss.S");
        let strTempStatus = 'A';
        let strTempRandom = funGenRandomNumber(6);
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID, strUsrNick, strUsrPW, strUsrEmail, strTempDate, strTempStatus, strTempRandom], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result['affectedRows'] !== 0) {
                        // Record Added
                        socketAll.to(`${socketID}`).emit('RegisterResult', aryResult);

                        // Send Email
                        funSendEmail(strUsrID, strUsrNick, strUsrEmail, strTempRandom, strLang);
                    } else {
                        // Record Not Added, System Error
                        socketAll.to(`${socketID}`).emit('RegisterResult', ['9999', '9999']);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('RegisterResult', ['9999', '9999']);
    }
}
function funSendEmail(strUsrID, strUsrNick, strUsrEmail, strTempRandom, strLang) {
    try {
        let strSubject = '';
        let strText = '';
        let strHTML = '';
        switch (strLang) {
            case 'EN':
                strSubject = 'Account Activation Email';
                strHTML = 'Dear ' + strUsrNick + ',<br><br>';
                strHTML += 'You have created an User ID: ' + strUsrID + '<br><br>';
                strHTML += 'The Activation Code is: ' + strTempRandom + '<br><br>';
                strHTML += 'Please use the Activation Code inside your mobile phone app to activate your account, thank you.<br><br>';
                strHTML += 'Best Regards, <br><br>';
                strHTML += 'info@zephan.top';
                strText = 'Dear ' + strUsrNick + ',\n\n';
                strText += 'You have created an User ID: ' + strUsrID + '\n\n';
                strText += 'The Activation Code is: ' + strTempRandom + '\n\n';
                strText += 'Please use the Activation Code inside your mobile phone app to activate your account, thank you.\n\n';
                strText += 'Best Regards, \n\n';
                strText += 'info@zephan.top';
                break;
            case 'SC':
                strSubject = '账户激活邮件';
                strHTML = strUsrNick + ' 您好,<br><br>';
                strHTML += '您注册了一个新的账号：' + strUsrID + '<br><br>';
                strHTML += '激活码是：' + strTempRandom + '<br><br>';
                strHTML += '请在手机 App 内使用激活码激活账户，谢谢。<br><br>';
                strHTML += 'info@zephan.top';
                strText = strUsrNick + ' 您好,\n\n';
                strText += '您注册了一个新的账号：' + strUsrID + '\n\n';
                strText += '激活码是：' + strTempRandom + '\n\n';
                strText += '请在手机 App 内使用激活码激活账户，谢谢。\n\n';
                strText += 'info@zephan.top';
                break;
            default:
                strSubject = '賬戶激活郵件';
                strHTML = strUsrNick + ' 您好,<br><br>';
                strHTML += '您註冊了一個新的賬號：' + strUsrID + '<br><br>';
                strHTML += '激活碼是：' + strTempRandom + '<br><br>';
                strHTML += '請在手機 App 內使用激活碼激活賬戶，謝謝。<br><br>';
                strHTML += 'info@zephan.top';
                strText = strUsrNick + ' 您好,\n\n';
                strText += '您註冊了一個新的賬號：' + strUsrID + '\n\n';
                strText += '激活碼是：' + strTempRandom + '\n\n';
                strText += '請在手機 App 內使用激活碼激活賬戶，謝謝。\n\n';
                strText += 'info@zephan.top';
                break;
        }
        let mailOptions = {
            from: 'info@zephan.top',
            to: strUsrEmail,
            subject: strSubject,
            text: strText,
            html: strHTML
        };
        transporter.sendMail(mailOptions, function(error, info){
            if (error) {
                // console.log(error);
            } else {
                // console.log('Email sent: ' + info.response);
            }
        });
    } catch (err) {
        // Send Email System Error
    }
}
// Activate
function funActivate(strUsrID, strActCode, socketID) {
    try {
        let sql = 'SELECT usr_id, usr_status FROM userid WHERE usr_id = ? AND usr_confirmcode = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID, strActCode], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        // Activate Code Not Correct
                        aryResult[0] = '0300';
                        socketAll.to(`${socketID}`).emit('ActivateResult', aryResult);
                    } else {
                        // User Found, check user status
                        if (result[0]['usr_status'] == 'E') {
                            // Already Activate, Return
                            aryResult[0] = '0100';
                            socketAll.to(`${socketID}`).emit('ActivateResult', aryResult);
                        } else if (result[0]['usr_status'] == 'D') {
                            // Account Disabled, Return
                            aryResult[0] = '0200';
                            socketAll.to(`${socketID}`).emit('ActivateResult', aryResult);
                        } else {
                            // Not Yet Activate, Activate Now
                           funActivateSQL(strUsrID, socketID);
                        }
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('ActivateResult', ['9999', '9999']);
    }
}
// Activate Account SQL
function funActivateSQL(strUsrID, socketID) {
    try {
        let sql = "UPDATE userid SET usr_status = 'E' WHERE usr_id = ?";
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result['affectedRows'] !== 0) {
                        // Record Added
                        socketAll.to(`${socketID}`).emit('ActivateResult', aryResult);
                    } else {
                        // Record Not Updated, System Error
                        socketAll.to(`${socketID}`).emit('ActivateResult', ['9999', '9999']);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('ActivateResult', ['9999', '9999']);
    }
}
// Send Email Again
function funSendEmailAgain(strUsrID, strLang, socketID) {
    try {
        let sql = 'SELECT usr_id, usr_nick, usr_email, usr_confirmcode FROM userid WHERE usr_id = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        // User Not Found, Impossible
                        aryResult[0] = '9999';
                        socketAll.to(`${socketID}`).emit('SendEmailAgainResult', aryResult);
                    } else {
                        // User Found, Send Email Again
                        funSendEmail(strUsrID, result[0]['usr_nick'], result[0]['usr_email'], result[0]['usr_confirmcode'], strLang);
                        socketAll.to(`${socketID}`).emit('SendEmailAgainResult', aryResult);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('SendEmailAgainResult', ['9999', '9999']);
    }
}
// Get Personal Information
function funGetPerInfo(strUsrID, socketID) {
    try {
        let sql = 'SELECT usr_id, usr_nick, usr_email FROM userid WHERE usr_id = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrID], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        // User Not Found, Impossible
                        aryResult[0] = '9999';
                        socketAll.to(`${socketID}`).emit('GetPerInfoResult', aryResult);
                    } else {
                        // User Found
                        socketAll.to(`${socketID}`).emit('GetPerInfoResult', aryResult);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('GetPerInfoResult', ['9999', '9999']);
    }
}
// Change Personal Info
function funChangePerInfo(strUsrID, strUsrNick, strUsrEmail, bolEmailChanged, socketID, strLang) {
    try {
        let strTempRandom = '';
        let sql = '';
        let arySQL = [];
        if (bolEmailChanged) {
            strTempRandom = funGenRandomNumber(6);
            sql = "UPDATE userid SET usr_nick = ?, usr_email = ?, usr_confirmcode = ?, usr_status = 'A' WHERE usr_id = ?";
            arySQL = [strUsrNick, strUsrEmail, strTempRandom, strUsrID];
        } else {
            sql = "UPDATE userid SET usr_nick = ? WHERE usr_id = ?";
            arySQL = [strUsrNick, strUsrID];
        }
        pool.getConnection(function (err, connection) {
            connection.query(sql, arySQL, function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result['affectedRows'] !== 0) {
                        // Record Updated
                        socketAll.to(`${socketID}`).emit('ChangePerInfoResult', aryResult);

                       if (bolEmailChanged) {
                            // Send Email Again
                            funSendEmail(strUsrID, strUsrNick, strUsrEmail, strTempRandom, strLang);
                        }
                    } else {
                        // Record Not Updated, System Error
                        socketAll.to(`${socketID}`).emit('ChangePerInfoResult', ['9999', '9999']);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('ChangePerInfoResult', ['9999', '9999']);
    }
}
// Change Password
function funChangePassword(strUsrID, strUsrPWOld, strUsrPW, socketID) {
    try {
        let sql = "UPDATE userid SET usr_pw = ? WHERE usr_id = ? AND usr_pw = ?";
        let arySQL = [strUsrPW, strUsrID, strUsrPWOld];
        pool.getConnection(function (err, connection) {
            connection.query(sql, arySQL, function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result['affectedRows'] !== 0) {
                        // Record Updated
                        socketAll.to(`${socketID}`).emit('ChangePasswordResult', aryResult);
                    } else {
                        // Old Password Not Correct
                        aryResult[0] = '1000';
                        socketAll.to(`${socketID}`).emit('ChangePasswordResult', aryResult);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('ChangePasswordResult', ['9999', '9999']);
    }
}
// Forget Password
function funForgetPassword(strUsrEmail, socketID, strLang) {
    try {
        let sql = 'SELECT usr_id, usr_pw FROM userid WHERE usr_email = ?';
        pool.getConnection(function (err, connection) {
            connection.query(sql, [strUsrEmail], function (err, result) {
                if (err) {
                    pool.releaseConnection(connection);
                    // throw err;
                } else {
                    // Save result value
                    let aryResult = ['0000', result];
                    pool.releaseConnection(connection);
                    if (result.length === 0) {
                        aryResult[0] = '1000';
                        socketAll.to(`${socketID}`).emit('ForgetPasswordResult', aryResult);
                    } else {
                        // Found User ID and Password
                        funForgetPWSendEmail(strUsrEmail, result, strLang);
                        socketAll.to(`${socketID}`).emit('ForgetPasswordResult', aryResult);
                    }
                }
            });
        });
    } catch (Err) {
        socketAll.to(`${socketID}`).emit('ForgetPasswordResult', ['9999', '9999']);
    }
}
function funForgetPWSendEmail(strUsrEmail, result, strLang) {
    try {
        let strSubject = '';
        let strText = '';
        let strHTML = '';
        let strTemp1 = '';
        let strTemp2 = '';
        switch (strLang) {
            case 'EN':
                strSubject = 'Forget Password';
                strHTML = 'Your List of User ID and Password:'+ '<br><br>';
                strText = 'Your List of User ID and Password:'+  '\n\n';
                strTemp1 = 'User ID:  ';
                strTemp2 = 'Password: ';
                break;
            case 'SC':
                strSubject = '忘记密码';
                strHTML = '账号密码列表：'+ '<br><br>';
                strText = '账号密码列表：'+  '\n\n';
                strTemp1 = '账号：';
                strTemp2 = '密码：';
                break;
            default:
                strSubject = '忘記密碼';
                strHTML = '賬號密碼列表：'+ '<br><br>';
                strText = '賬號密碼列表：'+  '\n\n';
                strTemp1 = '賬號：';
                strTemp2 = '密碼：';
                break;
        }

        // Loop for result
        for (let i=0; i<result.length; i++) {
            strHTML += strTemp1 + result[i]['usr_id'] + '<br>';
            strHTML += strTemp2 + result[i]['usr_pw'] + '<br><br>';
            strText += strTemp1 + result[i]['usr_id'] + '\n';
            strText += strTemp2 + result[i]['usr_pw'] + '\n\n';
        }

        let mailOptions = {
            from: 'info@zephan.top',
            to: strUsrEmail,
            subject: strSubject,
            text: strText,
            html: strHTML
        };
        transporter.sendMail(mailOptions, function(error, info){
            if (error) {
                // console.log(error);
            } else {
                // console.log('Email sent: ' + info.response);
            }
        });
    } catch (err) {
        // Send Email System Error
    }
}







// Here are functions for AIML

// For client using app
var aryAIML = [];
var gintAIMLCount = 0;

function funRequestPythonAIML(strAIML, strLang, socID, clientUserId) {
    // Increate Counter
    gintAIMLCount += 1;

    // Push into Array
    aryAIML.push({ count: gintAIMLCount, sockID: socID, userID: clientUserId  });
    

    //strAIML = "你好嗎你好嗎";


    let bytesAIML = utf8.encode(strAIML);
    let b64AIML = base64.encode(bytesAIML);
    //strAIML = Buffer.from(strAIML).toString('utf8');
    funUpdateServerMonitor("b64AIML: " + b64AIML, true);


    // Here Call Python AIML
    // let strSendToPy = 'MESSAGE:' + gintAIMLCount + ';' + strAIML;
    let strSendToPy = 'MESSAGE:' + gintAIMLCount + ';' + b64AIML + ';' + strLang;
    funUpdateServerMonitor("Server send to py client message: " + strSendToPy, true);

    // there may be no pyAIML
    try {
        //strSendToPy = Buffer.from(strSendToPy).toString('base64');
        pyAIML[0].socketID.write(utf8Encode(strSendToPy));
        //pyAIML[0].socketID.write(strAIML);
    } catch (err) {
        // return to client
        socketAll.to(`${socID}`).emit('SocketSendAIMLToClient', ['No aiml yet']);
        funUpdateServerMonitor("Sent aiml answer to client: " + 'No aiml yet'  + ' socketid: ' + socID, false);
        aryAIML.splice(aryAIML.length - 1, 1);
    }
}


function funAIMLEndRes(idSocket, idUser, strAnswer) {
    // Get Count in Array

    funUpdateServerMonitor("Start AIML End Res, ans: " + strAnswer, false);

    // Send to client
    //socketAll.to(`${idSocket}`).emit('SocketSendAIMLToClient', [strAnswer]);
    //funUpdateServerMonitor("Sent aiml answer to client: " + strAnswer, false);

    // Send to ONE pib
    for (let x = 0; x < aryClients.length; x++) {
        if (idUser === aryClients[x].userId && idSocket != aryClients[x].connectionCode) {
            socketAll.to(`${aryClients[x].connectionCode}`).emit('TtsStart', [strAnswer]);
            funUpdateServerMonitor("Sent aiml answer to pib: " + strAnswer, false);
            break;
        }
    }
}

function funRBMoveRobot(RBcode,aryRBMoveRobot) {
    funUpdateServerMonitor("RBMoveRobot, rbCode: " + RBcode, false);
    for (let i = 0; i < aryRBClients.length; i++) {
        if (aryRBClients[i].rbCode == RBcode) {
            funUpdateServerMonitor("Found rb code, rbCode: " + RBcode, false);
            socketRB.to(`${aryRBClients[i].connectionCode}`).emit('moveRobot', aryRBMoveRobot);
            break;
        }
    }
}



// For python clients, they translate aiml questions to answers

// vars
var pyAIMLnet = require('net');
var pyAIMLPORT = 10532;

// pyAIML contains all the Python AIML Clients
// actually, there is only 1
var pyAIML = [];


// Below Bigaibot Related

try {
    var pyAIMLServer = pyAIMLnet.createServer(function (sock) {
        try {
            // If client connect, push client into List
            let dtTemp = Date.now();
            sock.name = sock.remoteAddress + ':' + sock.remotePort;
            pyAIML.push({ userID: "", socketID: sock, dtLastHB: dtTemp });

            // No need to setEncoding
            // sock.setEncoding('binary');

            // Set No Delay so that WRITE will be sent immediately
            sock.setNoDelay(true);

            // ????????????? - ????????????????socket????
            funUpdateServerMonitor('pyAIML CONNECTED', true);
            funUpdateServerMonitor('pyAIML CONNECTED: ' +
                sock.remoteAddress + ':' + sock.remotePort, true);

            // ????socket?????????"data"?????????
            sock.on('data', function (data) {
                funpyAIMLGotDataFromClient(sock, data);
            });

            // ????socket?????????"close"?????????
            sock.on('close', function (data) {
                funUpdateServerMonitor('pyAIML DISCONNECTED: ' +
                    sock.remoteAddress + ':' + sock.remotePort, true);
                funpyAIMLRemoveUser(sock);
            });

            sock.on('error', function () {
                // Error
            });
        } catch (err) {
            funUpdateServerMonitor("pyAIML Create Server Error: " + err, true);
        }
    }).listen(pyAIMLPORT);
} catch (Err) {
    //
}


funUpdateConsole('pyAIML Socket Server Listening on: ' +
    pyAIMLPORT, true);


function funpyAIMLGotDataFromClient(sock, data) { 
    try {
        let i = 0;
        let strTemp = data.toString('utf-8');
        if (strTemp === 'HBHBHBHB') {
            // At Least 8 bytes must be sent, for example, send only HB, EV3 will receive NOTHING
            // Also, must use utf8Encode, otherwise EV3 will also receive NOTHING
            // HeartBeat
            let dtTemp = Date.now();
            for (i = 0; i < pyAIML.length; i++) {
                if (pyAIML[i].socketID.name === sock.name) {
                    pyAIML[i].dtLastHB = dtTemp;
                }
            }
            let bolTemp = sock.write(utf8Encode('HBHBHBHB'));
        } else if (strTemp.indexOf('|||LOGIN') === 0) {
            // Login
            for (i = 0; i < pyAIML.length; i++) {
                if (pyAIML[i].socketID.name === sock.name) {
                    // Suppose UserID is what after the first 8 chars |||LOGIN
                    pyAIML[i].userID = strTemp.substring(8);
                    pyAIML[i].socketID.write(utf8Encode('|LOGINOK'));
                    //pyAIML[i].socketID.write('|LOGINOK');
                    funUpdateServerMonitor("pyAIML Client Login ID: " + strTemp.substring(8) + "   Address: " + sock.name, true);
                }
            }
        } else if (strTemp.indexOf('ANSWER::') === 0) {
            let strAnswerTemp = strTemp.substring(8);

            // Get Count
            let intTemp = strAnswerTemp.indexOf(';');
            let intCount = parseInt(strAnswerTemp.substring(0, intTemp));
            let strAnswer = strAnswerTemp.substring(intTemp + 1);
            funUpdateServerMonitor("pyAIML Answer: " + strAnswer, true);

            // Get socket id and user id
            let idSocket = '';
            let idUser = '';
            for (let i = 0; i < aryAIML.length; i++) {
                if (intCount === aryAIML[i].count) {
                    idSocket = aryAIML[i].sockID;
                    idUser = aryAIML[i].userID;
                    aryAIML.splice(i, 1);
                    break;
                }
            }


            //socket.emit('BGBClientToServer', strAnswer);
            //strAnswer = funCheckFunInAnswer(intCount,strAnswer);
            funCheckFunInAnswer(idSocket, idUser, strAnswer);
            //funAIMLEndRes(intCount, strAnswer);
        } else {
            //
        }
    } catch (err) {
        funUpdateServerMonitor("funpyAIMLGotoDataFromClient Error: " + err, true);
    }
}



function funCheckFunInAnswer(idSocket, idUser, strAns) {
    // set values
    let strAnswer = strAns;
    let funName = '';
    let aryFunValue = [];

    // Check if there is fun symbol
    // @fun(takePhoto)@/fun
    //let intTemp = strAnswer.indexOf('<fun>(');
    let intTemp = strAnswer.indexOf('@fun(');
    if (intTemp != -1) {

        // there is function
        //let intTemp2 = strAnswer.indexOf(')</fun>');
        let intTemp2 = strAnswer.indexOf(')@/fun');
        strAnswer = strAnswer.substring(5, intTemp2);

        // get function name
        let intTemp3 = strAnswer.indexOf(',');
        if (intTemp3 != -1) {
            // Has value

            // firstly, get funName
            funName = strAnswer.substring(0, intTemp3);

            // set answer to a format with all values only
            strAnswer = strAnswer.substring(intTemp3 + 1);

            // loop and get all values
            let bolEnd = false;
            while (bolEnd == false) {
                let intTemp4 = strAnswer.indexOf(',');
                if (intTemp4 != -1) {
                    let strValue = strAnswer.substring(0, intTemp4);
                    aryFunValue.push(strValue);
                    strAnswer = strAnswer.substring(intTemp4+1);
                } else {
                    strAnswer = strAnswer.substring(0);
                    aryFunValue.push(strAnswer);
                    bolEnd = true;
                }
            }

            funUpdateServerMonitor('aiml function detected: ' + funName + ', values: ' + aryFunValue[0], false);
        } else {
            // No value

            // Only have to get funName
            funName = strAnswer;

            funUpdateServerMonitor('aiml function detected: ' + funName + ', values: None', false);
        }

        // go to next function to further check the function
        let aryAIMLFun = [funName, aryFunValue];
        funCheckAIMLFun(idSocket, idUser, aryAIMLFun);
    } else {
        // no functions, return ans
        funAIMLEndRes(idSocket, idUser, strAns);
    }
}



function funCheckAIMLFun(idSocket, idUser, aryValue) {

    let aryTemp = aryValue;
    let strFunName = aryTemp[0];

    //funUpdateServerMonitor("1", true);
    if (strFunName == 'bingImg') {
        // take value out first
        let strSearchImg = aryTemp[1][0];
        funBingImageSearch('aimlRequestImg', strSearchImg, [idSocket, idUser]);
    } else if (strFunName == 'wikiSearch') {
        // take value out first
        let strSearchWiki = aryTemp[1][0];
        funWikiSearch(strSearchWiki, 'aimlRequestWiki', [idSocket, idUser]);
    } else if (strFunName == 'stopTTS') {
        for (let x = 0; x < aryClients.length; x++) {
            if (idUser === aryClients[x].userId && idSocket != aryClients[x].connectionCode) {
                socketAll.to(`${aryClients[x].connectionCode}`).emit('TtsStop');
                funUpdateServerMonitor("Sent TTS stop to pib: " + aryClients[x].userId, false);
                break;
            }
        }
    } else if (strFunName == 'takePhoto') {
        // call pib take photo
        for (let x = 0; x < aryClients.length; x++) {
            if (idUser === aryClients[x].userId && idSocket != aryClients[x].connectionCode) {
                socketAll.to(`${aryClients[x].connectionCode}`).emit('TakePhoto');
                funUpdateServerMonitor("Sent Take Photo to pib: " + aryClients[x].userId, false);
                break;
            }
        }
    } else if (strFunName == 'takePhotoAndClassify') {
        // call pib take photo
        for (let x = 0; x < aryClients.length; x++) {
            if (idUser === aryClients[x].userId && idSocket != aryClients[x].connectionCode) {
                socketAll.to(`${aryClients[x].connectionCode}`).emit('TakePhotoAndClassify');
                funUpdateServerMonitor("Sent Take Photo And Classify to pib: " + aryClients[x].userId, false);
                break;
            }
        }
    } else {
        // it should be impossible, or else error
        funUpdateServerMonitor("AIML Error: function name is not found", false);
    }
}


function funpyAIMLRemoveUser(sock) {
    try {
        // Remove User
        for (let i = 0; i < pyAIML.length; i++) {
            if (pyAIML[i].socketID.name === sock.name) {
                try {
                    pyAIML.splice(i, 1);
                    funUpdateServerMonitor("pyAIML Client Removed: " + sock.name, true);
                    break;
                } catch (err) {
                    //
                }
            }
        }
    } catch (err) {
        funUpdateServerMonitor("funpyAIMLRemoveUser Error: " + err, true);
    }
}



function funpyAIMLSendDataToClient(strUserID, strMsg) {
    try {
        funUpdateServerMonitor("Start Send Data to pyAIML ID: " + strUserID + " Message: " + strMsg, true);
        // Send Data To Client
        for (let i = 0; i < pyAIML.length; i++) {
            if (pyAIML[i].userID === strUserID) {
                pyAIML[i].socketID.write(utf8Encode(strMsg));
                funUpdateServerMonitor("Sent Data to pyAIML ID: " + strUserID + " Message: " + strMsg, true);
            }
        }
    } catch (err) {
        funUpdateServerMonitor("funpyAIMLSendDataToClient Error: " + err, true);
    }
}



function funZFBValueDB(strValue) {
    funUpdateServerMonitor("ZFB Server Get Value: " + strValue, false);
}



function funBingImageSearch(strCaller, strSearch, aryValues) {
    try {
        let strLang = 'en';
        if (stringBytes(strSearch) === strSearch.length) {
            strLang = 'en';
        } else {
            strLang = 'sc';
        }

        let BingRequest_Params = {
            method: 'GET',
            hostname: BingHost,
            path: BingPath + '?q=' + encodeURIComponent(strSearch),
            headers: {
                'Ocp-Apim-Subscription-Key': BingSubscriptionKey
            }
        };

        let BingResponse_Handler = function (BingResponse) {
            let strBingBody = '';
            BingResponse.on('data', function (d) {
                strBingBody += d;
            });

            BingResponse.on('end', function () {
                funUpdateServerMonitor('Got Result from Bing', true);
                //funUpdateServerMonitor("Bing Result: " + strBingBody, true);
                let aryBingBody = JSON.parse(strBingBody);
                //funUpdateServerMonitor(strBingBody, false);
                //funUpdateServerMonitor(aryBingBody, false);
                //funUpdateServerMonitor(aryBingBody.value, false);
                //funUpdateServerMonitor(aryBingBody.value[0], false);

                let intMax = 10;

                let aryBingImgFinal = [];

                try {
                    if (aryBingBody.value.length < intMax) {
                        intMax = aryBingBody.value.length;
                    }
                } catch (err) {
                    funUpdateServerMonitor("Bing Image Search [aryBingBody] Error:" + err, true);
                    let strAnswer = '';
                    if (strLang == 'en') {
                        strAnswer = "I don't have the image of " + strSearch + '.';
                    } else {
                        strAnswer = '我没有' + strSearch + '的图片。';
                    }
                    funAIMLEndRes(aryValues[0], aryValues[1], strAnswer);
                    return;
                }

                

                for (let i = 1; i <= intMax; i++) {
                    try {
                        aryBingImgFinal.push([strSearch, aryBingBody.value[i - 1].thumbnailUrl, aryBingBody.value[i - 1].contentUrl])
                    } catch (err) {
                        funUpdateServerMonitor("Bing Image Add SQL Error: " + err, true);
                    }
                }

                if (strCaller == 'aimlRequestImg') {
                    for (let x = 0; x < aryClients.length; x++) {
                        if (aryValues[1] === aryClients[x].userId && aryClients[x].connectionCode != aryValues[0]) {
                            socketAll.to(`${aryClients[x].connectionCode}`).emit('ShowImage', aryBingImgFinal);
                            funUpdateServerMonitor("Sent Bing Image to pib.", true);
                        }
                    }
                } else {
                   // do nothing
                }
            });
        };

        let BingReq = httpsBing.request(BingRequest_Params, BingResponse_Handler);
        BingReq.end();
        funUpdateServerMonitor("Bing Image Search Start: " + strSearch, true);
    } catch (err) {
       funUpdateServerMonitor("Bing Image Search Error:" + err, true);
    }
}




// Following about wikipedia
function funWikiSearch(strContent, strCaller, aryValues) {

    //https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=Stack%20Overflow

    let strLang = "en";

    if (Buffer.byteLength(strContent) == strContent.length) {
        // en
        strLang = "en";
    } else {
        // default = 'zh'
        strLang = "zh";
    }

    let strAction = 'query';
    let strProp = 'extracts';
    let strTitles = strContent;
    let strFormat = 'json';

    let WikiURL = 'https://' + strLang + '.wikipedia.org/w/api.php?action=' +  strAction + '&titles=' + strTitles + '&format=' + strFormat + '&prop=extracts&exintro&explaintext&redirects=1';
    WikiURL = encodeURI(WikiURL);

    funUpdateServerMonitor('wiki start search, url: ' + WikiURL, false);

    http.get(WikiURL, (resp) => {
        let data = '';

        // A chunk of data has been recieved.
        resp.on('data', (chunk) => {
            data += chunk;
        });

        // The whole response has been received. Print out the result.
        resp.on('end', () => {
            let parsedData = JSON.parse(data);
            //console.log(parsedData);
            //console.log(parsedData.query.pages);
            //console.log(parsedData["query"]["pages"]);
            //console.log(Object.keys(parsedData.query.pages)[0]);
            let extractAns = parsedData["query"]["pages"][Object.keys(parsedData.query.pages)[0]]["extract"];
            //console.log(extractAns);
            try {
                if (strLang == 'zh') {
                    extractAns = extractAns.substring(0,intTTSCHMax);

                    if (extractAns.lastIndexOf("。") != -1) {
                        extractAns = extractAns.substring(0,extractAns.lastIndexOf("。")+1);
                    }
                } else {
                    extractAns = extractAns.substring(0,intTTSCHMax * 2);

                    if (extractAns.lastIndexOf(".") != -1) {
                        extractAns = extractAns.substring(0,extractAns.lastIndexOf(".")+1);
                    }
                }
            } catch (Err) {
                if (strLang == 'en') {
                    extractAns = "I don't have the information of " + strContent;
                } else {
                    extractAns = "我沒有" + strContent + "的资料";
                }
            }


            // do sth
            // Check caller
            if (strCaller == 'aimlRequestWiki') {
                funAIMLEndRes(aryValues[0], aryValues[1], extractAns);
            } else {
                // do nothing
            }
        });
    }).on("error", (err) => {
        funUpdateServerMonitor("Wiki Search Error: " + err.message, false);
    });
}



// Baidu Functions

// Image Classify
function funBaiduAIImageClassify(imgB64, strCaller, aryValues) {
    try {
        clientBaiduImageClassify.advancedGeneral(imgB64).then(function (result) {
            //socket.emit('BaiduAIImageClassifyReturn', result);
            let strResult = result;

            funUpdateServerMonitor("BaiduAIImageClassify Result: " + JSON.stringify(strResult), true);

            strResult = funBaiduAIImageClassifyReturn(strResult);

            // Check caller
            switch (strCaller) {
                case 'pibRequestPhoto':
                    for (let x = 0; x < aryClients.length; x++) {
                        if (aryValues[1] === aryClients[x].userId && aryValues[0] == aryClients[x].connectionCode) {
                            socketAll.to(`${aryClients[x].connectionCode}`).emit('TtsStart', [strResult]);
                            funUpdateServerMonitor("Sent aiml answer to pib: " + strResult, false);
                            break;
                        }
                    }
                    break;
                default:
                    funUpdateServerMonitor("BaiduAIImageClassify Error: Cannot find function caller", true);
            }
        }).catch(function (err) {
            // 如果发生网络错误
            funUpdateServerMonitor("BaiduAIImageClassify Error: " + err, true);
        });
    } catch (err) {
        funUpdateServerMonitor("BaiduAIImageClassify Error:" + err, true);
    }
}



function funBaiduAIImageClassifyReturn(strResult) {
    try {
        // showDebug(json_encode(strResult), 3000);

        // Get Result Num
        let intResult = 0;
        let strTemp = "";
        let i;

        let strAnswer = '我不知道这是什么';

        intResult = strResult.result_num;
        if (intResult !== 0) {
            // Check For Company Logo First
            let bolLogo = false;
            let strLogo = "";
            for (i = 0; i < strResult.result_num; i++) {
                if (strResult.result[i].score > 0.5 && strResult.result[i].root === "Logo") {
                    bolLogo = true;
                    strLogo = strResult.result[i].keyword;
                    break;
                }
            }
            if (bolLogo) {
                strTemp = strLogo;
                if (strTemp.indexOf("三星") >= 0) {
                    strTemp = '三星公司，全球最佳手机生产商';
                } else if (strTemp.indexOf("苹果") >= 0) {
                    strTemp = '苹果公司，全球最贵手机生产商';
                }
                strAnswer = strTemp;
            } else {
                // Probably Not a Company Logo
                if (strResult.result[0].score > 0.3) {
                    strTemp += strResult.result[0].keyword;

                    // Handle Special Situation

                    switch (strTemp) {
                        case "轿车":
                            // For Car
                            if (intResult > 1) {
                                if (strResult.result[1].score > 0.3 && strResult.result[1].keyword.indexOf("货车") >= 0) {
                                    strTemp = '货车';
                                } else {
                                    if (gstrLang === "TC") {
                                        strTemp = '私家车';
                                    }
                                }
                            } else {
                                if (gstrLang === "TC") {
                                    strTemp = '私家车';
                                }
                            }
                            break;
                        case "自行车":
                            // For Bicycle
                            if (gstrLang === "TC") {
                                strTemp = '单车';
                            }
                            break;
                        case "三星标志":
                            strTemp = '三星公司，全球最佳手机生产商';
                            break;
                        case "苹果":
                            let bolAppleLogo = false;
                            for (i = 0; i < strResult.result.length; i++) {
                                if (strResult.result[i].keyword.indexOf("苹果商标") >= 0) {
                                    bolAppleLogo = true;
                                    break;
                                }
                            }
                            if (bolAppleLogo) {
                                strTemp = '苹果公司，全球最贵手机生产商';
                            }
                            break;
                    }
                    strAnswer = '这是' + strTemp;
                } else {
                    strAnswer = '我不知道这是什么';
                }
            }
        } else {
            strAnswer = '我不知道这是什么'
        }

        return strAnswer;
    } catch (err) {
        //
    }
}






// For raspberry clients
var aryRBClients = [];

var socketRB = new ioClient();
socketRB.attach(serverRBClient);

socketRB.on('connection', function (socket) {
    funUpdateServerMonitor("RB Client Connected, Socket ID: " + socket.id, false);
    // socket.emit("UpdateYourSocketID", socket.id);

    // Add Connection to Array with Empty User ID
    aryRBClients.push({ connectionCode: socket.id, rbCode: '', socket: socket});

    socketRB.emit('serverNeedRBCode');

    funUpdateServerMonitor("Server required rbCode, Socket ID: " + socket.id, false);

    socket.on('updateRBCode', function (RBcode) {
        funUpdateServerMonitor("update rb code: " + RBcode, false);
        for (let i = 0; i < aryRBClients.length; i++) {
            if (aryRBClients[i].connectionCode === socket.id) {
                aryRBClients[i].rbCode = RBcode;
                //funUpdateServerMonitor("updated rb code: " + aryRBClients[i].rbCode, false);
                // Test
                //funRBMoveRobot(RBcode, ['S', 1, 1, 1]);
                break;
            }
        }
    });

    socket.on('disconnect', function () {
        funUpdateServerMonitor("Client Disconnected, Socket ID: " + socket.id, false);
        for (let i = 0; i < aryRBClients.length; i++) {
            if (aryRBClients[i].connectionCode === socket.id) {
                aryRBClients.splice(i, 1);
            }
        }
        // socketAll.emit("ServerUpdateUserList", aryClients);
    });

    // Catch any unexpected error, to avoid system hangs
    socket.on('error', function () { });
});


















// Support Functions


function funGenRandomNumber(intLength) {
    let strTemp = "";
    let codeChars = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 0);
    for (let i = 0; i < intLength; i++) {
        let charNum = Math.floor(Math.random() * 10);
        strTemp += codeChars[charNum];
    }
    return strTemp;
}
function funGenRandomString(intLength) {
    let strTemp = "";
    let codeChars = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9,
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'); //所有候选组成验证码的字符，当然也可以用中文的
    for (let i = 0; i < intLength; i++) {
        let charNum = Math.floor(Math.random() * 51);
        strTemp += codeChars[charNum];
    }
    return strTemp;
}


function stringBytes(c) {
    let n = c.length, s;
    let len = 0;
    for (let i = 0; i < n; i++) {
        s = c.charCodeAt(i);
        while (s > 0) {
            len++;
            s = s >> 8;
        }
    }
    return len;
}



// Encode String to UTF-8
function utf8Encode(string) {
    string = string.replace(/\r\n/g, "\n");
    let utftext = "";
    for (let n = 0; n < string.length; n++) {
        let c = string.charCodeAt(n);
        if (c < 128) {
            utftext += String.fromCharCode(c);
        } else if ((c > 127) && (c < 2048)) {
            utftext += String.fromCharCode((c >> 6) | 192);
            utftext += String.fromCharCode((c & 63) | 128);
        } else {
            utftext += String.fromCharCode((c >> 12) | 224);
            utftext += String.fromCharCode(((c >> 6) & 63) | 128);
            utftext += String.fromCharCode((c & 63) | 128);
        }

    }
    return utftext;
}







// Decode String From UTF-8
function utf8Decode(utftext) {
    let string = "";
    let i = 0;
    let c = c1 = c2 = 0;
    while (i < utftext.length) {
        c = utftext.charCodeAt(i);
        if (c < 128) {
            string += String.fromCharCode(c);
            i++;
        } else if ((c > 191) && (c < 224)) {
            c2 = utftext.charCodeAt(i + 1);
            string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
            i += 2;
        } else {
            c2 = utftext.charCodeAt(i + 1);
            c3 = utftext.charCodeAt(i + 2);
            string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
            i += 3;
        }
    }
    return string;
}

function json_decode(str_json) {
    let json = JSON;
    if (typeof json === 'object' && typeof json.parse === 'function') {
        return json.parse(str_json);
    }

    let cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
    let j;
    let text = str_json;

    // Parsing happens in four stages. In the first stage, we replace certain
    // Unicode characters with escape sequences. JavaScript handles many characters
    // incorrectly, either silently deleting them, or treating them as line endings.
    cx.lastIndex = 0;
    if (cx.test(text)) {
        text = text.replace(cx, function (a) {
            return '\\u' +
                ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        });
    }

    // In the second stage, we run the text against regular expressions that look
    // for non-JSON patterns. We are especially concerned with '()' and 'new'
    // because they can cause invocation, and '=' because it can cause mutation.
    // But just to be safe, we want to reject all unexpected forms.

    // We split the second stage into 4 regexp operations in order to work around
    // crippling inefficiencies in IE's and Safari's regexp engines. First we
    // replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
    // replace all simple value tokens with ']' characters. Third, we delete all
    // open brackets that follow a colon or comma or that begin the text. Finally,
    // we look to see that the remaining characters are only whitespace or ']' or
    // ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.
    if (/^[\],:{}\s]*$/.
        test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
            replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
            replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

        // In the third stage we use the eval function to compile the text into a
        // JavaScript structure. The '{' operator is subject to a syntactic ambiguity
        // in JavaScript: it can begin a block or an object literal. We wrap the text
        // in parens to eliminate the ambiguity.

        j = eval('(' + text + ')');

        return j;
    }

    // If the text is not JSON parseable, then a SyntaxError is thrown.
    throw new SyntaxError('json_decode');
}

function json_encode(mixed_val) {
    let json = JSON;
    if (typeof json === 'object' && typeof json.stringify === 'function') {
        return json.stringify(mixed_val);
    }

    let value = mixed_val;

    let quote = function (string) {
        let escapable = /[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
        let meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"': '\\"',
            '\\': '\\\\'
        };

        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                let c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    };

    let str = function (key, holder) {
        let gap = '';
        let indent = '    ';
        let i = 0;          // The loop counter.
        let k = '';          // The member key.
        let v = '';          // The member value.
        let length = 0;
        let mind = gap;
        let partial = [];
        let value = holder[key];

        // If the value has a toJSON method, call it to obtain a replacement value.
        if (value && typeof value === 'object' &&
            typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

        // What happens next depends on the value's type.
        switch (typeof value) {
            case 'string':
                return quote(value);

            case 'number':
                // JSON numbers must be finite. Encode non-finite numbers as null.
                return isFinite(value) ? String(value) : 'null';

            case 'boolean':
            case 'null':
                // If the value is a boolean or null, convert it to a string. Note:
                // typeof null does not produce 'null'. The case is included here in
                // the remote chance that this gets fixed someday.

                return String(value);

            case 'object':
                // If the type is 'object', we might be dealing with an object or an array or
                // null.
                // Due to a specification blunder in ECMAScript, typeof null is 'object',
                // so watch out for that case.
                if (!value) {
                    return 'null';
                }

                // Make an array to hold the partial results of stringifying this object value.
                gap += indent;
                partial = [];

                // Is the value an array?
                if (Object.prototype.toString.apply(value) === '[object Array]') {
                    // The value is an array. Stringify every element. Use null as a placeholder
                    // for non-JSON values.

                    length = value.length;
                    for (i = 0; i < length; i += 1) {
                        partial[i] = str(i, value) || 'null';
                    }

                    // Join all of the elements together, separated with commas, and wrap them in
                    // brackets.
                    v = partial.length === 0 ? '[]' :
                        gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                            mind + ']' :
                            '[' + partial.join(',') + ']';
                    gap = mind;
                    return v;
                }

                // Iterate through all of the keys in the object.
                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }

                // Join all of the member texts together, separated with commas,
                // and wrap them in braces.
                v = partial.length === 0 ? '{}' :
                    gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
                gap = mind;
                return v;
        }
    };

    // Make a fake root object containing our value under the key of ''.
    // Return the result of stringifying the value.
    return str('', {
        '': value
    });
}
