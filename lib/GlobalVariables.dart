// This program stores ALL global variables required by ALL darts

// Import Flutter Darts
import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threading/threading.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';

// import 'package:flutter_webrtc/webrtc.dart';

// Import Self Darts
import 'LangStrings.dart';
import 'Utilities.dart';
import 'PageHome.dart';
import 'signaling.dart';

// Import Pages

enum Actions {
  Increment
} // The reducer, which takes the previous count and increments it in response to an Increment action.
int reducerRedux(int intSomeInteger, dynamic action) {
  if (action == Actions.Increment) {
    return intSomeInteger + 1;
  }
  return intSomeInteger;
}

enum TtsState { playing, stopped }

enum DialogDemoAction {
  cancel,
  connect,
}

// class for stt
class sttLanguage {
  final String name;
  final String code;

  const sttLanguage(this.name, this.code);
}

class gv {
  // Current Page
  // gstrCurPage stores the Current Page to be loaded
  static var gstrCurPage = 'SelectLanguage';
  static var gstrLastPage = 'SelectLanguage';

  // Init gintBottomIndex
  // i.e. Which Tab is selected in the Bottom Navigator Bar
  static var gintBottomIndex = 1;

  // Declare Language
  // i.e. Language selected by user
  static var gstrLang = '';

  // bolLoading is used by the 'package:modal_progress_hud/modal_progress_hud.dart'
  // Inside a particular page that use Modal_Progress_Hud  :
  // Set it to true to show the 'Loading' Icon
  // Set it to false to hide the 'Loading' Icon
  static bool bolLoading = false;

  // Defaults

  // Allow Duplicate Login?
  // static const bool bolAllowDuplicateLogin = false;

  // Min / Max of Fields
  // User ID from 3 to 20 Bytes
  static const int intDefUserIDMinLen = 3;
  static const int intDefUserIDMaxLen = 20;
  // Password from 6 to 20 Bytes
  static const int intDefUserPWMinLen = 6;
  static const int intDefUserPWMaxLen = 20;
  // Nick Name from 3 to 20 Bytes
  static const int intDefUserNickMinLen = 3;
  static const int intDefUserNickMaxLen = 20;
  static const int intDefEmailMaxLen = 60;
  // Activation Code Length
  static const int intDefActivateLength = 6;

  // Declare STORE here for Redux

  // Store for SettingsMain
  static Store<int> storeMain =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storeHome =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storeSettingsMain =
      new Store<int>(reducerRedux, initialState: 0);
  static Store<int> storePerInfo =
      new Store<int>(reducerRedux, initialState: 0);

  // Declare SharedPreferences && Connectivity
  static var NetworkStatus;
  static SharedPreferences pref;
  static Init() async {
    pref = await SharedPreferences.getInstance();

    // Detect Connectivity
    NetworkStatus = await (Connectivity().checkConnectivity());
    if (NetworkStatus == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      print('Mobile Network');
    } else if (NetworkStatus == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      print('WiFi Network');
    }

    // Init for TTS
    ttsFlutter = FlutterTts();

    if (Platform.isAndroid) {
      ttsFlutter.ttsInitHandler(() {
        ttsGetLanguages();
        ttsGetVoices();
      });
    } else if (Platform.isIOS) {
      ttsGetLanguages();
    }

    // Init for STT
    sttInit();
  }

  // Functions for TTS
  static Future ttsGetLanguages() async {
    ttsLanguages = await ttsFlutter.getLanguages;
    // if (languages != null) setState(() => languages);
  }

  static Future ttsGetVoices() async {
    ttsVoices = await ttsFlutter.getVoices;
    // if (voices != null) setState(() => voices);
  }

  static Future ttsSpeak() async {
    if (ttsNewVoiceText != null) {
      if (ttsNewVoiceText.isNotEmpty) {
        print(jsonEncode(await ttsFlutter.getLanguages));
        print(jsonEncode(await ttsFlutter.getVoices));
        print(await ttsFlutter.isLanguageAvailable("en-US"));
        await ttsFlutter.setLanguage("en-US");
        await ttsFlutter.setVoice("luy");
        await ttsFlutter.setSpeechRate(1.0);
        await ttsFlutter.setVolume(1.0);
        await ttsFlutter.setPitch(1.0);

        //ttsNewVoiceText = 'do you have a brain? Yes, you are so stupid. you are an idiot!';

        var result = await ttsFlutter.speak(ttsNewVoiceText);
        // if (result == 1) setState(() => ttsState = TtsState.playing);
        if (result == 1) {
          ttsState = TtsState.playing;
        }
      }
    }
  }

