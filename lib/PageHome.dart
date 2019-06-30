// This program display the Home Page

// Import Flutter Darts
//import 'dart:convert';
import 'dart:async';
import 'dart:convert';

//import 'dart:io';
import 'package:flutter/material.dart';

// import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/services.dart';

// import 'package:simple_permissions/simple_permissions.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:threading/threading.dart';

import 'flutter_incall_manager.dart';
import 'incall.dart';

// Import Self Darts
import 'LangStrings.dart';
import 'ScreenVariables.dart';
import 'GlobalVariables.dart';
import 'Utilities.dart';
import 'signaling.dart';
import 'ShowDialog.dart';

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

  AppLifecycleState _lastLifecycleState;

  // Web Rtc
  Signaling _signaling;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  // flutter incall manager
  //IncallManager incall = new IncallManager();

  @override
  initState() {
    super.initState();
//    intCountState += 1;
    if (gv.bolWebRtcShouldInit) {
      initRenderers();
      _connect();
    }

    //incall.checkRecordPermission();
    //incall.requestRecordPermission();
    //incall.start({'media': 'audio', 'auto': true, 'ringback': ''});
    //incall.setForceSpeakerphoneOn(true);
  }

  @override
  deactivate() {
    super.deactivate();

    funDisposeWebRTC();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
    ut.funDebug('*****   Life Cycle State: ' +
        _lastLifecycleState.toString() +
        '   *****');
    if (_lastLifecycleState.toString() == 'AppLifecycleState.paused') {
      try {
        if (gv.rtcInCalling) {
          _hangUp();
          setState(() {});
          ut.funDebug('WebRTC hang up in didChange paused');
        }
      } catch (err) {
        ut.funDebug('Video Pause Error in didChange paused: ' + err.toString());
      }
    } else if (_lastLifecycleState.toString() == 'AppLifecycleState.resumed') {
      try {
        if (gv.rtcInCalling) {
          funWebRTCBtnPressed();
          ut.funDebug('WebRTC Invite in didChange resumed');
        }
        setState(() {});
        ut.funDebug('After setState in didChange resumed');
      } catch (err) {
        ut.funDebug(
            'Video Pause Error in didChange resumed: ' + err.toString());
      }
    }
  }

  void funDisposeWebRTC() {
    try {
      if (_signaling != null) _signaling.close();
      ut.funDebug('_signaling Closed!');
    } catch (Err) {
      print("_signaling.close() Error:" + Err.toString());
    }
    try {
      _localRenderer.dispose();
      ut.funDebug('_localRenderer disposed!');
    } catch (Err) {
      print("_localRenderer.dispose() Error:" + Err.toString());
    }
    try {
      _remoteRenderer.dispose();
      ut.funDebug('_remoteRenderer disposed!');
    } catch (Err) {
      print("_remoteRenderer.dispose() Error:" + Err.toString());
    }

    gv.bolWebRtcShouldInit = true;

    ut.funDebug('funDisposeWebRTC Done');
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connect() async {
    try {
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
          this.setState(() {});
        });

        _signaling.onAddRemoteStream = ((stream) {
          _remoteRenderer.srcObject = stream;
          this.setState(() {});
        });

        _signaling.onRemoveRemoteStream = ((stream) {
          _remoteRenderer.srcObject = null;
          this.setState(() {});
        });

        ut.funDebug('Done connect web rtc');
      }
    } catch (err) {
      ut.funDebug('web rtc connect error: ' + err.toString());
    }
  }

  _invitePeer(context, peerId, use_screen) async {
    try {
      if (_signaling != null && peerId != gv.rtcSelfId) {
        ut.funDebug('web rtc invite peer');
        _signaling.invite(peerId, 'video', use_screen);
      }
    } catch (err) {
      ut.funDebug('web rtc invite peer error: ' + err.toString());
    }
  }

  _hangUp() {
    try {
      if (_signaling != null) {
        ut.funDebug('web rtc hang up');
        _signaling.bye();
      }
    } catch (err) {
      ut.funDebug('web rtc hangUp error: ' + err.toString());
    }
  }

