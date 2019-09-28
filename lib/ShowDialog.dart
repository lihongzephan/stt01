// This program display the Dialog

// Import Flutter Darts
import 'package:flutter/material.dart';
import 'package:stt01/GlobalVariables.dart' as prefix0;

// Import Self Darts
import 'GlobalVariables.dart';
import 'LangStrings.dart';
import 'ScreenVariables.dart';

// Show Dialog Class sd
class sd {
  // The original widget calls the following showAlert method in async mode
  // Which means that, after calling showAlert, the codes after showAlert will be run immediately
  // i.e. Anything showAlert should be done, must be done inside showAlert.
  // In other words, the original widget must be using Redux for State Management.  (CANNOT use setState)
  // inside showDialog, can use either:
  // 1. AlertDialog (To show 1 row of buttons at the bottom)
  // 2. SimpleDialog (To show rows of buttons)
  // See Below examples for AlertDialog (case 'Logout') and SimpleDialog (case 'Logout2')

  // How to Call

  // The following example show how to call 'YesNo'
  // gv.strDialogYN = '';
  // sd.showAlert(context, 'Title','Content','YesNo');

  static void showAlert(BuildContext context, strTitle, strContent, strAction) {
    switch (strAction) {
      case 'YesNo':
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text(strTitle),
                  content: Text(strContent),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(ls.gs('Yes')),
                      onPressed: () {
                        gv.strDialogYN = 'Y';
                        Navigator.of(context).pop();

                        // gv.storeHome.dispatch(Actions.Increment);
                      },
                    ),
                    new FlatButton(
                      child: new Text(ls.gs('No')),
                      onPressed: () {
                        gv.strDialogYN = 'N';
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
        break;
      case 'EditAIMLAnswer':
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text(strTitle),
                content: Row(
                  children: <Widget>[
                    Text(' '),
                    Expanded(
                      child: TextField(
                        controller: gv.ctlEditAIMLAnswer,
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: ls.gs('EditAnswer'),
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                        ),
                      ),
                    ),
                    Text(' '),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text(ls.gs('Confirm')),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Do something here
                        gv.strDialogEditAIMLResult = 'Y';
                        // May be set a value here

                        // May be Navigator.pushAndRemoveUntil to somewhere

                        // May be do nothing, just let the original dart file use future.delay to check the return value
                      }),
                  new FlatButton(
                    child: new Text(ls.gs('Cancel')),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      gv.strDialogEditAIMLResult = 'N';
                    },
                  ),
                ],
              ),
        );
        break;
      case 'Logout':
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text(strTitle),
                  content: Text(strContent),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(ls.gs('Yes')),
                      onPressed: () {
                        Navigator.of(context).pop();
                        gv.gstrCurPage = 'SettingsMain';

                        // Do Logout
                        gv.strLoginID = '';
                        gv.strLoginPW = '';
                        gv.strLoginStatus = '';
                        gv.setString('strLoginID', gv.strLoginID);
                        gv.setString('strLoginPW', gv.strLoginPW);

                        // Call Server to Logout
                        gv.socket.emit('LogoutFromServer', []);

                        // Increment storeSettingsMain to refresh page
                        gv.storeSettingsMain.dispatch(prefix0.Actions.Increment);
                      },
                    ),
                    new FlatButton(
                      child: new Text(ls.gs('No')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
        break;
      case 'Logout2':
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SimpleDialog(
                  title: Center(
                    child: Text(strTitle + ': ' + strContent),
                  ),
                  children: <Widget>[
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.of(context).pop();
                        gv.gstrCurPage = 'SettingsMain';

                        // Do Logout
                        gv.strLoginID = '';
                        gv.strLoginPW = '';
                        gv.strLoginStatus = '';
                        gv.setString('strLoginID', gv.strLoginID);
                        gv.setString('strLoginPW', gv.strLoginPW);

                        // Call Server to Logout
                        gv.socket.emit('LogoutFromServer', []);

                        // Increment storeSettingsMain to refresh page
                        gv.storeSettingsMain.dispatch(prefix0.Actions.Increment);
                      },
                      child: Center(
                        child: Text(
                          ls.gs('Yes'),
                          style: TextStyle(
                              fontSize: sv.dblDefaultFontSize * 1.2,
                              color: Colors.blue),
                        ),
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text(
                          ls.gs('No'),
                          style: TextStyle(
                              fontSize: sv.dblDefaultFontSize * 1.2,
                              color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ));
        break;
      default:
        break;
    }
  }
}
