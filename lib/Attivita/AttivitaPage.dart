import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/AcqNfcPages/AcqNFCWinit.dart';
import 'package:flutter_hr_app/database.dart';
import 'package:flutter_nfc_plugin/models/nfc_message.dart';
import 'package:flutter_nfc_plugin/models/nfc_state.dart';
import 'package:flutter_nfc_plugin/nfc_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePages/homePage.dart';
import '../Model/Impostazione.dart';
import '../Model/Refresh.dart';
import '../TimbPages/timbratureListWinit.dart';
import '../preferenze.dart';
import '../ws.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final String barcode;
  final double long;
  final double lat;
  final bool internet;

  const MultiSelect(
      {this.items, this.barcode, this.long, this.lat, this.internet});

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
  static String time = "";
  static String date = "";
  NfcMessage nfcMessageStartedWith;
  final DateFormat dati = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  Container loadEvent = new Container();
  Container confirm = new Container();
  List<String> _selectedItems = [];
  bool vdoUpdate = false;
  List<Module> moduleList = [];
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

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  timbcount() async {
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
    WidgetsBinding.instance?.addObserver(this);
    _nfcstatus();
    timbcount();
    dbHelper.getAttivita();
    super.initState();
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  void _submit() {
    initPlatformState();
  }

  void _reset() {
    _selectedItems.clear();
    Navigator.pop(context);
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

  Future<void> initPlatformState() async {
    time = getSystemTime();
    date = getSystemDate();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AcquisizioneNfcWinit(
                nfc: widget.barcode,
                date: date,
                time: time,
                selectedItems: _selectedItems,
                long: widget.long,
                lat: widget.lat,
                internet: widget.internet)));
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

  void selectAtt(att) {
    if (Preferenze.multiAtt == 1) {
      if (attivita == "") {
        attivita = att;
      } else {
        attivita = attivita + "," + att;
      }
    } else {
      attivita = att;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scegli il tipo di Attività'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked),
                  ))
              .toList(),
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('INVIA'),
          onPressed: _submit,
        ),
        ElevatedButton(
          child: const Text('ANNULLA'),
          onPressed: _reset,
        ),
      ],
    );
  }
}

class AttivitaList extends StatefulWidget {
  final String cantieridb;
  final double longitudine;
  final double latitudine;
  final bool internet;

  const AttivitaList(
      this.cantieridb, this.longitudine, this.latitudine, this.internet);

  @override
  State<StatefulWidget> createState() {
    return AttivitaListState();
  }
}

class AttivitaListState extends State<AttivitaList> {
  TextEditingController txtdescrizione = TextEditingController();
  TextEditingController txtmatricola = TextEditingController();
  Refresh objectRefresh = Refresh();
  List<dynamic> _journals = [];
  static String time = "";
  static String date = "";
  NfcMessage nfcMessageStartedWith;

  _refreshJournals() async {
    if (widget.internet == true) {
      List data = await dbHelper.getAttivita();
      setState(() {
        _journals = data;
      });
    } else {}
  }

  List _selectedItems = [];

  _showMultiSelect() {
    List<String> _items = [];
    for (int i = 0; i < _journals.length; i++) {
      _items.add(_journals[i]["CodiceAtt"].toString());
    }
    List results = showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
            items: _items,
            barcode: widget.cantieridb,
            long: widget.longitudine,
            lat: widget.latitudine,
            internet: widget.internet);
      },
    ) as List;
    if (results != null) {
      _selectedItems = results;
    }
  }

  String string = "";

  @override
  void initState() {
    _refreshJournals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATTIVITA'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcquisizioneNfcWinit(
                        nfc: widget.cantieridb,
                        date: date,
                        time: time,
                        selectedItems: _selectedItems,
                        long: 0.0,
                        lat: 0.0,
                        internet: widget.internet),
                  ));
            }),
        backgroundColor: Colors.blue,
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
            Container(
                width: MediaQuery.of(context).size.width * 1.0,
                height: MediaQuery.of(context).size.height * 0.60,
                child: ListView.builder(
                    itemCount: _journals.length,
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        child: Row(children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _journals[index]["DescrizioneAtt"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.black),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    _journals[index]['CodiceAtt'].toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.black),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  IconButton(
                                      icon: const Icon(Icons.list),
                                      onPressed: _showMultiSelect),
                                ]),
                            width: MediaQuery.of(context).size.width * 0.10,
                          ),
                        ]),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