//  _switchCamera() {
//    _signaling.switchCamera();
//  }

  void funAddAIMLAns() {
    ut.funDebug('Add Ans Button pressed');

    gv.strDialogEditAIMLResult = '';

    sd.showAlert(context, 'Edit AIML', '', 'EditAIMLAnswer');

    new Future.delayed(new Duration(milliseconds: 100), () async {
      while (gv.strDialogEditAIMLResult == "") {
        await Thread.sleep(100);

        if (gv.strDialogEditAIMLResult == "Y") {
          gv.strAddAIML = gv.ctlEditAIMLAnswer.text;
          gv.ctlEditAIMLAnswer.text = '';

          ut.funDebug('User Want to Add AIML: ' + gv.strAddAIML);

          // Start learn aiml

          String strLang = '';
          if (ut.stringBytes(gv.strAddAIML) == gv.strAddAIML.length) {
            strLang = 'EN';
          } else {
            strLang = gv.gstrLang;
          }

          bool bolContinue = true;

          if (gv.listText.isNotEmpty) {
            bolContinue = true;
          } else {
            bolContinue = false;
            ut.showToast(ls.gs('CannotLearnAIML'));
          }

          if (bolContinue) {
            if (gv.strAddAIML != '') {
              // http://www.zephan.top:10551/learnAIML/<key>/<agrName>/<aimlLang>/<aimlPattern>/<aimlTemplate>
              // http://www.zephan.top:10551/learnAIML/DyKsg4WkmA7DxctF/LEARN/EN/SEk=/SEk=
              String strB64Pattern = base64.encode(utf8.encode(gv.listText[gv.listText.length - 1])).replaceAll('/', '_');
              String strB64Template = base64.encode(utf8.encode(gv.strAddAIML)).replaceAll('/', '_');

              gv.dioGet(
                  'learnAIML',
                  'http://www.zephan.top:10551/learnAIML/' +
                      gv.aimlKey +
                      '/' +
                      gv.aimlLearnName +
                      '/' +
                      strLang +
                      '/' +
                      strB64Pattern +
                      '/' +
                      strB64Template);
            } else {
              ut.showToast(ls.gs('CannotLearnAIML'));
            }
          }

          //ut.funDebug('LearnAIML strLang: ' + strLang);
          //ut.funDebug('LearnAIML aimlKey: ' + gv.aimlKey);
          //ut.funDebug('LearnAIML groupName: ' + gv.aimlLearnName);
          //ut.funDebug('LearnAIML pattern: ' + base64.encode(utf8.encode(gv.listText[gv.listText.length - 1])));
          //ut.funDebug('LearnAIML answer: ' + base64.encode(utf8.encode(gv.strAddAIML)));

        } else {
          // Do nothing
        }
      }
    });
  }

  void funHomeInputAudio() async {
    try {
      //ut.funDebug('Should Init Web rtc: ' + gv.bolWebRtcShouldInit.toString());
      if (gv.bolWebRtcShouldInit) {
        gv.bolWebRtcShouldInit = false;
        _hangUp();
        gv.storeHome.dispatch(Actions.Increment);
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
    } catch (err) {
      ut.funDebug('home audio input error: ' + err.toString());
    }
  }

  void funWebRTCBtnPressed() {
    try {
      if (gv.bolWebRtcShouldInit) {
        if (gv.bolCanPressWebRtc) {
          gv.bolCanPressWebRtc = false;

          if (gv.rtcInCalling) {
            _hangUp();
          } else {
            gv.rtcPerrId = '';

            gv.socket.emit('SttRequestPibWebRtc', [gv.strLoginID]);

            // Start Login Time in ms
            gv.timGetWRTCId = DateTime.now().millisecondsSinceEpoch;

            gv.bolHomeHavePibWebRtcId = false;

            new Future.delayed(new Duration(milliseconds: 100), () async {
              while (gv.bolHomeHavePibWebRtcId == false) {
                await Thread.sleep(100);
                // Use string to check if it is array
                if (gv.rtcPerrId == '') {
                  // this means the server not yet return any value
                  if (DateTime.now().millisecondsSinceEpoch - gv.timGetWRTCId >
                      4000) {
                    // Assume Get Id Fail after ? seconds
                    ut.showToast(ls.gs('ErrCantGetPibId'));
                    gv.bolHomeHavePibWebRtcId = true;
                  } else {
                    // Not Yet Timeout, so Continue Loading
                  }
                } else {
                  // this means that server has returned some values
                  gv.bolHomeHavePibWebRtcId = true;
                  _invitePeer(context, gv.rtcPerrId, false);
                }
              }
            });
          }

          Future.delayed(Duration(milliseconds: 5000), () {
            gv.bolCanPressWebRtc = true;
          });
        }
      } else {
        gv.bolWebRtcShouldInit = true;
        gv.sttCancel();
        gv.storeHome.dispatch(Actions.Increment);
        funWebRTCBtnPressed();
      }
    } catch (err) {
      ut.funDebug('web rtc btn pressed error: ' + err.toString());
      //ut.showToast('web rtc btn pressed error: ' + err.toString());
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
      //ut.funDebug('Send move rb to server, id: ' + gv.strLoginID);
      gv.socket.emit('RBMoveRobot', [
        gv.strLoginID,
        ['F', intLeft, intRight, 0]
      ]);
      gv.intLastLeft = intLeft;
      gv.intLastRight = intRight;
    }
  }

  Widget AddAnsButton() {
    var text = ls.gs('EditAnswer');
    var color = Colors.blueAccent;
    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funAddAIMLAns(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }

  Widget RecordButton() {
    var text = ls.gs('Record');
    var color = Colors.greenAccent;
    if (gv.sttIsListening) {
      text = ls.gs('Cancel');
      color = Colors.redAccent;
    } else {
      text = ls.gs('Record');
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
      return Text(
          gv.listText.length.toString() +
              ': ' +
              gv.listText[gv.listText.length - 1],
          style: TextStyle(fontSize: sv.dblDefaultFontSize * 1.5));
    } else {
      return Text(ls.gs('PressBtnToTalk'),
          style: TextStyle(fontSize: sv.dblDefaultFontSize * 1.5));
    }
  }

  Widget Body() {
    ut.funDebug('Get UserID: ' + gv.getString('strLoginID'));
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            width: sv.dblScreenWidth,
            height: sv.dblBodyHeight / 3.5,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TabDownDetails) {
                funWebRTCBtnPressed();
              },
              child: Container(
                //color: Colors.black,
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.black),
                ),
                child: (gv.rtcInCalling)
                    ? new RTCVideoView(_remoteRenderer)
                    : Center(
                        child: Text(
                          ls.gs('EnableVideo'),
                          style:
                              TextStyle(fontSize: sv.dblDefaultFontSize * 1.5),
                        ),
                      ),
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
                  gv.dblAlignX =
                      (dragDetails2.globalPosition.dx * 2 - sv.dblScreenWidth) /
                          sv.dblScreenWidth;
                  //gv.dblAlignY = ((dragDetails2.globalPosition.dy - sv.dblTopHeight * 1.5) * 2 - sv.dblScreenHeight / 2) / sv.dblScreenHeight * 2;
                  // 自己container的height - 上面所有widget的height， 再除以自己Container的height，最后减0.5再乘以2
                  gv.dblAlignY = ((dragDetails2.globalPosition.dy -
                                  sv.dblBodyHeight / 3.5 -
                                  sv.dblTopHeight) /
                              (sv.dblBodyHeight / 3) -
                          0.5) *
                      2;
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
                    gv.strLoginID,
                    ['F', 0, 0, 0]
                  ]);
                  gv.intLastLeft = 0;
                  gv.intLastRight = 0;
                },
                child: Container(
                  height: sv.dblScreenWidth / 5,
                  width: sv.dblScreenWidth / 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sv.dblScreenWidth / 10),
                    color: Colors.lightBlue,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 8.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
