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
import 'package:flutter_hr_app/HomePages/homePage.dart';
class HomePageTimb extends StatefulWidget {
  int mode;
  HomePageTimb(int mode) {
    this.mode = mode;
  }
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<HomePageTimb> {
  static Isolate isolate = null;
  int vmode = 0;
  List<String> tecnologieAbilitate = [];
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

  void start() async {
    ReceivePort receivePort =
        ReceivePort(); //port for this main isolate to receive messages.
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
    dbHelper.get_TipologieTecnologie("Timbrature").then((tips) => setState(() {
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
            if (users[0]["GPS_MANDATORY"] == 1) {
              isSwitched = true;
            } else {
            }
            authrowid = users[0]["ID"];
            uid = users[0]["USER_ID"];
            cid = users[0]["CLIENTE_ID"];
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
                child: getGridViewHomeTimb()
                )));
  }
  Stack getGridViewHomeTimb() {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height / 10);
    final double itemWidth = size.width / 2;
    List<Widget> wList = [];
    if (tecnologieAbilitate.contains("MAN")) {
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(""),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
          //DO NOTHING
        },
        child: Text(Common.timbratureManuali + " " + Common.timbratureManuali2,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
          //DO NOTHING
        },
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "U";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          timb["TIPO_ACQUISIZIONE"] = vmode;
          timb["TECNOLOGIA_ACQUISIZIONE"] = "MAN";
          timb["VALORE_ACQUISIZIONE"] = jsonEncode([
            {"datetime": timb["DATETIME"], "verso": timb["VERSO"]}
          ]);
          try {
            dbHelper.insert_TIMB(timb).then((val) => setState(() {
                  sendAllDataNotImported();
                  thereAreTimbNotImported();
                  Navigator.pop(context);
                  _showDialogOK(false, (-1).toString(), (-1).toString());
                }));
          } on Exception catch (_) {
            Navigator.pop(context);
            _showDialogKO(false);
          }
        },
        label: Text("U",
            style: TextStyle(
                fontSize: Common.moduleFontSize, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.red,
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "E";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          timb["TIPO_ACQUISIZIONE"] = vmode;
          timb["TECNOLOGIA_ACQUISIZIONE"] = "MAN";
          timb["VALORE_ACQUISIZIONE"] = jsonEncode([
            {"datetime": timb["DATETIME"], "verso": timb["VERSO"]}
          ]);
          try {
            dbHelper.insert_TIMB(timb).then((val) => setState(() {
                  sendAllDataNotImported();
                  thereAreTimbNotImported();
                  Navigator.pop(context);
                  _showDialogOK(false, (-1).toString(), (-1).toString());
                }));
          } on Exception catch (_) {
            Navigator.pop(context);
            _showDialogKO(false);
          }
        },
        label: Text("E",
            style: TextStyle(
                fontSize: Common.moduleFontSize, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.arrow_forward_ios),
        color: Colors.red,
      ));
    }
    if (tecnologieAbilitate.contains("GPS")) {
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {},
        child: Text(""),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {},
        child: Text(Common.timbratureGps2,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: Common.moduleFontSize),
            textAlign: TextAlign.center),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {},
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "U";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          try {
            if (isSwitched == true) {
              PositionRecord positionManager = new PositionRecord();
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
                          "verso": timb["VERSO"]
                        }
                      ]);
                      _showMapsWidget(true, p.latitude.toString(),
                          p.longitude.toString(), timb, p);
                    } else {
                      _showDialogKO(true);
                    }
                  }));
            } else
            {
              dbHelper.insert_TIMB(timb).then((val) => setState(() {
                    sendAllDataNotImported();
                    thereAreTimbNotImported();
                    _showDialogOK(false, (-1).toString(), (-1).toString());
                  }));
            }
          } on Exception catch (_) {
            _showDialogKO(false);
          }
        },
        label: Text("U",
            style: TextStyle(
                fontSize: Common.moduleFontSize, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.yellow,
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "E";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          try {
            if (isSwitched == true) {
              PositionRecord positionManager = new PositionRecord();
              positionManager.getStoredPosition().then((p) => setState(() {
                    if (p != null) {
                      timb["LATITUDE"] = p.latitude;
                      timb["LONGITUDE"] = p.longitude;
                      timb["TECNOLOGIA_ACQUISIZIONE"] = "GPS";
                      timb["TIPO_ACQUISIZIONE"] = vmode;
                      timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                        {
                          "longitudine": timb["LONGITUDE"],
                          "latitudine": timb["LATITUDE"],
                          "datetime": timb["DATETIME"],
                          "verso": timb["VERSO"]
                        }
                      ]);
                      _showMapsWidget(true, p.latitude.toString(),
                          p.longitude.toString(), timb, p);
                    } else {
                      _showDialogKO(true);
                    }
                  }));
            } else
            {
              dbHelper.insert_TIMB(timb).then((val) => setState(() {
                    sendAllDataNotImported();
                    thereAreTimbNotImported();
                    _showDialogOK(false, (-1).toString(), (-1).toString());
                  }));
            }
          } on Exception catch (_) {
            _showDialogKO(false);
          }
        },
        label: Text("E",
            style: TextStyle(
                fontSize: Common.moduleFontSize, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.arrow_forward_ios),
        color: Colors.yellow,
      ));
    }
    if (tecnologieAbilitate.contains("NFC")) {
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {

        },
        child: Text(""),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(Common.timbratureNfc2,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: Common.moduleFontSize),
            textAlign: TextAlign.center),
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "U";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          try {
            FlutterNfcReader.read(instruction: "It's reading").then((value) {
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
                  "nfccode":
                      ios == false ? Common.normalizzaNFC(value.id) : val2Write,
                  "datetime": timb["DATETIME"],
                  "verso": timb["VERSO"]
                }
              ]);
              dbHelper.insert_TIMB(timb).then((val) => setState(() {
                    sendAllDataNotImported();
                    thereAreTimbNotImported();
                    Navigator.pop(context);
                    _showDialogOK(
                        false, value.id.toString(), value.id.toString());
                  }));
            }).catchError((Object exception) {
              Navigator.pop(context);
              _showDialogKO(false);
            });
          } on Exception catch (_) {
            Navigator.pop(context);
            _showDialogKO(false);
          }
        },
        label: Text("U", style: TextStyle(fontSize: Common.moduleFontSize)),
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.green,
      ));
      wList.add(MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: EdgeInsets.all(0.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
        },
        child: Text(""),
      ));
      wList.add(RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          showLoaderDialog(context);
          DateTime tin = DateTime.now();
          Map<String, dynamic> timb = new Map<String, dynamic>();
          timb["USER_ID"] = uid;
          timb["DATETIME"] = dbformatter.format(tin);
          timb["VERSO"] = "E";
          timb["LATITUDE"] = -1;
          timb["LONGITUDE"] = -1;
          timb["IMPORTED"] = 0;
          try {
            FlutterNfcReader.read(instruction: "It's reading").then((value) {
              debugPrint(value.id);
              timb["TECNOLOGIA_ACQUISIZIONE"] = "NFC";
              timb["TIPO_ACQUISIZIONE"] = vmode;
              timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                {
                  "nfccode": Common.normalizzaNFC(value.id),
                  "datetime": timb["DATETIME"],
                  "verso": timb["VERSO"]
                }
              ]);
              dbHelper.insert_TIMB(timb).then((val) => setState(() {
                    sendAllDataNotImported();
                    thereAreTimbNotImported();
                    Navigator.pop(context);
                    _showDialogOK(
                        false, value.id.toString(), value.id.toString());
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
        label: Text("E",
            style: TextStyle(
                fontSize: Common.moduleFontSize, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.arrow_forward_ios),
        color: Colors.green,
      ));
    }
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
      },
      child: Text(""),
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
      },
      child:
          Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.black,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
      },
      child: Text(""),
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
      },
      child: TextField(
        decoration: InputDecoration(
          labelText: "",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    ));
    wList.add(MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
          side: BorderSide(color: Common.moduleBorderColor)),
      color: Colors.orange,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TimbraturePage(1)),
        );
      },
      child: Text(Common.TimbratureBtnLabel,
          style: TextStyle(fontSize: Common.moduleFontSize)),
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.black,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
      },
      child: Text(""),
    ));
    return Stack(children: <Widget>[
      Positioned(
          child: ListView(
        children: [
          MaterialButton(
            color: Colors.white,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(0.0),
            splashColor: Colors.blueAccent,
            onPressed: () {},
            child: TextField(
              style: TextStyle(
                  fontSize: Common.moduleFontSize, color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Common.calendarioModuleIcon,
                  size: Common.moduleIconSize,
                ),
                labelText: Common.acquisizioniModuleName +
                    " " +
                    Common.timbratureModuleName,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabled: false,
              ),
            ),
          ),
          Container(
              height: Common.SpaceHeight,
              child: TextField(
                controller: timbNotImpController,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                decoration: new InputDecoration.collapsed(
                    hintText: '', border: InputBorder.none, enabled: false),
              )),
          GridView.count(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              shrinkWrap: true,
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 8,
              children: wList)
        ],
      )),
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
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              label:
                  Text("", style: TextStyle(fontSize: Common.moduleFontSize)),
              icon: Icon(Icons.arrow_back, size: Common.moduleIconSize),
              color: Common.impostazioniModuleColor,
            )),
      )
    ]);
  }
  List<Widget> getTimbratureView() {
    return [
      Positioned(
          child: Container(
              child: ListView(children: <Widget>[
        Container(
            height: Common.SpaceHeight,
            child: TextField(
              controller: timbNotImpController,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              decoration: new InputDecoration.collapsed(
                  hintText: '', border: InputBorder.none),
            )),
        Container(
          height: 60,
          child: Text(Common.gpsNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        CupertinoSwitch(
          value: isSwitched,
          onChanged: null,
          activeColor: Colors.green,
        ),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.green,
              child: Text(Common.TimbraturaGPSBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {},
            )),
        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.red,
              child: Text(Common.TimbraturaNFCBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                showLoaderDialog(context);
                try {
                  FlutterNfcReader.read(instruction: "It's reading")
                      .then((value) {
                    debugPrint(value.id);
                    _showDialogOK(
                        false, value.id.toString(), value.id.toString());
                  }).catchError(() {
                    _showDialogKO(false);
                  });
                } on Exception catch (_) {
                  _showDialogKO(false);
                }
              },
            )),
        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.red,
              child: Text(Common.AcquisizioneNFCBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                try {
                  FlutterNfcReader.read(instruction: "It's reading")
                      .then((value) {
                    debugPrint(value.id);
                  });
                } on Exception catch (_) {
                  _showDialogKO(false);
                }
              },
            )),
        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.orange,
              child: Text(Common.TimbratureBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                sendAllDataNotImported();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimbraturePage(1)),
                );
              },
            )),
        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.orange,
              child: Text(Common.AcquisizioniBtnLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                sendAllDataNotImported();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimbraturePage(1)),
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
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              label:
                  Text("", style: TextStyle(fontSize: Common.moduleFontSize)),
              icon: Icon(Icons.arrow_back, size: Common.moduleIconSize),
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
          title: new Text("Timbratura acquisita correttamente!"),
          content: new Text("" +
              ((withCoord == true)
                  ? "alle coordinate: " + lat + "," + longi
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
  Widget setupAlertDialogContainer(String lat, String longi) {
    return Container(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
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
                          size: 50, color: Colors.blueAccent)),
                  point: null,
                ),
              ],
            ),
          ],
        ));
  }
  void _showMapsWidget(bool withCoord, String lat, String longi,
      Map<String, dynamic> timb, dynamic p) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Conferma Posizione"),
          content:
              Container(
                  height: 300.0, // Change as per your requirement
                  width: 300.0, // Change as per your requirement
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
                                    size: 50, color: Colors.blueAccent)),
                            point: null,
                          ),
                        ],
                      ),
                    ],
                  )),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new MaterialButton(
              child:
                  new Text("Aggiorna", style: TextStyle(color: Colors.black)),
              onPressed: () {
                PositionRecord positionManager = new PositionRecord();
                positionManager.getStoredPosition().then((p) => setState(() {
                      if (p != null) {
                        timb["LATITUDE"] = p.latitude;
                        timb["LONGITUDE"] = p.longitude;
                        timb["TIPO_ACQUISIZIONE"] = vmode;
                        timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                          {
                            "longitudine": timb["LONGITUDE"],
                            "latitudine": timb["LATITUDE"],
                            "datetime": timb["DATETIME"],
                            "verso": timb["VERSO"]
                          }
                        ]);
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
                timb["TIPO_ACQUISIZIONE"] = vmode;
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
  void _showDialogKO(bool withCoord) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore Timbratura"),
          content: new Text("Timbratura non acquisita correttamente! " +
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
