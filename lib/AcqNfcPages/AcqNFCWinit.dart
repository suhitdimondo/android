import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_hr_app/Damage/DamagePageCompiled.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/Model/Eventi.dart';
import 'package:flutter_hr_app/Model/Internet.dart';
import 'package:flutter_hr_app/Squadra/SquadraPage.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:flutter_nfc_plugin/models/nfc_message.dart';
import 'package:flutter_nfc_plugin/models/nfc_state.dart';
import 'package:flutter_nfc_plugin/nfc_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Impostazione.dart';
import '../Model/Refresh.dart';
import '../Prodotti/FormProdotto.dart';
import '../Prodotti/DisplayProdotto.dart';
import '../common.dart';
import '../database.dart';
import '../preferenze.dart';
import '../ws.dart';

String name1 = "";
String name2 = "";
String name3 = "";
String attivita = "";
String att = "";
String att2 = "";
String att3 = "";
int ripetizioni = Preferenze.rip;

class MultiSelect extends StatefulWidget {
  final Map<String, bool> items;
  final String barcode;
  final double long;
  final double lat;
  final String date;
  final String time;
  final bool internet;
  final int color;

  MultiSelect(
      {this.items,
        this.barcode,
        this.date,
        this.time,
        this.long,
        this.lat,
        this.internet,
        this.color});

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> with WidgetsBindingObserver {
  final AudioCache _audioCache = AudioCache();
  int vmode = 0;
  String vname = "";
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  NfcMessage nfcMessageStartedWith;
  final DateFormat dati = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  Container loadEvent = new Container();
  Container confirm = new Container();
  bool vdoUpdate = false;
  final timbNotImpController = new TextEditingController();
  int eventi = 0;
  int start = 0;
  bool useFBA = false;
  bool isOn = true;
  bool useNAV = true;
  bool nfcIsOn = false;
  int timbCount = 0;
  int nfcNotSupported = 0;
  int count = 0;
  int gps = 0;
  int gtimbCount = 0;
  bool isLocationEnabled = true;
  String conc = "";
  String long = "";
  String lat = "";
  String loc = "";
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat finalformat = DateFormat('HH:mm');
  final DateFormat finalformat2 = DateFormat('dd');
  var connectivityResult;
  Impostazione objectImpostazione = Impostazione(
      cantieridb: 0,
      squadradb: 0,
      gpsdb: 0,
      scheduledGPSdb: 0,
      activities: 0,
      pausaPranzo: 0,
      idCliente: "",
      segnalazioni: 0,
      connection: "");
  Refresh objectRefresh = Refresh(
      cantieridb: 0,
      squadradb: 0,
      gpsdb: 0,
      scheduledGPSdb: 0,
      segnalazioni: 0,
      pausaPranzo: 0,
      idCliente: "",
      connection: "",
      activities: 0);
  String val2Write = "";
  int getactivities = 0;
  int getcantiere = 0;
  int getgps = 0;
  int getsquadra = 0;
  int getscheduledgps = 0;
  int getcliente = 0;
  int getsegnalazione = 0;
  int getpausapranzo = 0;
  int cantieridb = 0;
  int squadradb = 0;
  int gpsdb = 0;
  int scheduledGPSdb = 0;
  int activities = 0;
  int segnalazioni = 0;
  int pausaPranzo = 0;
  int flag = 0;
  Timer _incrementCounterTimer;
  int counter = 1;
  int sendcolor;

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

  _nfcstatus() async {
    NfcPlugin nfcPlugin = NfcPlugin();
    try {
      final NfcState _nfcState = await nfcPlugin.nfcState;
      if (_nfcState == NfcState.enabled)
        return nfcIsOn = true;
      else if (_nfcState == NfcState.notSupported) return nfcNotSupported = 1;
      return nfcIsOn = false;
    } on PlatformException {}
  }

  String string = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _nfcstatus();
    timbcount();
    setState(() {
      getItems();
    });
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      gpsdb = 0; //Gps Spento
    } else {
      gpsdb = 1; //Gps Acceso
    }
  }

  recuperoSegnalazioni() async {
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
    _gpsService();
  }

  DateTime licenza;

  sendAllDataNotImported() {
    RESTApi wsClient = new RESTApi();
    dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
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
              String valore =
              timb["VALORE_ACQUISIZIONE"].toString();
              String tecnologia =
              timb["TECNOLOGIA_ACQUISIZIONE"].toString();
              String tipo = timb["TIPO_ACQUISIZIONE"].toString();
              String giornata =
              timb["DATETIME"].toString().substring(0, 10);
              wsClient
                  .sendData(giornata, uid.toString(),
                  cid.toString(), valore, tipo, tecnologia)
                  .then((val) => setState(() {
                rb = val;
                if (rb != 'Error') {
                  Map<String, dynamic> ti =
                  new Map<String, dynamic>();
                  ti["ID"] =
                      int.parse(timb["ID"].toString());
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
    }));
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
              timbNotImpController.text =
              "Registrazioni da inviare:  $ntimb";
            } else {
              timbNotImpController.text = "";
            }
          } on Exception catch (_) {}
        }
      }
    }))
        .catchError((e) {});
  }

  void audio() {
    _audioCache.play('Audio/Ping.mp3');
  }

  getUser() {
    dbHelper.queryAllRows_AUTH_USER().then((users) =>
    {this.uid = users[0]["USER_ID"], this.cid = users[0]["CLIENTE_ID"]});
  }

  Map<String, bool> _selectedItems = {};

  getItems() async {
    int countAttivita = await dbHelper.count_attivita_flag();
    if (countAttivita < 1) {
      String productURl =
          "http://backend.winitsrl.eu:81/app/ws/Attivita?IdCliente=16";
      http.Response response = await http.get(Uri.parse(productURl),
          headers: {"Content-Type": "application/json"});
      for (int i = 0; i < json.decode(response.body).length; i++) {
        dbHelper.insert_attivita(json.decode(response.body)[i]["CodiceAtt"],
            json.decode(response.body)[i]["DescrizioneAtt"], "16", "false");
        setState(() {
          _selectedItems
              .addAll({json.decode(response.body)[i]["DescrizioneAtt"]: false});
        });
      }
    } else {
      List result = await dbHelper.attivita_select();
      for (int i = 0; i < result.length; i++) {
        bool flag = result[i]["flag"].toString().toLowerCase() ==
            true.toString().toLowerCase();
        setState(() {
          _selectedItems.addAll({result[i]["DescrizioneAtt"].toString(): flag});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attività'),
      content: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children: _selectedItems.keys.map((key) {
            return new CheckboxListTile(
              title: new Text(
                "(  )  " + key,
                textAlign: TextAlign.left,
              ),
              value: _selectedItems[key],
              activeColor: Colors.black,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _selectedItems[key] = value;
                  dbHelper.update_attivita_flag(
                      key, _selectedItems[key].toString());
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        Container(
          child: Row(
            children: [
              Container(
                child: Column(
                  children: [
                    MaterialButton(
                      child: const Text('TUTTO',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      onPressed: () async {
                        List result = await dbHelper.attivita_select();
                        for (int i = 0; i < result.length; i++) {
                          setState(() {
                            _selectedItems.addAll(
                                {result[i]["DescrizioneAtt"].toString(): true});
                            dbHelper.update_attivita_flag(
                                result[i]["DescrizioneAtt"].toString(), "true");
                          });
                        }
                      },
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.22,
              ),
              Container(
                child: Column(
                  children: [
                    MaterialButton(
                      child: const Text('INVIA',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.left),
                      onPressed: () async {
                        await changeColorBtn();
                      },
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.23,
              ),
              Container(
                child: Column(
                  children: [
                    MaterialButton(
                      child: const Text('ANNULLA',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.27,
              )
            ],
          ),
        )
      ],
    );
  }

  changeColorBtn() async {
    List color = await dbHelper.attivita_select();
    for (int i = 0; i < color.length; i++) {
      String flag = color[i]["flag"].toString();
      if (flag == "true") {
        sendcolor = 1;
        break;
      }
    }
    _incrementCounterTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      counter++;
      if (counter == 2) {
        _incrementCounterTimer.cancel();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AcquisizioneNfcWinit(
                    nfc: widget.barcode,
                    date: widget.date,
                    time: widget.time,
                    selectedItems: [],
                    long: widget.long,
                    lat: widget.lat,
                    internet: widget.internet,
                    color: sendcolor)));
      }
    });
  }
}

class AcquisizioneNfcWinit extends StatefulWidget {
  final String nfc;
  final String date;
  final String time;
  final List selectedItems;
  final double long;
  final double lat;
  final bool internet;
  final int color;

  AcquisizioneNfcWinit(
      {this.nfc,
        this.date,
        this.time,
        this.selectedItems,
        this.long,
        this.lat,
        this.internet,
        this.color});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<AcquisizioneNfcWinit> with WidgetsBindingObserver {
  Checkinternet objectinternet = Checkinternet();
  final AudioCache _audioCache = AudioCache();
  List _selected = [];
  int vmode = 0;
  String vname = "";
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  String val2Write = "";
  Impostazione objectImpostazione = Impostazione();
  Refresh objectRefresh = Refresh();
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  Container loadEvent = new Container();
  int cantieridb = 0;
  int squadradb = 0;
  int gpsdb = 0;
  bool isOn = true;
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
  int flag = 0;
  final DateFormat finalformat = DateFormat('HH:mm');
  final DateFormat finalformat2 = DateFormat('dd');

  @override
  void initState() {
    super.initState();
    typeTimb();
    recuperonome();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  TextEditingController txtdescrizione = TextEditingController();
  TextEditingController txtmatricola = TextEditingController();
  NfcMessage nfcMessageStartedWith;

  _showMultiSelect() async {
    Map<String, bool> _items = {};
    List res = await dbHelper.attivita_select();
    for (int i = 0; i < res.length; i++) {
      bool flag = res[i]["flag"].toString().toLowerCase() ==
          true.toString().toLowerCase();
      _items.addAll({res[i]["CodiceAtt"]: flag});
    }
    List results = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
            items: _items,
            barcode: widget.nfc,
            date: widget.date,
            time: widget.time,
            long: widget.long,
            lat: widget.lat,
            internet: widget.internet,
            color: 0);
      },
    ) as List;
    if (results != null) {
      _selected.add(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[100],
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(
            "NFC",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageWinit(),
                )),
          ),
        ),
        body: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 92, 15, 5),
                        height: Common.SpaceHeight,
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
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 12),
                        height: Common.SpaceHeight,
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
                      Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 12, 15, 12),
                        height: Common.SpaceHeight,
                        child: Row(children: [
                          Text(
                            "Cantiere:",
                            style: TextStyle(fontSize: 20, color: Colors.black54),
                          ),
                          Spacer(),
                          Flexible(
                            child: Text(
                              "${widget.nfc}",
                              style: TextStyle(fontSize: 20, color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          )
                        ]),
                      ),
                      Divider(height: 10, thickness: 10, color: Colors.grey[200]),

                      //loadEvent,

                      Container(
                        margin: const EdgeInsets.only(top: 30),
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
                                    margin: EdgeInsets.only(bottom: 20.0),
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
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    width: 300.0,
                                    height: 40.0,
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
                                            MaterialPageRoute(builder: (context) => FormProduct(nfc: "${widget.nfc}")));
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
                                    margin: EdgeInsets.only(bottom: 20.0),
                                    width: 300.0,
                                    height: 40.0,
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      textColor: Colors.white,
                                      padding: EdgeInsets.all(8.0),
                                      onPressed: _showMultiSelect,
                                      child: Text(
                                        "ATTIVITA".toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: widget.color.toString() == "1"
                                              ? GradientColors.orange
                                              : GradientColors.skyLine,
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
                                      onPressed: () async {
                                        if (widget.internet == true) {
                                          getsegnalazione = int.parse(
                                              await objectRefresh
                                                  .getSegnalazioneT());
                                        } else {
                                          getsegnalazione = await objectRefresh
                                              .getSegnalazioneF();
                                        }
                                        if (getsegnalazione == 1) {
                                          damage();
                                        } else {}
                                      },
                                      child: Text(
                                        "SEGNALAZIONI".toUpperCase(),
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
                                        padding: EdgeInsets.all(11.0),
                                        onPressed: () async {
                                          if (widget.internet == true) {
                                            getpausapranzo = int.parse(
                                                await objectRefresh
                                                    .getPausaPranzoT());
                                          } else {
                                            getpausapranzo = await objectRefresh
                                                .getPausaPranzoF();
                                          }
                                          if (getpausapranzo == 1) {
                                            dBSaveDataPausa("", "E");
                                          } else {}
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
                                    width: 300.0,
                                    height: 40.0,
                                    child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)),
                                        textColor: Colors.white,
                                        padding: EdgeInsets.all(11.0),
                                        onPressed: () async {
                                          if (widget.internet == true) {
                                            getsquadra = int.parse(
                                                await objectRefresh.getSquadraT());
                                          } else {
                                            getsquadra =
                                            await objectRefresh.getSquadraF();
                                          }
                                          if (getsquadra == 1) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CollaboratoriList(
                                                            widget.nfc,
                                                            widget.long,
                                                            widget.lat,
                                                            widget.internet)));
                                          } else {}
                                        },
                                        child: Text(
                                          "SQUARDA".toUpperCase(),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                    ])),
          ],
        ));
  }

  getUser() {
    dbHelper.queryAllRows_AUTH_USER().then((users) =>
    {this.uid = users[0]["USER_ID"], this.cid = users[0]["CLIENTE_ID"]});
  }

  void dBSaveData(verso, attivita) {
    audio();
    if (Preferenze.attObl == 0) {
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
          "nfccode": widget.nfc,
          "datetime": tsformatter.format(tin),
          "motivazione": verso != null ? verso : "none",
          "attivita": attivita != null ? attivita : "none",
          "squadra":
          widget.selectedItems != null ? widget.selectedItems : "none",
          "long": widget.long != null ? widget.long : "none",
          "lat": widget.lat != null ? widget.lat : "none",
          "cantiere": widget.nfc != null ? widget.nfc : "none",
        }
      ]);
      try {
        dbHelper.insert_TIMB(timb).then((val) => null);
        Preferenze.Squadra = 0;
        onBackPressed(context);
      } on Exception catch (_) {}
    } else if (Preferenze.attObl == 1 && attivita != null) {
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
          "nfccode": widget.nfc,
          "datetime": tsformatter.format(tin),
          "motivazione": verso != null ? verso : "none",
          "attivita": attivita != null ? attivita : "none",
          "squadra":
          widget.selectedItems != null ? widget.selectedItems : "none",
          "long": widget.long != null ? widget.long : "none",
          "lat": widget.lat != null ? widget.lat : "none",
          "cantiere": widget.nfc != null ? widget.nfc : "none",
        }
      ]);
      try {
        dbHelper.insert_TIMB(timb).then((val) => null);
        onBackPressed(context);
        Preferenze.Squadra = 0;
      } on Exception catch (_) {}
    } else {
      _toastError("Attività richiesta");
    }
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
        "longitudine": timb["LONGITUDE"],
        "latitudine": timb["LATITUDE"],
        "datetime": tsformatter.format(tin),
        "verso": verso,
        "motivazione": "Pausa",
        "squadra": widget.selectedItems,
        "long": widget.long,
        "lat": widget.lat
      }
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
      onBackPressed(context);
      Preferenze.Squadra = 0;
    } on Exception catch (_) {}
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

  final Shader linearGradient = LinearGradient(
    colors: GradientColors.skyLine,
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  nFCContainerEU() {
    //loadEvent
  }

  nFCContainerPF() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 135.0,
                      height: 125.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () => dBSaveData("PART", attivita),
                        child: Text(
                          "PARTENZA".toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.beautifulGreen,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      width: 135.0,
                      height: 125.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () => dBSaveData("FERM", attivita),
                        child: Text(
                          "FERMATA".toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.sunrise,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                  width: 300.4,
                  height: 50.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getactivities =
                            int.parse(await objectRefresh.getActivitiesT());
                      } else {
                        getactivities = await objectRefresh.getActivitiesF();
                      }
                      if (getactivities == 1) {
                        if (await objectinternet.checkConnectivityState() ==
                            true) {
                        } else {}
                      } else {}
                    },
                    child: Text(
                      "ATTIVITA'".toUpperCase(),
                      style: TextStyle(
                        fontSize: 30.0,
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
                  margin: EdgeInsets.only(bottom: 30),
                  width: 300.0,
                  height: 40.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getsegnalazione =
                            int.parse(await objectRefresh.getSegnalazioneT());
                      } else {
                        getsegnalazione =
                        await objectRefresh.getSegnalazioneF();
                      }
                      if (getsegnalazione == 1) {
                        damage();
                      } else {}
                    },
                    child: Text(
                      "SEGNALAZIONI".toUpperCase(),
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
                        } else {}
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  recuperonome() async {
    final dbHelper = DatabaseHelper.instance;
    int cid = 0;
    await dbHelper
        .queryAllRows_AUTH_USER()
        .then((users) => {cid = users[0]["CLIENTE_ID"]});
    RESTApi wsClient = new RESTApi();
    wsClient.GetActivities(cid).then((value) => {
      if (value != null)
        {
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
        }
    });
    Preferenze.rip = -1;
  }

  nFCContainerP() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      width: 135.0,
                      height: 125.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () => dBSaveData("PART", attivita),
                        child: Text(
                          "PARTENZA".toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.sunrise,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                  width: 300.4,
                  height: 50.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getactivities =
                            int.parse(await objectRefresh.getActivitiesT());
                      } else {
                        getactivities = await objectRefresh.getActivitiesF();
                      }
                      if (getactivities == 1) {
                      } else {}
                    },
                    child: Text(
                      "ATTIVITA'".toUpperCase(),
                      style: TextStyle(
                        fontSize: 30.0,
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
                  margin: EdgeInsets.only(bottom: 30),
                  width: 300.0,
                  height: 50.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getsegnalazione =
                            int.parse(await objectRefresh.getSegnalazioneT());
                      } else {
                        getsegnalazione =
                        await objectRefresh.getSegnalazioneF();
                      }
                      if (getsegnalazione == 1) {
                        damage();
                      } else {}
                    },
                    child: Text(
                      "SEGNALAZIONI".toUpperCase(),
                      style: TextStyle(
                        fontSize: 30.0,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  nFCContainerF() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      width: 135.0,
                      height: 125.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () => dBSaveData("FERM", attivita),
                        child: Text(
                          "FERMATA".toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: GradientColors.sunrise,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                  width: 300.4,
                  height: 50.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getactivities =
                            int.parse(await objectRefresh.getActivitiesT());
                      } else {
                        getactivities = await objectRefresh.getActivitiesF();
                      }
                      if (getactivities == 1) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 20),
                            title: Center(
                                child: Text('Scegli il tipo di Attività')),
                            actions: <Widget>[
                              (name1 != null)
                                  ? MaterialButton(
                                child: Text(
                                  '$name1',
                                  style: TextStyle(
                                    foreground: Paint()
                                      ..shader = linearGradient,
                                    fontSize: 30.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                height: 60,
                                minWidth: 300,
                                onPressed: () {
                                  Navigator.pop(_);
                                },
                              )
                                  : Row(),
                              const Divider(
                                height: 10,
                                color: Colors.white,
                              ),
                              (name2 != null)
                                  ? MaterialButton(
                                child: Text(
                                  '$name2',
                                  style: TextStyle(
                                    foreground: Paint()
                                      ..shader = linearGradient,
                                    fontSize: 30.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                height: 60,
                                minWidth: 300,
                                onPressed: () {
                                  Navigator.pop(_);
                                },
                              )
                                  : Row(),
                              const Divider(
                                height: 10,
                                color: Colors.white,
                              ),
                              (name3 != null)
                                  ? Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: MaterialButton(
                                  child: Text(
                                    '$name3',
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..shader = linearGradient,
                                      fontSize: 30.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.blue,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius:
                                    BorderRadius.circular(50),
                                  ),
                                  height: 60,
                                  minWidth: 300,
                                  onPressed: () {
                                    Navigator.pop(_);
                                  },
                                ),
                              )
                                  : Row(),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                        );
                      } else {}
                    },
                    child: Text(
                      "ATTIVITA'".toUpperCase(),
                      style: TextStyle(
                        fontSize: 30.0,
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
                  margin: EdgeInsets.only(bottom: 30),
                  width: 300.0,
                  height: 50.0,
                  //color: Colors.red,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      if (widget.internet == true) {
                        getsegnalazione =
                            int.parse(await objectRefresh.getSegnalazioneT());
                      } else {
                        getsegnalazione =
                        await objectRefresh.getSegnalazioneF();
                      }
                      if (getsegnalazione == 1) {
                        damage();
                      } else {}
                    },
                    child: Text(
                      "SEGNALAZIONI".toUpperCase(),
                      style: TextStyle(
                        fontSize: 30.0,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  typeTimb() async {
    dbHelper.getEvent(widget.nfc).then((value) {
      if (value != null) {
        if (Eventi.fromJson(value).evento == "PART&PERM") {
          bottonType(true);
        } else {
          bottonType(false);
        }
      } else if (value == null) {
        bottonType(false);
      }
    });
  }

  void audio() {
    _audioCache.play('Audio/my_audio.mp3');
  }

  bottonType(bool partAndPerm) {
    var a;
    DateTime tin = DateTime.now();
    List<String> prova;
    String formattedDate = DateFormat('yyyy-MM-dd').format(tin);
    dbHelper.queryAllRows_TIMB().then((value) {
      if (value.isNotEmpty) {
        a = jsonDecode(value.last["VALORE_ACQUISIZIONE"]);
        prova = a[0]["datetime"].split(' ');
        if (prova.first == formattedDate) {
          if (a[0]["nfccode"] == widget.nfc && a[0]["motivazione"] == "PART") {
            loadEvent = nFCContainerP();
          } else if (a[0]["nfccode"] == widget.nfc &&
              a[0]["motivazione"] == "FERM") {
            loadEvent = nFCContainerF();
          } else if (Preferenze.inOutPref == 1 && partAndPerm) {
            loadEvent = nFCContainerPF();
          } else if (Preferenze.inOutPref == 0 && !partAndPerm) {
            loadEvent = nFCContainerPF();
          } else if (Preferenze.inOutPref == 1 && !partAndPerm) {
            loadEvent = nFCContainerEU();
          } else {
            loadEvent = nFCContainerEU();
          }
          return loadEvent;
        }
      } else {
        a = null;
        loadEvent = nFCContainerEU();
      }
    });
    if (a == null) {
      if (Preferenze.inOutPref == 1 && partAndPerm == false) {
        loadEvent = nFCContainerEU();
      } else if (Preferenze.inOutPref == 1 && partAndPerm) {
        loadEvent = nFCContainerPF();
      } else if (Preferenze.inOutPref == 0 && partAndPerm == false) {
        loadEvent = nFCContainerPF();
      } else {
        loadEvent = nFCContainerEU();
      }
      return loadEvent;
    }
  }

  void damage() {
    dbHelper.getEvent(widget.nfc).then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DamageCompiled(
                  cantiere: widget.nfc.toString(),
                  codice: widget.nfc.toString())));
    });
  }

  void doppiaTimbratura(attivita) {
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
          dBSaveData("", attivita);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        } else {
          _toastError("Intervallo doppia timbratura non rispettato");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageWinit()));
        }
      } else {
        dBSaveData("", attivita);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePageWinit()));
      }
    });
  }

  void eseguiTimbratura() {
    if (Preferenze.doppiaTimbratura == 0) {
      dBSaveData("", attivita);
    } else {
      doppiaTimbratura(attivita);
    }
  }
}

void onBackPressed(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => HomePageWinit()));
}
