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
    if ( !gv.sttIsListening) {
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
          borderRadius: new BorderRadius.circular(
              sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funHomeInputAudio(),
      child: Text(
          text,
          style: TextStyle(
              fontSize:
              sv.dblDefaultFontSize * 1)),
     );
  }

  Widget Body() {
    return Container(
        height: sv.dblBodyHeight,
        width: sv.dblScreenWidth,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(' '),
                Text(' '),
                Container(
                  height: sv.dblBodyHeight / 2,
                  width: sv.dblScreenWidth / 2,
                  child: Center(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: gv.listText.length,
                        itemBuilder: (context, index) {
                          return Text((index + 1).toString() + ': ' + gv.listText[index]);
                        }),
                  ),
                ),
                Text(' '),
                Text(' '),
                Container(
                  height: sv.dblBodyHeight / 4,
                  width: sv.dblScreenWidth / 4,
                  child: Center(
                    child: SizedBox(
                      height: sv.dblDefaultFontSize * 2.5,
                      child: RecordButton(),
                    ),
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
//          actions: [
//            new PopupMenuButton<Language>(
//              onSelected: _selectLangHandler,
//              itemBuilder: (BuildContext context) => _buildLanguagesWidgets,
//            )
//          ],
        ),
        preferredSize: new Size.fromHeight(sv.dblTopHeight),
      ),
//      body: new Padding(
//          padding: new EdgeInsets.all(8.0),
//          child: new Center(
//            child: new Column(
//              mainAxisSize: MainAxisSize.min,
//              crossAxisAlignment: CrossAxisAlignment.stretch,
//              children: [
//                new Expanded(
//                    child: new Container(
//                        padding: const EdgeInsets.all(8.0),
//                        color: Colors.grey.shade200,
//                        child: new Text(transcription))),
//                _buildButton(
//                  onPressed: _speechRecognitionAvailable && !_isListening
//                      ? () => start()
//                      : null,
//                  label: _isListening
//                      ? 'Listening...'
//                      : 'Listen (${selectedLang.code})',
//                ),
//                _buildButton(
//                  onPressed: _isListening ? () => cancel() : null,
//                  label: 'Cancel',
//                ),
//                _buildButton(
//                  onPressed: _isListening ? () => stop() : null,
//                  label: 'Stop',
//                ),
//              ],
//            ),
//          ),
//      ),
      body: Body(),
      bottomNavigationBar: ClsBottom(),
    );
  }


//  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
//      .map((l) => new CheckedPopupMenuItem<Language>(
//    value: l,
//    checked: selectedLang == l,
//    child: new Text(l.name),
//  ))
//      .toList();
//
//  void _selectLangHandler(Language lang) {
//    setState(() => selectedLang = lang);
//  }
//
//  Widget _buildButton({String label, VoidCallback onPressed}) => new Padding(
//      padding: new EdgeInsets.all(12.0),
//      child: new RaisedButton(
//        color: Colors.cyan.shade600,
//        onPressed: onPressed,
//        child: new Text(
//          label,
//          style: const TextStyle(color: Colors.white),
//        ),
//      ));
//
//  void start() => _speech
//      .listen(locale: selectedLang.code)
//      .then((result) => print('_MyAppState.start => result $result'));
//
//  void cancel() =>
//      _speech.cancel().then((result) => setState(() => _isListening = false));
//
//  void stop() => _speech.stop().then((result) {
//    setState(() => _isListening = false);
//  });
//
//  void onSpeechAvailability(bool result) =>
//      setState(() => _speechRecognitionAvailable = result);
//
//  void onCurrentLocale(String locale) {
//    print('_MyAppState.onCurrentLocale... $locale');
//    setState(
//            () => selectedLang = languages.firstWhere((l) => l.code == locale));
//  }
//
//  void onRecognitionStarted() => setState(() => _isListening = true);
//
//  void onRecognitionResult(String text) {
//    setState(() {
//      transcription = text;
//      gv.timHome = DateTime.now().millisecondsSinceEpoch;
//      print('sent text: ' + text);
//      gv.socket.emit('ClientNeedAIML', [text]);
//    });
//  }
//
//  void onRecognitionComplete() => setState(() => _isListening = false);
//
//  void errorHandler() => activateSpeechRecognizer();
}