  static Future ttsStop() async {
    var result = await ttsFlutter.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }

  static getString(strKey) {
    var strResult = '';
    strResult = pref.getString(strKey) ?? '';
    return strResult;
  }

  static setString(strKey, strValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(strKey, strValue);
  }

  // tts vars
  static FlutterTts ttsFlutter;
  static dynamic ttsLanguages;
  static dynamic ttsVoices;
  static String ttsLanguage;
  static String ttsVoice;

  static String ttsNewVoiceText;

  static TtsState ttsState = TtsState.stopped;

  static get ttsIsPlaying => ttsState == TtsState.playing;
  static get ttsIsStopped => ttsState == TtsState.stopped;

  // stt vars
  static const sttLanguages = const [
    const sttLanguage('Chinese', 'zh_CN'),
    const sttLanguage('English', 'en_US'),
    const sttLanguage('Francais', 'fr_FR'),
    const sttLanguage('Pусский', 'ru_RU'),
    const sttLanguage('Italiano', 'it_IT'),
    const sttLanguage('Español', 'es_ES'),
  ];

  static SpeechRecognition sttSpeech;

  static bool sttSpeechRecognitionAvailable = false;
  static bool sttIsListening = false;

  static String sttTranscription = '';

  static String sttRecognisedLang = 'EN';

  // O = 'Original' or T = 'Translate'
  static String sttType = '';

  //String _currentLocale = 'en_US';
  static Language sttSelectedLang = languages.first;

  static void sttInit() {
    try {
      print('_MyAppState.activateSpeechRecognizer... ');
      sttSpeech = new SpeechRecognition();
      sttSpeech.setAvailabilityHandler(sttOnSpeechAvailability);
      sttSpeech.setCurrentLocaleHandler(sttOnCurrentLocale);
      sttSpeech.setRecognitionStartedHandler(sttOnRecognitionStarted);
      sttSpeech.setRecognitionResultHandler(sttOnRecognitionResult);
      sttSpeech.setRecognitionCompleteHandler(sttOnRecognitionComplete);
      sttSpeech.activate().then((res) => sttSpeechRecognitionAvailable = res);
    } catch (err) {
      ut.funDebug('stt Init error: ' + err.toString());
    }
  }

  static void sttStart() {
    try {
      if (!sttSpeechRecognitionAvailable) {
        sttInit();
      }
      sttSpeech.listen(locale: sttSelectedLang.code).then((result) {});
    } catch (err) {
      ut.funDebug('stt Start error: ' + err.toString());
    }
  }

  static void sttCancel() {
    try {
      sttSpeech.cancel().then((result) {
        sttIsListening = false;

        switch(gstrCurPage) {
          case 'Home':
            gv.storeHome.dispatch(Actions.Increment);
            break;
          default:
            break;
        }
      });
    } catch (err) {
      ut.funDebug('stt Cancel error: ' + err.toString());
    }
  }

  static void sttStop() {
    try {
      sttSpeech.stop().then((result) {
        sttIsListening = false;
      });
    } catch (err) {
      ut.funDebug('stt Stop error: ' + err.toString());
    }
  }

  static void sttOnSpeechAvailability(bool result) =>
      sttSpeechRecognitionAvailable = result;