//          Row(
//            children: <Widget>[
//              Text(ut.Space(sv.gintSpaceTextField)),
//              Expanded(
//                child: TextField(
//                  controller: ctlRBCode,
//                  onChanged: (text) => gv.strRBCode = ctlRBCode.text,
//                  onTap: () {
//                    ctlRBCode.text = '';
//                    gv.strRBCode = ctlRBCode.text;
//                  },
//                  keyboardType: TextInputType.text,
//                  autofocus: false,
//                  decoration: InputDecoration(
//                    hintText: 'RB Code',
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//                    border: OutlineInputBorder(
//                        borderRadius: BorderRadius.circular(32.0)),
//                  ),
//                ),
//              ),
//              Text(ut.Space(sv.gintSpaceTextField)),
//            ],
//          ),
//          Text(' '),

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
                Text(' '),
                Container(
                  // height: sv.dblBodyHeight / 4,
                  // width: sv.dblScreenWidth / 4,
                  child: Center(
                    child: SizedBox(
                      height: sv.dblDefaultFontSize * 2.5,
                      width: sv.dblScreenWidth / 3,
                      child: AddAnsButton(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void funInitFirstTime() {
    // WebRTC
    if (gv.rtcSelfId == '') {
      initRenderers();
      _connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      //    if (intCountState == 1) {
      //      intCountState += 1;
      //      funInitFirstTime();
      //    }

      return Scaffold(
        resizeToAvoidBottomPadding: true,
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
    } catch (err) {
      ut.funDebug('home wigdet build error: ' + err.toString());
      return Container();
    }
  }
}
