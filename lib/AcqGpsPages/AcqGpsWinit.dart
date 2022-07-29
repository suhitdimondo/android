import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/Squadra/SquadraPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';

import '../Model/Refresh.dart';
import '../Prodotti/FormProdotto.dart';
import '../Prodotti/DisplayProdotto.dart';
import '../common.dart';
import '../database.dart';
import '../preferenze.dart';
import '../widgets/menu/nav-drawer-Winit.dart';
import '../ws.dart';

String name1 = "";
String name2 = "";
String name3 = "";
String attivita = "";
String att = "";
String att2 = "";
String att3 = "";
int ripetizioni = Preferenze.rip;

class Acquisizionegpswinit extends StatefulWidget {
  final String date;
  final String time;
  double long;
  double lat;
  final String loc;
  final String conc;
  final bool internet;

  Acquisizionegpswinit(
      {this.date,
      this.time,
      this.long,
      this.lat,
      this.loc,
      this.conc,
      this.internet});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Acquisizionegpswinit> {
  final AudioCache _audioCache = AudioCache();
  int vmode = 0;
  String vname = "";
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  String val2Write = "";
  int cantieridb = 0;
  int squadradb = 0;
  int gpsdb = 0;
  int scheduledGPSdb = 0;
  int activities = 0;
  int segnalazioni = 0;
  int pausaPranzo = 0;
  int getcantiere = 0;
  int getgps = 0;
  int getscheduledgps = 0;
  int getcliente = 0;
  int getsquadra = 0;
  int getsegnalazione = 0;
  int getpausapranzo = 0;
  int getactivities = 0;
  bool internet = false;
  double longitude = 0.0;
  double latitude = 0.0;
  Refresh objectRefresh = Refresh();
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  Container loadEvent = new Container();
  Container confirm = new Container();
  String string = "";

  @override
  void initState() {
    super.initState();
    typeTimb();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final Shader linearGradient = LinearGradient(
    colors: GradientColors.skyLine,
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          "GPS",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => onBackPressed(context),
        ),
      ),
      body: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15, 92, 15, 3),
                child: Row(children: [
                  Text(
                    "Data registrazione:",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  Spacer(),
                  Text(
                    "${widget.date}",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 3, 15, 8),
                child: Row(children: [
                  Text(
                    "Ora registrazione:",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  Spacer(),
                  Text(
                    "${widget.time}",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(150, 8, 0, 8),
                height: Common.SpaceHeight,
                child: Row(children: [
                  Text(
                    "Località:",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  Container(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.wifi_protected_setup,
                              color: Colors.black, size: 25),
                          onPressed: () async {
                            await mylocation();
                            await widgetgpsmapppa();
                          },
                          padding: EdgeInsets.only(bottom: 8),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
              Divider(height: 5, thickness: 10, color: Colors.grey[200]),
              Container(
                //margin: EdgeInsets.fromLTRB(60, 3, 60, 8),
                alignment: Alignment.center,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "${widget.loc}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ]),
                padding: EdgeInsets.all(5.0),
              ),
              Divider(height: 5, thickness: 10, color: Colors.grey[200]),
              Container(
                //margin: EdgeInsets.fromLTRB(15, 3, 120, 8),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "${widget.conc}",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ]),
                padding: EdgeInsets.all(5.0),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                child: widgetgpsmapppa(),
              ),
              loadEvent
            ],
          ),
        ),
      ]),
    );
  }

  typeTimb() {
    if (Preferenze.pulsanteTimbra == 0) {
      button(true);
    } else {
      button(false);
    }
  }

  Widget button(bool button) {
    if (button == true) {
      loadEvent = gpsContainerEU();
    } else {
      loadEvent = gpsContainerTimbra();
    }
    return loadEvent;
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

  gpsContainerEU() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
            height: 40.0,
            width: 300.0,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () => eseguiTimbratura(),
              child: Text(
                "ENTRATA".toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: GradientColors.skyLine,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            height: 40.0,
            width: 300.0,
            //color: Colors.red,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () => eseguiTimbratura(),
              child: Text(
                "USCITA".toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: GradientColors.skyLine,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            width: 300.0,
            height: 40.0,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FormProduct(nfc: "${widget.loc}"+", "+"${widget.conc}")));
              },
              child: Text(
                "PRODOTTO".toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: GradientColors.skyLine,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
          )
          /*
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            height: 40.0,
            width: 300.0,
            //color: Colors.red,
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                onPressed: () async {
                  if (widget.internet == true) {
                    getpausapranzo =
                        int.parse(await objectRefresh.getPausaPranzoT());
                  } else {
                    getpausapranzo = await objectRefresh.getPausaPranzoF();
                  }
                  if (getpausapranzo == 1) {
                    dBSaveDataPausa("", "E");
                  } else {
                    showAlertDialog();
                  }
                },
                child: Text(
                  "PAUSA PRANZO".toUpperCase(),
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                )),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: GradientColors.skyLine,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
          ),
          Container(
            height: 40.0,
            width: 300.0,
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                onPressed: () async {
                  if (widget.internet == true) {
                    getsquadra = int.parse(await objectRefresh.getSquadraT());
                  } else {
                    getsquadra = await objectRefresh.getSquadraF();
                  }
                  if (getsquadra == 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollaboratoriList(
                                "", widget.long, widget.lat, widget.internet)));
                  } else {
                    showAlertDialog();
                  }
                },
                child: Text(
                  "SQUADRA".toUpperCase(),
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                )),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: GradientColors.skyLine,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
          ),

           */
        ],
      ))
    ]));
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
      widget.lat = _locationData.latitude;
      widget.long = _locationData.longitude;
    } catch (e) {
      erroreInMappa();
    }
  }

  gpsContainerTimbra() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300.0,
                  height: 40.0,
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () => outOfRange(),
                    child: Text(
                      "Timbra".toUpperCase() + squadradb.toString(),
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: GradientColors.skyLine,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
                ),
                Container(
                  width: 300.0,
                  height: 40.0,
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(11.0),
                      onPressed: () async {
                        if (widget.internet == true) {
                          getpausapranzo =
                              int.parse(await objectRefresh.getPausaPranzoT());
                        } else {
                          getpausapranzo =
                              await objectRefresh.getPausaPranzoF();
                        }
                        if (getpausapranzo == 1) {
                          dBSaveDataPausa("", "E");
                        } else {
                          showAlertDialog();
                        }
                      },
                      child: Text(
                        "PAUSA PRANZO".toUpperCase(),
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      )),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: GradientColors.skyLine,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  conferma() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Center(
            child: Text("Sei fuori dal cantiere d'entrata," +
                "\n Vuoi effettuare una nuova entrata in un NUOVO CANTIERE?")),
        actions: <Widget>[
          MaterialButton(
            child: Text(
              'SI',
              style: TextStyle(
                foreground: Paint()..shader = linearGradient,
                fontSize: 30.0,
              ),
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.blue, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50),
            ),
            height: 60,
            minWidth: 300,
            onPressed: () => dBSaveDataU("E"),
          ),
          const Divider(
            height: 10,
            color: Colors.white,
          ),
          MaterialButton(
            child: Text(
              'NO',
              style: TextStyle(
                foreground: Paint()..shader = linearGradient,
                fontSize: 30.0,
              ),
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.blue, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50),
            ),
            height: 60,
            minWidth: 300,
            onPressed: () => {confermaUscita()},
          ),
          const Divider(
            height: 10,
            color: Colors.white,
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
    );
  }

  confermaUscita() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              title:
                  Center(child: Text("Vuoi uscire dal cantiere PRECEDENTE?")),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    'SI',
                    style: TextStyle(
                      foreground: Paint()..shader = linearGradient,
                      fontSize: 30.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.blue, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 60,
                  minWidth: 300,
                  onPressed: () => dBSaveDataCoordinates(
                      "U", Preferenze.rigthlat, Preferenze.rigthlong),
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                ),
                MaterialButton(
                  child: Text(
                    'NO',
                    style: TextStyle(
                      foreground: Paint()..shader = linearGradient,
                      fontSize: 30.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.blue, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 60,
                  minWidth: 300,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ));
  }

  recuperonome() async {
    Refresh objectRefresh = Refresh();
    if (widget.internet == true) {
      getcliente = int.parse(await objectRefresh.getClientIdT());
    } else {
      getcliente = await objectRefresh.getClientIdF();
    }
    RESTApi wsClient = new RESTApi();
    wsClient.GetActivities(getcliente).then((value) => {
          if (ripetizioni == -1)
            {
              value.forEach((element) {
                ripetizioni++;
              }),
              ripetizioni++
            },
          Preferenze.rip = ripetizioni,
          if (value != null)
            {
              value.forEach((element) {
                setState(() {
                  if (name1 == null && ripetizioni > 0) {
                    name1 = element.descrizione;
                    att = element.codice;
                    ripetizioni--;
                  } else if (name2 == null && ripetizioni > 0) {
                    name2 = element.descrizione;
                    att2 = element.codice;
                    ripetizioni--;
                  } else if (name3 == null && ripetizioni > 0) {
                    name3 = element.descrizione;
                    att3 = element.codice;
                    ripetizioni--;
                  }
                });
              })
            }
        });
    Preferenze.rip = -1;
  }

  getUser() {
    dbHelper.queryAllRows_AUTH_USER().then((users) =>
        {this.uid = users[0]["USER_ID"], this.cid = users[0]["CLIENTE_ID"]});
  }

  void dBSaveData(verso) {
    audio();
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = Preferenze.lat;
    timb["LONGITUDE"] = Preferenze.long;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "longitudine": widget.long,
        "latitudine": widget.lat,
        "datetime": tsformatter.format(tin),
        "verso": "",
        "motivazione": verso
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      Preferenze.Squadra = 0;
      onBackPressed(context);
    } on Exception catch (_) {}
  }

  void dBSaveDataSquadra(verso) {
    audio();
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = Preferenze.lat;
    timb["LONGITUDE"] = Preferenze.long;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "longitudine": widget.long,
        "latitudine": widget.lat,
        "datetime": tsformatter.format(tin),
        "verso": "",
        "motivazione": verso
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      Preferenze.Squadra = 0;
      onBackPressed(context);
    } on Exception catch (_) {}
  }

  void dBSaveDataPausa(motivazione, verso) {
    audio();
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = Preferenze.lat;
    timb["LONGITUDE"] = Preferenze.long;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "longitudine": widget.long,
        "latitudine": widget.lat,
        "datetime": tsformatter.format(tin),
        "verso": verso,
        "motivazione": "Pausa"
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      Preferenze.Squadra = 0;
      onBackPressed(context);
    } on Exception catch (_) {}
  }

  void dBSaveDataU(verso) {
    audio();
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = Preferenze.lat;
    timb["LONGITUDE"] = Preferenze.long;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "longitudine": widget.long,
        "latitudine": widget.lat,
        "datetime": tsformatter.format(tin),
        "verso": verso,
        "motivazione": ""
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      Preferenze.Squadra = 0;
      onBackPressed(context);
    } on Exception catch (_) {}
  }

  void dBSaveDataCoordinates(verso, lat, long) {
    audio();
    getUser();
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = Preferenze.lat;
    timb["LONGITUDE"] = Preferenze.long;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {
        "longitudine": widget.long,
        "latitudine": widget.lat,
        "datetime": tsformatter.format(tin),
        "verso": verso,
        "motivazione": ""
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      Preferenze.Squadra = 0;
      onBackPressed(context);
    } on Exception catch (_) {}
  }

  void audio() {
    _audioCache.play('Audio/Ping.mp3');
  }

  void outOfRange() {
    if (getgps == 0 && getpausapranzo == 0) {
      dBSaveData(" ");
    } else if (getpausapranzo == 1) {
      var valoreAcq;
      DateTime tin = DateTime.now();
      List<String> date;
      String formattedDate = DateFormat('yyyy-MM-dd').format(tin);
      dbHelper.queryAllRows_TIMB().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            valoreAcq = jsonDecode(value.last["VALORE_ACQUISIZIONE"]);
          });
          date = valoreAcq[0]["datetime"].split(' ');
          if (date.first == formattedDate) {
            if (valoreAcq[0]["verso"] == "E" &&
                valoreAcq[0]["motivazione"] == "Pausa") {
              dBSaveDataPausa("", "U");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePageWinit()));
            } else {
              dBSaveDataU("E");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePageWinit()));
            }
          } else {
            dBSaveData("");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePageWinit()));
          }
        } else {
          dBSaveData("");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        }
      });
    } else {
      var valoreAcq;
      DateTime tin = DateTime.now();
      List<String> date;
      String formattedDate = DateFormat('yyyy-MM-dd').format(tin);
      dbHelper.queryAllRows_TIMB().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            valoreAcq = jsonDecode(value.last["VALORE_ACQUISIZIONE"]);
          });
          date = valoreAcq[0]["datetime"].split(' ');
          if (date.first == formattedDate) {
            double convertedLat = widget.lat;
            double convertedLong = widget.long;
            Preferenze.rigthlat = convertedLat;
            Preferenze.rigthlong = convertedLong;
            double lat = widget.lat;
            double long = widget.long;
            double total = 0;
            total = calculateDistance(convertedLat, convertedLong, lat, long);
            if (valoreAcq[0]["verso"] == "U" || total < Preferenze.raggio) {
              dBSaveData("");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePageWinit()));
            } else if (valoreAcq[0]["verso"] != "U" &&
                total > Preferenze.raggio) {
              confirm = conferma();
              return confirm;
            } else if (valoreAcq[0]["verso"] == "E" &&
                valoreAcq[0]["motivazione"] == "Pausa") {
              dBSaveDataPausa("", "U");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePageWinit()));
            } else {
              dBSaveDataU("E");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePageWinit()));
            }
          } else {
            dBSaveData("");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePageWinit()));
          }
        } else {
          dBSaveData("");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        }
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    var total = 12742 * asin(sqrt(a));
    return total * 1000;
  }

  void doppiaTimbratura() {
    var valoreAcq;
    DateTime tin = DateTime.now();
    dbHelper.queryAllRows_TIMB().then((value) {
      if (value.length > 0) {
        setState(() {
          valoreAcq = jsonDecode(value.last["VALORE_ACQUISIZIONE"]);
        });
        DateTime temp = DateTime.parse(valoreAcq[0]["datetime"]);
        temp = temp.add(Duration(minutes: Preferenze.intervalloDoppia));
        if (temp.isBefore(tin)) {
          dBSaveData("");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        } else {
          _toastError("Intervallo doppia timbratura non rispettato");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        }
      } else {
        dBSaveData("");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePageWinit()));
      }
    });
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

  void eseguiTimbratura() {
    if (Preferenze.doppiaTimbratura == 0) {
      dBSaveData("");
    } else if (Preferenze.abilSquadra == 1) {
      dBSaveDataSquadra("");
    } else {
      doppiaTimbratura();
    }
  }

  void onBackPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePageWinit()));
  }

  widgetgpsmapppa() {
    try {
      final LatLng _kMapCenter = LatLng(widget.lat, widget.long);
      final CameraPosition _kInitialPosition =
          CameraPosition(target: _kMapCenter, zoom: 18);
      return GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: _kInitialPosition,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: true,
        zoomControlsEnabled: false,
      );
    } catch (e) {
      erroreInMappa();
    }
  }
}
