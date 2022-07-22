import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:background_fetch/background_fetch.dart' as bf;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/position.dart';
import 'package:flutter_hr_app/TimbPages/timbratureList.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'ws.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:flutter_hr_app/AcqManuale.dart';
import 'package:flutter_hr_app/AcqQrCodePages/AcqQrCode.dart';
import 'package:flutter_hr_app/homePageAcq.dart';
class HomePageAcquisizioniInner extends StatefulWidget {
  int mode;
  String tipoAcquisizione;
  HomePageAcquisizioniInner(int mode, String tipoAcquisizione) {
    this.mode = mode;
    this.tipoAcquisizione = tipoAcquisizione;
  }
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<HomePageAcquisizioniInner> {
  static Isolate isolate = null;
  bool isSwitched = false;
  final DateFormat wsformatter = DateFormat('yyyy-MM-dd');
  final DateFormat timeformatter = DateFormat('HH:mm:ss');
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  int timbNotImp = 0;
  final timbNotImpController = new TextEditingController();
  int _status = 0;
  List<DateTime> _events = [];
  int vmode = 0;
  String vtipoAcquisizione = "";
  List<String> tecnologieAbilitate = [];
  void start() async {
    ReceivePort receivePort =
        ReceivePort();
    if (isolate == null) {
      isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
      receivePort.listen((data) {

      });
    }
  }
  void runTimer(SendPort sendPort) {
    int counter = 0;
    Timer.periodic(new Duration(seconds: 5), (Timer t) {
      counter++;
      String msg = 'notification ' + counter.toString();

      sendPort.send(msg);
    });
  }
  void stop() {
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
    }
  }
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setGPSMandatory());
    vmode = widget.mode;
    vtipoAcquisizione = widget.tipoAcquisizione;
    dbHelper
        .get_TipologieTecnologie(vtipoAcquisizione)
        .then((tips) => setState(() {
              for (var tip in tips) {
                String code = tip.toString();
                code = code.replaceAll("NOMETECNOLOGIA:", "");
                code = code.replaceAll(" ", "");
                code = code.replaceAll("{", "");
                code = code.replaceAll("}", "");
                tecnologieAbilitate.add(code);
              }
            }));
    start();
  }
  void backgroundFetchHeadlessTask(String taskId) async {
    bf.BackgroundFetch.finish(taskId);
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
                      timbNotImpController.text = Common.thereArePendingTimbs;
                    } else {
                      timbNotImpController.text = "";
                    }
                  } on Exception catch (_) {
                  }
                }
              }
            }))
        .catchError((e) {
    });
  }
  sendAllDataNotImported() {
    dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
          print(users);
          uid = users[0]["USER_ID"];
          cid = users[0]["CLIENTE_ID"];
          dbHelper
              .queryAllRows_TIMBOfDayNotImported()
              .then((timbs) => setState(() {
                    if (timbs != null) {
                      for (var timb in timbs) {
                        try {
                          RESTApi wsClient = new RESTApi();
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
                                              }))
                                          .catchError((e) {
                                      });
                                    } else {
                                    }
                                  }))
                              .catchError((e) {
                          });
                        } on Exception catch (_) {
                        }
                      }
                    }
                  }))
              .catchError((e) {
          });
        }));
  }
  Future<void> initPlatformState() async {
    bf.BackgroundFetch.configure(
        bf.BackgroundFetchConfig(
            minimumFetchInterval: 5,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false), (String taskId) async {
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      sendAllDataNotImported();
      thereAreTimbNotImported();
      bf.BackgroundFetch.finish(taskId);
    }).then((int status) {
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      setState(() {
        _status = e;
      });
    });
    int status = await bf.BackgroundFetch.status;
    setState(() {
      _status = status;
    });
    if (!mounted) return;
  }
  void setGPSMandatory() {
    try {
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            print(users);
            if (users[0]["GPS_MANDATORY"] == 1) {
              isSwitched = true;
            } else {
            }
            authrowid = users[0]["ID"];
            uid = users[0]["USER_ID"];
          }));
      sendAllDataNotImported();
      thereAreTimbNotImported();
    } on Exception catch (_) {
    }
  }
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
  void onBackPressed(BuildContext context) {
    return Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return WillPopScope(
        onWillPop: () {
          onBackPressed(context);
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Image.asset(
                Common.logo,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
            body: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Stack(
                  children: getAcquisizioniView(),
                )
                )));
  }
  List<Widget> getAcquisizioniView() {
    return [
      Positioned(
          child: Container(
              child: ListView(children: <Widget>[
        MaterialButton(
            color: Colors.white,
            textColor: Colors.black,
            disabledColor: Colors.black,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(0.0),
            splashColor: Colors.blueAccent,
            onPressed: () {},
            child: TextField(
              style: TextStyle(
                  fontSize: Common.moduleFontSize, color: Colors.black),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixIcon: Icon(Common.acquisizioniModuleIcon,
                    size: Common.moduleIconSize),
                labelText: Common.acquisizioniModuleName +
                    " " +
                    vtipoAcquisizione.toUpperCase(),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabled: false,
              ),
            )),
        Container(
            height: Common.SpaceHeight,
            child: TextField(
              controller: timbNotImpController,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              decoration: new InputDecoration.collapsed(
                  hintText: '', border: InputBorder.none, enabled: false),
            )),
        Container(
            height: tecnologieAbilitate.contains("MAN") ? Common.BtnHeight : 0,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Visibility(
                visible: true,
                child: tecnologieAbilitate.contains("MAN")
                    ? RaisedButton(
                        textColor: Colors.black,
                        color: Colors.red,
                        child: Text(Common.AcquisizioneManualeBtnLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AcquisizioneManuale(
                                    vmode, vtipoAcquisizione)),
                          );
                        },
                      )
                    : Container(
                        height: Common.SpaceHeight,
                      ))),
        Container(
            height:
                tecnologieAbilitate.contains("GPS") ? Common.SpaceHeight : 0),
        Container(
            height: tecnologieAbilitate.contains("GPS") ? Common.BtnHeight : 0,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Visibility(
                visible: true,
                child: tecnologieAbilitate.contains("GPS")
                    ? RaisedButton(
                        textColor: Colors.black,
                        color: Colors.yellow,
                        child: Text(Common.AcquisizioneGPSBtnLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showLoaderDialog(context);
                          DateTime tin = DateTime.now();
                          Map<String, dynamic> timb =
                              new Map<String, dynamic>();
                          timb["USER_ID"] = uid;
                          timb["DATETIME"] = dbformatter.format(tin);
                          timb["VERSO"] = "";
                          timb["LATITUDE"] = -1;
                          timb["LONGITUDE"] = -1;
                          timb["IMPORTED"] = 0;
                          PositionRecord positionManager = new PositionRecord();
                          positionManager
                              .getStoredPosition()
                              .then((p) => setState(() {
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
                                          "verso": timb["VERSO"]
                                        }
                                      ]);
                                      Navigator.of(context).pop();
                                      _showMapsWidget(
                                          true,
                                          p.latitude.toString(),
                                          p.longitude.toString(),
                                          timb,
                                          p);
                                    } else {
                                      _showDialogKO(true);
                                    }
                                  }));
                        },
                      )
                    : Container(height: Common.SpaceHeight))),
        Container(
            height:
                tecnologieAbilitate.contains("NFC") ? Common.SpaceHeight : 0),
        Container(
            height: tecnologieAbilitate.contains("NFC") ? Common.BtnHeight : 0,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Visibility(
                visible:
                    true,
                child: tecnologieAbilitate.contains("NFC")
                    ? RaisedButton(
                        textColor: Colors.black,
                        color: Colors.green,
                        child: Text(Common.AcquisizioneNFCBtnLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showLoaderDialog(context);
                          DateTime tin = DateTime.now();
                          Map<String, dynamic> timb =
                              new Map<String, dynamic>();
                          timb["USER_ID"] = uid;
                          timb["DATETIME"] = dbformatter.format(tin);
                          timb["VERSO"] = "";
                          timb["LATITUDE"] = -1;
                          timb["LONGITUDE"] = -1;
                          timb["IMPORTED"] = 0;
                          try {
                            FlutterNfcReader.read(instruction: "It's reading")
                                .then((value) {
                              debugPrint(value.id);
                              String val2Write = value.id.toString();
                              bool ios = false;
                              if (val2Write.trim().length == 0) {
                                ios = true;
                                val2Write = value.content;
                              }
                              timb["TECNOLOGIA_ACQUISIZIONE"] = "NFC";
                              timb["TIPO_ACQUISIZIONE"] = vmode;
                              timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                                {
                                  "nfccode": ios == false
                                      ? Common.normalizzaNFC(value.id)
                                      : val2Write,
                                  "datetime": timb["DATETIME"],
                                  "verso": timb["VERSO"]
                                }
                              ]);
                              dbHelper
                                  .insert_TIMB(timb)
                                  .then((val) => setState(() {
                                        sendAllDataNotImported();
                                        thereAreTimbNotImported();
                                        Navigator.pop(context);
                                        _showDialogOK(
                                            false,
                                            value.id.toString(),
                                            value.id.toString());
                                      }));
                            }).catchError((Object error) {
                              Navigator.pop(context);
                              _showDialogKO(false);
                            });
                          } on Exception catch (_) {
                            Navigator.pop(context);
                            _showDialogKO(false);
                          }
                        },
                      )
                    : Container(height: Common.SpaceHeight))),
        Container(
            height: tecnologieAbilitate.contains("QRCODE")
                ? Common.SpaceHeight
                : 0),
        Container(
            height:
                tecnologieAbilitate.contains("QRCODE") ? Common.BtnHeight : 0,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Visibility(
                visible: true,
                child: tecnologieAbilitate.contains("QRCODE")
                    ? RaisedButton(
                        textColor: Colors.black,
                        color: Colors.blue,
                        child: Text(Common.AcquisizioneQRCodeBtnLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AcquisizioneQrCode(
                                    vmode, vtipoAcquisizione)),
                          );
                        },
                      )
                    : Container(
                        height: Common.SpaceHeight,
                      ))),
        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.black,
              color: Colors.orange,
              child: Text(Common.AcquisizioniBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TimbraturePage(vmode)),
                );
              },
            )),
        Container(
          height: Common.SpaceHeight,
        )
      ]))),
      Positioned(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Common.moduleRoundedCorner / 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePageAcquisizioni()),
                );
              },
              label:
                  Text("", style: TextStyle(fontSize: Common.moduleFontSize)),
              icon: Icon(Icons.arrow_back, size: 28),
              color: Common.impostazioniModuleColor,
            )),
      )
    ];
  }
  void _showDialogOK(bool withCoord, String lat, String longi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Acquisizione avvenuta correttamente!"),
          content: new Text("" +
              ((withCoord == true)
                  ? "alle coordinate: " + lat + "," + longi
                  : "")),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new MaterialButton(
              child: new Text("Chiudi"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showDialogKO(bool withCoord) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore Acquisizione"),
          content: new Text("Acquisizione non effettuata correttamente! " +
              ((withCoord == true)
                  ? " Verifica la connessione internet e GPS "
                  : "")),
          actions: <Widget>[
            new MaterialButton(
              child: new Text("Chiudi"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showMapsWidget(bool withCoord, String lat, String longi,
      Map<String, dynamic> timb, dynamic p) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Conferma Posizione"),
          content: Container(
              height: 300.0,
              width: 300.0,
              child: FlutterMap(
                options: MapOptions(
                  zoom: 18.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        builder: (ctx) => Container(
                          child: Icon(Icons.location_on,
                              size: 50, color: Colors.blueAccent),
                        ),
                        point: null,
                      ),
                    ],
                  ),
                ],
              )),
          actions: <Widget>[
            new MaterialButton(
              child:
                  new Text("Aggiorna", style: TextStyle(color: Colors.black)),
              onPressed: () {
                PositionRecord positionManager = new PositionRecord();
                positionManager.getStoredPosition().then((p) => setState(() {
                      if (p != null) {
                        timb["LATITUDE"] = p.latitude;
                        timb["LONGITUDE"] = p.longitude;
                        timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                          {
                            "longitudine": timb["LONGITUDE"],
                            "latitudine": timb["LATITUDE"],
                            "datetime": timb["DATETIME"],
                            "verso": timb["VERSO"]
                          }
                        ]);
                        Navigator.of(context).pop();
                        _showMapsWidget(true, p.latitude.toString(),
                            p.longitude.toString(), timb, p);
                      }
                    }));
              },
            ),
            new MaterialButton(
              child:
                  new Text("Conferma", style: TextStyle(color: Colors.green)),
              onPressed: () {
                timb["LATITUDE"] = p.latitude;
                timb["LONGITUDE"] = p.longitude;
                timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                  {
                    "longitudine": timb["LONGITUDE"],
                    "latitudine": timb["LATITUDE"],
                    "datetime": timb["DATETIME"],
                    "verso": timb["VERSO"]
                  }
                ]);
                dbHelper.insert_TIMB(timb).then((val) => setState(() {
                      sendAllDataNotImported();
                      thereAreTimbNotImported();
                      Navigator.of(context).pop();
                      _showDialogOK(
                          true, p.latitude.toString(), p.longitude.toString());
                    }));
              },
            ),
            new MaterialButton(
              child: new Text("Annulla", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text("Attesa...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 20), () {}).then((_) {
          Navigator.of(context).pop();
        });
        return alert;
      },
    );
  }
}
