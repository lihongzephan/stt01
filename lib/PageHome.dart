// This program display the Home Page

// Import Flutter Darts
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_webrtc/webrtc.dart';

// Import Self Darts
import 'LangStrings.dart';
import 'ScreenVariables.dart';
import 'GlobalVariables.dart';
import 'Utilities.dart';
import 'signaling.dart';

// Import Pages
import 'BottomBar.dart';

// Class for stt
const languages = const [
  const Language('Chinese', 'zh_CN'),
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

enum TtsState { playing, stopped }

// Home Page
class ClsHomeBase extends StatelessWidget {
  final intState;

  ClsHomeBase(this.intState);

  @override
  Widget build(BuildContext context) {
    return ClsHome();
  }
}


class ClsHome extends StatefulWidget {
  @override
  _ClsHomeState createState() => _ClsHomeState();
}

class _ClsHomeState extends State<ClsHome> {

//  int intCountState = 0;



  // Vars
  var ctlRBCode = new TextEditingController();

  Signaling _signaling;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();



  @override
  initState() {
    super.initState();
//    intCountState += 1;
    if (gv.bolWebRtcShouldInit) {
      initRenderers();
      _connect();
      Future.delayed(Duration(milliseconds:  1000), () {
        funWebRTCBtnPressed();
      });
    } else {
      Future.delayed(Duration(milliseconds:  1000), () {
        funHomeInputAudio();
      });
    }
  }



  @override
  deactivate() {
    super.deactivate();

    funDisposeWebRTC();
  }

  void funDisposeWebRTC() {
    try {
      if (_signaling != null) _signaling.close();
    } catch (Err) {
      print("_signaling.close() Error:" + Err.toString());
    }
    try {
      _localRenderer.dispose();
    } catch (Err) {
      print("_localRenderer.dispose() Error:" + Err.toString());
    }
    try {
      _remoteRenderer.dispose();
    } catch (Err) {
      print("_remoteRenderer.dispose() Error:" + Err.toString());
    }
  }



  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = new Signaling(gv.rtcServerIP, gv.rtcDisplayName)
        ..connect();

      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              gv.rtcInCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              gv.rtcInCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          gv.rtcSelfId = event['self'];
          gv.rtcPeers = event['peers'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
        this.setState(() {
        });
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
        this.setState(() {
        });
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
        this.setState(() {
        });
      });
    }
  }

  _invitePeer(context, peerId, use_screen) async {
    if (_signaling != null && peerId != gv.rtcSelfId) {
      _signaling.invite(peerId, 'video', use_screen);
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }



  void funHomeInputAudio() {
    if (gv.bolWebRtcShouldInit) {
      gv.bolWebRtcShouldInit = false;
      _hangUp();
      gv.storeMain.dispatch(Actions.Increment);
      funHomeInputAudio();
    } else {
      if (!gv.sttIsListening) {
        // Start Record
        gv.sttStart();
      } else {
        // Cancel Record
        gv.sttCancel();
      }
    }
  }



  void funWebRTCBtnPressed() {
    try {
      if (gv.bolWebRtcShouldInit) {
        if (gv.rtcInCalling) {
          _hangUp();
        } else {
          var i = 0;
          for (i = 0; i < gv.rtcPeers.length; i++) {
            if (gv.rtcPeers[i]['id'] != gv.rtcSelfId) {
              _invitePeer(context, gv.rtcPeers[i]['id'], false);
            }
          }
        }
      } else {
        gv.bolWebRtcShouldInit = true;
        gv.sttCancel();
        gv.storeMain.dispatch(Actions.Increment);
        funWebRTCBtnPressed();
      }
    } catch (Err) {
      //
    }
  }



  void funCheckJoyStick() {
    int x = (gv.dblAlignX * 10).toInt();
    int y = (gv.dblAlignY * 10).toInt();

    int intLeft = 0;
    int intRight = 0;

    // Checking
    if (x > 0) {
      if (y >= x) {
        intLeft = -1;
        intRight = -1;
      } else if (y <= -x) {
        intLeft = 1;
        intRight = 1;
      } else {
        intLeft = 1;
        intRight = -1;
      }
    } else if (x == 0) {
      if (y > 0) {
        intLeft = -1;
        intRight = -1;
      } else if (y == 0) {
        intLeft = 0;
        intRight = 0;
      } else {
        intLeft = 1;
        intRight = 1;
      }
    } else {
      if (y >= -x) {
        intLeft = -1;
        intRight = -1;
      } else if (y <= x) {
        intLeft = 1;
        intRight = 1;
      } else {
        intLeft = -1;
        intRight = 1;
      }
    }
    //print(intLeft.toString() + ' , ' + intRight.toString());
    // Socket emit
    if (intLeft != gv.intLastLeft || intRight != gv.intLastRight) {
      gv.socket.emit('RBMoveRobot', [
        ctlRBCode.text,
        ['F', intLeft, intRight, 0]
      ]);
      gv.intLastLeft = intLeft;
      gv.intLastRight = intRight;
    }
  }



  Widget RecordButton() {
    var text = 'Record';
    var color = Colors.greenAccent;
    if (gv.sttIsListening) {
      text = 'Cancel';
      color = Colors.redAccent;
    } else {
      text = 'Record';
      color = Colors.greenAccent;
    }
    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funHomeInputAudio(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }



  Widget STTBody() {
    if (gv.listText.length != 0) {
      return Text(gv.listText.length.toString() +
          ': ' +
          gv.listText[gv.listText.length - 1]);
    } else {
      return Text("Nothing Yet");
    }
  }



  Widget WebRTCActivateButton() {
    var text = '✓';
    var color = Colors.greenAccent;
    if (gv.rtcInCalling) {
      text = '✓';
      color = Colors.greenAccent;
    } else {
      text = 'X';
      color = Colors.redAccent;
    }
    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funWebRTCBtnPressed(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }



  Widget Body() {
    ctlRBCode.text = gv.strRBCode;
    return Container(
      // height: sv.dblBodyHeight,
      width: sv.dblScreenWidth,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: sv.dblScreenWidth,
                height: sv.dblBodyHeight / 3,
                child: new RTCVideoView(_remoteRenderer)
            ),
            Text(' '),
            Container(
              width: sv.dblScreenWidth,
              child: Center(
                child: SizedBox(
                  height: sv.dblDefaultFontSize * 2.5,
                  width: sv.dblDefaultFontSize * 2.5,
                  child: WebRTCActivateButton(),
                ),
              ),
            ),
            Container(
              height: sv.dblBodyHeight / 3,
              width: sv.dblScreenWidth,
              child: Align(
                alignment: Alignment(gv.dblAlignX, gv.dblAlignY),
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (dragDetails1) {
                      // print('Start: ' + dragDetails1.toString());
                    },
                    onPanUpdate: (dragDetails2) {
                      // print('Update: ' + dragDetails2.toString());
                      gv.dblAlignX = (dragDetails2.globalPosition.dx * 2 -
                              sv.dblScreenWidth) /
                          sv.dblScreenWidth;
                      //gv.dblAlignY = ((dragDetails2.globalPosition.dy - sv.dblTopHeight * 1.5) * 2 - sv.dblScreenHeight / 2) / sv.dblScreenHeight * 2;
                      gv.dblAlignY = ((dragDetails2.globalPosition.dy - sv.dblBodyHeight / 3 * 2 + sv.dblDefaultFontSize * 3) / (sv.dblBodyHeight / 3) - 0.5) * 2;
                      //print(gv.dblAlignY);
                      if (gv.dblAlignY > 1) {
                        gv.dblAlignY = 1;
                      }
                      if (gv.dblAlignY < -1) {
                        gv.dblAlignY = -1;
                      }
                      gv.storeHome.dispatch(Actions.Increment);
                      funCheckJoyStick();
                    },
                    onPanEnd: (dragDetails1) {
                      gv.dblAlignX = 0;
                      gv.dblAlignY = 0;
                      gv.storeHome.dispatch(Actions.Increment);
                      gv.socket.emit('RBMoveRobot', [
                        ctlRBCode.text,
                        ['F', 0, 0, 0]
                      ]);
                      gv.intLastLeft = 0;
                      gv.intLastRight = 0;
                    },
                    child: Container(
                      height: sv.dblScreenWidth / 5,
                      width: sv.dblScreenWidth / 5,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(sv.dblScreenWidth / 10),
                        color: Colors.lightBlue,
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 8.0,
                        ),
                      ),
                    )),
              ),
            ),
            Row(
              children: <Widget>[
                Text(ut.Space(sv.gintSpaceTextField)),
                Expanded(
                  child: TextField(
                    controller: ctlRBCode,
                    onChanged: (text) => gv.strRBCode = ctlRBCode.text,
                    onTap: () {
                      ctlRBCode.text = '';
                      gv.strRBCode = ctlRBCode.text;
                    },
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'RB Code',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),
                Text(ut.Space(sv.gintSpaceTextField)),
              ],
            ),
            Text(' '),
            Container(
              width: sv.dblScreenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    // width: sv.dblScreenWidth / 2,
                    child: Center(
                      child: STTBody(),
//                      child: ListView.builder(
//                          shrinkWrap: true,
//                          reverse: true,
//                          itemCount: gv.listText.length,
//                          itemBuilder: (context, index) {
//                            return Text((index + 1).toString() +
//                                ': ' +
//                                gv.listText[index]);
//                          }),
                    ),
                  ),
                  Text(' '),
                  Container(
                    // height: sv.dblBodyHeight / 4,
                    // width: sv.dblScreenWidth / 4,
                    child: Center(
                      child: SizedBox(
                        height: sv.dblDefaultFontSize * 2.5,
                        width: sv.dblScreenWidth / 3,
                        child: RecordButton(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



//  void funInitFirstTime() {
//    // WebRTC
//    if (gv.rtcSelfId == '') {
//      initRenderers();
//      _connect();
//    }
//  }



  @override
  Widget build(BuildContext context) {

//    if (intCountState == 1) {
//      intCountState += 1;
//      funInitFirstTime();
//    }

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          title: Text(
            ls.gs('Home'),
            style: TextStyle(fontSize: sv.dblDefaultFontSize),
          ),
        ),
        preferredSize: new Size.fromHeight(sv.dblTopHeight),
      ),
      body: Body(),
      bottomNavigationBar: ClsBottom(),
    );
  }
}
