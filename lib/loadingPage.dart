import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hr_app/Model/Refresh.dart';
import 'package:flutter_hr_app/database.dart';
import 'package:flutter_nfc_plugin/models/nfc_message.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timer_builder/timer_builder.dart';

import '../Model/Internet.dart';
import '../preferenze.dart';
import '../ws.dart';
import 'HomePages/homePageWinit.dart';

class LoadingPageWinit extends StatefulWidget {
  final bool login;
  LoadingPageWinit(this.login);
  @override
  State<StatefulWidget> createState() => new _State();
}

class Module {
  String name = "";
  String displayName = "";
  String code = "";
  Color color;
  IconData icon;
  int position = 0;
}

class _State extends State<LoadingPageWinit> with WidgetsBindingObserver {
  Checkinternet objectinternet = new Checkinternet();
  bool vdoUpdate = false;
  List<Module> moduleList;
  final dbHelper = DatabaseHelper.instance;
  NfcMessage nfcMessageStartedWith;
  final timbNotImpController = new TextEditingController();
  int uid = 0;
  int cid = 0;
  int eventi = 0;
  int pulsanteTimbra = 0;
  int start = 0;
  bool useFBA = false;
  bool isOn = true;
  bool useNAV = true;
  bool nfcIsOn = false;
  int timbCount = 0;
  int vmode = 0;
  int nfcNotSupported = 0;
  int count = 0;
  int gps = 0;
  int invioAuto = 0;
  int gtimbCount = 0;
  bool isLocationEnabled = true;
  String conc = "";
  String loc = "";
  String string = "";
  Refresh objectRefresh = Refresh();
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat finalformat = DateFormat('HH:mm');
  final DateFormat finalformat2 = DateFormat('dd');
  var connectivityResult;
  RESTApi wsClient = new RESTApi();
  QRViewController controller;
  String val2Write = "";
  double longitude = 0.0;
  double latitude = 0.0;
  bool internet = false;
  bool _loader = true;
  @override
  initState() {
    super.initState();
    zoomLogo();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        setState(() {
          isOn = false;
        });
        initPlatformState();
        break;
      case AppLifecycleState.resumed:
        setState(() {
          isOn = true;
        });
        initPlatformState();
        break;
      case AppLifecycleState.inactive:
        setState(() {
          isOn = false;
        });
        initPlatformState();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  DateTime licenza;
  bool isTapped = false;
  clock() {
    return TimerBuilder.periodic(
      Duration(seconds: 1),
      builder: (context) {
        return Text(
          "${getSystemTime()}",
          style: TextStyle(
              color: Colors.black54, fontSize: 70, fontWeight: FontWeight.w400),
        );
      },
    );
  }
  Timer _incrementCounterTimer;
  int counter = 1;
  zoomLogo() async {
    _incrementCounterTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
          counter++;
          setState(() {
            isTapped = !isTapped;
          });
          if (counter == 6) {
            _incrementCounterTimer.cancel();
          }
        });
  }
  mycontainer() {
    return SafeArea(
        child: Container(
            margin: const EdgeInsets.only(top: 10.0),
            color: Colors.grey[100],
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: clock(),
                    ),
                    Text(
                      "${getSystemDate()}",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                    ),
                    (_loader == true)
                        ? SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 1.5,
                            ))
                        : Row(),

                    Container(
                      margin: EdgeInsets.only(top: 60),
                      width: MediaQuery.of(context).size.width*1.0,
                      child: Center(
                        child: AnimatedContainer(
                          height: isTapped ? 100.0 : 80.0,
                          width: isTapped ? 300.0 : 250.0,
                          duration: Duration(seconds: 2),
                          curve: Curves.fastOutSlowIn,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage('assets/Winit/LogoVettoriale20.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ])));
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "ClockApp 2.0",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: [],
              ),
            ),
            mycontainer(),
          ],
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    await recuperoImpostazioni();
  }

  Future<void> recuperoImpostazioni() async {
    internet = await objectinternet.checkConnectivityState();
    await dbHelper
        .queryAllRows_AUTH_USER()
        .then((users) => {cid = users[0]["CLIENTE_ID"]});
    if (internet == true) {
      await wsClient.GetCustomization(cid).then((value) => {
            if (value != null)
              {
                value.forEach((element) {
                  Preferenze.intervallo = element.intervallo;
                  Preferenze.gps = element.gps;
                  Preferenze.activities = element.activities;
                  Preferenze.raggio = element.raggio;
                  Preferenze.attObl = element.attObl;
                  Preferenze.multiAtt = element.multiAtt;
                  Preferenze.simpleGps = element.simpleGps;
                  Preferenze.registrazioni = element.registrazioni;
                  Preferenze.invioAutomatico = element.invioAutomatico;
                  Preferenze.doppiaTimbratura = element.doppiaTimbratura;
                  Preferenze.intervalloDoppia = element.intervalloDoppia;
                  Preferenze.gps = element.gps;
                  print("Fatto");
                }),
                dbHelper.deleteCustomization(),
                dbHelper.insertCustomization(value),
              }
            else
              {
                print("Else"),
              }
          });
      String createCustomization =
          "CREATE TABLE IF NOT EXISTS personalizzazioni (id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER);";
      Database db = await DatabaseHelper.instance.database;
      await db.execute(createCustomization);
      //if(widget.login) {
      //  String create_customization = "CREATE TABLE IF NOT EXISTS personalizzazioni (id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER);";
      //  Database db = await DatabaseHelper.instance.database;
      //  await db.execute(create_customization);
      //  await db.rawQuery(
      //      "insert into personalizzazioni(scheduledGPS,gps,idCliente,squadra,cantieri,pulsanteTimbra,doppiaTimbratura,IntervalloDoppia, simpleGps, raggio) values('" +
      //          "0','" +
      //          Preferenze.gps.toString().toString() + "','" +
      //          cid.toString() + "','" +
      //          Preferenze.abilSquadra.toString() + "','" +
      //          Preferenze.Cantieri.toString() + "','" +
      //          Preferenze.pulsanteTimbra.toString() + "','" +
      //          Preferenze.doppiaTimbratura.toString() + "','" +
      //          Preferenze.intervalloDoppia.toString() + "','" +
      //          Preferenze.simpleGps.toString() + "','" +
      //          Preferenze.raggio.toString() + "')");
      //  print("Database creato");
      //}
    } else {
      //Preferenze.gps = await objectRefresh.getGPSF();
      //Preferenze.simpleGps = await objectRefresh.getSimpleF();
      //pulsanteTimbra = await objectRefresh.getPulsanteTimbraF();
      //invioAuto = await objectRefresh.getIntervalloF();
      //Preferenze.raggio = await objectRefresh.getRaggioF();
    }
    print(Preferenze.gps);
    print(Preferenze.simpleGps);
    print(Preferenze.raggio);
    Future.delayed(Duration(milliseconds: 4000), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePageWinit()));
    });
  }

  onBackPressed(BuildContext context) {
    exit(0);
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("IN ATTESA...")),
        ],
      ),
    );
  }
}
