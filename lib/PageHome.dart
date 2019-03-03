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

// Import Self Darts
import 'LangStrings.dart';
import 'ScreenVariables.dart';
import 'GlobalVariables.dart';
import 'Utilities.dart';

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
class ClsHome extends StatelessWidget {
  final intState;

  ClsHome(this.intState);

  //@override
  //_ClsHomeState createState() => _ClsHomeState();
//}

//class _ClsHomeState extends State<ClsHome> {
//  SpeechRecognition _speech;
//
//  bool _speechRecognitionAvailable = false;
//  bool _isListening = false;
//
//  String transcription = '';
//
//  //String _currentLocale = 'en_US';
//  Language selectedLang = languages.first;
//
//
//
//  @override
//  initState() {
//    super.initState();
//    activateSpeechRecognizer();
//  }
//
//
//  void activateSpeechRecognizer() {
//    print('_MyAppState.activateSpeechRecognizer... ');
//    _speech = new SpeechRecognition();
//    _speech.setAvailabilityHandler(onSpeechAvailability);
//    _speech.setCurrentLocaleHandler(onCurrentLocale);
//    _speech.setRecognitionStartedHandler(onRecognitionStarted);
//    _speech.setRecognitionResultHandler(onRecognitionResult);
//    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
//    //_speech.setErrorHandler(errorHandler);
//    _speech
//        .activate()
//        .then((res) => setState(() => _speechRecognitionAvailable = res));
//  }

  void funHomeInputAudio() {
    //ut.showToast(listText[listText.length - 1], true);
    //gv.listText.add(gv.listText.length.toString());
    //gv.storeHome.dispatch(Actions.Increment);
    //_speechRecognitionAvailable &&
    if (!gv.sttIsListening) {
      // Start Record
      //gv.bolPressedRecord = false;
      //start();
      gv.sttStart();
    } else if (gv.sttIsListening) {
      // Cancel Record
      //gv.bolPressedRecord = true;
      //stop();
      gv.sttCancel();
    } else {
      // do nothing, it should be impossible
    }
//    if (_speechRecognitionAvailable && !_isListening) {
//      start();
//    }
//    if (_isListening) {
//      stop();
//    }
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
      gv.socket.emit('RBMoveRobot', [ctlRBCode.text, ['F', intLeft, intRight, 0]]);
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

  var ctlRBCode = new TextEditingController();

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
              height: sv.dblBodyHeight / 2,
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
                      gv.dblAlignY =
                          ((dragDetails2.globalPosition.dy - sv.dblTopHeight * 1.5) *
                                      2 -
                                  sv.dblScreenHeight / 2) /
                              sv.dblScreenHeight *
                              2;
                      if (gv.dblAlignY > 1) {
                        gv.dblAlignY = 1;
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
            Container(
              height: sv.dblBodyHeight / 3,
              width: sv.dblScreenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: sv.dblBodyHeight / 6,
                    // width: sv.dblScreenWidth / 2,
                    child: Center(
                      child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: gv.listText.length,
                          itemBuilder: (context, index) {
                            return Text((index + 1).toString() +
                                ': ' +
                                gv.listText[index]);
                          }),
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

  @override
  Widget build(BuildContext context) {
//    if (gv.bolHomeFirstIn) {
//      gv.bolHomeFirstIn = false;
//      //activateSpeechRecognizer();
//      gv.storeHome.dispatch(Actions.Increment);
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