  static void sttOnCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    sttSelectedLang = languages.firstWhere((l) => l.code == locale);
  }

  static void sttOnRecognitionStarted() {
    try {
      sttIsListening = true;

      switch(gstrCurPage) {
        case 'Home':
          gv.storeHome.dispatch(Actions.Increment);
          break;
        default:
          break;
      }
    } catch (err) {
      ut.funDebug('stt OnRecognitionStarted() error: ' + err.toString());
    }
  }

    static void sttOnRecognitionResult(String text) {
      try {
        sttTranscription = text;

        switch(gstrCurPage) {
          case 'Home':
            sttCancel();
            gv.listText.add(sttTranscription);
            ut.funDebug('listText: ' + gv.listText[0]);
            ut.funDebug('length: ' + gv.listText.length.toString());
            gv.storeHome.dispatch(Actions.Increment);
            gv.timHome = DateTime.now().millisecondsSinceEpoch;

            // Check language
            //ut.funDebug("string bytes: " + ut.stringBytes(sttTranscription).toString());
            //ut.funDebug("length: " + sttTranscription.length.toString());
            //ut.funDebug("strLang: " + ls.strLang);
            if (ut.stringBytes(sttTranscription) == sttTranscription.length) {
              // Language is english
              sttRecognisedLang = 'EN';
            } else {
              // Not english, check selected language
              if (ls.strLang == "EN") {
                // default = 'SC'
                sttRecognisedLang = 'SC';
              } else {
                // get selected language in app
                sttRecognisedLang = ls.strLang;
              }
            }

            ut.funDebug("sttRecognisedLang: " + sttRecognisedLang);

            if (gv.sttType == 'O') {
              // Remove all '/' in text, as '+' and '/' are two symbols in all 64 symbols
              String strB64Text = base64.encode(utf8.encode(text));
              strB64Text = strB64Text.replaceAll('/', '_');
              //ut.funDebug('strB64Text: ' + strB64Text);

              gv.dioGet('sttResult', 'http://www.zephan.top:10551/get/' + aimlKey + '/' + sttRecognisedLang + '/' + strB64Text);
            } else {
              ut.funDebug('Sending Voice Input Translate: ' + text);
              gv.socket.emit('SendVoiceInputTranslate', [text]);
              ut.funDebug('Sent Voice Input Translate: ' + text);
            }


            break;
          default:
            break;
        }
      } catch (err) {
        ut.funDebug('stt OnRecognitionResult error: ' + err.toString());
      }
    }

    static void sttOnRecognitionComplete() {
      try {
        sttIsListening = false;
      } catch (err) {
        ut.funDebug('stt OnRecognitionComplete error: ' + err.toString());
      }

    }



    // Web RTC Vars
    static String rtcDisplayName = "STT01";
    static List<dynamic> rtcPeers;
    static var rtcSelfId = '';
    static bool rtcInCalling = false;
    static String rtcServerIP = "www.zephan.top";
    static var rtcPerrId = '';
    static var timGetWRTCId = DateTime.now().millisecondsSinceEpoch;



    // Dio Vars
    static var dio = Dio();
    static var aimlKey = 'DyKsg4WkmA7DxctF';
    static var aimlLearnName = 'LEARN';

    static dioGet(String strCaller, String strUrl) async {
      try {
        Response response = await dio.get(strUrl);
        //print(response.data);
        response.data = response.data.substring(2, response.data.length - 2);

        bool bolEnd = false;
        while (bolEnd == false) {
          bolEnd = true;
          int index = response.data.indexOf('", "');
          if (index != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index);
            String strB = response.data.substring(index+4);
            response.data = strA + "', '" + strB;
          }
          int index2 = response.data.indexOf("', " + '"');
          if (index2 != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index2);
            String strB = response.data.substring(index2+4);
            response.data = strA + "', '" + strB;
          }
          int index3 = response.data.indexOf('",' + " '");
          if (index3 != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index3);
            String strB = response.data.substring(index3+4);
            response.data = strA + "', '" + strB;
          }
        }

        response.data = response.data.split("', '");
        //print(response.data);
        //print(response.data[0]);
        ut.funDebug('Got response from dio: ' + response.data.toString());

        switch (strCaller) {
          case 'sttResult':
            ut.funDebug('aiml return: ' + response.data[4]);
            gv.socket.emit('ClientNeedAIML', [response.data[4], sttRecognisedLang]);
            ut.funDebug('sent text: ' + response.data[4]);

            break;
          case 'learnAIML':
            ut.funDebug('learn aiml return: ' + response.data[0]);
            if (response.data[0] == 'LearnAIML Success') {
              //ut.showToast(ls.gs('LearnAIMLSuccess'));
              List<String> aryDbPublish = ['PublishROBOTGroup', base64.encode(utf8.encode(response.data[1]))];
              ut.funDebug(base64.encode(utf8.encode(response.data[1])));
              dioPost('publishAIML', "http://www.bigaibot.com/php/AjaxDbPublishROBOTGroup.php", aryDbPublish);

            } else {
              ut.showToast(ls.gs('LearnAIMLFailed'));
            }

            break;
          default:
            break;
        }
      } catch (err) {
        ut.funDebug('dioGet Error: ' + err.toString());
      }
    }

  static dioPost(String strCaller, String strUrl, List<String> aryValues) async {
      try {
        //dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
        dio.options.contentType = "application/x-www-form-urlencoded";
        Response response = await dio.post(
            strUrl,
            data: { 'aryAjaxSend': base64.encode(utf8.encode(json.encode(aryValues)))},
            //options: new Options(contentType: ContentType.parse("application/x-www-form-urlencoded"))
            options: new Options(contentType: "application/x-www-form-urlencoded")
        );

        // Decode response

        response.data = response.data.substring(2, response.data.length - 2);

        bool bolEnd = false;
        while (bolEnd == false) {
          bolEnd = true;
          int index = response.data.indexOf('", "');
          if (index != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index);
            String strB = response.data.substring(index+4);
            response.data = strA + "', '" + strB;
          }
          int index2 = response.data.indexOf("', " + '"');
          if (index2 != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index2);
            String strB = response.data.substring(index2+4);
            response.data = strA + "', '" + strB;
          }
          int index3 = response.data.indexOf('",' + " '");
          if (index3 != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index3);
            String strB = response.data.substring(index3+4);
            response.data = strA + "', '" + strB;
          }
          int index4 = response.data.indexOf('","');
          if (index4 != -1) {
            bolEnd = false;
            String strA = response.data.substring(0, index4);
            String strB = response.data.substring(index4+3);
            response.data = strA + "', '" + strB;
          }
        }

        response.data = response.data.split("', '");

        ut.funDebug('dioPost response: ' + response.toString());

        // Response is ready to be used

        switch (strCaller) {
          case 'publishAIML':
            if (response.data[1] == '0000') {
              ut.showToast(ls.gs('LearnAIMLSuccess'));
            } else {
              ut.showToast(ls.gs('LearnAIMLFailed'));
            }
            break;
          default:
            break;
        }
      } catch (err) {
        ut.funDebug('dioPost Error: ' + err.toString());
      }
  }


    // Vars for Show Dialog
    static String strDialogYN = '';
    static String strDialogEditAIMLResult = '';


    // Vars For Pages

    // Var For Activate
    static var strActivateError = '';
    static var aryActivateResult = [];
    static var timActivate = DateTime.now().millisecondsSinceEpoch;

    // Var For Change Password
    static var strChangePWError = '';
    static var aryChangePWResult = [];
    static var timChangePW = DateTime.now().millisecondsSinceEpoch;

    // Var For Forget Password
    static var strForgetPWError = '';
    static var aryForgetPWResult = [];
    static var timForgetPW = DateTime.now().millisecondsSinceEpoch;

    // Var For Home
    static bool bolHomeFirstIn = false;
    static List<String> listText = [];
    static var aryHomeAIMLResult = [];
    static var timHome = DateTime.now().millisecondsSinceEpoch;
    static double dblAlignX = 0;
    static double dblAlignY = 0;
    static var intLastLeft = 0;
    static var intLastRight = 0;
    static var strRBCode = '';
    static bool bolWebRtcShouldInit = true;
    static bool bolCanPressWebRtc = true;
    static bool bolHomeHavePibWebRtcId = false;
    static bool bolLearnAIML = false;
    static final ctlEditAIMLAnswer = TextEditingController();
    static String strAddAIML = '';

    // Var For Login
    static var strLoginID = '';
    static var strLoginPW = '';
    static var strLoginError = '';
    static var aryLoginResult = [];
    static var strLoginStatus = '';
    static var bolFirstTimeCheckLogin = false;
    static var timLogin = DateTime.now().millisecondsSinceEpoch;

    // Var For PersonalInformation
    static var strPerInfoError = ls.gs('ChangeEmailNeedActivateAgain');
    static var aryPerInfoResult = [];
    static var timPerInfo = DateTime.now().millisecondsSinceEpoch;
    static var strPerInfoUsr_NickL = '';
    static var strPerInfoUsr_EmailL = '';
    static var ctlPerInfoUserNick = TextEditingController();
    static var ctlPerInfoUserEmail = TextEditingController();
    static bool bolPerInfoFirstCall = false;

    // Var For Register
    static var strRegisterError = ls.gs('EmailAddressRegisterWarning');
    static var aryRegisterResult = [];
    static var timRegister = DateTime.now().millisecondsSinceEpoch;

    // Var For ShowDialog
    static int intShowDialogIndex = 0;

    // socket.io related
    static const String URI = 'http://thisapp.zephan.top:10531';
    static bool gbolSIOConnected = false;
    static SocketIO socket;
    static int intSocketTimeout = 10000;
    static int intHBInterval = 5000;

    static initSocket() async {
      if (!gbolSIOConnected) {
        socket = await SocketIOManager().createInstance(URI);
      }
      socket.onConnect((data) {
        gbolSIOConnected = true;
        print('onConnect');
        ut.showToast(ls.gs('NetworkConnected'));

        if (!bolFirstTimeCheckLogin) {
          bolFirstTimeCheckLogin = true;
          // Check Login Again if strLoginID != ''
          if (strLoginID != '') {
            timLogin = DateTime.now().millisecondsSinceEpoch;
            socket.emit('LoginToServer', [strLoginID, strLoginPW, false]);
          }
        }
      });
      socket.onConnectError((data) {
        gbolSIOConnected = false;
        print('onConnectError');
      });
      socket.onConnectTimeout((data) {
        gbolSIOConnected = false;
        print('onConnectTimeout');
      });
      socket.onError((data) {
        gbolSIOConnected = false;
        print('onError');
      });
      socket.onDisconnect((data) {
        gbolSIOConnected = false;
        print('onDisconnect');
        ut.showToast(ls.gs('NetworkDisconnected'));
      });

      // Socket Return from socket.io server

      socket.on('ActivateResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timActivate >
            intSocketTimeout) {
          print('Activate result timeout');
          return;
        }
        aryActivateResult = data;
      });

      socket.on('ChangePasswordResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timChangePW >
            intSocketTimeout) {
          print('ChangePasswordResult Timeout');
          return;
        }
        aryChangePWResult = data;
      });

      socket.on('ChangePerInfoResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timPerInfo >
            intSocketTimeout) {
          print('ChangePerInfo Result Timeout');
          return;
        }
        aryPerInfoResult = data;
      });

      socket.on('ForceLogoutByServer', (data) {
        // Force Logout By Server (Duplicate Login)

        // Clear User ID
        strLoginID = '';
        strLoginPW = '';
        strLoginStatus = '';
        setString('strLoginID', strLoginID);
        setString('strLoginPW', strLoginPW);

        // Show Long Toast
        ut.showToast(ls.gs('LoginErrorReLogin'), true);

        // Reset States
        resetStates();
      });

      socket.on('ForgetPasswordResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timForgetPW >
            intSocketTimeout) {
          print('ForgetPasswordResult Timeout');
          return;
        }
        aryForgetPWResult = data;
      });

      socket.on('GetPerInfoResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timPerInfo >
            intSocketTimeout) {
          print('GetPerInfo Result Timeout');
          return;
        }
        aryPerInfoResult = data;

        strPerInfoUsr_NickL = gv.aryPerInfoResult[1][0]['usr_nick'];
        strPerInfoUsr_EmailL = gv.aryPerInfoResult[1][0]['usr_email'];

        bolLoading = false;
        ctlPerInfoUserNick.text = gv.strPerInfoUsr_NickL;
        ctlPerInfoUserEmail.text = gv.strPerInfoUsr_EmailL;
      });

      socket.on('LoginResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timLogin > intSocketTimeout) {
          print('login result timeout');
          return;
        }

        // Get User Status
        if (data[2].length != 0) {
          strLoginStatus = data[2][0]['usr_status'];
          print('strLoginStatus: ' + strLoginStatus);
        }

        if (data[1] != true) {
          // Not the First Time Login, but a Re-Login
          // Change SettingsMain Login/Logout State
          ut.funDebug('LoginResult: ' + data[0]);
          if (data[0] == '0000') {
            // Re-Login Successful
            // Nothing Changed
            if (strLoginStatus == 'A' && gstrCurPage == 'SettingsMain') {
              storeSettingsMain.dispatch(Actions.Increment);
            }
          } else {
            // Re-Login Failed
            strLoginID = '';
            strLoginPW = '';
            strLoginStatus = '';
            setString('strLoginID', strLoginID);
            setString('strLoginPW', strLoginPW);
            if (gstrCurPage == 'SettingsMain') {
              storeSettingsMain.dispatch(Actions.Increment);
            }
            // Display Toast Message

          }
        } else {
          // First Time Login, return aryLoginResult
          aryLoginResult = data;
        }
      });

      socket.on('RegisterResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timRegister >
            intSocketTimeout) {
          print('Register result timeout');
          return;
        }
        aryRegisterResult = data;
      });

      socket.on('SendEmailAgainResult', (data) {
        // Check if the result comes back too late
        if (DateTime.now().millisecondsSinceEpoch - timActivate >
            intSocketTimeout) {
          print('Send Email Again Timeout');
          return;
        }
        aryActivateResult = data;
      });

      socket.on('SocketSendAIMLToClient', (data) {
        // Check if the result comes back too late
        //ttsNewVoiceText = 'do you have a brain? Yes, you are so stupid. you are an idiot!';

        print('Got result from server');
        if (DateTime.now().millisecondsSinceEpoch - timHome > intSocketTimeout) {
          print('Home Receive AIML Timeout');
          return;
        }
        aryHomeAIMLResult = data;
        print('Got result from server: ' + aryHomeAIMLResult[0]);
        ut.showToast('Answer: ' + aryHomeAIMLResult[0], true);

        //ttsNewVoiceText = 'zephan, naomi, bigaibot';
        ttsNewVoiceText = aryHomeAIMLResult[0];
        ttsSpeak();
      });


      socket.on('ServerSendPibWenRtcToStt', (data) {
        switch (gstrCurPage) {
          case 'Home':
            rtcPerrId = data[0];
            ut.funDebug('Got pib web rtc id from server: ' + rtcPerrId);
            break;
          default:
            break;
        }

        socket.on('HBReturn', (data) async {
          timLastHbReceive = DateTime.now().millisecondsSinceEpoch;
        });
      });



      // Connect Socket
      socket.connect();

      // Create a thread to send HeartBeat
      var threadHB = new Thread(funTimerHeartBeat);
      threadHB.start();
    } // End of initSocket()


    static int intHBFinalTimeout = 30000;
    static int timLastHbReceive = DateTime.now().millisecondsSinceEpoch;

    // HeartBeat Timer
    static void funTimerHeartBeat() async {
      while (true) {
        await Thread.sleep(intHBInterval);
        if (socket != null) {
          // print('Sending HB...' + DateTime.now().toString());
          socket.emit('HB', [strLoginID, rtcSelfId, gstrLang]);
        }

        if (DateTime.now().millisecondsSinceEpoch - timLastHbReceive > intHBFinalTimeout) {
          gbolSIOConnected = false;
          socket.connect();
        }
      }
    } // End of funTimerHeartBeat()

    // Reset All variables
    static void resetVars() {
      // Reset Vars for Activate
      strActivateError = ls.gs('ActivationCodeWarning');

      // Reset Vars for Login
      strLoginError = '';

      // Reset Vars for Register
      strRegisterError = ls.gs('EmailAddressRegisterWarning');

      // Reset Vars for Per Info
      strPerInfoError = ls.gs('ChangeEmailNeedActivateAgain');

      // Reset Vars for Change Password
      strChangePWError = '';

      // Reset Vars for Forget Password
      strForgetPWError = '';
    }

    // Reset All states
    static void resetStates() {
      switch (gstrCurPage) {
        case 'PersonalInformation':
          storeSettingsMain.dispatch(Actions.Increment);
          break;
        case 'SettingsMain':
          storeSettingsMain.dispatch(Actions.Increment);
          break;
        default:
          break;
      }
    }
  }
// End of class gv
