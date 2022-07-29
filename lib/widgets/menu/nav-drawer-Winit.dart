import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hr_app/Damage/DamagePage.dart';
import 'package:flutter_hr_app/InfoPages/infoWinit.dart';
import 'package:flutter_hr_app/Model/Impostazione.dart';
import 'package:flutter_hr_app/Model/Internet.dart';
import 'package:flutter_hr_app/TimbPages/timbratureListWinit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:launch_review/launch_review.dart';

import '../../HomePages/homePageWinit.dart';
import '../../Impostazione/impostazioniPage.dart';
import '../../Prodotti/FormProdotto.dart';
import '../../Prodotti/DisplayProdotto.dart';
import '../../database.dart';
import '../../preferenze.dart';

class NavDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<NavDrawer> {
  Checkinternet objectinternet = Checkinternet();
  bool internet = false;

  checkinternet() async {
    internet = await objectinternet.checkConnectivityState();
    return internet;
  }
  AppUpdateInfo _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        LaunchReview.launch(androidAppId: "it.winit.clockApp",
            iOSAppId: "585027354");
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }
  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 80.0,
            child: DrawerHeader(
                child: Text('Menu',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                decoration: BoxDecoration(color: Colors.blue),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(15.0)),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black),
            title: Text('Impostazioni'),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ImpostazioniPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.download_rounded, color: Colors.black),
            title: Text('Recupera Impostazioni'),
            onTap: () async {
              internet = await checkinternet();
              if (internet == true) {
                wait_alert();
                bool flag = await objectImpostazione.recuperoimpostazioni();
                if (flag == true) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePageWinit()));
                }
              } else {
                _toastError("provarci ancora");
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.black),
            title: Text('Prodotti'),
              onTap: () {
                try{
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          ProductDisplay()));
                }catch(e){
                  print(e);
                }
            },
          ),
          (Preferenze.registrazioni == 1)
              ? ListTile(
                  leading: Icon(Icons.list_alt_rounded, color: Colors.black),
                  title: Text('Registrazioni'),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimbraturePageWinit(1)))
                  },
                )
              : Row(),
          (Preferenze.segnalazioni == 1)
              ? ListTile(
                  leading: Icon(
                    Icons.announcement_rounded,
                    color: Colors.black,
                  ),
                  title: Text('Segnalazioni'),
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Damage()))
                  },
                )
              : Row(),
          ListTile(
            leading: Icon(
              Icons.update,
              color: Colors.black,
            ),
            title: Text('Aggiornamento'),
            onTap: () => {
            checkForUpdate(),
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.black,
            ),
            title: Text('Informazioni'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => InfoWinit()))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.black),
            title: Text('Chiudi'),
            onTap: () => {exit(0)},
          ),
        ],
      ),
      bottomNavigationBar: (Preferenze.logo == "HSM")
          ? Image.asset(
              'assets/Winit/LOGOHSM2.png',
              height: MediaQuery.of(context).size.width * 0.25,
            )
          : Row(),
    ));
  }

  logout() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.resetApp();
  }

  Impostazione objectImpostazione = Impostazione();
  Checkinternet objectInternet = Checkinternet();

  wait_alert() {
    AlertDialog alert = AlertDialog(
        content: Text(
      "Attendere prego..",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey, fontSize: 20),
    ));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _toast(String messaggio) {
    Fluttertoast.showToast(
        msg: messaggio,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _toastError(String messaggio) {
    Fluttertoast.showToast(
        msg: messaggio,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
