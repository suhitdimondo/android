import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/AcqGpsPages/AcqGpsWinit.dart';
import 'package:flutter_hr_app/AcqNfcPages/AcqNFCWinit.dart';
import 'package:flutter_hr_app/AcqQrCodePages/AcqQrCodeWinit.dart';
import 'package:flutter_hr_app/Model/Refresh.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/database.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_nfc_plugin/models/nfc_event.dart';
import 'package:flutter_nfc_plugin/models/nfc_message.dart';
import 'package:flutter_nfc_plugin/models/nfc_state.dart';
import 'package:flutter_nfc_plugin/nfc_plugin.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcode/qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';

import '../Cantiere/CantiereWinit.dart';
import '../Model/Internet.dart';
import '../position.dart';
import '../preferenze.dart';
import '../ws.dart';

class HomePageWinit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class Module {
  bool enabled = false;
  String name = "";
  String displayName = "";
  String code = "";
  Color color;
  IconData icon;
  int position = 0;
}

class _State extends State<HomePageWinit> with WidgetsBindingObserver {
  Checkinternet objectinternet = new Checkinternet();
  String txtinternet = "";
  QRCaptureController _captureController = QRCaptureController();
  bool vdoUpdate = false;
  List<Module> moduleList;
  final dbHelper = DatabaseHelper.instance;
  NfcMessage nfcMessageStartedWith;
  static String time = "";
  static String date = "";
  final timbNotImpController = new TextEditingController();
  int uid = 0;
  int cid = 0;
  int eventi = 0;
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
  int _selectedIndex = 0;
  String val2Write = "";
  int getactivities = 0;
  int getcantiere = 0;
  int getgps = 0;
  int getsquadra = 0;
  int getscheduledgps = 0;
  int getcliente = 0;
  int getsegnalazione = 0;
  int getpausapranzo = 0;
  double longitude = 0.0;
  double latitude = 0.0;
  bool _loader = false;
  bool check_location = false;
  Timer _incrementCounterTimer;
  int counter = 1;
  StreamSubscription _connectivitySubscription;
  ConnectivityResult _connectivityResult;
  bool internet = false;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    _nfcstatus();
    timerCheckGPSNfc();
    setStart();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print('Current connectivity status: $result');
      _connectivityResult = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
  }

  timerCheckGPSNfc() async {
    _incrementCounterTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
      counter++;
      if (counter == 2) {
        await check_nfc_gps();
        _incrementCounterTimer.cancel();
      }
    });
  }

  check_nfc_gps() async {
    NfcPlugin nfcPlugin = NfcPlugin();
    NfcState _nfcState = await nfcPlugin.nfcState;
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    if (nfcIsOn == true) {}
    if (isLocationEnabled == true) {}
    if (nfcIsOn == false) {}
    if (isLocationEnabled == false) {}
  }

  mylocation() async {
    try {
      Location location = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      _locationData = await location.getLocation();
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
    } catch (e) {
      erroreInMappa();
    }
  }

  checkinternet() async {
    internet = await objectinternet.checkConnectivityState();
    if (internet == true) {
      return true;
    } else {
      return false;
    }
  }

  showAlertDialog() {
    AlertDialog alert = AlertDialog(
        content: Text(
      "Disattiva",
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

  _nfcstatus() async {
    NfcPlugin nfcPlugin = NfcPlugin();
    try {
      NfcState _nfcState = await nfcPlugin.nfcState;
      if (_nfcState == NfcState.enabled) {
        return nfcIsOn = true;
      } else if (_nfcState == NfcState.notSupported) return nfcNotSupported = 1;
      return nfcIsOn = false;
    } on PlatformException {}
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
  sendAllDataNotImported() {
    RESTApi wsClient = new RESTApi();
    dbHelper.queryAllRows_AUTH_USER().then((users) {
      uid = users[0]["USER_ID"];
      cid = users[0]["CLIENTE_ID"];
      wsClient.GetLicenza(cid).then((value) => licenza = value);
      dbHelper
          .queryAllRows_TIMBOfDayNotImported()
          .then((timbs) => setState(() {
                if (timbs != null) {
                  for (var timb in timbs) {
                    try {
                      String rb = "";
                      String valore = timb["VALORE_ACQUISIZIONE"].toString();
                      String tecnologia =
                          timb["TECNOLOGIA_ACQUISIZIONE"].toString();
                      String tipo = timb["TIPO_ACQUISIZIONE"].toString();
                      String giornata =
                          timb["DATETIME"].toString().substring(0, 10);
                      wsClient
                          .sendData(giornata, uid.toString(), cid.toString(),
                              valore, tipo, tecnologia)
                          .then((val) => setState(() {
                                rb = val;
                                if (rb != 'Error') {
                                  Map<String, dynamic> ti =
                                      new Map<String, dynamic>();
                                  ti["ID"] = int.parse(timb["ID"].toString());
                                  ti["IMPORTED"] = 1;
                                  dbHelper
                                      .update_TIMB(ti)
                                      .then((val) => setState(() {
                                            timbNotImpController.text = "";
                                          }))
                                      .catchError((e) {});
                                } else {}
                              }))
                          .catchError((e) {});
                    } on Exception catch (_) {}
                  }
                }
              }))
          .catchError((e) {});
    });
  }

  timbcount() async {
    try {
      await dbHelper.queryRowCount_TIMB().then((value) => setState(() {
            timbCount = value;
          }));
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      SharedPreferences preferences = await _prefs;
      Object lastVisitDate = preferences.get("mDateKey");
      Future<SharedPreferences> _prefs2 = SharedPreferences.getInstance();
      SharedPreferences gtimb = await _prefs2;
      gtimbCount = int.parse(gtimb.get("counter").toString());
      String toDayDate = DateTime.now().day.toString();
      if (toDayDate == lastVisitDate) {
        if (Preferenze.nuovo == 0) {
          Preferenze.save = timbCount;
          Preferenze.nuovo++;
        } else {
          if (timbCount != Preferenze.save) {
            gtimbCount++;
          } else {
            gtimbCount = gtimbCount;
          }
          Preferenze.save = timbCount;
        }
        gtimb.setInt('counter', gtimbCount);
      } else {
        gtimbCount = 0;
        gtimb.setInt('counter', gtimbCount);
        preferences.setString("mDateKey", toDayDate);
        Preferenze.nuovo++;
      }
    } catch (e) {}
  }

  recuperosegnalazioni() async {
    final dbHelper = DatabaseHelper.instance;
    int cid = 0;
    await dbHelper
        .queryAllRows_AUTH_USER()
        .then((users) => {cid = users[0]["CLIENTE_ID"]});
    RESTApi wsClient = new RESTApi();
    wsClient.GetSegnalazioni(cid).then((value) => {
          if (value != null)
            {
              dbHelper.deleteDataDamage(),
              dbHelper.insertDataDamage(value),
            }
        });
    Preferenze.segnalazioniCount = 1;
  }

  gpsPeriodico(verso) {
    FlutterLogs.logInfo("GPS", "Metodo", "Entro nel metodo GPS ");
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "U";
    timb["LATITUDE"] = -1;
    timb["LONGITUDE"] = -1;
    timb["IMPORTED"] = 0;
    PositionRecord positionManager = new PositionRecord();
    if (isLocationEnabled == true) {
      positionManager.getStoredPosition().then((p) => setState(() {
            if (p != null) {
              timb["LATITUDE"] = p.latitude;
              timb["LONGITUDE"] = p.longitude;
              timb["TIPO_ACQUISIZIONE"] = vmode;
              timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
              timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                {
                  "longitudine": timb["LONGITUDE"],
                  "latitudine": timb["LATITUDE"],
                  "datetime": timb["DATETIME"],
                  "verso": timb["VERSO"],
                  "squadra": Preferenze.Squadra
                }
              ]);
              dbHelper.insert_TIMB(timb).then((val) => setState(() {
                    Preferenze.Squadra = 0;
                    sendAllDataNotImported();
                    thereAreTimbNotImported();
                  }));
            }
          }));
    }
  }

  getUser() {
    dbHelper.queryAllRows_AUTH_USER().then((users) =>
        {this.uid = users[0]["USER_ID"], this.cid = users[0]["CLIENTE_ID"]});
  }

  regNFC() {
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = -1;
    timb["LONGITUDE"] = -1;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "NFC";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "nfccode": "WINIT01047",
        "datetime": tsformatter.format(tin),
        "verso": "",
        "motivazione": "U",
        "squadra": Preferenze.Squadra
      }
    ]);
    dbHelper.insert_TIMB(timb).then((val) => null);
    Preferenze.Squadra = 0;
  }

  void thereAreTimbNotImported() {
    dbHelper
        .queryAllRows_CountTIMBOfDayNotImported()
        .then((timbs) => setState(() {
              int ntimb = 0;
              if (timbs != null) {
                for (var timb in timbs) {
                  try {
                    ntimb = int.parse(timb["ct"].toString());
                    if (ntimb > 0) {
                      timbNotImpController.text = "$ntimb";
                    } else {
                      timbNotImpController.text = "";
                    }
                  } on Exception catch (_) {}
                }
              }
            }))
        .catchError((e) {});
  }

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

  Widget footer() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_remote),
          label: 'NFC',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gps_fixed),
          label: 'GPS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_rounded),
          label: 'QRCODE',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.taxi_alert),
          label: 'CANTIERI',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }

  _onItemTapped(int index) async {
    _selectedIndex = index;
    if (_selectedIndex == 0) {
      time = getSystemTime();
      date = getSystemDate();
      var position = await Geolocator().getCurrentPosition();
      var longitude = position.longitude.toString();
      var latitude = position.latitude.toString();
      FlutterNfcReader.read(instruction: "It's reading").then((value) {
        String val2Write = value.id.toString();
        if (val2Write.trim().length == 0) {
          val2Write = value.content;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AcquisizioneNfcWinit(
                      nfc: nfcMessageStartedWith.payload.first,
                      date: date,
                      time: time,
                      selectedItems: [],
                      long: double.parse(longitude),
                      lat: double.parse(latitude),
                      internet: internet)));
        }
      });
      _toast("NFC");
    }
    if (_selectedIndex == 1) {
      date = getSystemDate();
      time = getSystemTime();
      try {
        isLocationEnabled = await Geolocator().isLocationServiceEnabled();
        internet = await checkinternet();
        if (isLocationEnabled == true) {
          try {
            await _getCurrentLocation();
          } catch (e) {
            showAlertDialog();
          }
        } else {
          showAlertDialog();
        }
      } catch (e) {
        _toastError("GPS non disponibile");
      }
      _toast("GPS");
    }
    if (_selectedIndex == 2) {
      internet = await checkinternet();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AcquisizioneQrCodeWinit(
                    nfc: "",
                    mode: 0,
                    selectedItems: [],
                    internet: internet,
                  )));
      _toast("QRCODE");
    }
    if (_selectedIndex == 3) {
      setState(() {
        _loader = true;
      });
      isLocationEnabled = await Geolocator().isLocationServiceEnabled();
      internet = await checkinternet();
      if (internet == true) {
        getcantiere = int.parse(await objectRefresh.getCantiereT());
      } else {
        getcantiere = await objectRefresh.getCantiereF();
      }
      if (getcantiere == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Cantieri(fissa: '', internet: internet)),
        );
      } else {
        showAlertDialog();
        setState(() {
          _loader = false;
        });
      }
      _toast("CANTIERI");
    }
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
                    Divider(
                      height: 10,
                      color: Colors.white,
                    ),
                    Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                    Divider(
                      height: 15,
                      color: Colors.white,
                    ),
                    (nfcIsOn == true && isLocationEnabled == true)
                        ? Container(
                            width: 350,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade700,
                                border: Border.all(
                                    color: Colors.black, // set border color
                                    width: 1.0), // set border width
                                borderRadius: BorderRadius.all(Radius.circular(
                                    10.0)), // set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.black54,
                                      offset: Offset(1, 3))
                                ] // make rounded corner of border
                                ),
                            child: Text(
                              "Dispositivo avviato correttamente",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Row(),
                    (isLocationEnabled == false)
                        ? Container(
                            width: 350,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.amber.shade800,
                                border: Border.all(
                                    color: Colors.black, // set border color
                                    width: 1.0), // set border width
                                borderRadius: BorderRadius.all(Radius.circular(
                                    10.0)), // set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.black54,
                                      offset: Offset(1, 3))
                                ] // make rounded corner of border
                                ),
                            child: Text(
                              "GPS non attivo nel telefono",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Row(),
                    (nfcIsOn == false)
                        ? Container(
                            width: 350,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.amber.shade800,
                                border: Border.all(
                                    color: Colors.black, // set border color
                                    width: 1.0), // set border width
                                borderRadius: BorderRadius.all(Radius.circular(
                                    10.0)), // set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.black54,
                                      offset: Offset(1, 3))
                                ] // make rounded corner of border
                                ),
                            child: Text(
                              "NFC non supportato dal dispositivo",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Row(),
                    Divider(
                      height: 20,
                      color: Colors.white,
                    ),
                    Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                    Divider(
                      height: 10,
                      color: Colors.white,
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                        height: Common.SpaceHeight,
                        child: Row(children: [
                          Text(
                            'Timbrature Salvate:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '$timbCount',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        ])),
                    Container(
                      margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                      height: Common.SpaceHeight,
                      child: Row(
                        children: [
                          Text(
                            'Timbrature Giornaliere:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '$gtimbCount',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    (timbNotImpController.text != "")
                        ? Container(
                            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                            height: Common.SpaceHeight,
                            child: Row(
                              children: [
                                Text(
                                  'Registrazioni da inviare:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "${timbNotImpController.text}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(),
                    Divider(
                      height: 10,
                      color: Colors.white,
                    ),
                    Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                    Divider(
                      height: 10,
                      color: Colors.white,
                    ),
                    (timbNotImpController.text != "")
                        ? Container(
                            margin: EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(color: Colors.blue)),
                              color: Colors.blue,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              onPressed: () async {
                                internet = await checkinternet();
                                if (internet == true) {
                                  getscheduledgps = int.parse(
                                      await objectRefresh.getScheduledGPST());
                                } else {
                                  getscheduledgps =
                                      await objectRefresh.getScheduledGPSF();
                                }
                                if (getscheduledgps == 0) {
                                  sendAllDataNotImported();
                                } else {
                                  showAlertDialog();
                                }
                              },
                              child: Text(
                                "INVIA REGISTRAZIONI".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 25.0,
                                ),
                              ),
                            ),
                          )
                        : Row(),
                    (timbNotImpController.text == "")
                        ? Divider(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.05,
                          )
                        : Row(),
                    (timbNotImpController.text != "")
                        ? Divider(
                            thickness: 0,
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.02,
                          )
                        : Row(),
                    if (Preferenze.logo == "HSM")
                      Container(
                        width: 250,
                        child: Image.asset('assets/Winit/LogoVettoriale20.png'),
                      )
                    else
                      Container(
                        width: 200,
                        child: Image.asset('assets/Winit/LogoVettoriale20.png'),
                      ),
                    (_loader == true)
                        ? Divider(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.07,
                          )
                        : Row(),
                    (_loader == true)
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 1.5,
                            ))
                        : Row(),
                  ],
                ),
              ),
            ])));
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          "ClockApp 2.0",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  _nfcstatus();
                  initPlatformState();
                  checkinternet();
                  timerCheckGPSNfc();
                },
                child: Icon(
                  Icons.replay_outlined,
                  size: 26.0,
                ),
              )),
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
      bottomNavigationBar: footer(),
    );
  }

  _getCurrentLocation() async {
    try {
      await mylocation();
      time = getSystemTime();
      date = getSystemDate();
      var position = await Geolocator().getCurrentPosition();
      final coordinates =
          new Coordinates(position.latitude, position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      loc = addresses[0].thoroughfare + "," + addresses[0].featureName;
      conc = addresses[0].locality +
          "," +
          addresses[0].postalCode +
          "," +
          addresses[0].countryName;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Acquisizionegpswinit(
                  date: date,
                  time: time,
                  long: longitude.toDouble(),
                  lat: latitude.toDouble(),
                  loc: loc,
                  conc: conc,
                  internet: false)));
    } catch (e) {
      erroreInMappa();
    }
  }

  setStart() {
    if (start == 0) {
      setState(() {
        start = 1;
        initPlatformState();
      });
    } else {
      setState(() {
        start = 0;
        initPlatformState();
      });
    }
  }

  erroreInMappa() {
    AlertDialog alert = AlertDialog(
        content: Text(
      "Problem Trovare Località..",
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

  _toastError(String messaggio) {
    Fluttertoast.showToast(
        msg: messaggio,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  recuperoSegnalazioni() async {
    final dbHelper = DatabaseHelper.instance;
    int cid;
    await dbHelper
        .queryAllRows_AUTH_USER()
        .then((users) => {cid = users[0]["CLIENTE_ID"]});
    RESTApi wsClient = new RESTApi();
    internet = await checkinternet();
    if (internet == true) {
      wsClient.GetSegnalazioni(cid).then((value) => {
            if (value != null)
              {
                dbHelper.deleteDataDamage(),
                dbHelper.insertDataDamage(value),
              }
          });
      Preferenze.segnalazioniCount = 1;
    } else {}
  }

  StreamSubscription<NfcEvent> nfcmesagesubscription;
  initPlatformState() async {
    NfcState _nfcState = NfcState.disabled;
    var position = await Geolocator().getCurrentPosition();
    var longitude = position.longitude.toString();
    var latitude = position.latitude.toString();
    await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.ERROR,
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: ["device", "network", "errors"],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "MyLogs",
        logsExportDirectoryName: "MyLogs/Exported",
        debugFileOperations: true,
        isDebuggable: true);
    NfcPlugin nfcPlugin = NfcPlugin();
    FlutterLogs.logInfo("Prova", "Prova", "Inizio dell'app");
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    wsClient.GetCustomization(16).then((value) => {
          if (value != null)
            {
              value.forEach((element) {
                Preferenze.scheduledGPS = element.scheduledGPS;
                Preferenze.intervallo = element.intervallo;
                Preferenze.gps = element.gps;
                Preferenze.inOutPref = element.inOutPref;
                Preferenze.activities = element.activities;
                Preferenze.segnalazioni = element.segnalazioni;
                Preferenze.attObl = element.attObl;
                Preferenze.multiAtt = element.multiAtt;
                Preferenze.simpleGps = element.simpleGps;
                Preferenze.raggio = element.raggio;
                Preferenze.nomeSocieta = element.nomeSocieta;
                Preferenze.logo = element.logo;
                Preferenze.registrazioni = element.registrazioni;
                Preferenze.invioAutomatico = element.invioAutomatico;
                Preferenze.doppiaTimbratura = element.doppiaTimbratura;
                Preferenze.intervalloDoppia = element.intervalloDoppia;
                Preferenze.pausaPranzo = element.pausaPranzo;
                Preferenze.pulsanteTimbra = element.pulsanteTimbra;
                Preferenze.Squadra = element.squadra;
                Preferenze.ClienteId = element.idCliente;
                Preferenze.Cantieri = element.cantieri;
              }),
              dbHelper.insertCustomization(value),
            }
        });
    Preferenze.eventi = 1;
    if (start != 0 && eventi != 0) {
      thereAreTimbNotImported();
    }
    if (Preferenze.invioAutomatico == 1) {
      sendAllDataNotImported();
    }
    if (Preferenze.eventi == 0 && Preferenze.segnalazioniCount == 0) {
      recuperoSegnalazioni();
    }
    eventi++;
    try {
      _nfcState = await nfcPlugin.nfcState;
      final NfcEvent _nfcEventStartedWith = await nfcPlugin.nfcStartedWith;
      print('NFC event started with is ${_nfcEventStartedWith.toString()}');
      if (_nfcEventStartedWith != null) {
        nfcMessageStartedWith = _nfcEventStartedWith.message;
        time = getSystemTime();
        date = getSystemDate();
        List color = await dbHelper.attivita_select();
        for (int i = 0; i < color.length; i++) {
          String flag = color[i]["flag"].toString();
          if (flag == "true") {
            sendcolor = 1;
            break;
          }
        }
        internet = await checkinternet();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AcquisizioneNfcWinit(
                    nfc: nfcMessageStartedWith.payload.first,
                    date: date,
                    time: time,
                    selectedItems: [],
                    long: double.parse(longitude),
                    lat: double.parse(latitude),
                    internet: internet,
                    color: sendcolor)));
      }
    } on PlatformException {}
    if (!mounted) return;
    if (_nfcState == NfcState.enabled) {
      nfcmesagesubscription =
          nfcPlugin.onNfcMessage.listen((NfcEvent event) async {
        if (event.error.isNotEmpty) {
          setState(() {});
        } else {
          nfcMessageStartedWith = event.message;

          time = getSystemTime();
          date = getSystemDate();
          List color = await dbHelper.attivita_select();
          for (int i = 0; i < color.length; i++) {
            String flag = color[i]["flag"].toString();
            if (flag == "true") {
              sendcolor = 1;
              break;
            }
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AcquisizioneNfcWinit(
                      nfc: nfcMessageStartedWith.payload.first,
                      date: date,
                      time: time,
                      selectedItems: [],
                      long: double.parse(longitude),
                      lat: double.parse(latitude),
                      internet: internet,
                      color: sendcolor)));
        }
      });
    }
  }

  int sendcolor;
}
