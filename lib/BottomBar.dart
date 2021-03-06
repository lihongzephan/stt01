// This program contains the Class for the Bottom Navigator Bar

// Import Flutter Darts
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

// Import Self Darts
import 'GlobalVariables.dart';
import 'LangStrings.dart';
import 'Utilities.dart';

// Import Pages
import 'PageHome.dart';
import 'PageSettingsMain.dart';

// Class Bottom
class ClsBottom extends StatefulWidget {
  @override
  _ClsBottomState createState() => _ClsBottomState();
}

class _ClsBottomState extends State<ClsBottom> {
  @override
  initState() {
    super.initState();
    // Add listeners to this class, if any
  }

  void _onItemTapped(int index) {
    try {
      ut.funDebug('Bottom Item Tapped');

      if (gv.gstrLang != '' && gv.bolLoading == false) {
        gv.gintBottomIndex = index;
        switch (index) {
          case 0:
            gv.bolHomeFirstIn = true;

            // Page Home Clicked
            gv.gstrLastPage = gv.gstrCurPage;
            gv.gstrCurPage = 'Home';

            // Goto Home
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                  builder: (context) => StoreProvider(
                    store: gv.storeHome,
                    child: StoreConnector<int, int>(
                      builder: (BuildContext context, int intTemp) {
                        return ClsHomeBase(intTemp);
                      },
                      converter: (Store<int> sintTemp) {
                        return sintTemp.state;
                      },
                    ),
                  )),
                  (_) => false,
            );

            break;
          case 1:
            if (gv.rtcInCalling) {
              ut.showToast(ls.gs('InCallCannotChangePage'));
              gv.gstrCurPage = 'Home';
              return;
            }

            ut.funDebug('Change Page to Settings Main');

            // Page Settings Clicked
            gv.gstrLastPage = gv.gstrCurPage;
            gv.gstrCurPage = 'SettingsMain';

            // Goto SettingsMain
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                  builder: (context) => StoreProvider(
                    store: gv.storeSettingsMain,
                    child: StoreConnector<int, int>(
                      builder: (BuildContext context, int intTemp) {
                        return ClsSettingsMain(intTemp);
                      },
                      converter: (Store<int> sintTemp) {
                        return sintTemp.state;
                      },
                    ),
                  )),
                  (_) => false,
            );
            break;
          default:
            break;
        }
      }
    } catch(err) {
      ut.showToast('BottomBar Error: ' + err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.home), title: Text(ls.gs('Home'))),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), title: Text(ls.gs('Settings'))),
      ],
      currentIndex: gv.gintBottomIndex,
      fixedColor: Colors.deepPurple,
      onTap: _onItemTapped,
    );
  }
}
